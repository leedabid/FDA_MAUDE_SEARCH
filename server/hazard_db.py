# -*- coding: utf-8 -*-
"""Dedicated SQLite Database & Repository for ISO 14971 MAUDE Hazards.

Isolates all hazard intelligence, reviewer decisions, audit logs, and versioning
into a lightweight, separate database file (`maude_hazard.db`) away from the
large 30GB read-only `fda_maude_cgm_v2.db`.
Implements Common Rules v0.3 F-1, F-2, F-4, F-5, F-6, F-7, F-9, F-10.
"""
from __future__ import annotations

import json
import logging
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

log = logging.getLogger("hazard_db")

BASE_DIR = Path(__file__).resolve().parent.parent
HAZARD_DB_PATH = BASE_DIR / "maude_hazard.db"
LEGACY_MAUDE_DB_PATH = BASE_DIR / "fda_maude_cgm_v2.db"

# ---------------------------------------------------------------------------
# Common Rules v0.3 Allowed Values & Mapping Standards (Section 2, 4, 5)
# ---------------------------------------------------------------------------
ALLOWED_ADOPTION_DECISIONS = ["", "채택", "보류", "제외"]

ALLOWED_USE_MODES = [
    "향후 AID 연동",
    "CGM 단독·수동 치료",
    "제품 안전·임상·보호자",
    "펌프 단독 참고",
]

USE_MODE_CONVERSION = {
    "향후 AID 연동": "향후 AID 연동",
    "AID": "향후 AID 연동",
    "Both": "향후 AID 연동",
    "CGM 단독 사용": "CGM 단독·수동 치료",
    "CGM 단독·수동 치료": "CGM 단독·수동 치료",
    "CGM-only": "CGM 단독·수동 치료",
    "센서 삽입/부착": "제품 안전·임상·보호자",
    "모바일 앱/UI": "제품 안전·임상·보호자",
    "클라우드 동기화": "제품 안전·임상·보호자",
    "제품 안전·임상·보호자": "제품 안전·임상·보호자",
    "펌프 단독 참고": "펌프 단독 참고",
}

# ISO 14971 Risk Calculation Standards (Section 4)
SEVERITY_SCORES: Dict[str, int] = {
    "catastrophic": 5, "5": 5, "치명적": 5,
    "critical": 4, "4": 4, "위험": 4,
    "serious": 3, "3": 3, "심각": 3,
    "minor": 2, "2": 2, "경미": 2,
    "negligible": 1, "1": 1, "미미": 1,
}

PROBABILITY_SCORES: Dict[str, int] = {
    "frequent": 5, "5": 5, "빈번": 5,
    "probable": 4, "4": 4, "가능성높음": 4,
    "occasional": 3, "3": 3, "간헐적": 3,
    "remote": 2, "2": 2, "희박": 2,
    "improbable": 1, "1": 1, "거의없음": 1,
}


def calc_risk_level(severity_str: str, probability_str: str) -> Tuple[int, str]:
    """Calculates ISO 14971 score (1~25) and returns standardized Korean level: 높음/중간/낮음."""
    s_val = SEVERITY_SCORES.get(str(severity_str).strip().lower(), 3)
    p_val = PROBABILITY_SCORES.get(str(probability_str).strip().lower(), 3)
    score = s_val * p_val

    # Thresholds: 1~7 낮음 / 8~14 중간 / 15~25 높음
    if score >= 15:
        level_ko = "높음"
    elif score >= 8:
        level_ko = "중간"
    else:
        level_ko = "낮음"
    return score, level_ko


# ---------------------------------------------------------------------------
# Connection Manager
# ---------------------------------------------------------------------------
def get_hazard_conn(readonly: bool = False) -> sqlite3.Connection:
    """Connects to `maude_hazard.db` with WAL mode and 30-second busy timeout."""
    if readonly:
        conn = sqlite3.connect(f"{HAZARD_DB_PATH.as_uri()}?mode=ro", uri=True, timeout=30.0)
    else:
        conn = sqlite3.connect(HAZARD_DB_PATH, timeout=30.0)

    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA busy_timeout = 30000")
    if not readonly:
        conn.execute("PRAGMA journal_mode = WAL")
        conn.execute("PRAGMA synchronous = NORMAL")
    return conn


