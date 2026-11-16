# -*- coding: utf-8 -*-
"""FastAPI Backend Server for FDA MAUDE Intelligence Platform."""
from __future__ import annotations

import os
import sys
import threading
import webbrowser
from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from server import ai_hazard_service
from server import db_engine as engine
from server import hazard_db

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


class HazardGeneratePayload(BaseModel):
    report_number: str
    force_refresh: bool = False


class HazardBatchGeneratePayload(BaseModel):
    report_numbers: List[str]
    force_refresh: bool = False


class HazardReviewPayload(BaseModel):
    workflow_status: Optional[str] = None
    adoption_decision: Optional[str] = None
    adoption_reason: Optional[str] = None
    future_aid_risk: Optional[str] = None
    decision_reason: Optional[str] = None
    use_mode: Optional[str] = None
    ppt_include: Optional[str] = None
    ppt_id: Optional[str] = None
    reviewer_name: Optional[str] = None
    review_note: Optional[str] = None
    internal_tags: Optional[str] = None
    manual_overrides: Optional[Dict[str, Any]] = None
    client_updated_at: Optional[str] = None


class HazardFinalizePayload(BaseModel):
    version_tag: str
    finalized_by: str = "위험관리 책임자"
    summary_notes: str = ""


class HazardCandidatePayload(BaseModel):
    report_number: str
    brand_name: str = ""
    device_category: str = "CGM"
    event_type: str = ""
    date_received: str = ""
    note: str = ""


class HazardBatchReviewPayload(BaseModel):
    report_numbers: List[str]
    workflow_status: str
    reviewer_name: str = ""
    review_note: str = ""
    internal_tags: str = ""


class ReportHazardStatusPayload(BaseModel):
    report_numbers: List[str]


class TranslatePayload(BaseModel):
    text: str
    target_lang: str = "ko"


class TranslateBatchPayload(BaseModel):
    texts: List[str]
    target_lang: str = "ko"


_TRANSLATION_CACHE: Dict[str, str] = {}


def _gemini_translate_fallback(text: str) -> Optional[str]:
    """Fallback translation using Google Gemini Flash API if GTX is unavailable."""
    try:
        import requests
        from server.ai_hazard_service import load_gemini_api_key
        api_key = load_gemini_api_key()
        if not api_key:
            return None
        prompt = f"Translate the following medical device adverse event report excerpt to Korean. Output ONLY the Korean translation without quotes or notes:\n\n{text[:3000]}"
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent?key={api_key}"
        resp = requests.post(url, json={"contents": [{"parts": [{"text": prompt}]}]}, timeout=12)
        if resp.status_code == 200:
            return resp.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
    except Exception:
        pass
    return None


def _do_translate(text: str, target_lang: str = "ko") -> str:
    cleaned = (text or "").strip()
    if not cleaned:
        return ""
    if cleaned in _TRANSLATION_CACHE:
        return _TRANSLATION_CACHE[cleaned]

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        "Accept": "*/*",
    }

    try:
        import requests
        url = "https://translate.googleapis.com/translate_a/single"
        # Split into chunks if text is exceptionally long
        chunks = [cleaned[i:i + 2000] for i in range(0, len(cleaned), 2000)]
        results = []
        for chunk in chunks:
            params = {
                "client": "gtx",
                "sl": "auto",
                "tl": target_lang,
                "dt": "t",
                "q": chunk,
            }
            resp = requests.get(url, params=params, headers=headers, timeout=8)
            if resp.status_code == 200:
                data = resp.json()
                translated_chunk = "".join([part[0] for part in data[0] if part[0]])
                results.append(translated_chunk)
            else:
                fb = _gemini_translate_fallback(chunk)
                results.append(fb if fb else chunk)

        translated = "\n".join(results)
        if len(_TRANSLATION_CACHE) > 5000:
            _TRANSLATION_CACHE.clear()
        _TRANSLATION_CACHE[cleaned] = translated
        return translated
    except Exception as e:
        fb = _gemini_translate_fallback(cleaned)
        if fb:
            _TRANSLATION_CACHE[cleaned] = fb
            return fb
        return f"[번역 실패: {e}] {cleaned}"


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
# Real-Time Korean Translation Endpoints
# ---------------------------------------------------------------------------
@app.post("/api/translate")
def translate_single(payload: TranslatePayload) -> Dict[str, Any]:
    """Translates a single English narrative text to Korean."""
    translated = _do_translate(payload.text, payload.target_lang)
    return {"translated_text": translated}


