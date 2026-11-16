import React, { useState, useEffect, useMemo } from "react";
import {
  ChevronLeft,
  ChevronRight,
  ArrowUpDown,
  FileText,
  ExternalLink,
  X,
  Copy,
  Check,
  AlertCircle,
  Stethoscope,
  Activity,
  Layers,
  Sparkles,
  Star,
  Tag,
  Folder,
  Globe,
  Bookmark,
  Filter,
  RotateCcw,
  Search,
  Maximize2,
  Minimize2,
  Eye,
  Info,
  Languages,
  ShieldAlert,
} from "lucide-react";
import type { FilterState, ReportItem, ReportDetail, BookmarkItem, Metadata, ReportHazardStatus } from "../../types";
import {
  queryReports,
  getReportDetail,
  getBookmarks,
  translateText,
  translateBatch,
  generateAIHazard,
  generateAIHazardsBatch,
  getReportsHazardStatus,
  addHazardCandidate,
} from "../../api/client";
import { BookmarkModal } from "../modals/BookmarkModal";

interface ReportsTabProps {
  filters: FilterState;
  selectedReportNumber?: string | null;
  onClearSelectedReport?: () => void;
  metadata?: Metadata | null;
}

const EVENT_TYPE_OPTIONS = [
  { id: "ALL", label: "전체 부작용", color: "text-slate-300", bg: "bg-slate-800" },
  { id: "Malfunction", label: "오작동 (Malfunction)", color: "text-blue-300", bg: "bg-blue-500/20 border-blue-500/40" },
  { id: "Injury", label: "상해 (Injury)", color: "text-amber-300", bg: "bg-amber-500/20 border-amber-500/40" },
  { id: "Death", label: "사망 (Death)", color: "text-rose-300", bg: "bg-rose-500/20 border-rose-500/40" },
  { id: "Other", label: "기타 (Other)", color: "text-purple-300", bg: "bg-purple-500/20 border-purple-500/40" },
];

