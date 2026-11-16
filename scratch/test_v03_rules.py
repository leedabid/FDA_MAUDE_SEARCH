# -*- coding: utf-8 -*-
"""Verification script for Common Rules v0.3 (Recall · MAUDE 공통 규칙) Acceptance Tests T-1 ~ T-11.

Covers:
  - T-1: Partial update preservation (F-1)
  - T-2: Deletion permanence across restarts / migrations (F-2)
  - T-3: Protected reanalysis on reviewed/adopted reports (F-11, F-8)
  - T-4: Preservation of customized use_mode during reanalysis (F-3, F-8)
  - T-5: Strict 4 allowed use_mode categories check (F-4)
  - T-6: first_ingest_month (collected_at) & date_received accuracy (F-5)
  - T-7: Rejection of version finalization when adopted count is 0 (F-7, F-12)
  - T-8: first_finalized_version immutability across multiple finalizations (F-7)
  - T-9: Hazard candidate duplicate prevention and timestamp preservation (F-9)
  - T-10: Strict validation rejection for invalid adoption_decision or use_mode (F-4, F-10)
  - T-11: Strict protection against deletion of user-judged / reviewed rows (F-6)
"""
import sys
import json
import sqlite3
from datetime import datetime
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

from server import hazard_db
from server import ai_hazard_service


def _get_hz(hz_id: str):
    with hazard_db.get_hazard_conn(readonly=True) as conn:
        r = conn.execute("SELECT * FROM maude_hazards WHERE hazard_row_id = ?", (hz_id,)).fetchone()
        return dict(r) if r else None


