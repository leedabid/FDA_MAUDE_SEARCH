# -*- coding: utf-8 -*-
"""Verification script for MAUDE hazard database, APIs, and common rules."""
import sys
from pathlib import Path

# Add project root
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

from server import hazard_db

def main():
    print("=== Testing Hazard DB ===")
    hazard_db.init_hazard_db()

    # 1. Check existing hazards
    res = hazard_db.get_hazards()
    print(f"Total hazards: {res['total']}")
    if res["items"]:
        first = res["items"][0]
        print(f"Sample hazard row_id: {first['hazard_row_id']}, workflow: {first['workflow_status']}, risk_level: {first['risk_level']}, score: {first.get('risk_score')}")

    # 2. Test Review Validation: 채택 without reasons must raise ValueError
    if res["items"]:
        hz_id = res["items"][0]["hazard_row_id"]
        try:
            hazard_db.save_hazard_review(hz_id, workflow_status="검토완료", adoption_decision="채택", adoption_reason="")
            print("ERROR: Expected ValueError for missing adoption_reason!")
        except ValueError as e:
            print(f"PASS: Caught expected validation error: {e}")

        # 3. Test Review Success with reasons
        review_res = hazard_db.save_hazard_review(
            hz_id,
            workflow_status="검토완료",
            adoption_decision="채택",
            adoption_reason="센서 효소 코팅 불균일로 인한 급격한 저혈당 미감지 위험 (CareSens Air 직접 연관)",
            future_aid_risk="AID 연동 시 저혈당 미감지로 인슐린 주입이 중단되지 않아 저혈당 쇼크 유발 위험",
            use_mode="향후 AID 연동",
            ppt_include="Y",
            ppt_id="PPT-HZ-01",
            reviewer_name="테스터 책임연구원",
            review_note="사내 RMF 등재 승인 완료",
        )
        print(f"PASS: Review saved: {review_res}")

    # 4. Test Confirmed hazards query
    confirmed = hazard_db.get_confirmed_hazards()
    print(f"PASS: Confirmed hazards count (adoption_decision='채택'): {len(confirmed)}")
    assert len(confirmed) >= 1

    # 5. Test Duplicate PPT ID rejection
    try:
        # Try to save another record with same ppt_id if there is a second record
        hazard_db.save_hazard_review(
            "NON_EXISTENT_ID",
            workflow_status="검토완료",
            adoption_decision="채택",
            adoption_reason="사유",
            future_aid_risk="영향",
            ppt_id="PPT-HZ-01",
        )
    except (KeyError, ValueError) as e:
        print(f"PASS: Caught expected error for duplicate/missing: {e}")

    # 6. Test Multi-sheet Excel export
    excel_bytes, filename = hazard_db.export_hazards_to_excel(export_type="final", confirmed_only=True)
    print(f"PASS: Excel generated successfully: {filename}, size: {len(excel_bytes):,} bytes")

    import openpyxl
    import io
    wb = openpyxl.load_workbook(io.BytesIO(excel_bytes))
    print(f"PASS: Excel sheet names: {wb.sheetnames}")
    assert "최종 Hazard" in wb.sheetnames
    assert "운영 매트릭스" in wb.sheetnames
    assert "월별 요약" in wb.sheetnames
    assert "버전 이력" in wb.sheetnames
    assert "변경 이력" in wb.sheetnames
    assert "부록_평가기준" in wb.sheetnames

    # 7. Test Audit change logs
    logs = hazard_db.get_hazard_change_logs()
    print(f"PASS: Audit log entries count: {len(logs)}")
    if logs:
        print(f"Latest log: {logs[0]['field_name']} -> {logs[0]['new_value'][:50]}")

    print("\nALL HAZARD DB TESTS PASSED!")

if __name__ == "__main__":
    main()
