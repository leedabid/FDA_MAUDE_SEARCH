import React, { useState, useMemo } from "react";
import {
  TrendingUp,
  Calendar,
  Layers,
  BarChart2,
  PieChart,
  Activity,
  LineChart,
  CheckSquare,
  Square,
  Sparkles,
} from "lucide-react";
import ReactECharts from "echarts-for-react";
import type { MonthlyDataPoint, Metadata } from "../../types";

interface MonthlyTrendTabProps {
  data: MonthlyDataPoint[];
  loading: boolean;
  metadata?: Metadata | null;
}

type TimeGrain = "month" | "quarter" | "year";
type ChartType = "stacked_bar" | "share" | "area" | "grouped_bar" | "line";
type GroupBy = "brand" | "event_type";
type BrandMode = "canonical" | "raw";

export const MonthlyTrendTab: React.FC<MonthlyTrendTabProps> = ({ data, loading }) => {
  const [groupBy, setGroupBy] = useState<GroupBy>("brand");
  const [chartType, setChartType] = useState<ChartType>("share"); // Default to 100% Share
  const [timeGrain, setTimeGrain] = useState<TimeGrain>("quarter");
  const [brandMode, setBrandMode] = useState<BrandMode>("canonical");
  const [topLimit, setTopLimit] = useState<number>(10);
  const [disabledSeries, setDisabledSeries] = useState<Record<string, boolean>>({});

  // Aggregation helper based on TimeGrain (Month -> YYYY-MM, Quarter -> YYYY-Q#, Year -> YYYY)
  const formatTimeKey = (m: string, grain: TimeGrain): string => {
    if (!m || m.length < 4) return "Unknown";
    const year = m.slice(0, 4);
    if (grain === "year") return year;
    if (grain === "quarter" && m.length >= 7) {
      const monthNum = parseInt(m.slice(5, 7), 10);
      const q = Math.ceil(monthNum / 3);
      return `${year}-Q${q}`;
    }
    return m.slice(0, 7); // Monthly
  };

  // Processed and aggregated timeline data
  const { timeKeys, allSeriesNames, matrix, rawCountsMatrix } = useMemo(() => {
    if (!data || data.length === 0) {
      return { timeKeys: [], allSeriesNames: [], matrix: {}, rawCountsMatrix: {} };
    }

    const timeSet = new Set<string>();
    const groupCountMap: Record<string, number> = {};
    const agg: Record<string, Record<string, number>> = {};
    const rawCounts: Record<string, Record<string, number>> = {};

    data.forEach((d) => {
      const tKey = formatTimeKey(d.month, timeGrain);
      if (!tKey || tKey === "Unknown" || tKey < "2020") return;

      timeSet.add(tKey);

      let groupKey = "Unknown";
      if (groupBy === "event_type") {
        groupKey = d.event_type || "Unknown";
      } else {
        groupKey = (brandMode === "canonical" ? d.brand_name : (d.raw_brand_name || d.brand_name)) || "Unknown";
      }

      groupCountMap[groupKey] = (groupCountMap[groupKey] || 0) + d.count;

      if (!agg[tKey]) agg[tKey] = {};
      if (!rawCounts[tKey]) rawCounts[tKey] = {};

      agg[tKey][groupKey] = (agg[tKey][groupKey] || 0) + d.count;
      rawCounts[tKey][groupKey] = (rawCounts[tKey][groupKey] || 0) + d.count;
    });

    const sortedSeries = Object.entries(groupCountMap)
      .sort((a, b) => b[1] - a[1])
      .slice(0, groupBy === "brand" ? topLimit : 6)
      .map(([k]) => k);

    const sortedTimeKeys = Array.from(timeSet).sort();

    return {
      timeKeys: sortedTimeKeys,
      allSeriesNames: sortedSeries,
      matrix: agg,
      rawCountsMatrix: rawCounts,
    };
  }, [data, timeGrain, groupBy, brandMode, topLimit]);

  // Active series list (excluding user-disabled series)
  const activeSeriesNames = useMemo(() => {
    return allSeriesNames.filter((name) => !disabledSeries[name]);
  }, [allSeriesNames, disabledSeries]);

  const toggleSeries = (name: string) => {
    setDisabledSeries((prev) => ({
      ...prev,
      [name]: !prev[name],
    }));
  };

  const selectAllSeries = (select: boolean) => {
    if (select) {
      setDisabledSeries({});
    } else {
      const allDis: Record<string, boolean> = {};
      allSeriesNames.forEach((n) => (allDis[n] = true));
      setDisabledSeries(allDis);
    }
  };

  // ECharts Option with dynamic 100% re-normalization
  const chartOption = useMemo(() => {
    if (timeKeys.length === 0) return {};

    const isShare = chartType === "share";
    const isBar = chartType === "stacked_bar" || chartType === "grouped_bar" || isShare;
    const isStacked = chartType === "area" || chartType === "stacked_bar" || isShare;
    const isLine = chartType === "line";

    const colorPalette = [
      "#6366f1",
      "#10b981",
      "#f59e0b",
      "#ec4899",
      "#06b6d4",
      "#8b5cf6",
      "#f43f5e",
      "#3b82f6",
      "#14b8a6",
      "#a855f7",
      "#64748b",
    ];

    // Compute dynamic sum for ONLY actively selected series at each time grain
    const activeTotalByTime: Record<string, number> = {};
    timeKeys.forEach((tKey) => {
      let sum = 0;
      activeSeriesNames.forEach((name) => {
        sum += matrix[tKey]?.[name] || 0;
      });
      activeTotalByTime[tKey] = sum;
    });

    const series = activeSeriesNames.map((name, idx) => {
      const color = colorPalette[idx % colorPalette.length];
      const seriesData = timeKeys.map((tKey) => {
        const val = matrix[tKey]?.[name] || 0;
        if (isShare) {
          const tot = activeTotalByTime[tKey] || 1;
          return parseFloat(((val / tot) * 100).toFixed(1));
        }
        return val;
      });

      const base: any = {
        name,
        type: isBar ? "bar" : "line",
        data: seriesData,
        smooth: !isBar,
        symbol: isLine ? "circle" : "none",
        symbolSize: 6,
        itemStyle: { color },
      };

      if (isStacked) {
        base.stack = "total";
      }

      if (chartType === "area") {
        base.areaStyle = {
          opacity: 0.45,
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: color },
              { offset: 1, color: "rgba(15, 23, 42, 0.1)" },
            ],
          },
        };
      }

      return base;
    });

    return {
      backgroundColor: "transparent",
      tooltip: {
        trigger: "axis",
        backgroundColor: "#0f172a",
        borderColor: "#334155",
        textStyle: { color: "#f8fafc", fontSize: 12 },
        formatter: (params: any[]) => {
          if (!params || params.length === 0) return "";
          const tKey = params[0].axisValue;
          const activeSum = activeTotalByTime[tKey] || 0;
          let out = `
            <div class="font-bold border-b border-slate-700 pb-1 mb-1 flex items-center justify-between gap-4">
              <span class="text-white text-sm">${tKey}</span>
              <span class="text-xs text-indigo-400 font-mono">
                선택 항목 합산: ${activeSum.toLocaleString()}건 ${isShare ? "(100%)" : ""}
              </span>
            </div>
          `;
          params.forEach((p) => {
            const rawVal = rawCountsMatrix[tKey]?.[p.seriesName] || 0;
            const pctVal = isShare
              ? p.value
              : activeSum > 0
              ? ((rawVal / activeSum) * 100).toFixed(1)
              : "0";
            const valDisplay = isShare
              ? `<span class="font-mono font-bold text-white">${pctVal}%</span> <span class="text-slate-400 text-xs font-normal">(${rawVal.toLocaleString()}건)</span>`
              : `<span class="font-mono font-bold text-white">${p.value.toLocaleString()}건</span> <span class="text-slate-400 text-xs font-normal">(${pctVal}%)</span>`;

            out += `
              <div class="flex items-center justify-between gap-4 py-0.5 text-xs">
                <span class="flex items-center gap-1.5 truncate max-w-[220px]">
                  <span class="w-2.5 h-2.5 rounded-full shrink-0" style="background:${p.color}"></span>
                  <span class="truncate text-slate-200">${p.seriesName}</span>
                </span>
                <span class="shrink-0">${valDisplay}</span>
              </div>
            `;
          });
          return out;
        },
      },
      legend: {
        show: false, // Managed via custom interactive UI chips below
      },
      grid: {
        left: "2%",
        right: "2%",
        bottom: "10%",
        top: "6%",
        containLabel: true,
      },
      xAxis: {
        type: "category",
        boundaryGap: isBar,
        data: timeKeys,
        axisLine: { lineStyle: { color: "#334155" } },
        axisLabel: { color: "#94a3b8", fontSize: 11 },
      },
      yAxis: {
        type: "value",
        max: isShare ? 100 : undefined,
        min: isShare ? 0 : undefined,
        axisLabel: {
          color: "#94a3b8",
          formatter: (v: number) => (isShare ? `${v}%` : v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v),
        },
        splitLine: { lineStyle: { color: "#1e293b", type: "dashed" } },
      },
      dataZoom: [
        {
          type: "inside",
          start: timeKeys.length > 24 ? 50 : 0,
          end: 100,
        },
        {
          type: "slider",
          bottom: 0,
          height: 20,
          borderColor: "#334155",
          fillerColor: "rgba(99, 102, 241, 0.2)",
          handleStyle: { color: "#6366f1" },
          textStyle: { color: "#94a3b8", fontSize: 10 },
          start: timeKeys.length > 24 ? 50 : 0,
          end: 100,
        },
      ],
      series,
    };
  }, [timeKeys, activeSeriesNames, chartType, matrix, rawCountsMatrix]);

  return (
    <div className="space-y-4 animate-fadeIn">
      {/* 1. Control Header Bar */}
      <div className="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl backdrop-blur-md flex flex-wrap items-center justify-between gap-4 shadow-xl">
        {/* Left: Dimension Selectors */}
        <div className="flex flex-wrap items-center gap-3">
          {/* Group By Dimension */}
          <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
            <button
              type="button"
              onClick={() => setGroupBy("brand")}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                groupBy === "brand"
                  ? "bg-indigo-600 text-white shadow-sm font-semibold"
                  : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <Layers className="w-3.5 h-3.5" />
              <span>제품별</span>
            </button>
            <button
              type="button"
              onClick={() => setGroupBy("event_type")}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                groupBy === "event_type"
                  ? "bg-indigo-600 text-white shadow-sm font-semibold"
                  : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <Activity className="w-3.5 h-3.5" />
              <span>부작용 유형별</span>
            </button>
          </div>

          {/* Canonical vs Raw Brand Toggle (when groupBy === 'brand') */}
          {groupBy === "brand" && (
            <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
              <button
                type="button"
                onClick={() => setBrandMode("canonical")}
                className={`px-3 py-1.5 rounded-lg font-medium transition ${
                  brandMode === "canonical"
                    ? "bg-indigo-600 text-white shadow-sm font-semibold"
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                🏷️ 대표 그룹 (통합)
              </button>
              <button
                type="button"
                onClick={() => setBrandMode("raw")}
                className={`px-3 py-1.5 rounded-lg font-medium transition ${
                  brandMode === "raw"
                    ? "bg-indigo-600 text-white shadow-sm font-semibold"
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                📋 원본 제품명
              </button>
            </div>
          )}

          {/* Time Grain Selector */}
          <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
            <button
              type="button"
              onClick={() => setTimeGrain("month")}
              className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
                timeGrain === "month"
                  ? "bg-indigo-600 text-white font-semibold shadow-sm"
                  : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <Calendar className="w-3.5 h-3.5" />
              <span>월별 (Monthly)</span>
            </button>
            <button
              type="button"
              onClick={() => setTimeGrain("quarter")}
              className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
                timeGrain === "quarter"
                  ? "bg-indigo-600 text-white font-semibold shadow-sm"
                  : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <span>분기별 (Quarterly)</span>
            </button>
            <button
              type="button"
              onClick={() => setTimeGrain("year")}
              className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
                timeGrain === "year"
                  ? "bg-indigo-600 text-white font-semibold shadow-sm"
                  : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <span>연도별 (Yearly)</span>
            </button>
          </div>
        </div>

        {/* Right: Chart Type Selector */}
        <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
          <button
            type="button"
            onClick={() => setChartType("share")}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
              chartType === "share"
                ? "bg-indigo-600 text-white font-semibold shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
            title="선택된 제품들의 합을 100%로 재계산하여 누적 막대로 표시"
          >
            <PieChart className="w-3.5 h-3.5" />
            <span>100% 점유율 막대</span>
          </button>
          <button
            type="button"
            onClick={() => setChartType("stacked_bar")}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
              chartType === "stacked_bar"
                ? "bg-indigo-600 text-white font-semibold shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <BarChart2 className="w-3.5 h-3.5" />
            <span>누적 막대</span>
          </button>
          <button
            type="button"
            onClick={() => setChartType("grouped_bar")}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
              chartType === "grouped_bar"
                ? "bg-indigo-600 text-white font-semibold shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <BarChart2 className="w-3.5 h-3.5" />
            <span>개별 막대</span>
          </button>
          <button
            type="button"
            onClick={() => setChartType("area")}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
              chartType === "area"
                ? "bg-indigo-600 text-white font-semibold shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <TrendingUp className="w-3.5 h-3.5" />
            <span>영역 (Area)</span>
          </button>
          <button
            type="button"
            onClick={() => setChartType("line")}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
              chartType === "line"
                ? "bg-indigo-600 text-white font-semibold shadow-sm"
                : "text-slate-400 hover:text-slate-200"
            }`}
          >
            <LineChart className="w-3.5 h-3.5" />
            <span>선형 (Line)</span>
          </button>
        </div>
      </div>

      {/* 2. Interactive Product Select / Deselect Chips (Auto 100% Re-calculation) */}
      <div className="bg-slate-900/60 border border-slate-800 p-3.5 rounded-2xl flex flex-wrap items-center justify-between gap-3 text-xs">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-slate-400 font-semibold mr-1">표시 제품 선택:</span>
          {allSeriesNames.map((name) => {
            const isEnabled = !disabledSeries[name];
            return (
              <button
                key={name}
                type="button"
                onClick={() => toggleSeries(name)}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-xs font-semibold border transition ${
                  isEnabled
                    ? "bg-indigo-600/20 border-indigo-500/60 text-indigo-200 shadow-sm"
                    : "bg-slate-950/40 border-slate-800 text-slate-500 line-through opacity-60"
                }`}
              >
                {isEnabled ? (
                  <CheckSquare className="w-3 h-3 text-indigo-400 shrink-0" />
                ) : (
                  <Square className="w-3 h-3 text-slate-600 shrink-0" />
                )}
                <span>{name}</span>
              </button>
            );
          })}
        </div>

        <div className="flex items-center gap-2 text-[11px] text-slate-400 shrink-0">
          <button
            type="button"
            onClick={() => selectAllSeries(true)}
            className="hover:text-indigo-300 transition"
          >
            전체 선택
          </button>
          <span>•</span>
          <button
            type="button"
            onClick={() => selectAllSeries(false)}
            className="hover:text-indigo-300 transition"
          >
            전체 해제
          </button>
        </div>
      </div>

      {/* 3. Main Chart Canvas Card */}
      <div className="bg-slate-900/60 border border-slate-800 p-6 rounded-2xl backdrop-blur-md shadow-xl flex flex-col min-h-[580px]">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800 mb-2">
          <div>
            <h3 className="text-sm font-bold text-white flex items-center gap-2">
              <span>시계열 부작용 보고 추이 분석</span>
              {chartType === "share" && (
                <span className="text-xs px-2 py-0.5 bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 rounded-md font-normal">
                  선택된 {activeSeriesNames.length}개 항목 기준 100% 점유율 막대
                </span>
              )}
            </h3>
            <p className="text-[11px] text-slate-400 mt-0.5">
              제품 선택을 해제하면 해당 제품을 제외하고 실시간으로 100% 합계를 재계산하여 표시합니다.
            </p>
          </div>
        </div>

        <div className="flex-1 w-full min-h-[500px]">
          {loading ? (
            <div className="flex items-center justify-center h-full text-slate-400">
              추이 데이터를 계산 중입니다...
            </div>
          ) : timeKeys.length === 0 ? (
            <div className="flex items-center justify-center h-full text-slate-500">
              조회 조건에 해당하는 시계열 데이터가 없습니다.
            </div>
          ) : (
            <ReactECharts
              option={chartOption}
              style={{ height: "100%", width: "100%" }}
              notMerge={true}
            />
          )}
        </div>
      </div>
    </div>
  );
};
