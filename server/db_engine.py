# -*- coding: utf-8 -*-
"""High-performance Database Engine for FDA MAUDE Analysis.

Optimized with CTE Late Joins for instant pagination and 100% accurate narrative evaluation.
"""
from __future__ import annotations

import json
import logging
import os
import sqlite3
import zlib
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from server.annex_loader import (
    get_device_code,
    get_patient_code,
    get_term_by_code,
    load_annex_codes,
    split_problem_terms,
)

log = logging.getLogger("db_engine")

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH_V1 = BASE_DIR / "fda_maude_cgm.db"
DB_PATH_V2 = BASE_DIR / "fda_maude_cgm_v2.db"
BRAND_GROUPS_PATH = BASE_DIR / "brand_groups.json"
FILTER_METADATA_CACHE_PATH = BASE_DIR / ".maude_filter_metadata_cache.json"
BOOKMARKS_PATH = BASE_DIR / "user_bookmarks.json"

_DB_OVERRIDE = os.environ.get("MAUDE_DB_PATH", "").strip()
if _DB_OVERRIDE:
    DB_PATH = Path(_DB_OVERRIDE)
else:
    DB_PATH = DB_PATH_V2 if DB_PATH_V2.exists() else DB_PATH_V1

_PRAGMA_CACHE_KIB = 1_048_576       # 1GB cache
_PRAGMA_MMAP_BYTES = 4_294_967_296  # 4GB mmap

# Check FTS availability
HAS_FTS = False
try:
    if DB_PATH.exists():
        _c = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro", uri=True)
        _fts_check = _c.execute(
            "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='maude_reports_fts'"
        ).fetchone()[0]
        HAS_FTS = bool(_fts_check > 0)
        _c.close()
except Exception as e:
    log.warning(f"Could not verify FTS5 table: {e}")

# Load Brand Groups mapping
CANONICAL_TO_MEMBERS: Dict[str, List[str]] = {}
MEMBER_TO_CANONICAL: Dict[str, str] = {}
CANONICAL_CATEGORIES: Dict[str, str] = {}

def reload_brand_groups():
    global CANONICAL_TO_MEMBERS, MEMBER_TO_CANONICAL, CANONICAL_CATEGORIES
    CANONICAL_TO_MEMBERS = {}
    MEMBER_TO_CANONICAL = {}
    CANONICAL_CATEGORIES = {}
    if BRAND_GROUPS_PATH.exists():
        try:
            with open(BRAND_GROUPS_PATH, "r", encoding="utf-8") as f:
                data = json.load(f)
                groups = data.get("groups", data)
                categories = data.get("categories", {})
                for canon, members in groups.items():
                    CANONICAL_TO_MEMBERS[canon] = [m.strip() for m in members]
                    for m in members:
                        MEMBER_TO_CANONICAL[m.strip()] = canon
                        MEMBER_TO_CANONICAL[m.upper().strip()] = canon
                CANONICAL_CATEGORIES = categories
        except Exception as e:
            log.error(f"Failed to load brand_groups.json: {e}")

reload_brand_groups()


def get_sqlite_conn(readonly: bool = True) -> sqlite3.Connection:
    if readonly:
        conn = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro", uri=True, timeout=30.0)
    else:
        conn = sqlite3.connect(DB_PATH, timeout=30.0)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA busy_timeout = 30000")
    conn.execute(f"PRAGMA cache_size = -{_PRAGMA_CACHE_KIB // 1024}")
    conn.execute(f"PRAGMA mmap_size = {_PRAGMA_MMAP_BYTES}")
    conn.execute("PRAGMA temp_store = MEMORY")
    return conn


def _build_filter_clauses(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    code_filter: Optional[str] = None,
    prefix: str = "r.",
) -> Tuple[List[str], List[Any]]:
    clauses: List[str] = []
    params: List[Any] = []

    # 1. Device Category Filter
    if categories:
        valid_cats = [c for c in categories if c in ("CGM", "Insulin Pump")]
        if valid_cats and len(valid_cats) < 2:
            clauses.append(f"{prefix}device_category = ?")
            params.append(valid_cats[0])

    # 2. Brand Name Filter (expands canonical groups if selected, case-insensitive)
    if brands:
        all_raw_targets = set()
        for b in brands:
            b_norm = b.strip()
            # If b matches a canonical group
            matched_canon = None
            for c_group in CANONICAL_TO_MEMBERS:
                if (
                    c_group.lower() == b_norm.lower()
                    or c_group.lower().replace("+", " plus") == b_norm.lower().replace("+", " plus")
                    or c_group.lower().replace(" plus", "+") == b_norm.lower().replace(" plus", "+")
                ):
                    matched_canon = c_group
                    break

            if matched_canon:
                all_raw_targets.add(matched_canon.upper().strip())
                all_raw_targets.add(b_norm.upper().strip())
                if "+" in matched_canon:
                    all_raw_targets.add(matched_canon.replace("+", " Plus").upper().strip())
                elif " plus" in matched_canon.lower():
                    all_raw_targets.add(matched_canon.replace(" Plus", "+").replace(" plus", "+").upper().strip())
                for member in CANONICAL_TO_MEMBERS[matched_canon]:
                    all_raw_targets.add(member.upper().strip())
            else:
                all_raw_targets.add(b_norm.upper().strip())

        if all_raw_targets:
            placeholders = ",".join(["?"] * len(all_raw_targets))
            clauses.append(f"UPPER({prefix}brand_name) IN ({placeholders})")
            params.extend(list(all_raw_targets))

    # 3. Event Types
    if event_types:
        placeholders = ",".join(["?"] * len(event_types))
        clauses.append(f"{prefix}event_type IN ({placeholders})")
        params.extend(event_types)

    # 4. Date range
    if date_from:
        if prefix.startswith("s"):
            clauses.append(f"{prefix}month >= ?")
            params.append(date_from[:7])
        else:
            clauses.append(f"{prefix}date_received >= ?")
            params.append(date_from)
    if date_to:
        if prefix.startswith("s"):
            clauses.append(f"{prefix}month <= ?")
            params.append(date_to[:7])
        else:
            clauses.append(f"{prefix}date_received <= ?")
            params.append(date_to)

    # 5. IMDRF Code filter
    if code_filter:
        if not prefix.startswith("s"):
            code_term = get_term_by_code(code_filter) or code_filter
            clauses.append(f"({prefix}patient_problems LIKE ? OR {prefix}product_problems LIKE ?)")
            params.extend([f"%{code_term}%", f"%{code_term}%"])

    return clauses, params


