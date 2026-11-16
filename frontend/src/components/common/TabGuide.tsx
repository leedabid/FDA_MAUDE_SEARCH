import React, { useState, useEffect } from "react";
import {
  HelpCircle,
  ChevronDown,
  ChevronUp,
  Info,
  BookOpen,
  Sparkles,
  Tag,
  ShieldCheck,
  CheckCircle2,
} from "lucide-react";

export interface GuideItem {
  term: string;
  badge?: string;
  badgeColor?: "cyan" | "indigo" | "emerald" | "amber" | "rose" | "slate";
  description: string;
}

export interface TabGuideProps {
  tabKey: string;
  title: string;
  subtitle: string;
  purpose: string;
  items: GuideItem[];
  tips?: string[];
  defaultOpen?: boolean;
}

const BADGE_STYLES: Record<string, string> = {
  cyan: "bg-cyan-950/80 text-cyan-300 border-cyan-500/30",
  indigo: "bg-indigo-950/80 text-indigo-300 border-indigo-500/30",
  emerald: "bg-emerald-950/80 text-emerald-300 border-emerald-500/30",
  amber: "bg-amber-950/80 text-amber-300 border-amber-500/30",
  rose: "bg-rose-950/80 text-rose-300 border-rose-500/30",
  slate: "bg-slate-900 text-slate-300 border-slate-700",
};

export const TabGuide: React.FC<TabGuideProps> = ({
  tabKey,
  title,
  subtitle,
  purpose,
  items,
  tips = [],
  defaultOpen = false,
}) => {
  const storageKey = `cgm_recall_guide_${tabKey}`;
  const [isOpen, setIsOpen] = useState<boolean>(() => {
    try {
      const saved = localStorage.getItem(storageKey);
      if (saved !== null) {
        return saved === "true";
      }
      return defaultOpen;
    } catch {
      return defaultOpen;
    }
  });

  const toggleOpen = () => {
    setIsOpen((prev) => {
      const next = !prev;
      try {
        localStorage.setItem(storageKey, String(next));
      } catch (e) {
        console.error(e);
      }
      return next;
    });
  };

  return (
    <div className="mb-6 rounded-2xl bg-gradient-to-r from-slate-900/90 via-slate-900/60 to-slate-950/90 border border-slate-800/90 backdrop-blur-md shadow-lg transition-all duration-300 overflow-hidden">
      {/* Collapsible Header Banner */}
      <div
        onClick={toggleOpen}
        className="px-4 py-3 flex items-center justify-between gap-3 cursor-pointer hover:bg-slate-800/30 transition-colors select-none"
      >
        <div className="flex items-center gap-2.5 min-w-0">
          <div className="w-6 h-6 rounded-lg bg-cyan-500/10 border border-cyan-500/30 flex items-center justify-center shrink-0">
            <HelpCircle className="w-3.5 h-3.5 text-cyan-400" />
          </div>
          <div className="flex items-center gap-2 truncate">
            <span className="text-xs font-bold text-slate-100">{title}</span>
            <span className="text-slate-500 hidden sm:inline">|</span>
            <span className="text-[11px] text-slate-400 truncate hidden md:inline">
              {subtitle}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2 shrink-0">
          <span className="text-[11px] font-semibold text-cyan-400 bg-cyan-950/60 px-2 py-0.5 rounded-full border border-cyan-500/20">
            {isOpen ? "설명 접기" : "라벨 및 용어 가이드 보기"}
          </span>
          <div className="text-slate-400 hover:text-white transition-transform">
            {isOpen ? (
              <ChevronUp className="w-4 h-4" />
            ) : (
              <ChevronDown className="w-4 h-4" />
            )}
          </div>
        </div>
      </div>

      {/* Expanded Content Drawer */}
      {isOpen && (
        <div className="px-5 pb-5 pt-2 border-t border-slate-800/70 space-y-4 text-xs animate-in fade-in slide-in-from-top-1 duration-200">
          {/* Purpose & Objective */}
          <div className="bg-slate-950/70 border border-slate-800/80 rounded-xl p-3.5 flex items-start gap-3">
            <Info className="w-4 h-4 text-cyan-400 shrink-0 mt-0.5" />
            <div>
              <span className="font-bold text-cyan-300 block mb-0.5">화면 목적 및 활용 가이드</span>
              <p className="text-slate-300 leading-relaxed">{purpose}</p>
            </div>
          </div>

          {/* Key Terminology & Labels Grid */}
          <div>
            <div className="flex items-center gap-1.5 text-slate-300 font-bold mb-2">
              <Tag className="w-3.5 h-3.5 text-indigo-400" />
              <span>핵심 라벨 및 용어 설명</span>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2.5">
              {items.map((item, idx) => {
                const badgeColorClass = BADGE_STYLES[item.badgeColor || "cyan"];
                return (
                  <div
                    key={idx}
                    className="bg-slate-900/60 border border-slate-800 rounded-xl p-3 hover:border-slate-700 transition"
                  >
                    <div className="flex items-center justify-between gap-2 mb-1.5">
                      <span className="font-bold text-slate-100">{item.term}</span>
                      {item.badge && (
                        <span
                          className={`px-1.5 py-0.5 rounded text-[10px] font-mono font-bold border ${badgeColorClass}`}
                        >
                          {item.badge}
                        </span>
                      )}
                    </div>
                    <p className="text-slate-400 text-[11px] leading-relaxed">{item.description}</p>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Practical Tips (Optional) */}
          {tips.length > 0 && (
            <div className="bg-emerald-950/20 border border-emerald-500/20 rounded-xl p-3 space-y-1.5">
              <div className="flex items-center gap-1.5 text-emerald-400 font-bold text-[11px]">
                <Sparkles className="w-3.5 h-3.5" />
                <span>R&D 및 인허가(RA) 실무 팁</span>
              </div>
              <ul className="space-y-1 text-slate-300 text-[11px] pl-4 list-disc">
                {tips.map((tip, idx) => (
                  <li key={idx} className="leading-relaxed">
                    {tip}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
