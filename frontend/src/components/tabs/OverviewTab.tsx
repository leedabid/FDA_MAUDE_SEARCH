import React, { useState, useRef, useEffect } from "react";
import ReactECharts from "echarts-for-react";
import {
  AlertCircle,
  AlertTriangle,
  CheckCircle,
  TrendingUp,
  Database,
  Filter,
  Calendar,
  Layers,
  Sparkles,
  Info,
  Maximize2,
  Minimize2,
  MoveVertical,
  RefreshCw,
} from "lucide-react";
import type { OverviewStats, FilterState, Metadata } from "../../types";

interface OverviewTabProps {
  stats: OverviewStats | null;
  loading: boolean;
  filters: FilterState;
  metadata: Metadata | null;
  onOpenSyncModal?: () => void;
}

export const OverviewTab: React.FC<OverviewTabProps> = ({
  stats,
  loading,
  filters,
  metadata,
  onOpenSyncModal,
}) => {
  const [brandViewMode, setBrandViewMode] = useState<"canonical" | "raw">("canonical");
  const [scaleMode, setScaleMode] = useState<"linear" | "log">("linear");

  // Dynamic Resizable Height for Charts Section (Default 580px: ~2.5x larger than original 240px)
  const [chartHeight, setChartHeight] = useState<number>(580);
  const isDraggingRef = useRef<boolean>(false);
  const startYRef = useRef<number>(0);
  const startHeightRef = useRef<number>(580);

  // Mouse Drag to Resize Handler
  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    isDraggingRef.current = true;
    startYRef.current = e.clientY;
    startHeightRef.current = chartHeight;

    const handleMouseMove = (moveEvent: MouseEvent) => {
      if (!isDraggingRef.current) return;
      const deltaY = moveEvent.clientY - startYRef.current;
      const newHeight = Math.max(380, Math.min(1200, startHeightRef.current + deltaY));
      setChartHeight(newHeight);
    };

    const handleMouseUp = () => {
      isDraggingRef.current = false;
      window.removeEventListener("mousemove", handleMouseMove);
      window.removeEventListener("mouseup", handleMouseUp);
    };

    window.addEventListener("mousemove", handleMouseMove);
    window.addEventListener("mouseup", handleMouseUp);
  };

  if (loading || !stats) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center space-y-3">
          <div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-xs text-slate-400">데이터를 고속 집계 중입니다...</p>
        </div>
      </div>
    );
  }

  const total = stats.total_reports || 1;
  const deathPct = ((stats.death_count / total) * 100).toFixed(1);
  const injuryPct = ((stats.injury_count / total) * 100).toFixed(1);
  const malPct = ((stats.malfunction_count / total) * 100).toFixed(1);
  const otherPct = ((stats.other_count / total) * 100).toFixed(1);

  // ECharts: Event Type Donut (Scales smoothly with height)
  const donutOption = {
    backgroundColor: "transparent",
    tooltip: {
      trigger: "item",
      backgroundColor: "#0f172a",
      borderColor: "#334155",
      textStyle: { color: "#f8fafc", fontSize: 13 },
      formatter: "{b}: {c}건 ({d}%)",
    },
    legend: {
      bottom: "2%",
      left: "center",
      textStyle: { color: "#94a3b8", fontSize: 12 },
      itemGap: 16,
    },
    color: ["#f43f5e", "#f59e0b", "#3b82f6", "#64748b"],
    series: [
      {
        name: "부작용 유형",
        type: "pie",
        radius: ["42%", "68%"],
        center: ["50%", "45%"],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: "#0f172a",
          borderWidth: 3,
        },
        label: {
          show: true,
          position: "outside",
          formatter: "{b}\n{d}%",
          color: "#cbd5e1",
          fontSize: 11,
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 14,
            fontWeight: "bold",
            color: "#fff",
          },
        },
        data: [
          { value: stats.death_count, name: "사망 (Death)" },
          { value: stats.injury_count, name: "상해 (Injury)" },
          { value: stats.malfunction_count, name: "오작동 (Malfunction)" },
          { value: stats.other_count, name: "기타 (Other)" },
        ],
      },
    ],
  };

  // ECharts: Top Products Bar Chart (Canonical Group vs Raw Brands & Linear vs Log Scale)
  const targetBrandsList =
    brandViewMode === "canonical"
      ? stats.top_canonical_brands || stats.top_brands || []
      : stats.top_raw_brands || stats.top_brands || [];

  const isLog = scaleMode === "log";

  const barOption = {
    backgroundColor: "transparent",
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "shadow" },
      backgroundColor: "#0f172a",
      borderColor: "#334155",
      textStyle: { color: "#f8fafc", fontSize: 12 },
      formatter: (params: any[]) => {
        if (!params || params.length === 0) return "";
        const p = params[0];
        const rawVal = targetBrandsList.find((b) => b.brand === p.name)?.count || p.value;
        return `
          <div class="font-bold text-indigo-300 border-b border-slate-700 pb-1 mb-1 text-sm">${p.name}</div>
          <div class="flex items-center justify-between gap-4 py-1">
            <span class="text-slate-400 text-xs">총 보고 건수:</span>
            <span class="font-mono font-bold text-white text-base">${rawVal.toLocaleString()}건</span>
          </div>
          <div class="text-[10px] text-slate-500 mt-1">
            ${brandViewMode === "canonical" ? "✓ 통합 대표 그룹 합산" : "✓ 개별 원본 명칭"}
          </div>
        `;
      },
    },
    grid: {
      left: "2%",
      right: "8%",
      bottom: "5%",
      top: "8%",
      containLabel: true,
    },
    xAxis: {
      type: isLog ? "log" : "value",
      logBase: 10,
      min: isLog ? 100 : undefined,
      axisLabel: {
        color: "#94a3b8",
        fontSize: 12,
        formatter: (v: number) => {
          if (v >= 1000000) return `${(v / 1000000).toFixed(1)}M`;
          if (v >= 1000) return `${(v / 1000).toFixed(0)}k`;
          return v;
        },
      },
      splitLine: { lineStyle: { color: "#334155", type: "dashed" } },
    },
    yAxis: {
      type: "category",
      data: targetBrandsList.map((b) => b.brand).reverse(),
      axisLabel: {
        color: "#f1f5f9",
        fontSize: 12,
        fontWeight: "bold",
        width: 180,
        overflow: "truncate",
      },
    },
    series: [
      {
        name: "보고 건수",
        type: "bar",
        barMaxWidth: 36,
        data: targetBrandsList.map((b) => b.count).reverse(),
        label: {
          show: true,
          position: "right",
          color: "#cbd5e1",
          fontSize: 11,
          fontWeight: "bold",
          formatter: (params: any) => {
            const v = params.value;
            return v >= 10000 ? `${(v / 1000).toFixed(0)}k건` : `${v.toLocaleString()}건`;
          },
        },
        itemStyle: {
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 1,
            y2: 0,
            colorStops: [
              { offset: 0, color: "#6366f1" },
              { offset: 1, color: "#a5b4fc" },
            ],
          },
          borderRadius: [0, 8, 8, 0],
        },
      },
    ],
  };

  // Active filter helper text
  const activeCategories = filters?.categories?.length ? filters.categories.join(", ") : "전체 카테고리";
  const minMonth = metadata?.min_date ? metadata.min_date.slice(0, 7).replace("-", ".") : "2020.01";
  const maxMonth = metadata?.max_date ? metadata.max_date.slice(0, 7).replace("-", ".") : "";
  const activeDateRange =
    filters?.date_from || filters?.date_to
      ? `${filters.date_from || "시작"} ~ ${filters.date_to || "현재"}`
      : maxMonth
      ? `전체 수집 기간 (${minMonth} ~ ${maxMonth})`
      : "전체 수집 기간";
  const activeEventTypes = filters?.event_types?.length ? filters.event_types.join(", ") : "전체 부작용 유형";
  const activeBrands =
    !filters?.brands || filters.brands.length === 0
      ? "전체 브랜드"
      : filters.brands.length <= 2
      ? `${filters.brands.join(", ")} (${filters.brands.length}개)`
      : `${filters.brands[0]} 외 ${filters.brands.length - 1}개 (${filters.brands.length}개)`;

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* 0. Data Scope & Active Filter Summary Banner */}
      <div className="bg-gradient-to-r from-indigo-950/40 via-slate-900/60 to-slate-900/60 border border-indigo-500/20 p-4 rounded-2xl backdrop-blur-md shadow-lg flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-indigo-500/20 text-indigo-400 border border-indigo-500/30 rounded-xl">
            <Database className="w-4 h-4" />
          </div>
          <div>
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-xs font-bold text-white">데이터베이스 수집 범위</span>
              <span className="text-[11px] px-2 py-0.5 rounded-md bg-indigo-500/10 text-indigo-300 border border-indigo-500/20 font-mono">
                {metadata?.min_date || "2020-01-02"} ~ {metadata?.max_date || "현재"} (총 {metadata?.total_reports?.toLocaleString() || "0"}건)
              </span>
              <button
                type="button"
                onClick={onOpenSyncModal}
                className="text-[11px] px-2.5 py-0.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white font-bold transition flex items-center gap-1 shadow-md shadow-indigo-600/30 cursor-pointer"
                title="OpenFDA 실시간 데이터 수집 / 갱신 모달 열기"
              >
                <RefreshCw className="w-3 h-3" />
                <span>최신 데이터 수집 / 갱신</span>
              </button>
            </div>
            <p className="text-[11px] text-slate-400 mt-0.5">
              FDA MAUDE 연속혈당측정기(CGM) 및 인슐린 펌프 부작용 전수 데이터베이스
            </p>
          </div>
        </div>

        {/* Current Active Filter Badges */}
        <div className="flex flex-wrap items-center gap-2 text-xs">
          <div className="flex items-center gap-1 px-2.5 py-1 bg-slate-950/80 border border-slate-800 rounded-lg text-slate-300">
            <Filter className="w-3 h-3 text-indigo-400" />
            <span className="text-[11px] text-slate-400">카테고리:</span>
            <span className="font-semibold text-indigo-300">{activeCategories}</span>
          </div>

          <div className="flex items-center gap-1 px-2.5 py-1 bg-slate-950/80 border border-slate-800 rounded-lg text-slate-300">
            <Calendar className="w-3 h-3 text-indigo-400" />
            <span className="text-[11px] text-slate-400">조회 기간:</span>
            <span className="font-semibold text-indigo-300">{activeDateRange}</span>
          </div>

          <div className="flex items-center gap-1 px-2.5 py-1 bg-slate-950/80 border border-slate-800 rounded-lg text-slate-300">
            <Layers className="w-3 h-3 text-indigo-400" />
            <span className="text-[11px] text-slate-400">브랜드:</span>
            <span className="font-semibold text-indigo-300">{activeBrands}</span>
          </div>
        </div>
      </div>

      {/* 1. KPI Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Total */}
        <div className="bg-slate-900/60 border border-slate-800 p-5 rounded-2xl shadow-sm relative overflow-hidden backdrop-blur-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">
                현재 조회된 보고 건수
              </p>
              <h3 className="text-2xl font-bold text-white mt-1">
                {stats.total_reports.toLocaleString()}
                <span className="text-xs font-normal text-slate-400 ml-1">건</span>
              </h3>
            </div>
            <div className="w-12 h-12 bg-indigo-500/10 border border-indigo-500/20 rounded-xl flex items-center justify-center text-indigo-400">
              <TrendingUp className="w-6 h-6" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-xs text-slate-400">
            <span>좌측 필터 조건에 부합하는 레코드 수</span>
          </div>
        </div>

        {/* Death */}
        <div className="bg-slate-900/60 border border-rose-500/30 p-5 rounded-2xl shadow-sm relative overflow-hidden bg-gradient-to-b from-rose-500/5 to-transparent backdrop-blur-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-rose-400 uppercase tracking-wider">
                사망 (Death)
              </p>
              <h3 className="text-2xl font-bold text-white mt-1">
                {stats.death_count.toLocaleString()}
                <span className="text-xs font-normal text-slate-400 ml-1">건</span>
              </h3>
            </div>
            <div className="w-12 h-12 bg-rose-500/10 border border-rose-500/20 rounded-xl flex items-center justify-center text-rose-400">
              <AlertTriangle className="w-6 h-6" />
            </div>
          </div>
          <div className="mt-4 flex items-center justify-between text-xs">
            <span className="text-rose-400 font-semibold">{deathPct}%</span>
            <span className="text-slate-400">전체 보고 중 비중</span>
          </div>
        </div>

        {/* Injury */}
        <div className="bg-slate-900/60 border border-amber-500/30 p-5 rounded-2xl shadow-sm relative overflow-hidden bg-gradient-to-b from-amber-500/5 to-transparent backdrop-blur-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-amber-400 uppercase tracking-wider">
                상해 (Injury)
              </p>
              <h3 className="text-2xl font-bold text-white mt-1">
                {stats.injury_count.toLocaleString()}
                <span className="text-xs font-normal text-slate-400 ml-1">건</span>
              </h3>
            </div>
            <div className="w-12 h-12 bg-amber-500/10 border border-amber-500/20 rounded-xl flex items-center justify-center text-amber-400">
              <AlertCircle className="w-6 h-6" />
            </div>
          </div>
          <div className="mt-4 flex items-center justify-between text-xs">
            <span className="text-amber-400 font-semibold">{injuryPct}%</span>
            <span className="text-slate-400">전체 보고 중 비중</span>
          </div>
        </div>

        {/* Malfunction */}
        <div className="bg-slate-900/60 border border-blue-500/30 p-5 rounded-2xl shadow-sm relative overflow-hidden bg-gradient-to-b from-blue-500/5 to-transparent backdrop-blur-md">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-blue-400 uppercase tracking-wider">
                기기 오작동 (Malfunction)
              </p>
              <h3 className="text-2xl font-bold text-white mt-1">
                {stats.malfunction_count.toLocaleString()}
                <span className="text-xs font-normal text-slate-400 ml-1">건</span>
              </h3>
            </div>
            <div className="w-12 h-12 bg-blue-500/10 border border-blue-500/20 rounded-xl flex items-center justify-center text-blue-400">
              <CheckCircle className="w-6 h-6" />
            </div>
          </div>
          <div className="mt-4 flex items-center justify-between text-xs">
            <span className="text-blue-400 font-semibold">{malPct}%</span>
            <span className="text-slate-400">전체 보고 중 비중</span>
          </div>
        </div>
      </div>

      {/* 2. Height Control Bar & Preset Buttons */}
      <div className="flex items-center justify-between px-1 text-xs text-slate-400">
        <span className="flex items-center gap-1.5 font-medium">
          <MoveVertical className="w-3.5 h-3.5 text-indigo-400" />
          그래프 세로 높이: <strong className="text-white font-mono">{chartHeight}px</strong> (하단 우측을 드래그하여 조절)
        </span>
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setChartHeight(450)}
            className={`px-2.5 py-1 rounded-lg border transition text-[11px] ${
              chartHeight === 450
                ? "bg-indigo-600 text-white border-indigo-500"
                : "bg-slate-900 border-slate-800 hover:text-slate-200"
            }`}
          >
            기본 (450px)
          </button>
          <button
            type="button"
            onClick={() => setChartHeight(580)}
            className={`px-2.5 py-1 rounded-lg border transition text-[11px] ${
              chartHeight === 580
                ? "bg-indigo-600 text-white border-indigo-500"
                : "bg-slate-900 border-slate-800 hover:text-slate-200"
            }`}
          >
            권장 확대 (580px)
          </button>
          <button
            type="button"
            onClick={() => setChartHeight(750)}
            className={`px-2.5 py-1 rounded-lg border transition text-[11px] ${
              chartHeight === 750
                ? "bg-indigo-600 text-white border-indigo-500"
                : "bg-slate-900 border-slate-800 hover:text-slate-200"
            }`}
          >
            대형 (750px)
          </button>
          <button
            type="button"
            onClick={() => setChartHeight(950)}
            className={`px-2.5 py-1 rounded-lg border transition text-[11px] ${
              chartHeight === 950
                ? "bg-indigo-600 text-white border-indigo-500"
                : "bg-slate-900 border-slate-800 hover:text-slate-200"
            }`}
          >
            최대 (950px)
          </button>
        </div>
      </div>

      {/* 3. Main Visuals Grid (Resizable Container) */}
      <div className="relative group">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Event Type Donut (1/3) */}
          <div
            style={{ height: `${chartHeight}px` }}
            className="bg-slate-900/60 border border-slate-800 p-6 rounded-2xl backdrop-blur-md flex flex-col shadow-xl transition-[height] duration-75"
          >
            <div className="pb-3 border-b border-slate-800 mb-2 shrink-0">
              <h3 className="text-sm font-bold text-white">부작용 유형별 분포</h3>
              <p className="text-[11px] text-slate-400">사망, 상해, 오작동, 기타 비율</p>
            </div>
            <div className="flex-1 w-full min-h-0">
              <ReactECharts
                option={donutOption}
                style={{ height: "100%", width: "100%" }}
                notMerge={true}
              />
            </div>
          </div>

          {/* Top Products Bar Chart with Mode & Log Scale Toggles (2/3) */}
          <div
            style={{ height: `${chartHeight}px` }}
            className="lg:col-span-2 bg-slate-900/60 border border-slate-800 p-6 rounded-2xl backdrop-blur-md flex flex-col shadow-xl transition-[height] duration-75 relative"
          >
            <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-slate-800 mb-2 shrink-0">
              <div>
                <h3 className="text-sm font-bold text-white flex items-center gap-2">
                  보고 건수 상위 제품명 Top 10
                </h3>
                <p className="text-[11px] text-slate-400">
                  {brandViewMode === "canonical"
                    ? "동일 제품의 유사 표기들을 통합한 대표 제품 그룹 기준 집계 (Dexcom ..., FreeStyle Libre ...)"
                    : "DB에 기입된 개별 원본 제품명 기준 집계"}
                </p>
              </div>

              <div className="flex items-center gap-2 text-xs">
                {/* Scale Mode (Linear vs Log Scale) */}
                <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800">
                  <button
                    type="button"
                    onClick={() => setScaleMode("linear")}
                    className={`px-2.5 py-1 rounded-lg transition ${
                      scaleMode === "linear"
                        ? "bg-indigo-600 text-white font-semibold shadow-sm"
                        : "text-slate-400 hover:text-slate-200"
                    }`}
                    title="선형 스케일 (절대 건수 비례)"
                  >
                    📊 선형
                  </button>
                  <button
                    type="button"
                    onClick={() => setScaleMode("log")}
                    className={`px-2.5 py-1 rounded-lg transition ${
                      scaleMode === "log"
                        ? "bg-indigo-600 text-white font-semibold shadow-sm"
                        : "text-slate-400 hover:text-slate-200"
                    }`}
                    title="로그 스케일 (비균등 스케일: G6 외 타 제품군 비교에 최적)"
                  >
                    📈 로그 (비균등)
                  </button>
                </div>

                {/* View Mode (Canonical Group vs Raw Product Names) */}
                <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800">
                  <button
                    type="button"
                    onClick={() => setBrandViewMode("canonical")}
                    className={`px-3 py-1 rounded-lg font-medium transition ${
                      brandViewMode === "canonical"
                        ? "bg-indigo-600 text-white font-semibold shadow-sm"
                        : "text-slate-400 hover:text-slate-200"
                    }`}
                  >
                    🏷️ 대표 그룹 (통합)
                  </button>
                  <button
                    type="button"
                    onClick={() => setBrandViewMode("raw")}
                    className={`px-3 py-1 rounded-lg font-medium transition ${
                      brandViewMode === "raw"
                        ? "bg-indigo-600 text-white font-semibold shadow-sm"
                        : "text-slate-400 hover:text-slate-200"
                    }`}
                  >
                    📋 원본 제품명
                  </button>
                </div>
              </div>
            </div>

            <div className="flex-1 w-full min-h-0">
              <ReactECharts
                option={barOption}
                style={{ height: "100%", width: "100%" }}
                notMerge={true}
              />
            </div>
          </div>
        </div>

        {/* Interactive Mouse Drag Resize Handle (Bottom-Right) */}
        <div
          onMouseDown={handleMouseDown}
          className="absolute -bottom-3 right-3 flex items-center gap-1.5 px-3 py-1 bg-indigo-600 hover:bg-indigo-500 text-white rounded-full text-[11px] font-semibold cursor-ns-resize shadow-xl border border-indigo-400/30 select-none transition"
          title="마우스를 누른 채 위아래로 드래그하여 세로 크기 조절"
        >
          <MoveVertical className="w-3 h-3" />
          <span>드래그하여 크기 조절</span>
          <span className="font-mono text-[10px] opacity-80">({chartHeight}px)</span>
        </div>
      </div>
    </div>
  );
};