# ---------------------------------------------------------------------------
# Metadata Retrieval
# ---------------------------------------------------------------------------
def get_metadata() -> Dict[str, Any]:
    if FILTER_METADATA_CACHE_PATH.exists():
        try:
            with open(FILTER_METADATA_CACHE_PATH, "r", encoding="utf-8") as f:
                data = json.load(f)
                if (
                    isinstance(data, dict)
                    and data.get("total_reports")
                    and data.get("canonical_brands_by_category")
                    and data.get("all_brands_by_category")
                ):
                    return data
        except Exception:
            pass

    with get_sqlite_conn() as conn:
        tot_row = conn.execute("SELECT sum(report_count) FROM maude_monthly_summary").fetchone()
        total_reports = tot_row[0] or 0

        date_bounds = conn.execute(
            "SELECT min(month), max(month) FROM maude_monthly_summary"
        ).fetchone()

        max_date_row = conn.execute(
            "SELECT date_received FROM maude_reports WHERE date_received IS NOT NULL ORDER BY date_received DESC LIMIT 1"
        ).fetchone()
        actual_max_date = max_date_row[0] if max_date_row and max_date_row[0] else (date_bounds[1] + "-30" if date_bounds and date_bounds[1] else "2026-09-30")

        min_date_row = conn.execute(
            "SELECT date_received FROM maude_reports WHERE date_received >= '2020-01-01' ORDER BY date_received ASC LIMIT 1"
        ).fetchone()
        actual_min_date = min_date_row[0] if min_date_row and min_date_row[0] else (date_bounds[0] + "-01" if date_bounds and date_bounds[0] else "2020-01-01")

        all_brands = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT brand_name FROM maude_monthly_summary WHERE brand_name IS NOT NULL AND brand_name != '' ORDER BY brand_name"
            ).fetchall()
        ]

        cgm_brands = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT brand_name FROM maude_monthly_summary WHERE device_category = 'CGM' AND brand_name IS NOT NULL AND brand_name != '' ORDER BY brand_name"
            ).fetchall()
        ]

        pump_brands = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT brand_name FROM maude_monthly_summary WHERE device_category = 'Insulin Pump' AND brand_name IS NOT NULL AND brand_name != '' ORDER BY brand_name"
            ).fetchall()
        ]

        event_types = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT event_type FROM maude_monthly_summary WHERE event_type IS NOT NULL ORDER BY event_type"
            ).fetchall()
        ]

    canonical_brands = list(CANONICAL_TO_MEMBERS.keys())
    canonical_cgm = [c for c, cat in CANONICAL_CATEGORIES.items() if cat == "CGM"] or [
        c for c in canonical_brands if "Libre" in c or "Dexcom" in c or "CGM" in c
    ]
    canonical_pump = [c for c, cat in CANONICAL_CATEGORIES.items() if cat == "Insulin Pump"] or [
        c for c in canonical_brands if c not in canonical_cgm
    ]

    meta = {
        "db_path": str(DB_PATH),
        "total_reports": total_reports,
        "min_date": actual_min_date,
        "max_date": actual_max_date,
        "categories": ["CGM", "Insulin Pump"],
        "canonical_brands": canonical_brands,
        "canonical_brands_by_category": {
            "CGM": canonical_cgm,
            "Insulin Pump": canonical_pump,
        },
        "all_brands": all_brands,
        "all_brands_by_category": {
            "CGM": cgm_brands,
            "Insulin Pump": pump_brands,
        },
        "brand_groups": CANONICAL_TO_MEMBERS,
        "brand_categories": CANONICAL_CATEGORIES,
        "event_types": event_types,
    }

    try:
        with open(FILTER_METADATA_CACHE_PATH, "w", encoding="utf-8") as f:
            json.dump(meta, f, ensure_ascii=False, indent=2)
    except Exception as e:
        log.warning(f"Failed to write metadata cache: {e}")

    return meta


