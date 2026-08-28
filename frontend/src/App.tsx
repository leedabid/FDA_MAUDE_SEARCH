import React, { useState, useEffect, useCallback } from "react";
import { Header } from "./components/layout/Header";
import { Sidebar } from "./components/layout/Sidebar";
import { OverviewTab } from "./components/tabs/OverviewTab";
import { ReportsTab } from "./components/tabs/ReportsTab";
import { MonthlyTrendTab } from "./components/tabs/MonthlyTrendTab";
import { ProblemCodesTab } from "./components/tabs/ProblemCodesTab";
import { InsightsTab } from "./components/tabs/InsightsTab";
import { BookmarksTab } from "./components/tabs/BookmarksTab";
import { BrandGroupManagerModal } from "./components/modals/BrandGroupManagerModal";
import { SyncModal } from "./components/modals/SyncModal";

import {
  getMetadata,
  getOverviewStats,
  getMonthlyStats,
  getProblemCodes,
  getInsights,
} from "./api/client";

import type {
  FilterState,
  Metadata,
  OverviewStats,
  MonthlyDataPoint,
  ProblemCodeItem,
  InsightsData,
} from "./types";

const INITIAL_FILTERS: FilterState = {
  categories: ["CGM"],
  brands: [],
  event_types: [],
  date_from: "",
  date_to: "",
  keyword: "",
  code_filter: "",
};

