import React, { useState, useMemo } from "react";
import ReactECharts from "echarts-for-react";
import {
  ShieldAlert,
  Send,
  TrendingUp,
  BarChart3,
  Layers,
  Sparkles,
  PieChart,
  Calendar,
  AlertTriangle,
  Globe,
  Building,
  HeartPulse,
} from "lucide-react";
import type { InsightsData } from "../../types";

interface InsightsTabProps {
  insights: InsightsData | null;
  loading: boolean;
}

type SeverityViewMode = "canonical" | "raw";
type SeverityChartType = "stacked_bar" | "grouped_bar" | "share";
type PathwayTimeGrain = "month" | "quarter" | "year";
type PathwayChartType = "share" | "area" | "bar" | "line";

export const InsightsTab: React.FC<InsightsTabProps> = ({ insights, loading }) => {
  // Severity Matrix state
  const [severityMode, setSeverityMode] = useState<SeverityViewMode>("canonical");
  const [severityChartType, setSeverityChartType] = useState<SeverityChartType>("stacked_bar");

  // Pathway timeline state
  const [pathwayTimeGrain, setPathwayTimeGrain] = useState<PathwayTimeGrain>("month");
  const [pathwayChartType, setPathwayChartType] = useState<PathwayChartType>("share");

  if (loading || !insights) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center space-y-3">
          <div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-xs text-slate-400">안전성 및 보고 경로 인사이트를 분석 중입니다...</p>
        </div>
      </div>
    );
  }

  // -------------------------------------------------------------------------
  // 1. Severity Matrix Chart (Canonical Groups vs Raw Brands)
  // -------------------------------------------------------------------------
  const severityTargetData =
    severityMode === "canonical"
      ? insights?.canonical_severity || {}
      : insights?.raw_severity || {};

  // Sort brands by total volume and take top 12
  const sortedBrands = useMemo(() => {
    if (!severityTargetData || typeof severityTargetData !== "object") return [];
    return Object.entries(severityTargetData)
      .map(([b, counts]) => {
        const c = typeof counts === "object" && counts !== null ? counts : {};
        const total =
          Number(c.Death || 0) +
          Number(c.Injury || 0) +
          Number(c.Malfunction || 0) +
          Number(c.Other || 0);
        return { brand: b, total, counts: c };
      })
      .sort((a, b) => b.total - a.total)
      .slice(0, 12);
  }, [severityTargetData]);

  const brandNames = sortedBrands.map((s) => s.brand);
  const deathData = sortedBrands.map((s) => Number(s.counts?.Death || 0));
  const injuryData = sortedBrands.map((s) => Number(s.counts?.Injury || 0));
  const malData = sortedBrands.map((s) => Number(s.counts?.Malfunction || 0));
  const otherData = sortedBrands.map((s) => Number(s.counts?.Other || 0));

  const isShareSeverity = severityChartType === "share";

  const severityOption = useMemo(() => {
    if (brandNames.length === 0) return {};
    const calcShare = (val: number, idx: number) => {
      const tot = sortedBrands[idx]?.total || 1;
      return parseFloat(((val / (tot || 1)) * 100).toFixed(1));
    };

    return {
      backgroundColor: "transparent",
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "shadow" },
        backgroundColor: "#0f172a",
        borderColor: "#334155",
        textStyle: { color: "#f8fafc", fontSize: 12 },
        formatter: (params: any[]) => {
          if (!params || params.length === 0) return "";
          let out = `<div class="font-bold border-b border-slate-700 pb-1 mb-1">${params[0].axisValue}</div>`;
          params.forEach((p) => {
            const val = isShareSeverity ? `${p.value}%` : `${p.value.toLocaleString()}건`;
            out += `
              <div class="flex items-center justify-between gap-4 py-0.5">
                <span class="flex items-center gap-1.5">
                  <span class="w-2.5 h-2.5 rounded-full" style="background:${p.color}"></span>
                  <span>${p.seriesName}</span>
                </span>
                <span class="font-mono font-bold">${val}</span>
              </div>
            `;
          });
          return out;
        },
      },
      legend: {
        top: 0,
        textStyle: { color: "#94a3b8", fontSize: 11 },
      },
      grid: {
        left: "3%",
        right: "3%",
        bottom: "8%",
        top: "14%",
        containLabel: true,
      },
      xAxis: {
        type: "category",
        data: brandNames,
        axisLine: { lineStyle: { color: "#334155" } },
        axisLabel: {
          color: "#94a3b8",
          fontSize: 11,
          interval: 0,
          rotate: brandNames.length > 6 ? 20 : 0,
        },
      },
      yAxis: {
        type: "value",
        max: isShareSeverity ? 100 : undefined,
        axisLabel: {
          color: "#94a3b8",
          formatter: (v: number) => (isShareSeverity ? `${v}%` : v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v),
        },
        splitLine: { lineStyle: { color: "#1e293b", type: "dashed" } },
      },
      series: [
        {
          name: "사망 (Death)",
          type: "bar",
          stack: isShareSeverity || severityChartType === "stacked_bar" ? "total" : undefined,
          data: isShareSeverity ? deathData.map(calcShare) : deathData,
          itemStyle: { color: "#f43f5e" },
        },
        {
          name: "상해 (Injury)",
          type: "bar",
          stack: isShareSeverity || severityChartType === "stacked_bar" ? "total" : undefined,
          data: isShareSeverity ? injuryData.map(calcShare) : injuryData,
          itemStyle: { color: "#f59e0b" },
        },
        {
          name: "오작동 (Malfunction)",
          type: "bar",
          stack: isShareSeverity || severityChartType === "stacked_bar" ? "total" : undefined,
          data: isShareSeverity ? malData.map(calcShare) : malData,
          itemStyle: { color: "#3b82f6" },
        },
        {
          name: "기타 (Other)",
          type: "bar",
          stack: isShareSeverity || severityChartType === "stacked_bar" ? "total" : undefined,
          data: isShareSeverity ? otherData.map(calcShare) : otherData,
          itemStyle: { color: "#64748b" },
        },
      ],
    };
  }, [brandNames, deathData, injuryData, malData, otherData, severityChartType, isShareSeverity, sortedBrands]);

  // -------------------------------------------------------------------------
  // 2. Reporting Pathways: Donut Share & Time-Series Trend
  // -------------------------------------------------------------------------
  const pathwaysDist = insights?.pathways_distribution || {};
  const donutData = Object.entries(pathwaysDist).map(([name, value]) => ({
    name: name || "기타/미상",
    value: Number(value || 0),
  }));

  const pathwayDonutOption = useMemo(() => {
    if (donutData.length === 0) return {};
    return {
      backgroundColor: "transparent",
      tooltip: {
        trigger: "item",
        backgroundColor: "#0f172a",
        borderColor: "#334155",
        textStyle: { color: "#f8fafc" },
        formatter: "{b}: {c}건 ({d}%)",
      },
      legend: {
        orient: "vertical",
        right: "5%",
        top: "center",
        textStyle: { color: "#94a3b8", fontSize: 11 },
      },
      color: ["#6366f1", "#10b981", "#f59e0b", "#ec4899", "#64748b"],
      series: [
        {
          type: "pie",
          radius: ["48%", "72%"],
          center: ["40%", "50%"],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 8,
            borderColor: "#0f172a",
            borderWidth: 2,
          },
          label: { show: false },
          emphasis: {
            label: {
              show: true,
              fontSize: 13,
              fontWeight: "bold",
              color: "#fff",
            },
          },
          data: donutData,
        },
      ],
    };
  }, [donutData]);

  // Time-Series Pathway aggregation
  const formatPathwayTime = (m: string, grain: PathwayTimeGrain): string => {
    if (!m || m.length < 4) return "Unknown";
    const year = m.slice(0, 4);
    if (grain === "year") return year;
    if (grain === "quarter" && m.length >= 7) {
      const q = Math.ceil(parseInt(m.slice(5, 7), 10) / 3);
      return `${year}-Q${q}`;
    }
    return m.slice(0, 7);
  };

  const { pathwayTimeKeys, pathwaySeries } = useMemo(() => {
    const rawTimeline = insights?.pathways_timeline || [];
    const timeSet = new Set<string>();
    const pathways = [
      "MDR (제조사 의무보고)",
      "MedWatch (자발적 보고)",
      "Foreign (해외 보고)",
      "Distributor (유통/수입사)",
      "Other/Literature (문헌/기타)",
    ];

    const agg: Record<string, Record<string, number>> = {};
    const totals: Record<string, number> = {};

    rawTimeline.forEach((item) => {
      const tKey = formatPathwayTime(item.month, pathwayTimeGrain);
      if (!tKey || tKey === "Unknown" || tKey < "2020") return;

      timeSet.add(tKey);
      if (!agg[tKey]) agg[tKey] = {};

      pathways.forEach((p) => {
        const val = Number(item[p] || 0);
        agg[tKey][p] = (agg[tKey][p] || 0) + val;
        totals[tKey] = (totals[tKey] || 0) + val;
      });
    });

    const sortedTime = Array.from(timeSet).sort();
    const isShare = pathwayChartType === "share";
    // 100% share is always a bar chart stacked to 100%
    const isBar = pathwayChartType === "bar" || isShare;

    const colors: Record<string, string> = {
      "MDR (제조사 의무보고)": "#6366f1",
      "MedWatch (자발적 보고)": "#10b981",
      "Foreign (해외 보고)": "#f59e0b",
      "Distributor (유통/수입사)": "#ec4899",
      "Other/Literature (문헌/기타)": "#64748b",
    };

    const series = pathways.map((p) => {
      const color = colors[p] || "#6366f1";
      const sdata = sortedTime.map((tKey) => {
        const val = agg[tKey]?.[p] || 0;
        if (isShare) {
          const tot = totals[tKey] || 1;
          return parseFloat(((val / tot) * 100).toFixed(1));
        }
        return val;
      });

      const sObj: any = {
        name: p,
        type: isBar ? "bar" : "line",
        data: sdata,
        smooth: true,
        symbol: pathwayChartType === "line" ? "circle" : "none",
        symbolSize: 6,
        itemStyle: { color },
      };

      if (pathwayChartType === "area" || isShare || isBar) {
        sObj.stack = "total";
      }

      if (pathwayChartType === "area") {
        sObj.areaStyle = {
          opacity: 0.4,
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: color },
              { offset: 1, color: "rgba(15, 23, 42, 0.05)" },
            ],
          },
        };
      }

      return sObj;
    });

    return { pathwayTimeKeys: sortedTime, pathwaySeries: series };
  }, [insights?.pathways_timeline, pathwayTimeGrain, pathwayChartType]);

  const pathwayTimelineOption = useMemo(() => {
    if (pathwayTimeKeys.length === 0) return {};
    return {
      backgroundColor: "transparent",
      tooltip: {
        trigger: "axis",
        backgroundColor: "#0f172a",
        borderColor: "#334155",
        textStyle: { color: "#f8fafc", fontSize: 12 },
      },
      legend: {
        top: 0,
        textStyle: { color: "#94a3b8", fontSize: 11 },
      },
      grid: {
        left: "3%",
        right: "3%",
        bottom: "8%",
        top: "14%",
        containLabel: true,
      },
      xAxis: {
        type: "category",
        boundaryGap: pathwayChartType === "bar" || pathwayChartType === "share",
        data: pathwayTimeKeys,
        axisLine: { lineStyle: { color: "#334155" } },
        axisLabel: { color: "#94a3b8", fontSize: 11 },
      },
      yAxis: {
        type: "value",
        max: pathwayChartType === "share" ? 100 : undefined,
        min: pathwayChartType === "share" ? 0 : undefined,
        axisLabel: {
          color: "#94a3b8",
          formatter: (v: number) => (pathwayChartType === "share" ? `${v}%` : v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v),
        },
        splitLine: { lineStyle: { color: "#1e293b", type: "dashed" } },
      },
      series: pathwaySeries,
    };
  }, [pathwayTimeKeys, pathwaySeries, pathwayChartType]);

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* 1. Brand Severity Risk Matrix (Section 1) */}
      <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-6 backdrop-blur-md shadow-xl">
        <div className="flex flex-wrap items-center justify-between gap-4 pb-4 border-b border-slate-800 mb-4">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-rose-500/10 text-rose-400 border border-rose-500/20 rounded-xl">
              <ShieldAlert className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                제품별 중증 부작용 발생량 비교 (Severity Matrix)
              </h3>
              <p className="text-xs text-slate-400">
                기본 대표 그룹별 집계로 깔끔하게 비교하며, 개별 원본 제품명 전환 및 점유율 차트를 지원합니다.
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3 text-xs">
            {/* View Mode Toggle */}
            <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800">
              <button
                onClick={() => setSeverityMode("canonical")}
                className={`px-3 py-1.5 rounded-lg font-medium transition ${
                  severityMode === "canonical"
                    ? "bg-indigo-600 text-white font-semibold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                🏷️ 대표 그룹별 (기본)
              </button>
              <button
                onClick={() => setSeverityMode("raw")}
                className={`px-3 py-1.5 rounded-lg font-medium transition ${
                  severityMode === "raw"
                    ? "bg-indigo-600 text-white font-semibold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                📋 개별 원본 제품명 (상위 12개)
              </button>
            </div>

            {/* Chart Type Toggle */}
            <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800">
              <button
                onClick={() => setSeverityChartType("stacked_bar")}
                className={`px-2.5 py-1.5 rounded-lg transition ${
                  severityChartType === "stacked_bar"
                    ? "bg-indigo-600 text-white"
                    : "text-slate-400 hover:text-white"
                }`}
              >
                📊 누적 막대
              </button>
              <button
                onClick={() => setSeverityChartType("grouped_bar")}
                className={`px-2.5 py-1.5 rounded-lg transition ${
                  severityChartType === "grouped_bar"
                    ? "bg-indigo-600 text-white"
                    : "text-slate-400 hover:text-white"
                }`}
              >
                📊 묶은 막대
              </button>
              <button
                onClick={() => setSeverityChartType("share")}
                className={`px-2.5 py-1.5 rounded-lg transition ${
                  severityChartType === "share"
                    ? "bg-indigo-600 text-white"
                    : "text-slate-400 hover:text-white"
                }`}
              >
                🥧 100% 점유율
              </button>
            </div>
          </div>
        </div>

        <div className="h-80 w-full">
          <ReactECharts
            option={severityOption}
            style={{ height: "100%", width: "100%" }}
            notMerge={true}
          />
        </div>
      </div>

      {/* 2. Reporting Pathway Analysis (Section 2 - MDR / MedWatch / Foreign / Distributor) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Pathway Donut Share (1/3 width) */}
        <div className="bg-slate-900/60 border border-slate-800 rounded-2xl p-6 backdrop-blur-md shadow-xl flex flex-col">
          <div className="flex items-center gap-3 pb-4 border-b border-slate-800 mb-4">
            <div className="p-2.5 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-xl">
              <Send className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-white">보고 접수 경로 대분류</h3>
              <p className="text-[11px] text-slate-400">MDR / MedWatch / 해외 / 유통사 비중</p>
            </div>
          </div>

          <div className="flex-1 h-64">
            <ReactECharts
              option={pathwayDonutOption}
              style={{ height: "100%", width: "100%" }}
              notMerge={true}
            />
          </div>

          {/* Quick Pathway Legend Summary */}
          <div className="grid grid-cols-2 gap-2 text-xs pt-3 border-t border-slate-800">
            {donutData.map((d, idx) => (
              <div key={d.name} className="flex items-center justify-between p-1.5 bg-slate-950/60 rounded-lg border border-slate-800/80">
                <span className="text-[11px] text-slate-300 truncate pr-1">{d.name}</span>
                <span className="font-mono font-semibold text-white">{d.value.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Pathway Time-Series Trend (2/3 width) */}
        <div className="lg:col-span-2 bg-slate-900/60 border border-slate-800 rounded-2xl p-6 backdrop-blur-md shadow-xl flex flex-col">
          <div className="flex flex-wrap items-center justify-between gap-3 pb-4 border-b border-slate-800 mb-4">
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 rounded-xl">
                <TrendingUp className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-white">보고 접수 경로별 시계열 추이</h3>
                <p className="text-[11px] text-slate-400">월별/분기별/연도별 보고 경로 변화 추적</p>
              </div>
            </div>

            <div className="flex items-center gap-2 text-xs">
              {/* Granularity */}
              <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800">
                <button
                  onClick={() => setPathwayTimeGrain("month")}
                  className={`px-2.5 py-1 rounded-lg transition ${
                    pathwayTimeGrain === "month" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                >
                  월별
                </button>
                <button
                  onClick={() => setPathwayTimeGrain("quarter")}
                  className={`px-2.5 py-1 rounded-lg transition ${
                    pathwayTimeGrain === "quarter" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                >
                  분기별
                </button>
                <button
                  onClick={() => setPathwayTimeGrain("year")}
                  className={`px-2.5 py-1 rounded-lg transition ${
                    pathwayTimeGrain === "year" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                >
                  연도별
                </button>
              </div>

              {/* Chart Type (100% share is 100% stacked bar) */}
              <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800">
                <button
                  onClick={() => setPathwayChartType("share")}
                  className={`px-2 py-1 rounded-lg transition ${
                    pathwayChartType === "share" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                  title="100% 누적 점유율 막대"
                >
                  🥧 100% 점유율
                </button>
                <button
                  onClick={() => setPathwayChartType("bar")}
                  className={`px-2 py-1 rounded-lg transition ${
                    pathwayChartType === "bar" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                  title="누적 막대"
                >
                  📊 막대
                </button>
                <button
                  onClick={() => setPathwayChartType("area")}
                  className={`px-2 py-1 rounded-lg transition ${
                    pathwayChartType === "area" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                  title="누적 영역"
                >
                  📈 영역
                </button>
                <button
                  onClick={() => setPathwayChartType("line")}
                  className={`px-2 py-1 rounded-lg transition ${
                    pathwayChartType === "line" ? "bg-indigo-600 text-white font-medium" : "text-slate-400"
                  }`}
                  title="선 그래프"
                >
                  📉 선
                </button>
              </div>
            </div>
          </div>

          <div className="flex-1 h-72">
            <ReactECharts
              option={pathwayTimelineOption}
              style={{ height: "100%", width: "100%" }}
              notMerge={true}
            />
          </div>
        </div>
      </div>
    </div>
  );
};