# ---------------------------------------------------------------------------
# Overview Stats
# ---------------------------------------------------------------------------
def get_stats_overview(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    code_filter: Optional[str] = None,
    keyword: Optional[str] = None,
    report_numbers: Optional[List[str]] = None,
    **kwargs: Any,
) -> Dict[str, Any]:
    clauses, params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="s.",
    )
    where_sql = " AND ".join(clauses) if clauses else "1=1"

    with get_sqlite_conn() as conn:
        tot_row = conn.execute(
            f"SELECT sum(s.report_count) FROM maude_monthly_summary s WHERE {where_sql}",
            params,
        ).fetchone()
        total_reports = tot_row[0] or 0

        et_rows = conn.execute(
            f"SELECT s.event_type, sum(s.report_count) FROM maude_monthly_summary s WHERE {where_sql} GROUP BY s.event_type",
            params,
        ).fetchall()
        event_type_counts = {r[0]: (r[1] or 0) for r in et_rows}

        brand_rows = conn.execute(
            f"""
            SELECT s.brand_name, sum(s.report_count) as cnt
            FROM maude_monthly_summary s
            WHERE {where_sql}
            GROUP BY s.brand_name
            ORDER BY cnt DESC
            LIMIT 50
            """,
            params,
        ).fetchall()

        top_raw_brands = [{"brand": r[0], "count": r[1]} for r in brand_rows[:15]]

        canonical_agg: Dict[str, int] = {}
        for r in conn.execute(
            f"SELECT s.brand_name, sum(s.report_count) FROM maude_monthly_summary s WHERE {where_sql} GROUP BY s.brand_name",
            params,
        ).fetchall():
            raw_b = r[0]
            cnt = r[1] or 0
            c_name = MEMBER_TO_CANONICAL.get(raw_b.upper().strip(), None)
            if c_name:
                canonical_agg[c_name] = canonical_agg.get(c_name, 0) + cnt

        canonical_list = []
        for c_group in CANONICAL_TO_MEMBERS.keys():
            cnt = canonical_agg.get(c_group, 0)
            cat = CANONICAL_CATEGORIES.get(c_group, "CGM")
            if categories and len(categories) == 1 and cat != categories[0]:
                continue
            if brands and cnt == 0:
                continue
            canonical_list.append({"brand": c_group, "count": cnt, "category": cat})

        canonical_list.sort(key=lambda x: x["count"], reverse=True)

        cat_rows = conn.execute(
            f"SELECT s.device_category, sum(s.report_count) FROM maude_monthly_summary s WHERE {where_sql} GROUP BY s.device_category",
            params,
        ).fetchall()
        category_counts = {r[0]: (r[1] or 0) for r in cat_rows}

    return {
        "total_reports": total_reports,
        "death_count": event_type_counts.get("Death", 0),
        "injury_count": event_type_counts.get("Injury", 0),
        "malfunction_count": event_type_counts.get("Malfunction", 0),
        "other_count": event_type_counts.get("Other", 0),
        "event_type_counts": event_type_counts,
        "top_brands": canonical_list[:10] if canonical_list else top_raw_brands[:10],
        "top_canonical_brands": canonical_list,
        "top_raw_brands": top_raw_brands,
        "category_counts": category_counts,
    }


# ---------------------------------------------------------------------------
# Monthly Timeline Stats
# ---------------------------------------------------------------------------
def get_stats_monthly(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    code_filter: Optional[str] = None,
    keyword: Optional[str] = None,
    report_numbers: Optional[List[str]] = None,
    **kwargs: Any,
) -> List[Dict[str, Any]]:
    clauses, params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="s.",
    )
    where_sql = " AND ".join(clauses) if clauses else "1=1"

    with get_sqlite_conn() as conn:
        rows = conn.execute(
            f"""
            SELECT s.month, s.brand_name, s.event_type, sum(s.report_count) as cnt
            FROM maude_monthly_summary s
            WHERE {where_sql}
            GROUP BY s.month, s.brand_name, s.event_type
            ORDER BY s.month ASC
            """,
            params,
        ).fetchall()

    agg: Dict[Tuple[str, str, str, str], int] = {}
    for r in rows:
        ym, raw_b, et, cnt = r[0], r[1], r[2], r[3]
        c_brand = MEMBER_TO_CANONICAL.get(raw_b.upper().strip(), raw_b)
        key = (ym, c_brand, raw_b, et)
        agg[key] = agg.get(key, 0) + cnt

    result = []
    for (ym, b_name, raw_b, et), cnt in agg.items():
        result.append({
            "month": ym,
            "brand_name": b_name,
            "raw_brand_name": raw_b,
            "event_type": et,
            "count": cnt,
        })

    result.sort(key=lambda x: (x["month"], x["brand_name"]))
    return result