def init_hazard_db() -> None:
    """Initializes tables, indexes, runs 1-time migrations safely (F-2, F-4, F-5, F-7)."""
    with get_hazard_conn(readonly=False) as conn:
        # 1. Master Hazards Table
        conn.execute("""
            CREATE TABLE IF NOT EXISTS maude_hazards (
                hazard_row_id TEXT PRIMARY KEY,
                source_type TEXT DEFAULT 'MAUDE',
                source_key TEXT NOT NULL,
                report_number TEXT NOT NULL,
                first_ingest_month TEXT,
                first_ingested_at TEXT,
                brand_name TEXT,
                device_category TEXT,
                event_type TEXT,
                date_received TEXT,
                manufacturer_name TEXT,
                hazard_id_local TEXT,
                hazard_category_primary TEXT,
                hazard_ko TEXT,
                initiating_event_ko TEXT,
                hazardous_situation_ko TEXT,
                harm_ko TEXT,
                severity_level TEXT,
                probability_level TEXT,
                risk_level TEXT,
                risk_level_raw TEXT,
                risk_score INTEGER DEFAULT 0,
                cgm_relevance_score INTEGER DEFAULT 0,
                pump_relevance_score INTEGER DEFAULT 0,
                aid_relevance_score INTEGER DEFAULT 0,
                patient_risk_score INTEGER DEFAULT 0,
                use_mode TEXT DEFAULT '향후 AID 연동',
                fda_action_summary_ko TEXT,
                care_sens_implication_ko TEXT,
                isens_preparation_ko TEXT,
                recommended_preventive_controls TEXT,
                recommended_recall_controls TEXT,
                workflow_status TEXT DEFAULT '미검토',
                adoption_decision TEXT DEFAULT '',
                adoption_reason TEXT DEFAULT '',
                future_aid_risk TEXT DEFAULT '',
                decision_reason TEXT DEFAULT '',
                ppt_include TEXT DEFAULT 'N',
                ppt_id TEXT DEFAULT '',
                first_finalized_version TEXT DEFAULT '',
                finalized_version TEXT DEFAULT '',
                finalized_at TEXT DEFAULT '',
                reviewer_name TEXT DEFAULT '',
                reviewed_at TEXT DEFAULT '',
                review_note TEXT DEFAULT '',
                internal_tags TEXT DEFAULT '',
                manual_override_json TEXT DEFAULT '',
                has_manual_override INTEGER DEFAULT 0,
                traceability_note_ko TEXT DEFAULT '',
                created_at TEXT,
                updated_at TEXT
            )
        """)
        conn.execute("CREATE INDEX IF NOT EXISTS idx_hz_rep_num ON maude_hazards(report_number)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_hz_workflow ON maude_hazards(workflow_status)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_hz_adoption ON maude_hazards(adoption_decision)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_hz_risk_score ON maude_hazards(risk_score)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_hz_ppt_id ON maude_hazards(ppt_id)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_hz_date_rec ON maude_hazards(date_received)")

        # Ensure first_finalized_version column exists for existing tables (F-7)
        cur = conn.execute("PRAGMA table_info(maude_hazards)")
        cols = [r[1] for r in cur.fetchall()]
        if "first_finalized_version" not in cols:
            conn.execute("ALTER TABLE maude_hazards ADD COLUMN first_finalized_version TEXT DEFAULT ''")
        if "traceability_note_ko" not in cols:
            conn.execute("ALTER TABLE maude_hazards ADD COLUMN traceability_note_ko TEXT DEFAULT ''")

        # 2. Metadata / Migration Tracking Table (F-2)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS maude_hazard_meta (
                meta_key TEXT PRIMARY KEY,
                meta_value TEXT,
                updated_at TEXT
            )
        """)

        # 3. Candidate Selection Table (Section 6.2, 14.2, F-9)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS maude_hazard_candidates (
                report_number TEXT PRIMARY KEY,
                source_key TEXT,
                brand_name TEXT,
                device_category TEXT,
                event_type TEXT,
                date_received TEXT,
                candidate_added_at TEXT,
                candidate_status TEXT DEFAULT '대기',
                candidate_note TEXT DEFAULT ''
            )
        """)

        # 4. Raw AI Response Table (Section 15.2 M-7)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS maude_ai_hazard_outputs (
                output_id INTEGER PRIMARY KEY AUTOINCREMENT,
                report_number TEXT NOT NULL,
                source_key TEXT,
                model_name TEXT,
                prompt_version TEXT,
                input_hash TEXT,
                raw_response_json TEXT,
                tokens_used INTEGER DEFAULT 0,
                created_at TEXT
            )
        """)
        conn.execute("CREATE INDEX IF NOT EXISTS idx_ai_out_rep ON maude_ai_hazard_outputs(report_number)")

        # 5. Audit Change Log Table (Section 3.4, 10.5)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS hazard_change_log (
                log_id INTEGER PRIMARY KEY AUTOINCREMENT,
                hazard_row_id TEXT NOT NULL,
                change_type TEXT,
                changed_by TEXT,
                changed_at TEXT,
                field_name TEXT,
                old_value TEXT,
                new_value TEXT
            )
        """)
        conn.execute("CREATE INDEX IF NOT EXISTS idx_chg_log_hz ON hazard_change_log(hazard_row_id)")

        # 6. Reanalysis Candidates Table (Section 14.4, M-1)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS hazard_reanalysis_candidates (
                candidate_id INTEGER PRIMARY KEY AUTOINCREMENT,
                report_number TEXT NOT NULL,
                hazard_row_id TEXT,
                new_hazard_json TEXT,
                reanalyzed_at TEXT,
                model_name TEXT,
                status TEXT DEFAULT '대기'
            )
        """)

        # 7. Finalized Versions History Table (Section 10.4)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS hazard_versions (
                version_id INTEGER PRIMARY KEY AUTOINCREMENT,
                version_tag TEXT NOT NULL UNIQUE,
                finalized_at TEXT NOT NULL,
                finalized_by TEXT,
                summary_notes TEXT,
                total_hazards INTEGER,
                adopted_hazards INTEGER,
                high_risk_count INTEGER,
                medium_risk_count INTEGER,
                low_risk_count INTEGER,
                snapshot_json TEXT
            )
        """)

    # Run One-Time Migrations (F-2, F-4, F-5)
    _migrate_legacy_hazards_if_needed()
    _migrate_use_modes_if_needed()
    _migrate_ingest_dates_if_needed()


def _migrate_legacy_hazards_if_needed() -> None:
    """Safely copies legacy hazard rows from 30GB legacy DB into `maude_hazard.db` EXACTLY ONCE (F-2)."""
    if not LEGACY_MAUDE_DB_PATH.exists():
        return

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with get_hazard_conn(readonly=False) as dest:
        # Check if already migrated
        cur = dest.execute("SELECT meta_value FROM maude_hazard_meta WHERE meta_key = 'legacy_migrated'").fetchone()
        if cur and cur[0] == "1":
            return

        try:
            legacy_conn = sqlite3.connect(f"{LEGACY_MAUDE_DB_PATH.as_uri()}?mode=ro", uri=True, timeout=5.0)
            legacy_conn.row_factory = sqlite3.Row
            has_table = legacy_conn.execute(
                "SELECT 1 FROM sqlite_master WHERE type='table' AND name='maude_hazards'"
            ).fetchone()
            if not has_table:
                legacy_conn.close()
                dest.execute(
                    "INSERT OR REPLACE INTO maude_hazard_meta (meta_key, meta_value, updated_at) VALUES ('legacy_migrated', '1', ?)",
                    (now_str,),
                )
                return

            legacy_rows = legacy_conn.execute("SELECT * FROM maude_hazards").fetchall()
            legacy_conn.close()

            if legacy_rows:
                for r in legacy_rows:
                    rd = dict(r)
                    s_str = rd.get("severity_level") or "Serious"
                    p_str = rd.get("probability_level") or "Occasional"
                    score, level_ko = calc_risk_level(s_str, p_str)

                    rd.setdefault("source_type", "MAUDE")
                    rd.setdefault("source_key", rd.get("report_number", ""))
                    rd.setdefault("first_ingest_month", (rd.get("date_received") or "")[:7])
                    rd.setdefault("first_ingested_at", rd.get("date_received") or rd.get("created_at") or "")
                    rd.setdefault("use_mode", "향후 AID 연동")
                    rd.setdefault("adoption_decision", "")
                    rd.setdefault("adoption_reason", "")
                    rd.setdefault("future_aid_risk", "")
                    rd.setdefault("decision_reason", "")
                    rd.setdefault("ppt_include", "N")
                    rd.setdefault("ppt_id", "")
                    rd.setdefault("first_finalized_version", "")
                    rd.setdefault("finalized_version", "")
                    rd.setdefault("finalized_at", "")
                    rd.setdefault("risk_level_raw", rd.get("risk_level") or "")
                    rd.setdefault("traceability_note_ko", "")
                    rd["risk_score"] = score
                    rd["risk_level"] = level_ko

                    cols = list(rd.keys())
                    placeholders = ":" + ", :".join(cols)
                    sql = f"INSERT OR IGNORE INTO maude_hazards ({', '.join(cols)}) VALUES ({placeholders})"
                    dest.execute(sql, rd)

                dest.execute(
                    """
                    INSERT INTO hazard_change_log (
                        hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                    ) VALUES ('SYSTEM', 'LEGACY_MIGRATION', 'SYSTEM', ?, 'maude_hazards', '', ?)
                    """,
                    (now_str, f"Migrated {len(legacy_rows)} rows from legacy DB"),
                )

            dest.execute(
                "INSERT OR REPLACE INTO maude_hazard_meta (meta_key, meta_value, updated_at) VALUES ('legacy_migrated', '1', ?)",
                (now_str,),
            )
            log.info(f"Successfully recorded 1-time legacy hazard migration: {len(legacy_rows) if legacy_rows else 0} rows")
        except Exception as e:
            log.warning(f"Legacy hazard migration note: {e}")


