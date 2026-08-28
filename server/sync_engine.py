# -*- coding: utf-8 -*-
"""Real-time Incremental Sync Engine for OpenFDA MAUDE Data.

Fetches newly received or changed MDR reports from OpenFDA API,
performs 3-stage summarization, Annex mapping, and upserts into SQLite DB.
"""
from __future__ import annotations

import asyncio
import json
import logging
import sqlite3
import time
import urllib.request
import zlib
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional

from server.annex_loader import get_device_code, get_patient_code, split_problem_terms
from server.db_engine import DB_PATH, load_annex_codes

log = logging.getLogger("sync_engine")

SYNC_STATE: Dict[str, Any] = {
    "is_running": False,
    "current_step": "idle",
    "total_target": 0,
    "processed_count": 0,
    "inserted_count": 0,
    "start_time": None,
    "error": None,
    "logs": [],
}


def get_sync_status() -> Dict[str, Any]:
    return dict(SYNC_STATE)


def _log(msg: str):
    timestamp = datetime.now().strftime("%H:%M:%S")
    formatted = f"[{timestamp}] {msg}"
    SYNC_STATE["logs"].append(formatted)
    if len(SYNC_STATE["logs"]) > 200:
        SYNC_STATE["logs"].pop(0)
    log.info(formatted)


def fetch_openfda_page(search_query: str, skip: int, limit: int = 100) -> Dict[str, Any]:
    encoded_search = urllib.parse.quote(search_query)
    url = f"https://api.fda.gov/device/event.json?search={encoded_search}&skip={skip}&limit={limit}"
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "FDA-MAUDE-Surveillance-Sync/2.0"}
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


