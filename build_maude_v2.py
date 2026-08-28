#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""openFDA 벌크 다운로드로 MAUDE DB(v2 스키마)를 재구축한다.

기존 수집기(fda_maude_collector.py)는 openFDA API 를 1,000건씩 페이지네이션해서
받는다. 수백만 건 규모에서는 요청 수와 skip 한도(25,000) 우회 로직 때문에 매우
느리다. 이 스크립트는 openFDA 가 제공하는 분기별 zip 덤프를 받아서 로컬에서
브랜드 필터를 적용한다.

v2 스키마의 핵심은 "세로 분할"이다. 대시보드의 필터/정렬/집계 질의는 짧은
메타데이터 칼럼만 읽는데, 기존 스키마는 한 행에 raw_json(약 6.8KB)까지 같이
들어 있어서 행 하나가 약 10.9KB 였다. 그래서 인덱스가 커버하지 못하는 질의는
쓰지도 않을 raw_json 을 디스크에서 끌어오느라 느렸다(실측: COUNT 하나에
5,770초). v2 는 이렇게 나눈다.

    maude_reports        약  578 B/행   필터·정렬·집계 전용
    maude_reports_text   약  912 B/행   본문 텍스트 (키워드 검색 / 상세)
    maude_reports_raw    약 2,378 B/행  raw_json zlib 압축 (상세에서 1행씩)
    maude_reports_fts                   본문 텍스트 FTS5 (external content)

사용법:
    py -3 build_maude_v2.py                    # 2020-01-01 이후 전체 재구축
    py -3 build_maude_v2.py --since 2022       # 2022년 이후만
    py -3 build_maude_v2.py --resume           # 중단된 작업 이어서
    py -3 build_maude_v2.py --limit-partitions 2   # 소량으로 시험

중단해도 안전하다. 파티션 단위로 커밋하며 완료 목록을 DB 에 기록하므로
--resume 으로 이어서 받을 수 있다.
"""
from __future__ import annotations

import argparse
import io
import json
import logging
import re
import sqlite3
import sys
import time
import zipfile
import zlib
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

import requests

# 기존 수집기의 변환 로직을 그대로 재사용한다. 같은 규칙으로 만들어야
# 대시보드가 두 경로(API/벌크)로 들어온 데이터를 구분 없이 다룰 수 있다.
import fda_maude_collector as fc

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_DB = BASE_DIR / "fda_maude_cgm_v2.db"
MANIFEST_URL = "https://api.fda.gov/download.json"

log = logging.getLogger("build_v2")


# ---------------------------------------------------------------------------
# 스키마
# ---------------------------------------------------------------------------

SCHEMA = """
-- 필터·정렬·집계 전용 좁은 테이블.
CREATE TABLE IF NOT EXISTS maude_reports (
    report_number          TEXT PRIMARY KEY,
    mdr_report_key         TEXT,
    event_type             TEXT,
    date_received          TEXT,
    date_of_event          TEXT,
    date_report            TEXT,
    brand_name             TEXT,
    device_category        TEXT,
    generic_name           TEXT,
    manufacturer_name      TEXT,
    manufacturer_country   TEXT,
    model_number           TEXT,
    product_code           TEXT,
    source_type            TEXT,
    report_source_code     TEXT,
    type_of_report         TEXT,
    patient_age            TEXT,
    patient_sex            TEXT,
    patient_ethnicity      TEXT,
    patient_race           TEXT,
    patient_weight         TEXT,
    patient_problems       TEXT,
    product_problems       TEXT,
    summary_complaint_kr   TEXT,
    summary_response_kr    TEXT,
    summary_conclusion_kr  TEXT,
    collected_at           TEXT,
    record_hash            TEXT
);

-- 본문 텍스트. rid 는 FTS5 external content 가 참조하므로 명시적으로 둔다
-- (암묵 rowid 는 VACUUM 에서 바뀔 수 있어 external content 에 쓰면 위험하다).
CREATE TABLE IF NOT EXISTS maude_reports_text (
    rid                                INTEGER PRIMARY KEY AUTOINCREMENT,
    report_number                      TEXT UNIQUE NOT NULL,
    event_description                  TEXT,
    manufacturer_narrative             TEXT,
    additional_manufacturer_narrative  TEXT
);

