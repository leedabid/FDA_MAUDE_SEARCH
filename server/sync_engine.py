# -*- coding: utf-8 -*-
"""Real-time Incremental Sync Engine for OpenFDA MAUDE Data.

Fetches newly received or changed MDR reports from OpenFDA API using
search_after cursor pagination (no 5,000/25,000 limits), performs
3-stage summarization, Annex mapping, and upserts into SQLite DB.
"""
from __future__ import annotations

import asyncio
import json
import logging
import os
import re
import sqlite3
import time
import urllib.parse
import zlib
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests

from server.annex_loader import get_device_code, get_patient_code, split_problem_terms
from server.db_engine import BASE_DIR, DB_PATH, load_annex_codes

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

API_KEY_FILES: List[Path] = [
    BASE_DIR / "FDA_MAUDE_API_KEY.txt",
    BASE_DIR / "api_key.txt",
]


def load_api_key() -> Optional[str]:
    for p in API_KEY_FILES:
        if p.exists():
            try:
                key = p.read_text(encoding="utf-8").strip()
                if key and len(key) >= 10:
                    return key
            except Exception:
                pass
    return None


def get_sync_status() -> Dict[str, Any]:
    return dict(SYNC_STATE)


def _log(msg: str):
    timestamp = datetime.now().strftime("%H:%M:%S")
    formatted = f"[{timestamp}] {msg}"
    SYNC_STATE["logs"].append(formatted)
    if len(SYNC_STATE["logs"]) > 2000:
        SYNC_STATE["logs"].pop(0)
    log.info(formatted)


# ---------------------------------------------------------------------------
# Korean Keyword Summarizer
# ---------------------------------------------------------------------------
try:
    from fda_maude_collector import summarize_korean as _summarize_korean_fn
    from fda_maude_collector import _resolve_device_category as _resolve_cat_fn
except ImportError:
    def _resolve_cat_fn(brand_name: Optional[str]) -> str:
        if not brand_name:
            return "CGM"
        b_upper = brand_name.upper()
        if any(p in b_upper for p in ["OMNIPOD", "INSULET", "TANDEM", "T:SLIM", "MINIMED", "780G", "MEDTRONIC", "MOBI"]):
            return "Insulin Pump"
        return "CGM"

    def _summarize_korean_fn(event_type, p_prob, d_prob, desc, mfr):
        complaint = f"환자 문제: {p_prob or '없음'} | 기기 문제: {d_prob or '없음'}"
        response = mfr[:200] if mfr else "제조사 대응 정보 없음"
        verdict = event_type or "보고 접수"
        return complaint, response, verdict


def parse_next_link(link_header: Optional[str]) -> Optional[str]:
    """HTTP Link 헤더에서 rel='next' URL을 추출"""
    if not link_header:
        return None
    links = link_header.split(",")
    for link in links:
        match = re.search(r'<([^>]+)>;\s*rel="next"', link.strip())
        if match:
            return match.group(1)
    return None


def fetch_openfda_url(
    session: requests.Session,
    url: str,
    api_key: Optional[str] = None,
) -> Tuple[Dict[str, Any], Optional[str]]:
    """OpenFDA API 호출 및 search_after 다음 페이지 URL 반환"""
    if api_key and "api_key=" not in url:
        sep = "&" if "?" in url else "?"
        url = f"{url}{sep}api_key={api_key}"

    headers = {
        "User-Agent": "FDA-MAUDE-Surveillance-Sync/2.0",
        "Accept": "application/json",
    }
    resp = session.get(url, headers=headers, timeout=45)
    if resp.status_code == 404:
        return {"meta": {"results": {"total": 0}}, "results": []}, None
    if resp.status_code == 429:
        time.sleep(5)
        resp = session.get(url, headers=headers, timeout=45)
    if resp.status_code != 200:
        raise RuntimeError(f"OpenFDA HTTP {resp.status_code}: {resp.text[:300]}")

    next_link = parse_next_link(resp.headers.get("Link"))
    return resp.json(), next_link


