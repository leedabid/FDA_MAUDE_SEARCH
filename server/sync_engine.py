# -*- coding: utf-8 -*-
"""Real-time Incremental Sync Engine for OpenFDA MAUDE Data.

Fetches newly received or changed MDR reports from OpenFDA API using
search_after cursor pagination (no 5,000/25,000 limits), performs
3-stage summarization, Annex mapping, and upserts into SQLite DB.

Key features:
1. Resilient exponential backoff retry for transient OpenFDA 500/502/503/504/429 errors.
2. Checkpoint resume: Saves next page URL without API key on every commit and automatically resumes from interrupted page.
3. Transparent step-by-step profiling: Logs exact duration for [API Fetch | Parsing | DB Insert].
4. 60-day lookback window for incremental sync to prevent missing late-arriving FDA reports.
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
from requests.adapters import HTTPAdapter
from urllib3.util import Retry

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

CHECKPOINT_PATH = BASE_DIR / ".maude_sync_checkpoint.json"


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
# Checkpoint Resume Management (중단된 지점 이어받기)
# ---------------------------------------------------------------------------
def _sanitize_url_for_checkpoint(url: str) -> str:
    """URL에서 api_key 파라미터를 안전하게 제거하여 파일에 키가 남지 않도록 함"""
    parsed = urllib.parse.urlparse(url)
    qs = urllib.parse.parse_qs(parsed.query)
    qs.pop("api_key", None)
    new_query = urllib.parse.urlencode(qs, doseq=True)
    return urllib.parse.urlunparse(parsed._replace(query=new_query))


def save_checkpoint(
    search_query: str,
    mode: str,
    next_url: Optional[str],
    page: int,
    total_target: int,
    total_fetched: int,
    inserted_count: int,
    start_date_str: str,
    end_date_str: str,
):
    """각 페이지 DB 커밋 완료 후 다음 페이지 커서 주소를 파일에 기록"""
    if not next_url:
        clear_checkpoint()
        return
    try:
        clean_url = _sanitize_url_for_checkpoint(next_url)
        data = {
            "search_query": search_query,
            "mode": mode,
            "next_url": clean_url,
            "page": page,
            "total_target": total_target,
            "processed_count": total_fetched,
            "inserted_count": inserted_count,
            "start_date_str": start_date_str,
            "end_date_str": end_date_str,
            "updated_at": datetime.now().isoformat(),
        }
        with open(CHECKPOINT_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception as e:
        log.warning("Failed to save sync checkpoint: %s", e)


def load_checkpoint(search_query: str) -> Optional[Dict[str, Any]]:
    """동일한 쿼리로 진행 중단된 체크포인트가 있으면 복원"""
    if not CHECKPOINT_PATH.exists():
        return None
    try:
        with open(CHECKPOINT_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
        if data.get("search_query") == search_query and data.get("next_url"):
            return data
    except Exception as e:
        log.warning("Failed to load sync checkpoint: %s", e)
    return None


def clear_checkpoint():
    """동기화 성공 또는 취소 시 체크포인트 파일 삭제"""
    if CHECKPOINT_PATH.exists():
        try:
            CHECKPOINT_PATH.unlink()
        except Exception:
            pass


def get_max_db_date() -> str:
    """DB에서 가장 최근 date_received 값을 고속으로 조회 (0.01초 소요)"""
    try:
        conn = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro", uri=True, timeout=30.0)
        conn.execute("PRAGMA busy_timeout = 30000")
        # 1. 월별 서머리 테이블을 통한 최신 월 확인
        max_m = conn.execute("SELECT max(month) FROM maude_monthly_summary").fetchone()[0]
        if max_m:
            row = conn.execute(
                "SELECT max(date_received) FROM maude_reports WHERE date_received >= ?",
                (f"{max_m}-01",)
            ).fetchone()
            if row and row[0]:
                conn.close()
                return str(row[0])
        
        # 2. 폴백: 최근 연도 필터링으로 인덱스 활용
        row = conn.execute("SELECT max(date_received) FROM maude_reports WHERE date_received >= '2024-01-01'").fetchone()
        conn.close()
        return str(row[0]) if row and row[0] else "2024-01-01"
    except Exception as e:
        log.warning("Failed to get max db date: %s", e)
        return "2024-01-01"


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
    max_retries: int = 8,
) -> Tuple[Dict[str, Any], Optional[str]]:
    """OpenFDA API 호출 및 search_after 다음 페이지 URL 반환.
    
    OpenFDA 서버의 일시적인 500/502/503/504/429 오류 및 네트워크 지연 발생 시
    지수 백오프로 최대 8회 자동 재시도하여 대량 수집이 중단되지 않도록 보호합니다.
    """
    if api_key and "api_key=" not in url:
        sep = "&" if "?" in url else "?"
        url = f"{url}{sep}api_key={api_key}"

    headers = {
        "User-Agent": "FDA-MAUDE-Surveillance-Sync/2.0",
        "Accept": "application/json",
    }
    
    last_err: Optional[Exception] = None
    last_status = None

    for attempt in range(1, max_retries + 1):
        try:
            resp = session.get(url, headers=headers, timeout=60)
            last_status = resp.status_code

            if resp.status_code == 200:
                if attempt > 1:
                    _log(f"✅ OpenFDA 재시도 성공! (시도 {attempt}회 만에 정상 복구)")
                next_link = parse_next_link(resp.headers.get("Link"))
                return resp.json(), next_link

            if resp.status_code == 404:
                # 검색 결과 0건
                return {"meta": {"results": {"total": 0}}, "results": []}, None

            if resp.status_code == 429:
                wait_sec = min(5.0 * attempt, 30.0)
                _log(f"⚠️ OpenFDA API 속도 제한(429) 감지. {wait_sec:.0f}초 대기 후 자동 재시도... ({attempt}/{max_retries})")
                time.sleep(wait_sec)
                continue

            if resp.status_code in (500, 502, 503, 504):
                wait_sec = min(2.0 * (2 ** (attempt - 1)), 45.0)
                _log(f"⚠️ OpenFDA 서버 일시 오류 (HTTP {resp.status_code}: Service Unavailable). {wait_sec:.0f}초 후 자동 재시도... ({attempt}/{max_retries})")
                time.sleep(wait_sec)
                continue

            # 기타 HTTP 오류
            wait_sec = min(2.0 * attempt, 20.0)
            _log(f"⚠️ OpenFDA 응답 상태 이상 (HTTP {resp.status_code}). {wait_sec:.0f}초 후 재시도... ({attempt}/{max_retries})")
            time.sleep(wait_sec)

        except (requests.exceptions.RequestException, Exception) as exc:
            last_err = exc
            wait_sec = min(2.0 * (2 ** (attempt - 1)), 45.0)
            _log(f"⚠️ OpenFDA 네트워크 통신 지연 ({exc.__class__.__name__}). {wait_sec:.0f}초 후 재시도... ({attempt}/{max_retries})")
            time.sleep(wait_sec)

    if last_status:
        raise RuntimeError(f"OpenFDA HTTP {last_status}: Service Unavailable (총 {max_retries}회 재시도 실패)")
    raise RuntimeError(f"OpenFDA 통신 실패: {last_err}")


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

    _log("🚀 OpenFDA 데이터 수집 및 동기화 시작")

    session = requests.Session()
    adapter = HTTPAdapter(pool_connections=10, pool_maxsize=10)
    session.mount("https://", adapter)
    session.mount("http://", adapter)

    try:
        # 1. 수집 대상 날짜 범위 결정
        max_db_date = await asyncio.to_thread(get_max_db_date)
        _log(f"📊 현재 로컬 DB 최신 접수일자: {max_db_date}")

        if mode == "incremental":
            last_dt = datetime.strptime(max_db_date, "%Y-%m-%d")
            # openFDA 지연 보고서(Late-arriving reports) 누락 방지를 위해 최근 접수일 기준 60일 전부터 겹쳐서 수집
            start_dt = last_dt - timedelta(days=60)
            start_date_str = start_dt.strftime("%Y%m%d")
            end_date_str = datetime.now().strftime("%Y%m%d")
            _log(f"📌 최신 증분 수집 범위: {start_date_str} ~ {end_date_str} (기존 최신일 {max_db_date} 기준 지연보고 60일 윈도우 적용)")
        else:
            raw_start = str(date_from or "2024-01-01")
            raw_end = str(date_to or datetime.now().strftime("%Y-%m-%d"))
            start_date_str = re.sub(r"[^0-9]", "", raw_start)[:8]
            end_date_str = re.sub(r"[^0-9]", "", raw_end)[:8]
            if len(start_date_str) < 8:
                start_date_str = "20240101"
            if len(end_date_str) < 8:
                end_date_str = datetime.now().strftime("%Y%m%d")
            _log(f"📌 기간 지정 수집 범위: {start_date_str} ~ {end_date_str} (입력: {raw_start} ~ {raw_end})")

        # 2. 브랜드별 쿼리 생성
        if categories and "CGM" in categories and "Insulin Pump" not in categories:
            brand_terms = 'device.brand_name:dexcom device.brand_name:libre'
        elif categories and "Insulin Pump" in categories and "CGM" not in categories:
            brand_terms = 'device.brand_name:omnipod device.brand_name:medtronic device.brand_name:tandem'
        else:
            brand_terms = 'device.brand_name:dexcom device.brand_name:libre device.brand_name:omnipod device.brand_name:medtronic device.brand_name:tandem'

        search_query = f'({brand_terms}) AND (date_received:[{start_date_str} TO {end_date_str}])'

        _log(f"🔍 OpenFDA 쿼리: {search_query}")
        SYNC_STATE["current_step"] = "OpenFDA 대상 건수 확인 및 체크포인트 검사 중..."

        limit = 1000 if api_key else 100
        initial_params = {
            "search": search_query,
            "limit": limit,
        }
        if api_key:
            initial_params["api_key"] = api_key

        current_url: Optional[str] = f"https://api.fda.gov/device/event.json?{urllib.parse.urlencode(initial_params)}"

        total_target = 0
        total_fetched = 0
        page = 1

        # 3. 이전 중단 지점(체크포인트) 확인 및 이어받기 복원
        checkpoint = load_checkpoint(search_query)
        if checkpoint:
            current_url = checkpoint["next_url"]
            page = checkpoint.get("page", 1)
            total_target = checkpoint.get("total_target", 0)
            total_fetched = checkpoint.get("processed_count", 0)
            SYNC_STATE["total_target"] = total_target
            SYNC_STATE["processed_count"] = total_fetched
            SYNC_STATE["inserted_count"] = checkpoint.get("inserted_count", 0)
            _log(f"🔄 이전 중단 지점 발견! [페이지 {page}] ({total_fetched:,}건 수집 완료 시점)부터 이어서 수집을 재개합니다.")

        # 4. search_after 커서 페이징을 통한 전수 수집 및 DB 저장
        from build_maude_v2 import build_rows, INSERT_NARROW, INSERT_TEXT, INSERT_RAW

        # DB 커넥션 설정 (타임아웃 120초 및 고속 WAL / synchronous=OFF 설정)
        write_conn = sqlite3.connect(str(DB_PATH), timeout=120.0, isolation_level=None)
        write_conn.execute("PRAGMA journal_mode = WAL")
        write_conn.execute("PRAGMA synchronous = OFF")
        write_conn.execute("PRAGMA busy_timeout = 120000")
        write_conn.execute("PRAGMA cache_size = -1048576")
        write_conn.execute("PRAGMA temp_store = MEMORY")

        try:
            while current_url:
                t0_net = time.time()
                resp_json, next_link = await asyncio.to_thread(fetch_openfda_url, session, current_url, api_key)
                t_net = time.time() - t0_net

                if page == 1 and not checkpoint:
                    total_target = resp_json.get("meta", {}).get("results", {}).get("total", 0)
                    SYNC_STATE["total_target"] = total_target
                    _log(f"📊 수집 대상 총 보고서: {total_target:,}건")

                    if total_target == 0:
                        _log(f"✅ openFDA에 해당 기간({start_date_str} ~ {end_date_str})의 신규 보고서가 없습니다. DB가 이미 openFDA 최신 상태와 동일합니다.")
                        _log("💡 참고: FDA MAUDE 서버는 통상 1~2개월 단위 시차를 두고 신규 데이터를 일괄 업로드합니다.")
                        SYNC_STATE["current_step"] = "동기화 완료 (신규 데이터 없음)"
                        clear_checkpoint()
                        SYNC_STATE["is_running"] = False
                        return
                    else:
                        _log(f"🔄 search_after 커서 페이징으로 전수 {total_target:,}건을 순차 수집합니다.")

                results = resp_json.get("results", [])
                if not results:
                    break

                # 행 변환 및 3단계 요약
                t0_parse = time.time()
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
                t_parse = time.time() - t0_parse

                # DB 일괄 저장 (FTS/Index 동기화)
                t0_db = time.time()
                if narrows:
                    for attempt in range(5):
                        try:
                            write_conn.execute("BEGIN IMMEDIATE")
                            write_conn.executemany(INSERT_NARROW, narrows)
                            write_conn.executemany(INSERT_TEXT, texts)
                            write_conn.executemany(INSERT_RAW, raws)
                            write_conn.execute("COMMIT")
                            break
                        except sqlite3.OperationalError as db_err:
                            if ("locked" in str(db_err) or "busy" in str(db_err)) and attempt < 4:
                                try:
                                    write_conn.execute("ROLLBACK")
                                except Exception:
                                    pass
                                await asyncio.sleep(1.0 * (attempt + 1))
                            else:
                                raise

                    SYNC_STATE["inserted_count"] += len(narrows)
                t_db = time.time() - t0_db

                total_fetched += len(results)
                SYNC_STATE["processed_count"] = total_fetched
                progress_pct = (total_fetched / total_target * 100) if total_target > 0 else 100
                SYNC_STATE["current_step"] = f"데이터 수집 중 ({total_fetched:,}건 / 총 {total_target:,}건, {progress_pct:.1f}%)..."
                _log(f"📥 [페이지 {page}] {len(results):,}건 수집 반영 (누적: {total_fetched:,} / {total_target:,}건, {progress_pct:.1f}%) [API: {t_net:.1f}s | 변환: {t_parse:.1f}s | DB: {t_db:.1f}s]")

                # 체크포인트 기록 (인증키 제외)
                save_checkpoint(
                    search_query=search_query,
                    mode=mode,
                    next_url=next_link,
                    page=page + 1,
                    total_target=total_target,
                    total_fetched=total_fetched,
                    inserted_count=SYNC_STATE["inserted_count"],
                    start_date_str=start_date_str,
                    end_date_str=end_date_str,
                )

                current_url = next_link
                page += 1
                await asyncio.sleep(0.05 if api_key else 0.35)

            # 5. 업데이트된 기간의 월별 요약 테이블 재색인
            SYNC_STATE["current_step"] = "시계열 요약 통계(maude_monthly_summary) 재색인 중..."
            _log("📊 월별 통계 서머리 테이블 갱신 중...")
            start_ym = f"{start_date_str[:4]}-{start_date_str[4:6]}"
            end_ym = f"{end_date_str[:4]}-{end_date_str[4:6]}"
            
            write_conn.execute("BEGIN IMMEDIATE")
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
            write_conn.execute("COMMIT")

            # 전체 수집 성공 시 체크포인트 파일 제거
            clear_checkpoint()

        finally:
            try:
                write_conn.close()
            except Exception:
                pass

        # 캐시 무효화
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
        _log(f"❌ 동기화 중단: {e}")
        _log("💡 다시 [DB 갱신]을 실행하시면 중단된 마지막 페이지부터 자동으로 이어서 수집됩니다.")
    finally:
        SYNC_STATE["is_running"] = False