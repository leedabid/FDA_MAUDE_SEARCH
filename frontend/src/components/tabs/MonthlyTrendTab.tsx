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
  Filter,
  Check,
  Sparkles,
  PieChart as PieIcon,
  Percent,
  Award,
  Sun,
  Moon,
  LayoutGrid,
  Hash,
  Download,
  FolderPlus,
  Settings2,
  Copy,
  Loader2,
} from "lucide-react";
import * as echarts from "echarts";
import ReactECharts from "echarts-for-react";
import type { MonthlyDataPoint, Metadata } from "../../types";
import { CustomTrendGroupModal, type CustomTrendGroup } from "../modals/CustomTrendGroupModal";

interface MonthlyTrendTabProps {
  data: MonthlyDataPoint[];
  loading: boolean;
  metadata?: Metadata | null;
}

type TimeGrain = "month" | "quarter" | "year";
type ChartType = "stacked_bar" | "share" | "area" | "grouped_bar" | "line";
type CountChartType = "line" | "stacked_bar" | "grouped_bar" | "area";
type GroupBy = "event_brand_breakdown" | "brand" | "event_type";
type BrandMode = "canonical" | "raw";
type ThemeMode = "dark" | "light";
type ViewLayout = "dual" | "share_only" | "count_only";

// Standard FDA MAUDE Event Types configuration
const EVENT_TYPES_CONFIG = [
  {
    id: "Malfunction",
    nameKr: "오작동",
    label: "오작동 (Malfunction)",
    color: "#0284c7",
    badgeBg: "bg-blue-500/20 border-blue-500/50 text-blue-300",
    activeBtnBg: "bg-blue-600 text-white border-blue-500",
    dotColor: "bg-blue-400",
  },
  {
    id: "Injury",
    nameKr: "상해",
    label: "상해 (Injury)",
    color: "#f59e0b",
    badgeBg: "bg-amber-500/20 border-amber-500/50 text-amber-300",
    activeBtnBg: "bg-amber-600 text-white border-amber-500",
    dotColor: "bg-amber-400",
  },
  {
    id: "Death",
    nameKr: "사망",
    label: "사망 (Death)",
    color: "#f43f5e",
    badgeBg: "bg-rose-500/20 border-rose-500/50 text-rose-300",
    activeBtnBg: "bg-rose-600 text-white border-rose-500",
    dotColor: "bg-rose-400",
  },
  {
    id: "Other",
    nameKr: "기타",
    label: "기타 (Other)",
    color: "#8b5cf6",
    badgeBg: "bg-purple-500/20 border-purple-500/50 text-purple-300",
    activeBtnBg: "bg-purple-600 text-white border-purple-500",
    dotColor: "bg-purple-400",
  },
];

const EVENT_TYPE_MAP = Object.fromEntries(EVENT_TYPES_CONFIG.map((e) => [e.id, e]));

// Curated harmonious color palette matching the user's reference charts
const BRAND_COLOR_PALETTE = [
  "#0284c7", // Deep Sky Blue (Dexcom G6 style)
  "#06b6d4", // Cyan (Dexcom G7 style)
  "#0f766e", // Teal / Deep Cyan (Dexcom G7 15 Day style)
  "#ea580c", // Orange (Libre 2 style)
  "#eab308", // Golden Yellow (Libre 2+ style)
  "#16a34a", // Bright Green (Libre 3 style)
  "#9333ea", // Purple (Libre 3+ style)
  "#ec4899", // Pink
  "#6366f1", // Indigo
  "#3b82f6", // Blue
  "#14b8a6", // Mint
  "#f43f5e", // Rose
  "#64748b", // Slate
];

