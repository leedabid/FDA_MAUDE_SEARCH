import React, { useState } from "react";
import { Tag, ArrowUpRight, Search, Activity, Cpu } from "lucide-react";
import { ProblemCodeItem } from "../../types";

interface ProblemCodesTabProps {
  patientProblems: ProblemCodeItem[];
  productProblems: ProblemCodeItem[];
  loading: boolean;
  onSelectCode: (code: string) => void;
}

export const ProblemCodesTab: React.FC<ProblemCodesTabProps> = ({
  patientProblems,
  productProblems,
  loading,
  onSelectCode,
}) => {
  const [activeSubTab, setActiveSubTab] = useState<"patient" | "device">("patient");
  const [search, setSearch] = useState("");

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="flex flex-col items-center space-y-3">
          <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-sm text-slate-400">문제 코드 통계를 집계 중입니다...</p>
        </div>
      </div>
    );
  }

  const currentList = Array.isArray(activeSubTab === "patient" ? patientProblems : productProblems)
    ? (activeSubTab === "patient" ? patientProblems : productProblems)
    : [];
  const filteredList = currentList.filter(
    (item) =>
      String(item?.term || "").toLowerCase().includes(search.toLowerCase()) ||
      String(item?.code || "").toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header & Sub-Tab Navigation */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 bg-slate-900 border border-slate-800 p-4 rounded-2xl">
        <div>
          <h3 className="text-sm font-bold text-white flex items-center gap-2">
            <Tag className="w-4 h-4 text-indigo-400" />
            FDA 공식 문제 코드 (Annex A & E) 분석
          </h3>
          <p className="text-xs text-slate-400 mt-0.5">
            FDA 표준 용어 및 코드별 발생 빈도를 확인하고, 클릭 시 해당 보고서 목록으로 즉시 드릴다운합니다.
          </p>
        </div>

        <div className="flex items-center gap-2 text-xs">
          <button
            onClick={() => setActiveSubTab("patient")}
            className={`px-3 py-2 rounded-xl font-semibold flex items-center gap-1.5 transition-all ${
              activeSubTab === "patient"
                ? "bg-indigo-600 text-white shadow-lg shadow-indigo-600/30"
                : "bg-slate-800 text-slate-400 hover:text-white"
            }`}
          >
            <Activity className="w-3.5 h-3.5" />
            환자 증상 (Annex E)
          </button>
          <button
            onClick={() => setActiveSubTab("device")}
            className={`px-3 py-2 rounded-xl font-semibold flex items-center gap-1.5 transition-all ${
              activeSubTab === "device"
                ? "bg-cyan-600 text-white shadow-lg shadow-cyan-600/30"
                : "bg-slate-800 text-slate-400 hover:text-white"
            }`}
          >
            <Cpu className="w-3.5 h-3.5" />
            기기 문제 (Annex A)
          </button>
        </div>
      </div>

      {/* Code Search & Filter Bar */}
      <div className="flex items-center justify-between bg-slate-900 border border-slate-800 p-3 rounded-xl">
        <div className="relative w-full max-w-xs">
          <input
            type="text"
            placeholder="코드 번호 또는 용어 검색..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-slate-800 border border-slate-700 text-xs text-white rounded-lg pl-8 pr-3 py-1.5 focus:outline-none focus:border-blue-500"
          />
          <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-2.5" />
        </div>

        <div className="text-xs text-slate-400">
          총 <span className="font-bold text-white">{filteredList.length}</span>개 코드 항목
        </div>
      </div>

      {/* Problem Code Table */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-300">
            <thead className="bg-slate-800/80 text-slate-400 uppercase text-[11px] font-semibold border-b border-slate-700/80">
              <tr>
                <th className="px-4 py-3 w-28">FDA 코드</th>
                <th className="px-4 py-3">표준 용어 (Annex Term)</th>
                <th className="px-4 py-3 w-28 text-right">발생 건수</th>
                <th className="px-4 py-3">브랜드별 분포</th>
                <th className="px-4 py-3 w-20 text-center">탐색</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {filteredList.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-12 text-center text-slate-500">
                    검색 조건에 맞는 문제 코드가 없습니다.
                  </td>
                </tr>
              ) : (
                filteredList.map((item, idx) => (
                  <tr
                    key={idx}
                    onClick={() => item.code && item.code !== "-" && onSelectCode(item.code)}
                    className="hover:bg-blue-600/10 cursor-pointer transition-colors group"
                  >
                    <td className="px-4 py-3">
                      <span className="font-mono font-bold px-2 py-1 rounded bg-slate-800 text-blue-400 border border-slate-700">
                        {item.code}
                      </span>
                    </td>
                    <td className="px-4 py-3 font-semibold text-white">
                      {item.term}
                    </td>
                    <td className="px-4 py-3 text-right font-mono font-bold text-slate-200">
                      {Number(item?.count || 0).toLocaleString()}건
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex flex-wrap gap-1 max-w-md">
                        {Object.entries(item.brand_breakdown || {})
                          .sort((a, b) => b[1] - a[1])
                          .slice(0, 4)
                          .map(([brand, cnt], bidx) => (
                            <span
                              key={bidx}
                              className="px-1.5 py-0.5 rounded text-[10px] bg-slate-800/80 text-slate-300 border border-slate-700/60 flex items-center gap-1"
                            >
                              <span className="truncate max-w-[120px]">{brand}</span>
                              <span className="font-bold text-blue-400">({cnt})</span>
                            </span>
                          ))}
                      </div>
                    </td>
                    <td className="px-4 py-3 text-center">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          if (item.code && item.code !== "-") onSelectCode(item.code);
                        }}
                        className="p-1.5 rounded-lg bg-slate-800 group-hover:bg-blue-600 text-slate-400 group-hover:text-white transition-colors"
                        title="해당 코드로 필터링하여 보고서 보기"
                      >
                        <ArrowUpRight className="w-3.5 h-3.5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