# ---------------------------------------------------------------------------
# Reports Table Query with CTE Late Join for 100% Accurate Narrative Evaluation
# ---------------------------------------------------------------------------
def query_reports(
    filters: Optional[Dict[str, Any]] = None,
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    keyword: Optional[str] = None,
    code_filter: Optional[str] = None,
    report_numbers: Optional[List[str]] = None,
    page: int = 1,
    page_size: int = 50,
    sort_by: str = "date_received",
    sort_desc: bool = True,
    **kwargs: Any,
) -> Dict[str, Any]:
    if isinstance(filters, dict):
        categories = filters.get("categories", categories)
        brands = filters.get("brands", brands)
        event_types = filters.get("event_types", event_types)
        date_from = filters.get("date_from", date_from)
        date_to = filters.get("date_to", date_to)
        keyword = filters.get("keyword", keyword)
        code_filter = filters.get("code_filter", code_filter)
        report_numbers = filters.get("report_numbers", report_numbers)

    offset = max(0, (page - 1) * page_size)
    allowed_sorts = {
        "date_received", "report_number", "brand_name", "event_type",
        "manufacturer_name", "date_of_event", "device_category"
    }
    order_col = f"r.{sort_by}" if sort_by in allowed_sorts else "r.date_received"
    order_dir = "DESC" if sort_desc else "ASC"

    clauses, params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="r.",
    )

    if report_numbers:
        placeholders = ",".join(["?"] * len(report_numbers))
        clauses.append(f"r.report_number IN ({placeholders})")
        params.extend(report_numbers)

    # Keyword search clause
    kw = (keyword or "").strip()
    if kw:
        clauses.append(
            "(r.report_number LIKE ? OR r.brand_name LIKE ? OR "
            "r.summary_complaint_kr LIKE ? OR r.patient_problems LIKE ? OR r.product_problems LIKE ?)"
        )
        like_kw = f"%{kw}%"
        params.extend([like_kw, like_kw, like_kw, like_kw, like_kw])

    where_sql = " AND ".join(clauses) if clauses else "1=1"

    # Optimization: Determine optimal index hint to avoid full table sort when filtering by category, event_type, or date
    index_hint = ""
    if event_types and ("Death" in event_types or (len(event_types) == 1 and event_types[0] != "Malfunction")):
        index_hint = "INDEXED BY idx_reports_event_date"
    elif sort_by in ("date_received", "date_of_event", "event_type") or not sort_by:
        if event_types and len(event_types) == 1:
            index_hint = "INDEXED BY idx_reports_event_date"
        elif categories and len(categories) == 1 and not brands and not event_types:
            index_hint = "INDEXED BY idx_reports_cat_date"
        elif not categories and not brands and not event_types and not keyword:
            index_hint = "INDEXED BY idx_reports_date"

    # CTE Late Join Pattern: Page first from indexed table, then join text table only for the 50 rows
    data_sql = f"""
        WITH paged AS (
            SELECT r.report_number, r.mdr_report_key, r.event_type, r.date_received, r.date_of_event,
                   r.brand_name, r.device_category, r.manufacturer_name, r.patient_problems, r.product_problems,
                   r.summary_complaint_kr, r.summary_response_kr, r.summary_conclusion_kr
            FROM maude_reports r {index_hint}
            WHERE {where_sql}
            ORDER BY {order_col} {order_dir}
            LIMIT ? OFFSET ?
        )
        SELECT p.*,
               ((t.event_description IS NOT NULL AND length(trim(t.event_description)) > 10) OR
                (t.manufacturer_narrative IS NOT NULL AND length(trim(t.manufacturer_narrative)) > 10) OR
                (t.additional_manufacturer_narrative IS NOT NULL AND length(trim(t.additional_manufacturer_narrative)) > 10)) AS has_real_narrative
        FROM paged p
        LEFT JOIN maude_reports_text t ON t.report_number = p.report_number
    """

    with get_sqlite_conn() as conn:
        cursor = conn.execute(data_sql, params + [page_size, offset])
        rows = []
        for r in cursor.fetchall():
            row_dict = dict(r)
            has_narr = bool(row_dict.get("has_real_narrative"))
            row_dict["has_narrative"] = has_narr
            rows.append(row_dict)

        # Total count calculation:
        # If no free-text or code filter, fetch exact count instantly from maude_monthly_summary
        total_count = 0
        if not kw and not code_filter and not report_numbers:
            s_clauses, s_params = _build_filter_clauses(
                categories=categories,
                brands=brands,
                event_types=event_types,
                date_from=date_from,
                date_to=date_to,
                prefix="s.",
            )
            s_where = " AND ".join(s_clauses) if s_clauses else "1=1"
            row = conn.execute(
                f"SELECT COALESCE(sum(s.report_count), 0) FROM maude_monthly_summary s WHERE {s_where}",
                s_params,
            ).fetchone()
            total_count = int(row[0]) if row and row[0] is not None else 0
        else:
            count_sql = f"SELECT count(*) FROM (SELECT 1 FROM maude_reports r {index_hint} WHERE {where_sql} LIMIT 5000)"
            total_count = conn.execute(count_sql, params).fetchone()[0]

    return {
        "total": total_count,
        "page": page,
        "page_size": page_size,
        "items": rows,
    }


# ---------------------------------------------------------------------------
# Report Detail Retrieval
# ---------------------------------------------------------------------------
def get_report_detail(report_number: str) -> Optional[Dict[str, Any]]:
    with get_sqlite_conn() as conn:
        row = conn.execute(
            "SELECT * FROM maude_reports WHERE report_number = ?", (report_number,)
        ).fetchone()
        if not row:
            return None

        result = dict(row)

        try:
            t_row = conn.execute(
                "SELECT event_description, manufacturer_narrative, additional_manufacturer_narrative "
                "FROM maude_reports_text WHERE report_number = ?",
                (report_number,),
            ).fetchone()
            if t_row:
                result["event_description"] = t_row["event_description"]
                result["manufacturer_narrative"] = t_row["manufacturer_narrative"]
                result["additional_manufacturer_narrative"] = t_row["additional_manufacturer_narrative"]
        except Exception:
            pass

        # Load compressed raw JSON
        try:
            raw_row = conn.execute(
                "SELECT raw_json_z FROM maude_reports_raw WHERE report_number = ?",
                (report_number,),
            ).fetchone()
            if raw_row and raw_row[0]:
                result["raw_json"] = json.loads(zlib.decompress(raw_row[0]).decode("utf-8"))
        except Exception:
            result["raw_json"] = None

    # Determine accurate has_narrative
    has_narr = bool(
        (result.get("event_description") and len(str(result["event_description"]).strip()) > 10) or
        (result.get("manufacturer_narrative") and len(str(result["manufacturer_narrative"]).strip()) > 10) or
        (result.get("additional_manufacturer_narrative") and len(str(result["additional_manufacturer_narrative"]).strip()) > 10)
    )
    result["has_narrative"] = has_narr

    # IMDRF Annex mappings
    patient_terms = split_problem_terms(result.get("patient_problems"))
    product_terms = split_problem_terms(result.get("product_problems"))

    result["patient_problem_list"] = [
        {"term": term, "code": get_patient_code(term) or "코드미상"}
        for term in patient_terms if term
    ]
    result["product_problem_list"] = [
        {"term": term, "code": get_device_code(term) or "코드미상"}
        for term in product_terms if term
    ]

    return result


