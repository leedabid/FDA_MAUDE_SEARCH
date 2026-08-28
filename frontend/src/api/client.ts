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

export default api;
