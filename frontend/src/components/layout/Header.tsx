import React from "react";
import {
  Activity,
  BarChart3,
  FileText,
  TrendingUp,
  AlertTriangle,
  Lightbulb,
  Database,
  Cpu,
  Star,
  ShieldAlert,
  ShieldCheck,
} from "lucide-react";

interface HeaderProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  totalRecords: number;
  dbPath?: string;
  bookmarkCount?: number;
  onOpenSyncModal?: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  activeTab,
  setActiveTab,
  totalRecords,
  dbPath,
  bookmarkCount = 0,
  onOpenSyncModal,
}) => {
  const navItems = [
    { id: "overview", label: "종합 개요", icon: BarChart3 },
    { id: "reports", label: "전체 보고서", icon: FileText },
    { id: "monthly", label: "월별 추이", icon: TrendingUp },
    { id: "hazards", label: "위해 분석", icon: ShieldAlert },
    { id: "confirmed_hazards", label: "확정 위해 항목", icon: ShieldCheck },
    { id: "codes", label: "문제 코드 (Annex)", icon: AlertTriangle },
    { id: "insights", label: "안전성 인사이트", icon: Lightbulb },
    { id: "bookmarks", label: "⭐ 보관함 & 태그", icon: Star, badge: bookmarkCount },
  ];

  return (
    <header className="bg-slate-900/80 backdrop-blur-md border-b border-slate-800 sticky top-0 z-30 px-6 py-3.5 flex items-center justify-between transition-all">
      {/* Brand & System Status */}
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-tr from-indigo-600 to-violet-500 rounded-xl shadow-lg shadow-indigo-500/30 text-white">
            <Activity className="w-6 h-6 animate-pulse" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-lg font-bold text-white tracking-tight">
                FDA MAUDE Intelligence
              </h1>
              <span className="px-2 py-0.5 text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                LIVE v2.1
              </span>
            </div>
            <p className="text-xs text-slate-400 font-medium">
              연속혈당측정기 (CGM) 및 인슐린 펌프 부작용 심층 분석 플랫폼
            </p>
          </div>
        </div>

        {/* Database Metric & Sync Trigger Badge */}
        <button
          onClick={onOpenSyncModal}
          type="button"
          title="OpenFDA 최신 데이터 수집 / 갱신 모달 열기"
          className="hidden lg:flex items-center gap-2 px-3 py-1.5 bg-slate-800/80 hover:bg-slate-800 border border-slate-700/80 hover:border-indigo-500/50 rounded-xl text-xs text-slate-300 transition group cursor-pointer"
        >
          <Database className="w-3.5 h-3.5 text-indigo-400 group-hover:scale-110 transition" />
          <span>전체 DB:</span>
          <span className="font-semibold text-white font-mono">
            {totalRecords ? totalRecords.toLocaleString() : "3,979,575"}
          </span>
          <span className="text-[10px] text-indigo-300 bg-indigo-500/20 group-hover:bg-indigo-500/30 px-1.5 py-0.5 rounded border border-indigo-500/30 flex items-center gap-1">
            🔄 DB 갱신
          </span>
        </button>
      </div>

      {/* Main Tabs Navigation */}
      <nav className="flex items-center gap-1.5 bg-slate-950/60 p-1.5 rounded-2xl border border-slate-800/80">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all relative ${
                isActive
                  ? "bg-gradient-to-r from-indigo-600 to-indigo-500 text-white shadow-md shadow-indigo-600/30 scale-[1.02]"
                  : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/60"
              }`}
            >
              <Icon className={`w-4 h-4 ${isActive ? "text-white" : "text-slate-400"}`} />
              <span>{item.label}</span>
              {item.badge !== undefined && item.badge > 0 && (
                <span
                  className={`px-1.5 py-0.2 text-[10px] rounded-full font-bold ${
                    isActive
                      ? "bg-white text-indigo-600"
                      : "bg-amber-500/20 text-amber-300 border border-amber-500/30"
                  }`}
                >
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </nav>
    </header>
  );
};
