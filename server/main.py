# -*- coding: utf-8 -*-
"""FastAPI Backend Server for FDA MAUDE Intelligence Platform."""
from __future__ import annotations

import os
import sys
import threading
import webbrowser
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from server import db_engine as engine

app = FastAPI(
    title="FDA MAUDE CGM Intelligence API",
    version="2.1.0",
    description="High-Performance Analysis Backend for Continuous Glucose Monitors & Insulin Pumps Adverse Event Reports",
)

# Enable CORS for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Request/Response Schemas
# ---------------------------------------------------------------------------
class FilterPayload(BaseModel):
    categories: Optional[List[str]] = None
    brands: Optional[List[str]] = None
    event_types: Optional[List[str]] = None
    date_from: Optional[str] = None
    date_to: Optional[str] = None
    keyword: Optional[str] = None
    code_filter: Optional[str] = None
    report_numbers: Optional[List[str]] = None


class BrandGroupsPayload(BaseModel):
    groups: Dict[str, List[str]]
    categories: Optional[Dict[str, str]] = None


class BookmarkPayload(BaseModel):
    report_number: str
    folder: str = "기본 보관함"
    tags: Optional[List[str]] = None
    note: str = ""


class SyncRequestPayload(BaseModel):
    mode: str = "incremental"
    date_from: Optional[str] = None
    date_to: Optional[str] = None
    categories: Optional[List[str]] = None


# ---------------------------------------------------------------------------
# Sync Engine Endpoints
# ---------------------------------------------------------------------------
from server import sync_engine
import asyncio

@app.get("/api/sync/status")
def get_sync_status() -> Dict[str, Any]:
    """Returns the current real-time OpenFDA synchronization state and progress logs."""
    return sync_engine.get_sync_status()


@app.post("/api/sync/start")
async def start_sync(payload: SyncRequestPayload) -> Dict[str, Any]:
    """Triggers an asynchronous OpenFDA incremental or custom date range synchronization."""
    if sync_engine.SYNC_STATE["is_running"]:
        return {"status": "already_running", "message": "이미 동기화 작업이 진행 중입니다."}

    asyncio.create_task(
        sync_engine.run_incremental_sync(
            date_from=payload.date_from,
            date_to=payload.date_to,
            categories=payload.categories,
            mode=payload.mode,
        )
    )
    return {"status": "started", "message": "OpenFDA 동기화가 백그라운드에서 시작되었습니다."}


# ---------------------------------------------------------------------------
# Metadata & Filter Discovery Endpoints
# ---------------------------------------------------------------------------
@app.get("/api/metadata")
def get_metadata() -> Dict[str, Any]:
    """Returns dynamic filter options, brands, categories, and date boundaries."""
    return engine.get_metadata()


@app.get("/api/brand-groups")
def get_brand_groups() -> Dict[str, Any]:
    """Returns the brand groups and list of all brands."""
    meta = engine.get_metadata()
    return {
        "groups": meta.get("brand_groups", {}),
        "categories": meta.get("brand_categories", {}),
        "all_brands": meta.get("all_brands", []),
    }


@app.post("/api/brand-groups")
def update_brand_groups(payload: BrandGroupsPayload) -> Dict[str, Any]:
    """Saves updated brand groups and categories."""
    success = engine.save_brand_groups(payload.groups, payload.categories)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to save brand groups")
    return {"status": "ok", "groups": payload.groups, "categories": payload.categories}


# ---------------------------------------------------------------------------
# Bookmarks & Folder Management Endpoints
# ---------------------------------------------------------------------------
@app.get("/api/bookmarks")
def get_bookmarks() -> Dict[str, Any]:
    """Returns all user bookmarks and folders."""
    return engine.load_bookmarks()


@app.post("/api/bookmarks")
def save_bookmark(payload: BookmarkPayload) -> Dict[str, Any]:
    """Saves or updates a bookmark with folder, tags, and notes."""
    result = engine.set_bookmark(
        report_number=payload.report_number,
        folder=payload.folder,
        tags=payload.tags,
        note=payload.note,
    )
    return {"status": "ok", "bookmark": result}


@app.delete("/api/bookmarks/{report_number}")
def delete_bookmark(report_number: str) -> Dict[str, Any]:
    """Deletes a bookmark."""
    deleted = engine.delete_bookmark(report_number)
    return {"status": "ok" if deleted else "not_found"}


