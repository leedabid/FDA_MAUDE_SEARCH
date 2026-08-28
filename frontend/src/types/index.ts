export interface FilterState {
  categories: string[];
  brands: string[];
  event_types: string[];
  date_from: string;
  date_to: string;
  keyword: string;
  code_filter: string;
  report_numbers?: string[];
}

export interface Metadata {
  db_path: string;
  total_reports: number;
  min_date: string;
  max_date: string;
  categories: string[];
  canonical_brands: string[];
  canonical_brands_by_category?: Record<string, string[]>;
  all_brands: string[];
  all_brands_by_category?: Record<string, string[]>;
  brand_groups: Record<string, string[]>;
  brand_categories?: Record<string, string>;
  event_types: string[];
}

export interface OverviewStats {
  total_reports: number;
  death_count: number;
  injury_count: number;
  malfunction_count: number;
  other_count: number;
  event_type_counts: Record<string, number>;
  top_brands: Array<{ brand: string; count: number; category?: string }>;
  top_canonical_brands?: Array<{ brand: string; count: number; category?: string }>;
  top_raw_brands?: Array<{ brand: string; count: number }>;
  category_counts: Record<string, number>;
}

export interface ReportItem {
  report_number: string;
  mdr_report_key?: string;
  event_type: string;
  date_received: string;
  date_of_event?: string;
  brand_name: string;
  device_category: string;
  manufacturer_name?: string;
  patient_problems?: string;
  product_problems?: string;
  summary_complaint_kr?: string;
  summary_response_kr?: string;
  summary_conclusion_kr?: string;
  has_narrative?: boolean;
  content_status?: "narrative" | "codes" | "none";
}

export interface ProblemCodeItem {
  term: string;
  code: string;
  count: number;
  brand_breakdown: Record<string, number>;
}

export interface ReportDetail extends ReportItem {
  event_description?: string;
  manufacturer_narrative?: string;
  additional_manufacturer_narrative?: string;
  patient_problem_list?: Array<{ term: string; code: string }>;
  product_problem_list?: Array<{ term: string; code: string }>;
  raw_json?: any;
  bookmark?: BookmarkItem;
}

export interface MonthlyDataPoint {
  month: string;
  brand_name: string;
  raw_brand_name?: string;
  event_type: string;
  count: number;
}

export interface InsightsData {
  canonical_severity: Record<string, Record<string, number>>;
  raw_severity: Record<string, Record<string, number>>;
  pathways_distribution: Record<string, number>;
  pathways_timeline: Array<{ month: string; [key: string]: any }>;
  recent_month_trend: Array<{ month: string; count: number }>;
}

export interface BookmarkItem {
  report_number: string;
  folder: string;
  tags: string[];
  note: string;
  saved_at: string;
}

export interface BookmarksData {
  bookmarks: Record<string, BookmarkItem>;
  folders: string[];
}
