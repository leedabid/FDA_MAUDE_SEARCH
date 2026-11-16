import axios from "axios";
import type {
  FilterState,
  Metadata,
  OverviewStats,
  ReportDetail,
  ReportItem,
  ProblemCodeItem,
  MonthlyDataPoint,
  InsightsData,
  BookmarksData,
  BookmarkItem,
  HazardItem,
  HazardReviewPayload,
  HazardBatchReviewPayload,
  ReportHazardStatus,
  HazardVersion,
  HazardCandidate,
} from "../types";

const API_BASE_URL = import.meta.env.VITE_API_URL || "/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 30000,
});

export const getMetadata = async (): Promise<Metadata> => {
  const res = await api.get<Metadata>("/metadata");
  return res.data;
};

export const getBrandGroups = async (): Promise<{
  groups: Record<string, string[]>;
  categories?: Record<string, string>;
  all_brands: string[];
}> => {
  const res = await api.get<{
    groups: Record<string, string[]>;
    categories?: Record<string, string>;
    all_brands: string[];
  }>("/brand-groups");
  return res.data;
};

export const updateBrandGroups = async (
  groups: Record<string, string[]>,
  categories?: Record<string, string>
): Promise<void> => {
  await api.post("/brand-groups", { groups, categories });
};

export const getBookmarks = async (): Promise<BookmarksData> => {
  const res = await api.get<BookmarksData>("/bookmarks");
  return res.data;
};

export const saveBookmark = async (
  reportNumber: string,
  folder: string,
  tags: string[],
  note: string
): Promise<{ status: string; bookmark: BookmarkItem }> => {
  const res = await api.post<{ status: string; bookmark: BookmarkItem }>("/bookmarks", {
    report_number: reportNumber,
    folder,
    tags,
    note,
  });
  return res.data;
};

export const deleteBookmark = async (reportNumber: string): Promise<void> => {
  await api.delete(`/bookmarks/${encodeURIComponent(reportNumber)}`);
};

export const getBookmarkedReports = async (
  folder?: string,
  tag?: string,
  page: number = 1,
  pageSize: number = 50
): Promise<{ total: number; page: number; page_size: number; items: ReportItem[]; bookmarks: Record<string, BookmarkItem> }> => {
  const params = new URLSearchParams();
  if (folder) params.append("folder", folder);
  if (tag) params.append("tag", tag);
  params.append("page", String(page));
  params.append("page_size", String(pageSize));

  const res = await api.post<{
    total: number;
    page: number;
    page_size: number;
    items: ReportItem[];
    bookmarks: Record<string, BookmarkItem>;
  }>(`/bookmarks/reports?${params.toString()}`);
  return res.data;
};

export const getOverviewStats = async (filters: FilterState): Promise<OverviewStats> => {
  const res = await api.post<OverviewStats>("/stats/overview", filters);
  return res.data;
};

export const getMonthlyStats = async (filters: FilterState): Promise<MonthlyDataPoint[]> => {
  const res = await api.post<MonthlyDataPoint[]>("/stats/monthly", filters);
  return res.data;
};

export const getProblemCodes = async (
  filters: FilterState,
  limit: number = 20
): Promise<{ patient_problems: ProblemCodeItem[]; product_problems: ProblemCodeItem[] }> => {
  const res = await api.post<{ patient_problems: ProblemCodeItem[]; product_problems: ProblemCodeItem[] }>(
    `/stats/problem-codes?limit=${limit}`,
    filters
  );
  return res.data;
};

export const queryReports = async (
  filters: FilterState,
  page: number = 1,
  pageSize: number = 50,
  sortBy: string = "date_received",
  sortDesc: boolean = true
): Promise<{ total: number; page: number; page_size: number; items: ReportItem[] }> => {
  const res = await api.post<{ total: number; page: number; page_size: number; items: ReportItem[] }>(
    `/reports?page=${page}&page_size=${pageSize}&sort_by=${sortBy}&sort_desc=${sortDesc}`,
    filters
  );
  return res.data;
};