-- raw_json 은 상세 보기에서만 1행씩 읽으므로 분리 + zlib 압축한다.
CREATE TABLE IF NOT EXISTS maude_reports_raw (
    report_number  TEXT PRIMARY KEY,
    raw_json_z     BLOB
);

-- 월 x 브랜드 x 이벤트타입 사전집계. 대시보드는 매 로드마다 브랜드/카테고리
-- 목록을 만드는데, 이 테이블이 있으면 380만 행 대신 수천 행만 읽는다.
-- (대시보드는 테이블 존재 여부를 보고 없으면 maude_reports 로 폴백한다.)
CREATE TABLE IF NOT EXISTS maude_monthly_summary (
    month            TEXT NOT NULL,
    brand_name       TEXT NOT NULL,
    event_type       TEXT NOT NULL,
    device_category  TEXT,
    report_count     INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (month, brand_name, event_type, device_category)
);

CREATE TABLE IF NOT EXISTS load_state (
    partition_file  TEXT PRIMARY KEY,
    finished_at     TEXT,
    matched         INTEGER,
    scanned         INTEGER
);

CREATE TABLE IF NOT EXISTS collector_state (
    state_key    TEXT PRIMARY KEY,
    state_value  TEXT
);
"""

# 벌크 적재가 끝난 뒤에 만든다. 인덱스를 걸어둔 채 수백만 건을 넣으면
# 훨씬 느리기 때문이다.
INDEXES = [
    # 대시보드 주력 필터: 카테고리 + 브랜드 + 기간. 세 칼럼을 모두 담아
    # 커버링 인덱스가 되게 한다(테이블 접근 없이 인덱스만으로 처리).
    ("idx_reports_cat_brand_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_cat_brand_date "
     "ON maude_reports(device_category, brand_name, date_received)"),
    # 브랜드를 먼저 좁히는 계획을 고를 때도 커버링이 되도록 대칭 인덱스를 둔다.
    ("idx_reports_brand_date_cat",
     "CREATE INDEX IF NOT EXISTS idx_reports_brand_date_cat "
     "ON maude_reports(brand_name, date_received, device_category)"),
    # EVENT_TYPE 까지 얹은 4칼럼 버전. 카테고리+브랜드+날짜에 이벤트유형까지
    # 거는 조합이 흔한데, event_type 이 인덱스에 없으면 후보마다 테이블 행을
    # 꺼내 확인해야 해서 3조건보다 훨씬 느려진다(계획에서 COVERING 이 빠짐).
    ("idx_reports_cat_brand_date_event",
     "CREATE INDEX IF NOT EXISTS idx_reports_cat_brand_date_event "
     "ON maude_reports(device_category, brand_name, date_received, event_type)"),
    ("idx_reports_brand_date_cat_event",
     "CREATE INDEX IF NOT EXISTS idx_reports_brand_date_cat_event "
     "ON maude_reports(brand_name, date_received, device_category, event_type)"),
    # 인구통계 / 국가 집계용.
    ("idx_reports_sex_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_sex_date "
     "ON maude_reports(patient_sex, date_received)"),
    ("idx_reports_country_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_country_date "
     "ON maude_reports(manufacturer_country, date_received)"),
    ("idx_reports_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_date "
     "ON maude_reports(date_received)"),
    ("idx_reports_cat_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_cat_date "
     "ON maude_reports(device_category, date_received)"),
    ("idx_reports_event_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_event_date "
     "ON maude_reports(event_type, date_received)"),
    ("idx_reports_mfr_date",
     "CREATE INDEX IF NOT EXISTS idx_reports_mfr_date "
     "ON maude_reports(manufacturer_name, date_received)"),
    ("idx_reports_product_code",
     "CREATE INDEX IF NOT EXISTS idx_reports_product_code "
     "ON maude_reports(product_code)"),
    ("idx_reports_mdr_key",
     "CREATE INDEX IF NOT EXISTS idx_reports_mdr_key "
     "ON maude_reports(mdr_report_key)"),
]

# tokenize='trigram' 을 쓰는 이유: 대시보드의 키워드 검색은 원래
# LIKE '%단어%' 라 단어 중간부터도 걸린다. unicode61 은 토큰(단어) 단위라
# 그 의미를 재현하지 못하지만, trigram 은 부분일치를 그대로 지원한다.
# 실측(34,645행): 인덱스 1,227 B/행(370만 행 환산 4.7GB), 부분일치 질의
# 0.001초 대 LIKE 0.072초. 단, trigram 은 3글자 이상만 색인하므로 1~2글자
# 검색어는 호출부에서 LIKE 로 처리해야 한다.
FTS_SQL = """
CREATE VIRTUAL TABLE IF NOT EXISTS maude_reports_fts USING fts5(
    event_description,
    manufacturer_narrative,
    additional_manufacturer_narrative,
    content='maude_reports_text',
    content_rowid='rid',
    tokenize='trigram'
);
"""

# 최초 벌크 구축은 행마다 FTS 를 갱신하지 않고 마지막에 rebuild 하는 편이
# 빠르다. 한 번 구축한 뒤에는 아래 트리거가 증분 INSERT/UPDATE/DELETE 를
# 색인에 반영하므로, --resume 때마다 수백만 행 전체를 재색인할 필요가 없다.
FTS_TRIGGERS_SQL = """
CREATE TRIGGER IF NOT EXISTS maude_reports_text_fts_ai
AFTER INSERT ON maude_reports_text BEGIN
    INSERT INTO maude_reports_fts(
        rowid, event_description, manufacturer_narrative,
        additional_manufacturer_narrative
    ) VALUES (
        new.rid, new.event_description, new.manufacturer_narrative,
        new.additional_manufacturer_narrative
    );