# ---------------------------------------------------------------------------
# Problem Codes Analysis (Annex E & Annex A)
# ---------------------------------------------------------------------------
def get_problem_codes_stats(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    code_filter: Optional[str] = None,
    keyword: Optional[str] = None,
    report_numbers: Optional[List[str]] = None,
    limit: int = 20,
    **kwargs: Any,
) -> Dict[str, Any]:
    clauses, params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="r.",
    )
    if keyword and keyword.strip():
        kw = f"%{keyword.strip()}%"
        clauses.append("(r.brand_name LIKE ? OR r.generic_name LIKE ? OR r.manufacturer_name LIKE ? OR r.patient_problems LIKE ? OR r.product_problems LIKE ? OR r.report_number LIKE ?)")
        params.extend([kw, kw, kw, kw, kw, kw])

    where_sql = " AND ".join(clauses) if clauses else "1=1"

    with get_sqlite_conn() as conn:
        rows = conn.execute(
            f"""
            SELECT r.brand_name, r.patient_problems, r.product_problems
            FROM maude_reports r
            WHERE {where_sql}
            LIMIT 2000
            """,
            params,
        ).fetchall()

    patient_counts: Dict[str, int] = {}
    patient_brands: Dict[str, Dict[str, int]] = {}
    product_counts: Dict[str, int] = {}
    product_brands: Dict[str, Dict[str, int]] = {}

    for r in rows:
        raw_b = r[0] or "Unknown"
        c_brand = MEMBER_TO_CANONICAL.get(raw_b.upper().strip(), raw_b)
        p_probs = split_problem_terms(r[1])
        d_probs = split_problem_terms(r[2])

        for p in p_probs:
            if p and p != "No Clinical Signs, Symptoms or Conditions" and p != "No Information":
                patient_counts[p] = patient_counts.get(p, 0) + 1
                if p not in patient_brands:
                    patient_brands[p] = {}
                patient_brands[p][c_brand] = patient_brands[p].get(c_brand, 0) + 1

        for d in d_probs:
            if d and d != "No Information" and len(d) > 2:
                product_counts[d] = product_counts.get(d, 0) + 1
                if d not in product_brands:
                    product_brands[d] = {}
                product_brands[d][c_brand] = product_brands[d].get(c_brand, 0) + 1

    top_patient = []
    for term, count in sorted(patient_counts.items(), key=lambda x: x[1], reverse=True)[:limit]:
        code = get_patient_code(term) or "코드미상"
        top_patient.append({
            "term": term,
            "code": code,
            "count": count,
            "brand_breakdown": patient_brands.get(term, {}),
        })

    top_product = []
    for term, count in sorted(product_counts.items(), key=lambda x: x[1], reverse=True)[:limit]:
        code = get_device_code(term) or "코드미상"
        top_product.append({
            "term": term,
            "code": code,
            "count": count,
            "brand_breakdown": product_brands.get(term, {}),
        })

    return {
        "patient_problems": top_patient,
        "product_problems": top_product,
    }


def _map_source_type_to_pathway(report_source_code: Optional[str], source_type: Optional[str]) -> str:
    rsc = (report_source_code or "").strip().upper()
    st = (source_type or "").strip().upper()

    if "FOREIGN" in st or "FOREIGN" in rsc:
        return "Foreign (해외 보고)"
    if "DISTRIBUTOR" in st or "DISTRIBUTOR" in rsc:
        return "Distributor (유통/수입사)"
    if "VOLUNTARY" in rsc or "CONSUMER" in st or "PATIENT" in st or "HEALTH PROFESSIONAL" in st or "USER" in st:
        return "MedWatch (자발적 보고)"
    if "MANUFACTURER" in rsc or "COMPANY" in st or "MDR" in rsc:
        return "MDR (제조사 의무보고)"
    return "Other/Literature (문헌/기타)"


# ---------------------------------------------------------------------------
# Insights & Advanced Analytics
# ---------------------------------------------------------------------------
def get_insights(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    code_filter: Optional[str] = None,
    keyword: Optional[str] = None,
    report_numbers: Optional[List[str]] = None,
    **kwargs: Any,
) -> Dict[str, Any]:
    clauses, params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="s.",
    )
    where_sql = " AND ".join(clauses) if clauses else "1=1"

    with get_sqlite_conn() as conn:
        rows = conn.execute(
            f"""
            SELECT s.month, s.brand_name, s.event_type, sum(s.report_count)
            FROM maude_monthly_summary s
            WHERE {where_sql}
            GROUP BY s.month, s.brand_name, s.event_type
            """,
            params,
        ).fetchall()

    canonical_severity: Dict[str, Dict[str, int]] = {}
    raw_severity: Dict[str, Dict[str, int]] = {}
    monthly_trend_map: Dict[str, int] = {}

    for r in rows:
        ym, raw_b, et, cnt = r[0], r[1], r[2], r[3]
        c_brand = MEMBER_TO_CANONICAL.get(raw_b.upper().strip(), raw_b)

        if c_brand not in canonical_severity:
            canonical_severity[c_brand] = {"Death": 0, "Injury": 0, "Malfunction": 0, "Other": 0}
        canonical_severity[c_brand][et] = canonical_severity[c_brand].get(et, 0) + cnt

        if raw_b not in raw_severity:
            raw_severity[raw_b] = {"Death": 0, "Injury": 0, "Malfunction": 0, "Other": 0}
        raw_severity[raw_b][et] = raw_severity[raw_b].get(et, 0) + cnt

        monthly_trend_map[ym] = monthly_trend_map.get(ym, 0) + cnt

    # Pathways distribution and time-series from indexed sample
    r_clauses, r_params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="r.",
    )
    if keyword and keyword.strip():
        kw = f"%{keyword.strip()}%"
        r_clauses.append("(r.brand_name LIKE ? OR r.generic_name LIKE ? OR r.manufacturer_name LIKE ? OR r.patient_problems LIKE ? OR r.product_problems LIKE ? OR r.report_number LIKE ?)")
        r_params.extend([kw, kw, kw, kw, kw, kw])

    r_where = " AND ".join(r_clauses) if r_clauses else "1=1"
    
    with get_sqlite_conn() as conn:
        src_rows = conn.execute(
            f"""
            SELECT substr(date_received, 1, 7) as ym,
                   report_source_code,
                   source_type,
                   count(*) as cnt
            FROM (
                SELECT date_received, report_source_code, source_type
                FROM maude_reports r
                WHERE {r_where}
                LIMIT 5000
            ) sub
            GROUP BY ym, report_source_code, source_type
            ORDER BY ym ASC
            """,
            r_params,
        ).fetchall()

    timeline_map: Dict[str, Dict[str, Any]] = {}
    pathways_dist: Dict[str, int] = {
        "MDR (제조사 의무보고)": 0,
        "MedWatch (자발적 보고)": 0,
        "Foreign (해외 보고)": 0,
        "Distributor (유통/수입사)": 0,
        "Other/Literature (문헌/기타)": 0,
    }

    for r in src_rows:
        ym, rsc, st, cnt = r[0], r[1], r[2], r[3]
        if not ym or len(ym) < 7:
            continue
        pathway = _map_source_type_to_pathway(rsc, st)
        pathways_dist[pathway] = pathways_dist.get(pathway, 0) + cnt

        if ym not in timeline_map:
            timeline_map[ym] = {
                "month": ym,
                "MDR (제조사 의무보고)": 0,
                "MedWatch (자발적 보고)": 0,
                "Foreign (해외 보고)": 0,
                "Distributor (유통/수입사)": 0,
                "Other/Literature (문헌/기타)": 0,
            }
        timeline_map[ym][pathway] += cnt

    pathways_timeline = [timeline_map[ym] for ym in sorted(timeline_map.keys())]

    recent_trend = [
        {"month": ym, "count": monthly_trend_map[ym]}
        for ym in sorted(monthly_trend_map.keys())[-12:]
    ]

    return {
        "canonical_severity": canonical_severity,
        "raw_severity": raw_severity,
        "pathways_distribution": pathways_dist,
        "pathways_timeline": pathways_timeline,
        "recent_month_trend": recent_trend,
    }