export const getReportDetail = async (reportNumber: string): Promise<ReportDetail> => {
  const res = await api.get<ReportDetail>(`/reports/${encodeURIComponent(reportNumber)}`);
  return res.data;
};

export const translateText = async (text: string): Promise<string> => {
  const res = await api.post<{ translated_text: string }>("/translate", { text });
  return res.data.translated_text;
};

export const translateBatch = async (texts: string[]): Promise<string[]> => {
  const res = await api.post<{ translations: string[] }>("/translate/batch", { texts });
  return res.data.translations;
};

export const getInsights = async (filters: FilterState): Promise<InsightsData> => {
  const res = await api.post<InsightsData>("/insights", filters);
  return res.data;
};

export interface SyncStatusResponse {
  is_running: boolean;
  current_step: string;
  total_target: number;
  processed_count: number;
  inserted_count: number;
  start_time: number | null;
  error: string | null;
  logs: string[];
}

export const getSyncStatus = async (): Promise<SyncStatusResponse> => {
  const res = await api.get<SyncStatusResponse>("/sync/status");
  return res.data;
};

export const startSync = async (payload: {
  mode: "incremental" | "custom";
  date_from?: string;
  date_to?: string;
  categories?: string[];
}): Promise<{ status: string; message: string }> => {
  const res = await api.post<{ status: string; message: string }>("/sync/start", payload);
  return res.data;
};

// ---------------------------------------------------------------------------
// ISO 14971 Hazard Intelligence & Review Workflow
// ---------------------------------------------------------------------------
export const getHazards = async (params?: {
  confirmed_only?: boolean;
  adoption_decision?: string;
  hazard_category?: string;
  risk_level?: string;
  use_mode?: string;
  ppt_include?: string;
  min_aid_score?: number;
  brand_name?: string;
  workflow_status?: string;
  keyword?: string;
  page?: number;
  page_size?: number;
}): Promise<HazardItem[]> => {
  const query = new URLSearchParams();
  if (params?.confirmed_only) query.append("confirmed_only", "true");
  if (params?.adoption_decision) query.append("adoption_decision", params.adoption_decision);
  if (params?.hazard_category) query.append("hazard_category", params.hazard_category);
  if (params?.risk_level) query.append("risk_level", params.risk_level);
  if (params?.use_mode) query.append("use_mode", params.use_mode);
  if (params?.ppt_include) query.append("ppt_include", params.ppt_include);
  if (params?.min_aid_score) query.append("min_aid_score", String(params.min_aid_score));
  if (params?.brand_name) query.append("brand_name", params.brand_name);
  if (params?.workflow_status) query.append("workflow_status", params.workflow_status);
  if (params?.keyword) query.append("keyword", params.keyword);
  if (params?.page) query.append("page", String(params.page));
  if (params?.page_size) query.append("page_size", String(params.page_size));

  const res = await api.get<{ total: number; hazards: HazardItem[] }>(`/hazards?${query.toString()}`);
  return res.data.hazards;
};

export const getConfirmedHazards = async (params?: {
  hazard_category?: string;
  risk_level?: string;
  min_aid_score?: number;
  keyword?: string;
}): Promise<HazardItem[]> => {
  const query = new URLSearchParams();
  if (params?.hazard_category) query.append("hazard_category", params.hazard_category);
  if (params?.risk_level) query.append("risk_level", params.risk_level);
  if (params?.min_aid_score) query.append("min_aid_score", String(params.min_aid_score));
  if (params?.keyword) query.append("keyword", params.keyword);

  const res = await api.get<{ total: number; hazards: HazardItem[] }>(`/confirmed-hazards?${query.toString()}`);
  return res.data.hazards;
};

export const generateAIHazard = async (
  reportNumber: string,
  forceRefresh: boolean = false
): Promise<{ success: boolean; cached?: boolean; protected?: boolean; message?: string; hazards: HazardItem[]; error?: string }> => {
  const res = await api.post("/hazards/generate", { report_number: reportNumber, force_refresh: forceRefresh });
  return res.data;
};