export const ReportsTab: React.FC<ReportsTabProps> = ({
  filters,
  selectedReportNumber,
  onClearSelectedReport,
  metadata,
}) => {
  // Data State
  const [reports, setReports] = useState<ReportItem[]>([]);
  const [total, setTotal] = useState<number>(0);
  const [page, setPage] = useState<number>(1);
  const [pageSize, setPageSize] = useState<number>(50);
  const [sortBy, setSortBy] = useState<string>("date_received");
  const [sortDesc, setSortDesc] = useState<boolean>(true);
  const [loading, setLoading] = useState<boolean>(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // In-Tab Sub-Filter State (Allows further filtering inside Reports tab)
  const [subEventType, setSubEventType] = useState<string>("ALL");
  const [subBrand, setSubBrand] = useState<string>("ALL");
  const [subKeyword, setSubKeyword] = useState<string>("");
  const [keywordInput, setKeywordInput] = useState<string>("");
  const [subNarrativeOnly, setSubNarrativeOnly] = useState<"ALL" | "YES" | "NO">("ALL");

  // Split-View Detail Panel State (Left side)
  const [activeDetailNumber, setActiveDetailNumber] = useState<string | null>(null);
  const [detail, setDetail] = useState<ReportDetail | null>(null);
  const [loadingDetail, setLoadingDetail] = useState<boolean>(false);
  const [copiedJson, setCopiedJson] = useState<boolean>(false);
  const [isDetailOpen, setIsDetailOpen] = useState<boolean>(false);

  // Translation State
  const [translations, setTranslations] = useState<Record<string, string>>({});
  const [translatingMap, setTranslatingMap] = useState<Record<string, boolean>>({});
  const [autoTranslate, setAutoTranslate] = useState<boolean>(false);

  // Bookmarks
  const [bookmarksMap, setBookmarksMap] = useState<Record<string, BookmarkItem>>({});
  const [bookmarkTarget, setBookmarkTarget] = useState<ReportItem | null>(null);

  // Hazard Candidate Selection & Status State
  const [selectedReportNumbers, setSelectedReportNumbers] = useState<string[]>([]);
  const [hazardStatusMap, setHazardStatusMap] = useState<Record<string, ReportHazardStatus>>({});
  const [generatingHazards, setGeneratingHazards] = useState<boolean>(false);
  const [batchProgress, setBatchProgress] = useState<string>("");

  // Sync in-tab sub-filters when global filters change
  useEffect(() => {
    if (filters.event_types && filters.event_types.length === 1) {
      setSubEventType(filters.event_types[0]);
    } else {
      setSubEventType("ALL");
    }
    if (filters.brands && filters.brands.length === 1) {
      setSubBrand(filters.brands[0]);
    } else {
      setSubBrand("ALL");
    }
    setSubKeyword("");
    setKeywordInput("");
    setSubNarrativeOnly("ALL");
    setPage(1);
  }, [filters]);

  const loadBookmarksData = async () => {
    try {
      const data = await getBookmarks();
      setBookmarksMap(data.bookmarks || {});
    } catch (err) {
      console.error("Failed to load bookmarks:", err);
    }
  };

  useEffect(() => {
    loadBookmarksData();
  }, []);

  // Compute available brand options for In-Tab Sub-Filter
  const availableBrands = useMemo(() => {
    if (filters.brands && filters.brands.length > 0) {
      return filters.brands;
    }
    if (metadata?.canonical_brands_by_category && filters.categories) {
      const brandsList: string[] = [];
      filters.categories.forEach((cat) => {
        const catBrands = metadata.canonical_brands_by_category?.[cat] || [];
        brandsList.push(...catBrands);
      });
      if (brandsList.length > 0) {
        return Array.from(new Set(brandsList)).sort();
      }
    }
    return metadata?.canonical_brands || [];
  }, [filters.brands, filters.categories, metadata]);

  // Merge global filters with in-tab sub-filters
  const effectiveFilters = useMemo<FilterState>(() => {
    const merged: FilterState = { ...filters };

    if (subEventType !== "ALL") {
      merged.event_types = [subEventType];
    } else if (filters.event_types && filters.event_types.length === 1) {
      // If user explicitly selected '전체 부작용' chip in tab, clear event_types to view all
      merged.event_types = [];
    }
    if (subBrand !== "ALL") {
      merged.brands = [subBrand];
    }
    if (subKeyword.trim()) {
      merged.keyword = subKeyword.trim();
    }

    return merged;
  }, [filters, subEventType, subBrand, subKeyword]);

  // Fetch reports from backend
  const fetchReports = async () => {
    setLoading(true);
    setErrorMsg(null);
    try {
      const data = await queryReports(effectiveFilters, page, pageSize, sortBy, sortDesc);
      let items = data.items || [];

      if (subNarrativeOnly === "YES") {
        items = items.filter((item) => item.has_narrative);
      } else if (subNarrativeOnly === "NO") {
        items = items.filter((item) => !item.has_narrative);
      }

      setReports(items);
      setTotal(data.total || 0);

      // Fetch hazard statuses for current reports
      if (items.length > 0) {
        getReportsHazardStatus(items.map((it) => it.report_number))
          .then((statusData) => setHazardStatusMap(statusData))
          .catch((e) => console.error("Failed to load hazard statuses:", e));
      } else {
        setHazardStatusMap({});
      }
    } catch (err: any) {
      console.error("Failed to query reports:", err);
      setErrorMsg(err?.message || "보고서 데이터를 불러오지 못했습니다.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReports();
  }, [effectiveFilters, page, pageSize, sortBy, sortDesc, subNarrativeOnly]);

  // Handle external selected report (e.g. from Bookmark or Insight tab)
  useEffect(() => {
    if (selectedReportNumber) {
      handleOpenDetail(selectedReportNumber);
    }
  }, [selectedReportNumber]);

  // Reset translations on report change
  useEffect(() => {
    setTranslations({});
    setTranslatingMap({});
  }, [activeDetailNumber]);

  const handleOpenDetail = async (reportNumber: string) => {
    setActiveDetailNumber(reportNumber);
    setIsDetailOpen(true);
    setLoadingDetail(true);
    try {
      const data = await getReportDetail(reportNumber);
      setDetail(data);

      if (autoTranslate && data) {
        triggerAutoTranslation(data);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleCloseDetail = () => {
    setIsDetailOpen(false);
    setActiveDetailNumber(null);
    setDetail(null);
    if (onClearSelectedReport) {
      onClearSelectedReport();
    }
  };

  const handleSort = (col: string) => {
    if (sortBy === col) {
      setSortDesc(!sortDesc);
    } else {
      setSortBy(col);
      setSortDesc(true);
    }
  };

  const handleCopyJson = () => {
    if (!detail?.raw_json) return;
    navigator.clipboard.writeText(JSON.stringify(detail.raw_json, null, 2));
    setCopiedJson(true);
    setTimeout(() => setCopiedJson(false), 2000);
  };

  const handleKeywordSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubKeyword(keywordInput);
    setPage(1);
  };

  const handleResetSubFilters = () => {
    setSubEventType("ALL");
    setSubBrand("ALL");
    setSubKeyword("");
    setKeywordInput("");
    setSubNarrativeOnly("ALL");
    setSelectedReportNumbers([]);
    setPage(1);
  };

  // Hazard Candidate Selection Handlers
  const handleSelectAllRows = () => {
    if (selectedReportNumbers.length === reports.length) {
      setSelectedReportNumbers([]);
    } else {
      setSelectedReportNumbers(reports.map((r) => r.report_number));
    }
  };

  const handleToggleSelectRow = (reportNumber: string) => {
    setSelectedReportNumbers((prev) =>
      prev.includes(reportNumber)
        ? prev.filter((n) => n !== reportNumber)
        : [...prev, reportNumber]
    );
  };

  const handleBatchGenerateHazards = async () => {
    if (selectedReportNumbers.length === 0) return;
    if (
      !confirm(
        `선택하신 ${selectedReportNumbers.length}건의 보고서에 대해 AI 위해(Hazard) 분석을 실행하시겠습니까?\n생성된 위해 요인은 상단 [위해 분석] 메뉴에서 검토 및 확정할 수 있습니다.`
      )
    ) {
      return;
    }
    setGeneratingHazards(true);
    setBatchProgress(`분석 중... (${selectedReportNumbers.length}건)`);
    try {
      const res = await generateAIHazardsBatch(selectedReportNumbers);
      alert(
        `AI 위해 분석이 완료되었습니다!\n총 ${res.total}건 중 성공: ${res.success_count}건, 실패: ${res.fail_count}건\n상단 [위해 분석] 탭으로 이동하여 ISO 14971 위해 사슬 및 설계 통제안을 검토하세요.`
      );
      if (reports.length > 0) {
        const statusData = await getReportsHazardStatus(reports.map((r) => r.report_number));
        setHazardStatusMap(statusData);
      }
      setSelectedReportNumbers([]);
    } catch (err) {
      alert("AI 위해 분석 실행 실패: " + err);
    } finally {
      setGeneratingHazards(false);
      setBatchProgress("");
    }
  };

  const handleBatchAddCandidates = async () => {
    if (selectedReportNumbers.length === 0) return;
    let addedCount = 0;
    let existedCount = 0;
    for (const repNum of selectedReportNumbers) {
      const rep = reports.find((r) => r.report_number === repNum);
      try {
        const res = await addHazardCandidate({
          report_number: repNum,
          brand_name: rep?.brand_name,
          device_category: rep?.device_category,
          event_type: rep?.event_type,
          date_received: rep?.date_received,
        });
        if (res.already_exists) {
          existedCount++;
        } else {
          addedCount++;
        }
      } catch (err) {
        console.error("Failed to add candidate:", err);
      }
    }
    alert(
      `위해 분석 후보 담기 완료:\n- 신규 후보 등록: ${addedCount}건\n- 이미 등록되어 있던 후보: ${existedCount}건`
    );
  };

  const handleGenerateSingleHazard = async (reportNumber: string) => {
    const status = hazardStatusMap[reportNumber];
    let forceRefresh = false;

    if (status?.has_hazard) {
      const ok = window.confirm(
        `[MDR ${reportNumber}]\n이미 AI 위해 분석이 완료된 보고서입니다 (위해 항목: ${status.hazard_count}건, 상태: ${status.hazard_status || "미검토"}).\n\n재분석을 실행하시겠습니까?\n※ 이미 [채택/검토]된 기존 데이터는 안전하게 보존되며, 새 결과는 재분석 후보로 보관됩니다.\n\n[확인]을 누르면 재분석을 진행하고, [취소]를 누르면 실행하지 않습니다.`
      );
      if (!ok) {
        return;
      }
      forceRefresh = true;
    }

    setGeneratingHazards(true);
    try {
      const res = await generateAIHazard(reportNumber, forceRefresh);
      if (res.success) {
        if (res.protected) {
          alert(
            `MDR ${reportNumber} AI 재분석 완료:\n` +
            (res.message || "기존 검토/채택 데이터가 안전하게 보호되었으며, 새 결과는 '재분석 후보'로 별도 보관되었습니다.")
          );
        } else {
          alert(
            `MDR ${reportNumber}에 대한 AI 위해 분석이 완료되었습니다 (${res.hazards?.length || 0}개 위해 요인 추출).\n상단 [위해 분석] 탭에서 검토하실 수 있습니다.`
          );
        }
        const statusData = await getReportsHazardStatus([reportNumber]);
        setHazardStatusMap((prev) => ({ ...prev, ...statusData }));
      } else {
        alert("위해 분석 실패: " + (res.error || "오류"));
      }
    } catch (err) {
      alert("위해 분석 실행 오류: " + err);
    } finally {
      setGeneratingHazards(false);
    }
  };

  // Translation Handlers
  const handleTranslateParagraph = async (key: string, text: string) => {
    if (!text || translations[key]) return;
    setTranslatingMap((prev) => ({ ...prev, [key]: true }));
    try {
      const translated = await translateText(text);
      setTranslations((prev) => ({ ...prev, [key]: translated }));
    } catch (err) {
      console.error("Translation failed:", err);
    } finally {
      setTranslatingMap((prev) => ({ ...prev, [key]: false }));
    }
  };

  const triggerAutoTranslation = async (targetDetail: ReportDetail) => {
    const tasks: { key: string; text: string }[] = [];
    if (targetDetail.event_description) {
      tasks.push({ key: "event_desc", text: targetDetail.event_description });
    }
    if (targetDetail.manufacturer_narrative) {
      tasks.push({ key: "mfr_narr", text: targetDetail.manufacturer_narrative });
    }
    if (targetDetail.additional_manufacturer_narrative) {
      tasks.push({ key: "add_mfr_narr", text: targetDetail.additional_manufacturer_narrative });
    }
    if (targetDetail.raw_json?.mdr_text && Array.isArray(targetDetail.raw_json.mdr_text)) {
      targetDetail.raw_json.mdr_text.forEach((item: any, idx: number) => {
        if (item.text) {
          tasks.push({ key: `raw_txt_${idx}`, text: item.text });
        }
      });
    }

    if (tasks.length === 0) return;

    setTranslatingMap((prev) => {
      const updated = { ...prev };
      tasks.forEach((t) => (updated[t.key] = true));
      return updated;
    });

    try {
      const texts = tasks.map((t) => t.text);
      const results = await translateBatch(texts);
      setTranslations((prev) => {
        const updated = { ...prev };
        tasks.forEach((t, i) => {
          updated[t.key] = results[i] || "";
        });
        return updated;
      });
    } catch (err) {
      console.error("Batch translation failed:", err);
    } finally {
      setTranslatingMap((prev) => {
        const updated = { ...prev };
        tasks.forEach((t) => (updated[t.key] = false));
        return updated;
      });
    }
  };

  const handleTranslateAllNarratives = () => {
    if (detail) {
      triggerAutoTranslation(detail);
    }
  };

  const isSubFilterActive =
    subEventType !== "ALL" ||
    subBrand !== "ALL" ||
    subKeyword.trim() !== "" ||
    subNarrativeOnly !== "ALL";

  const totalPages = Math.ceil(total / pageSize);

  // FDA Official Webpage link for this report
  const fdaOfficialUrl = detail?.mdr_report_key
    ? `https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfmaude/detail.cfm?mdrfoi__id=${detail.mdr_report_key}`
    : detail?.report_number
    ? `https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfmaude/results.cfm?start_search=1&searchnumber=${encodeURIComponent(detail.report_number)}`
    : null;

  return (
    <div className="space-y-4 animate-fadeIn flex flex-col h-full">
      {/* 1. In-Tab Smart Filter Bar */}
      <div className="bg-slate-900/80 border border-slate-800 p-3.5 rounded-2xl backdrop-blur-md shadow-xl space-y-3">
        <div className="flex flex-wrap items-center justify-between gap-3">
          {/* Title & Total count */}
          <div className="flex items-center gap-2.5">
            <div className="p-2 bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 rounded-xl">
              <FileText className="w-4 h-4" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-sm font-bold text-white">전체 MDR 부작용 보고서</h2>
                <span className="px-2 py-0.5 text-[10px] font-mono font-bold bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 rounded-full">
                  {total.toLocaleString()}건
                </span>
                {isSubFilterActive && (
                  <span className="text-[10px] text-amber-400 bg-amber-500/10 border border-amber-500/20 px-2 py-0.5 rounded-full flex items-center gap-1">
                    <Filter className="w-2.5 h-2.5" />
                    내부 필터 적용됨
                  </span>
                )}
              </div>
              <p className="text-[11px] text-slate-400">
                초기 필터 결과 내에서 특정 제품, 부작용 유형, 또는 키워드로 즉시 재필터링할 수 있습니다.
              </p>
            </div>
          </div>

          {/* Right Action: In-tab Keyword Search & Reset */}
          <div className="flex items-center gap-2">
            <form onSubmit={handleKeywordSearchSubmit} className="relative">
              <input
                type="text"
                placeholder="결과 내 검색 (증상, 모델명, 번호)..."
                value={keywordInput}
                onChange={(e) => setKeywordInput(e.target.value)}
                className="w-56 pl-8 pr-7 py-1.5 bg-slate-950 border border-slate-700/80 rounded-xl text-xs text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500 focus:w-64 transition-all"
              />
              <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-1/2 -translate-y-1/2" />
              {keywordInput && (
                <button
                  type="button"
                  onClick={() => {
                    setKeywordInput("");
                    setSubKeyword("");
                  }}
                  className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              )}
            </form>

            {isSubFilterActive && (
              <button
                type="button"
                onClick={handleResetSubFilters}
                className="flex items-center gap-1 px-2.5 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs rounded-xl border border-slate-700 transition"
                title="내부 필터 초기화"
              >
                <RotateCcw className="w-3 h-3 text-amber-400" />
                <span>필터 초기화</span>
              </button>
            )}

            {/* Split View Toggle Button */}
            <button
              type="button"
              onClick={() => {
                if (!isDetailOpen && reports.length > 0) {
                  handleOpenDetail(reports[0].report_number);
                } else {
                  setIsDetailOpen(!isDetailOpen);
                }
              }}
              className={`flex items-center gap-1.5 px-3 py-1.5 text-xs rounded-xl font-medium border transition ${
                isDetailOpen
                  ? "bg-indigo-600/20 text-indigo-300 border-indigo-500/40"
                  : "bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700"
              }`}
            >
              {isDetailOpen ? (
                <>
                  <Maximize2 className="w-3.5 h-3.5 text-indigo-400" />
                  <span>목록 전체화면</span>
                </>
              ) : (
                <>
                  <Eye className="w-3.5 h-3.5 text-slate-400" />
                  <span>상세 패널 열기</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* Sub-Filter Controls Row */}
        <div className="pt-2 border-t border-slate-800/80 flex flex-wrap items-center justify-between gap-3 text-xs">
          {/* 1. Quick Event Type Chips */}
          <div className="flex items-center gap-1.5 flex-wrap">
            <span className="text-[11px] font-semibold text-slate-400 mr-1 flex items-center gap-1">
              <Activity className="w-3 h-3 text-indigo-400" />
              부작용 유형:
            </span>
            {EVENT_TYPE_OPTIONS.map((opt) => {
              const active = subEventType === opt.id;
              return (
                <button
                  key={opt.id}
                  type="button"
                  onClick={() => {
                    setSubEventType((prev) => (prev === opt.id && opt.id !== "ALL" ? "ALL" : opt.id));
                    setPage(1);
                  }}
                  className={`px-2.5 py-1 rounded-lg text-[11px] font-medium border transition cursor-pointer ${
                    active
                      ? `${opt.bg} ${opt.color} border-current shadow-md font-bold scale-105 ring-1 ring-current`
                      : "bg-slate-950/60 border-slate-800 text-slate-400 hover:text-white hover:bg-slate-800/60"
                  }`}
                >
                  {opt.label}
                </button>
              );
            })}
          </div>

          {/* 2. Quick Brand Dropdown & Narrative toggle & Page Size */}
          <div className="flex items-center gap-3 flex-wrap">
            {/* Brand Dropdown */}
            {availableBrands.length > 0 && (
              <div className="flex items-center gap-1.5">
                <span className="text-[11px] text-slate-400">제품(Brand):</span>
                <select
                  value={subBrand}
                  onChange={(e) => {
                    setSubBrand(e.target.value);
                    setPage(1);
                  }}
                  className="bg-slate-950 border border-slate-700/80 rounded-lg px-2.5 py-1 text-white text-xs focus:outline-none focus:border-indigo-500 max-w-[160px] truncate"
                >
                  <option value="ALL">전체 제품 (모두 보기)</option>
                  {availableBrands.map((b) => (
                    <option key={b} value={b}>
                      {b}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Narrative Content filter */}
            <div className="flex items-center gap-1.5">
              <span className="text-[11px] text-slate-400">내용 유무:</span>
              <select
                value={subNarrativeOnly}
                onChange={(e) => {
                  setSubNarrativeOnly(e.target.value as any);
                  setPage(1);
                }}
                className="bg-slate-950 border border-slate-700/80 rounded-lg px-2 py-1 text-white text-xs focus:outline-none focus:border-indigo-500"
              >
                <option value="ALL">전체</option>
                <option value="YES">🟢 원문 있음</option>
                <option value="NO">⚪ 원문 없음 (코드만)</option>
              </select>
            </div>

            {/* Page Size */}
            <div className="flex items-center gap-1.5">
              <span className="text-[11px] text-slate-400">보기:</span>
              <select
                value={pageSize}
                onChange={(e) => {
                  setPageSize(Number(e.target.value));
                  setPage(1);
                }}
                className="bg-slate-950 border border-slate-700/80 rounded-lg px-2 py-1 text-white text-xs focus:outline-none focus:border-indigo-500"
              >
                <option value={20}>20건</option>
                <option value={50}>50건</option>
                <option value={100}>100건</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Batch Hazard Candidate Action Toolbar */}
      {selectedReportNumbers.length > 0 && (
        <div className="bg-rose-950/70 border border-rose-500/40 rounded-xl px-4 py-2.5 flex items-center justify-between text-xs animate-fadeIn shadow-lg">
          <div className="flex items-center gap-3">
            <span className="font-bold text-rose-200">
              {selectedReportNumbers.length}건의 보고서가 위해 분석 후보로 선택됨
            </span>
            <span className="text-slate-400 text-[11px]">
              (체크된 불만 사례에 대해 ISO 14971 위해 요인 자동 도출)
            </span>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleBatchAddCandidates}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-indigo-700 hover:bg-indigo-600 text-white font-semibold transition shadow cursor-pointer"
              title="선택된 보고서를 사내 위해 관리 검토 대상 후보로 등록합니다"
            >
              <span>📌 후보 담기</span>
            </button>
            <button
              type="button"
              onClick={handleBatchGenerateHazards}
              disabled={generatingHazards}
              className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-500 text-white font-bold transition shadow cursor-pointer disabled:opacity-50"
            >
              <Sparkles className="w-3.5 h-3.5" />
              <span>{generatingHazards ? (batchProgress || "AI 분석 생성 중...") : "✨ 선택 보고서 AI 위해 분석 실행"}</span>
            </button>
            <button
              type="button"
              onClick={() => setSelectedReportNumbers([])}
              className="px-2.5 py-1 text-slate-400 hover:text-slate-200 text-xs cursor-pointer"
            >
              선택 취소
            </button>
          </div>
        </div>
      )}

      {/* 2. Main Content: Master-Detail Split View (Left: Detail, Right: List) */}
      <div className="flex-1 flex gap-4 min-h-0 overflow-hidden">
        {/* LEFT PANEL: Selected MDR Report Detail */}
        {isDetailOpen && (
          <div className="w-full lg:w-5/12 xl:w-5/12 flex flex-col bg-slate-900/80 border border-slate-800 rounded-2xl overflow-hidden shadow-2xl backdrop-blur-md animate-fadeIn">
            {/* Detail Header */}
            <div className="p-4 border-b border-slate-800 bg-slate-950/80 flex items-center justify-between shrink-0">
              <div className="flex items-center gap-2.5 overflow-hidden">
                <div className="p-2 bg-indigo-500/20 text-indigo-400 rounded-xl border border-indigo-500/30 shrink-0">
                  <FileText className="w-4 h-4" />
                </div>
                <div className="truncate">
                  <div className="flex items-center gap-2">
                    <h3 className="text-sm font-bold text-white font-mono truncate">
                      {activeDetailNumber || "보고서 상세"}
                    </h3>
                    {detail && (
                      <span
                        className={`px-2 py-0.5 text-[10px] font-bold rounded uppercase shrink-0 ${
                          detail.event_type === "Death"
                            ? "bg-rose-500/20 text-rose-300 border border-rose-500/30"
                            : detail.event_type === "Injury"
                            ? "bg-amber-500/20 text-amber-300 border border-amber-500/30"
                            : "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                        }`}
                      >
                        {detail.event_type}
                      </span>
                    )}
                  </div>
                  <p className="text-[11px] text-slate-400 truncate">
                    {detail?.brand_name || "MDR Report Details"}
                  </p>
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center gap-1.5 shrink-0">
                {fdaOfficialUrl && (
                  <a
                    href={fdaOfficialUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="flex items-center gap-1 px-2.5 py-1 text-[11px] font-semibold bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 rounded-lg transition"
                    title="FDA 공식 MAUDE 웹페이지 새창 열기"
                  >
                    <Globe className="w-3 h-3" />
                    <span>FDA 웹 ↗</span>
                  </a>
                )}

                {detail && (
                  <button
                    onClick={() => handleGenerateSingleHazard(detail.report_number)}
                    disabled={generatingHazards}
                    className="flex items-center gap-1 px-2.5 py-1 text-[11px] font-semibold bg-rose-600/20 hover:bg-rose-600/30 text-rose-300 border border-rose-500/30 rounded-lg transition cursor-pointer"
                    title="이 MDR 보고서에 대해 ISO 14971 AI 위해 분석을 실행합니다"
                  >
                    <ShieldAlert className="w-3 h-3 text-rose-400" />
                    <span>
                      {hazardStatusMap[detail.report_number]?.has_hazard
                        ? "위해 재분석"
                        : "AI 위해 분석"}
                    </span>
                  </button>
                )}

                {detail && (
                  <button
                    onClick={() => setBookmarkTarget(detail)}
                    className="flex items-center gap-1 px-2.5 py-1 text-[11px] font-semibold bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 border border-amber-500/30 rounded-lg transition"
                    title={activeDetailNumber && bookmarksMap[activeDetailNumber] ? "보관함 수정" : "보관함 저장"}
                  >
                    <Star
                      className={`w-3 h-3 ${
                        activeDetailNumber && bookmarksMap[activeDetailNumber] ? "fill-amber-400" : ""
                      }`}
                    />
                    <span>{activeDetailNumber && bookmarksMap[activeDetailNumber] ? "저장됨" : "보관"}</span>
                  </button>
                )}

                <button
                  onClick={handleCloseDetail}
                  className="p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
                  title="상세 패널 닫기 (목록 전체화면)"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Detail Scrollable Body */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4 custom-scrollbar text-xs">
              {loadingDetail ? (
                <div className="flex flex-col items-center justify-center h-64 text-slate-400 space-y-3">
                  <div className="w-7 h-7 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
                  <span>보고서 상세 정보 로딩 중...</span>
                </div>
              ) : detail ? (
                <>
                  {/* Bookmark info if saved */}
                  {activeDetailNumber && bookmarksMap[activeDetailNumber] && (
                    <div className="p-3 bg-amber-500/10 border border-amber-500/20 rounded-xl space-y-1.5">
                      <div className="flex items-center justify-between text-xs text-amber-300 font-semibold">
                        <span className="flex items-center gap-1.5">
                          <Folder className="w-3.5 h-3.5" />
                          보관함: {bookmarksMap[activeDetailNumber].folder}
                        </span>
                        <span className="text-[10px] text-amber-400/80 font-mono">
                          {bookmarksMap[activeDetailNumber].saved_at}
                        </span>
                      </div>
                      {bookmarksMap[activeDetailNumber].tags?.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {bookmarksMap[activeDetailNumber].tags.map((tag) => (
                            <span
                              key={tag}
                              className="px-2 py-0.5 bg-amber-500/20 text-amber-300 text-[10px] rounded flex items-center gap-1 font-mono"
                            >
                              <Tag className="w-2.5 h-2.5" />
                              {tag}
                            </span>
                          ))}
                        </div>
                      )}
                      {bookmarksMap[activeDetailNumber].note && (
                        <p className="text-slate-300 text-[11px] italic bg-slate-900/60 p-2 rounded-lg border border-slate-800/80">
                          "{bookmarksMap[activeDetailNumber].note}"
                        </p>
                      )}
                    </div>
                  )}

                  {/* 1. AI & Rule Based Korean 3-Stage Summary Card */}
                  <div className="space-y-2">
                    <div className="flex items-center gap-1.5 text-indigo-400 font-bold text-xs uppercase tracking-wider">
                      <Sparkles className="w-3.5 h-3.5" />
                      <span>3단계 핵심 내용 요약 (Summary)</span>
                    </div>

                    <div className="space-y-2">
                      <div className="p-3 bg-slate-950/80 border border-slate-800 rounded-xl space-y-1">
                        <span className="text-[11px] font-semibold text-indigo-300 block">
                          1. 소비자/환자 불만 및 증상 (Complaint)
                        </span>
                        <p className="text-slate-200 leading-relaxed text-xs">
                          {detail.summary_complaint_kr || "불만사항 정보가 없습니다."}
                        </p>
                      </div>

                      <div className="p-3 bg-slate-950/80 border border-slate-800 rounded-xl space-y-1">
                        <span className="text-[11px] font-semibold text-amber-300 block">
                          2. 제조사 조사 및 대응 내용 (Response)
                        </span>
                        <p className="text-slate-200 leading-relaxed text-xs">
                          {detail.summary_response_kr || "제조사 대응 정보가 없습니다."}
                        </p>
                      </div>

                      <div className="p-3 bg-slate-950/80 border border-slate-800 rounded-xl space-y-1">
                        <span className="text-[11px] font-semibold text-emerald-300 block">
                          3. 종합 결론 (Conclusion)
                        </span>
                        <p className="text-slate-200 leading-relaxed text-xs">
                          {detail.summary_conclusion_kr || "종합 결론 정보가 없습니다."}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* 2. Metadata Grid */}
                  <div className="grid grid-cols-2 gap-2.5 p-3 bg-slate-950/60 border border-slate-800 rounded-xl">
                    <div>
                      <span className="text-slate-500 block text-[10px]">제품명 (Brand)</span>
                      <span className="font-semibold text-white truncate block">{detail.brand_name || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[10px]">제조사</span>
                      <span className="font-semibold text-white truncate block">{detail.manufacturer_name || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[10px]">접수 일자</span>
                      <span className="font-mono text-slate-300">{detail.date_received || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[10px]">사건 발생일</span>
                      <span className="font-mono text-slate-300">{detail.date_of_event || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[10px]">카테고리</span>
                      <span className="text-slate-300">{detail.device_category || "CGM"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[10px]">MDR Key</span>
                      <span className="font-mono text-slate-300">{detail.mdr_report_key || "-"}</span>
                    </div>
                  </div>

                  {/* 3. FDA IMDRF Standard Annex Codes */}
                  <div className="space-y-2">
                    <div className="flex items-center gap-1.5 text-slate-300 font-bold text-xs uppercase tracking-wider">
                      <Stethoscope className="w-3.5 h-3.5 text-emerald-400" />
                      <span>FDA IMDRF 표준 문제 코드</span>
                    </div>

                    <div className="grid grid-cols-1 gap-2">
                      {/* Annex E: Patient Problem */}
                      <div className="p-3 bg-slate-950/60 border border-slate-800 rounded-xl space-y-1.5">
                        <span className="text-[11px] font-semibold text-emerald-400 block">
                          Annex E (환자 증상 코드)
                        </span>
                        {detail.patient_problem_list && detail.patient_problem_list.length > 0 ? (
                          <div className="space-y-1">
                            {detail.patient_problem_list.map((p, idx) => (
                              <div
                                key={idx}
                                className="flex items-center justify-between bg-slate-900/80 px-2.5 py-1.5 rounded-lg border border-slate-800"
                              >
                                <span className="text-slate-300 text-xs">{p.term}</span>
                                <span className="font-mono text-[10px] bg-emerald-500/20 text-emerald-300 px-1.5 py-0.5 rounded border border-emerald-500/30">
                                  {p.code || "코드미상"}
                                </span>
                              </div>
                            ))}
                          </div>
                        ) : (
                          <span className="text-slate-500 text-xs">환자 증상 코드 없음</span>
                        )}
                      </div>

                      {/* Annex A: Device Problem */}
                      <div className="p-3 bg-slate-950/60 border border-slate-800 rounded-xl space-y-1.5">
                        <span className="text-[11px] font-semibold text-blue-400 block">
                          Annex A (기기 결함 코드)
                        </span>
                        {detail.product_problem_list && detail.product_problem_list.length > 0 ? (
                          <div className="space-y-1">
                            {detail.product_problem_list.map((p, idx) => (
                              <div
                                key={idx}
                                className="flex items-center justify-between bg-slate-900/80 px-2.5 py-1.5 rounded-lg border border-slate-800"
                              >
                                <span className="text-slate-300 text-xs">{p.term}</span>
                                <span className="font-mono text-[10px] bg-blue-500/20 text-blue-300 px-1.5 py-0.5 rounded border border-blue-500/30">
                                  {p.code || "코드미상"}
                                </span>
                              </div>
                            ))}
                          </div>
                        ) : (
                          <span className="text-slate-500 text-xs">기기 결함 코드 없음</span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* 4. English Narratives + Korean Translation (Bilingual View) */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between flex-wrap gap-2 pt-1 border-t border-slate-800/80">
                      <div className="flex items-center gap-1.5 text-slate-300 font-bold text-xs uppercase tracking-wider">
                        <Layers className="w-3.5 h-3.5 text-indigo-400" />
                        <span>영어 원문 내러티브 & 한국어 번역</span>
                      </div>

                      {/* Translation Controls */}
                      <div className="flex items-center gap-2">
                        <label className="flex items-center gap-1 text-[11px] text-slate-400 hover:text-white cursor-pointer select-none">
                          <input
                            type="checkbox"
                            checked={autoTranslate}
                            onChange={(e) => {
                              setAutoTranslate(e.target.checked);
                              if (e.target.checked && detail) {
                                triggerAutoTranslation(detail);
                              }
                            }}
                            className="rounded border-slate-700 bg-slate-800 text-indigo-500 focus:ring-0 w-3 h-3"
                          />
                          <span>자동 번역</span>
                        </label>

                        <button
                          type="button"
                          onClick={handleTranslateAllNarratives}
                          className="flex items-center gap-1 px-2.5 py-1 text-[11px] font-semibold bg-indigo-600/30 hover:bg-indigo-600/50 text-indigo-200 border border-indigo-500/40 rounded-lg transition shadow-sm"
                          title="영어 원문 전체를 한국어로 실시간 번역"
                        >
                          <Languages className="w-3.5 h-3.5 text-indigo-300" />
                          <span>전체 한국어 번역</span>
                        </button>
                      </div>
                    </div>

                    {/* 4-1. Event Description */}
                    {detail.event_description && (
                      <div className="p-3 bg-slate-950/70 border border-slate-800 rounded-xl space-y-2 shadow-inner">
                        <div className="flex items-center justify-between">
                          <span className="text-[11px] font-semibold text-indigo-400 flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-indigo-400"></span>
                            Event Description (사건/불만 설명)
                          </span>
                          {!translations["event_desc"] && (
                            <button
                              type="button"
                              onClick={() => handleTranslateParagraph("event_desc", detail.event_description!)}
                              disabled={translatingMap["event_desc"]}
                              className="text-[10px] text-slate-400 hover:text-indigo-300 flex items-center gap-1 px-1.5 py-0.5 rounded border border-slate-800 hover:border-indigo-500/50 transition"
                            >
                              <Languages className="w-2.5 h-2.5" />
                              <span>{translatingMap["event_desc"] ? "번역 중..." : "한글 번역"}</span>
                            </button>
                          )}
                        </div>

                        {/* English Original */}
                        <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                          {detail.event_description}
                        </p>

                        {/* Korean Translation Box */}
                        {translatingMap["event_desc"] ? (
                          <div className="mt-2 p-2 bg-indigo-950/30 border border-indigo-500/30 rounded-lg flex items-center gap-2 text-indigo-300 text-xs">
                            <div className="w-3.5 h-3.5 border-2 border-indigo-400 border-t-transparent rounded-full animate-spin"></div>
                            <span>한국어로 번역 중...</span>
                          </div>
                        ) : translations["event_desc"] ? (
                          <div className="mt-2.5 p-2.5 bg-emerald-950/20 border border-emerald-500/30 rounded-lg space-y-1 animate-fadeIn">
                            <div className="flex items-center justify-between text-[10px] font-bold text-emerald-400">
                              <span className="flex items-center gap-1">
                                <Languages className="w-3 h-3" />
                                🇰🇷 한국어 번역
                              </span>
                              <span className="text-[9px] text-emerald-500/70 font-normal">실시간 번역</span>
                            </div>
                            <p className="text-emerald-100/90 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                              {translations["event_desc"]}
                            </p>
                          </div>
                        ) : null}
                      </div>
                    )}

                    {/* 4-2. Manufacturer Narrative */}
                    {detail.manufacturer_narrative && (
                      <div className="p-3 bg-slate-950/70 border border-slate-800 rounded-xl space-y-2 shadow-inner">
                        <div className="flex items-center justify-between">
                          <span className="text-[11px] font-semibold text-amber-400 flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
                            Manufacturer Narrative (제조사 1차 분석 및 대응)
                          </span>
                          {!translations["mfr_narr"] && (
                            <button
                              type="button"
                              onClick={() => handleTranslateParagraph("mfr_narr", detail.manufacturer_narrative!)}
                              disabled={translatingMap["mfr_narr"]}
                              className="text-[10px] text-slate-400 hover:text-amber-300 flex items-center gap-1 px-1.5 py-0.5 rounded border border-slate-800 hover:border-amber-500/50 transition"
                            >
                              <Languages className="w-2.5 h-2.5" />
                              <span>{translatingMap["mfr_narr"] ? "번역 중..." : "한글 번역"}</span>
                            </button>
                          )}
                        </div>

                        {/* English Original */}
                        <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                          {detail.manufacturer_narrative}
                        </p>

                        {/* Korean Translation Box */}
                        {translatingMap["mfr_narr"] ? (
                          <div className="mt-2 p-2 bg-amber-950/30 border border-amber-500/30 rounded-lg flex items-center gap-2 text-amber-300 text-xs">
                            <div className="w-3.5 h-3.5 border-2 border-amber-400 border-t-transparent rounded-full animate-spin"></div>
                            <span>한국어로 번역 중...</span>
                          </div>
                        ) : translations["mfr_narr"] ? (
                          <div className="mt-2.5 p-2.5 bg-emerald-950/20 border border-emerald-500/30 rounded-lg space-y-1 animate-fadeIn">
                            <div className="flex items-center justify-between text-[10px] font-bold text-emerald-400">
                              <span className="flex items-center gap-1">
                                <Languages className="w-3 h-3" />
                                🇰🇷 한국어 번역
                              </span>
                              <span className="text-[9px] text-emerald-500/70 font-normal">실시간 번역</span>
                            </div>
                            <p className="text-emerald-100/90 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                              {translations["mfr_narr"]}
                            </p>
                          </div>
                        ) : null}
                      </div>
                    )}

                    {/* 4-3. Additional Manufacturer Narrative */}
                    {detail.additional_manufacturer_narrative && (
                      <div className="p-3 bg-slate-950/70 border border-slate-800 rounded-xl space-y-2 shadow-inner">
                        <div className="flex items-center justify-between">
                          <span className="text-[11px] font-semibold text-emerald-400 flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                            Additional Manufacturer Narrative (제조사 추가 분석)
                          </span>
                          {!translations["add_mfr_narr"] && (
                            <button
                              type="button"
                              onClick={() => handleTranslateParagraph("add_mfr_narr", detail.additional_manufacturer_narrative!)}
                              disabled={translatingMap["add_mfr_narr"]}
                              className="text-[10px] text-slate-400 hover:text-emerald-300 flex items-center gap-1 px-1.5 py-0.5 rounded border border-slate-800 hover:border-emerald-500/50 transition"
                            >
                              <Languages className="w-2.5 h-2.5" />
                              <span>{translatingMap["add_mfr_narr"] ? "번역 중..." : "한글 번역"}</span>
                            </button>
                          )}
                        </div>

                        {/* English Original */}
                        <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                          {detail.additional_manufacturer_narrative}
                        </p>

                        {/* Korean Translation Box */}
                        {translatingMap["add_mfr_narr"] ? (
                          <div className="mt-2 p-2 bg-emerald-950/30 border border-emerald-500/30 rounded-lg flex items-center gap-2 text-emerald-300 text-xs">
                            <div className="w-3.5 h-3.5 border-2 border-emerald-400 border-t-transparent rounded-full animate-spin"></div>
                            <span>한국어로 번역 중...</span>
                          </div>
                        ) : translations["add_mfr_narr"] ? (
                          <div className="mt-2.5 p-2.5 bg-emerald-950/20 border border-emerald-500/30 rounded-lg space-y-1 animate-fadeIn">
                            <div className="flex items-center justify-between text-[10px] font-bold text-emerald-400">
                              <span className="flex items-center gap-1">
                                <Languages className="w-3 h-3" />
                                🇰🇷 한국어 번역
                              </span>
                              <span className="text-[9px] text-emerald-500/70 font-normal">실시간 번역</span>
                            </div>
                            <p className="text-emerald-100/90 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                              {translations["add_mfr_narr"]}
                            </p>
                          </div>
                        ) : null}
                      </div>
                    )}

                    {/* Fallback to raw_json mdr_text list */}
                    {!detail.event_description &&
                      !detail.manufacturer_narrative &&
                      !detail.additional_manufacturer_narrative &&
                      detail.raw_json?.mdr_text &&
                      Array.isArray(detail.raw_json.mdr_text) &&
                      detail.raw_json.mdr_text.length > 0 && (
                        <div className="space-y-2">
                          {detail.raw_json.mdr_text.map((txtItem: any, idx: number) => {
                            const k = `raw_txt_${idx}`;
                            return (
                              <div
                                key={idx}
                                className="p-3 bg-slate-950/70 border border-slate-800 rounded-xl space-y-2"
                              >
                                <div className="flex items-center justify-between">
                                  <span className="text-[11px] font-semibold text-indigo-300 block">
                                    {txtItem.text_type_code || `Narrative #${idx + 1}`}
                                  </span>
                                  {!translations[k] && txtItem.text && (
                                    <button
                                      type="button"
                                      onClick={() => handleTranslateParagraph(k, txtItem.text)}
                                      disabled={translatingMap[k]}
                                      className="text-[10px] text-slate-400 hover:text-indigo-300 flex items-center gap-1 px-1.5 py-0.5 rounded border border-slate-800 hover:border-indigo-500/50 transition"
                                    >
                                      <Languages className="w-2.5 h-2.5" />
                                      <span>{translatingMap[k] ? "번역 중..." : "한글 번역"}</span>
                                    </button>
                                  )}
                                </div>
                                <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                                  {txtItem.text}
                                </p>
                                {translations[k] && (
                                  <div className="mt-2.5 p-2.5 bg-emerald-950/20 border border-emerald-500/30 rounded-lg space-y-1 animate-fadeIn">
                                    <div className="flex items-center justify-between text-[10px] font-bold text-emerald-400">
                                      <span className="flex items-center gap-1">
                                        <Languages className="w-3 h-3" />
                                        🇰🇷 한국어 번역
                                      </span>
                                    </div>
                                    <p className="text-emerald-100/90 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                                      {translations[k]}
                                    </p>
                                  </div>
                                )}
                              </div>
                            );
                          })}
                        </div>
                      )}

                    {/* No narrative note */}
                    {!detail.event_description &&
                      !detail.manufacturer_narrative &&
                      !detail.additional_manufacturer_narrative &&
                      (!detail.raw_json?.mdr_text || detail.raw_json.mdr_text.length === 0) && (
                        <div className="p-3.5 bg-slate-950/70 border border-slate-800 rounded-xl space-y-1.5 text-xs">
                          <div className="flex items-center gap-1.5 text-amber-400 font-semibold text-[11px]">
                            <AlertCircle className="w-3.5 h-3.5 shrink-0" />
                            <span>openFDA 공개 API 텍스트 미제공 안내</span>
                          </div>
                          <p className="text-slate-400 text-[11px] leading-relaxed">
                            본 보고서는 openFDA 공개 JSON 데이터셋 상에 원문 텍스트가 누락된 건입니다. FDA 공식 웹페이지에서 전체 원문을 확인하실 수 있습니다.
                          </p>
                          {fdaOfficialUrl && (
                            <a
                              href={fdaOfficialUrl}
                              target="_blank"
                              rel="noreferrer"
                              className="inline-flex items-center gap-1 px-2.5 py-1 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-bold text-xs transition mt-1"
                            >
                              <Globe className="w-3 h-3" />
                              <span>FDA 공식 웹페이지에서 확인 ↗</span>
                            </a>
                          )}
                        </div>
                      )}
                  </div>

                  {/* 5. Raw JSON Accordion */}
                  {detail.raw_json && (
                    <div className="space-y-1.5 pt-2 border-t border-slate-800">
                      <div className="flex items-center justify-between">
                        <span className="text-slate-400 font-semibold text-[11px]">
                          FDA MAUDE Raw JSON 원본
                        </span>
                        <button
                          onClick={handleCopyJson}
                          className="flex items-center gap-1 text-[11px] text-indigo-400 hover:text-indigo-300 transition"
                        >
                          {copiedJson ? (
                            <>
                              <Check className="w-3 h-3 text-emerald-400" />
                              <span className="text-emerald-400">복사됨</span>
                            </>
                          ) : (
                            <>
                              <Copy className="w-3 h-3" />
                              <span>JSON 복사</span>
                            </>
                          )}
                        </button>
                      </div>
                      <pre className="p-2.5 bg-slate-950 border border-slate-800 rounded-xl font-mono text-[10px] text-slate-400 overflow-x-auto max-h-48 custom-scrollbar">
                        {JSON.stringify(detail.raw_json, null, 2)}
                      </pre>
                    </div>
                  )}
                </>
              ) : (
                <div className="flex flex-col items-center justify-center h-64 text-slate-500 space-y-2">
                  <Info className="w-6 h-6 text-slate-600" />
                  <span>보고서 정보를 불러올 수 없습니다.</span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* RIGHT PANEL: Master Reports Table */}
        <div
          className={`flex-1 flex flex-col bg-slate-900/60 border border-slate-800 rounded-2xl backdrop-blur-md overflow-hidden shadow-xl transition-all ${
            isDetailOpen ? "" : "w-full"
          }`}
        >
          {/* Table Container */}
          <div className="flex-1 overflow-x-auto overflow-y-auto custom-scrollbar">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-800 text-slate-400 font-medium bg-slate-950/80 sticky top-0 z-10 backdrop-blur-md">
                  {/* Select All Checkbox */}
                  <th
                    className="py-2.5 px-2 text-center w-8 cursor-pointer"
                    onClick={handleSelectAllRows}
                  >
                    <input
                      type="checkbox"
                      checked={reports.length > 0 && selectedReportNumbers.length === reports.length}
                      onChange={() => {}}
                      className="rounded bg-slate-900 border-slate-700 text-indigo-500 focus:ring-0 cursor-pointer pointer-events-none"
                      title="전체 선택 / 해제"
                    />
                  </th>
                  <th className="py-2.5 px-2.5 text-center w-9">
                    <Bookmark className="w-3.5 h-3.5 mx-auto text-amber-400" />
                  </th>
                  <th
                    onClick={() => handleSort("report_number")}
                    className="py-2.5 px-3 cursor-pointer hover:text-white transition w-36"
                  >
                    <div className="flex items-center gap-1">
                      <span>MDR 번호</span>
                      <ArrowUpDown className="w-3 h-3 text-slate-500" />
                    </div>
                  </th>
                  <th
                    onClick={() => handleSort("brand_name")}
                    className="py-2.5 px-3 cursor-pointer hover:text-white transition w-40"
                  >
                    <div className="flex items-center gap-1">
                      <span>제품명 (Brand)</span>
                      <ArrowUpDown className="w-3 h-3 text-slate-500" />
                    </div>
                  </th>
                  <th
                    onClick={() => handleSort("event_type")}
                    className="py-2.5 px-2.5 cursor-pointer hover:text-white transition w-24 text-center"
                  >
                    <div className="flex items-center justify-center gap-1">
                      <span>부작용</span>
                      <ArrowUpDown className="w-3 h-3 text-slate-500" />
                    </div>
                  </th>
                  <th className="py-2.5 px-2 text-center w-20">내용유무</th>
                  <th
                    onClick={() => handleSort("date_received")}
                    className="py-2.5 px-3 cursor-pointer hover:text-white transition w-24 text-center"
                  >
                    <div className="flex items-center justify-center gap-1">
                      <span>접수일</span>
                      <ArrowUpDown className="w-3 h-3 text-slate-500" />
                    </div>
                  </th>
                  <th className="py-2.5 px-3">불만/증상 요약 (Summary)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/60 text-slate-300">
                {loading ? (
                  <tr>
                    <td colSpan={8} className="text-center py-24 text-slate-500">
                      <div className="flex flex-col items-center gap-2">
                        <div className="w-6 h-6 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
                        <span>데이터 로딩 중...</span>
                      </div>
                    </td>
                  </tr>
                ) : errorMsg ? (
                  <tr>
                    <td colSpan={8} className="text-center py-24 text-rose-400">
                      <div className="flex flex-col items-center gap-2">
                        <AlertCircle className="w-6 h-6 text-rose-400" />
                        <span>데이터 조회 중 오류가 발생했습니다: {errorMsg}</span>
                        <button
                          type="button"
                          onClick={fetchReports}
                          className="px-3 py-1 bg-slate-800 hover:bg-slate-700 text-xs text-white rounded-lg border border-slate-700 cursor-pointer"
                        >
                          다시 시도
                        </button>
                      </div>
                    </td>
                  </tr>
                ) : reports.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="text-center py-24 text-slate-500">
                      일치하는 보고서 데이터가 없습니다. 필터 조건을 변경해 보세요.
                    </td>
                  </tr>
                ) : (
                  reports.map((report) => {
                    const isDeath = report.event_type === "Death";
                    const isInjury = report.event_type === "Injury";
                    const isSaved = !!bookmarksMap[report.report_number];
                    const isSelected = isDetailOpen && activeDetailNumber === report.report_number;
                    const hazardInfo = hazardStatusMap[report.report_number];

                    return (
                      <tr
                        key={report.report_number}
                        onClick={() => handleOpenDetail(report.report_number)}
                        className={`cursor-pointer transition group ${
                          isSelected
                            ? "bg-indigo-950/60 border-l-4 border-indigo-500 text-white"
                            : "hover:bg-slate-800/50"
                        }`}
                      >
                        {/* Row Selection Checkbox for AI Hazard */}
                        <td
                          className="py-2.5 px-2 text-center cursor-pointer"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleToggleSelectRow(report.report_number);
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={selectedReportNumbers.includes(report.report_number)}
                            onChange={() => {}}
                            className="rounded bg-slate-900 border-slate-700 text-indigo-500 focus:ring-0 cursor-pointer pointer-events-none"
                          />
                        </td>

                        {/* Bookmark Button */}
                        <td
                          className="py-2.5 px-2 text-center"
                          onClick={(e) => {
                            e.stopPropagation();
                            setBookmarkTarget(report);
                          }}
                        >
                          <button
                            type="button"
                            className={`p-1 rounded-lg transition hover:scale-110 ${
                              isSaved
                                ? "text-amber-400 hover:text-amber-300"
                                : "text-slate-600 hover:text-slate-400 group-hover:text-slate-500"
                            }`}
                            title={isSaved ? "보관함에 저장됨 (수정)" : "보관함에 저장"}
                          >
                            <Star className={`w-3.5 h-3.5 ${isSaved ? "fill-amber-400" : ""}`} />
                          </button>
                        </td>

                        {/* Report Number with Hazard Status Badge */}
                        <td
                          className={`py-2.5 px-3 font-mono text-xs font-medium ${
                            isSelected ? "text-indigo-300 font-bold" : "text-indigo-400 group-hover:text-indigo-300"
                          }`}
                        >
                          <div className="flex items-center gap-1.5 flex-wrap">
                            <span>{report.report_number}</span>
                            {hazardInfo?.has_hazard && (
                              <span
                                className={`inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[9px] font-bold border ${
                                  hazardInfo.hazard_status === "검토완료"
                                    ? "bg-emerald-950/80 text-emerald-300 border-emerald-600/50"
                                    : "bg-rose-950/80 text-rose-300 border-rose-700/60"
                                }`}
                                title={`ISO 14971 위해 분석됨 (${hazardInfo.hazard_count}개 요인, 상태: ${hazardInfo.hazard_status})`}
                              >
                                <ShieldAlert className="w-2.5 h-2.5" />
                                <span>{hazardInfo.hazard_status}</span>
                              </span>
                            )}
                          </div>
                        </td>

                        {/* Brand Name */}
                        <td className="py-2.5 px-3 font-semibold text-white truncate max-w-[140px]">
                          <div className="truncate">{report.brand_name || "-"}</div>
                          <div className="text-[10px] text-slate-500 font-normal truncate">
                            {report.device_category}
                          </div>
                        </td>

                        {/* Event Type */}
                        <td className="py-2.5 px-2 text-center">
                          <span
                            className={`inline-block px-1.5 py-0.5 text-[10px] font-bold rounded uppercase tracking-wider ${
                              isDeath
                                ? "bg-rose-500/20 text-rose-300 border border-rose-500/30"
                                : isInjury
                                ? "bg-amber-500/20 text-amber-300 border border-amber-500/30"
                                : "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                            }`}
                          >
                            {report.event_type}
                          </span>
                        </td>

                        {/* Content Status */}
                        <td className="py-2.5 px-2 text-center">
                          {report.has_narrative ? (
                            <span
                              className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 shadow-sm"
                              title="영어 원문 내러티브 등록됨"
                            >
                              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                              O (원문)
                            </span>
                          ) : (
                            <span
                              className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9px] font-bold bg-slate-800/80 text-slate-400 border border-slate-700"
                              title="영어 원문 서술 내용 없음"
                            >
                              <span className="w-1.5 h-1.5 rounded-full bg-slate-500"></span>
                              X (코드)
                            </span>
                          )}
                        </td>

                        {/* Date Received */}
                        <td className="py-2.5 px-3 text-center text-slate-400 font-mono text-[11px] whitespace-nowrap">
                          {report.date_received || "-"}
                        </td>

                        {/* Summary / Complaint */}
                        <td className="py-2.5 px-3 text-slate-300">
                          <div className="line-clamp-2 leading-relaxed text-[11px]">
                            {report.summary_complaint_kr ||
                              report.patient_problems ||
                              report.product_problems ||
                              "-"}
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Footer Pagination */}
          <div className="px-4 py-2.5 border-t border-slate-800 bg-slate-950/80 flex items-center justify-between text-xs text-slate-400 shrink-0">
            <div>
              <span>
                총 <strong>{total.toLocaleString()}</strong>건 중{" "}
                {reports.length > 0 ? (
                  <>
                    <strong>{(page - 1) * pageSize + 1}</strong> -{" "}
                    <strong>{Math.min(page * pageSize, total)}</strong>건
                  </>
                ) : (
                  "0건"
                )}
              </span>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                onClick={() => setPage(Math.max(1, page - 1))}
                disabled={page <= 1}
                className="p-1.5 rounded-lg border border-slate-800 hover:bg-slate-800 disabled:opacity-40 transition"
              >
                <ChevronLeft className="w-3.5 h-3.5" />
              </button>
              <span className="font-mono px-2 text-[11px]">
                {page} / {Math.max(1, totalPages)}
              </span>
              <button
                onClick={() => setPage(Math.min(totalPages, page + 1))}
                disabled={page >= totalPages}
                className="p-1.5 rounded-lg border border-slate-800 hover:bg-slate-800 disabled:opacity-40 transition"
              >
                <ChevronRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Bookmark Save/Edit Modal */}
      {bookmarkTarget && (
        <BookmarkModal
          isOpen={true}
          onClose={() => setBookmarkTarget(null)}
          reportNumber={bookmarkTarget.report_number}
          brandName={bookmarkTarget.brand_name}
          eventType={bookmarkTarget.event_type}
          onSaved={() => {
            loadBookmarksData();
            setBookmarkTarget(null);
          }}
        />
      )}
    </div>
  );
};
