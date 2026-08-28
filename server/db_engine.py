# -*- coding: utf-8 -*-
"""High-performance Database Engine for FDA MAUDE Analysis.

Optimized with candidate-bounded FTS5 joins, pre-aggregated monthly summaries, brand groups, and user bookmarks.
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
_PRAGMA_MMAP_BYTES = 8 * 1024 ** 3  # 8GB memory mapped I/O

BRAND_GROUPS: Dict[str, List[str]] = {}
BRAND_CATEGORIES: Dict[str, str] = {}
CANONICAL_TO_MEMBERS: Dict[str, List[str]] = {}
MEMBER_TO_CANONICAL: Dict[str, str] = {}


def load_brand_groups() -> Dict[str, List[str]]:
    global BRAND_GROUPS, BRAND_CATEGORIES, CANONICAL_TO_MEMBERS, MEMBER_TO_CANONICAL
    if not BRAND_GROUPS_PATH.exists():
        return {}
    try:
        with open(BRAND_GROUPS_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
            groups = data.get("groups", {})
            cats = data.get("categories", {})
            BRAND_GROUPS = groups
            BRAND_CATEGORIES = cats
            CANONICAL_TO_MEMBERS = {k: v for k, v in groups.items()}
            MEMBER_TO_CANONICAL = {}
            for canonical, members in groups.items():
                for m in members:
                    MEMBER_TO_CANONICAL[m.strip().upper()] = canonical
            return BRAND_GROUPS
    except Exception as e:
        log.warning(f"Failed to load brand_groups.json: {e}")
        return {}


def save_brand_groups(groups: Dict[str, List[str]], categories: Optional[Dict[str, str]] = None) -> bool:
    """Saves updated brand groups and their categories to brand_groups.json."""
    global BRAND_GROUPS, BRAND_CATEGORIES, CANONICAL_TO_MEMBERS, MEMBER_TO_CANONICAL
    try:
        cats = categories if categories is not None else BRAND_CATEGORIES
        data = {
            "updated_at": datetime.now().isoformat(),
            "groups": groups,
            "categories": cats,
        }
        with open(BRAND_GROUPS_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        BRAND_GROUPS = groups
        BRAND_CATEGORIES = cats
        CANONICAL_TO_MEMBERS = {k: v for k, v in groups.items()}
        MEMBER_TO_CANONICAL = {}
        for canonical, members in groups.items():
            for m in members:
                MEMBER_TO_CANONICAL[m.strip().upper()] = canonical
        return True
    except Exception as e:
        log.error(f"Failed to save brand_groups.json: {e}")
        return False


load_brand_groups()


# ---------------------------------------------------------------------------
# Bookmarks / Tagged Folders Storage
# ---------------------------------------------------------------------------
def load_bookmarks() -> Dict[str, Any]:
    if not BOOKMARKS_PATH.exists():
        return {"bookmarks": {}, "folders": ["기본 보관함", "관심 보고서", "상해 의심 건", "센서 오작동"]}
    try:
        with open(BOOKMARKS_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {"bookmarks": {}, "folders": ["기본 보관함", "관심 보고서", "상해 의심 건", "센서 오작동"]}


def save_bookmarks_data(data: Dict[str, Any]) -> bool:
    try:
        with open(BOOKMARKS_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        log.error(f"Failed to save bookmarks: {e}")
        return False


def set_bookmark(
    report_number: str,
    folder: str = "기본 보관함",
    tags: Optional[List[str]] = None,
    note: str = "",
) -> Dict[str, Any]:
    data = load_bookmarks()
    bookmarks = data.get("bookmarks", {})
    folders = data.get("folders", [])
    
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
    save_bookmarks_data(data)
    return bookmarks[report_number]


def delete_bookmark(report_number: str) -> bool:
    data = load_bookmarks()
    bookmarks = data.get("bookmarks", {})
    if report_number in bookmarks:
        del bookmarks[report_number]
        data["bookmarks"] = bookmarks
        save_bookmarks_data(data)
        return True
    return False


def get_sqlite_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(f"{DB_PATH.as_uri()}?mode=ro&immutable=1", uri=True, timeout=30)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA busy_timeout = 30000")
    for pragma in (
        f"PRAGMA cache_size = -{_PRAGMA_CACHE_KIB}",
        f"PRAGMA mmap_size = {_PRAGMA_MMAP_BYTES}",
        "PRAGMA temp_store = MEMORY",
    ):
        try:
            conn.execute(pragma)
        except sqlite3.Error:
            pass
    return conn


def _has_fts() -> bool:
    if not DB_PATH.exists():
        return False
    try:
        with get_sqlite_conn() as conn:
            names = {r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type IN ('table','view')")}
            return {"maude_reports", "maude_reports_text", "maude_reports_fts"}.issubset(names)
    except Exception:
        return False


def _has_monthly_summary() -> bool:
    if not DB_PATH.exists():
        return False
    try:
        with get_sqlite_conn() as conn:
            names = {r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type IN ('table','view')")}
            return "maude_monthly_summary" in names
    except Exception:
        return False


HAS_FTS = _has_fts()
HAS_MONTHLY_SUMMARY = _has_monthly_summary()


def _build_filter_clauses(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    code_filter: Optional[str] = None,
    prefix: str = "r.",
    date_col: str = "date_received",
) -> Tuple[List[str], List[Any]]:
    clauses: List[str] = []
    params: List[Any] = []

    if categories:
        clean_cats = [c.strip() for c in categories if c.strip()]
        if clean_cats:
            placeholders = ",".join(["?"] * len(clean_cats))
            clauses.append(f"{prefix}device_category IN ({placeholders})")
            params.extend(clean_cats)

    if brands:
        expanded_brands: List[str] = []
        for b in brands:
            members = CANONICAL_TO_MEMBERS.get(b)
            if members:
                expanded_brands.extend(members)
            else:
                expanded_brands.append(b)
        unique_brands = list(set(expanded_brands))
        if unique_brands:
            placeholders = ",".join(["?"] * len(unique_brands))
            clauses.append(f"{prefix}brand_name IN ({placeholders})")
            params.extend(unique_brands)

    if event_types:
        clean_events = [e.strip() for e in event_types if e.strip()]
        if clean_events:
            placeholders = ",".join(["?"] * len(clean_events))
            clauses.append(f"{prefix}event_type IN ({placeholders})")
            params.extend(clean_events)

    if date_from:
        clauses.append(f"{prefix}{date_col} >= ?")
        params.append(date_from if date_col == "date_received" else date_from[:7])
    if date_to:
        clauses.append(f"{prefix}{date_col} <= ?")
        params.append(date_to if date_col == "date_received" else date_to[:7])

    if code_filter:
        cf = code_filter.strip()
        term = get_term_by_code(cf)
        if term:
            like_term = f"%{term}%"
            clauses.append(f"({prefix}patient_problems LIKE ? OR {prefix}product_problems LIKE ?)")
            params.extend([like_term, like_term])
        else:
            like_cf = f"%{cf}%"
            clauses.append(f"({prefix}patient_problems LIKE ? OR {prefix}product_problems LIKE ?)")
            params.extend([like_cf, like_cf])

    return clauses, params


def get_metadata() -> Dict[str, Any]:
    load_brand_groups()
    with get_sqlite_conn() as conn:
        if HAS_MONTHLY_SUMMARY:
            categories_rows = conn.execute(
                "SELECT DISTINCT device_category FROM maude_monthly_summary WHERE device_category IS NOT NULL"
            ).fetchall()
            categories = sorted([r[0] for r in categories_rows if r[0]])

            brands_rows = conn.execute(
                "SELECT DISTINCT brand_name FROM maude_monthly_summary WHERE brand_name IS NOT NULL ORDER BY brand_name ASC"
            ).fetchall()
            all_db_brands = [r[0] for r in brands_rows if r[0]]

            event_types_rows = conn.execute(
                "SELECT DISTINCT event_type FROM maude_monthly_summary WHERE event_type IS NOT NULL"
            ).fetchall()
            event_types = [r[0] for r in event_types_rows if r[0]]

            date_stats = conn.execute(
                "SELECT MIN(month), MAX(month) FROM maude_monthly_summary"
            ).fetchone()
            min_date = (date_stats[0] + "-01") if date_stats and date_stats[0] else "2020-01-01"
            max_date = (date_stats[1] + "-28") if date_stats and date_stats[1] else "2026-12-31"

            total_reports_row = conn.execute(
                "SELECT SUM(report_count) FROM maude_monthly_summary"
            ).fetchone()
            total_reports = total_reports_row[0] if total_reports_row and total_reports_row[0] else 3979575
        else:
            categories_rows = conn.execute(
                "SELECT DISTINCT device_category FROM maude_reports WHERE device_category IS NOT NULL"
            ).fetchall()
            categories = sorted([r[0] for r in categories_rows if r[0]])

            brands_rows = conn.execute(
                "SELECT DISTINCT brand_name FROM maude_reports WHERE brand_name IS NOT NULL LIMIT 500"
            ).fetchall()
            all_db_brands = sorted([r[0] for r in brands_rows if r[0]])
            cgm_brands = [b for b in all_db_brands if "CGM" in b]
            pump_brands = [b for b in all_db_brands if "Pump" in b]

            event_types_rows = conn.execute(
                "SELECT DISTINCT event_type FROM maude_reports WHERE event_type IS NOT NULL"
            ).fetchall()
            event_types = [r[0] for r in event_types_rows if r[0]]

            row_stats = conn.execute("SELECT MIN(date_received), MAX(date_received) FROM maude_reports").fetchone()
            min_date = row_stats[0] if row_stats else "2020-01-01"
            max_date = row_stats[1] if row_stats else "2026-12-31"

            count_row = conn.execute("SELECT max(rowid) FROM maude_reports").fetchone()
            total_reports = count_row[0] if count_row and count_row[0] else 3979575

        canonical_brands = list(BRAND_GROUPS.keys()) if BRAND_GROUPS else all_db_brands[:11]

        canonical_by_cat = {"CGM": [], "Insulin Pump": []}
        for grp in canonical_brands:
            cat = BRAND_CATEGORIES.get(grp, "CGM")
            if cat in canonical_by_cat:
                canonical_by_cat[cat].append(grp)

        result = {
            "db_path": str(DB_PATH),
            "total_reports": total_reports,
            "min_date": min_date,
            "max_date": max_date,
            "categories": ["CGM", "Insulin Pump"],
            "canonical_brands": canonical_brands,
            "canonical_brands_by_category": canonical_by_cat,
            "all_brands": all_db_brands,
            "all_brands_by_category": {
                "CGM": cgm_brands,
                "Insulin Pump": pump_brands,
            },
            "brand_groups": BRAND_GROUPS,
            "brand_categories": BRAND_CATEGORIES,
            "event_types": event_types or ["Death", "Injury", "Malfunction", "Other"],
        }
        return result


def query_reports(
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
) -> Dict[str, Any]:
    offset = max(0, (page - 1) * page_size)
    allowed_sorts = {
        "date_received", "report_number", "brand_name", "event_type",
        "manufacturer_name", "date_of_event", "device_category"
    }
    order_col = f"r.{sort_by}" if sort_by in allowed_sorts else "r.date_received"
    order_dir = "DESC" if sort_desc else "ASC"

    has_keyword = bool(keyword and keyword.strip())
    kw = keyword.strip() if has_keyword else ""

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

    with get_sqlite_conn() as conn:
        if has_keyword and HAS_FTS and len(kw) >= 3:
            from_sql = (
                "(SELECT rowid FROM maude_reports_fts WHERE maude_reports_fts MATCH ? LIMIT 2000) f "
                "JOIN maude_reports_text t ON f.rowid = t.rid "
                "JOIN maude_reports r ON r.report_number = t.report_number"
            )
            where_sql = " AND ".join(clauses) if clauses else "1=1"
            full_params = [f'"{kw}"'] + params
        elif has_keyword:
            from_sql = "maude_reports r"
            like_kw = f"%{kw}%"
            kw_clause = (
                "(r.report_number LIKE ? OR r.brand_name LIKE ? OR "
                "r.summary_complaint_kr LIKE ? OR r.summary_response_kr LIKE ? OR "
                "r.patient_problems LIKE ? OR r.product_problems LIKE ?)"
            )
            where_parts = [kw_clause] + clauses
            where_sql = " AND ".join(where_parts) if where_parts else "1=1"
            full_params = [like_kw, like_kw, like_kw, like_kw, like_kw, like_kw] + params
        else:
            from_sql = "maude_reports r"
            where_sql = " AND ".join(clauses) if clauses else "1=1"
            full_params = params

        data_sql = f"""
            SELECT r.report_number, r.mdr_report_key, r.event_type, r.date_received, r.date_of_event,
                   r.brand_name, r.device_category, r.manufacturer_name, r.patient_problems, r.product_problems,
                   r.summary_complaint_kr, r.summary_response_kr, r.summary_conclusion_kr,
                   ((t.event_description IS NOT NULL AND length(trim(t.event_description)) > 10) OR
                    (t.manufacturer_narrative IS NOT NULL AND length(trim(t.manufacturer_narrative)) > 10) OR
                    (t.additional_manufacturer_narrative IS NOT NULL AND length(trim(t.additional_manufacturer_narrative)) > 10)) AS has_real_narrative
            FROM {from_sql}
            LEFT JOIN maude_reports_text t ON t.report_number = r.report_number
            WHERE {where_sql}
            ORDER BY {order_col} {order_dir}
            LIMIT ? OFFSET ?
        """
        cursor = conn.execute(data_sql, full_params + [page_size, offset])
        rows = []
        for r in cursor.fetchall():
            row_dict = dict(r)
            has_narr = bool(row_dict.get("has_real_narrative"))
            row_dict["has_narrative"] = has_narr
            rows.append(row_dict)

        count_sql = f"SELECT count(*) FROM (SELECT 1 FROM {from_sql} WHERE {where_sql} LIMIT 2000)"
        total_count = conn.execute(count_sql, full_params).fetchone()[0]

        return {
            "total": total_count,
            "page": page,
            "page_size": page_size,
            "items": rows,
        }


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
                result.update(dict(t_row))
        except Exception:
            pass

        try:
            raw_row = conn.execute(
                "SELECT raw_json_z FROM maude_reports_raw WHERE report_number = ?",
                (report_number,),
            ).fetchone()
            if raw_row and raw_row[0]:
                decompressed = zlib.decompress(raw_row[0]).decode("utf-8")
                result["raw_json"] = json.loads(decompressed)
        except Exception:
            result["raw_json"] = None

        patient_terms = split_problem_terms(result.get("patient_problems") or "", "patient")
        device_terms = split_problem_terms(result.get("product_problems") or "", "device")

        result["patient_problem_list"] = [
            {"term": t, "code": get_patient_code(t)} for t in patient_terms
        ]
        result["product_problem_list"] = [
            {"term": t, "code": get_device_code(t)} for t in device_terms
        ]

        bdata = load_bookmarks().get("bookmarks", {})
        if report_number in bdata:
            result["bookmark"] = bdata[report_number]

        return result


def get_stats_overview(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    keyword: Optional[str] = None,
    code_filter: Optional[str] = None,
) -> Dict[str, Any]:
    load_brand_groups()
    with get_sqlite_conn() as conn:
        if HAS_MONTHLY_SUMMARY and not keyword and not code_filter:
            clauses, params = _build_filter_clauses(
                categories=categories,
                brands=brands,
                event_types=event_types,
                date_from=date_from,
                date_to=date_to,
                prefix="",
                date_col="month",
            )
            where_sql = " AND ".join(clauses) if clauses else "1=1"

            cursor = conn.execute(
                f"SELECT event_type, SUM(report_count) as cnt FROM maude_monthly_summary "
                f"WHERE {where_sql} GROUP BY event_type",
                params,
            )
            event_type_counts = {r["event_type"] or "Unknown": r["cnt"] for r in cursor.fetchall()}
            total_reports = sum(event_type_counts.values())

            # Brand counts
            cursor = conn.execute(
                f"SELECT brand_name, SUM(report_count) as cnt FROM maude_monthly_summary "
                f"WHERE {where_sql} GROUP BY brand_name",
                params,
            )
            raw_brand_counts: Dict[str, int] = {}
            canonical_brand_counts: Dict[str, int] = {}

            for r in cursor.fetchall():
                b = r["brand_name"] or "Unknown"
                cnt = r["cnt"]
                raw_brand_counts[b] = cnt

                # Map to canonical brand group
                canonical = MEMBER_TO_CANONICAL.get(b.strip().upper())
                if canonical:
                    canonical_brand_counts[canonical] = canonical_brand_counts.get(canonical, 0) + cnt

            # Top canonical groups strictly from BRAND_GROUPS filtered by active categories
            clean_cats = [c.strip() for c in (categories or []) if c.strip()]
            canonical_list = []
            for canonical in BRAND_GROUPS.keys():
                cat = BRAND_CATEGORIES.get(canonical, "CGM")
                if clean_cats and cat not in clean_cats:
                    continue
                cnt = canonical_brand_counts.get(canonical, 0)
                if brands and cnt == 0:
                    continue
                canonical_list.append({"brand": canonical, "count": cnt, "category": cat})

            top_canonical = sorted(canonical_list, key=lambda x: x["count"], reverse=True)

            # Top raw brands
            top_raw = [
                {"brand": k, "count": v}
                for k, v in sorted(raw_brand_counts.items(), key=lambda x: x[1], reverse=True)[:10]
            ]

            cursor = conn.execute(
                f"SELECT device_category, SUM(report_count) as cnt FROM maude_monthly_summary "
                f"WHERE {where_sql} GROUP BY device_category",
                params,
            )
            category_counts = {r["device_category"] or "Unknown": r["cnt"] for r in cursor.fetchall()}

            return {
                "total_reports": total_reports,
                "death_count": event_type_counts.get("Death", 0),
                "injury_count": event_type_counts.get("Injury", 0),
                "malfunction_count": event_type_counts.get("Malfunction", 0),
                "other_count": event_type_counts.get("Other", 0),
                "event_type_counts": event_type_counts,
                "top_brands": top_canonical,
                "top_canonical_brands": top_canonical,
                "top_raw_brands": top_raw,
                "category_counts": category_counts,
            }

        # Fallback direct scan
        clauses, params = _build_filter_clauses(
            categories=categories,
            brands=brands,
            event_types=event_types,
            date_from=date_from,
            date_to=date_to,
            code_filter=code_filter,
            prefix="",
        )
        where_sql = " AND ".join(clauses) if clauses else "1=1"

        cursor = conn.execute(
            f"SELECT event_type, COUNT(*) as cnt FROM maude_reports WHERE {where_sql} GROUP BY event_type",
            params,
        )
        event_type_counts = {r["event_type"] or "Unknown": r["cnt"] for r in cursor.fetchall()}
        total_reports = sum(event_type_counts.values())

        cursor = conn.execute(
            f"SELECT brand_name, COUNT(*) as cnt FROM maude_reports WHERE {where_sql} GROUP BY brand_name",
            params,
        )
        raw_brand_counts = {}
        canonical_brand_counts = {}
        for r in cursor.fetchall():
            b = r["brand_name"] or "Unknown"
            cnt = r["cnt"]
            raw_brand_counts[b] = cnt
            canonical = MEMBER_TO_CANONICAL.get(b.strip().upper())
            if canonical:
                canonical_brand_counts[canonical] = canonical_brand_counts.get(canonical, 0) + cnt

        clean_cats = [c.strip() for c in (categories or []) if c.strip()]
        canonical_list = []
        for canonical in BRAND_GROUPS.keys():
            cat = BRAND_CATEGORIES.get(canonical, "CGM")
            if clean_cats and cat not in clean_cats:
                continue
            cnt = canonical_brand_counts.get(canonical, 0)
            if brands and cnt == 0:
                continue
            canonical_list.append({"brand": canonical, "count": cnt, "category": cat})

        top_canonical = sorted(canonical_list, key=lambda x: x["count"], reverse=True)
        top_raw = [
            {"brand": k, "count": v}
            for k, v in sorted(raw_brand_counts.items(), key=lambda x: x[1], reverse=True)[:10]
        ]

        cursor = conn.execute(
            f"SELECT device_category, COUNT(*) as cnt FROM maude_reports WHERE {where_sql} GROUP BY device_category",
            params,
        )
        category_counts = {r["device_category"] or "Unknown": r["cnt"] for r in cursor.fetchall()}

        return {
            "total_reports": total_reports,
            "death_count": event_type_counts.get("Death", 0),
            "injury_count": event_type_counts.get("Injury", 0),
            "malfunction_count": event_type_counts.get("Malfunction", 0),
            "other_count": event_type_counts.get("Other", 0),
            "event_type_counts": event_type_counts,
            "top_brands": top_canonical,
            "top_canonical_brands": top_canonical,
            "top_raw_brands": top_raw,
            "category_counts": category_counts,
        }


def get_stats_monthly(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    keyword: Optional[str] = None,
    code_filter: Optional[str] = None,
) -> List[Dict[str, Any]]:
    load_brand_groups()
    with get_sqlite_conn() as conn:
        if HAS_MONTHLY_SUMMARY and not keyword and not code_filter:
            clauses, params = _build_filter_clauses(
                categories=categories,
                brands=brands,
                event_types=event_types,
                date_from=date_from,
                date_to=date_to,
                prefix="",
                date_col="month",
            )
            where_sql = " AND ".join(clauses) if clauses else "1=1"
            sql = f"""
                SELECT month, brand_name, event_type, SUM(report_count) AS count
                FROM maude_monthly_summary
                WHERE {where_sql}
                GROUP BY month, brand_name, event_type
                ORDER BY month ASC
            """
            cursor = conn.execute(sql, params)
            rows = []
            for r in cursor.fetchall():
                b = r["brand_name"] or "Unknown"
                canonical = MEMBER_TO_CANONICAL.get(b.strip().upper(), b)
                rows.append({
                    "month": r["month"],
                    "brand_name": canonical,
                    "raw_brand_name": b,
                    "event_type": r["event_type"],
                    "count": r["count"],
                })
            return rows

        clauses, params = _build_filter_clauses(
            categories=categories,
            brands=brands,
            event_types=event_types,
            date_from=date_from,
            date_to=date_to,
            code_filter=code_filter,
            prefix="",
        )
        where_sql = " AND ".join(clauses) if clauses else "1=1"

        sql = f"""
            SELECT SUBSTR(date_received, 1, 7) AS month, brand_name, event_type, COUNT(*) AS count
            FROM maude_reports
            WHERE {where_sql} AND date_received IS NOT NULL
            GROUP BY month, brand_name, event_type
            ORDER BY month ASC
        """
        cursor = conn.execute(sql, params)
        rows = []
        for r in cursor.fetchall():
            b = r["brand_name"] or "Unknown"
            canonical = MEMBER_TO_CANONICAL.get(b.strip().upper(), b)
            rows.append({
                "month": r["month"],
                "brand_name": canonical,
                "raw_brand_name": b,
                "event_type": r["event_type"],
                "count": r["count"],
            })
        return rows


def get_problem_codes_stats(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    event_types: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    keyword: Optional[str] = None,
    code_filter: Optional[str] = None,
    limit: int = 15,
) -> Dict[str, Any]:
    clauses, params = _build_filter_clauses(
        categories=categories,
        brands=brands,
        event_types=event_types,
        date_from=date_from,
        date_to=date_to,
        code_filter=code_filter,
        prefix="",
    )
    where_sql = " AND ".join(clauses) if clauses else "1=1"

    with get_sqlite_conn() as conn:
        sql = f"""
            SELECT patient_problems, product_problems, brand_name
            FROM maude_reports
            WHERE {where_sql} AND (patient_problems IS NOT NULL OR product_problems IS NOT NULL)
            LIMIT 5000
        """
        cursor = conn.execute(sql, params)

        patient_counter: Dict[str, int] = {}
        device_counter: Dict[str, int] = {}
        patient_by_brand: Dict[str, Dict[str, int]] = {}
        device_by_brand: Dict[str, Dict[str, int]] = {}

        for row in cursor.fetchall():
            bname = row["brand_name"] or "Unknown"
            canonical = MEMBER_TO_CANONICAL.get(bname.strip().upper(), bname)

            if row["patient_problems"]:
                for term in split_problem_terms(row["patient_problems"], "patient"):
                    patient_counter[term] = patient_counter.get(term, 0) + 1
                    if term not in patient_by_brand:
                        patient_by_brand[term] = {}
                    patient_by_brand[term][canonical] = patient_by_brand[term].get(canonical, 0) + 1

            if row["product_problems"]:
                for term in split_problem_terms(row["product_problems"], "device"):
                    device_counter[term] = device_counter.get(term, 0) + 1
                    if term not in device_by_brand:
                        device_by_brand[term] = {}
                    device_by_brand[term][canonical] = device_by_brand[term].get(canonical, 0) + 1

        top_patient = sorted(patient_counter.items(), key=lambda x: x[1], reverse=True)[:limit]
        top_device = sorted(device_counter.items(), key=lambda x: x[1], reverse=True)[:limit]

        return {
            "patient_problems": [
                {
                    "term": term,
                    "code": get_patient_code(term) or "-",
                    "count": count,
                    "brand_breakdown": patient_by_brand.get(term, {}),
                }
                for term, count in top_patient
            ],
            "product_problems": [
                {
                    "term": term,
                    "code": get_device_code(term) or "-",
                    "count": count,
                    "brand_breakdown": device_by_brand.get(term, {}),
                }
                for term, count in top_device
            ],
        }


def _classify_pathway(report_source_code: Optional[str], source_type: Optional[str], country: Optional[str]) -> str:
    rsc = (report_source_code or "").upper()
    st = (source_type or "").upper()
    cntry = (country or "").upper()

    if "FOREIGN" in st or (cntry and cntry not in ("US", "USA", "UNITED STATES")):
        return "Foreign (해외 보고)"
    if "VOLUNTARY" in rsc or "USER FACILITY" in rsc or "USER FACILITY" in st or "HEALTH PROFESSIONAL" in st:
        return "MedWatch (자발적 보고)"
    if "DISTRIBUTOR" in rsc or "DISTRIBUTOR" in st:
        return "Distributor (유통/수입사)"
    if "MANUFACTURER" in rsc or "CONSUMER" in st or "COMPANY REPRESENTATIVE" in st:
        return "MDR (제조사 의무보고)"
    if "LITERATURE" in st or "STUDY" in st or "OTHER" in st:
        return "Other/Literature (문헌/기타)"
    return "MDR (제조사 의무보고)"


def get_insights_data(
    categories: Optional[List[str]] = None,
    brands: Optional[List[str]] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
) -> Dict[str, Any]:
    load_brand_groups()
    with get_sqlite_conn() as conn:
        clauses, params = _build_filter_clauses(
            categories=categories,
            brands=brands,
            date_from=date_from,
            date_to=date_to,
            prefix="",
            date_col="month" if HAS_MONTHLY_SUMMARY else "date_received",
        )
        where_sql = " AND ".join(clauses) if clauses else "1=1"

        raw_severity: Dict[str, Dict[str, int]] = {}
        canonical_severity: Dict[str, Dict[str, int]] = {}

        if HAS_MONTHLY_SUMMARY:
            cursor = conn.execute(
                f"SELECT brand_name, event_type, SUM(report_count) as count FROM maude_monthly_summary "
                f"WHERE {where_sql} GROUP BY brand_name, event_type",
                params,
            )
        else:
            cursor = conn.execute(
                f"SELECT brand_name, event_type, count(*) as count FROM maude_reports "
                f"WHERE {where_sql} GROUP BY brand_name, event_type",
                params,
            )

        clean_cats = [c.strip() for c in (categories or []) if c.strip()]

        for r in cursor.fetchall():
            b = r["brand_name"] or "Unknown"
            et = r["event_type"] or "Unknown"
            cnt = r["count"]

            if b not in raw_severity:
                raw_severity[b] = {}
            raw_severity[b][et] = cnt

            canonical = MEMBER_TO_CANONICAL.get(b.strip().upper())
            if canonical:
                cat = BRAND_CATEGORIES.get(canonical, "CGM")
                if clean_cats and cat not in clean_cats:
                    continue
                if canonical not in canonical_severity:
                    canonical_severity[canonical] = {}
                canonical_severity[canonical][et] = canonical_severity[canonical].get(et, 0) + cnt

        clauses_full, params_full = _build_filter_clauses(
            categories=categories,
            brands=brands,
            date_from=date_from,
            date_to=date_to,
            prefix="",
        )
        where_full = " AND ".join(clauses_full) if clauses_full else "1=1"

        pathway_cursor = conn.execute(
            f"""
            SELECT report_source_code, source_type, manufacturer_country, SUBSTR(date_received, 1, 7) as month, count(*) as count
            FROM (
                SELECT report_source_code, source_type, manufacturer_country, date_received
                FROM maude_reports
                WHERE {where_full} AND date_received IS NOT NULL
                LIMIT 15000
            )
            GROUP BY report_source_code, source_type, manufacturer_country, month
            """,
            params_full,
        )

        pathways_dist: Dict[str, int] = {}
        pathways_monthly: Dict[str, Dict[str, int]] = {}

        for r in pathway_cursor.fetchall():
            pathway = _classify_pathway(r["report_source_code"], r["source_type"], r["manufacturer_country"])
            cnt = r["count"]
            m = r["month"] or "Unknown"

            pathways_dist[pathway] = pathways_dist.get(pathway, 0) + cnt

            if m not in pathways_monthly:
                pathways_monthly[m] = {}
            pathways_monthly[m][pathway] = pathways_monthly[m].get(pathway, 0) + cnt

        pathway_timeline = [
            {"month": m, **counts}
            for m, counts in sorted(pathways_monthly.items(), key=lambda x: x[0])
            if len(m) == 7 and m >= "2020-01"
        ]

        if HAS_MONTHLY_SUMMARY:
            cursor = conn.execute(
                f"SELECT month, SUM(report_count) as count FROM maude_monthly_summary "
                f"WHERE {where_sql} GROUP BY month ORDER BY month DESC LIMIT 12",
                params,
            )
        else:
            cursor = conn.execute(
                f"SELECT SUBSTR(date_received, 1, 7) as month, count(*) as count FROM maude_reports "
                f"WHERE {where_sql} AND date_received IS NOT NULL GROUP BY month ORDER BY month DESC LIMIT 12",
                params,
            )
        month_trend = [dict(r) for r in cursor.fetchall()]

        return {
            "canonical_severity": canonical_severity,
            "raw_severity": raw_severity,
            "pathways_distribution": pathways_dist,
            "pathways_timeline": pathway_timeline,
            "recent_month_trend": month_trend,
        }