export const generateAIHazardsBatch = async (
  reportNumbers: string[],
  forceRefresh: boolean = false
): Promise<{ total: number; success_count: number; protected_count?: number; fail_count: number; results: any[] }> => {
  const res = await api.post("/hazards/generate-batch", { report_numbers: reportNumbers, force_refresh: forceRefresh });
  return res.data;
};

export const saveHazardReview = async (
  hazardRowId: string,
  payload: HazardReviewPayload
): Promise<{ success: boolean; hazard_row_id: string; workflow_status: string; adoption_decision?: string }> => {
  const res = await api.post(`/hazards/${encodeURIComponent(hazardRowId)}/review`, payload);
  return res.data;
};

export const saveHazardReviewBatch = async (
  payload: HazardBatchReviewPayload
): Promise<{ success: boolean; updated_count: number }> => {
  const res = await api.post("/hazards/batch-review", payload);
  return res.data;
};

export const deleteHazard = async (
  hazardRowId: string
): Promise<{ success: boolean; deleted_id: string }> => {
  const res = await api.delete(`/hazards/${encodeURIComponent(hazardRowId)}`);
  return res.data;
};

export const getReportsHazardStatus = async (
  reportNumbers: string[]
): Promise<Record<string, ReportHazardStatus>> => {
  if (!reportNumbers || reportNumbers.length === 0) return {};
  const res = await api.post<Record<string, ReportHazardStatus>>("/reports/hazard-status", {
    report_numbers: reportNumbers,
  });
  return res.data;
};

export const finalizeHazardVersion = async (
  versionTag: string,
  finalizedBy: string = "위험관리 책임자",
  summaryNotes: string = ""
): Promise<{ success: boolean; version_tag: string; finalized_at: string; adopted_hazards: number }> => {
  const res = await api.post("/hazards/finalize", {
    version_tag: versionTag,
    finalized_by: finalizedBy,
    summary_notes: summaryNotes,
  });
  return res.data;
};

export const getHazardVersions = async (): Promise<HazardVersion[]> => {
  const res = await api.get<HazardVersion[]>("/hazards/versions");
  return res.data;
};

export const getHazardChanges = async (hazardRowId?: string): Promise<any[]> => {
  const query = hazardRowId ? `?hazard_row_id=${encodeURIComponent(hazardRowId)}` : "";
  const res = await api.get<any[]>(`/hazards/changes${query}`);
  return res.data;
};

export const addHazardCandidate = async (payload: {
  report_number: string;
  brand_name?: string;
  device_category?: string;
  event_type?: string;
  date_received?: string;
  note?: string;
}): Promise<{ success: boolean; report_number: string; already_exists?: boolean; message?: string }> => {
  const res = await api.post("/hazards/candidates", payload);
  return res.data;
};

export const getHazardCandidates = async (): Promise<HazardCandidate[]> => {
  const res = await api.get<HazardCandidate[]>("/hazards/candidates");
  return res.data;
};

export const deleteHazardCandidate = async (reportNumber: string): Promise<{ success: boolean }> => {
  const res = await api.delete(`/hazards/candidates/${encodeURIComponent(reportNumber)}`);
  return res.data;
};

export const downloadHazardsExcel = (
  exportType: "final" | "operations",
  filters: {
    confirmed_only?: boolean;
    hazard_category?: string;
    risk_level?: string;
    min_aid_score?: number;
    workflow_status?: string;
    keyword?: string;
  } = {}
) => {
  const params = new URLSearchParams();
  params.append("export_type", exportType);
  if (filters.confirmed_only) params.append("confirmed_only", "true");
  if (filters.hazard_category) params.append("hazard_category", filters.hazard_category);
  if (filters.risk_level) params.append("risk_level", filters.risk_level);
  if (filters.min_aid_score) params.append("min_aid_score", String(filters.min_aid_score));
  if (filters.workflow_status) params.append("workflow_status", filters.workflow_status);
  if (filters.keyword) params.append("keyword", filters.keyword);

  const url = `${API_BASE_URL}/hazards/export-excel?${params.toString()}`;
  window.open(url, "_blank");
};

export default api;
