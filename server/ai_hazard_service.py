# -*- coding: utf-8 -*-
"""AI Hazard Intelligence Service for FDA MAUDE Continuous Glucose Monitoring & AID Systems.

Integrates with Google Gemini API to analyze FDA MAUDE MDR adverse event reports
under ISO 14971 medical device risk management standards and CareSens Air / AID compatibility guidelines.
Implements Common Rules v0.3 F-4, F-5, F-8, F-11.
"""
from __future__ import annotations

import hashlib
import json
import logging
import os
import re
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

import requests
from server.db_engine import get_report_detail
from server.hazard_db import (
    ALLOWED_USE_MODES,
    USE_MODE_CONVERSION,
    calc_risk_level,
    get_hazard_conn,
    init_hazard_db,
)

log = logging.getLogger("ai_hazard_service")

BASE_DIR = Path(__file__).resolve().parent.parent

# Ordered fallback list of supported Gemini models
GEMINI_MODELS = [
    "gemini-flash-lite-latest",
    "gemini-3.5-flash-lite",
    "gemini-3.8-flash",
    "gemini-flash-latest",
]
AI_HAZARD_PROMPT_VERSION = "v0.3-maude-iso14971"

API_KEY_FILES = [
    BASE_DIR / "GEMINI_API_KEY.txt",
    BASE_DIR / ".secrets" / "GEMINI_API_KEY.txt",
    BASE_DIR / ".secrets" / "GOOGLE_AI_API_KEY.txt",
    BASE_DIR / "gemini_api_key.txt",
    BASE_DIR / "GOOGLE_API_KEY.txt",
]

AUTO_HAZARD_COLUMNS = [
    "hazard_category_primary",
    "hazard_ko",
    "initiating_event_ko",
    "hazardous_situation_ko",
    "harm_ko",
    "severity_level",
    "probability_level",
    "risk_level",
    "risk_level_raw",
    "risk_score",
    "cgm_relevance_score",
    "pump_relevance_score",
    "aid_relevance_score",
    "patient_risk_score",
    "fda_action_summary_ko",
    "care_sens_implication_ko",
    "isens_preparation_ko",
    "recommended_preventive_controls",
    "recommended_recall_controls",
]


def load_gemini_api_key() -> Optional[str]:
    """Loads Gemini API key from environment variable or local key files."""
    env_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if env_key and env_key.strip():
        return env_key.strip()

    for path in API_KEY_FILES:
        if path.exists():
            try:
                content = path.read_text(encoding="utf-8").strip()
                if content and not content.startswith("#"):
                    return content
            except Exception as e:
                log.warning(f"Failed to read key file {path}: {e}")
    return None