# ---------------------------------------------------------------------------
# Bookmarks Management
# ---------------------------------------------------------------------------
def get_bookmarks() -> Dict[str, Any]:
    if BOOKMARKS_PATH.exists():
        try:
            with open(BOOKMARKS_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"bookmarks": {}, "folders": ["기본 보관함", "임상 분석", "제조 결함", "저혈당 쇼크"]}


load_bookmarks = get_bookmarks


def save_bookmark(
    report_number: str,
    folder: str = "기본 보관함",
    tags: Optional[List[str]] = None,
    note: str = "",
) -> Dict[str, Any]:
    data = get_bookmarks()
    bookmarks = data.get("bookmarks", {})
    folders = data.get("folders", ["기본 보관함"])

    if folder not in folders:
        folders.append(folder)

    bookmarks[report_number] = {
        "report_number": report_number,
        "folder": folder,
        "tags": tags or [],
        "note": note,
        "saved_at": datetime.now().strftime("%Y-%m-%d %H:%M"),
    }

    data["bookmarks"] = bookmarks
    data["folders"] = folders

    with open(BOOKMARKS_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    return data


set_bookmark = save_bookmark


def delete_bookmark(report_number: str) -> Dict[str, Any]:
    data = get_bookmarks()
    bookmarks = data.get("bookmarks", {})
    if report_number in bookmarks:
        del bookmarks[report_number]
        data["bookmarks"] = bookmarks
        with open(BOOKMARKS_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    return data


def save_brand_groups(groups: Dict[str, List[str]], categories: Optional[Dict[str, str]] = None) -> bool:
    try:
        data = {
            "groups": groups,
            "categories": categories or CANONICAL_CATEGORIES,
        }
        with open(BRAND_GROUPS_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        reload_brand_groups()

        if FILTER_METADATA_CACHE_PATH.exists():
            FILTER_METADATA_CACHE_PATH.unlink()

        return True
    except Exception as e:
        log.error(f"Failed to save brand_groups.json: {e}")
        return False


# ---------------------------------------------------------------------------
# ISO 14971 MAUDE Hazard Intelligence Engine
# ---------------------------------------------------------------------------
def init_hazard_table():
    """Initializes the maude_hazards table and indices if they do not exist."""
    with get_sqlite_conn(readonly=False) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS maude_hazards (
                hazard_row_id TEXT PRIMARY KEY,
                report_number TEXT NOT NULL,
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
                cgm_relevance_score INTEGER DEFAULT 0,
                pump_relevance_score INTEGER DEFAULT 0,
                aid_relevance_score INTEGER DEFAULT 0,
                patient_risk_score INTEGER DEFAULT 0,
                fda_action_summary_ko TEXT,
                care_sens_implication_ko TEXT,
                isens_preparation_ko TEXT,
                recommended_preventive_controls TEXT,
                recommended_recall_controls TEXT,
                workflow_status TEXT DEFAULT '미검토',
                reviewer_name TEXT DEFAULT '',
                review_note TEXT DEFAULT '',
                internal_tags TEXT DEFAULT '',
                created_at TEXT,
                updated_at TEXT
            )
        """)
        conn.execute("CREATE INDEX IF NOT EXISTS idx_maude_hazards_rep_num ON maude_hazards(report_number)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_maude_hazards_workflow ON maude_hazards(workflow_status)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_maude_hazards_risk ON maude_hazards(risk_level)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_maude_hazards_aid_score ON maude_hazards(aid_relevance_score)")


def get_hazards(filters: Dict[str, Any], confirmed_only: bool = False) -> List[Dict[str, Any]]:
    """Retrieves ISO 14971 hazard list with domain filters."""
    init_hazard_table()
    where_parts = []
    params = []

    if confirmed_only:
        where_parts.append("(h.workflow_status = '검토완료' OR h.workflow_status = '확정')")

    if filters.get("hazard_category"):
        where_parts.append("h.hazard_category_primary = ?")
        params.append(filters["hazard_category"])

    if filters.get("risk_level"):
        where_parts.append("h.risk_level = ?")
        params.append(filters["risk_level"])

    if filters.get("min_aid_score") is not None and str(filters["min_aid_score"]).isdigit() and int(filters["min_aid_score"]) > 0:
        where_parts.append("h.aid_relevance_score >= ?")
        params.append(int(filters["min_aid_score"]))

    if filters.get("workflow_status"):
        where_parts.append("h.workflow_status = ?")
        params.append(filters["workflow_status"])

    if filters.get("keyword") and str(filters["keyword"]).strip():
        kw = f"%{filters['keyword'].strip()}%"
        where_parts.append(
            "(h.hazard_ko LIKE ? OR h.initiating_event_ko LIKE ? OR "
            "h.hazardous_situation_ko LIKE ? OR h.harm_ko LIKE ? OR "
            "h.care_sens_implication_ko LIKE ? OR h.report_number LIKE ? OR h.brand_name LIKE ?)"
        )
        params.extend([kw, kw, kw, kw, kw, kw, kw])

    where_sql = " AND ".join(where_parts) if where_parts else "1=1"

    query = f"""
        SELECT h.*,
               COALESCE(r.patient_problems, '') as patient_problems,
               COALESCE(r.product_problems, '') as product_problems,
               COALESCE(r.summary_complaint_kr, '') as summary_complaint_kr
        FROM maude_hazards h
        LEFT JOIN maude_reports r ON h.report_number = r.report_number
        WHERE {where_sql}
        ORDER BY h.aid_relevance_score DESC, h.risk_level DESC, h.created_at DESC
        LIMIT 500
    """

    with get_sqlite_conn() as conn:
        rows = conn.execute(query, params).fetchall()
        return [dict(r) for r in rows]


def get_confirmed_hazards(filters: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Retrieves only approved/confirmed hazard items for final RMF matrix."""
    return get_hazards(filters=filters, confirmed_only=True)


def get_reports_hazard_status(report_numbers: List[str]) -> Dict[str, Dict[str, Any]]:
    """Returns mapping of report_number -> {has_hazard, hazard_status, hazard_count} for UI list."""
    if not report_numbers:
        return {}
    init_hazard_table()
    placeholders = ",".join(["?"] * len(report_numbers))
    query = f"""
        SELECT report_number,
               count(*) as hazard_count,
               max(workflow_status) as status_max,
               min(workflow_status) as status_min
        FROM maude_hazards
        WHERE report_number IN ({placeholders})
        GROUP BY report_number
    """
    result: Dict[str, Dict[str, Any]] = {}
    with get_sqlite_conn() as conn:
        rows = conn.execute(query, report_numbers).fetchall()
        for r in rows:
            rn = r[0]
            cnt = r[1]
            s_max = r[2]
            s_min = r[3]
            status = "검토완료" if s_max == "검토완료" and s_min == "검토완료" else ("부분검토" if "검토완료" in (s_max, s_min) else "미검토")
            result[rn] = {
                "has_hazard": cnt > 0,
                "hazard_count": cnt,
                "hazard_status": status,
            }
    return result


def save_hazard_review(
    hazard_row_id: str,
    workflow_status: str,
    reviewer_name: str,
    review_note: str,
    internal_tags: str = "",
) -> Dict[str, Any]:
    """Updates review workflow status, reviewer, and notes for a specific hazard."""
    init_hazard_table()
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with get_sqlite_conn(readonly=False) as conn:
        conn.execute("""
            UPDATE maude_hazards
               SET workflow_status = ?,
                   reviewer_name = ?,
                   review_note = ?,
                   internal_tags = ?,
                   updated_at = ?
             WHERE hazard_row_id = ?
        """, (workflow_status, reviewer_name, review_note, internal_tags, now_str, hazard_row_id))
    return {"success": True, "hazard_row_id": hazard_row_id, "workflow_status": workflow_status}


def save_hazard_review_batch(
    report_numbers: List[str],
    workflow_status: str,
    reviewer_name: str,
    review_note: str,
    internal_tags: str = "",
) -> int:
    """Updates review workflow status in bulk for all hazards under the given report numbers."""
    if not report_numbers:
        return 0
    init_hazard_table()
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    placeholders = ",".join(["?"] * len(report_numbers))
    query = f"""
        UPDATE maude_hazards
           SET workflow_status = ?,
               reviewer_name = ?,
               review_note = ?,
               internal_tags = ?,
               updated_at = ?
         WHERE report_number IN ({placeholders})
    """
    params = [workflow_status, reviewer_name, review_note, internal_tags, now_str] + report_numbers
    with get_sqlite_conn(readonly=False) as conn:
        cursor = conn.execute(query, params)
        return cursor.rowcount


def delete_hazard(hazard_row_id: str) -> bool:
    """Deletes a single hazard row from maude_hazards."""
    init_hazard_table()
    with get_sqlite_conn(readonly=False) as conn:
        cursor = conn.execute("DELETE FROM maude_hazards WHERE hazard_row_id = ?", (hazard_row_id,))
        return cursor.rowcount > 0


def delete_hazards_by_report(report_number: str) -> int:
    """Deletes all hazards for a specific report_number."""
    init_hazard_table()
    with get_sqlite_conn(readonly=False) as conn:
        cursor = conn.execute("DELETE FROM maude_hazards WHERE report_number = ?", (report_number,))
        return cursor.rowcount


def export_hazards_to_excel(
    filters: Dict[str, Any],
    export_type: str = "final",  # "final" | "operations"
    confirmed_only: bool = False,
) -> bytes:
    """Generates styled professional Excel workbook for ISO 14971 final hazards or operational matrix."""
    import io
    import openpyxl
    from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
    from openpyxl.utils import get_column_letter

    hazards = get_hazards(filters=filters, confirmed_only=confirmed_only)

    wb = openpyxl.Workbook()
    ws = wb.active

    font_family = "맑은 고딕"
    header_font = Font(name=font_family, size=10, bold=True, color="FFFFFF")
    data_font = Font(name=font_family, size=9)
    bold_data_font = Font(name=font_family, size=9, bold=True)

    header_fill = PatternFill(start_color="0F172A", end_color="0F172A", fill_type="solid")  # Slate 900
    thin_border_side = Side(border_style="thin", color="CBD5E1")
    border = Border(left=thin_border_side, right=thin_border_side, top=thin_border_side, bottom=thin_border_side)

    align_center = Alignment(horizontal="center", vertical="center", wrap_text=True)
    align_left = Alignment(horizontal="left", vertical="center", wrap_text=True)

    if export_type == "final":
        ws.title = "ISO 14971 최종 위해 분석"
        headers = [
            "MDR 보고서 번호",
            "제품명 (Brand)",
            "의료기기 분류",
            "부작용 유형",
            "접수일자",
            "Hazard ID",
            "위해 분류 (Category)",
            "위해 요인 (Hazard)",
            "원인 사건 (Initiating Event)",
            "위해 상황 (Hazardous Situation)",
            "환자 위해 (Harm)",
            "심각도 (S)",
            "발생확률 (P)",
            "위험 수준 (Risk Level)",
            "AID 연동 관련도 (1-5)",
            "CareSens Air / AID 시사점",
            "권장 설계 예방 통제안 (Preventive Controls)",
            "검토 의견 (Review Note)",
        ]
        ws.append(headers)

        for r in hazards:
            row_data = [
                r.get("report_number") or "",
                r.get("brand_name") or "",
                r.get("device_category") or "",
                r.get("event_type") or "",
                r.get("date_received") or "",
                r.get("hazard_id_local") or r.get("hazard_row_id") or "",
                r.get("hazard_category_primary") or "",
                r.get("hazard_ko") or "",
                r.get("initiating_event_ko") or "",
                r.get("hazardous_situation_ko") or "",
                r.get("harm_ko") or "",
                r.get("severity_level") or "",
                r.get("probability_level") or "",
                r.get("risk_level") or "",
                r.get("aid_relevance_score") or 0,
                r.get("care_sens_implication_ko") or "",
                r.get("recommended_preventive_controls") or "",
                r.get("review_note") or "",
            ]
            ws.append(row_data)

    else:  # "operations"
        ws.title = "위해 분석 사내 운영 매트릭스"
        headers = [
            "Hazard Row ID",
            "MDR 보고서 번호",
            "제품명",
            "부작용",
            "접수일",
            "위해 요인",
            "원인 사건",
            "위해 상황",
            "환자 위해",
            "위험 수준",
            "AID 관련도",
            "검토 상태 (Status)",
            "검토자 (Reviewer)",
            "검토 의견 (Note)",
            "사내 태그 (Tags)",
            "생성일시",
            "수정일시",
        ]
        ws.append(headers)

        for r in hazards:
            row_data = [
                r.get("hazard_row_id") or "",
                r.get("report_number") or "",
                r.get("brand_name") or "",
                r.get("event_type") or "",
                r.get("date_received") or "",
                r.get("hazard_ko") or "",
                r.get("initiating_event_ko") or "",
                r.get("hazardous_situation_ko") or "",
                r.get("harm_ko") or "",
                r.get("risk_level") or "",
                r.get("aid_relevance_score") or 0,
                r.get("workflow_status") or "미검토",
                r.get("reviewer_name") or "",
                r.get("review_note") or "",
                r.get("internal_tags") or "",
                r.get("created_at") or "",
                r.get("updated_at") or "",
            ]
            ws.append(row_data)

    # Styling Header
    ws.row_dimensions[1].height = 28
    for col_num in range(1, len(headers) + 1):
        cell = ws.cell(row=1, column=col_num)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = align_center
        cell.border = border

    # Styling Rows
    risk_fills = {
        "High": PatternFill(start_color="FFE4E6", end_color="FFE4E6", fill_type="solid"),     # Rose 100
        "Medium": PatternFill(start_color="FEF3C7", end_color="FEF3C7", fill_type="solid"),   # Amber 100
        "Low": PatternFill(start_color="E0F2FE", end_color="E0F2FE", fill_type="solid"),      # Sky 100
    }
    status_fills = {
        "검토완료": PatternFill(start_color="DCFCE7", end_color="DCFCE7", fill_type="solid"),  # Emerald 100
        "확정": PatternFill(start_color="DCFCE7", end_color="DCFCE7", fill_type="solid"),
        "미검토": PatternFill(start_color="F1F5F9", end_color="F1F5F9", fill_type="solid"),   # Slate 100
        "보류": PatternFill(start_color="FEF9C3", end_color="FEF9C3", fill_type="solid"),
        "제외": PatternFill(start_color="F3F4F6", end_color="F3F4F6", fill_type="solid"),
    }

    for row_idx in range(2, len(hazards) + 2):
        ws.row_dimensions[row_idx].height = 24
        for col_idx in range(1, len(headers) + 1):
            cell = ws.cell(row=row_idx, column=col_idx)
            cell.font = data_font
            cell.border = border
            header_name = headers[col_idx - 1]

            if any(k in header_name for k in ["번호", "ID", "일자", "일시", "수준", "분류", "상태", "검토자", "관련도", "S", "P"]):
                cell.alignment = align_center
            else:
                cell.alignment = align_left

            # Highlight Risk Level
            if "위험 수준" in header_name and cell.value in risk_fills:
                cell.fill = risk_fills[cell.value]
                cell.font = bold_data_font

            # Highlight Status
            if "상태" in header_name and cell.value in status_fills:
                cell.fill = status_fills[cell.value]
                cell.font = bold_data_font

    # Column Widths
    for col in ws.columns:
        col_letter = get_column_letter(col[0].column)
        max_len = 0
        for cell in col:
            val_str = str(cell.value or "")
            first_line = val_str.split("\n")[0]
            max_len = max(max_len, len(first_line.encode("utf-8", "ignore")))
        ws.column_dimensions[col_letter].width = min(max(max_len + 3, 12), 45)

    buffer = io.BytesIO()
    wb.save(buffer)
    return buffer.getvalue()