@app.post("/api/translate/batch")
def translate_batch(payload: TranslateBatchPayload) -> Dict[str, Any]:
    """Batch translates multiple English texts to Korean."""
    translations = [_do_translate(t, payload.target_lang) for t in payload.texts]
    return {"translations": translations}


# ---------------------------------------------------------------------------
# ISO 14971 Hazard Intelligence & Review Workflow Endpoints
# ---------------------------------------------------------------------------
@app.get("/api/hazards")
def get_hazards_list(
    confirmed_only: bool = False,
    adoption_decision: Optional[str] = None,
    hazard_category: Optional[str] = None,
    risk_level: Optional[str] = None,
    use_mode: Optional[str] = None,
    ppt_include: Optional[str] = None,
    min_aid_score: Optional[int] = None,
    brand_name: Optional[str] = None,
    workflow_status: Optional[str] = None,
    keyword: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: Optional[int] = Query(50, ge=1, le=500),
) -> Dict[str, Any]:
    filters = {
        "adoption_decision": adoption_decision,
        "hazard_category": hazard_category,
        "risk_level": risk_level,
        "use_mode": use_mode,
        "ppt_include": ppt_include,
        "min_aid_score": min_aid_score,
        "brand_name": brand_name,
        "workflow_status": workflow_status,
        "keyword": keyword,
    }
    result = hazard_db.get_hazards(filters, confirmed_only=confirmed_only, page=page, page_size=page_size)
    return {"total": result["total"], "page": result["page"], "page_size": result["page_size"], "hazards": result["items"]}


@app.get("/api/confirmed-hazards")
def get_confirmed_hazards_list(
    hazard_category: Optional[str] = None,
    risk_level: Optional[str] = None,
    min_aid_score: Optional[int] = None,
    keyword: Optional[str] = None,
) -> Dict[str, Any]:
    filters = {
        "hazard_category": hazard_category,
        "risk_level": risk_level,
        "min_aid_score": min_aid_score,
        "keyword": keyword,
    }
    items = hazard_db.get_confirmed_hazards(filters)
    return {"total": len(items), "hazards": items}


@app.post("/api/hazards/generate")
def generate_hazard(payload: HazardGeneratePayload) -> Dict[str, Any]:
    result = ai_hazard_service.generate_hazard_for_report(payload.report_number, force_refresh=payload.force_refresh)
    return result


@app.post("/api/hazards/generate-batch")
def generate_hazards_batch(payload: HazardBatchGeneratePayload) -> Dict[str, Any]:
    result = ai_hazard_service.generate_hazards_batch(payload.report_numbers, force_refresh=payload.force_refresh)
    return result


@app.post("/api/hazards/{hazard_row_id}/review")
def review_hazard(hazard_row_id: str, payload: HazardReviewPayload) -> Dict[str, Any]:
    try:
        return hazard_db.save_hazard_review(
            hazard_row_id=hazard_row_id,
            workflow_status=payload.workflow_status,
            adoption_decision=payload.adoption_decision,
            adoption_reason=payload.adoption_reason,
            future_aid_risk=payload.future_aid_risk,
            decision_reason=payload.decision_reason,
            use_mode=payload.use_mode,
            ppt_include=payload.ppt_include,
            ppt_id=payload.ppt_id,
            reviewer_name=payload.reviewer_name,
            review_note=payload.review_note,
            internal_tags=payload.internal_tags,
            manual_overrides=payload.manual_overrides,
            client_updated_at=payload.client_updated_at,
        )
    except ValueError as e:
        err_msg = str(e)
        if "먼저 수정" in err_msg:
            raise HTTPException(status_code=409, detail=err_msg)
        raise HTTPException(status_code=400, detail=err_msg)
    except KeyError as e:
        raise HTTPException(status_code=404, detail=str(e))