def get_hazard_analysis_prompt(report: Dict[str, Any]) -> str:
    """Constructs a rigorous ISO 14971 risk analysis prompt for Gemini based on a MAUDE MDR report.

    Incorporates the 3 mandatory CareSens Air / AID adoption questions & 4 unified use_mode categories (v0.3 F-4).
    """
    rep_num = report.get("report_number", "")
    brand_name = report.get("brand_name", "")
    category = report.get("device_category", "CGM")
    mfr = report.get("manufacturer_name", "")
    event_type = report.get("event_type", "")
    date_rec = report.get("date_received", "")
    date_event = report.get("date_of_event", "")
    patient_probs = report.get("patient_problems", "")
    product_probs = report.get("product_problems", "")

    # Detailed narratives
    event_desc = report.get("event_description", "") or report.get("summary_complaint_kr", "")
    mfr_narrative = report.get("manufacturer_narrative", "") or report.get("summary_response_kr", "")
    conclusion = report.get("summary_conclusion_kr", "")

    return f"""당신은 당뇨 의료기기(연속혈당측정기 CGM, 인슐린 펌프, 인공췌장 AID 시스템) 분야의 최고 의료기기 RA/QA 및 위험관리(ISO 14971:2019) 전문가입니다.

아래 제공된 FDA MAUDE(의료기기 부작용/불만 보고서) 정보를 바탕으로, 국내 선도 기업(i-SENS / CareSens Air)의 미국 FDA 510(k)/PMA 허가 및 차세대 AID 펌프 연동(iCGM) 관점에서 엄밀한 위해 요인(Hazard) 분석을 수행해주세요.

[FDA MAUDE 부작용 보고서 정보]
- MDR Report Number: {rep_num}
- 제품명 (Brand Name): {brand_name}
- 의료기기 분류 (Category): {category}
- 제조사 (Manufacturer): {mfr}
- 부작용 유형 (Event Type): {event_type}
- FDA 접수일 (Date Received): {date_rec} (사건 발생일: {date_event})
- 환자 문제 코드 (Patient Problems): {patient_probs}
- 제품 문제 코드 (Product Problems): {product_probs}
- 환자/소비자 불만 내러티브 (Event Description):
{event_desc[:2500]}
- 제조사 조사 및 평가 내러티브 (Manufacturer Narrative):
{mfr_narrative[:2500]}
- 기존 결론 요약: {conclusion}

[분석 요구사항 및 핵심 검토 3개 질문 (Section 5)]
1. 위 사건에 내재된 잠재적 위해 요인(Hazard)을 1~2개 도출하고 순번은 반드시 'HZ-01', 'HZ-02'로 부여하세요.
2. 각 위해 요인마다 ISO 14971 시퀀스(Hazard -> Initiating Event -> Hazardous Situation -> Harm)를 구체적으로 작성하세요.
3. 다음 3가지 핵심 질문에 대해 CareSens Air 관점에서 명확히 검토하여 기술하세요:
   (Q1) CareSens Air를 인슐린 펌프와 연결했을 때도 실제로 일어날 수 있는가? (CareSens Air 적용 가능성)
   (Q2) 일어나면 펌프나 펌프 앱이 잘못된 혈당값을 받아 잘못 제어할 수 있는가? (인슐린 오주입, 저·고혈당 쇼크 오제어 경로)
   (Q3) 센서 제조사인 우리 쪽에서 설계·제조 공정상 사전 차단하거나 알릴 수 있는가? (i-SENS 기구현 통제 수단)
4. 사용 모드(use_mode)는 반드시 아래 4개 표준 값 중 하나로만 지정하세요 (목록 외 값 엄격 금지):
   ['향후 AID 연동', 'CGM 단독·수동 치료', '제품 안전·임상·보호자', '펌프 단독 참고']

[출력 형식]
반드시 유효한 JSON 형식으로만 응답하세요. 백틱(```json) 없이 순수 JSON 객체만 반환하세요:
{{
  "hazards": [
    {{
      "hazard_id_local": "HZ-01",
      "hazard_category_primary": "Sensor Inaccuracy / Calibration | Wireless Communication / Signal Loss | Physical / Adhesive / Detachment | Software / Algorithm Defect | Battery / Power Failure | Biocompatibility / Skin Irritation | AID / Insulin Delivery Integration 중 택1",
      "use_mode": "향후 AID 연동 | CGM 단독·수동 치료 | 제품 안전·임상·보호자 | 펌프 단독 참고 중 택1",
      "hazard_ko": "위해 요인 명칭 (한국어 요약, 예: 센서 전극 열화로 인한 혈당치 심각한 과대평가)",
      "initiating_event_ko": "최초 유발 사건/원인 (한국어, 예: 제조 공정 중 효소 코팅 불균일 또는 체류 기간 경과)",
      "hazardous_situation_ko": "위해 상황/환자 노출 조건 (한국어, 예: 실제 저혈당(55 mg/dL)임에도 정상(110 mg/dL)으로 표시되어 환자 및 AID 알고리즘이 저혈당을 인지하지 못함)",
      "harm_ko": "환자에게 미치는 최종 상해 (한국어, 예: 중증 저혈당 쇼크, 의식 상실 또는 부적절한 인슐린 자동 주입)",
      "severity_level": "Catastrophic | Critical | Serious | Minor | Negligible 중 택1",
      "probability_level": "Frequent | Probable | Occasional | Remote | Improbable 중 택1",
      "risk_level": "High | Medium | Low 중 택1",
      "cgm_relevance_score": 1부터 5까지 정수 (CGM 관련성),
      "pump_relevance_score": 1부터 5까지 정수 (인슐린 펌프 관련성),
      "aid_relevance_score": 1부터 5까지 정수 (AID 연동 관련성),
      "patient_risk_score": 1부터 5까지 정수 (환자 직접 위험도),
      "fda_action_summary_ko": "제조사 조사 결과 및 결론 요약 (한국어)",
      "care_sens_implication_ko": "CareSens Air 개발 및 품질/RMF 관점 시사점 (Q1 적용 가능성 및 Q2 AID 오제어 경로 포함, 한국어)",
      "isens_preparation_ko": "i-SENS 사내 사전 시험평가 및 Q3 기구현/추가 필요 설계 통제 권고사항 (한국어)",
      "recommended_preventive_controls": "권장 사전 예방 설계 통제 (Preventive Controls, 한국어)",
      "recommended_recall_controls": "유사 결함 발생 시 신속 시장 조치 및 시정 방안 (한국어)"
    }}
  ]
}}
"""