END;

CREATE TRIGGER IF NOT EXISTS maude_reports_text_fts_ad
AFTER DELETE ON maude_reports_text BEGIN
    INSERT INTO maude_reports_fts(
        maude_reports_fts, rowid, event_description, manufacturer_narrative,
        additional_manufacturer_narrative
    ) VALUES (
        'delete', old.rid, old.event_description, old.manufacturer_narrative,
        old.additional_manufacturer_narrative
    );
END;

CREATE TRIGGER IF NOT EXISTS maude_reports_text_fts_au
AFTER UPDATE ON maude_reports_text BEGIN
    INSERT INTO maude_reports_fts(
        maude_reports_fts, rowid, event_description, manufacturer_narrative,
        additional_manufacturer_narrative
    ) VALUES (
        'delete', old.rid, old.event_description, old.manufacturer_narrative,
        old.additional_manufacturer_narrative
    );
    INSERT INTO maude_reports_fts(
        rowid, event_description, manufacturer_narrative,
        additional_manufacturer_narrative
    ) VALUES (
        new.rid, new.event_description, new.manufacturer_narrative,
        new.additional_manufacturer_narrative
    );
END;
"""

NARROW_COLS = [
    "report_number", "mdr_report_key", "event_type", "date_received",
    "date_of_event", "date_report", "brand_name", "device_category",
    "generic_name", "manufacturer_name", "manufacturer_country",
    "model_number", "product_code", "source_type", "report_source_code",
    "type_of_report", "patient_age", "patient_sex", "patient_ethnicity",
    "patient_race", "patient_weight", "patient_problems", "product_problems",
    "summary_complaint_kr", "summary_response_kr", "summary_conclusion_kr",
    "collected_at", "record_hash",
]


def open_db(path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(str(path), timeout=120, isolation_level=None)
    # 벌크 적재 동안에는 내구성보다 속도를 택한다. 중단되면 해당 파티션만
    # 다시 받으면 되므로(파티션 단위 커밋 + load_state) 손실이 크지 않다.
    for pragma in (
        "PRAGMA journal_mode = WAL",
        "PRAGMA synchronous = OFF",
        "PRAGMA cache_size = -1048576",
        "PRAGMA temp_store = MEMORY",
        "PRAGMA busy_timeout = 120000",
    ):
        conn.execute(pragma)
    conn.executescript(SCHEMA)
    return conn


# ---------------------------------------------------------------------------
# 매니페스트
# ---------------------------------------------------------------------------

def fetch_partitions(since_year: int) -> List[Dict[str, Any]]:
    """since_year 이후 분기와 최신 ``all_other`` 파티션을 돌려준다.

    openFDA 는 아직 정규 분기 파일로 묶이지 않은 최신 레코드를
    ``/device/event/all_other/`` 에 게시한다. 따라서 이 파티션을 빼면
    다운로드 매니페스트가 갱신되어도 DB 최신 날짜가 직전 분기 말에
    머물 수 있다. 분기 파티션을 먼저, ``all_other`` 를 마지막에 처리해
    동일 보고서가 양쪽에 있더라도 최신 덤프 내용으로 UPSERT 한다.
    """
    log.info("매니페스트 조회: %s", MANIFEST_URL)
    meta = requests.get(MANIFEST_URL, timeout=120).json()
    parts = meta["results"]["device"]["event"]["partitions"]
    picked: List[Tuple[Tuple[int, int, int], Dict[str, Any]]] = []
    for p in parts:
        url = p["file"]
        m = re.search(r"/event/(\d{4})q(\d)/[^/]*?(\d+)-of-\d+\.json\.zip", url)
        if not m:
            all_other = re.search(
                r"/event/all_other/[^/]*?(\d+)-of-\d+\.json\.zip", url
            )
            if all_other:
                # 아직 분기 파일로 확정되지 않은 최신 데이터. 항상 마지막에
                # 처리해 분기 파일과 겹치는 report_number 는 최신 값으로 갱신한다.
                picked.append(((9999, 9, int(all_other.group(1))), p))
            # device/event 이 아닌 예기치 않은 형식은 안전하게 제외한다.
            continue
        year, quarter, part = int(m.group(1)), int(m.group(2)), int(m.group(3))
        if year < since_year:
            continue
        picked.append(((year, quarter, part), p))
    picked.sort(key=lambda t: t[0])
    return [p for _, p in picked]


def is_all_other_partition(part: Dict[str, Any]) -> bool:
    """내용이 같은 URL 아래 계속 갱신되는 최신 임시 파티션인지 판정."""
    return "/device/event/all_other/" in str(part.get("file") or "")


# ---------------------------------------------------------------------------
# 레코드 매칭 (openFDA 검색식과 동일한 의미)
# ---------------------------------------------------------------------------

_MFR_NEEDLES = [m.upper() for m in fc.SEARCH_MANUFACTURERS]
_BRAND_NEEDLES = [b.upper() for b in fc.SEARCH_BRANDS]
_EVENT_TYPES = {str(e).upper() for e in (fc.EVENT_TYPES or [])}


def resolve_category(*fields: Optional[str]) -> Optional[str]:
    """brand/generic/manufacturer/product_code 로 device_category 를 정한다.

    수집기의 _resolve_device_category 는 brand_name 만 보지만, 실제 DB 는
    backfill_device_category 로 다른 칼럼까지 훑어서 채워졌다. 여기서는 그
    최종 상태를 한 번에 재현한다.
    """
    combined = " | ".join(str(f).upper() for f in fields if f)
    if not combined:
        return None
    for needle, cat in fc.BRAND_CATEGORY_MAP:
        if needle in combined:
            return cat
    return None


def matches_target(ev: Dict[str, Any]) -> bool:
    """이 이벤트를 저장할지 판정.

    openFDA 검색식(manufacturer/brand 토큰 매칭)을 그대로 흉내내면 ABBOTT
    VASCULAR 스텐트나 ABBOTT DIAGNOSTICS 분석기처럼 당뇨와 무관한 기기까지
    딸려온다(실측: 2020Q1 두 파티션에서 3,715건). 기존 DB 에는 그런 레코드가
    한 건도 없고 device_category NULL 도 0 이므로, 카테고리가 확정되는
    레코드만 남겨 같은 상태를 만든다.
    """
    if _EVENT_TYPES:
        et = str(ev.get("event_type") or "").upper()
        if et and et not in _EVENT_TYPES:
            return False
    for dev in ev.get("device") or []:
        if not isinstance(dev, dict):
            continue
        if resolve_category(
            dev.get("brand_name"),
            dev.get("generic_name"),
            dev.get("manufacturer_d_name"),
            dev.get("device_report_product_code"),
        ):
            return True
    return False


def build_rows(ev: Dict[str, Any]) -> Optional[Tuple[Tuple, Tuple, Tuple]]:
    """이벤트 하나를 (narrow, text, raw) 삽입 튜플로 변환."""
    row = fc.flatten_event(ev)
    if not row.get("report_number"):
        return None

    # flatten_event 는 brand_name 만으로 카테고리를 정한다. 비면 나머지
    # 식별 칼럼으로 한 번 더 찾아서 device_category NULL 을 남기지 않는다.
    if not row.get("device_category"):
        row["device_category"] = resolve_category(
            row.get("brand_name"), row.get("generic_name"),
            row.get("manufacturer_name"), row.get("product_code"),
        )

    # 한글 요약: 수집기 upsert_report 와 동일한 입력으로 만든다.
    mfr_text = "\n\n".join(
        p for p in [row.get("manufacturer_narrative"),
                    row.get("additional_manufacturer_narrative")] if p
    ) or None
    complaint_kr, response_kr, conclusion_kr = fc.summarize_korean(
        row.get("event_type"),
        row.get("patient_problems"),
        row.get("product_problems"),
        row.get("event_description"),
        mfr_text,
    )
    row["summary_complaint_kr"] = complaint_kr
    row["summary_response_kr"] = response_kr
    row["summary_conclusion_kr"] = conclusion_kr
    row["collected_at"] = time.strftime("%Y-%m-%dT%H:%M:%S")

    narrow = tuple(row.get(c) for c in NARROW_COLS)
    text = (
        row["report_number"],
        row.get("event_description"),
        row.get("manufacturer_narrative"),
        row.get("additional_manufacturer_narrative"),
    )
    raw_json = row.get("raw_json") or ""
    raw = (row["report_number"], zlib.compress(raw_json.encode("utf-8"), 6))
    return narrow, text, raw


# ---------------------------------------------------------------------------
# 적재
# ---------------------------------------------------------------------------

INSERT_NARROW = (
    f"INSERT INTO maude_reports ({','.join(NARROW_COLS)}) "
    f"VALUES ({','.join('?' * len(NARROW_COLS))}) "
    f"ON CONFLICT(report_number) DO UPDATE SET "
    + ", ".join(f"{c}=excluded.{c}" for c in NARROW_COLS if c != "report_number")
)
INSERT_TEXT = (
    "INSERT INTO maude_reports_text "
    "(report_number, event_description, manufacturer_narrative, "
    " additional_manufacturer_narrative) VALUES (?,?,?,?) "
    "ON CONFLICT(report_number) DO UPDATE SET "
    "event_description=excluded.event_description, "
    "manufacturer_narrative=excluded.manufacturer_narrative, "
    "additional_manufacturer_narrative=excluded.additional_manufacturer_narrative"
)
INSERT_RAW = (
    "INSERT INTO maude_reports_raw (report_number, raw_json_z) VALUES (?,?) "
    "ON CONFLICT(report_number) DO UPDATE SET raw_json_z=excluded.raw_json_z"
)


def load_partition(conn: sqlite3.Connection, part: Dict[str, Any],
                   session: requests.Session) -> Tuple[int, int]:
    """파티션 하나를 받아 적재. (스캔 건수, 매칭 건수) 반환."""
    url = part["file"]
    blob = session.get(url, timeout=900).content
    with zipfile.ZipFile(io.BytesIO(blob)) as z:
        name = z.namelist()[0]
        data = json.loads(z.read(name))
    del blob

    results = data.get("results") or []
    narrows: List[Tuple] = []
    texts: List[Tuple] = []
    raws: List[Tuple] = []
    for ev in results:
        if not matches_target(ev):
            continue
        built = build_rows(ev)
        if built is None:
            continue
        narrows.append(built[0])
        texts.append(built[1])
        raws.append(built[2])

    if narrows:
        conn.execute("BEGIN")
        conn.executemany(INSERT_NARROW, narrows)
        conn.executemany(INSERT_TEXT, texts)
        conn.executemany(INSERT_RAW, raws)
        conn.execute("COMMIT")
    return len(results), len(narrows)


def finalize(conn: sqlite3.Connection) -> None:
    """적재 후 인덱스 생성 · device_category 백필 · FTS 구축 · ANALYZE."""
    log.info("=" * 60)
    log.info("마무리 단계 시작")

    log.info("[1/5] device_category 백필")
    t = time.perf_counter()
    try:
        fc.backfill_device_category(conn)
    except Exception as e:  # noqa: BLE001
        log.warning("device_category 백필 실패(계속 진행): %s", e)
    log.info("      완료 (%.1fs)", time.perf_counter() - t)

    log.info("[2/5] 인덱스 생성 (%d개)", len(INDEXES))
    for name, sql in INDEXES:
        t = time.perf_counter()
        conn.execute(sql)
        log.info("      %-32s %.1fs", name, time.perf_counter() - t)

    log.info("[3/5] FTS5 인덱스 구축")
    t = time.perf_counter()
    fts_exists = conn.execute(
        "SELECT 1 FROM sqlite_master WHERE type='table' "
        "AND name='maude_reports_fts'"
    ).fetchone() is not None
    fts_triggers_exist = conn.execute(
        "SELECT COUNT(*) FROM sqlite_master WHERE type='trigger' "
        "AND name IN ('maude_reports_text_fts_ai', "
        "'maude_reports_text_fts_ad', 'maude_reports_text_fts_au')"
    ).fetchone()[0] == 3
    conn.executescript(FTS_SQL)
    if not fts_exists or not fts_triggers_exist:
        # 최초 구축 또는 구버전 DB 전환 시 한 번만 전체 색인을 맞춘다.
        conn.execute(
            "INSERT INTO maude_reports_fts(maude_reports_fts) VALUES('rebuild')"
        )
    else:
        log.info("      증분 FTS 트리거가 동기화한 기존 색인을 유지합니다.")
    conn.executescript(FTS_TRIGGERS_SQL)
    log.info("      완료 (%.1fs)", time.perf_counter() - t)

    log.info("[4/5] 월간 사전집계 재계산")
    t = time.perf_counter()
    conn.execute("DELETE FROM maude_monthly_summary")
    conn.execute(
        """
        INSERT INTO maude_monthly_summary
            (month, brand_name, event_type, device_category, report_count)
        SELECT substr(date_received, 1, 7),
               COALESCE(brand_name, ''),
               COALESCE(event_type, ''),
               device_category,
               COUNT(*)
          FROM maude_reports
         WHERE date_received IS NOT NULL AND date_received <> ''
         GROUP BY 1, 2, 3, 4
        """
    )
    n = conn.execute("SELECT COUNT(*) FROM maude_monthly_summary").fetchone()[0]
    log.info("      %d행 (%.1fs)", n, time.perf_counter() - t)

    log.info("[5/5] ANALYZE")
    t = time.perf_counter()
    conn.execute("ANALYZE")
    log.info("      완료 (%.1fs)", time.perf_counter() - t)

    conn.execute("PRAGMA synchronous = FULL")
    conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    log.info("마무리 단계 완료")
    log.info("=" * 60)


def main() -> int:
    ap = argparse.ArgumentParser(description="openFDA 벌크 덤프로 MAUDE v2 DB 재구축")
    ap.add_argument("--db", default=str(DEFAULT_DB), help="출력 DB 경로")
    ap.add_argument("--since", type=int, default=2020, help="이 연도부터 수집 (기본 2020)")
    ap.add_argument("--resume", action="store_true",
                    help="이미 끝난 파티션을 건너뛰고 이어서 진행")
    ap.add_argument("--limit-partitions", type=int, default=0,
                    help="처음 N개 파티션만 처리 (시험용)")
    ap.add_argument("--skip-finalize", action="store_true",
                    help="인덱스/FTS/ANALYZE 단계를 생략")
    ap.add_argument("--finalize-only", action="store_true",
                    help="적재는 건너뛰고 마무리 단계만 실행")
    args = ap.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler(BASE_DIR / "build_maude_v2.log", encoding="utf-8"),
        ],
    )

    db_path = Path(args.db)
    conn = open_db(db_path)

    if args.finalize_only:
        if args.skip_finalize:
            log.error("--finalize-only 와 --skip-finalize 는 함께 쓸 수 없습니다.")
            conn.close()
            return 2
        finalize(conn)
        conn.close()
        return 0

    parts = fetch_partitions(args.since)
    done = {r[0] for r in conn.execute("SELECT partition_file FROM load_state")}
    if args.resume and done:
        # 정규 분기 파일은 중단 복구 시 건너뛰되, all_other 는 URL이 같아도
        # 매니페스트 갱신 때 내용이 바뀌므로 항상 다시 받아 UPSERT 한다.
        before = len(parts)
        parts = [
            p for p in parts
            if p["file"] not in done or is_all_other_partition(p)
        ]
        log.info(
            "이미 완료된 정규 파티션 %d개를 건너뜁니다. "
            "all_other 파티션은 최신 내용 확인을 위해 다시 처리합니다.",
            before - len(parts),
        )
    if args.limit_partitions:
        parts = parts[: args.limit_partitions]

    total_mb = sum(float(p.get("size_mb", 0) or 0) for p in parts)
    log.info("=" * 60)
    log.info("대상 파티션: %d개, 압축 %.1f GB", len(parts), total_mb / 1024)
    log.info("출력 DB    : %s", db_path)
    log.info("=" * 60)

    session = requests.Session()
    t0 = time.perf_counter()
    tot_scanned = tot_matched = 0
    for i, p in enumerate(parts, 1):
        t = time.perf_counter()
        try:
            scanned, matched = load_partition(conn, p, session)
        except Exception as e:  # noqa: BLE001
            log.exception("파티션 실패(건너뜀): %s — %s", p["file"], e)
            continue
        tot_scanned += scanned
        tot_matched += matched
        conn.execute(
            "INSERT INTO load_state(partition_file, finished_at, matched, scanned) "
            "VALUES (?,?,?,?) ON CONFLICT(partition_file) DO UPDATE SET "
            "finished_at=excluded.finished_at, matched=excluded.matched, "
            "scanned=excluded.scanned",
            (p["file"], time.strftime("%Y-%m-%dT%H:%M:%S"), matched, scanned),
        )
        elapsed = time.perf_counter() - t0
        eta = elapsed / i * (len(parts) - i)
        log.info(
            "[%3d/%3d] %-24s 스캔 %6d → 적재 %6d  (%.1fs, 누적 %6.1f분, 남은 %5.1f분)",
            i, len(parts), p.get("display_name", "")[:24], scanned, matched,
            time.perf_counter() - t, elapsed / 60, eta / 60,
        )

    log.info("=" * 60)
    log.info("적재 완료: 스캔 %d건 → 저장 %d건 (%.1f분)",
             tot_scanned, tot_matched, (time.perf_counter() - t0) / 60)

    if not args.skip_finalize:
        finalize(conn)

    n = conn.execute("SELECT COUNT(*) FROM maude_reports").fetchone()[0]
    lo, hi = conn.execute(
        "SELECT MIN(date_received), MAX(date_received) FROM maude_reports"
    ).fetchone()
    size = db_path.stat().st_size if db_path.exists() else 0
    log.info("DB 총 보고서 : %d건", n)
    log.info("날짜 범위    : %s ~ %s", lo, hi)
    log.info("DB 크기      : %.2f GB", size / 1e9)
    conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
