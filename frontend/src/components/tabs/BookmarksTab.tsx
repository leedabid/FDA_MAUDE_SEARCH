import React, { useState, useEffect } from "react";
import {
  Folder,
  Tag,
  Star,
  Trash2,
  Edit3,
  Search,
  Download,
  AlertCircle,
  FileText,
  Eye,
  Calendar,
  Layers,
} from "lucide-react";
import { getBookmarks, getBookmarkedReports } from "../../api/client";
import type { BookmarkItem, ReportItem, ReportDetail } from "../../types";
import { BookmarkModal } from "../modals/BookmarkModal";
import { getReportDetail } from "../../api/client";

interface BookmarksTabProps {
  onOpenReportDetail: (reportNumber: string) => void;
}

export const BookmarksTab: React.FC<BookmarksTabProps> = ({ onOpenReportDetail }) => {
  const [folders, setFolders] = useState<string[]>([]);
  const [selectedFolder, setSelectedFolder] = useState<string>("ALL");
  const [selectedTag, setSelectedTag] = useState<string>("ALL");
  const [allTags, setAllTags] = useState<string[]>([]);
  const [reports, setReports] = useState<ReportItem[]>([]);
  const [bookmarksMap, setBookmarksMap] = useState<Record<string, BookmarkItem>>({});
  const [loading, setLoading] = useState<boolean>(false);
  const [searchQuery, setSearchQuery] = useState<string>("");

  // Edit modal state
  const [editTarget, setEditTarget] = useState<string | null>(null);

  const loadData = async () => {
    setLoading(true);
    try {
      const bdata = await getBookmarks();
      setFolders(bdata.folders || []);
      
      // Extract unique tags
      const tagSet = new Set<string>();
      Object.values(bdata.bookmarks || {}).forEach((b) => {
        (b.tags || []).forEach((t) => tagSet.add(t));
      });
      setAllTags(Array.from(tagSet));

      // Fetch reports
      const repData = await getBookmarkedReports(
        selectedFolder === "ALL" ? undefined : selectedFolder,
        selectedTag === "ALL" ? undefined : selectedTag,
        1,
        200
      );
      setReports(repData.items || []);
      setBookmarksMap(repData.bookmarks || {});
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [selectedFolder, selectedTag]);

  // Client search filter
  const filteredReports = reports.filter((r) => {
    if (!searchQuery) return true;
    const q = searchQuery.toLowerCase();
    const binfo = bookmarksMap[r.report_number];
    return (
      r.report_number.toLowerCase().includes(q) ||
      (r.brand_name && r.brand_name.toLowerCase().includes(q)) ||
      (binfo?.note && binfo.note.toLowerCase().includes(q)) ||
      (binfo?.tags && binfo.tags.some((t) => t.toLowerCase().includes(q)))
    );
  });

  const handleExportCSV = () => {
    if (filteredReports.length === 0) {
      alert("내보낼 데이터가 없습니다.");
      return;
    }
    const headers = [
      "Report Number",
      "Brand Name",
      "Event Type",
      "Date Received",
      "Folder",
      "Tags",
      "Memo / Notes",
      "Summary Complaint",
    ];
    const rows = filteredReports.map((r) => {
      const b = bookmarksMap[r.report_number];
      return [
        `"${r.report_number}"`,
        `"${r.brand_name || ""}"`,
        `"${r.event_type || ""}"`,
        `"${r.date_received || ""}"`,
        `"${b?.folder || ""}"`,
        `"${(b?.tags || []).join(", ")}"`,
        `"${(b?.note || "").replace(/"/g, '""')}"`,
        `"${(r.summary_complaint_kr || "").replace(/"/g, '""')}"`,
      ];
    });

    const csvContent = "\uFEFF" + [headers.join(","), ...rows.map((row) => row.join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `MAUDE_Bookmarks_${selectedFolder}_${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="flex h-full gap-6 animate-fadeIn">
      {/* Left Sidebar: Folders & Tags */}
      <div className="w-72 flex flex-col gap-5 bg-slate-900/60 border border-slate-800 rounded-2xl p-4 shrink-0">
        {/* Folders Section */}
        <div>
          <div className="flex items-center justify-between mb-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
            <span className="flex items-center gap-1.5">
              <Folder className="w-3.5 h-3.5 text-indigo-400" />
              보관 폴더 ({folders.length})
            </span>
          </div>

          <div className="space-y-1">
            <button
              onClick={() => {
                setSelectedFolder("ALL");
                setSelectedTag("ALL");
              }}
              className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs transition ${
                selectedFolder === "ALL" && selectedTag === "ALL"
                  ? "bg-indigo-600 text-white font-semibold shadow-md shadow-indigo-600/20"
                  : "text-slate-300 hover:bg-slate-800/60"
              }`}
            >
              <span>📁 전체 보관함</span>
              <span className="text-[10px] bg-slate-800/80 px-2 py-0.5 rounded-full">
                {Object.keys(bookmarksMap).length}
              </span>
            </button>

            {folders.map((f) => {
              const isSelected = selectedFolder === f;
              const count = Object.values(bookmarksMap).filter((b) => b.folder === f).length;
              return (
                <button
                  key={f}
                  onClick={() => {
                    setSelectedFolder(f);
                    setSelectedTag("ALL");
                  }}
                  className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs transition ${
                    isSelected
                      ? "bg-indigo-600/20 border border-indigo-500/50 text-indigo-300 font-semibold"
                      : "text-slate-300 hover:bg-slate-800/60"
                  }`}
                >
                  <span className="truncate pr-2">📁 {f}</span>
                  <span className="text-[10px] text-slate-400">{count}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Tags Section */}
        <div className="pt-4 border-t border-slate-800 flex-1 flex flex-col overflow-hidden">
          <div className="flex items-center justify-between mb-3 text-xs font-semibold text-slate-400 uppercase tracking-wider">
            <span className="flex items-center gap-1.5">
              <Tag className="w-3.5 h-3.5 text-emerald-400" />
              태그 필터 ({allTags.length})
            </span>
          </div>

          <div className="flex-1 overflow-y-auto space-y-1 pr-1 custom-scrollbar">
            {allTags.length === 0 ? (
              <div className="text-[11px] text-slate-500 py-2">등록된 태그가 없습니다.</div>
            ) : (
              allTags.map((t) => {
                const isSelected = selectedTag === t;
                const count = Object.values(bookmarksMap).filter((b) => (b.tags || []).includes(t)).length;
                return (
                  <button
                    key={t}
                    onClick={() => setSelectedTag(isSelected ? "ALL" : t)}
                    className={`w-full flex items-center justify-between px-3 py-1.5 rounded-lg text-xs transition ${
                      isSelected
                        ? "bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 font-medium"
                        : "text-slate-400 hover:bg-slate-800/40 hover:text-slate-200"
                    }`}
                  >
                    <span className="truncate">#{t}</span>
                    <span className="text-[10px] text-slate-500">{count}</span>
                  </button>
                );
              })
            )}
          </div>
        </div>
      </div>

      {/* Right Content Area: Saved Reports Table */}
      <div className="flex-1 flex flex-col bg-slate-900/60 border border-slate-800 rounded-2xl overflow-hidden">
        {/* Top Filter Bar */}
        <div className="p-4 border-b border-slate-800 bg-slate-950/40 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-amber-500/10 text-amber-400 border border-amber-500/20 rounded-xl">
              <Star className="w-5 h-5 fill-amber-400" />
            </div>
            <div>
              <h2 className="text-sm font-bold text-white flex items-center gap-2">
                {selectedFolder === "ALL" ? "전체 보관함" : selectedFolder}
                {selectedTag !== "ALL" && (
                  <span className="px-2 py-0.5 text-xs font-normal bg-emerald-500/20 text-emerald-300 rounded-md border border-emerald-500/30">
                    #{selectedTag}
                  </span>
                )}
              </h2>
              <p className="text-xs text-slate-400">
                총 {filteredReports.length}건의 주요 관심 보고서가 저장되어 있습니다.
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="relative w-64">
              <Search className="absolute left-3 top-2.5 w-3.5 h-3.5 text-slate-500" />
              <input
                type="text"
                placeholder="보관함 내 검색 (메모, 번호, 브랜드)..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-8 pr-3 py-1.5 text-xs bg-slate-950 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white placeholder-slate-500"
              />
            </div>
            <button
              onClick={handleExportCSV}
              className="flex items-center gap-1.5 px-3.5 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-xl text-xs font-medium border border-slate-700 transition"
            >
              <Download className="w-3.5 h-3.5" />
              CSV 내보내기
            </button>
          </div>
        </div>

        {/* Table List */}
        <div className="flex-1 overflow-y-auto custom-scrollbar">
          {loading ? (
            <div className="flex items-center justify-center h-64 text-slate-500 text-xs">
              보관함 보고서 불러오는 중...
            </div>
          ) : filteredReports.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-64 text-slate-500 text-xs gap-2">
              <AlertCircle className="w-8 h-8 text-slate-600 stroke-[1.5]" />
              <span>저장된 보고서가 없습니다.</span>
              <span className="text-[11px] text-slate-600">
                전체 보고서 탭에서 ⭐ 별 아이콘을 클릭하여 보고서를 태그 및 폴더에 저장할 수 있습니다.
              </span>
            </div>
          ) : (
            <div className="divide-y divide-slate-800/80">
              {filteredReports.map((r) => {
                const b = bookmarksMap[r.report_number];
                return (
                  <div
                    key={r.report_number}
                    className="p-4 hover:bg-slate-800/40 transition flex flex-col gap-2.5 cursor-pointer group"
                    onClick={() => onOpenReportDetail(r.report_number)}
                  >
                    {/* Top Row: Meta info */}
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-xs font-semibold text-indigo-400 group-hover:text-indigo-300">
                          {r.report_number}
                        </span>
                        <span
                          className={`px-2 py-0.5 text-[10px] font-bold rounded-md uppercase tracking-wider ${
                            r.event_type === "Death"
                              ? "bg-rose-500/20 text-rose-300 border border-rose-500/30"
                              : r.event_type === "Injury"
                              ? "bg-amber-500/20 text-amber-300 border border-amber-500/30"
                              : "bg-blue-500/20 text-blue-300 border border-blue-500/30"
                          }`}
                        >
                          {r.event_type}
                        </span>
                        <span className="text-xs font-semibold text-white">{r.brand_name}</span>
                        <span className="text-[11px] text-slate-400">({r.device_category})</span>
                      </div>

                      <div className="flex items-center gap-3">
                        <span className="text-[11px] text-slate-400 flex items-center gap-1">
                          <Calendar className="w-3 h-3 text-slate-500" />
                          {r.date_received}
                        </span>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setEditTarget(r.report_number);
                          }}
                          className="p-1 text-slate-400 hover:text-amber-400 rounded transition hover:bg-slate-800"
                          title="태그 및 메모 수정"
                        >
                          <Edit3 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </div>

                    {/* Tags & Folder Badges */}
                    <div className="flex items-center gap-2 flex-wrap text-[11px]">
                      <span className="px-2 py-0.5 bg-indigo-500/10 text-indigo-300 rounded border border-indigo-500/20 font-medium">
                        📁 {b?.folder || "기본 보관함"}
                      </span>
                      {(b?.tags || []).map((t) => (
                        <span
                          key={t}
                          className="px-2 py-0.5 bg-emerald-500/10 text-emerald-300 rounded border border-emerald-500/20 font-medium"
                        >
                          #{t}
                        </span>
                      ))}
                    </div>

                    {/* Memo & Notes */}
                    {b?.note && (
                      <div className="p-2.5 bg-slate-950/80 border border-amber-500/20 rounded-xl text-xs text-amber-200/90 flex items-start gap-2">
                        <FileText className="w-4 h-4 text-amber-400 shrink-0 mt-0.5" />
                        <span className="flex-1 whitespace-pre-wrap">{b.note}</span>
                      </div>
                    )}

                    {/* 3-Part Summary snippet */}
                    {r.summary_complaint_kr && (
                      <div className="text-xs text-slate-300 bg-slate-950/40 p-2.5 rounded-xl border border-slate-800/80 line-clamp-2">
                        <span className="font-semibold text-indigo-400">요약: </span>
                        {r.summary_complaint_kr}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Edit Bookmark Modal */}
      {editTarget && (
        <BookmarkModal
          isOpen={true}
          reportNumber={editTarget}
          brandName={reports.find((r) => r.report_number === editTarget)?.brand_name}
          eventType={reports.find((r) => r.report_number === editTarget)?.event_type}
          onClose={() => setEditTarget(null)}
          onSaved={() => {
            setEditTarget(null);
            loadData();
          }}
        />
      )}
    </div>
  );
};