def _is_hazard_protected(hazard_row: Dict[str, Any]) -> bool:
    """Checks if a hazard row has reviewer input that must NOT be overwritten (F-11 / Section 14.4).

    Aligned with Recall standards:
    Protects if ANY of the following user judgments are present:
    1. adoption_decision is set ('채택', '보류', '제외')
    2. adoption_reason or future_aid_risk is filled
    3. has_manual_override == 1 or manual_override_json is non-empty
    4. reviewer_name is filled and != '관리자 (일괄)' (individual reviewer stamp)
    """
    ad = str(hazard_row.get("adoption_decision") or "").strip()
    if ad in ("채택", "보류", "제외"):
        return True
    if str(hazard_row.get("adoption_reason") or "").strip():
        return True
    if str(hazard_row.get("future_aid_risk") or "").strip():
        return True
    if hazard_row.get("has_manual_override") or str(hazard_row.get("manual_override_json") or "").strip():
        return True
    rev = str(hazard_row.get("reviewer_name") or "").strip()
    if rev and rev != "관리자 (일괄)":
        return True
    return False


def generate_hazard_for_report(report_number: str, force_refresh: bool = False) -> Dict[str, Any]:
    """Generates on-demand ISO 14971 hazard intelligence for a specific MAUDE report.

    Implements:
    - Protected reanalysis (F-11 / Section 14.4)
    - Unreviewed rows UPSERT instead of DELETE (F-8)
    - Date standardization via collected_at & date_received (F-5)
    - 4 allowed use_mode values (F-4)
    - Raw AI logging in maude_ai_hazard_outputs (M-7)
    """
    init_hazard_db()

    # 1. Check existing hazards in maude_hazards
    existing_hazards: List[Dict[str, Any]] = []
    with get_hazard_conn(readonly=True) as conn:
        rows = conn.execute(
            "SELECT * FROM maude_hazards WHERE report_number = ? ORDER BY hazard_id_local ASC",
            (report_number,),
        ).fetchall()
        existing_hazards = [dict(r) for r in rows]

    if existing_hazards and not force_refresh:
        return {
            "success": True,
            "cached": True,
            "report_number": report_number,
            "hazards": existing_hazards,
        }

    # Check protection status if force_refresh is requested
    is_protected = any(_is_hazard_protected(h) for h in existing_hazards)

    # 2. Fetch full report details from read-only legacy DB
    report = get_report_detail(report_number)
    if not report:
        return {"success": False, "error": f"MDR report not found: {report_number}"}

    # 3. Load Gemini API key
    api_key = load_gemini_api_key()
    if not api_key:
        return {
            "success": False,
            "error": "Gemini API Key가 등록되지 않았습니다. GEMINI_API_KEY.txt 파일에 유효한 키를 확인해주세요.",
        }

    prompt = get_hazard_analysis_prompt(report)
    req_body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.2,
            "responseMimeType": "application/json",
        },
    }

    input_hash = hashlib.sha256(prompt.encode("utf-8")).hexdigest()[:16]

    resp = None
    used_model = ""
    last_err = ""

    for model_name in GEMINI_MODELS:
        api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
        try:
            r = requests.post(
                api_url,
                headers={"Content-Type": "application/json"},
                json=req_body,
                timeout=40,
            )
            if r.status_code == 200:
                resp = r
                used_model = model_name
                break
            else:
                last_err = f"Gemini API Error ({r.status_code}) on {model_name}: {r.text[:200]}"
                log.warning(last_err)
        except Exception as e:
            last_err = f"Exception on {model_name}: {e}"
            log.warning(last_err)

    if resp is None or resp.status_code != 200:
        return {"success": False, "error": last_err or "Gemini API 호출에 실패했습니다."}

    # Parse response JSON
    raw_response_text = ""
    try:
        raw_response_text = resp.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
        cleaned_text = raw_response_text
        if cleaned_text.startswith("```json"):
            cleaned_text = re.sub(r"^```json\s*", "", cleaned_text)
            cleaned_text = re.sub(r"\s*```$", "", cleaned_text)
        elif cleaned_text.startswith("```"):
            cleaned_text = re.sub(r"^```\s*", "", cleaned_text)
            cleaned_text = re.sub(r"\s*```$", "", cleaned_text)

        parsed_data = json.loads(cleaned_text)
        hazards_list = parsed_data.get("hazards", [])
        if not hazards_list and isinstance(parsed_data, list):
            hazards_list = parsed_data

    except Exception as e:
        log.error(f"Failed to parse Gemini hazard response for {report_number}: {e}")
        return {"success": False, "error": f"AI 분석 결과 JSON 파싱 실패: {e}"}

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # M-7: Record Raw AI Output in maude_ai_hazard_outputs
    try:
        with get_hazard_conn(readonly=False) as conn:
            conn.execute(
                """
                INSERT INTO maude_ai_hazard_outputs (
                    report_number, source_key, model_name, prompt_version,
                    input_hash, raw_response_json, tokens_used, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    report_number,
                    report.get("mdr_report_key") or report_number,
                    used_model,
                    AI_HAZARD_PROMPT_VERSION,
                    input_hash,
                    raw_response_text,
                    0,
                    now_str,
                ),
            )
    except Exception as e:
        log.warning(f"Failed to record raw AI output: {e}")

    # Build standardized hazard items (F-4, F-5, M-8, M-9, Risk Calculation)
    prepared_hazards: List[Dict[str, Any]] = []

    # F-5 Date Standardization:
    coll_at = report.get("collected_at") or ""
    date_rec = report.get("date_received") or ""
    first_month = coll_at[:7] if coll_at else (date_rec[:7] if date_rec else now_str[:7])
    first_ingested = coll_at or date_rec or now_str
    mdr_key = report.get("mdr_report_key") or report_number
    traceability_note = ""
    if not coll_at:
        traceability_note = "수집일시(collected_at) 부재로 위해 생성일시 대체"

    for idx, h in enumerate(hazards_list):
        hz_local = f"HZ-{idx+1:02d}"  # Standardized sequence (M-9)
        hz_row_id = f"MAUDE_{report_number}_{hz_local}"

        s_str = h.get("severity_level") or "Serious"
        p_str = h.get("probability_level") or "Occasional"
        score, level_ko = calc_risk_level(s_str, p_str)

        # F-4 Unified 4 use_mode values
        raw_mode = str(h.get("use_mode") or "").strip()
        use_mode = USE_MODE_CONVERSION.get(raw_mode, "향후 AID 연동")
        if use_mode not in ALLOWED_USE_MODES:
            use_mode = "향후 AID 연동"

        row_data = {
            "hazard_row_id": hz_row_id,
            "source_type": "MAUDE",
            "source_key": mdr_key,
            "report_number": report_number,
            "first_ingest_month": first_month,
            "first_ingested_at": first_ingested,
            "brand_name": report.get("brand_name", ""),
            "device_category": report.get("device_category", "CGM"),
            "event_type": report.get("event_type", ""),
            "date_received": date_rec,
            "manufacturer_name": report.get("manufacturer_name", ""),
            "hazard_id_local": hz_local,
            "hazard_category_primary": h.get("hazard_category_primary") or "Sensor Inaccuracy / Calibration",
            "hazard_ko": h.get("hazard_ko") or "",
            "initiating_event_ko": h.get("initiating_event_ko") or "",
            "hazardous_situation_ko": h.get("hazardous_situation_ko") or "",
            "harm_ko": h.get("harm_ko") or "",
            "severity_level": s_str,
            "probability_level": p_str,
            "risk_level": level_ko,
            "risk_level_raw": h.get("risk_level") or "Medium",
            "risk_score": score,
            "cgm_relevance_score": int(h.get("cgm_relevance_score") or 4),
            "pump_relevance_score": int(h.get("pump_relevance_score") or 3),
            "aid_relevance_score": int(h.get("aid_relevance_score") or 4),
            "patient_risk_score": int(h.get("patient_risk_score") or 3),
            "use_mode": use_mode,
            "fda_action_summary_ko": h.get("fda_action_summary_ko") or "",
            "care_sens_implication_ko": h.get("care_sens_implication_ko") or "",
            "isens_preparation_ko": h.get("isens_preparation_ko") or "",
            "recommended_preventive_controls": h.get("recommended_preventive_controls") or "",
            "recommended_recall_controls": h.get("recommended_recall_controls") or "",
            "workflow_status": "미검토",
            "adoption_decision": "",
            "adoption_reason": "",
            "future_aid_risk": "",
            "decision_reason": "",
            "ppt_include": "N",
            "ppt_id": "",
            "first_finalized_version": "",
            "finalized_version": "",
            "finalized_at": "",
            "reviewer_name": "",
            "reviewed_at": "",
            "review_note": "",
            "internal_tags": "",
            "manual_override_json": "",
            "has_manual_override": 0,
            "traceability_note_ko": traceability_note,
            "created_at": now_str,
            "updated_at": now_str,
        }
        prepared_hazards.append(row_data)

    # 4. Handle Save vs Protected Reanalysis (F-8, F-11)
    if is_protected:
        # Save to hazard_reanalysis_candidates without touching existing reviewed maude_hazards
        with get_hazard_conn(readonly=False) as conn:
            for ph in prepared_hazards:
                conn.execute(
                    """
                    INSERT INTO hazard_reanalysis_candidates (
                        report_number, hazard_row_id, new_hazard_json, reanalyzed_at, model_name, status
                    ) VALUES (?, ?, ?, ?, ?, '대기')
                    """,
                    (report_number, ph["hazard_row_id"], json.dumps(ph, ensure_ascii=False), now_str, used_model),
                )
                conn.execute(
                    """
                    INSERT INTO hazard_change_log (
                        hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                    ) VALUES (?, 'REANALYSIS_PROTECTED', 'AI_ENGINE', ?, 'reanalysis_candidates', 'existing_preserved', 'candidate_stored')
                    """,
                    (ph["hazard_row_id"], now_str),
                )

        return {
            "success": True,
            "cached": False,
            "protected": True,
            "model_used": used_model,
            "report_number": report_number,
            "message": "이미 검토 또는 채택 판단이 완료된 항목입니다. 기존 검토 데이터는 안전하게 보존되었으며, 새 AI 분석 결과는 '재분석 후보'로 별도 보관되었습니다.",
            "hazards": existing_hazards,
            "reanalysis_candidates": prepared_hazards,
        }

    # Not protected: Upsert automatic columns without deleting entire report rows (F-8)
    saved_hazards = []
    with get_hazard_conn(readonly=False) as conn:
        existing_map = {h["hazard_id_local"]: h for h in existing_hazards}
        new_locals = set()

        for ph in prepared_hazards:
            hz_local = ph["hazard_id_local"]
            new_locals.add(hz_local)
            hz_row_id = ph["hazard_row_id"]

            if hz_local in existing_map:
                old_h = existing_map[hz_local]
                update_cols = []
                update_params = []

                for col in AUTO_HAZARD_COLUMNS:
                    new_val = ph[col]
                    old_val = old_h.get(col)
                    if str(old_val or "") != str(new_val or ""):
                        conn.execute(
                            """
                            INSERT INTO hazard_change_log (
                                hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                            ) VALUES (?, 'AUTO_REANALYSIS_UPDATE', 'AI_ENGINE', ?, ?, ?, ?)
                            """,
                            (hz_row_id, now_str, col, str(old_val or ""), str(new_val or "")),
                        )
                    update_cols.append(f"{col} = ?")
                    update_params.append(new_val)

                # Keep existing use_mode if already set (Section 5 / F-3)
                if not old_h.get("use_mode"):
                    update_cols.append("use_mode = ?")
                    update_params.append(ph["use_mode"])

                update_cols.append("updated_at = ?")
                update_params.append(now_str)
                update_params.append(hz_row_id)

                sql = f"UPDATE maude_hazards SET {', '.join(update_cols)} WHERE hazard_row_id = ?"
                conn.execute(sql, update_params)

                updated_row = conn.execute("SELECT * FROM maude_hazards WHERE hazard_row_id = ?", (hz_row_id,)).fetchone()
                saved_hazards.append(dict(updated_row))
            else:
                cols = list(ph.keys())
                placeholders = ":" + ", :".join(cols)
                sql = f"INSERT INTO maude_hazards ({', '.join(cols)}) VALUES ({placeholders})"
                conn.execute(sql, ph)
                saved_hazards.append(ph)

                conn.execute(
                    """
                    INSERT INTO hazard_change_log (
                        hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                    ) VALUES (?, 'AI_GENERATE', 'AI_ENGINE', ?, 'hazard_entry', '', ?)
                    """,
                    (hz_row_id, now_str, ph["hazard_ko"][:100]),
                )

        # Trim extra old unreviewed rows if AI returned fewer hazards (e.g. 2 -> 1)
        for old_hz_local, old_h in existing_map.items():
            if old_hz_local not in new_locals:
                if not _is_hazard_protected(old_h):
                    conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id = ?", (old_h["hazard_row_id"],))
                    conn.execute(
                        """
                        INSERT INTO hazard_change_log (
                            hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                        ) VALUES (?, 'AUTO_REANALYSIS_TRIM', 'AI_ENGINE', ?, 'hazard_entry', ?, '')
                        """,
                        (old_h["hazard_row_id"], now_str, old_h.get("hazard_ko") or ""),
                    )

    return {
        "success": True,
        "cached": False,
        "protected": False,
        "model_used": used_model,
        "report_number": report_number,
        "hazards": saved_hazards,
    }


def generate_hazards_batch(report_numbers: List[str], force_refresh: bool = False) -> Dict[str, Any]:
    """Generates hazard analysis for a batch of MAUDE report numbers."""
    results = []
    success_count = 0
    fail_count = 0
    protected_count = 0

    for rep_num in report_numbers:
        res = generate_hazard_for_report(rep_num, force_refresh=force_refresh)
        results.append(res)
        if res.get("success"):
            success_count += 1
            if res.get("protected"):
                protected_count += 1
        else:
            fail_count += 1

    return {
        "total": len(report_numbers),
        "success_count": success_count,
        "protected_count": protected_count,
        "fail_count": fail_count,
        "results": results,
    }