def _migrate_use_modes_if_needed() -> None:
    """Migrates existing use_mode values to the unified 4-value standard EXACTLY ONCE (F-4)."""
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with get_hazard_conn(readonly=False) as conn:
        cur = conn.execute("SELECT meta_value FROM maude_hazard_meta WHERE meta_key = 'use_mode_v03_migrated'").fetchone()
        if cur and cur[0] == "1":
            return

        rows = conn.execute("SELECT hazard_row_id, use_mode FROM maude_hazards").fetchall()
        migrated_cnt = 0
        for r in rows:
            old_mode = str(r[1] or "").strip()
            new_mode = USE_MODE_CONVERSION.get(old_mode, "향후 AID 연동")
            if old_mode != new_mode:
                conn.execute(
                    "UPDATE maude_hazards SET use_mode = ?, updated_at = ? WHERE hazard_row_id = ?",
                    (new_mode, now_str, r[0]),
                )
                conn.execute(
                    """
                    INSERT INTO hazard_change_log (
                        hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                    ) VALUES (?, 'USE_MODE_V03_MIGRATE', 'SYSTEM', ?, 'use_mode', ?, ?)
                    """,
                    (r[0], now_str, old_mode, new_mode),
                )
                migrated_cnt += 1

        conn.execute(
            "INSERT OR REPLACE INTO maude_hazard_meta (meta_key, meta_value, updated_at) VALUES ('use_mode_v03_migrated', '1', ?)",
            (now_str,),
        )
        if migrated_cnt > 0:
            log.info(f"Successfully converted {migrated_cnt} hazard use_mode values to v0.3 standard")


def _migrate_ingest_dates_if_needed() -> None:
    """Updates first_ingest_month to collected_at and populates date_received from source reports (F-5)."""
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if not LEGACY_MAUDE_DB_PATH.exists():
        return

    with get_hazard_conn(readonly=False) as conn:
        cur = conn.execute("SELECT meta_value FROM maude_hazard_meta WHERE meta_key = 'ingest_dates_v03_migrated'").fetchone()
        if cur and cur[0] == "1":
            return

        hz_rows = conn.execute("SELECT hazard_row_id, report_number, first_ingest_month, date_received FROM maude_hazards").fetchall()
        if not hz_rows:
            conn.execute(
                "INSERT OR REPLACE INTO maude_hazard_meta (meta_key, meta_value, updated_at) VALUES ('ingest_dates_v03_migrated', '1', ?)",
                (now_str,),
            )
            return

        try:
            legacy_conn = sqlite3.connect(f"{LEGACY_MAUDE_DB_PATH.as_uri()}?mode=ro", uri=True, timeout=5.0)
            legacy_conn.row_factory = sqlite3.Row

            for hr in hz_rows:
                hz_id, rep_num, cur_month, cur_date_rec = hr[0], hr[1], hr[2], hr[3]
                src = legacy_conn.execute(
                    "SELECT mdr_report_key, date_received, collected_at FROM maude_reports WHERE report_number = ?",
                    (rep_num,),
                ).fetchone()

                if src:
                    coll_at = src["collected_at"] or ""
                    date_rec = src["date_received"] or cur_date_rec or ""
                    mdr_key = src["mdr_report_key"] or rep_num

                    new_month = coll_at[:7] if coll_at else (date_rec[:7] if date_rec else now_str[:7])
                    new_ingested = coll_at or date_rec or now_str

                    conn.execute(
                        """
                        UPDATE maude_hazards
                           SET source_key = ?,
                               first_ingest_month = ?,
                               first_ingested_at = ?,
                               date_received = ?,
                               updated_at = ?
                         WHERE hazard_row_id = ?
                        """,
                        (mdr_key, new_month, new_ingested, date_rec, now_str, hz_id),
                    )

                    if cur_month != new_month:
                        conn.execute(
                            """
                            INSERT INTO hazard_change_log (
                                hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                            ) VALUES (?, 'INGEST_DATE_V03_MIGRATE', 'SYSTEM', ?, 'first_ingest_month', ?, ?)
                            """,
                            (hz_id, now_str, cur_month or "", new_month),
                        )

            legacy_conn.close()
        except Exception as e:
            log.warning(f"Note during ingest dates v0.3 migration: {e}")

        conn.execute(
            "INSERT OR REPLACE INTO maude_hazard_meta (meta_key, meta_value, updated_at) VALUES ('ingest_dates_v03_migrated', '1', ?)",
            (now_str,),
        )


# Initialize schema on module import
try:
    init_hazard_db()
except Exception as _e:
    log.warning(f"Initial hazard DB setup notice: {_e}")


# ---------------------------------------------------------------------------
# Hazard Query & Reporting Functions (Section 3.1, 7, 8, F-5)
# ---------------------------------------------------------------------------
def get_hazards(
    filters: Optional[Dict[str, Any]] = None,
    confirmed_only: bool = False,
    page: int = 1,
    page_size: Optional[int] = None,
    sort_by: str = "date_received",
) -> Dict[str, Any]:
    """Retrieves ISO 14971 hazards from `maude_hazard.db`.

    - If `confirmed_only=True`, filters strictly by `adoption_decision = '채택'`.
    - No 500-limit cutoff when `page_size is None` (e.g. for Excel export).
    - Sorts primarily by `date_received DESC, risk_score DESC` according to Section 3.1 & F-5.
    """
    filters = filters or {}
    where_parts: List[str] = []
    params: List[Any] = []

    # 1. Confirmed / Adoption Filter
    if confirmed_only:
        where_parts.append("h.adoption_decision = '채택'")
    elif filters.get("adoption_decision"):
        ad = str(filters["adoption_decision"]).strip()
        if ad == "미결정":
            where_parts.append("(h.adoption_decision IS NULL OR h.adoption_decision = '')")
        else:
            where_parts.append("h.adoption_decision = ?")
            params.append(ad)

    if filters.get("workflow_status"):
        where_parts.append("h.workflow_status = ?")
        params.append(filters["workflow_status"])

    if filters.get("hazard_category"):
        where_parts.append("h.hazard_category_primary = ?")
        params.append(filters["hazard_category"])

    if filters.get("risk_level"):
        where_parts.append("h.risk_level = ?")
        params.append(filters["risk_level"])

    if filters.get("use_mode"):
        where_parts.append("h.use_mode = ?")
        params.append(filters["use_mode"])

    if filters.get("ppt_include"):
        where_parts.append("h.ppt_include = ?")
        params.append(filters["ppt_include"])

    if filters.get("min_aid_score") is not None and str(filters["min_aid_score"]).isdigit() and int(filters["min_aid_score"]) > 0:
        where_parts.append("h.aid_relevance_score >= ?")
        params.append(int(filters["min_aid_score"]))

    if filters.get("brand_name"):
        where_parts.append("h.brand_name = ?")
        params.append(filters["brand_name"])

    if filters.get("keyword") and str(filters["keyword"]).strip():
        kw = f"%{filters['keyword'].strip()}%"
        where_parts.append(
            "(h.hazard_ko LIKE ? OR h.initiating_event_ko LIKE ? OR "
            "h.hazardous_situation_ko LIKE ? OR h.harm_ko LIKE ? OR "
            "h.care_sens_implication_ko LIKE ? OR h.report_number LIKE ? OR h.brand_name LIKE ? OR "
            "h.adoption_reason LIKE ? OR h.future_aid_risk LIKE ? OR h.internal_tags LIKE ?)"
        )
        params.extend([kw, kw, kw, kw, kw, kw, kw, kw, kw, kw])

    where_sql = " AND ".join(where_parts) if where_parts else "1=1"

    # Sorting: Section 3.1 & F-5 requires date_received for display/excel sorting
    if sort_by == "risk_score":
        order_clause = "ORDER BY h.risk_score DESC, h.date_received DESC, h.created_at DESC"
    elif sort_by == "first_ingest_month":
        order_clause = "ORDER BY h.first_ingest_month DESC, h.date_received DESC"
    else:  # default: date_received
        order_clause = "ORDER BY h.date_received DESC, h.risk_score DESC, h.created_at DESC"

    with get_hazard_conn(readonly=True) as conn:
        count_sql = f"SELECT count(*) FROM maude_hazards h WHERE {where_sql}"
        total_count = conn.execute(count_sql, params).fetchone()[0]

        if page_size and page_size > 0:
            offset = max(0, (page - 1) * page_size)
            query = f"SELECT h.* FROM maude_hazards h WHERE {where_sql} {order_clause} LIMIT ? OFFSET ?"
            rows = conn.execute(query, params + [page_size, offset]).fetchall()
        else:
            query = f"SELECT h.* FROM maude_hazards h WHERE {where_sql} {order_clause}"
            rows = conn.execute(query, params).fetchall()

        items = [dict(r) for r in rows]

    return {
        "total": total_count,
        "page": page,
        "page_size": page_size or total_count,
        "items": items,
    }