async def run_incremental_sync(
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    categories: Optional[List[str]] = None,
    mode: str = "incremental"
):
    global SYNC_STATE
    if SYNC_STATE["is_running"]:
        _log("⚠️ 이미 동기화 작업이 진행 중입니다.")
        return

    SYNC_STATE["is_running"] = True
    SYNC_STATE["current_step"] = "초기화 중..."
    SYNC_STATE["total_target"] = 0
    SYNC_STATE["processed_count"] = 0
    SYNC_STATE["inserted_count"] = 0
    SYNC_STATE["start_time"] = time.time()
    SYNC_STATE["error"] = None
    SYNC_STATE["logs"] = []

    api_key = load_api_key()
    if api_key:
        _log(f"🔑 FDA API Key 로드 완료 (끝 4자리: ...{api_key[-4:]})")
    else:
        _log("⚠️ API Key가 없습니다. (요청 속도가 제한될 수 있습니다)")

    _log("🚀 OpenFDA 데이터 증분 수집 동기화 시작")

    session = requests.Session()

    try:
        # 1. 수집 대상 날짜 범위 결정
        conn = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro", uri=True)
        max_db_date = conn.execute("SELECT max(date_received) FROM maude_reports").fetchone()[0]
        conn.close()

        if not max_db_date:
            max_db_date = "2020-01-01"

        if mode == "incremental":
            last_dt = datetime.strptime(max_db_date, "%Y-%m-%d")
            # 지연 보고서를 포괄하기 위해 마지막 접수일 7일 전부터 수집
            start_date_str = (last_dt - timedelta(days=7)).strftime("%Y%m%d")
            end_date_str = datetime.now().strftime("%Y%m%d")
            _log(f"📌 최근 증분 수집 범위: {start_date_str} ~ {end_date_str} (기존 DB 최신 접수일: {max_db_date})")
        else:
            raw_start = str(date_from or "2024-01-01")
            raw_end = str(date_to or datetime.now().strftime("%Y-%m-%d"))
            start_date_str = re.sub(r"[^0-9]", "", raw_start)[:8]
            end_date_str = re.sub(r"[^0-9]", "", raw_end)[:8]
            if len(start_date_str) < 8:
                start_date_str = "20240101"
            if len(end_date_str) < 8:
                end_date_str = datetime.now().strftime("%Y%m%d")
            _log(f"📌 기간 지정 수집 범위: {start_date_str} ~ {end_date_str} (입력값: {raw_start} ~ {raw_end})")

        # 2. 브랜드별 쿼리 생성
        if categories and "CGM" in categories and "Insulin Pump" not in categories:
            brand_terms = 'device.brand_name:dexcom device.brand_name:libre'
        elif categories and "Insulin Pump" in categories and "CGM" not in categories:
            brand_terms = 'device.brand_name:omnipod device.brand_name:medtronic device.brand_name:tandem'
        else:
            brand_terms = 'device.brand_name:dexcom device.brand_name:libre device.brand_name:omnipod device.brand_name:medtronic device.brand_name:tandem'

        search_query = f'({brand_terms}) AND (date_received:[{start_date_str} TO {end_date_str}])'

        _log(f"🔍 OpenFDA 쿼리: {search_query}")
        SYNC_STATE["current_step"] = "OpenFDA 대상 건수 확인 중..."

        limit = 1000 if api_key else 100
        initial_params = {
            "search": search_query,
            "limit": limit,
            "sort": "date_received:asc"
        }
        if api_key:
            initial_params["api_key"] = api_key

        current_url: Optional[str] = f"https://api.fda.gov/device/event.json?{urllib.parse.urlencode(initial_params)}"

        # 3. search_after 커서 페이징을 통한 전수 수집 및 DB 저장
        from build_maude_v2 import build_rows, INSERT_NARROW, INSERT_TEXT, INSERT_RAW

        write_conn = sqlite3.connect(DB_PATH)
        total_target = 0
        total_fetched = 0
        page = 1

        try:
            write_conn.execute("PRAGMA journal_mode = WAL")
            write_conn.execute("PRAGMA synchronous = NORMAL")
            write_conn.execute("PRAGMA cache_size = -1048576")
            write_conn.execute("PRAGMA temp_store = MEMORY")

            while current_url:
                resp_json, next_link = await asyncio.to_thread(fetch_openfda_url, session, current_url, api_key)

                if page == 1:
                    total_target = resp_json.get("meta", {}).get("results", {}).get("total", 0)
                    SYNC_STATE["total_target"] = total_target
                    _log(f"📊 수집 대상 총 보고서: {total_target:,}건")

                    if total_target == 0:
                        _log("✅ 새로운 갱신 데이터가 없습니다. DB가 이미 openFDA 최신 상태와 동일합니다.")
                        SYNC_STATE["current_step"] = "완료 (갱신 데이터 없음)"
                        SYNC_STATE["is_running"] = False
                        return
                    else:
                        _log(f"🔄 search_after 커서 페이징으로 전수 {total_target:,}건을 제한 없이 순차 수집합니다.")

                results = resp_json.get("results", [])
                if not results:
                    break

                # 행 변환 및 DB Upsert
                narrows = []
                texts = []
                raws = []
                for item in results:
                    try:
                        row_data = build_rows(item)
                        if not row_data:
                            continue
                        n, t, r = row_data
                        narrows.append(n)
                        texts.append(t)
                        raws.append(r)
                    except Exception as row_err:
                        log.warning("Row parse skipped: %s", row_err)

                if narrows:
                    write_conn.executemany(INSERT_NARROW, narrows)
                    write_conn.executemany(INSERT_TEXT, texts)
                    write_conn.executemany(INSERT_RAW, raws)
                    write_conn.commit()
                    SYNC_STATE["inserted_count"] += len(narrows)

                total_fetched += len(results)
                SYNC_STATE["processed_count"] = total_fetched
                SYNC_STATE["current_step"] = f"데이터 수집 중 ({total_fetched:,}건 / 총 {total_target:,}건 완료)..."
                _log(f"📥 [페이지 {page}] {len(results):,}건 수집 반영 (누적: {total_fetched:,} / {total_target:,}건)")

                current_url = next_link
                page += 1
                await asyncio.sleep(0.05 if api_key else 0.35)

            # 4. 업데이트된 기간의 월별 요약 테이블 재색인
            SYNC_STATE["current_step"] = "시계열 요약 통계(maude_monthly_summary) 재색인 중..."
            _log("📊 월별 통계 서머리 테이블 갱신 중...")
            start_ym = f"{start_date_str[:4]}-{start_date_str[4:6]}"
            end_ym = f"{end_date_str[:4]}-{end_date_str[4:6]}"
            write_conn.execute("DELETE FROM maude_monthly_summary WHERE month >= ? AND month <= ?", (start_ym, end_ym))
            write_conn.execute("""
                INSERT INTO maude_monthly_summary
                    (month, brand_name, event_type, device_category, report_count)
                SELECT substr(date_received, 1, 7) AS month,
                       COALESCE(brand_name, '') AS brand_name,
                       COALESCE(event_type, '') AS event_type,
                       device_category,
                       COUNT(*) AS report_count
                  FROM maude_reports
                 WHERE date_received IS NOT NULL AND date_received <> ''
                   AND substr(date_received, 1, 7) >= ?
                   AND substr(date_received, 1, 7) <= ?
                 GROUP BY 1, 2, 3, 4
            """, (start_ym, end_ym))
            write_conn.commit()
        finally:
            write_conn.close()

        # 캐시 초기화
        from server.db_engine import FILTER_METADATA_CACHE_PATH
        if FILTER_METADATA_CACHE_PATH.exists():
            try:
                FILTER_METADATA_CACHE_PATH.unlink()
            except Exception:
                pass

        elapsed = time.time() - SYNC_STATE["start_time"]
        _log(f"🎉 동기화 완료! 총 {SYNC_STATE['inserted_count']:,}건의 보고서가 성공적으로 반영되었습니다. ({elapsed:.1f}초 소요)")
        SYNC_STATE["current_step"] = "동기화 완료"

    except Exception as e:
        log.error(f"Sync failed: {e}", exc_info=True)
        SYNC_STATE["error"] = str(e)
        SYNC_STATE["current_step"] = f"오류 발생: {e}"
        _log(f"❌ 동기화 실패: {e}")
    finally:
        SYNC_STATE["is_running"] = False