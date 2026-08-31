import React, { useState, useMemo } from "react";
import {
  Search,
  Filter,
  Calendar,
  RotateCcw,
  Tag,
  CheckSquare,
  Square,
  Layers,
  Settings,
  Info,
  Check,
  Sparkles,
  X,
  Trash2,
} from "lucide-react";
import type { FilterState, Metadata } from "../../types";
import { matchMultiWordSearch } from "../../utils/search";

interface SidebarProps {
  stagedFilters: FilterState;
  setStagedFilters: React.Dispatch<React.SetStateAction<FilterState>>;
  appliedFilters: FilterState;
  onApplyFilters: () => void;
  metadata: Metadata | null;
  onReset: () => void;
  onOpenBrandManager: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  stagedFilters,
  setStagedFilters,
  appliedFilters,
  onApplyFilters,
  metadata,
  onReset,
  onOpenBrandManager,
}) => {
  const [brandSearch, setBrandSearch] = useState("");
  const [brandViewMode, setBrandViewMode] = useState<"canonical" | "all">("canonical");

  // Check if staged filters differ from applied filters
  const hasUnappliedChanges = JSON.stringify(stagedFilters) !== JSON.stringify(appliedFilters);

  // Toggle Category
  const handleCategoryToggle = (category: string) => {
    setStagedFilters((prev) => {
      const exists = prev.categories.includes(category);
      const nextCats = exists
        ? prev.categories.filter((c) => c !== category)
        : [...prev.categories, category];

      // When category changes, prune selected brands that no longer belong to selected categories
      return {
        ...prev,
        categories: nextCats,
      };
    });
  };

  // Toggle Brand
  const handleBrandToggle = (brand: string) => {
    setStagedFilters((prev) => {
      const exists = prev.brands.includes(brand);
      return {
        ...prev,
        brands: exists ? prev.brands.filter((b) => b !== brand) : [...prev.brands, brand],
      };
    });
  };

  // Remove single selected brand
  const handleRemoveBrand = (brand: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setStagedFilters((prev) => ({
      ...prev,
      brands: prev.brands.filter((b) => b !== brand),
    }));
  };

  // Clear all selected brands
  const handleClearAllBrands = () => {
    setStagedFilters((prev) => ({
      ...prev,
      brands: [],
    }));
  };

  // 1. Separate Canonical and All Candidate lists strictly constrained by active device categories
  const canonicalCandidates = useMemo(() => {
    if (!metadata) return [];
    const activeCats = stagedFilters.categories;
    if (
      !activeCats ||
      activeCats.length === 0 ||
      activeCats.length === 2 ||
      !metadata.canonical_brands_by_category
    ) {
      return metadata.canonical_brands || [];
    }
    const list: string[] = [];
    activeCats.forEach((cat) => {
      const catList = metadata.canonical_brands_by_category?.[cat] || [];
      list.push(...catList);
    });
    return list;
  }, [metadata, stagedFilters.categories]);

  const allCandidates = useMemo(() => {
    if (!metadata) return [];
    const activeCats = stagedFilters.categories;
    if (
      !activeCats ||
      activeCats.length === 0 ||
      activeCats.length === 2 ||
      !metadata.all_brands_by_category
    ) {
      return metadata.all_brands || [];
    }
    const list: string[] = [];
    activeCats.forEach((cat) => {
      const catList = metadata.all_brands_by_category?.[cat] || [];
      list.push(...catList);
    });
    return list;
  }, [metadata, stagedFilters.categories]);

  const candidateBrands = brandViewMode === "canonical" ? canonicalCandidates : allCandidates;

  // 2. Filter candidate brands by search query (multi-word match)
  const displayedBrands = useMemo(() => {
    return candidateBrands.filter((b) => matchMultiWordSearch(b, brandSearch));
  }, [candidateBrands, brandSearch]);

  // Select/Deselect All Brands currently visible in filtered candidate list
  const handleSelectAllBrands = (select: boolean) => {
    setStagedFilters((prev) => {
      if (select) {
        const merged = Array.from(new Set([...prev.brands, ...displayedBrands]));
        return { ...prev, brands: merged };
      } else {
        const toRemove = new Set(displayedBrands);
        const filtered = prev.brands.filter((b) => !toRemove.has(b));
        return { ...prev, brands: filtered };
      }
    });
  };

  // Toggle Event Type
  const handleEventTypeToggle = (eventType: string) => {
    setStagedFilters((prev) => {
      const exists = prev.event_types.includes(eventType);
      return {
        ...prev,
        event_types: exists
          ? prev.event_types.filter((e) => e !== eventType)
          : [...prev.event_types, eventType],
      };
    });
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      onApplyFilters();
    }
  };

  return (
    <aside className="w-96 bg-slate-900/70 border-r border-slate-800 p-4 flex flex-col gap-4 overflow-y-auto custom-scrollbar shrink-0 select-none h-full">
      {/* Filter Header, Apply Button & Reset */}
      <div className="space-y-2 pb-3 border-b border-slate-800">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 text-white font-bold text-sm">
            <Filter className="w-4 h-4 text-indigo-400" />
            <span>필터 조건 (Search Filters)</span>
          </div>
          <button
            onClick={onReset}
            className="flex items-center gap-1 text-[11px] font-medium text-slate-400 hover:text-indigo-400 transition"
          >
            <RotateCcw className="w-3 h-3" />
            초기화
          </button>
        </div>

        {/* Big Apply Button */}
        <button
          type="button"
          onClick={onApplyFilters}
          className={`w-full py-2.5 px-4 rounded-xl text-xs font-bold transition flex items-center justify-center gap-2 shadow-lg ${
            hasUnappliedChanges
              ? "bg-gradient-to-r from-indigo-600 to-indigo-500 hover:from-indigo-500 hover:to-indigo-400 text-white ring-2 ring-indigo-400/50 animate-pulse"
              : "bg-indigo-600 hover:bg-indigo-500 text-white"
          }`}
        >
          <Search className="w-3.5 h-3.5" />
          <span>{hasUnappliedChanges ? "🔍 필터 검색 적용하기 (Enter)" : "🔍 검색 조건 재적용"}</span>
        </button>

        {hasUnappliedChanges && (
          <p className="text-[10px] text-amber-400 text-center font-medium">
            ● 조건이 변경되었습니다. 적용 버튼을 눌러주세요.
          </p>
        )}
      </div>

      {/* 1. Keyword Search */}
      <div className="space-y-1.5">
        <label className="text-xs font-semibold text-slate-300 flex items-center justify-between">
          <span>키워드 전문 검색 (FTS5)</span>
        </label>
        <div className="relative">
          <Search className="absolute left-3 top-2.5 w-3.5 h-3.5 text-slate-500" />
          <input
            type="text"
            placeholder="증상, 원문, 불만사항 검색 (Enter)"
            value={stagedFilters.keyword}
            onChange={(e) => setStagedFilters((prev) => ({ ...prev, keyword: e.target.value }))}
            onKeyDown={handleKeyDown}
            className="w-full pl-9 pr-3 py-2 text-xs bg-slate-950/80 border border-slate-800 rounded-xl focus:outline-none focus:border-indigo-500 text-white placeholder-slate-500 shadow-inner"
          />
        </div>
      </div>

      {/* 2. Device Category */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <label className="text-xs font-semibold text-slate-300">의료기기 카테고리</label>
          <span className="text-[10px] text-slate-500">선택 시 제품 목록 자동 연동</span>
        </div>
        <div className="grid grid-cols-2 gap-2">
          {["CGM", "Insulin Pump"].map((cat) => {
            const isSelected = stagedFilters.categories.includes(cat);
            return (
              <button
                key={cat}
                type="button"
                onClick={() => handleCategoryToggle(cat)}
                className={`flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold border transition ${
                  isSelected
                    ? "bg-indigo-600/20 border-indigo-500 text-indigo-300 shadow-sm"
                    : "bg-slate-950/50 border-slate-800 text-slate-400 hover:border-slate-700"
                }`}
              >
                <span>{cat === "CGM" ? "연속혈당 (CGM)" : "인슐린 펌프"}</span>
                {isSelected ? (
                  <CheckSquare className="w-3.5 h-3.5 text-indigo-400" />
                ) : (
                  <Square className="w-3.5 h-3.5 text-slate-600" />
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* 3. Event Type Filter */}
      <div className="space-y-2">
        <label className="text-xs font-semibold text-slate-300">부작용 유형 (Event Type)</label>
        <div className="grid grid-cols-2 gap-1.5">
          {[
            { id: "Death", label: "사망 (Death)" },
            { id: "Injury", label: "상해 (Injury)" },
            { id: "Malfunction", label: "오작동 (Malfunction)" },
            { id: "Other", label: "기타 (Other)" },
          ].map((type) => {
            const isSelected = stagedFilters.event_types.includes(type.id);
            return (
              <button
                key={type.id}
                type="button"
                onClick={() => handleEventTypeToggle(type.id)}
                className={`flex items-center justify-between px-2.5 py-1.5 rounded-lg text-xs font-medium border transition ${
                  isSelected
                    ? type.id === "Death"
                      ? "bg-rose-500/20 border-rose-500/50 text-rose-300"
                      : type.id === "Injury"
                      ? "bg-amber-500/20 border-amber-500/50 text-amber-300"
                      : type.id === "Malfunction"
                      ? "bg-blue-500/20 border-blue-500/50 text-blue-300"
                      : "bg-slate-700/40 border-slate-600 text-slate-200"
                    : "bg-slate-950/40 border-slate-800 text-slate-500 hover:border-slate-700 hover:text-slate-400"
                }`}
              >
                <span>{type.label}</span>
                {isSelected && <span className="w-1.5 h-1.5 rounded-full bg-current"></span>}
              </button>
            );
          })}
        </div>
      </div>

      {/* 4. Brand Filter with Active Tags, Mode Toggle & Manager */}
      <div className="space-y-2 flex flex-col">
        <div className="flex items-center justify-between">
          <label className="text-xs font-semibold text-slate-300 flex items-center gap-1.5">
            <Layers className="w-3.5 h-3.5 text-indigo-400" />
            제품 선택 ({stagedFilters.categories.join(", ") || "전체"})
          </label>
          <button
            onClick={onOpenBrandManager}
            className="flex items-center gap-1 text-[11px] font-medium text-indigo-400 hover:text-indigo-300 bg-indigo-500/10 px-2 py-0.5 rounded-md border border-indigo-500/20 transition"
            title="대표 브랜드 그룹 관리자 열기"
          >
            <Settings className="w-3 h-3" />
            그룹 관리
          </button>
        </div>

        {/* Selected Brands Indicator & Chips (Displays 5~6 rows cleanly with smooth scrolling) */}
        {stagedFilters.brands.length > 0 && (
          <div className="p-2.5 bg-indigo-950/40 border border-indigo-500/30 rounded-xl space-y-1.5">
            <div className="flex items-center justify-between text-[11px]">
              <span className="font-semibold text-indigo-300 flex items-center gap-1">
                <Check className="w-3 h-3 text-indigo-400" />
                현재 선택된 제품: {stagedFilters.brands.length}개
              </span>
              <button
                type="button"
                onClick={handleClearAllBrands}
                className="text-[10px] text-rose-400 hover:text-rose-300 flex items-center gap-0.5 transition"
                title="선택된 모든 제품 비우기"
              >
                <Trash2 className="w-3 h-3" />
                선택 비우기
              </button>
            </div>
            <div className="flex flex-wrap gap-1 max-h-36 overflow-y-auto custom-scrollbar p-0.5">
              {stagedFilters.brands.map((b) => (
                <span
                  key={b}
                  className="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-indigo-600/30 border border-indigo-500/40 text-[10px] text-indigo-200 font-mono"
                >
                  <span className="truncate max-w-[140px]" title={b}>
                    {b}
                  </span>
                  <button
                    type="button"
                    onClick={(e) => handleRemoveBrand(b, e)}
                    className="hover:text-rose-400 transition"
                    title="선택 해제"
                  >
                    <X className="w-2.5 h-2.5" />
                  </button>
                </span>
              ))}
            </div>
          </div>
        )}

        {/* View Mode Toggle: Accurate separate counts */}
        <div className="flex bg-slate-950 p-1 rounded-xl border border-slate-800 text-[11px]">
          <button
            type="button"
            onClick={() => setBrandViewMode("canonical")}
            className={`flex-1 py-1 rounded-lg font-medium transition ${
              brandViewMode === "canonical"
                ? "bg-indigo-600 text-white shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            🏷️ 대표 그룹 ({canonicalCandidates.length})
          </button>
          <button
            type="button"
            onClick={() => setBrandViewMode("all")}
            className={`flex-1 py-1 rounded-lg font-medium transition ${
              brandViewMode === "all"
                ? "bg-indigo-600 text-white shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            📋 전체 원본 ({allCandidates.length})
          </button>
        </div>

        {/* Brand Search */}
        <div className="space-y-1">
          <div className="relative">
            <Search className="absolute left-2.5 top-2 w-3 h-3 text-slate-500" />
            <input
              type="text"
              placeholder={
                brandViewMode === "canonical"
                  ? "그룹 검색 (예: Dexcom, Libre)..."
                  : "원본 검색 (예: dexcom sensor 또는 g6, g7)..."
              }
              value={brandSearch}
              onChange={(e) => setBrandSearch(e.target.value)}
              className="w-full pl-7 pr-3 py-1.5 text-[11px] bg-slate-950/80 border border-slate-800 rounded-lg focus:outline-none focus:border-indigo-500 text-white placeholder-slate-500"
            />
          </div>
          <div className="text-[10px] text-slate-500 px-1 leading-tight">
            💡 띄어쓰기: AND 동시포함 | 쉼표(,): OR 다중검색
          </div>
        </div>

        {/* Select all / clear buttons */}
        <div className="flex justify-between items-center px-1 text-[10px] text-slate-400">
          <span>{displayedBrands.length}개 표시 중</span>
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={() => handleSelectAllBrands(true)}
              className="hover:text-indigo-300 transition text-indigo-400 font-medium"
            >
              현재 표시 선택
            </button>
            <span className="text-slate-600">|</span>
            <button
              type="button"
              onClick={handleClearAllBrands}
              className="hover:text-rose-300 transition text-rose-400 font-semibold"
              title="이전에 선택된 것까지 포함하여 모든 제품 선택을 완전 해제합니다."
            >
              전체 해제 (모두 비우기)
            </button>
          </div>
        </div>

        {/* Brands Scrollable List: Tall window (~20 items at once) with smooth scrolling */}
        <div className="h-[480px] overflow-y-auto border border-slate-800 rounded-xl p-2 bg-slate-950/40 space-y-1 custom-scrollbar">
          {displayedBrands.length === 0 ? (
            <div className="text-center py-8 text-slate-500 text-[11px]">
              선택된 카테고리에 해당하는 제품이 없습니다.
            </div>
          ) : (
            displayedBrands.map((b) => {
              const isSelected = stagedFilters.brands.includes(b);
              const groupMembersCount =
                brandViewMode === "canonical"
                  ? (metadata?.brand_groups?.[b] || []).length
                  : null;

              return (
                <div
                  key={b}
                  onClick={() => handleBrandToggle(b)}
                  title={b}
                  className={`flex items-center justify-between px-2.5 py-1.5 rounded-lg text-xs cursor-pointer transition select-none ${
                    isSelected
                      ? "bg-indigo-600/20 text-indigo-300 font-medium"
                      : "text-slate-400 hover:bg-slate-800/40 hover:text-slate-200"
                  }`}
                >
                  <div className="truncate flex-1 pr-2 font-mono" title={b}>
                    <span className="truncate" title={b}>
                      {b}
                    </span>
                    {groupMembersCount !== null && (
                      <span className="ml-1.5 text-[10px] text-slate-500 font-normal font-sans">
                        ({groupMembersCount}개 포함)
                      </span>
                    )}
                  </div>
                  {isSelected ? (
                    <CheckSquare className="w-3.5 h-3.5 text-indigo-400 shrink-0" />
                  ) : (
                    <Square className="w-3.5 h-3.5 text-slate-700 shrink-0" />
                  )}
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* 5. Date Range Presets & Inputs */}
      <div className="space-y-2 pt-2 border-t border-slate-800">
        <label className="text-xs font-semibold text-slate-300 flex items-center gap-1.5">
          <Calendar className="w-3.5 h-3.5 text-indigo-400" />
          접수 일자 범위 (Date Received)
        </label>
        <div className="grid grid-cols-2 gap-2 text-xs">
          <div>
            <span className="text-[10px] text-slate-500 block mb-0.5">시작일</span>
            <input
              type="date"
              value={stagedFilters.date_from}
              onChange={(e) => setStagedFilters((prev) => ({ ...prev, date_from: e.target.value }))}
              onKeyDown={handleKeyDown}
              className="w-full px-2 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-white text-[11px] focus:outline-none focus:border-indigo-500"
            />
          </div>
          <div>
            <span className="text-[10px] text-slate-500 block mb-0.5">종료일</span>
            <input
              type="date"
              value={stagedFilters.date_to}
              onChange={(e) => setStagedFilters((prev) => ({ ...prev, date_to: e.target.value }))}
              onKeyDown={handleKeyDown}
              className="w-full px-2 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-white text-[11px] focus:outline-none focus:border-indigo-500"
            />
          </div>
        </div>

        {/* Quick Date Presets */}
        <div className="flex gap-1 pt-1">
          {[
            { label: "전체", from: "", to: "" },
            { label: "2024년", from: "2024-01-01", to: "2024-12-31" },
            { label: "2023년", from: "2023-01-01", to: "2023-12-31" },
            { label: "최근 1년", from: "2025-01-01", to: "2026-12-31" },
          ].map((p) => (
            <button
              key={p.label}
              type="button"
              onClick={() => {
                setStagedFilters((prev) => ({ ...prev, date_from: p.from, date_to: p.to }));
              }}
              className="flex-1 py-1 bg-slate-950 hover:bg-slate-800 text-[10px] text-slate-400 hover:text-slate-200 rounded border border-slate-800 transition text-center"
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>
    </aside>
  );
};