def get_confirmed_hazards(filters: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
    """Returns all adopted/confirmed hazards without pagination limits for RMF matrix."""
    res = get_hazards(filters=filters, confirmed_only=True, page=1, page_size=None)
    return res["items"]


def get_reports_hazard_status(report_numbers: List[str]) -> Dict[str, Dict[str, Any]]:
    """Returns mapping of report_number -> {has_hazard, hazard_count, hazard_status, adoption_status}."""
    if not report_numbers:
        return {}

    placeholders = ",".join(["?"] * len(report_numbers))
    query = f"""
        SELECT report_number,
               count(*) as hazard_count,
               max(workflow_status) as status_max,
               min(workflow_status) as status_min,
               group_concat(adoption_decision) as adoptions
        FROM maude_hazards
        WHERE report_number IN ({placeholders})
        GROUP BY report_number
    """
    result: Dict[str, Dict[str, Any]] = {}
    with get_hazard_conn(readonly=True) as conn:
        rows = conn.execute(query, report_numbers).fetchall()
        for r in rows:
            rn = r[0]
            cnt = r[1]
            s_max = r[2]
            s_min = r[3]
            ad_str = str(r[4] or "")

            if s_max == "검토완료" and s_min == "검토완료":
                w_status = "검토완료"
            elif s_max == "확정" or s_min == "확정":
                w_status = "확정"
            elif "검토완료" in (s_max, s_min):
                w_status = "부분검토"
            else:
                w_status = "미검토"

            if "채택" in ad_str:
                ad_status = "채택"
            elif "보류" in ad_str:
                ad_status = "보류"
            elif "제외" in ad_str:
                ad_status = "제외"
            else:
                ad_status = "미결정"

            result[rn] = {
                "has_hazard": cnt > 0,
                "hazard_count": cnt,
                "hazard_status": w_status,
                "adoption_status": ad_status,
            }
    return result


# ---------------------------------------------------------------------------
# Hazard Review & Adoption Management (Section 2, 3.3, 3.5, 3.6 - F-1, F-4, F-10)
# ---------------------------------------------------------------------------
def save_hazard_review(
    hazard_row_id: str,
    workflow_status: Optional[str] = None,
    adoption_decision: Optional[str] = None,
    adoption_reason: Optional[str] = None,
    future_aid_risk: Optional[str] = None,
    decision_reason: Optional[str] = None,
    use_mode: Optional[str] = None,
    ppt_include: Optional[str] = None,
    ppt_id: Optional[str] = None,
    reviewer_name: Optional[str] = None,
    review_note: Optional[str] = None,
    internal_tags: Optional[str] = None,
    manual_overrides: Optional[Dict[str, Any]] = None,
    client_updated_at: Optional[str] = None,
) -> Dict[str, Any]:
    """Saves reviewer decision using Partial Update with strict validation & optimistic lock (F-1).

    - Only fields explicitly passed (not None) are modified; unmentioned fields keep their current values.
    - If client_updated_at is provided, rejects save if another process modified the row in the interim (14.3).
    - If adoption_decision == '채택', adoption_reason and future_aid_risk are strictly validated.
    - Validates use_mode against ALLOWED_USE_MODES (F-4) and adoption_decision against ALLOWED_ADOPTION_DECISIONS (F-10).
    - ppt_id must remain globally unique.
    - Only changed fields are written to `hazard_change_log`.
    """
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with get_hazard_conn(readonly=False) as conn:
        cur = conn.execute("SELECT * FROM maude_hazards WHERE hazard_row_id = ?", (hazard_row_id,)).fetchone()
        if not cur:
            raise KeyError(f"Hazard not found: {hazard_row_id}")
        cur_dict = dict(cur)

        # 1. Optimistic Locking Check (Section 3.6 / 14.3)
        if client_updated_at and cur_dict.get("updated_at"):
            if str(client_updated_at).strip() != str(cur_dict["updated_at"]).strip():
                raise ValueError("다른 곳에서 먼저 수정되었습니다. 최신 데이터를 다시 조회해주세요.")

        # 2. Determine Target Values for Validation
        target_adoption = (
            str(adoption_decision).strip() if adoption_decision is not None else (cur_dict.get("adoption_decision") or "")
        )
        target_ad_reason = (
            adoption_reason if adoption_reason is not None else (cur_dict.get("adoption_reason") or "")
        )
        target_aid_risk = (
            future_aid_risk if future_aid_risk is not None else (cur_dict.get("future_aid_risk") or "")
        )
        target_use_mode = (
            str(use_mode).strip() if use_mode is not None else (cur_dict.get("use_mode") or "향후 AID 연동")
        )
        target_ppt_id = (
            str(ppt_id).strip() if ppt_id is not None else (cur_dict.get("ppt_id") or "")
        )

        # 3. Validation: adoption_decision (F-10)
        if target_adoption not in ALLOWED_ADOPTION_DECISIONS:
            raise ValueError(f"유효하지 않은 채택 판단 값입니다: '{target_adoption}'. 허용 값: 채택, 보류, 제외, 미결정")

        # 4. Validation: Mandatory reasons when 채택 (Section 2.2)
        if target_adoption == "채택":
            if not str(target_ad_reason or "").strip():
                raise ValueError("위해 요인 [채택] 시 '채택 사유(왜 중요한가)'는 필수 입력 항목입니다.")
            if not str(target_aid_risk or "").strip():
                raise ValueError("위해 요인 [채택] 시 '차세대 AID 영향(어떻게 위험한가)'은 필수 입력 항목입니다.")

        # 5. Validation: use_mode 4 allowed values (Section 5 / F-4)
        if target_use_mode not in ALLOWED_USE_MODES:
            raise ValueError(f"유효하지 않은 사용 모드입니다: '{target_use_mode}'. 허용 값: {', '.join(ALLOWED_USE_MODES)}")

        # 6. Validation: ppt_id uniqueness (Section 3.5)
        if target_ppt_id:
            dup = conn.execute(
                "SELECT hazard_row_id FROM maude_hazards WHERE ppt_id = ? AND hazard_row_id != ?",
                (target_ppt_id, hazard_row_id),
            ).fetchone()
            if dup:
                raise ValueError(f"PPT ID '{target_ppt_id}'가 이미 다른 항목({dup[0]})에서 사용 중입니다. 고유한 ID를 부여하세요.")

        # 7. Build dynamic field updates & track changes (Partial Update - F-1)
        updatable_fields = {
            "workflow_status": workflow_status,
            "adoption_decision": target_adoption if adoption_decision is not None else None,
            "adoption_reason": adoption_reason,
            "future_aid_risk": future_aid_risk,
            "decision_reason": decision_reason,
            "use_mode": target_use_mode if use_mode is not None else None,
            "ppt_include": ppt_include,
            "ppt_id": target_ppt_id if ppt_id is not None else None,
            "reviewer_name": reviewer_name,
            "review_note": review_note,
            "internal_tags": internal_tags,
        }

        sql_sets = []
        sql_params = []
        author = reviewer_name or cur_dict.get("reviewer_name") or "사용자"

        for f_name, new_val in updatable_fields.items():
            if new_val is not None:
                old_val = cur_dict.get(f_name)
                # Only log and update if value actually changed
                if str(old_val or "") != str(new_val or ""):
                    conn.execute(
                        """
                        INSERT INTO hazard_change_log (
                            hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
                        ) VALUES (?, 'USER_REVIEW', ?, ?, ?, ?, ?)
                        """,
                        (hazard_row_id, author, now_str, f_name, str(old_val or ""), str(new_val or "")),
                    )
                sql_sets.append(f"{f_name} = ?")
                sql_params.append(new_val)

        # Handle manual overrides if passed
        if manual_overrides is not None:
            override_json = json.dumps(manual_overrides, ensure_ascii=False)
            sql_sets.append("manual_override_json = ?")
            sql_params.append(override_json)
            sql_sets.append("has_manual_override = 1")

        # Always update timestamp
        if reviewer_name is not None and str(reviewer_name).strip():
            sql_sets.append("reviewed_at = ?")
            sql_params.append(now_str)

        sql_sets.append("updated_at = ?")
        sql_params.append(now_str)

        sql_params.append(hazard_row_id)
        update_sql = f"UPDATE maude_hazards SET {', '.join(sql_sets)} WHERE hazard_row_id = ?"
        conn.execute(update_sql, sql_params)

    return {
        "success": True,
        "hazard_row_id": hazard_row_id,
        "updated_at": now_str,
        "adoption_decision": target_adoption,
        "workflow_status": workflow_status or cur_dict.get("workflow_status"),
    }


def save_hazard_review_batch(
    report_numbers: List[str],
    workflow_status: str,
    reviewer_name: str,
    review_note: str,
    internal_tags: str = "",
) -> int:
    """Updates workflow status in bulk. Explicitly forbids changing `adoption_decision` in batch (Section 2.2, 8)."""
    if not report_numbers:
        return 0

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    placeholders = ",".join(["?"] * len(report_numbers))
    query = f"""
        UPDATE maude_hazards
           SET workflow_status = ?,
               reviewer_name = ?,
               reviewed_at = ?,
               review_note = ?,
               internal_tags = ?,
               updated_at = ?
         WHERE report_number IN ({placeholders})
    """
    params = [workflow_status, reviewer_name, now_str, review_note, internal_tags, now_str] + report_numbers
    with get_hazard_conn(readonly=False) as conn:
        cursor = conn.execute(query, params)
        return cursor.rowcount


def delete_hazard(hazard_row_id: str, deleted_by: str = "사용자") -> bool:
    """Deletes an unreviewed AI-generated hazard.

    Rejects deletion if the hazard has ANY user judgment (Section 3.7, F-6):
    - adoption_decision is set ('채택', '보류', '제외')
    - workflow_status in ('검토완료', '확정')
    - reviewer_name is non-empty and != '관리자 (일괄)'
    - has_manual_override == 1
    Only pure unreviewed AI rows can be deleted. Logs deletion to hazard_change_log.
    """
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with get_hazard_conn(readonly=False) as conn:
        row = conn.execute("SELECT * FROM maude_hazards WHERE hazard_row_id = ?", (hazard_row_id,)).fetchone()
        if not row:
            return False
        rd = dict(row)

        ad = str(rd.get("adoption_decision") or "").strip()
        ws = str(rd.get("workflow_status") or "").strip()
        rev = str(rd.get("reviewer_name") or "").strip()
        has_mo = rd.get("has_manual_override") or 0

        has_user_judgment = (
            ad in ("채택", "보류", "제외")
            or ws in ("검토완료", "확정")
            or (rev and rev != "관리자 (일괄)")
            or has_mo == 1
            or bool(str(rd.get("adoption_reason") or "").strip())
        )
        if has_user_judgment:
            raise ValueError("검토 또는 판단이 완료된 항목은 삭제할 수 없습니다. 대신 [제외] 판단으로 전환해주세요.")

        cursor = conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id = ?", (hazard_row_id,))
        conn.execute(
            """
            INSERT INTO hazard_change_log (
                hazard_row_id, change_type, changed_by, changed_at, field_name, old_value, new_value
            ) VALUES (?, 'USER_DELETE', ?, ?, 'hazard_entry', ?, '')
            """,
            (hazard_row_id, deleted_by, now_str, rd.get("hazard_ko") or ""),
        )
        return cursor.rowcount > 0


# ---------------------------------------------------------------------------
# Finalization & Versioning Engine (Section 3.8, 10, F-7, F-12)
# ---------------------------------------------------------------------------
def finalize_hazard_version(
    version_tag: str,
    finalized_by: str = "위험관리 책임자",
    summary_notes: str = "",
) -> Dict[str, Any]:
    """Snapshots all current '채택' hazards and sets first_finalized_version and finalized_version (F-7).

    - Rejects finalization if 0 hazards are adopted (F-12 / Section 3.8).
    - first_finalized_version is stamped once and never overwritten.
    - finalized_version is updated to the latest version_tag.
    """
    v_tag = str(version_tag or "").strip()
    if not v_tag:
        raise ValueError("버전 태그(예: v0.2, v0.3)를 입력해주세요.")

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with get_hazard_conn(readonly=False) as conn:
        dup = conn.execute("SELECT version_id FROM hazard_versions WHERE version_tag = ?", (v_tag,)).fetchone()
        if dup:
            raise ValueError(f"버전 '{v_tag}'는 이미 확정된 버전입니다. 새로운 버전 번호를 입력하세요.")

        # Get all adopted hazards
        adopted_rows = conn.execute(
            "SELECT * FROM maude_hazards WHERE adoption_decision = '채택' ORDER BY risk_score DESC"
        ).fetchall()
        adopted_items = [dict(r) for r in adopted_rows]
        adopted_count = len(adopted_items)

        # F-12 / Section 3.8: Rejection if 0 adopted hazards
        if adopted_count == 0:
            raise ValueError("채택된 위해 요인이 0건이므로 확정할 수 없습니다. 최소 1건 이상의 위해 요인을 [채택]해야 합니다.")

        total_count = conn.execute("SELECT count(*) FROM maude_hazards").fetchone()[0]
        high_cnt = sum(1 for it in adopted_items if it.get("risk_level") == "높음")
        med_cnt = sum(1 for it in adopted_items if it.get("risk_level") == "중간")
        low_cnt = sum(1 for it in adopted_items if it.get("risk_level") == "낮음")

        snapshot_json = json.dumps(adopted_items, ensure_ascii=False)

        # 1. Insert version record
        conn.execute("""
            INSERT INTO hazard_versions (
                version_tag, finalized_at, finalized_by, summary_notes,
                total_hazards, adopted_hazards, high_risk_count, medium_risk_count, low_risk_count,
                snapshot_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            v_tag, now_str, finalized_by, summary_notes,
            total_count, adopted_count, high_cnt, med_cnt, low_cnt,
            snapshot_json
        ))

        # 2. Stamp finalized metadata on adopted records (first_finalized_version immutable once set)
        conn.execute("""
            UPDATE maude_hazards
               SET first_finalized_version = CASE
                       WHEN first_finalized_version IS NULL OR first_finalized_version = '' THEN ?
                       ELSE first_finalized_version
                   END,
                   finalized_version = ?,
                   finalized_at = ?,
                   workflow_status = '확정',
                   updated_at = ?
             WHERE adoption_decision = '채택'
        """, (v_tag, v_tag, now_str, now_str))

    return {
        "success": True,
        "version_tag": v_tag,
        "finalized_at": now_str,
        "adopted_hazards": adopted_count,
    }


def get_hazard_versions() -> List[Dict[str, Any]]:
    """Retrieves full history of finalized hazard versions."""
    with get_hazard_conn(readonly=True) as conn:
        rows = conn.execute(
            "SELECT version_id, version_tag, finalized_at, finalized_by, summary_notes, "
            "total_hazards, adopted_hazards, high_risk_count, medium_risk_count, low_risk_count "
            "FROM hazard_versions ORDER BY finalized_at DESC"
        ).fetchall()
        return [dict(r) for r in rows]


def get_hazard_change_logs(hazard_row_id: Optional[str] = None) -> List[Dict[str, Any]]:
    """Retrieves audit change log entries."""
    with get_hazard_conn(readonly=True) as conn:
        if hazard_row_id:
            rows = conn.execute(
                "SELECT * FROM hazard_change_log WHERE hazard_row_id = ? ORDER BY changed_at DESC LIMIT 200",
                (hazard_row_id,),
            ).fetchall()
        else:
            rows = conn.execute(
                "SELECT * FROM hazard_change_log ORDER BY changed_at DESC LIMIT 500"
            ).fetchall()
        return [dict(r) for r in rows]


# ---------------------------------------------------------------------------
# Candidate Reports Management (Section 6.2, 14.2, F-9)
# ---------------------------------------------------------------------------
def add_hazard_candidate(
    report_number: str,
    brand_name: str = "",
    device_category: str = "CGM",
    event_type: str = "",
    date_received: str = "",
    note: str = "",
) -> Dict[str, Any]:
    """Adds a report to maude_hazard_candidates without resetting candidate_added_at if already present (F-9)."""
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with get_hazard_conn(readonly=False) as conn:
        existing = conn.execute(
            "SELECT candidate_added_at, candidate_note FROM maude_hazard_candidates WHERE report_number = ?",
            (report_number,),
        ).fetchone()
        if existing:
            return {
                "success": True,
                "already_exists": True,
                "message": "이미 후보 목록에 등록되어 있습니다.",
                "candidate_added_at": existing[0],
                "report_number": report_number,
            }

        conn.execute("""
            INSERT INTO maude_hazard_candidates (
                report_number, source_key, brand_name, device_category, event_type,
                date_received, candidate_added_at, candidate_status, candidate_note
            ) VALUES (?, ?, ?, ?, ?, ?, ?, '대기', ?)
        """, (report_number, report_number, brand_name, device_category, event_type, date_received, now_str, note))
        return {
            "success": True,
            "already_exists": False,
            "message": "후보에 성공적으로 등록되었습니다.",
            "candidate_added_at": now_str,
            "report_number": report_number,
        }


def get_hazard_candidates() -> List[Dict[str, Any]]:
    """Lists all candidate reports waiting for or undergoing hazard review."""
    with get_hazard_conn(readonly=True) as conn:
        rows = conn.execute("SELECT * FROM maude_hazard_candidates ORDER BY candidate_added_at DESC").fetchall()
        return [dict(r) for r in rows]


def delete_hazard_candidate(report_number: str) -> bool:
    """Removes a report from candidates table."""
    with get_hazard_conn(readonly=False) as conn:
        c = conn.execute("DELETE FROM maude_hazard_candidates WHERE report_number = ?", (report_number,))
        return c.rowcount > 0


# ---------------------------------------------------------------------------
# Multi-Sheet Excel Export Engine (Section 9, M-4, M-11, M-12, F-4, F-5, F-7)
# ---------------------------------------------------------------------------
def export_hazards_to_excel(
    filters: Optional[Dict[str, Any]] = None,
    export_type: str = "final",
    confirmed_only: bool = False,
) -> Tuple[bytes, str]:
    """Generates standardized multi-sheet Excel workbook complying with Section 9.

    Sheets:
    1. 최종 Hazard (채택 완료된 위해 항목)
    2. 운영 매트릭스 (전체 / 필터된 위해 항목 전체)
    3. 월별 요약 (first_ingest_month 기준 건수 및 위험도 분포)
    4. 버전 이력 (hazard_versions 스냅샷)
    5. 변경 이력 (hazard_change_log 감사 로그)
    6. 부록 (ISO 14971 평가 기준 및 사용 모드 정의)

    Returns: (excel_bytes, suggested_filename)
    """
    import io
    import openpyxl
    from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
    from openpyxl.utils import get_column_letter

    filters = filters or {}
    now_dt = datetime.now()
    now_date_str = now_dt.strftime("%Y%m%d")

    # Fetch latest finalized version tag if available
    latest_v = "v0.3"
    with get_hazard_conn(readonly=True) as conn:
        v_row = conn.execute("SELECT version_tag FROM hazard_versions ORDER BY finalized_at DESC LIMIT 1").fetchone()
        if v_row and v_row[0]:
            latest_v = v_row[0]

    # Fetch adopted hazards (sorted by date_received DESC, risk_score DESC)
    adopted_items = get_hazards(filters={}, confirmed_only=True, page=1, page_size=None, sort_by="date_received")["items"]

    # Fetch operations hazards based on passed filters
    all_items = get_hazards(filters=filters, confirmed_only=confirmed_only, page=1, page_size=None, sort_by="date_received")["items"]

    wb = openpyxl.Workbook()
    wb.remove(wb.active)

    font_family = "맑은 고딕"
    header_font = Font(name=font_family, size=10, bold=True, color="FFFFFF")
    data_font = Font(name=font_family, size=9)
    bold_data_font = Font(name=font_family, size=9, bold=True)
    header_fill = PatternFill(start_color="0F172A", end_color="0F172A", fill_type="solid")  # Slate 900
    thin_side = Side(border_style="thin", color="CBD5E1")
    cell_border = Border(left=thin_side, right=thin_side, top=thin_side, bottom=thin_side)

    align_center = Alignment(horizontal="center", vertical="center", wrap_text=True)
    align_left = Alignment(horizontal="left", vertical="center", wrap_text=True)

    risk_fills = {
        "높음": PatternFill(start_color="FFE4E6", end_color="FFE4E6", fill_type="solid"),  # Rose 100
        "High": PatternFill(start_color="FFE4E6", end_color="FFE4E6", fill_type="solid"),
        "중간": PatternFill(start_color="FEF3C7", end_color="FEF3C7", fill_type="solid"),  # Amber 100
        "Medium": PatternFill(start_color="FEF3C7", end_color="FEF3C7", fill_type="solid"),
        "낮음": PatternFill(start_color="E0F2FE", end_color="E0F2FE", fill_type="solid"),  # Sky 100
        "Low": PatternFill(start_color="E0F2FE", end_color="E0F2FE", fill_type="solid"),
    }
    decision_fills = {
        "채택": PatternFill(start_color="DCFCE7", end_color="DCFCE7", fill_type="solid"),  # Emerald 100
        "보류": PatternFill(start_color="FEF9C3", end_color="FEF9C3", fill_type="solid"),  # Yellow 100
        "제외": PatternFill(start_color="F1F5F9", end_color="F1F5F9", fill_type="solid"),  # Gray
    }

    def _apply_sheet_styling(ws, headers, row_count):
        ws.row_dimensions[1].height = 28
        for col_idx in range(1, len(headers) + 1):
            c = ws.cell(row=1, column=col_idx)
            c.font = header_font
            c.fill = header_fill
            c.alignment = align_center
            c.border = cell_border

        for r_idx in range(2, row_count + 2):
            ws.row_dimensions[r_idx].height = 24
            for c_idx in range(1, len(headers) + 1):
                c = ws.cell(row=r_idx, column=c_idx)
                c.font = data_font
                c.border = cell_border
                h_name = headers[c_idx - 1]
                if any(k in h_name for k in ["번호", "ID", "일자", "일시", "수준", "분류", "상태", "판단", "검토자", "관련도", "S", "P", "점수", "모드"]):
                    c.alignment = align_center
                else:
                    c.alignment = align_left

                if "위험 수준" in h_name and c.value in risk_fills:
                    c.fill = risk_fills[c.value]
                    c.font = bold_data_font

                if "채택 여부" in h_name and c.value in decision_fills:
                    c.fill = decision_fills[c.value]
                    c.font = bold_data_font

        for col in ws.columns:
            col_letter = get_column_letter(col[0].column)
            max_len = 0
            for c in col:
                val = str(c.value or "")
                first_line = val.split("\n")[0]
                max_len = max(max_len, len(first_line.encode("utf-8", "ignore")))
            ws.column_dimensions[col_letter].width = min(max(max_len + 3, 12), 48)

    # 1. Sheet 1: 최종 Hazard (채택 완료)
    ws1 = wb.create_sheet(title="최종 Hazard")
    headers1 = [
        "PPT ID", "MDR 보고서 번호", "제품명", "의료기기 분류", "부작용 유형",
        "접수일자 (FDA)", "최초 수집월 (DB)", "사용 모드", "위해 분류", "위해 요인 (Hazard)",
        "원인 사건", "위해 상황", "환자 위해", "심각도 (S)", "발생확률 (P)",
        "위험도 점수 (S×P)", "위험 수준", "채택 사유 (왜 중요한가)", "차세대 AID 영향 (어떻게 위험한가)",
        "AID 연동 관련도", "권장 설계 예방 통제안", "권장 시장 조치/시정안",
        "검토자", "검토일시", "검토 의견", "최초 확정 버전", "마지막 확정 버전"
    ]
    ws1.append(headers1)
    for r in adopted_items:
        ws1.append([
            r.get("ppt_id") or "",
            r.get("report_number") or "",
            r.get("brand_name") or "",
            r.get("device_category") or "",
            r.get("event_type") or "",
            r.get("date_received") or "",
            r.get("first_ingest_month") or "",
            r.get("use_mode") or "",
            r.get("hazard_category_primary") or "",
            r.get("hazard_ko") or "",
            r.get("initiating_event_ko") or "",
            r.get("hazardous_situation_ko") or "",
            r.get("harm_ko") or "",
            r.get("severity_level") or "",
            r.get("probability_level") or "",
            r.get("risk_score") or 0,
            r.get("risk_level") or "",
            r.get("adoption_reason") or "",
            r.get("future_aid_risk") or "",
            r.get("aid_relevance_score") or 0,
            r.get("recommended_preventive_controls") or "",
            r.get("recommended_recall_controls") or "",
            r.get("reviewer_name") or "",
            r.get("reviewed_at") or "",
            r.get("review_note") or "",
            r.get("first_finalized_version") or "",
            r.get("finalized_version") or "",
        ])
    _apply_sheet_styling(ws1, headers1, len(adopted_items))

    # 2. Sheet 2: 운영 매트릭스
    ws2 = wb.create_sheet(title="운영 매트릭스")
    headers2 = [
        "Hazard Row ID", "MDR 보고서 번호", "제품명", "부작용 유형", "접수일자",
        "최초 수집월", "사용 모드", "위해 요인", "위해 상황", "환자 위해", "위험 수준",
        "AID 관련도", "검토 상태", "채택 여부", "채택 사유", "차세대 AID 영향",
        "PPT 포함", "PPT ID", "최초 확정 버전", "검토자", "검토 의견", "생성일시", "수정일시"
    ]
    ws2.append(headers2)
    for r in all_items:
        ws2.append([
            r.get("hazard_row_id") or "",
            r.get("report_number") or "",
            r.get("brand_name") or "",
            r.get("event_type") or "",
            r.get("date_received") or "",
            r.get("first_ingest_month") or "",
            r.get("use_mode") or "",
            r.get("hazard_ko") or "",
            r.get("hazardous_situation_ko") or "",
            r.get("harm_ko") or "",
            r.get("risk_level") or "",
            r.get("aid_relevance_score") or 0,
            r.get("workflow_status") or "미검토",
            r.get("adoption_decision") or "미결정",
            r.get("adoption_reason") or "",
            r.get("future_aid_risk") or "",
            r.get("ppt_include") or "N",
            r.get("ppt_id") or "",
            r.get("first_finalized_version") or "",
            r.get("reviewer_name") or "",
            r.get("review_note") or "",
            r.get("created_at") or "",
            r.get("updated_at") or "",
        ])
    _apply_sheet_styling(ws2, headers2, len(all_items))

    # 3. Sheet 3: 월별 요약 (first_ingest_month 기준)
    ws3 = wb.create_sheet(title="월별 요약")
    headers3 = ["최초 수집월 (DB)", "총 도출 건수", "채택 건수", "보류 건수", "제외 건수", "고위험(높음)", "중간위험", "저위험(낮음)"]
    ws3.append(headers3)
    with get_hazard_conn(readonly=True) as conn:
        m_rows = conn.execute("""
            SELECT first_ingest_month,
                   count(*) as total_cnt,
                   sum(case when adoption_decision = '채택' then 1 else 0 end) as adopt_cnt,
                   sum(case when adoption_decision = '보류' then 1 else 0 end) as hold_cnt,
                   sum(case when adoption_decision = '제외' then 1 else 0 end) as reject_cnt,
                   sum(case when risk_level = '높음' then 1 else 0 end) as high_cnt,
                   sum(case when risk_level = '중간' then 1 else 0 end) as med_cnt,
                   sum(case when risk_level = '낮음' then 1 else 0 end) as low_cnt
              FROM maude_hazards
             GROUP BY first_ingest_month
             ORDER BY first_ingest_month DESC
        """).fetchall()
        for mr in m_rows:
            ws3.append([
                mr[0] or "미분류", mr[1], mr[2], mr[3], mr[4], mr[5], mr[6], mr[7]
            ])
    _apply_sheet_styling(ws3, headers3, len(m_rows))

    # 4. Sheet 4: 버전 이력
    ws4 = wb.create_sheet(title="버전 이력")
    headers4 = ["버전 태그", "확정 일시", "확정 책임자", "요약 비고", "전체 항목", "채택 항목", "높음 위험", "중간 위험", "낮음 위험"]
    ws4.append(headers4)
    versions = get_hazard_versions()
    for v in versions:
        ws4.append([
            v.get("version_tag"), v.get("finalized_at"), v.get("finalized_by"), v.get("summary_notes"),
            v.get("total_hazards"), v.get("adopted_hazards"), v.get("high_risk_count"), v.get("medium_risk_count"), v.get("low_risk_count")
        ])
    _apply_sheet_styling(ws4, headers4, len(versions))

    # 5. Sheet 5: 변경 이력
    ws5 = wb.create_sheet(title="변경 이력")
    headers5 = ["로그 ID", "Hazard Row ID", "변경 유형", "작업자", "변경 일시", "변경된 필드", "이전 값", "새로운 값"]
    ws5.append(headers5)
    logs = get_hazard_change_logs()
    for lg in logs:
        ws5.append([
            lg.get("log_id"), lg.get("hazard_row_id"), lg.get("change_type"), lg.get("changed_by"),
            lg.get("changed_at"), lg.get("field_name"), lg.get("old_value")[:200] if lg.get("old_value") else "",
            lg.get("new_value")[:200] if lg.get("new_value") else ""
        ])
    _apply_sheet_styling(ws5, headers5, len(logs))

    # 6. Sheet 6: 부록 (ISO 14971 평가 기준 및 사용 모드 정의 v0.3)
    ws6 = wb.create_sheet(title="부록_평가기준")
    headers6 = ["구분", "항목 / 명칭", "점수 / 기준", "상세 설명 및 적용 가이드"]
    ws6.append(headers6)
    appendix_rows = [
        ("심각도 (Severity)", "Catastrophic (치명적)", "5", "사망 또는 영구적 회복 불능 상해 발생"),
        ("심각도 (Severity)", "Critical (위험)", "4", "영구적 기능 저하 또는 생명 위협 중증 부상 (전문 의료진 개입 필수)"),
        ("심각도 (Severity)", "Serious (심각)", "3", "가역적이나 중대한 상해 (병원 치료 또는 응급 개입 필요)"),
        ("심각도 (Severity)", "Minor (경미)", "2", "일시적 불편 또는 경미한 피부 손상 (처치 불필요 또는 자가 처치 가능)"),
        ("심각도 (Severity)", "Negligible (미미)", "1", "상해 없음 또는 극히 미미한 영향"),
        ("발생확률 (Probability)", "Frequent (빈번)", "5", "매우 자주 발생 (누적 사용 기간 대비 상시 발생 가능)"),
        ("발생확률 (Probability)", "Probable (가능성 높음)", "4", "정기적으로 또는 다수 사용자에게서 관찰됨"),
        ("발생확률 (Probability)", "Occasional (간헐적)", "3", "간헐적으로 발생"),
        ("발생확률 (Probability)", "Remote (희박)", "2", "드물게 발생하나 발생 가능성이 완전히 배제되지 않음"),
        ("발생확률 (Probability)", "Improbable (거의 없음)", "1", "극히 예외적이거나 거의 발생하지 않음"),
        ("종합 위험도 (Risk Level)", "높음 (High)", "15 ~ 25점", "허용 불가 위험 (반드시 최우선 설계 변경 또는 위험 통제 조치 필수)"),
        ("종합 위험도 (Risk Level)", "중간 (Medium)", "8 ~ 14점", "조건부 허용 (ALARP 원칙에 따른 추가 위험 저감 대책 강구 필요)"),
        ("종합 위험도 (Risk Level)", "낮음 (Low)", "1 ~ 7점", "넓은 의미에서 허용 가능한 잔여 위험"),
        ("사용 모드 (Use Mode)", "향후 AID 연동", "-", "연속혈당측정기와 인슐린 펌프 연동 자동 인슐린 투여 시스템(AID) 환경"),
        ("사용 모드 (Use Mode)", "CGM 단독·수동 치료", "-", "환자가 수동으로 혈당 알림 및 수치를 확인하고 인슐린을 직접 투여하는 환경"),
        ("사용 모드 (Use Mode)", "제품 안전·임상·보호자", "-", "센서 삽입/부착, 테이프 접착, 앱 UI 디스플레이, 클라우드 공유 등 공통 제품 안전"),
        ("사용 모드 (Use Mode)", "펌프 단독 참고", "-", "펌프 기기 자체의 기계적 결함으로 CGM과 직접적 연관이 없어 위험표에서 제외하는 항목"),
    ]
    for ar in appendix_rows:
        ws6.append(list(ar))
    _apply_sheet_styling(ws6, headers6, len(appendix_rows))

    kind_str = "Final" if (confirmed_only or export_type == "final") else "Operations"
    v_tag = latest_v if latest_v.startswith("v") else f"v{latest_v}"
    filename = f"MAUDE_Hazard_{kind_str}_{v_tag}_{now_date_str}.xlsx"

    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue(), filename
