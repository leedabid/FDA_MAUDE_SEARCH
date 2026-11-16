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

export interface HazardItem {
  hazard_row_id: string;
  source_type?: string;
  source_key?: string;
  report_number: string;
  first_ingest_month?: string;
  first_ingested_at?: string;
  brand_name?: string;
  device_category?: string;
  event_type?: string;
  date_received?: string;
  manufacturer_name?: string;
  hazard_id_local: string;
  hazard_category_primary: string;
  hazard_ko: string;
  initiating_event_ko: string;
  hazardous_situation_ko: string;
  harm_ko: string;
  severity_level: string;
  probability_level: string;
  risk_level: string;
  risk_level_raw?: string;
  risk_score?: number;
  cgm_relevance_score: number;
  pump_relevance_score: number;
  aid_relevance_score: number;
  patient_risk_score: number;
  use_mode?: string;
  fda_action_summary_ko?: string;
  care_sens_implication_ko?: string;
  isens_preparation_ko?: string;
  recommended_preventive_controls?: string;
  recommended_recall_controls?: string;
  workflow_status: string;
  adoption_decision?: string;
  adoption_reason?: string;
  future_aid_risk?: string;
  decision_reason?: string;
  ppt_include?: string;
  ppt_id?: string;
  first_finalized_version?: string;
  finalized_version?: string;
  finalized_at?: string;
  reviewer_name?: string;
  reviewed_at?: string;
  review_note?: string;
  internal_tags?: string;
  manual_override_json?: string;
  has_manual_override?: number;
  traceability_note_ko?: string;
  created_at?: string;
  updated_at?: string;
  patient_problems?: string;
  product_problems?: string;
  summary_complaint_kr?: string;
}

export interface HazardReviewPayload {
  workflow_status?: string;
  adoption_decision?: string;
  adoption_reason?: string;
  future_aid_risk?: string;
  decision_reason?: string;
  use_mode?: string;
  ppt_include?: string;
  ppt_id?: string;
  reviewer_name?: string;
  review_note?: string;
  internal_tags?: string;
  manual_overrides?: Record<string, any>;
  client_updated_at?: string;
}

export interface HazardBatchReviewPayload {
  report_numbers: string[];
  workflow_status: string;
  reviewer_name?: string;
  review_note?: string;
  internal_tags?: string;
}

export interface ReportHazardStatus {
  has_hazard: boolean;
  hazard_count: number;
  hazard_status: string;
  adoption_status?: string;
}

export interface HazardVersion {
  version_id: number;
  version_tag: string;
  finalized_at: string;
  finalized_by: string;
  summary_notes: string;
  total_hazards: number;
  adopted_hazards: number;
  high_risk_count: number;
  medium_risk_count: number;
  low_risk_count: number;
}

export interface HazardCandidate {
  report_number: string;
  source_key: string;
  brand_name: string;
  device_category: string;
  event_type: string;
  date_received: string;
  candidate_added_at: string;
  candidate_status: string;
  candidate_note: string;
}