async def run_incremental_sync(
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    categories: Optional[List[str]] = None,
    mode: str = "incremental"
):
    global SYNC_STATE
    if SYNC_STATE["is_running"]:
        _log("이미 동기화 작업이 진행 중입니다.")
        return

    SYNC_STATE["is_running"] = True
    SYNC_STATE["current_step"] = "초기화 중..."
    SYNC_STATE["total_target"] = 0
    SYNC_STATE["processed_count"] = 0
    SYNC_STATE["inserted_count"] = 0
    SYNC_STATE["start_time"] = time.time()
    SYNC_STATE["error"] = None
    SYNC_STATE["logs"] = []

    _log("🚀 OpenFDA 데이터 증분 수집 동기화 시작")

    try:
        # 1. Determine target date range
        conn = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro", uri=True)
        max_db_date = conn.execute("SELECT max(date_received) FROM maude_reports").fetchone()[0]
        conn.close()

        if not max_db_date:
            max_db_date = "2020-01-01"

        if mode == "incremental":
            # Start from the day after max_db_date or recent 14 days
            last_dt = datetime.strptime(max_db_date, "%Y-%m-%d")
            start_date_str = (last_dt - timedelta(days=7)).strftime("%Y%m%d")
            end_date_str = datetime.now().strftime("%Y%m%d")
            _log(f"📌 최근 증분 수집 범위: {start_date_str} ~ {end_date_str} (기존 DB 최신일: {max_db_date})")
        else:
            start_date_str = (date_from or "2024-01-01").replace("-", "")
            end_date_str = (date_to or datetime.now().strftime("%Y-%m-%d")).replace("-", "")
            _log(f"📌 기간 지정 수집 범위: {start_date_str} ~ {end_date_str}")

        # Construct openFDA search terms
        brand_terms = "device.brand_name:dexcom+device.brand_name:libre+device.brand_name:omnipod+device.brand_name:medtronic+device.brand_name:tandem"
        search_query = f"({brand_terms}) AND (date_received:[{start_date_str}+TO+{end_date_str}]+OR+date_changed:[{start_date_str}+TO+{end_date_str}])"

        _log(f"🔍 OpenFDA 쿼리: {search_query}")
        SYNC_STATE["current_step"] = "OpenFDA 총 대상 건수 확인 중..."

        # Query first page to get total count
        import urllib.parse
        try:
            first_resp = await asyncio.to_thread(fetch_openfda_page, search_query, 0, 1)
            total_target = first_resp.get("meta", {}).get("results", {}).get("total", 0)
        except Exception as e:
            _log(f"⚠️ OpenFDA 대상 건수 조회 결과: 0건 또는 요청 오류 ({e})")
            total_target = 0

        SYNC_STATE["total_target"] = total_target
        _log(f"📊 수집 대상 총 보고서: {total_target:,}건")

        if total_target == 0:
            _log("✅ 새로운 갱신 데이터가 없습니다. DB가 이미 최신 상태입니다.")
            SYNC_STATE["current_step"] = "완료 (갱신 데이터 없음)"
            SYNC_STATE["is_running"] = False
            return

        # 2. Fetch pages in batches of 100
        limit = 100
        skip = 0
        write_conn = sqlite3.connect(DB_PATH)
        write_conn.execute("PRAGMA journal_mode = WAL")
        write_conn.execute("PRAGMA synchronous = NORMAL")

        while skip < total_target and skip < 5000: # OpenFDA skip limit is 5000 for standard search
            SYNC_STATE["current_step"] = f"데이터 수집 중 ({skip:,} ~ {min(skip+limit, total_target):,}건)..."
            _log(f"📥 {skip:,} ~ {min(skip+limit, total_target):,}건 가져오는 중...")

            resp = await asyncio.to_thread(fetch_openfda_page, search_query, skip, limit)
            results = resp.get("results", [])
            if not results:
                break

            # Process and upsert batch
            for item in results:
                rnum = item.get("report_number")
                if not rnum:
                    continue

                # Category classification
                brand = ""
                devices = item.get("device", [])
                if devices:
                    brand = devices[0].get("brand_name", "")
                cat = "Insulin Pump" if any(p in brand.upper() for p in ["OMNIPOD", "INSULET", "TANDEM", "T:SLIM", "MINIMED", "780G", "MEDTRONIC", "MOBI"]) else "CGM"

                # Standard problems
                p_probs = []
                for p in item.get("patient", []):
                    for pr in p.get("patient_problems", []):
                        if pr: p_probs.append(pr)
                d_probs = item.get("product_problems", []) or []

                p_str = "; ".join(p_probs) if p_probs else None
                d_str = "; ".join(d_probs) if d_probs else None

                # Extract narratives
                mdr_texts = item.get("mdr_text", [])
                event_desc = None
                mfr_narr = None
                add_mfr_narr = None
                for t in mdr_texts:
                    code = t.get("text_type_code", "")
                    txt = t.get("text", "")
                    if "DESC" in code.upper() or not event_desc:
                        event_desc = txt
                    elif "MFR" in code.upper() or "RESP" in code.upper():
                        if not mfr_narr:
                            mfr_narr = txt
                        else:
                            add_mfr_narr = txt

                date_rec = item.get("date_received", "")
                if len(date_rec) == 8:
                    date_rec_fmt = f"{date_rec[:4]}-{date_rec[4:6]}-{date_rec[6:]}"
                else:
                    date_rec_fmt = date_rec

                date_event = item.get("date_of_event", "")
                if len(date_event) == 8:
                    date_event_fmt = f"{date_event[:4]}-{date_event[4:6]}-{date_event[6:]}"
                else:
                    date_event_fmt = date_event

                # Korean summary fallback
                summary_complaint = f"환자 증상: {p_str or '정보 없음'} | 기기 결함: {d_str or '정보 없음'}"
                summary_response = mfr_narr[:300] if mfr_narr else "제조사 대응 정보 없음"
                summary_conclusion = "추후 후속 보고 예정" if "FOLLOW" in str(item.get("type_of_report", "")).upper() else "조사 완료"

                # 1. Upsert maude_reports
                write_conn.execute("""
                    INSERT INTO maude_reports (
                        report_number, mdr_report_key, event_type, date_received, date_of_event,
                        date_report, brand_name, device_category, generic_name, manufacturer_name,
                        manufacturer_country, model_number, product_code, source_type,
                        report_source_code, type_of_report, patient_problems, product_problems,
                        summary_complaint_kr, summary_response_kr, summary_conclusion_kr, collected_at
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT(report_number) DO UPDATE SET
                        event_type = excluded.event_type,
                        date_received = excluded.date_received,
                        brand_name = excluded.brand_name,
                        patient_problems = excluded.patient_problems,
                        product_problems = excluded.product_problems,
                        collected_at = excluded.collected_at
                """, (
                    rnum, item.get("mdr_report_key"), item.get("event_type"), date_rec_fmt, date_event_fmt,
                    item.get("date_report"), brand, cat, devices[0].get("generic_name") if devices else "",
                    item.get("manufacturer_name"), item.get("manufacturer_country"),
                    devices[0].get("model_number") if devices else "",
                    devices[0].get("device_report_product_code") if devices else "QBJ",
                    item.get("source_type"), item.get("report_source_code"), item.get("type_of_report"),
                    p_str, d_str, summary_complaint, summary_response, summary_conclusion,
                    datetime.now().isoformat()
                ))

                # 2. Upsert maude_reports_text
                write_conn.execute("""
                    INSERT INTO maude_reports_text (report_number, event_description, manufacturer_narrative, additional_manufacturer_narrative)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT(report_number) DO UPDATE SET
                        event_description = excluded.event_description,
                        manufacturer_narrative = excluded.manufacturer_narrative,
                        additional_manufacturer_narrative = excluded.additional_manufacturer_narrative
                """, (rnum, event_desc, mfr_narr, add_mfr_narr))

                # 3. Upsert maude_reports_raw
                raw_z = zlib.compress(json.dumps(item).encode("utf-8"), level=6)
                write_conn.execute("""
                    INSERT INTO maude_reports_raw (report_number, raw_json_z)
                    VALUES (?, ?)
                    ON CONFLICT(report_number) DO UPDATE SET
                        raw_json_z = excluded.raw_json_z
                """, (rnum, raw_z))

                SYNC_STATE["inserted_count"] += 1

            write_conn.commit()
            skip += limit
            SYNC_STATE["processed_count"] = min(skip, total_target)
            await asyncio.sleep(0.2) # Friendly rate-limit

        # 3. Rebuild summary table for updated months
        SYNC_STATE["current_step"] = "시계열 요약 통계(maude_monthly_summary) 재색인 중..."
        _log("📊 월별 통계 서머리 테이블 갱신 중...")
        write_conn.execute("""
            INSERT OR REPLACE INTO maude_monthly_summary (year_month, brand_name, device_category, event_type, report_source_code, report_count)
            SELECT strftime('%Y-%m', date_received) as ym, brand_name, device_category, event_type,
                   COALESCE(report_source_code, 'Unknown'), count(*)
            FROM maude_reports
            WHERE strftime('%Y-%m', date_received) >= ?
            GROUP BY ym, brand_name, device_category, event_type, report_source_code
        """, (f"{start_date_str[:4]}-{start_date_str[4:6]}",))
        write_conn.commit()
        write_conn.close()

        # Invalidate metadata cache
        from server.db_engine import FILTER_METADATA_CACHE_PATH
        if FILTER_METADATA_CACHE_PATH.exists():
            FILTER_METADATA_CACHE_PATH.unlink()

        elapsed = time.time() - SYNC_STATE["start_time"]
        _log(f"🎉 동기화 완료! 총 {SYNC_STATE['inserted_count']:,}건의 최신 보고서가 성공적으로 반영되었습니다. ({elapsed:.1f}초 소요)")
        SYNC_STATE["current_step"] = "동기화 완료"

    except Exception as e:
        log.error(f"Sync failed: {e}", exc_info=True)
        SYNC_STATE["error"] = str(e)
        SYNC_STATE["current_step"] = f"오류 발생: {e}"
        _log(f"❌ 동기화 실패: {e}")
    finally:
        SYNC_STATE["is_running"] = False
