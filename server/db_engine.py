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
                    CANONICAL_TO_MEMBERS[canon] = [m.upper().strip() for m in members]
                    for m in members:
                        MEMBER_TO_CANONICAL[m.upper().strip()] = canon
                CANONICAL_CATEGORIES = categories
        except Exception as e:
            log.error(f"Failed to load brand_groups.json: {e}")

reload_brand_groups()


def get_sqlite_conn(readonly: bool = True) -> sqlite3.Connection:
    if readonly:
        conn = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro", uri=True)
    else:
        conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
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

    # 2. Brand Name Filter (expands canonical groups if selected)
    if brands:
        all_raw_targets = set()
        for b in brands:
            b_norm = b.strip()
            # If b matches a canonical group
            matched_canon = None
            for c_group in CANONICAL_TO_MEMBERS:
                if c_group.lower() == b_norm.lower():
                    matched_canon = c_group
                    break
            
            if matched_canon:
                for member in CANONICAL_TO_MEMBERS[matched_canon]:
                    all_raw_targets.add(member)
            else:
                all_raw_targets.add(b_norm.upper())

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
        clauses.append(f"{prefix}date_received >= ?")
        params.append(date_from)
    if date_to:
        clauses.append(f"{prefix}date_received <= ?")
        params.append(date_to)

    # 5. IMDRF Code filter
    if code_filter:
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
                return json.load(f)
        except Exception:
            pass

    with get_sqlite_conn() as conn:
        total_reports = conn.execute("SELECT count(*) FROM maude_reports").fetchone()[0]
        date_bounds = conn.execute(
            "SELECT min(date_received), max(date_received) FROM maude_reports"
        ).fetchone()

        all_brands = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT brand_name FROM maude_reports WHERE brand_name IS NOT NULL AND brand_name != '' ORDER BY brand_name"
            ).fetchall()
        ]

        cgm_brands = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT brand_name FROM maude_reports WHERE device_category = 'CGM' AND brand_name IS NOT NULL AND brand_name != '' ORDER BY brand_name"
            ).fetchall()
        ]

        pump_brands = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT brand_name FROM maude_reports WHERE device_category = 'Insulin Pump' AND brand_name IS NOT NULL AND brand_name != '' ORDER BY brand_name"
            ).fetchall()
        ]

        event_types = [
            r[0]
            for r in conn.execute(
                "SELECT DISTINCT event_type FROM maude_reports WHERE event_type IS NOT NULL ORDER BY event_type"
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
        "min_date": date_bounds[0] or "2020-01-01",
        "max_date": date_bounds[1] or "2026-08-31",
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
            SELECT s.year_month, s.brand_name, s.event_type, sum(s.report_count) as cnt
            FROM maude_monthly_summary s
            WHERE {where_sql}
            GROUP BY s.year_month, s.brand_name, s.event_type
            ORDER BY s.year_month ASC
            """,
            params,
        ).fetchall()

    agg: Dict[Tuple[str, str, str], int] = {}
    for r in rows:
        ym, raw_b, et, cnt = r[0], r[1], r[2], r[3]
        c_brand = MEMBER_TO_CANONICAL.get(raw_b.upper().strip(), raw_b)
        key = (ym, c_brand, et)
        agg[key] = agg.get(key, 0) + cnt

    result = []
    for (ym, b_name, et), cnt in agg.items():
        result.append({
            "month": ym,
            "brand_name": b_name,
            "event_type": et,
            "count": cnt,
        })

    result.sort(key=lambda x: (x["month"], x["brand_name"]))
    return result


# ---------------------------------------------------------------------------
# Reports Table Query with CTE Late Join for 100% Accurate Narrative Evaluation
# ---------------------------------------------------------------------------
def query_reports(
    filters: Dict[str, Any],
    page: int = 1,
    page_size: int = 50,
    sort_by: str = "date_received",
    sort_desc: bool = True,
) -> Dict[str, Any]:
    categories = filters.get("categories")
    brands = filters.get("brands")
    event_types = filters.get("event_types")
    date_from = filters.get("date_from")
    date_to = filters.get("date_to")
    keyword = filters.get("keyword")
    code_filter = filters.get("code_filter")
    report_numbers = filters.get("report_numbers")

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

    # CTE Late Join Pattern: Page first from indexed table, then join text table only for the 50 rows
    data_sql = f"""
        WITH paged AS (
            SELECT r.report_number, r.mdr_report_key, r.event_type, r.date_received, r.date_of_event,
                   r.brand_name, r.device_category, r.manufacturer_name, r.patient_problems, r.product_problems,
                   r.summary_complaint_kr, r.summary_response_kr, r.summary_conclusion_kr
            FROM maude_reports r
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

    count_sql = f"SELECT count(*) FROM (SELECT 1 FROM maude_reports r WHERE {where_sql} LIMIT 2000)"

    with get_sqlite_conn() as conn:
        cursor = conn.execute(data_sql, params + [page_size, offset])
        rows = []
        for r in cursor.fetchall():
            row_dict = dict(r)
            has_narr = bool(row_dict.get("has_real_narrative"))
            row_dict["has_narrative"] = has_narr
            rows.append(row_dict)

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
    where_sql = " AND ".join(clauses) if clauses else "1=1"

    with get_sqlite_conn() as conn:
        rows = conn.execute(
            f"""
            SELECT r.brand_name, r.patient_problems, r.product_problems
            FROM maude_reports r
            WHERE {where_sql} AND (r.patient_problems IS NOT NULL OR r.product_problems IS NOT NULL)
            LIMIT 50000
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
            SELECT s.year_month, s.brand_name, s.event_type, s.report_source_code, sum(s.report_count)
            FROM maude_monthly_summary s
            WHERE {where_sql}
            GROUP BY s.year_month, s.brand_name, s.event_type, s.report_source_code
            """,
            params,
        ).fetchall()

    canonical_severity: Dict[str, Dict[str, int]] = {}
    raw_severity: Dict[str, Dict[str, int]] = {}
    pathways_dist: Dict[str, int] = {}
    pathways_timeline_map: Dict[str, Dict[str, int]] = {}
    monthly_trend_map: Dict[str, int] = {}

    for r in rows:
        ym, raw_b, et, src, cnt = r[0], r[1], r[2], r[3] or "Unknown", r[4]
        c_brand = MEMBER_TO_CANONICAL.get(raw_b.upper().strip(), raw_b)

        if c_brand not in canonical_severity:
            canonical_severity[c_brand] = {"Death": 0, "Injury": 0, "Malfunction": 0, "Other": 0}
        canonical_severity[c_brand][et] = canonical_severity[c_brand].get(et, 0) + cnt

        if raw_b not in raw_severity:
            raw_severity[raw_b] = {"Death": 0, "Injury": 0, "Malfunction": 0, "Other": 0}
        raw_severity[raw_b][et] = raw_severity[raw_b].get(et, 0) + cnt

        pathways_dist[src] = pathways_dist.get(src, 0) + cnt

        if ym not in pathways_timeline_map:
            pathways_timeline_map[ym] = {}
        pathways_timeline_map[ym][src] = pathways_timeline_map[ym].get(src, 0) + cnt

        monthly_trend_map[ym] = monthly_trend_map.get(ym, 0) + cnt

    all_sources = sorted(pathways_dist.keys())
    pathways_timeline = []
    for ym in sorted(pathways_timeline_map.keys()):
        item: Dict[str, Any] = {"month": ym}
        for s in all_sources:
            item[s] = pathways_timeline_map[ym].get(s, 0)
        pathways_timeline.append(item)

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