@app.post("/api/bookmarks/reports")
def get_bookmarked_reports(
    folder: Optional[str] = None,
    tag: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=500),
) -> Dict[str, Any]:
    """Fetches report list for all bookmarked reports, optionally filtered by folder or tag."""
    bdata = engine.load_bookmarks()
    bookmarks = bdata.get("bookmarks", {})
    
    filtered_rep_nums = []
    for rnum, item in bookmarks.items():
        if folder and item.get("folder") != folder:
            continue
        if tag and tag not in item.get("tags", []):
            continue
        filtered_rep_nums.append(rnum)

    if not filtered_rep_nums:
        return {"total": 0, "page": page, "page_size": page_size, "items": [], "bookmarks": bookmarks}

    res = engine.query_reports(
        report_numbers=filtered_rep_nums,
        page=page,
        page_size=page_size,
    )
    res["bookmarks"] = bookmarks
    return res


# ---------------------------------------------------------------------------
# Fast Summary & Statistics Endpoints
# ---------------------------------------------------------------------------
@app.post("/api/stats/overview")
def get_stats_overview(payload: FilterPayload) -> Dict[str, Any]:
    """High-speed KPI counts and overview distributions."""
    return engine.get_stats_overview(
        categories=payload.categories,
        brands=payload.brands,
        event_types=payload.event_types,
        date_from=payload.date_from,
        date_to=payload.date_to,
        keyword=payload.keyword,
        code_filter=payload.code_filter,
    )


@app.post("/api/stats/monthly")
def get_stats_monthly(payload: FilterPayload) -> List[Dict[str, Any]]:
    """Monthly timeline aggregation by brand and event type."""
    return engine.get_stats_monthly(
        categories=payload.categories,
        brands=payload.brands,
        event_types=payload.event_types,
        date_from=payload.date_from,
        date_to=payload.date_to,
        keyword=payload.keyword,
        code_filter=payload.code_filter,
    )


@app.post("/api/stats/problem-codes")
def get_problem_codes_stats(
    payload: FilterPayload,
    limit: int = Query(20, ge=5, le=100),
) -> Dict[str, Any]:
    """Top Patient and Device problem terms with FDA Annex code mapping."""
    return engine.get_problem_codes_stats(
        categories=payload.categories,
        brands=payload.brands,
        event_types=payload.event_types,
        date_from=payload.date_from,
        date_to=payload.date_to,
        keyword=payload.keyword,
        code_filter=payload.code_filter,
        limit=limit,
    )


@app.post("/api/insights")
@app.post("/api/stats/insights")
def get_insights_data(payload: FilterPayload) -> Dict[str, Any]:
    """Deep Safety Insights: severity matrices, reporting pathways, and anomaly trends."""
    return engine.get_insights(
        categories=payload.categories,
        brands=payload.brands,
        event_types=payload.event_types,
        date_from=payload.date_from,
        date_to=payload.date_to,
        keyword=payload.keyword,
        code_filter=payload.code_filter,
    )


# ---------------------------------------------------------------------------
# Report Query & Detail Endpoints
# ---------------------------------------------------------------------------
@app.post("/api/reports")
def query_reports(
    payload: FilterPayload,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=10, le=500),
    sort_by: str = Query("date_received"),
    sort_desc: bool = Query(True),
) -> Dict[str, Any]:
    """Paginated report search with bounded FTS5 matching."""
    return engine.query_reports(
        categories=payload.categories,
        brands=payload.brands,
        event_types=payload.event_types,
        date_from=payload.date_from,
        date_to=payload.date_to,
        keyword=payload.keyword,
        code_filter=payload.code_filter,
        report_numbers=payload.report_numbers,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_desc=sort_desc,
    )


@app.get("/api/reports/{report_number}")
def get_report_detail(report_number: str) -> Dict[str, Any]:
    """Full detail of a single MDR report including narratives, problem codes, and raw JSON."""
    report = engine.get_report_detail(report_number)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report


# ---------------------------------------------------------------------------
# Single-Page Application (SPA) Static Files Serving
# ---------------------------------------------------------------------------
FRONTEND_DIST = engine.BASE_DIR / "frontend" / "dist"

if FRONTEND_DIST.exists():
    app.mount("/assets", StaticFiles(directory=str(FRONTEND_DIST / "assets")), name="static_assets")

    @app.get("/{full_path:path}")
    async def serve_spa(full_path: str):
        file_path = FRONTEND_DIST / full_path
        if file_path.exists() and file_path.is_file():
            return FileResponse(str(file_path))
        return FileResponse(str(FRONTEND_DIST / "index.html"))


# ---------------------------------------------------------------------------
# Auto Open Browser on Startup
# ---------------------------------------------------------------------------
@app.on_event("startup")
def on_startup():
    def _open():
        import time
        time.sleep(1.2)
        webbrowser.open("http://localhost:8000")

    if not os.environ.get("NO_BROWSER"):
        threading.Thread(target=_open, daemon=True).start()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server.main:app", host="0.0.0.0", port=8000, reload=False, workers=1)