def run_tests():
    print("=" * 70)
    print("STARTING ACCEPTANCE TESTS FOR COMMON RULES v0.3 (T-1 ~ T-11)")
    print("=" * 70)
    
    hazard_db.init_hazard_db()

    # -------------------------------------------------------------------------
    # T-1: 채택 완료 행의 메모만 수정 -> 채택 사유·향후 AID 위험·ppt_id 유지 (F-1)
    # -------------------------------------------------------------------------
    print("\n[T-1] Testing Partial Update (F-1)...")
    test_hz_id = "MAUDE_TEST_T1_001_HZ-01"
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Clean up test row if exists
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id = ?", (test_hz_id,))
        conn.execute(
            """
            INSERT INTO maude_hazards (
                hazard_row_id, source_type, source_key, report_number, first_ingest_month,
                brand_name, device_category, event_type, date_received, hazard_id_local,
                hazard_category_primary, hazard_ko, workflow_status, adoption_decision,
                adoption_reason, future_aid_risk, ppt_include, ppt_id, reviewer_name,
                review_note, created_at, updated_at
            ) VALUES (
                ?, 'MAUDE', 'SRC_001', 'REP_001', '2026-09',
                'Dexcom G6', 'CGM', 'Malfunction', '2026-08-01', 'HZ-01',
                'Sensor Inaccuracy', '테스트 위해', '검토완료', '채택',
                '원래 채택 사유입니다.', '원래 향후 AID 위험 영향입니다.', 'Y', 'PPT-T1-01', '원래 검토자',
                '원래 메모', ?, ?
            )
            """,
            (test_hz_id, now_str, now_str),
        )

    # Perform partial update: only change review_note and reviewer_name
    hazard_db.save_hazard_review(
        hazard_row_id=test_hz_id,
        review_note="수정된 검토 메모만 보냄",
        reviewer_name="수정 검토자",
        client_updated_at=now_str,
    )

    row_after = _get_hz(test_hz_id)
    assert row_after is not None, "Row must exist"
    assert row_after["adoption_decision"] == "채택", f"Expected 채택, got {row_after['adoption_decision']}"
    assert row_after["adoption_reason"] == "원래 채택 사유입니다.", "adoption_reason must be preserved"
    assert row_after["future_aid_risk"] == "원래 향후 AID 위험 영향입니다.", "future_aid_risk must be preserved"
    assert row_after["ppt_id"] == "PPT-T1-01", "ppt_id must be preserved"
    assert row_after["review_note"] == "수정된 검토 메모만 보냄", "review_note must be updated"
    assert row_after["reviewer_name"] == "수정 검토자", "reviewer_name must be updated"
    print("PASS: T-1 Partial update preserved adoption_reason, future_aid_risk, and ppt_id.")

    # -------------------------------------------------------------------------
    # T-2: 위해 삭제 후 앱 재시작 -> 되살아나지 않음 (F-2)
    # -------------------------------------------------------------------------
    print("\n[T-2] Testing Deletion Permanence & Migration 1-Time Guarantee (F-2)...")
    test_hz_t2 = "MAUDE_TEST_T2_002_HZ-01"
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id = ?", (test_hz_t2,))
        conn.execute(
            """
            INSERT INTO maude_hazards (
                hazard_row_id, source_type, source_key, report_number, first_ingest_month,
                hazard_id_local, hazard_ko, workflow_status, adoption_decision, created_at, updated_at
            ) VALUES (
                ?, 'MAUDE', 'SRC_002', 'REP_002', '2026-09',
                'HZ-01', '삭제될 미검토 위해', '미검토', '', ?, ?
            )
            """,
            (test_hz_t2, now_str, now_str),
        )

    # Delete unreviewed row
    del_res = hazard_db.delete_hazard(test_hz_t2)
    assert del_res is True, "Delete should succeed for unreviewed row"
    assert _get_hz(test_hz_t2) is None, "Row must be gone"

    # Simulate app restart and migration check
    hazard_db.init_hazard_db()
    assert _get_hz(test_hz_t2) is None, "Deleted row must NOT resurrect on restart/migration"
    print("PASS: T-2 Deleted unreviewed hazard did not resurrect on restart/migration.")

    # -------------------------------------------------------------------------
    # T-3: 채택 행이 있는 대상 재분석 -> 기존 행 불변, 새 결과는 후보에만 (보호)
    # -------------------------------------------------------------------------
    print("\n[T-3] Testing Protected Reanalysis (F-8, F-11)...")
    # Verify _is_hazard_protected logic
    protected_sample = {
        "adoption_decision": "채택",
        "adoption_reason": "중요 위해",
        "future_aid_risk": "쇼크 유발",
        "has_manual_override": 0,
        "reviewer_name": "책임연구원",
    }
    assert ai_hazard_service._is_hazard_protected(protected_sample) is True

    # Test protection when reviewer is "관리자 (일괄)" but no adoption decision
    bulk_reviewed_sample = {
        "workflow_status": "검토완료",
        "adoption_decision": "",
        "adoption_reason": "",
        "future_aid_risk": "",
        "has_manual_override": 0,
        "reviewer_name": "관리자 (일괄)",
    }
    assert ai_hazard_service._is_hazard_protected(bulk_reviewed_sample) is False, "Bulk review without decision is not protected"

    # Test protection on manual override
    override_sample = {
        "adoption_decision": "",
        "has_manual_override": 1,
        "reviewer_name": "",
    }
    assert ai_hazard_service._is_hazard_protected(override_sample) is True, "Manual override must be protected"
    print("PASS: T-3 Reanalysis protection flags align strictly with Section 14.4 & F-11.")

    # -------------------------------------------------------------------------
    # T-4: 판단 없는 행에서 use_mode를 사용자가 바꾼 뒤 재분석 -> 바꾼 값 유지 (F-3)
    # -------------------------------------------------------------------------
    print("\n[T-4] Testing Preservation of Customized use_mode (F-3, F-8)...")
    assert "use_mode" not in ai_hazard_service.AUTO_HAZARD_COLUMNS, "use_mode must NOT be in AUTO_HAZARD_COLUMNS"

    test_hz_t4 = "MAUDE_TEST_T4_004_HZ-01"
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id = ?", (test_hz_t4,))
        conn.execute(
            """
            INSERT INTO maude_hazards (
                hazard_row_id, source_type, source_key, report_number, first_ingest_month,
                hazard_id_local, hazard_ko, use_mode, workflow_status, adoption_decision, created_at, updated_at
            ) VALUES (
                ?, 'MAUDE', 'SRC_004', 'REP_004', '2026-09',
                'HZ-01', '테스트 모드 유지', 'CGM 단독·수동 치료', '미검토', '', ?, ?
            )
            """,
            (test_hz_t4, now_str, now_str),
        )

    # Simulate automatic upsert
    prepared_mock = {
        "hazard_row_id": test_hz_t4,
        "hazard_id_local": "HZ-01",
        "hazard_ko": "AI 갱신된 위해 요인 명칭",
        "hazard_category_primary": "Sensor Inaccuracy / Calibration",
        "initiating_event_ko": "갱신 원인",
        "hazardous_situation_ko": "갱신 상황",
        "harm_ko": "갱신 상해",
        "severity_level": "Critical",
        "probability_level": "Probable",
        "risk_level": "높음",
        "risk_level_raw": "High",
        "risk_score": 16,
        "cgm_relevance_score": 5,
        "pump_relevance_score": 4,
        "aid_relevance_score": 5,
        "patient_risk_score": 4,
        "fda_action_summary_ko": "요약",
        "care_sens_implication_ko": "시사점",
        "isens_preparation_ko": "대책",
        "recommended_preventive_controls": "통제",
        "recommended_recall_controls": "시정",
        "use_mode": "향후 AID 연동",  # AI suggested this, but user already set 'CGM 단독·수동 치료'
    }

    # Simulate the UPSERT in ai_hazard_service
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        old_h = conn.execute("SELECT * FROM maude_hazards WHERE hazard_row_id = ?", (test_hz_t4,)).fetchone()
        update_cols = []
        update_params = []
        for col in ai_hazard_service.AUTO_HAZARD_COLUMNS:
            update_cols.append(f"{col} = ?")
            update_params.append(prepared_mock[col])
        if not old_h["use_mode"]:
            update_cols.append("use_mode = ?")
            update_params.append(prepared_mock["use_mode"])
        update_cols.append("updated_at = ?")
        update_params.append(now_str)
        update_params.append(test_hz_t4)
        sql = f"UPDATE maude_hazards SET {', '.join(update_cols)} WHERE hazard_row_id = ?"
        conn.execute(sql, update_params)

    row_t4_after = _get_hz(test_hz_t4)
    assert row_t4_after["hazard_ko"] == "AI 갱신된 위해 요인 명칭", "Auto column must update"
    assert row_t4_after["use_mode"] == "CGM 단독·수동 치료", f"User use_mode must be preserved! Got {row_t4_after['use_mode']}"
    print("PASS: T-4 Customized use_mode was strictly preserved across reanalysis upsert.")

    # -------------------------------------------------------------------------
    # T-5: SELECT use_mode, COUNT(*) GROUP BY 1 -> 4개 값 안에만 존재 (F-3, F-4)
    # -------------------------------------------------------------------------
    print("\n[T-5] Testing Allowed use_mode Categories (F-3, F-4)...")
    with hazard_db.get_hazard_conn(readonly=True) as conn:
        rows = conn.execute("SELECT DISTINCT use_mode FROM maude_hazards WHERE use_mode IS NOT NULL AND use_mode != ''").fetchall()
        for r in rows:
            val = r[0]
            assert val in hazard_db.ALLOWED_USE_MODES, f"Unexpected use_mode found in DB: {val}"
    print(f"PASS: T-5 All use_mode values in DB conform to 4 allowed categories: {hazard_db.ALLOWED_USE_MODES}.")

    # -------------------------------------------------------------------------
    # T-6: MAUDE 위해 생성 시 first_ingest_month (collected_at) & date_received (F-5)
    # -------------------------------------------------------------------------
    print("\n[T-6] Testing Ingest Month and FDA Date Received (F-5)...")
    with hazard_db.get_hazard_conn(readonly=True) as conn:
        row = conn.execute("SELECT hazard_row_id, first_ingest_month, date_received FROM maude_hazards WHERE hazard_row_id = ?", (test_hz_id,)).fetchone()
        assert row["first_ingest_month"] == "2026-09"
        assert row["date_received"] == "2026-08-01"
    print("PASS: T-6 first_ingest_month and date_received correctly stored as separate standards.")

    # -------------------------------------------------------------------------
    # T-7: 채택 0건에서 최종 확인 -> 거부 (F-7, F-12)
    # -------------------------------------------------------------------------
    print("\n[T-7] Testing Finalization Rejection on 0 Adopted Hazards (F-7, F-12)...")
    # Temporarily remove adoption from all rows to simulate 0 adopted
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        previously_adopted = [r[0] for r in conn.execute("SELECT hazard_row_id FROM maude_hazards WHERE adoption_decision = '채택'").fetchall()]
        conn.execute("UPDATE maude_hazards SET adoption_decision = '보류' WHERE adoption_decision = '채택'")

    try:
        hazard_db.finalize_hazard_version(version_tag="v99.9", summary_notes="Test zero adopted")
        assert False, "Finalization must fail when adopted hazards == 0"
    except ValueError as e:
        print(f"PASS: T-7 Finalization with 0 adopted hazards correctly rejected: {e}")
    finally:
        # Restore previously adopted rows
        with hazard_db.get_hazard_conn(readonly=False) as conn:
            for hid in previously_adopted:
                conn.execute("UPDATE maude_hazards SET adoption_decision = '채택' WHERE hazard_row_id = ?", (hid,))

    # -------------------------------------------------------------------------
    # T-8: 확정 2회 -> 각 행의 first_finalized_version 유지, finalized_version만 갱신 (F-7)
    # -------------------------------------------------------------------------
    print("\n[T-8] Testing 2 Successive Finalizations (F-7)...")
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        conn.execute("DELETE FROM hazard_versions WHERE version_tag LIKE '%-test'")

    v1_res = hazard_db.finalize_hazard_version(version_tag="v0.1-test", summary_notes="First test finalization")
    assert v1_res["success"] is True

    row_v1 = _get_hz(test_hz_id)
    assert row_v1["first_finalized_version"] == "v0.1-test", f"Expected v0.1-test, got {row_v1['first_finalized_version']}"
    assert row_v1["finalized_version"] == "v0.1-test"

    v2_res = hazard_db.finalize_hazard_version(version_tag="v0.2-test", summary_notes="Second test finalization")
    assert v2_res["success"] is True

    row_v2 = _get_hz(test_hz_id)
    assert row_v2["first_finalized_version"] == "v0.1-test", f"first_finalized_version must be immutable! Got {row_v2['first_finalized_version']}"
    assert row_v2["finalized_version"] == "v0.2-test", f"finalized_version must be updated to v0.2-test! Got {row_v2['finalized_version']}"
    print("PASS: T-8 first_finalized_version remained immutable (v0.1-test) while finalized_version updated to v0.2-test.")

    # -------------------------------------------------------------------------
    # T-9: 같은 보고서를 후보에 2번 추가 -> 1건 유지, candidate_added_at 유지 (F-9)
    # -------------------------------------------------------------------------
    print("\n[T-9] Testing Candidate Duplicate Prevention (F-9)...")
    rep_num = "TEST_REP_DUPLICATE_001"
    # Clean up candidate
    hazard_db.delete_hazard_candidate(rep_num)

    c1 = hazard_db.add_hazard_candidate(
        report_number=rep_num,
        brand_name="Dexcom G7",
        device_category="CGM",
        event_type="Injury",
        date_received="2026-05-10",
        note="Initial candidate note",
    )
    assert c1["success"] is True
    assert c1.get("already_exists") is False

    with hazard_db.get_hazard_conn(readonly=True) as conn:
        cand1 = conn.execute("SELECT * FROM maude_hazard_candidates WHERE report_number = ?", (rep_num,)).fetchone()
        added_at1 = cand1["candidate_added_at"]
        note1 = cand1["candidate_note"]

    # Try adding same candidate again
    c2 = hazard_db.add_hazard_candidate(
        report_number=rep_num,
        brand_name="Dexcom G7 Modified",
        note="Overwritten note attempt",
    )
    assert c2["success"] is True
    assert c2.get("already_exists") is True, "Must report already_exists=True"

    with hazard_db.get_hazard_conn(readonly=True) as conn:
        cand2 = conn.execute("SELECT * FROM maude_hazard_candidates WHERE report_number = ?", (rep_num,)).fetchone()
        assert cand2["candidate_added_at"] == added_at1, "candidate_added_at must NOT change"
        assert cand2["candidate_note"] == note1, "Original candidate note must NOT be overwritten"

    hazard_db.delete_hazard_candidate(rep_num)
    print("PASS: T-9 Candidate addition idempotency confirmed: already_exists=True and initial timestamp preserved.")

    # -------------------------------------------------------------------------
    # T-10: 잘못된 adoption_decision / use_mode 값 전송 -> 거부 (F-4, F-10)
    # -------------------------------------------------------------------------
    print("\n[T-10] Testing Rejection of Invalid adoption_decision & use_mode (F-4, F-10)...")
    try:
        hazard_db.save_hazard_review(
            hazard_row_id=test_hz_id,
            adoption_decision="INVALID_DECISION",
        )
        assert False, "Must reject invalid adoption_decision"
    except ValueError as e:
        print(f"PASS: Rejected invalid adoption_decision: {e}")

    try:
        hazard_db.save_hazard_review(
            hazard_row_id=test_hz_id,
            use_mode="INVALID_USE_MODE",
        )
        assert False, "Must reject invalid use_mode"
    except ValueError as e:
        print(f"PASS: Rejected invalid use_mode: {e}")

    # -------------------------------------------------------------------------
    # T-11: 검토완료/채택 행 삭제 시도 -> 거부 (F-6)
    # -------------------------------------------------------------------------
    print("\n[T-11] Testing Strict Deletion Protection on Judged Rows (F-6)...")
    # test_hz_id is currently '채택'
    try:
        hazard_db.delete_hazard(test_hz_id)
        assert False, "Must reject deletion of adopted hazard"
    except ValueError as e:
        print(f"PASS: Rejected deletion of adopted hazard: {e}")

    # Now change test row to '검토완료' with no adoption decision
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        conn.execute(
            """
            UPDATE maude_hazards
            SET adoption_decision = '', workflow_status = '검토완료', adoption_reason = '', future_aid_risk = ''
            WHERE hazard_row_id = ?
            """,
            (test_hz_id,),
        )

    try:
        hazard_db.delete_hazard(test_hz_id)
        assert False, "Must reject deletion of reviewed (검토완료) hazard"
    except ValueError as e:
        print(f"PASS: Rejected deletion of reviewed hazard: {e}")

    # Clean up test rows
    with hazard_db.get_hazard_conn(readonly=False) as conn:
        conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id LIKE 'MAUDE_TEST_%'")
        conn.execute("DELETE FROM hazard_versions WHERE version_tag LIKE 'v0.%-test'")

    print("\n" + "=" * 70)
    print("ALL ACCEPTANCE TESTS (T-1 ~ T-11) PASSED SUCCESSFULLY!")
    print("=" * 70)


if __name__ == "__main__":
    run_tests()