export const MonthlyTrendTab: React.FC<MonthlyTrendTabProps> = ({ data, loading, metadata }) => {
  const [groupBy, setGroupBy] = useState<GroupBy>("event_brand_breakdown");
  const [targetEventType, setTargetEventType] = useState<string>("Malfunction");
  const [chartType, setChartType] = useState<ChartType>("share"); // Default to 100% Share
  const [countChartType, setCountChartType] = useState<CountChartType>("line"); // Default to Line
  const [timeGrain, setTimeGrain] = useState<TimeGrain>("month");
  const [brandMode, setBrandMode] = useState<BrandMode>("canonical");
  const [themeMode, setThemeMode] = useState<ThemeMode>("dark"); // "dark" or "light" (White report background)
  const [viewLayout, setViewLayout] = useState<ViewLayout>("dual"); // "dual" = both % share and raw counts
  const [selectedEventTypes, setSelectedEventTypes] = useState<string[]>([]); // For brand mode filtering
  const [topLimit, setTopLimit] = useState<number>(10);
  const [chartHeight, setChartHeight] = useState<number>(380);
  const [disabledSeries, setDisabledSeries] = useState<Record<string, boolean>>({});

  // Custom Trend Groups state (persisted in localStorage)
  const [customGroups, setCustomGroups] = useState<CustomTrendGroup[]>(() => {
    try {
      const saved = localStorage.getItem("maude_custom_trend_groups");
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [isCustomGroupEnabled, setIsCustomGroupEnabled] = useState<boolean>(() => {
    try {
      return localStorage.getItem("maude_custom_trend_group_enabled") === "true";
    } catch {
      return false;
    }
  });

  const [hideUngrouped, setHideUngrouped] = useState<boolean>(() => {
    try {
      const saved = localStorage.getItem("maude_custom_group_hide_ungrouped");
      return saved !== null ? saved === "true" : true;
    } catch {
      return true;
    }
  });

  const [isGroupModalOpen, setIsGroupModalOpen] = useState<boolean>(false);

  const handleSaveCustomGroups = (newGroups: CustomTrendGroup[]) => {
    setCustomGroups(newGroups);
    localStorage.setItem("maude_custom_trend_groups", JSON.stringify(newGroups));
    if (newGroups.length > 0) {
      setIsCustomGroupEnabled(true);
      localStorage.setItem("maude_custom_trend_group_enabled", "true");
    } else {
      setIsCustomGroupEnabled(false);
      localStorage.setItem("maude_custom_trend_group_enabled", "false");
    }
    setDisabledSeries({});
  };

  const handleToggleCustomGroupEnabled = (enabled: boolean) => {
    setIsCustomGroupEnabled(enabled);
    localStorage.setItem("maude_custom_trend_group_enabled", enabled ? "true" : "false");
    setDisabledSeries({});
  };

  const handleToggleHideUngrouped = (hide: boolean) => {
    setHideUngrouped(hide);
    localStorage.setItem("maude_custom_group_hide_ungrouped", hide ? "true" : "false");
    setDisabledSeries({});
  };

  // Available brands for group modal
  const availableBrands = useMemo(() => {
    const brandSet = new Set<string>();
    if (data && data.length > 0) {
      data.forEach((d) => {
        const b = brandMode === "canonical" ? d.brand_name : (d.raw_brand_name || d.brand_name);
        if (b && b !== "Unknown") brandSet.add(b);
      });
    }
    if (metadata) {
      const sourceList = brandMode === "canonical" ? metadata.canonical_brands : metadata.all_brands;
      if (sourceList && Array.isArray(sourceList)) {
        sourceList.forEach((b: string) => {
          if (b && b !== "Unknown") brandSet.add(b);
        });
      }
    }
    return Array.from(brandSet).sort();
  }, [data, metadata, brandMode]);

  // Fast lookup mapping brand -> custom group name
  const brandToGroupMap = useMemo(() => {
    const map: Record<string, string> = {};
    if (!isCustomGroupEnabled || customGroups.length === 0) return map;

    customGroups.forEach((g) => {
      g.brands.forEach((b) => {
        map[b] = g.name;
        map[b.toLowerCase()] = g.name;
      });
    });
    return map;
  }, [isCustomGroupEnabled, customGroups]);

  const isLight = themeMode === "light";

  // Helper to format event type labels
  const formatEventTypeName = (et: string): string => {
    return EVENT_TYPE_MAP[et]?.label || et || "Unknown";
  };

  // Toggle Event Type filter (when in Brand mode)
  const handleToggleEventTypeFilter = (eventTypeId: string) => {
    setSelectedEventTypes((prev) => {
      if (prev.includes(eventTypeId)) {
        return prev.filter((id) => id !== eventTypeId);
      } else {
        return [...prev, eventTypeId];
      }
    });
  };

  const handleSelectAllEventTypes = () => {
    setSelectedEventTypes([]);
  };

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

  // 1. Data Filtering based on active Mode & Selected Event Types
  const filteredData = useMemo(() => {
    if (!data || data.length === 0) return [];

    if (groupBy === "event_brand_breakdown") {
      // Filter strictly for the chosen targetEventType (e.g. Malfunction)
      return data.filter((d) => d.event_type === targetEventType);
    } else if (groupBy === "brand") {
      // Filter by selectedEventTypes in Brand mode (if user specified any)
      if (selectedEventTypes.length === 0) return data;
      const allowed = new Set(selectedEventTypes);
      return data.filter((d) => d.event_type && allowed.has(d.event_type));
    }
    return data;
  }, [data, groupBy, targetEventType, selectedEventTypes]);

  // 2. Processed and aggregated timeline data
  const { timeKeys, allSeriesNames, matrix, rawCountsMatrix, totalSeriesCounts, overallTargetTotal } = useMemo(() => {
    if (!filteredData || filteredData.length === 0) {
      return { timeKeys: [], allSeriesNames: [], matrix: {}, rawCountsMatrix: {}, totalSeriesCounts: {}, overallTargetTotal: 0 };
    }

    const timeSet = new Set<string>();
    const groupCountMap: Record<string, number> = {};
    const agg: Record<string, Record<string, number>> = {};
    const rawCounts: Record<string, Record<string, number>> = {};
    let totalSum = 0;

    const useCustomGrouping = isCustomGroupEnabled && customGroups.length > 0 && groupBy !== "event_type";

    filteredData.forEach((d) => {
      const tKey = formatTimeKey(d.month, timeGrain);
      if (!tKey || tKey === "Unknown" || tKey < "2020") return;

      let groupKey = "Unknown";
      if (groupBy === "event_type") {
        groupKey = d.event_type || "Unknown";
      } else {
        const rawOrCanonical = (brandMode === "canonical" ? d.brand_name : (d.raw_brand_name || d.brand_name)) || "Unknown";
        const canonical = d.brand_name || "";
        const raw = d.raw_brand_name || "";

        if (useCustomGrouping) {
          const matched =
            brandToGroupMap[rawOrCanonical] ||
            brandToGroupMap[rawOrCanonical.toLowerCase()] ||
            brandToGroupMap[canonical] ||
            brandToGroupMap[canonical.toLowerCase()] ||
            brandToGroupMap[raw] ||
            brandToGroupMap[raw.toLowerCase()];

          if (matched) {
            groupKey = matched;
          } else {
            if (hideUngrouped) {
              return; // Skip records not in any user custom group
            } else {
              groupKey = rawOrCanonical;
            }
          }
        } else {
          groupKey = rawOrCanonical;
        }
      }

      timeSet.add(tKey);
      groupCountMap[groupKey] = (groupCountMap[groupKey] || 0) + d.count;
      totalSum += d.count;

      if (!agg[tKey]) agg[tKey] = {};
      if (!rawCounts[tKey]) rawCounts[tKey] = {};

      agg[tKey][groupKey] = (agg[tKey][groupKey] || 0) + d.count;
      rawCounts[tKey][groupKey] = (rawCounts[tKey][groupKey] || 0) + d.count;
    });

    let sortedSeries: string[] = [];
    if (groupBy === "event_type") {
      const order = ["Malfunction", "Injury", "Death", "Other"];
      const existing = Object.keys(groupCountMap);
      sortedSeries = [
        ...order.filter((o) => existing.includes(o)),
        ...existing.filter((e) => !order.includes(e)),
      ];
    } else if (useCustomGrouping) {
      const customGroupNames = customGroups.map((g) => g.name);
      const activeCustom = customGroupNames.filter((name) => groupCountMap[name] !== undefined);
      const others = Object.entries(groupCountMap)
        .filter(([k]) => !customGroupNames.includes(k))
        .sort((a, b) => b[1] - a[1])
        .map(([k]) => k);
      sortedSeries = [...activeCustom, ...others].slice(0, topLimit);
    } else {
      sortedSeries = Object.entries(groupCountMap)
        .sort((a, b) => b[1] - a[1])
        .slice(0, topLimit)
        .map(([k]) => k);
    }

    const sortedTimeKeys = Array.from(timeSet).sort();

    return {
      timeKeys: sortedTimeKeys,
      allSeriesNames: sortedSeries,
      matrix: agg,
      rawCountsMatrix: rawCounts,
      totalSeriesCounts: groupCountMap,
      overallTargetTotal: totalSum,
    };
  }, [filteredData, timeGrain, groupBy, brandMode, topLimit, isCustomGroupEnabled, customGroups, brandToGroupMap, hideUngrouped]);

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

  // Top rankings for the target event type summary card
  const topRankings = useMemo(() => {
    if (groupBy !== "event_brand_breakdown" || !totalSeriesCounts) return [];
    const total = overallTargetTotal || 1;
    return Object.entries(totalSeriesCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([brand, count]) => ({
        brand,
        count,
        pct: ((count / total) * 100).toFixed(1),
      }));
  }, [groupBy, totalSeriesCounts, overallTargetTotal]);

  // Theme Styling Configuration Tokens
  const themeStyles = useMemo(() => {
    if (isLight) {
      return {
        cardBg: "bg-white border-slate-200 text-slate-900 shadow-md",
        headerText: "text-slate-900",
        subText: "text-slate-500",
        axisColor: "#475569",
        axisLineColor: "#cbd5e1",
        splitLineColor: "#f1f5f9",
        tooltipBg: "#ffffff",
        tooltipBorder: "#e2e8f0",
        tooltipText: "#0f172a",
        legendText: "#334155",
        bottomLabelBg: "bg-slate-50 border-slate-200 text-slate-700",
      };
    }
    return {
      cardBg: "bg-slate-900/70 border-slate-800 text-slate-100 shadow-xl",
      headerText: "text-white",
      subText: "text-slate-400",
      axisColor: "#94a3b8",
      axisLineColor: "#334155",
      splitLineColor: "#1e293b",
      tooltipBg: "#0f172a",
      tooltipBorder: "#334155",
      tooltipText: "#f8fafc",
      legendText: "#cbd5e1",
      bottomLabelBg: "bg-slate-950/60 border-slate-800 text-slate-300",
    };
  }, [isLight]);

  // Compute dynamic sum for ONLY actively selected series at each time grain
  const activeTotalByTime = useMemo(() => {
    const map: Record<string, number> = {};
    timeKeys.forEach((tKey) => {
      let sum = 0;
      activeSeriesNames.forEach((name) => {
        sum += matrix[tKey]?.[name] || 0;
      });
      map[tKey] = sum;
    });
    return map;
  }, [timeKeys, activeSeriesNames, matrix]);

  // =========================================================================
  // CHART 1: 100% Share (or Selected Format) Percentage Chart Option
  // =========================================================================
  const shareChartOption = useMemo(() => {
    if (timeKeys.length === 0) return {};

    const isShare = chartType === "share";
    const isBar = chartType === "stacked_bar" || chartType === "grouped_bar" || isShare;
    const isStacked = chartType === "area" || chartType === "stacked_bar" || isShare;
    const isLine = chartType === "line";

    const series = activeSeriesNames.map((name, idx) => {
      const color =
        groupBy === "event_type" && EVENT_TYPE_MAP[name]
          ? EVENT_TYPE_MAP[name].color
          : BRAND_COLOR_PALETTE[idx % BRAND_COLOR_PALETTE.length];

      const displayName = groupBy === "event_type" ? formatEventTypeName(name) : name;

      const seriesData = timeKeys.map((tKey) => {
        const val = matrix[tKey]?.[name] || 0;
        if (isShare) {
          const tot = activeTotalByTime[tKey] || 1;
          return parseFloat(((val / tot) * 100).toFixed(1));
        }
        return val;
      });

      const base: any = {
        name: displayName,
        rawKey: name,
        type: isBar ? "bar" : "line",
        data: seriesData,
        smooth: !isBar,
        symbol: isLine ? "circle" : "none",
        symbolSize: 5,
        itemStyle: { color },
      };

      if (isStacked) {
        base.stack = "total";
      }

      if (chartType === "area") {
        base.areaStyle = {
          opacity: 0.5,
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: color },
              { offset: 1, color: isLight ? "rgba(241, 245, 249, 0.2)" : "rgba(15, 23, 42, 0.1)" },
            ],
          },
        };
      }

      return base;
    });

    const targetEventLabel = EVENT_TYPE_MAP[targetEventType]?.label || targetEventType;

    return {
      backgroundColor: "transparent",
      tooltip: {
        trigger: "axis",
        backgroundColor: themeStyles.tooltipBg,
        borderColor: themeStyles.tooltipBorder,
        textStyle: { color: themeStyles.tooltipText, fontSize: 12 },
        formatter: (params: any[]) => {
          if (!params || params.length === 0) return "";
          const tKey = params[0].axisValue;
          const activeSum = activeTotalByTime[tKey] || 0;

          const headerTitle =
            groupBy === "event_brand_breakdown"
              ? `${tKey} [${targetEventLabel}] 제품별 비중`
              : `${tKey}`;

          let out = `
            <div style="font-weight: bold; border-bottom: 1px solid ${themeStyles.splitLineColor}; padding-bottom: 4px; margin-bottom: 6px; display: flex; justify-content: space-between; gap: 16px;">
              <span>${headerTitle}</span>
              <span style="color: #6366f1; font-family: monospace;">
                합산: ${activeSum.toLocaleString()}건 ${isShare ? "(100%)" : ""}
              </span>
            </div>
          `;
          params.forEach((p) => {
            const rawKey = activeSeriesNames[p.seriesIndex] || p.seriesName;
            const rawVal = rawCountsMatrix[tKey]?.[rawKey] || 0;
            const pctVal = isShare
              ? p.value
              : activeSum > 0
              ? ((rawVal / activeSum) * 100).toFixed(1)
              : "0";
            const valDisplay = isShare
              ? `<b style="font-family: monospace;">${pctVal}%</b> <span style="opacity: 0.7; font-size: 11px;">(${rawVal.toLocaleString()}건)</span>`
              : `<b style="font-family: monospace;">${p.value.toLocaleString()}건</b> <span style="opacity: 0.7; font-size: 11px;">(${pctVal}%)</span>`;

            out += `
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 2px 0; font-size: 12px;">
                <span style="display: flex; align-items: center; gap: 6px; max-width: 240px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  <span style="width: 10px; height: 10px; border-radius: 2px; background: ${p.color}; display: inline-block; flex-shrink: 0;"></span>
                  <span>${p.seriesName}</span>
                </span>
                <span style="flex-shrink: 0;">${valDisplay}</span>
              </div>
            `;
          });
          return out;
        },
      },
      legend: {
        show: true,
        bottom: 25,
        left: "center",
        icon: "rect",
        itemWidth: 12,
        itemHeight: 12,
        itemGap: 16,
        textStyle: {
          color: themeStyles.legendText,
          fontSize: 11,
        },
      },
      grid: {
        left: "3%",
        right: "3%",
        bottom: 70,
        top: 30,
        containLabel: true,
      },
      xAxis: {
        type: "category",
        name: "월",
        nameLocation: "middle",
        nameGap: 30,
        nameTextStyle: { color: themeStyles.axisColor, fontSize: 11 },
        boundaryGap: isBar,
        data: timeKeys,
        axisLine: { lineStyle: { color: themeStyles.axisLineColor } },
        axisLabel: { color: themeStyles.axisColor, fontSize: 10, rotate: timeKeys.length > 20 ? 45 : 0 },
      },
      yAxis: {
        type: "value",
        name: isShare ? "비중" : "건수",
        nameTextStyle: { color: themeStyles.axisColor, fontSize: 11 },
        max: isShare ? 100 : undefined,
        min: isShare ? 0 : undefined,
        axisLabel: {
          color: themeStyles.axisColor,
          formatter: (v: number) => (isShare ? `${v}%` : v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v),
        },
        splitLine: { lineStyle: { color: themeStyles.splitLineColor, type: "dashed" } },
      },
      dataZoom: [
        {
          type: "inside",
          start: timeKeys.length > 36 ? 40 : 0,
          end: 100,
        },
        {
          type: "slider",
          bottom: 0,
          height: 18,
          borderColor: themeStyles.axisLineColor,
          fillerColor: "rgba(2, 132, 199, 0.2)",
          handleStyle: { color: "#0284c7" },
          textStyle: { color: themeStyles.axisColor, fontSize: 10 },
          start: timeKeys.length > 36 ? 40 : 0,
          end: 100,
        },
      ],
      series,
    };
  }, [timeKeys, activeSeriesNames, chartType, matrix, rawCountsMatrix, groupBy, targetEventType, activeTotalByTime, themeStyles, isLight]);

  // =========================================================================
  // CHART 2: Absolute Count (Volume Trend) Chart Option
  // =========================================================================
  const countChartOption = useMemo(() => {
    if (timeKeys.length === 0) return {};

    const isStacked = countChartType === "stacked_bar" || countChartType === "area";
    const isBar = countChartType === "stacked_bar" || countChartType === "grouped_bar";

    const series = activeSeriesNames.map((name, idx) => {
      const color =
        groupBy === "event_type" && EVENT_TYPE_MAP[name]
          ? EVENT_TYPE_MAP[name].color
          : BRAND_COLOR_PALETTE[idx % BRAND_COLOR_PALETTE.length];

      const displayName = groupBy === "event_type" ? formatEventTypeName(name) : name;
      const seriesData = timeKeys.map((tKey) => rawCountsMatrix[tKey]?.[name] || 0);

      const base: any = {
        name: displayName,
        rawKey: name,
        type: isBar ? "bar" : "line",
        data: seriesData,
        smooth: !isBar,
        symbol: countChartType === "line" ? "circle" : "none",
        symbolSize: 6,
        itemStyle: { color },
        lineStyle: { width: 2.5 },
      };

      if (isStacked) {
        base.stack = "count_total";
      }

      if (countChartType === "area") {
        base.areaStyle = {
          opacity: 0.35,
          color: {
            type: "linear",
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: color },
              { offset: 1, color: isLight ? "rgba(241, 245, 249, 0.1)" : "rgba(15, 23, 42, 0.05)" },
            ],
          },
        };
      }

      return base;
    });

    const targetEventLabel = EVENT_TYPE_MAP[targetEventType]?.label || targetEventType;

    return {
      backgroundColor: "transparent",
      tooltip: {
        trigger: "axis",
        backgroundColor: themeStyles.tooltipBg,
        borderColor: themeStyles.tooltipBorder,
        textStyle: { color: themeStyles.tooltipText, fontSize: 12 },
        formatter: (params: any[]) => {
          if (!params || params.length === 0) return "";
          const tKey = params[0].axisValue;
          const activeSum = activeTotalByTime[tKey] || 0;

          const headerTitle =
            groupBy === "event_brand_breakdown"
              ? `${tKey} [${targetEventLabel}] 실제 발생 건수`
              : `${tKey} 실제 발생 건수`;

          let out = `
            <div style="font-weight: bold; border-bottom: 1px solid ${themeStyles.splitLineColor}; padding-bottom: 4px; margin-bottom: 6px; display: flex; justify-content: space-between; gap: 16px;">
              <span>${headerTitle}</span>
              <span style="color: #0284c7; font-family: monospace;">
                총 건수: ${activeSum.toLocaleString()}건
              </span>
            </div>
          `;
          params.forEach((p) => {
            const val = p.value || 0;
            const pct = activeSum > 0 ? ((val / activeSum) * 100).toFixed(1) : "0";
            out += `
              <div style="display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 2px 0; font-size: 12px;">
                <span style="display: flex; align-items: center; gap: 6px; max-width: 240px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  <span style="width: 10px; height: 10px; border-radius: 2px; background: ${p.color}; display: inline-block; flex-shrink: 0;"></span>
                  <span>${p.seriesName}</span>
                </span>
                <span style="flex-shrink: 0;">
                  <b style="font-family: monospace;">${val.toLocaleString()}건</b> 
                  <span style="opacity: 0.7; font-size: 11px;">(${pct}%)</span>
                </span>
              </div>
            `;
          });
          return out;
        },
      },
      legend: {
        show: true,
        bottom: 25,
        left: "center",
        icon: "rect",
        itemWidth: 12,
        itemHeight: 12,
        itemGap: 16,
        textStyle: {
          color: themeStyles.legendText,
          fontSize: 11,
        },
      },
      grid: {
        left: "3%",
        right: "3%",
        bottom: 70,
        top: 30,
        containLabel: true,
      },
      xAxis: {
        type: "category",
        name: "월",
        nameLocation: "middle",
        nameGap: 30,
        nameTextStyle: { color: themeStyles.axisColor, fontSize: 11 },
        boundaryGap: isBar,
        data: timeKeys,
        axisLine: { lineStyle: { color: themeStyles.axisLineColor } },
        axisLabel: { color: themeStyles.axisColor, fontSize: 10, rotate: timeKeys.length > 20 ? 45 : 0 },
      },
      yAxis: {
        type: "value",
        name: "건수",
        nameTextStyle: { color: themeStyles.axisColor, fontSize: 11 },
        axisLabel: {
          color: themeStyles.axisColor,
          formatter: (v: number) => (v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v.toLocaleString()),
        },
        splitLine: { lineStyle: { color: themeStyles.splitLineColor, type: "dashed" } },
      },
      dataZoom: [
        {
          type: "inside",
          start: timeKeys.length > 36 ? 40 : 0,
          end: 100,
        },
        {
          type: "slider",
          bottom: 0,
          height: 18,
          borderColor: themeStyles.axisLineColor,
          fillerColor: "rgba(2, 132, 199, 0.2)",
          handleStyle: { color: "#0284c7" },
          textStyle: { color: themeStyles.axisColor, fontSize: 10 },
          start: timeKeys.length > 36 ? 40 : 0,
          end: 100,
        },
      ],
      series,
    };
  }, [timeKeys, activeSeriesNames, countChartType, rawCountsMatrix, groupBy, targetEventType, activeTotalByTime, themeStyles, isLight]);

  const activeEventConfig = EVENT_TYPE_MAP[targetEventType] || EVENT_TYPES_CONFIG[0];

  // =========================================================================
  // PPT High-Resolution Combined Image Export & Clipboard Copy
  // =========================================================================
  const [isExporting, setIsExporting] = useState<boolean>(false);
  const [exportToast, setExportToast] = useState<string | null>(null);

  const handleExportPpt = async (action: "copy" | "download") => {
    if (isExporting || timeKeys.length === 0) return;
    setIsExporting(true);

    try {
      const isDual = viewLayout === "dual";
      const showCount = viewLayout === "dual" || viewLayout === "count_only";
      const showShare = viewLayout === "dual" || viewLayout === "share_only";

      const exportWidth = 1400;
      const singleHeight = 310;
      const dpr = 2; // High-DPI 2x resolution for crisp PPT slides

      const targetEventLabel = EVENT_TYPE_MAP[targetEventType]?.label || targetEventType;
      const customGroupSuffix = isCustomGroupEnabled && customGroups.length > 0 ? " (커스텀 그룹별)" : "";

      const countTitleText =
        groupBy === "event_brand_breakdown"
          ? `${targetEventLabel} 월별 실제 건수 추이${customGroupSuffix}`
          : groupBy === "event_type"
          ? "부작용 유형별 월별 실제 건수 추이"
          : `제품별 월별 실제 발생 건수 추이${customGroupSuffix}`;

      const shareTitleText =
        groupBy === "event_brand_breakdown"
          ? `[${targetEventLabel}] 월별 100% 누적 비중${customGroupSuffix}`
          : groupBy === "event_type"
          ? "부작용 유형별 100% 누적 비중 추이"
          : `제품별 월별 100% 누적 비중 추이${customGroupSuffix}`;

      // Clean, compact ECharts option for Actual Counts Chart
      const pptCountSeries = activeSeriesNames.map((name, idx) => {
        const color =
          groupBy === "event_type" && EVENT_TYPE_MAP[name]
            ? EVENT_TYPE_MAP[name].color
            : BRAND_COLOR_PALETTE[idx % BRAND_COLOR_PALETTE.length];
        const displayName = groupBy === "event_type" ? formatEventTypeName(name) : name;
        const seriesData = timeKeys.map((tKey) => rawCountsMatrix[tKey]?.[name] || 0);
        const isBar = countChartType === "stacked_bar" || countChartType === "grouped_bar";
        const isStacked = countChartType === "stacked_bar" || countChartType === "area";

        return {
          name: displayName,
          type: isBar ? "bar" : "line",
          data: seriesData,
          stack: isStacked ? "count_total" : undefined,
          smooth: !isBar,
          symbol: countChartType === "line" ? "circle" : "none",
          symbolSize: 5,
          itemStyle: { color },
          lineStyle: { width: 2 },
        };
      });

      const cleanCountOption: echarts.EChartsOption = {
        animation: false,
        backgroundColor: "#ffffff",
        title: {
          text: countTitleText,
          left: "center",
          top: 8,
          textStyle: {
            color: "#0f172a",
            fontSize: 13.5,
            fontWeight: "bold",
            fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Noto Sans KR', sans-serif",
          },
        },
        grid: {
          left: 45,
          right: 25,
          top: 34,
          bottom: 42,
          containLabel: true,
        },
        legend: {
          show: true,
          bottom: 2,
          left: "center",
          icon: "rect",
          itemWidth: 10,
          itemHeight: 10,
          itemGap: 14,
          textStyle: { color: "#334155", fontSize: 10 },
        },
        xAxis: {
          type: "category",
          data: timeKeys,
          axisLine: { lineStyle: { color: "#cbd5e1" } },
          axisLabel: {
            color: "#475569",
            fontSize: 9.5,
            rotate: 45,
            interval: timeKeys.length > 36 ? 1 : 0,
          },
        },
        yAxis: {
          type: "value",
          name: "건수",
          nameLocation: "end",
          nameGap: 8,
          nameTextStyle: { color: "#475569", fontSize: 10, fontWeight: "bold" },
          axisLabel: {
            color: "#475569",
            fontSize: 9.5,
            formatter: (v: number) => (v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v.toLocaleString()),
          },
          splitLine: { lineStyle: { color: "#f1f5f9", type: "dashed" } },
        },
        series: pptCountSeries as any,
      };

      // Clean, compact ECharts option for 100% Share Chart
      const pptShareSeries = activeSeriesNames.map((name, idx) => {
        const color =
          groupBy === "event_type" && EVENT_TYPE_MAP[name]
            ? EVENT_TYPE_MAP[name].color
            : BRAND_COLOR_PALETTE[idx % BRAND_COLOR_PALETTE.length];
        const displayName = groupBy === "event_type" ? formatEventTypeName(name) : name;
        const seriesData = timeKeys.map((tKey) => {
          const val = matrix[tKey]?.[name] || 0;
          const tot = activeTotalByTime[tKey] || 1;
          return parseFloat(((val / tot) * 100).toFixed(1));
        });

        return {
          name: displayName,
          type: "bar",
          stack: "share_total",
          data: seriesData,
          itemStyle: { color },
        };
      });

      const cleanShareOption: echarts.EChartsOption = {
        animation: false,
        backgroundColor: "#ffffff",
        title: {
          text: shareTitleText,
          left: "center",
          top: 8,
          textStyle: {
            color: "#0f172a",
            fontSize: 13.5,
            fontWeight: "bold",
            fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Noto Sans KR', sans-serif",
          },
        },
        grid: {
          left: 45,
          right: 25,
          top: 34,
          bottom: 42,
          containLabel: true,
        },
        legend: {
          show: true,
          bottom: 2,
          left: "center",
          icon: "rect",
          itemWidth: 10,
          itemHeight: 10,
          itemGap: 14,
          textStyle: { color: "#334155", fontSize: 10 },
        },
        xAxis: {
          type: "category",
          data: timeKeys,
          axisLine: { lineStyle: { color: "#cbd5e1" } },
          axisLabel: {
            color: "#475569",
            fontSize: 9.5,
            rotate: 45,
            interval: timeKeys.length > 36 ? 1 : 0,
          },
        },
        yAxis: {
          type: "value",
          name: "비중",
          nameLocation: "end",
          nameGap: 8,
          nameTextStyle: { color: "#475569", fontSize: 10, fontWeight: "bold" },
          max: 100,
          min: 0,
          axisLabel: {
            color: "#475569",
            fontSize: 9.5,
            formatter: "{value}%",
          },
          splitLine: { lineStyle: { color: "#f1f5f9", type: "dashed" } },
        },
        series: pptShareSeries as any,
      };

      // Offscreen container for rendering high-DPI charts
      const container = document.createElement("div");
      container.style.position = "fixed";
      container.style.left = "-99999px";
      container.style.top = "-99999px";
      container.style.visibility = "hidden";
      document.body.appendChild(container);

      const renderChartToUrl = (opt: echarts.EChartsOption): Promise<string> => {
        return new Promise((resolve) => {
          const div = document.createElement("div");
          div.style.width = `${exportWidth}px`;
          div.style.height = `${singleHeight}px`;
          container.appendChild(div);

          const chart = echarts.init(div, null, {
            renderer: "canvas",
            devicePixelRatio: dpr,
            width: exportWidth,
            height: singleHeight,
          });

          chart.setOption(opt);
          setTimeout(() => {
            const dataUrl = chart.getDataURL({
              type: "png",
              pixelRatio: dpr,
              backgroundColor: "#ffffff",
            });
            chart.dispose();
            resolve(dataUrl);
          }, 60);
        });
      };

      let urlCount: string | null = null;
      let urlShare: string | null = null;

      if (showCount) {
        urlCount = await renderChartToUrl(cleanCountOption);
      }
      if (showShare) {
        urlShare = await renderChartToUrl(cleanShareOption);
      }

      document.body.removeChild(container);

      // Create merged canvas
      const totalHeight = isDual ? singleHeight * 2 : singleHeight;
      const finalCanvas = document.createElement("canvas");
      finalCanvas.width = exportWidth * dpr;
      finalCanvas.height = totalHeight * dpr;

      const ctx = finalCanvas.getContext("2d");
      if (!ctx) throw new Error("Canvas context not available");

      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, finalCanvas.width, finalCanvas.height);

      const loadImage = (url: string): Promise<HTMLImageElement> => {
        return new Promise((resolve, reject) => {
          const img = new Image();
          img.onload = () => resolve(img);
          img.onerror = reject;
          img.src = url;
        });
      };

      if (isDual && urlCount && urlShare) {
        // Dual view: Actual Count on Top, 100% Share on Bottom (matching user's reference)
        const [imgCount, imgShare] = await Promise.all([
          loadImage(urlCount),
          loadImage(urlShare),
        ]);
        ctx.drawImage(imgCount, 0, 0, exportWidth * dpr, singleHeight * dpr);
        ctx.drawImage(imgShare, 0, singleHeight * dpr, exportWidth * dpr, singleHeight * dpr);
      } else if (urlCount) {
        const imgCount = await loadImage(urlCount);
        ctx.drawImage(imgCount, 0, 0, exportWidth * dpr, singleHeight * dpr);
      } else if (urlShare) {
        const imgShare = await loadImage(urlShare);
        ctx.drawImage(imgShare, 0, 0, exportWidth * dpr, singleHeight * dpr);
      }

      finalCanvas.toBlob(async (blob) => {
        if (!blob) {
          setIsExporting(false);
          return;
        }

        const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, "");
        const fileName = `MAUDE_월별추이_PPT_${dateStr}.png`;

        if (action === "copy") {
          try {
            await navigator.clipboard.write([
              new ClipboardItem({ "image/png": blob }),
            ]);
            setExportToast("✓ 클립보드에 복사되었습니다! PPT에서 Ctrl+V 하세요.");
          } catch (clipErr) {
            console.warn("Clipboard write failed, downloading file instead:", clipErr);
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = fileName;
            a.click();
            URL.revokeObjectURL(url);
            setExportToast("✓ 클립보드 권한 제한으로 PNG 파일이 다운로드되었습니다.");
          }
        } else {
          const url = URL.createObjectURL(blob);
          const a = document.createElement("a");
          a.href = url;
          a.download = fileName;
          a.click();
          URL.revokeObjectURL(url);
          setExportToast("✓ 고해상도 PPT 이미지가 다운로드되었습니다.");
        }

        setTimeout(() => setExportToast(null), 3500);
        setIsExporting(false);
      }, "image/png");
    } catch (err) {
      console.error("Export error:", err);
      setExportToast("이미지 생성 중 오류가 발생했습니다.");
      setTimeout(() => setExportToast(null), 3000);
      setIsExporting(false);
    }
  };

  return (
    <div className="space-y-4 animate-fadeIn">
      {/* 1. Control Header Bar */}
      <div className="bg-slate-900/60 border border-slate-800 p-4 rounded-2xl backdrop-blur-md flex flex-col gap-3.5 shadow-xl">
        {/* Top Row: Perspective Modes, Time Grain, Layout and Theme Switcher */}
        <div className="flex flex-wrap items-center justify-between gap-3">
          {/* Left: 3 Main Perspective Modes & Mode Toggles */}
          <div className="flex flex-wrap items-center gap-2.5">
            {/* Perspective Selector Group */}
            <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
              <button
                type="button"
                onClick={() => setGroupBy("event_brand_breakdown")}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                  groupBy === "event_brand_breakdown"
                    ? "bg-indigo-600 text-white shadow-sm font-semibold"
                    : "text-slate-400 hover:text-slate-200"
                }`}
                title="특정 부작용(예: 오작동, 상해) 내에서 각 제품이 차지하는 비중(%) 및 시계열 점유율 분석"
              >
                <PieIcon className="w-3.5 h-3.5 text-amber-400" />
                <span>부작용 내 제품 점유율 (통합)</span>
              </button>
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
                <span>제품별 추이</span>
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
                <span>부작용 유형별 추이</span>
              </button>
            </div>

            {/* Canonical vs Raw Brand Toggle (when grouping includes brands) */}
            {groupBy !== "event_type" && (
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
                  🏷️ 대표 그룹
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
                <span>월별</span>
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
                <span>분기별</span>
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
                <span>연도별</span>
              </button>
            </div>
          </div>

          {/* Right: Layout View & White/Dark Background Switcher */}
          <div className="flex items-center gap-2.5">
            {/* View Layout Toggle: Dual (Both) vs Share Only vs Count Only */}
            <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
              <button
                type="button"
                onClick={() => setViewLayout("dual")}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                  viewLayout === "dual"
                    ? "bg-indigo-600 text-white font-semibold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
                title="상하 2단으로 비중(%) 그래프와 실제 수치(건수) 그래프를 동시에 표시"
              >
                <LayoutGrid className="w-3.5 h-3.5 text-indigo-300" />
                <span>% 비중 + 실제 건수 동시 보기</span>
              </button>
              <button
                type="button"
                onClick={() => setViewLayout("share_only")}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                  viewLayout === "share_only"
                    ? "bg-indigo-600 text-white font-semibold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                <Percent className="w-3.5 h-3.5" />
                <span>비중(%)만</span>
              </button>
              <button
                type="button"
                onClick={() => setViewLayout("count_only")}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-medium transition ${
                  viewLayout === "count_only"
                    ? "bg-indigo-600 text-white font-semibold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                <Hash className="w-3.5 h-3.5" />
                <span>실제 건수만</span>
              </button>
            </div>

            {/* Background Theme Switcher: Dark vs White Report Style */}
            <div className="flex items-center bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
              <button
                type="button"
                onClick={() => setThemeMode("dark")}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
                  themeMode === "dark"
                    ? "bg-slate-800 text-white font-semibold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
                title="기본 다크 대시보드 테마"
              >
                <Moon className="w-3.5 h-3.5 text-indigo-400" />
                <span>다크</span>
              </button>
              <button
                type="button"
                onClick={() => setThemeMode("light")}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-medium transition ${
                  themeMode === "light"
                    ? "bg-white text-slate-900 font-bold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
                title="보고서 / 인쇄 및 캡처용 깔끔한 화이트 배경 테마"
              >
                <Sun className="w-3.5 h-3.5 text-amber-500" />
                <span>화이트 (보고서용)</span>
              </button>
            </div>

            {/* PPT Export / Copy Button Group */}
            <div className="relative flex items-center bg-slate-950 p-1 rounded-xl border border-indigo-500/40 text-xs shadow-sm">
              <button
                type="button"
                onClick={() => handleExportPpt("copy")}
                disabled={isExporting}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold bg-indigo-600 hover:bg-indigo-500 text-white transition shadow-sm disabled:opacity-50"
                title="상/하 그래프를 여백 없이 PPT 슬라이드 규격으로 합쳐 클립보드에 복사합니다. PPT에서 바로 Ctrl+V 하실 수 있습니다."
              >
                {isExporting ? (
                  <Loader2 className="w-3.5 h-3.5 animate-spin text-white" />
                ) : (
                  <Copy className="w-3.5 h-3.5 text-indigo-200" />
                )}
                <span>{isExporting ? "캡처 중..." : "📋 PPT용 복사"}</span>
              </button>

              <button
                type="button"
                onClick={() => handleExportPpt("download")}
                disabled={isExporting}
                className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-slate-300 hover:text-white hover:bg-slate-800 transition disabled:opacity-50"
                title="합쳐진 고해상도 PPT 이미지를 PNG 파일로 다운로드합니다."
              >
                <Download className="w-3.5 h-3.5 text-slate-400" />
                <span>PNG</span>
              </button>

              {/* Toast message floating pill */}
              {exportToast && (
                <div className="absolute -bottom-9 right-0 bg-emerald-600 text-white text-[11px] font-semibold px-3 py-1 rounded-lg shadow-xl whitespace-nowrap z-50 animate-fadeIn flex items-center gap-1.5 border border-emerald-400/30">
                  <Check className="w-3.5 h-3.5 text-white" />
                  <span>{exportToast}</span>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Dynamic Secondary Bar */}
        {groupBy === "event_brand_breakdown" ? (
          /* MODE 1: Event Type Chooser for Brand Share within Event Type */
          <div className="pt-2 border-t border-slate-800/80 flex flex-wrap items-center justify-between gap-3 text-xs animate-fadeIn">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-slate-300 font-bold flex items-center gap-1.5 mr-1">
                <Sparkles className="w-3.5 h-3.5 text-indigo-400" />
                분석 대상 부작용 선택:
              </span>
              {EVENT_TYPES_CONFIG.map((et) => {
                const isActive = targetEventType === et.id;
                return (
                  <button
                    key={et.id}
                    type="button"
                    onClick={() => setTargetEventType(et.id)}
                    className={`flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-bold border transition ${
                      isActive
                        ? et.activeBtnBg + " shadow-md"
                        : "bg-slate-950/60 border-slate-800 text-slate-400 hover:border-slate-700 hover:text-white"
                    }`}
                  >
                    <span className={`w-2 h-2 rounded-full ${isActive ? "bg-white" : et.dotColor}`}></span>
                    <span>{et.label} 내 제품 비중</span>
                    {isActive && <Check className="w-3.5 h-3.5 ml-0.5" />}
                  </button>
                );
              })}
            </div>

            {/* Quick Top Ranking Summary Pills */}
            <div className="flex items-center gap-2 flex-wrap">
              <span className="text-[11px] text-slate-400 flex items-center gap-1">
                <Award className="w-3.5 h-3.5 text-amber-400" />
                누적 비중 상위:
              </span>
              {topRankings.map((r, idx) => (
                <span
                  key={r.brand}
                  className="px-2 py-0.5 rounded-md bg-slate-950/80 border border-slate-800 text-[11px] font-mono text-slate-300 flex items-center gap-1"
                >
                  <span className="text-indigo-400 font-bold">{idx + 1}위</span>
                  <span className="text-white truncate max-w-[120px]">{r.brand}</span>
                  <span className="text-emerald-400 font-bold">{r.pct}%</span>
                </span>
              ))}
            </div>
          </div>
        ) : groupBy === "brand" ? (
          /* MODE 2: Multi-select Event Type Filter for Brand Timeline */
          <div className="pt-2 border-t border-slate-800/80 flex flex-wrap items-center justify-between gap-2 text-xs animate-fadeIn">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-slate-400 font-semibold flex items-center gap-1.5 mr-1">
                <Filter className="w-3.5 h-3.5 text-indigo-400" />
                부작용 유형 필터:
              </span>

              <button
                type="button"
                onClick={handleSelectAllEventTypes}
                className={`px-3 py-1.5 rounded-xl text-xs font-semibold border transition ${
                  selectedEventTypes.length === 0
                    ? "bg-indigo-600 text-white border-indigo-500 shadow-sm"
                    : "bg-slate-950/60 border-slate-800 text-slate-400 hover:border-slate-700 hover:text-slate-300"
                }`}
              >
                전체 부작용 유형
              </button>

              {EVENT_TYPES_CONFIG.map((et) => {
                const isSelected = selectedEventTypes.includes(et.id);
                return (
                  <button
                    key={et.id}
                    type="button"
                    onClick={() => handleToggleEventTypeFilter(et.id)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border transition ${
                      isSelected
                        ? et.badgeBg + " shadow-sm"
                        : "bg-slate-950/60 border-slate-800 text-slate-400 hover:border-slate-700 hover:text-slate-300"
                    }`}
                  >
                    <span className={`w-2 h-2 rounded-full ${et.dotColor}`}></span>
                    <span>{et.label}</span>
                    {isSelected && <Check className="w-3 h-3 text-current ml-0.5" />}
                  </button>
                );
              })}
            </div>

            {selectedEventTypes.length > 0 && (
              <div className="text-[11px] text-indigo-300 bg-indigo-500/10 px-2.5 py-1 rounded-lg border border-indigo-500/20">
                💡 {selectedEventTypes.map((id) => EVENT_TYPE_MAP[id]?.nameKr || id).join(", ")} 건만 필터링 중
              </div>
            )}
          </div>
        ) : null}

        {/* Row 3: Custom Trend Grouping Toolbar (available when not in event_type mode) */}
        {groupBy !== "event_type" && (
          <div className="pt-2.5 border-t border-slate-800/80 flex flex-wrap items-center justify-between gap-3 text-xs animate-fadeIn">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-slate-300 font-bold flex items-center gap-1.5 mr-1">
                <FolderPlus className="w-3.5 h-3.5 text-indigo-400" />
                커스텀 제품 묶음(그룹):
              </span>

              {/* Open Group Manager Modal Button */}
              <button
                type="button"
                onClick={() => setIsGroupModalOpen(true)}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/40 font-semibold transition shadow-sm"
              >
                <Settings2 className="w-3.5 h-3.5 text-indigo-400" />
                <span>제품 묶음(그룹) 관리</span>
                {customGroups.length > 0 && (
                  <span className="px-1.5 py-0.2 rounded-full bg-indigo-500 text-white text-[10px] font-mono">
                    {customGroups.length}개
                  </span>
                )}
              </button>

              {/* Grouping Enable/Disable Switch */}
              {customGroups.length > 0 && (
                <>
                  <button
                    type="button"
                    onClick={() => handleToggleCustomGroupEnabled(!isCustomGroupEnabled)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl border text-xs font-bold transition ${
                      isCustomGroupEnabled
                        ? "bg-emerald-600 text-white border-emerald-500 shadow-sm"
                        : "bg-slate-950/60 border-slate-800 text-slate-400 hover:text-slate-200"
                    }`}
                  >
                    {isCustomGroupEnabled ? (
                      <Check className="w-3.5 h-3.5 text-white" />
                    ) : (
                      <Square className="w-3.5 h-3.5 text-slate-500" />
                    )}
                    <span>묶음 차트 {isCustomGroupEnabled ? "적용 중" : "적용 (OFF)"}</span>
                  </button>

                  {isCustomGroupEnabled && (
                    <button
                      type="button"
                      onClick={() => handleToggleHideUngrouped(!hideUngrouped)}
                      className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl border text-[11px] font-medium transition ${
                        hideUngrouped
                          ? "bg-sky-500/20 border-sky-500/40 text-sky-300"
                          : "bg-slate-950/40 border-slate-800 text-slate-400 hover:text-slate-300"
                      }`}
                      title="그룹에 지정되지 않은 기타 제품들을 차트에서 숨기고 지정된 그룹들만 비교합니다."
                    >
                      <span>{hideUngrouped ? "✓ 지정 그룹만 표시 (외 제품 숨김)" : "미지정 제품도 포함 표시"}</span>
                    </button>
                  )}
                </>
              )}
            </div>

            {/* Display active custom groups pill list */}
            {isCustomGroupEnabled && customGroups.length > 0 && (
              <div className="flex items-center gap-1.5 flex-wrap">
                <span className="text-[11px] text-slate-400">적용 그룹:</span>
                {customGroups.map((g) => (
                  <span
                    key={g.id}
                    className="px-2 py-0.5 rounded-md bg-slate-950/80 border border-slate-800 text-[11px] text-slate-200 flex items-center gap-1.5 font-mono"
                  >
                    <span className="w-2 h-2 rounded-full bg-indigo-400"></span>
                    <span className="font-semibold">{g.name}</span>
                    <span className="text-slate-400 text-[10px]">({g.brands.length}개 제품)</span>
                  </span>
                ))}
              </div>
            )}
          </div>
        )}
      </div>

      {/* 2. Interactive Series Select / Deselect Chips (Auto 100% Re-calculation) */}
      <div className="bg-slate-900/60 border border-slate-800 p-3.5 rounded-2xl flex flex-wrap items-center justify-between gap-3 text-xs">
        <div className="flex flex-wrap items-center gap-2">
          <span className="text-slate-400 font-semibold mr-1">
            {groupBy === "event_type"
              ? "표시 부작용 유형 선택:"
              : isCustomGroupEnabled && customGroups.length > 0
              ? "표시 그룹 선택:"
              : groupBy === "event_brand_breakdown"
              ? `[${activeEventConfig.nameKr}] 내 표시 제품 선택:`
              : "표시 제품 선택:"}
          </span>
          {allSeriesNames.map((name, idx) => {
            const isEnabled = !disabledSeries[name];
            const isEvent = groupBy === "event_type";
            const eventConfig = isEvent ? EVENT_TYPE_MAP[name] : null;
            const displayName = isEvent ? formatEventTypeName(name) : name;
            const countVal = totalSeriesCounts[name] || 0;
            const sharePct = overallTargetTotal > 0 ? ((countVal / overallTargetTotal) * 100).toFixed(1) : "0";
            const seriesColor = isEvent && eventConfig ? eventConfig.color : BRAND_COLOR_PALETTE[idx % BRAND_COLOR_PALETTE.length];

            return (
              <button
                key={name}
                type="button"
                onClick={() => toggleSeries(name)}
                className={`flex items-center gap-1.5 px-2.5 py-1 rounded-xl text-xs font-semibold border transition ${
                  isEnabled
                    ? "bg-slate-800/80 border-slate-700 text-white shadow-sm"
                    : "bg-slate-950/40 border-slate-800 text-slate-500 line-through opacity-60"
                }`}
              >
                {isEnabled ? (
                  <CheckSquare className="w-3 h-3 text-indigo-400 shrink-0" />
                ) : (
                  <Square className="w-3 h-3 text-slate-600 shrink-0" />
                )}
                <span className="w-2.5 h-2.5 rounded-sm shrink-0" style={{ background: seriesColor }}></span>
                <span>{displayName}</span>
                {countVal > 0 && (
                  <span className="text-[10px] font-mono opacity-80">
                    {groupBy === "event_brand_breakdown" ? `(${sharePct}%)` : `(${countVal.toLocaleString()})`}
                  </span>
                )}
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

      {/* ===================================================================== */}
      {/* 3. UPPER CHART: 100% Cumulative Share / Percentage Chart Card         */}
      {/* ===================================================================== */}
      {(viewLayout === "dual" || viewLayout === "share_only") && (
        <div className={`p-6 rounded-2xl backdrop-blur-md transition-colors duration-200 border flex flex-col ${themeStyles.cardBg}`}>
          <div className="flex flex-wrap items-center justify-between pb-3 border-b border-slate-200/20 mb-3 gap-3">
            <div>
              <h3 className={`text-sm font-bold flex items-center gap-2 ${themeStyles.headerText}`}>
                <span>
                  {groupBy === "event_brand_breakdown"
                    ? `[${activeEventConfig.label}] 월별 100% 누적 비중 ${isCustomGroupEnabled && customGroups.length > 0 ? "(커스텀 그룹별)" : ""}`
                    : groupBy === "event_type"
                    ? "부작용 유형별 100% 누적 비중 추이"
                    : `제품별 월별 100% 누적 비중 추이 ${isCustomGroupEnabled && customGroups.length > 0 ? "(커스텀 그룹별)" : ""}`}
                </span>
                <span className="text-xs px-2 py-0.5 bg-sky-500/20 text-sky-600 dark:text-sky-300 border border-sky-500/30 rounded-md font-normal">
                  선택된 {activeSeriesNames.length}개 {isCustomGroupEnabled && customGroups.length > 0 && groupBy !== "event_type" ? "그룹" : "항목"} 기준 100% 점유율
                </span>
              </h3>
              <p className={`text-[11px] mt-0.5 ${themeStyles.subText}`}>
                {isCustomGroupEnabled && customGroups.length > 0 && groupBy !== "event_type"
                  ? "사용자가 직접 정의한 제품 그룹별로 합산하여 100%로 환산한 누적 점유율 변화입니다."
                  : groupBy === "event_brand_breakdown"
                  ? `${activeEventConfig.nameKr}(${targetEventType}) 발생 건 중 각 브랜드가 차지하는 상대적 비중(%) 변화입니다.`
                  : "선택된 항목들의 합을 100%로 환산한 누적 점유율 변화입니다."}
              </p>
            </div>

            {/* Upper Chart Type Selector */}
            <div className="flex items-center gap-2">
              <div className="flex items-center bg-slate-100 dark:bg-slate-950 p-1 rounded-xl border border-slate-200 dark:border-slate-800 text-xs">
                <button
                  type="button"
                  onClick={() => setChartType("share")}
                  className={`px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    chartType === "share"
                      ? "bg-sky-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  100% 점유율 막대
                </button>
                <button
                  type="button"
                  onClick={() => setChartType("stacked_bar")}
                  className={`px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    chartType === "stacked_bar"
                      ? "bg-sky-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  누적 막대
                </button>
                <button
                  type="button"
                  onClick={() => setChartType("area")}
                  className={`px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    chartType === "area"
                      ? "bg-sky-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  영역 (Area)
                </button>
              </div>

              {/* Height Selector */}
              <div className="flex items-center gap-1 bg-slate-100 dark:bg-slate-950 px-2 py-1 rounded-xl border border-slate-200 dark:border-slate-800 text-xs">
                {[
                  { label: "320px", val: 320 },
                  { label: "380px", val: 380 },
                  { label: "480px", val: 480 },
                ].map((h) => (
                  <button
                    key={h.val}
                    type="button"
                    onClick={() => setChartHeight(h.val)}
                    className={`px-1.5 py-0.5 rounded text-[11px] transition ${
                      chartHeight === h.val
                        ? "bg-sky-600 text-white font-semibold"
                        : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                    }`}
                  >
                    {h.label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="w-full transition-[height] duration-150" style={{ height: `${chartHeight}px` }}>
            {loading ? (
              <div className="flex items-center justify-center h-full text-slate-400">
                추이 데이터를 계산 중입니다...
              </div>
            ) : timeKeys.length === 0 ? (
              <div className="flex items-center justify-center h-full text-slate-400">
                조회 조건에 해당하는 시계열 데이터가 없습니다.
              </div>
            ) : (
              <ReactECharts
                option={shareChartOption}
                style={{ height: `${chartHeight}px`, width: "100%" }}
                notMerge={true}
              />
            )}
          </div>
        </div>
      )}

      {/* ===================================================================== */}
      {/* 4. LOWER CHART: Absolute Count (Volume Trend) Chart Card              */}
      {/* ===================================================================== */}
      {(viewLayout === "dual" || viewLayout === "count_only") && (
        <div className={`p-6 rounded-2xl backdrop-blur-md transition-colors duration-200 border flex flex-col ${themeStyles.cardBg}`}>
          <div className="flex flex-wrap items-center justify-between pb-3 border-b border-slate-200/20 mb-3 gap-3">
            <div>
              <h3 className={`text-sm font-bold flex items-center gap-2 ${themeStyles.headerText}`}>
                <span>
                  {groupBy === "event_brand_breakdown"
                    ? `${activeEventConfig.label} 월별 실제 건수 추이 ${isCustomGroupEnabled && customGroups.length > 0 ? "(커스텀 그룹별)" : ""}`
                    : groupBy === "event_type"
                    ? "부작용 유형별 월별 실제 건수 추이"
                    : `제품별 월별 실제 발생 건수 추이 ${isCustomGroupEnabled && customGroups.length > 0 ? "(커스텀 그룹별)" : ""}`}
                </span>
                <span className="text-xs px-2 py-0.5 bg-emerald-500/20 text-emerald-600 dark:text-emerald-300 border border-emerald-500/30 rounded-md font-normal">
                  실제 보고 수치 (건수)
                </span>
              </h3>
              <p className={`text-[11px] mt-0.5 ${themeStyles.subText}`}>
                {isCustomGroupEnabled && customGroups.length > 0 && groupBy !== "event_type"
                  ? `사용자 정의 그룹별로 합산된 실제 MAUDE 보고 수량(총 ${overallTargetTotal.toLocaleString()}건)의 시계열 변화입니다.`
                  : groupBy === "event_brand_breakdown"
                  ? `해당 기간 ${activeEventConfig.nameKr}로 접수된 실제 보고 수량(총 ${overallTargetTotal.toLocaleString()}건)의 시계열 변화입니다.`
                  : "선택된 기간 동안 접수된 실제 MAUDE 보고 건수의 절대 수량 변화입니다."}
              </p>
            </div>

            {/* Lower Count Chart Controls */}
            <div className="flex items-center gap-2">
              <div className="flex items-center bg-slate-100 dark:bg-slate-950 p-1 rounded-xl border border-slate-200 dark:border-slate-800 text-xs">
                <button
                  type="button"
                  onClick={() => setCountChartType("line")}
                  className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    countChartType === "line"
                      ? "bg-emerald-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  <LineChart className="w-3.5 h-3.5" />
                  <span>선형 (Line)</span>
                </button>
                <button
                  type="button"
                  onClick={() => setCountChartType("stacked_bar")}
                  className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    countChartType === "stacked_bar"
                      ? "bg-emerald-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  <BarChart2 className="w-3.5 h-3.5" />
                  <span>누적 막대</span>
                </button>
                <button
                  type="button"
                  onClick={() => setCountChartType("area")}
                  className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    countChartType === "area"
                      ? "bg-emerald-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  <TrendingUp className="w-3.5 h-3.5" />
                  <span>영역 (Area)</span>
                </button>
                <button
                  type="button"
                  onClick={() => setCountChartType("grouped_bar")}
                  className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-semibold transition ${
                    countChartType === "grouped_bar"
                      ? "bg-emerald-600 text-white shadow-sm"
                      : "text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200"
                  }`}
                >
                  <span>개별 막대</span>
                </button>
              </div>
            </div>
          </div>

          <div className="w-full transition-[height] duration-150" style={{ height: `${chartHeight}px` }}>
            {loading ? (
              <div className="flex items-center justify-center h-full text-slate-400">
                추이 데이터를 계산 중입니다...
              </div>
            ) : timeKeys.length === 0 ? (
              <div className="flex items-center justify-center h-full text-slate-400">
                조회 조건에 해당하는 시계열 데이터가 없습니다.
              </div>
            ) : (
              <ReactECharts
                option={countChartOption}
                style={{ height: `${chartHeight}px`, width: "100%" }}
                notMerge={true}
              />
            )}
          </div>
        </div>
      )}

      {/* 5. Custom Trend Group Modal */}
      <CustomTrendGroupModal
        isOpen={isGroupModalOpen}
        onClose={() => setIsGroupModalOpen(false)}
        availableBrands={availableBrands}
        groups={customGroups}
        onSaveGroups={handleSaveCustomGroups}
      />
    </div>
  );
};