@app.post("/api/hazards/batch-review")
def review_hazard_batch(payload: HazardBatchReviewPayload) -> Dict[str, Any]:
    updated_count = hazard_db.save_hazard_review_batch(
        report_numbers=payload.report_numbers,
        workflow_status=payload.workflow_status,
        reviewer_name=payload.reviewer_name,
        review_note=payload.review_note,
        internal_tags=payload.internal_tags,
    )
    return {"success": True, "updated_count": updated_count}


@app.delete("/api/hazards/{hazard_row_id}")
def delete_hazard(hazard_row_id: str) -> Dict[str, Any]:
    """Deletes an unreviewed hazard row by hazard_row_id. Rejects if adopted."""
    try:
        success = hazard_db.delete_hazard(hazard_row_id)
        if not success:
            raise HTTPException(status_code=404, detail="Hazard not found")
        return {"success": True, "deleted_id": hazard_row_id}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/reports/hazard-status")
def reports_hazard_status(payload: ReportHazardStatusPayload) -> Dict[str, Dict[str, Any]]:
    return hazard_db.get_reports_hazard_status(payload.report_numbers)


@app.post("/api/hazards/finalize")
def finalize_hazard_version(payload: HazardFinalizePayload) -> Dict[str, Any]:
    try:
        return hazard_db.finalize_hazard_version(
            version_tag=payload.version_tag,
            finalized_by=payload.finalized_by,
            summary_notes=payload.summary_notes,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/hazards/versions")
def get_hazard_versions() -> List[Dict[str, Any]]:
    return hazard_db.get_hazard_versions()


@app.get("/api/hazards/changes")
def get_hazard_changes(hazard_row_id: Optional[str] = None) -> List[Dict[str, Any]]:
    return hazard_db.get_hazard_change_logs(hazard_row_id)


@app.post("/api/hazards/candidates")
def add_hazard_candidate(payload: HazardCandidatePayload) -> Dict[str, Any]:
    success = hazard_db.add_hazard_candidate(
        report_number=payload.report_number,
        brand_name=payload.brand_name,
        device_category=payload.device_category,
        event_type=payload.event_type,
        date_received=payload.date_received,
        note=payload.note,
    )
    return {"success": success, "report_number": payload.report_number}


@app.get("/api/hazards/candidates")
def list_hazard_candidates() -> List[Dict[str, Any]]:
    return hazard_db.get_hazard_candidates()


@app.delete("/api/hazards/candidates/{report_number}")
def remove_hazard_candidate(report_number: str) -> Dict[str, Any]:
    success = hazard_db.delete_hazard_candidate(report_number)
    return {"success": success, "report_number": report_number}


@app.get("/api/hazards/export-excel")
def export_hazards_excel(
    export_type: str = Query("final", pattern="^(final|operations)$"),
    confirmed_only: bool = False,
    hazard_category: Optional[str] = None,
    risk_level: Optional[str] = None,
    min_aid_score: Optional[int] = None,
    workflow_status: Optional[str] = None,
    keyword: Optional[str] = None,
):
    import io
    from urllib.parse import quote
    filters = {
        "hazard_category": hazard_category,
        "risk_level": risk_level,
        "min_aid_score": min_aid_score,
        "workflow_status": workflow_status,
        "keyword": keyword,
    }
    excel_bytes, filename = hazard_db.export_hazards_to_excel(
        filters, export_type=export_type, confirmed_only=confirmed_only
    )
    encoded_filename = quote(filename)

    return StreamingResponse(
        io.BytesIO(excel_bytes),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={
            "Content-Disposition": f"attachment; filename*=UTF-8''{encoded_filename}",
        },
    )


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
        return FileResponse(
            str(FRONTEND_DIST / "index.html"),
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Pragma": "no-cache",
                "Expires": "0",
            },
        )


# ---------------------------------------------------------------------------
# Auto Open Browser on Startup
# ---------------------------------------------------------------------------
@app.on_event("startup")
def on_startup():
    def _open():
        import socket
        import time

        # Wait until port 8000 is actively accepting connections
        for _ in range(50):
            try:
                with socket.create_connection(("127.0.0.1", 8000), timeout=0.2):
                    break
            except OSError:
                time.sleep(0.1)

        webbrowser.open("http://localhost:8000")

    if not os.environ.get("NO_BROWSER"):
        threading.Thread(target=_open, daemon=True).start()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server.main:app", host="0.0.0.0", port=8000, reload=False, workers=1)