export const App: React.FC = () => {
  // Navigation
  const [activeTab, setActiveTab] = useState<string>("overview");

  // Filter States: staged (editing) vs applied (querying)
  const [stagedFilters, setStagedFilters] = useState<FilterState>(INITIAL_FILTERS);
  const [appliedFilters, setAppliedFilters] = useState<FilterState>(INITIAL_FILTERS);

  // Selected Report Number (from bookmarks or other tabs)
  const [selectedReportNumber, setSelectedReportNumber] = useState<string | null>(null);

  // Metadata & Lookups
  const [metadata, setMetadata] = useState<Metadata | null>(null);

  // Data States
  const [overviewStats, setOverviewStats] = useState<OverviewStats | null>(null);
  const [monthlyStats, setMonthlyStats] = useState<MonthlyDataPoint[]>([]);
  const [patientProblems, setPatientProblems] = useState<ProblemCodeItem[]>([]);
  const [productProblems, setProductProblems] = useState<ProblemCodeItem[]>([]);
  const [insightsData, setInsightsData] = useState<InsightsData | null>(null);

  // Loadings
  const [loadingOverview, setLoadingOverview] = useState<boolean>(false);
  const [loadingMonthly, setLoadingMonthly] = useState<boolean>(false);
  const [loadingProblems, setLoadingProblems] = useState<boolean>(false);
  const [loadingInsights, setLoadingInsights] = useState<boolean>(false);

  // Modals
  const [isBrandManagerOpen, setIsBrandManagerOpen] = useState<boolean>(false);
  const [isSyncModalOpen, setIsSyncModalOpen] = useState<boolean>(false);

  // 1. Initial Load: Metadata
  const fetchMetadata = async () => {
    try {
      const data = await getMetadata();
      setMetadata(data);
    } catch (err) {
      console.error("Failed to load metadata:", err);
    }
  };

  useEffect(() => {
    fetchMetadata();
  }, []);

  // 2. Fetch Tab Specific Data
  const fetchDashboardData = useCallback(async () => {
    if (activeTab === "overview") {
      setLoadingOverview(true);
      try {
        const data = await getOverviewStats(appliedFilters);
        setOverviewStats(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoadingOverview(false);
      }
    } else if (activeTab === "monthly") {
      setLoadingMonthly(true);
      try {
        const data = await getMonthlyStats(appliedFilters);
        setMonthlyStats(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoadingMonthly(false);
      }
    } else if (activeTab === "problems") {
      setLoadingProblems(true);
      try {
        const data = await getProblemCodes(appliedFilters, 30);
        setPatientProblems(data.patient_problems || []);
        setProductProblems(data.product_problems || []);
      } catch (err) {
        console.error(err);
      } finally {
        setLoadingProblems(false);
      }
    } else if (activeTab === "insights") {
      setLoadingInsights(true);
      try {
        const data = await getInsights(appliedFilters);
        setInsightsData(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoadingInsights(false);
      }
    }
  }, [activeTab, appliedFilters]);

  useEffect(() => {
    fetchDashboardData();
  }, [fetchDashboardData]);

  // Apply filters trigger
  const handleApplyFilters = () => {
    setAppliedFilters(stagedFilters);
  };

  // Reset filters
  const handleResetFilters = () => {
    setStagedFilters(INITIAL_FILTERS);
    setAppliedFilters(INITIAL_FILTERS);
  };

  // On Brand Group Saved
  const handleBrandGroupsSaved = () => {
    fetchMetadata();
    fetchDashboardData();
  };

  return (
    <div className="flex flex-col h-screen w-screen bg-slate-950 text-slate-100 font-sans overflow-hidden">
      {/* Header */}
      <Header
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        totalRecords={metadata?.total_reports || 3979575}
        dbPath={metadata?.db_path}
        onOpenSyncModal={() => setIsSyncModalOpen(true)}
      />

      {/* Main Content Layout */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left Filter Sidebar */}
        <Sidebar
          stagedFilters={stagedFilters}
          setStagedFilters={setStagedFilters}
          appliedFilters={appliedFilters}
          onApplyFilters={handleApplyFilters}
          metadata={metadata}
          onReset={handleResetFilters}
          onOpenBrandManager={() => setIsBrandManagerOpen(true)}
        />

        {/* Dynamic Tab Body */}
        <main className="flex-1 overflow-y-auto p-6 custom-scrollbar bg-gradient-to-br from-slate-950 via-slate-900/40 to-slate-950">
          {activeTab === "overview" && (
            <OverviewTab
              stats={overviewStats}
              loading={loadingOverview}
              filters={appliedFilters}
              metadata={metadata}
              onOpenSyncModal={() => setIsSyncModalOpen(true)}
            />
          )}

          {activeTab === "reports" && (
            <ReportsTab
              filters={appliedFilters}
              selectedReportNumber={selectedReportNumber}
              onClearSelectedReport={() => setSelectedReportNumber(null)}
            />
          )}

          {activeTab === "monthly" && (
            <MonthlyTrendTab
              data={monthlyStats}
              loading={loadingMonthly}
              metadata={metadata}
            />
          )}

          {activeTab === "problems" && (
            <ProblemCodesTab
              patientProblems={patientProblems}
              productProblems={productProblems}
              loading={loadingProblems}
              onSelectCode={(code) => {
                setStagedFilters((prev) => ({ ...prev, code_filter: code }));
                setAppliedFilters((prev) => ({ ...prev, code_filter: code }));
                setActiveTab("reports");
              }}
            />
          )}

          {activeTab === "insights" && (
            <InsightsTab
              insights={insightsData}
              loading={loadingInsights}
            />
          )}

          {activeTab === "bookmarks" && (
            <BookmarksTab
              onOpenReportDetail={(rnum) => {
                setSelectedReportNumber(rnum);
                setActiveTab("reports");
              }}
            />
          )}
        </main>
      </div>

      {/* Brand Group Manager Modal */}
      <BrandGroupManagerModal
        isOpen={isBrandManagerOpen}
        onClose={() => setIsBrandManagerOpen(false)}
        onSaved={handleBrandGroupsSaved}
      />

      {/* Real-time OpenFDA Sync Engine Modal */}
      <SyncModal
        isOpen={isSyncModalOpen}
        onClose={() => setIsSyncModalOpen(false)}
        metadata={metadata}
        onSyncCompleted={() => {
          fetchMetadata();
          fetchDashboardData();
        }}
      />
    </div>
  );
};

export default App;
