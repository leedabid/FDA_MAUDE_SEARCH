import React, { useState, useEffect } from "react";
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
} from "lucide-react";
import type { FilterState, ReportItem, ReportDetail, BookmarkItem } from "../../types";
import { queryReports, getReportDetail, getBookmarks } from "../../api/client";
import { BookmarkModal } from "../modals/BookmarkModal";

interface ReportsTabProps {
  filters: FilterState;
  selectedReportNumber?: string | null;
  onClearSelectedReport?: () => void;
}

export const ReportsTab: React.FC<ReportsTabProps> = ({
  filters,
  selectedReportNumber,
  onClearSelectedReport,
}) => {
  const [reports, setReports] = useState<ReportItem[]>([]);
  const [total, setTotal] = useState<number>(0);
  const [page, setPage] = useState<number>(1);
  const [pageSize, setPageSize] = useState<number>(50);
  const [sortBy, setSortBy] = useState<string>("date_received");
  const [sortDesc, setSortDesc] = useState<boolean>(true);
  const [loading, setLoading] = useState<boolean>(false);

  // Detail Drawer
  const [activeDetailNumber, setActiveDetailNumber] = useState<string | null>(null);
  const [detail, setDetail] = useState<ReportDetail | null>(null);
  const [loadingDetail, setLoadingDetail] = useState<boolean>(false);
  const [copiedJson, setCopiedJson] = useState<boolean>(false);

  // Bookmarks
  const [bookmarksMap, setBookmarksMap] = useState<Record<string, BookmarkItem>>({});
  const [bookmarkTarget, setBookmarkTarget] = useState<ReportItem | null>(null);

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

  const fetchReports = async () => {
    setLoading(true);
    try {
      const data = await queryReports(filters, page, pageSize, sortBy, sortDesc);
      setReports(data.items || []);
      setTotal(data.total || 0);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReports();
  }, [filters, page, pageSize, sortBy, sortDesc]);

  // Handle selected report triggered externally
  useEffect(() => {
    if (selectedReportNumber) {
      handleOpenDetail(selectedReportNumber);
    }
  }, [selectedReportNumber]);

  const handleOpenDetail = async (reportNumber: string) => {
    setActiveDetailNumber(reportNumber);
    setLoadingDetail(true);
    try {
      const data = await getReportDetail(reportNumber);
      setDetail(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleCloseDetail = () => {
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

  const totalPages = Math.ceil(total / pageSize);

  // FDA Official Webpage link for this report
  const fdaOfficialUrl = detail?.mdr_report_key
    ? `https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfmaude/detail.cfm?mdrfoi__id=${detail.mdr_report_key}`
    : detail?.report_number
    ? `https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfmaude/results.cfm?start_search=1&searchnumber=${encodeURIComponent(detail.report_number)}`
    : null;

  return (
    <div className="space-y-4 animate-fadeIn">
      {/* Top Action Bar */}
      <div className="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl backdrop-blur-md flex flex-wrap items-center justify-between gap-4 shadow-xl">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 rounded-xl">
            <FileText className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white flex items-center gap-2">
              전체 MDR 부작용 보고서 목록
            </h2>
            <p className="text-xs text-slate-400">
              전체 <strong>{total.toLocaleString()}</strong>건 중 현재 페이지{" "}
              {reports.length > 0 ? `${(page - 1) * pageSize + 1} - ${Math.min(page * pageSize, total)}건` : "0건"} 표시
            </p>
          </div>
        </div>

        {/* Page Size Selector */}
        <div className="flex items-center gap-2 text-xs text-slate-400">
          <span>페이지당 건수:</span>
          <select
            value={pageSize}
            onChange={(e) => {
              setPageSize(Number(e.target.value));
              setPage(1);
            }}
            className="bg-slate-950 border border-slate-800 rounded-lg px-2.5 py-1 text-white text-xs focus:outline-none focus:border-indigo-500"
          >
            <option value={20}>20건</option>
            <option value={50}>50건</option>
            <option value={100}>100건</option>
            <option value={200}>200건</option>
          </select>
        </div>
      </div>

      {/* Main Table Card */}
      <div className="bg-slate-900/60 border border-slate-800 rounded-2xl backdrop-blur-md overflow-hidden shadow-xl flex flex-col">
        <div className="overflow-x-auto custom-scrollbar">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-800 text-slate-400 font-medium bg-slate-950/60">
                <th className="py-3 px-3 text-center w-10">
                  <Bookmark className="w-3.5 h-3.5 mx-auto text-amber-400" />
                </th>
                <th
                  onClick={() => handleSort("report_number")}
                  className="py-3 px-4 cursor-pointer hover:text-white transition w-36"
                >
                  <div className="flex items-center gap-1">
                    <span>MDR 번호</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-500" />
                  </div>
                </th>
                <th
                  onClick={() => handleSort("brand_name")}
                  className="py-3 px-4 cursor-pointer hover:text-white transition w-48"
                >
                  <div className="flex items-center gap-1">
                    <span>제품명 (Brand)</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-500" />
                  </div>
                </th>
                <th
                  onClick={() => handleSort("event_type")}
                  className="py-3 px-3 cursor-pointer hover:text-white transition w-28 text-center"
                >
                  <div className="flex items-center justify-center gap-1">
                    <span>부작용 유형</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-500" />
                  </div>
                </th>
                <th className="py-3 px-3 text-center w-24">내용유무</th>
                <th
                  onClick={() => handleSort("date_received")}
                  className="py-3 px-4 cursor-pointer hover:text-white transition w-28 text-center"
                >
                  <div className="flex items-center justify-center gap-1">
                    <span>접수 일자</span>
                    <ArrowUpDown className="w-3 h-3 text-slate-500" />
                  </div>
                </th>
                <th className="py-3 px-4">불만/증상 요약 (FDA Narrative Summary)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60 text-slate-300">
              {loading ? (
                <tr>
                  <td colSpan={7} className="text-center py-20 text-slate-500">
                    <div className="flex flex-col items-center gap-2">
                      <div className="w-6 h-6 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
                      <span>데이터 로딩 중...</span>
                    </div>
                  </td>
                </tr>
              ) : reports.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-20 text-slate-500">
                    일치하는 보고서 데이터가 없습니다. 필터 조건을 변경해 보세요.
                  </td>
                </tr>
              ) : (
                reports.map((report) => {
                  const isDeath = report.event_type === "Death";
                  const isInjury = report.event_type === "Injury";
                  const isSaved = !!bookmarksMap[report.report_number];

                  return (
                    <tr
                      key={report.report_number}
                      onClick={() => handleOpenDetail(report.report_number)}
                      className="hover:bg-slate-800/50 cursor-pointer transition group"
                    >
                      {/* Star Bookmark button */}
                      <td
                        className="py-3 px-3 text-center"
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
                          <Star className={`w-4 h-4 ${isSaved ? "fill-amber-400" : ""}`} />
                        </button>
                      </td>

                      <td className="py-3 px-4 font-mono font-medium text-indigo-400 group-hover:text-indigo-300">
                        {report.report_number}
                      </td>
                      <td className="py-3 px-4 font-semibold text-white truncate max-w-[180px]">
                        <div>{report.brand_name || "-"}</div>
                        <div className="text-[10px] text-slate-500 font-normal">
                          {report.device_category}
                        </div>
                      </td>
                      <td className="py-3 px-3 text-center">
                        <span
                          className={`inline-block px-2 py-0.5 text-[11px] font-bold rounded-md uppercase tracking-wider ${
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
                      <td className="py-3 px-3 text-center">
                        {report.has_narrative ? (
                          <span
                            className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 shadow-sm"
                            title="영어 원문 내러티브(환자 서술 또는 제조사 분석 서술)가 등록되어 있습니다."
                          >
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                            O (있음)
                          </span>
                        ) : (
                          <span
                            className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-slate-800/80 text-slate-400 border border-slate-700"
                            title="영어 원문 서술 내용(내러티브)이 없는 보고서입니다."
                          >
                            <span className="w-1.5 h-1.5 rounded-full bg-slate-500"></span>
                            X (없음)
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4 text-center text-slate-400 font-mono text-[11px]">
                        {report.date_received || "-"}
                      </td>
                      <td className="py-3 px-4 text-slate-300">
                        <div className="line-clamp-2 leading-relaxed">
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
        <div className="px-6 py-3 border-t border-slate-800 bg-slate-950/60 flex items-center justify-between text-xs text-slate-400">
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

          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage(Math.max(1, page - 1))}
              disabled={page <= 1}
              className="p-1.5 rounded-lg border border-slate-800 hover:bg-slate-800 disabled:opacity-40 transition"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="font-mono px-2">
              {page} / {Math.max(1, totalPages)}
            </span>
            <button
              onClick={() => setPage(Math.min(totalPages, page + 1))}
              disabled={page >= totalPages}
              className="p-1.5 rounded-lg border border-slate-800 hover:bg-slate-800 disabled:opacity-40 transition"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Detail Slide Drawer Modal */}
      {activeDetailNumber && (
        <div className="fixed inset-0 z-50 flex justify-end bg-slate-950/80 backdrop-blur-sm animate-fadeIn">
          <div className="w-full max-w-2xl bg-slate-900 border-l border-slate-700 h-full flex flex-col shadow-2xl overflow-hidden text-slate-200">
            {/* Drawer Header */}
            <div className="p-5 border-b border-slate-800 bg-slate-950/80 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-indigo-500/20 text-indigo-400 rounded-xl border border-indigo-500/30">
                  <FileText className="w-5 h-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-base font-bold text-white font-mono">
                      {activeDetailNumber}
                    </h3>
                    {detail && (
                      <span
                        className={`px-2 py-0.5 text-[10px] font-bold rounded uppercase ${
                          detail.event_type === "Death"
                            ? "bg-rose-500/20 text-rose-300"
                            : detail.event_type === "Injury"
                            ? "bg-amber-500/20 text-amber-300"
                            : "bg-blue-500/20 text-blue-300"
                        }`}
                      >
                        {detail.event_type}
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-slate-400">{detail?.brand_name || "MDR Report Detail"}</p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                {/* FDA Official Webpage Direct Link */}
                {fdaOfficialUrl && (
                  <a
                    href={fdaOfficialUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 rounded-xl transition"
                    title="FDA 공식 MAUDE 웹사이트 원문 페이지 새창 열기"
                  >
                    <Globe className="w-3.5 h-3.5" />
                    <span>FDA 웹 원문 ↗</span>
                  </a>
                )}

                {/* Bookmark trigger */}
                <button
                  onClick={() => detail && setBookmarkTarget(detail)}
                  className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 border border-amber-500/30 rounded-xl transition"
                >
                  <Star className={`w-3.5 h-3.5 ${bookmarksMap[activeDetailNumber] ? "fill-amber-400" : ""}`} />
                  {bookmarksMap[activeDetailNumber] ? "보관함 수정" : "보관함 저장"}
                </button>

                <button
                  onClick={handleCloseDetail}
                  className="p-2 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Drawer Body */}
            <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar text-xs">
              {loadingDetail ? (
                <div className="flex items-center justify-center h-64 text-slate-400">
                  보고서 상세 정보 로딩 중...
                </div>
              ) : detail ? (
                <>
                  {/* Bookmark details if saved */}
                  {bookmarksMap[activeDetailNumber] && (
                    <div className="p-3.5 bg-amber-500/10 border border-amber-500/20 rounded-2xl space-y-2">
                      <div className="flex items-center justify-between text-xs text-amber-300 font-semibold">
                        <span className="flex items-center gap-1.5">
                          <Folder className="w-3.5 h-3.5" />
                          저장된 폴더: {bookmarksMap[activeDetailNumber].folder}
                        </span>
                        <span className="text-[11px] text-amber-400/80">
                          {bookmarksMap[activeDetailNumber].saved_at}
                        </span>
                      </div>
                      {bookmarksMap[activeDetailNumber].tags?.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {bookmarksMap[activeDetailNumber].tags.map((tag) => (
                            <span
                              key={tag}
                              className="px-2 py-0.5 bg-amber-500/20 text-amber-300 text-[10px] rounded-md flex items-center gap-1 font-mono"
                            >
                              <Tag className="w-2.5 h-2.5" />
                              {tag}
                            </span>
                          ))}
                        </div>
                      )}
                      {bookmarksMap[activeDetailNumber].note && (
                        <p className="text-slate-300 text-xs italic bg-slate-900/60 p-2.5 rounded-xl border border-slate-800/80">
                          "{bookmarksMap[activeDetailNumber].note}"
                        </p>
                      )}
                    </div>
                  )}

                  {/* Metadata Grid */}
                  <div className="grid grid-cols-2 gap-3 p-4 bg-slate-950/60 border border-slate-800 rounded-xl">
                    <div>
                      <span className="text-slate-500 block text-[11px]">제품명</span>
                      <span className="font-semibold text-white">{detail.brand_name || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[11px]">제조사</span>
                      <span className="font-semibold text-white">{detail.manufacturer_name || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[11px]">접수 일자</span>
                      <span className="font-mono text-slate-300">{detail.date_received || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[11px]">사건 발생일</span>
                      <span className="font-mono text-slate-300">{detail.date_of_event || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[11px]">MDR Report Key</span>
                      <span className="font-mono text-slate-300">{detail.mdr_report_key || "-"}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block text-[11px]">보고 출처 (Source)</span>
                      <span className="text-slate-300">{detail.device_category || "Voluntary / Manufacturer"}</span>
                    </div>
                  </div>

                  {/* AI & Rule Based Korean Narratives Summary */}
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-indigo-400 font-bold text-xs uppercase tracking-wider">
                      <Sparkles className="w-4 h-4" />
                      <span>3단계 핵심 내용 요약 (Summary)</span>
                    </div>

                    <div className="space-y-2">
                      <div className="p-3.5 bg-slate-950/80 border border-slate-800 rounded-xl space-y-1">
                        <span className="text-[11px] font-semibold text-indigo-300">
                          1. 소비자/환자 불만 및 사건 내용 (Complaint)
                        </span>
                        <p className="text-slate-300 leading-relaxed">
                          {detail.summary_complaint_kr || "불만사항 정보가 없습니다."}
                        </p>
                      </div>

                      <div className="p-3.5 bg-slate-950/80 border border-slate-800 rounded-xl space-y-1">
                        <span className="text-[11px] font-semibold text-amber-300">
                          2. 제조사 조사 및 대응 내용 (Response)
                        </span>
                        <p className="text-slate-300 leading-relaxed">
                          {detail.summary_response_kr || "제조사 대응 정보가 없습니다."}
                        </p>
                      </div>

                      <div className="p-3.5 bg-slate-950/80 border border-slate-800 rounded-xl space-y-1">
                        <span className="text-[11px] font-semibold text-emerald-300">
                          3. 종합 결론 (Conclusion)
                        </span>
                        <p className="text-slate-300 leading-relaxed">
                          {detail.summary_conclusion_kr || "종합 결론 정보가 없습니다."}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* FDA Standard Codes (Annex A & Annex E) */}
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-slate-300 font-bold text-xs uppercase tracking-wider">
                      <Stethoscope className="w-4 h-4 text-emerald-400" />
                      <span>FDA IMDRF 표준 문제 코드 (Annex Mappings)</span>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      {/* Annex E: Patient Problems */}
                      <div className="p-3.5 bg-slate-950/60 border border-slate-800 rounded-xl space-y-2">
                        <span className="text-[11px] font-semibold text-emerald-400 block">
                          Annex E (환자 증상 코드)
                        </span>
                        {detail.patient_problem_list && detail.patient_problem_list.length > 0 ? (
                          <div className="space-y-1.5">
                            {detail.patient_problem_list.map((p, idx) => (
                              <div
                                key={idx}
                                className="flex items-center justify-between bg-slate-900 p-2 rounded-lg border border-slate-800"
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

                      {/* Annex A: Device Problems */}
                      <div className="p-3.5 bg-slate-950/60 border border-slate-800 rounded-xl space-y-2">
                        <span className="text-[11px] font-semibold text-blue-400 block">
                          Annex A (기기 결함 코드)
                        </span>
                        {detail.product_problem_list && detail.product_problem_list.length > 0 ? (
                          <div className="space-y-1.5">
                            {detail.product_problem_list.map((p, idx) => (
                              <div
                                key={idx}
                                className="flex items-center justify-between bg-slate-900 p-2 rounded-lg border border-slate-800"
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

                  {/* English Narratives */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2 text-slate-300 font-bold text-xs uppercase tracking-wider">
                        <Layers className="w-4 h-4 text-indigo-400" />
                        <span>영어 원문 내러티브 (English Narratives)</span>
                      </div>
                      {fdaOfficialUrl && (
                        <a
                          href={fdaOfficialUrl}
                          target="_blank"
                          rel="noreferrer"
                          className="text-[11px] text-indigo-400 hover:text-indigo-300 flex items-center gap-1 transition"
                        >
                          <span>FDA 공식 웹페이지에서 보기</span>
                          <ExternalLink className="w-3 h-3" />
                        </a>
                      )}
                    </div>

                    {/* 1. Event Description */}
                    {detail.event_description && (
                      <div className="p-3.5 bg-slate-950/70 border border-slate-800 rounded-xl space-y-1.5 shadow-inner">
                        <div className="flex items-center justify-between">
                          <span className="text-[11px] font-semibold text-indigo-400 flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-indigo-400"></span>
                            Event Description (사건/불만 설명)
                          </span>
                        </div>
                        <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                          {detail.event_description}
                        </p>
                      </div>
                    )}

                    {/* 2. Manufacturer Narrative */}
                    {detail.manufacturer_narrative && (
                      <div className="p-3.5 bg-slate-950/70 border border-slate-800 rounded-xl space-y-1.5 shadow-inner">
                        <div className="flex items-center justify-between">
                          <span className="text-[11px] font-semibold text-amber-400 flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
                            Manufacturer Narrative (제조사 1차 분석 및 대응)
                          </span>
                        </div>
                        <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                          {detail.manufacturer_narrative}
                        </p>
                      </div>
                    )}

                    {/* 3. Additional Manufacturer Narrative */}
                    {detail.additional_manufacturer_narrative && (
                      <div className="p-3.5 bg-slate-950/70 border border-slate-800 rounded-xl space-y-1.5 shadow-inner">
                        <div className="flex items-center justify-between">
                          <span className="text-[11px] font-semibold text-emerald-400 flex items-center gap-1.5">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                            Additional Manufacturer Narrative (제조사 추가/후속 조사 결과)
                          </span>
                        </div>
                        <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                          {detail.additional_manufacturer_narrative}
                        </p>
                      </div>
                    )}

                    {/* Fallback to raw_json mdr_text list if individual narrative fields were empty */}
                    {!detail.event_description &&
                      !detail.manufacturer_narrative &&
                      !detail.additional_manufacturer_narrative &&
                      detail.raw_json?.mdr_text &&
                      Array.isArray(detail.raw_json.mdr_text) &&
                      detail.raw_json.mdr_text.length > 0 && (
                        <div className="space-y-2.5">
                          {detail.raw_json.mdr_text.map((txtItem: any, idx: number) => (
                            <div
                              key={idx}
                              className="p-3.5 bg-slate-950/70 border border-slate-800 rounded-xl space-y-1.5 shadow-inner"
                            >
                              <div className="flex items-center justify-between">
                                <span className="text-[11px] font-semibold text-indigo-300 flex items-center gap-1.5">
                                  <span className="w-1.5 h-1.5 rounded-full bg-indigo-400"></span>
                                  {txtItem.text_type_code || `Narrative #${idx + 1}`}
                                </span>
                                {txtItem.patient_sequence_number && (
                                  <span className="text-[10px] text-slate-500">
                                    Patient Seq: {txtItem.patient_sequence_number}
                                  </span>
                                )}
                              </div>
                              <p className="text-slate-200 leading-relaxed font-sans text-xs whitespace-pre-wrap">
                                {txtItem.text}
                              </p>
                            </div>
                          ))}
                        </div>
                      )}

                    {/* No narrative in openFDA API note + FDA official link */}
                    {!detail.event_description &&
                      !detail.manufacturer_narrative &&
                      !detail.additional_manufacturer_narrative &&
                      (!detail.raw_json?.mdr_text || detail.raw_json.mdr_text.length === 0) && (
                        <div className="p-4 bg-slate-950/70 border border-slate-800 rounded-xl space-y-2 text-xs">
                          <div className="flex items-center gap-2 text-amber-400 font-semibold">
                            <AlertCircle className="w-4 h-4 shrink-0" />
                            <span>openFDA 공개 API 텍스트 미제공 안내</span>
                          </div>
                          <p className="text-slate-400 leading-relaxed text-[11px]">
                            본 보고서는 MedWatch 자발적 소비자 보고(MW 번호)로, openFDA의 공개 JSON 데이터셋(API) 상에는 텍스트 필드가 비어 있는 상태(<code className="bg-slate-900 text-slate-300 px-1 py-0.5 rounded font-mono">mdr_text: []</code>)로 제공되었습니다.
                          </p>
                          {fdaOfficialUrl && (
                            <a
                              href={fdaOfficialUrl}
                              target="_blank"
                              rel="noreferrer"
                              className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-bold text-xs transition shadow-md mt-1"
                            >
                              <Globe className="w-3.5 h-3.5" />
                              <span>FDA 공식 MAUDE 웹페이지에서 원문 확인하기 ↗</span>
                            </a>
                          )}
                        </div>
                      )}
                  </div>

                  {/* Raw JSON viewer */}
                  {detail.raw_json && (
                    <div className="space-y-2 pt-2 border-t border-slate-800">
                      <div className="flex items-center justify-between">
                        <span className="text-slate-400 font-semibold text-xs">
                          FDA MAUDE Raw JSON (OpenFDA API 원본)
                        </span>
                        <button
                          onClick={handleCopyJson}
                          className="flex items-center gap-1 text-[11px] text-indigo-400 hover:text-indigo-300 transition"
                        >
                          {copiedJson ? (
                            <>
                              <Check className="w-3.5 h-3.5 text-emerald-400" />
                              <span className="text-emerald-400">복사 완료!</span>
                            </>
                          ) : (
                            <>
                              <Copy className="w-3.5 h-3.5" />
                              <span>JSON 복사</span>
                            </>
                          )}
                        </button>
                      </div>
                      <pre className="p-3.5 bg-slate-950 border border-slate-800 rounded-xl font-mono text-[10px] text-slate-400 overflow-x-auto max-h-60 custom-scrollbar">
                        {JSON.stringify(detail.raw_json, null, 2)}
                      </pre>
                    </div>
                  )}
                </>
              ) : (
                <div className="flex items-center justify-center h-64 text-slate-500">
                  보고서를 찾을 수 없습니다.
                </div>
              )}
            </div>
          </div>
        </div>
      )}

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
