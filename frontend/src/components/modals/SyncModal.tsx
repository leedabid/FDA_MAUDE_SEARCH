import React, { useState, useEffect, useRef } from "react";
import {
  X,
  RefreshCw,
  Calendar,
  Zap,
  CheckCircle2,
  AlertTriangle,
  Database,
  Terminal,
  ArrowRight,
} from "lucide-react";
import { getSyncStatus, startSync, type SyncStatusResponse } from "../../api/client";
import type { Metadata } from "../../types";

interface SyncModalProps {
  isOpen: boolean;
  onClose: () => void;
  metadata: Metadata | null;
  onSyncCompleted: () => void;
}

export const SyncModal: React.FC<SyncModalProps> = ({
  isOpen,
  onClose,
  metadata,
  onSyncCompleted,
}) => {
  const [mode, setMode] = useState<"incremental" | "custom">("incremental");
  const [dateFrom, setDateFrom] = useState<string>("2024-01-01");
  const [dateTo, setDateTo] = useState<string>(new Date().toISOString().split("T")[0]);
  const [status, setStatus] = useState<SyncStatusResponse | null>(null);
  const [polling, setPolling] = useState<boolean>(false);
  const [autoScroll, setAutoScroll] = useState<boolean>(true);
  const logContainerRef = useRef<HTMLDivElement>(null);
  const isUserScrolledUp = useRef<boolean>(false);

  // Poll status while modal is open or while running
  useEffect(() => {
    if (!isOpen) return;

    const checkStatus = async () => {
      try {
        const s = await getSyncStatus();
        setStatus(s);
        if (s.is_running) {
          setPolling(true);
        }
      } catch (err) {
        console.error("Failed to check sync status:", err);
      }
    };

    checkStatus();
    const interval = setInterval(checkStatus, 1000);
    return () => clearInterval(interval);
  }, [isOpen]);

  // Handle scroll events to detect if user scrolled up to read past logs
  const handleLogScroll = () => {
    if (logContainerRef.current) {
      const { scrollTop, scrollHeight, clientHeight } = logContainerRef.current;
      // If user is near bottom (within 40px), keep autoScroll active
      const isNearBottom = scrollHeight - scrollTop - clientHeight < 40;
      isUserScrolledUp.current = !isNearBottom;
    }
  };

  // Smart Auto-scroll logs: only scroll down if autoScroll is on and user hasn't scrolled up
  useEffect(() => {
    if (autoScroll && !isUserScrolledUp.current && logContainerRef.current) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  }, [status?.logs, autoScroll]);

  const scrollToBottom = () => {
    isUserScrolledUp.current = false;
    if (logContainerRef.current) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  };

  const handleStartSync = async () => {
    try {
      await startSync({
        mode,
        date_from: mode === "custom" ? dateFrom : undefined,
        date_to: mode === "custom" ? dateTo : undefined,
      });
      setPolling(true);
    } catch (err: any) {
      alert("동기화 시작 실패: " + (err.message || err));
    }
  };

  if (!isOpen) return null;

  const isRunning = status?.is_running;
  const isDone = !isRunning && status?.current_step?.includes("완료");
  const progressPercent =
    status?.total_target && status.total_target > 0
      ? Math.min(100, Math.round((status.processed_count / status.total_target) * 100))
      : isDone
      ? 100
      : isRunning
      ? 15
      : 0;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 backdrop-blur-md p-4 animate-fadeIn">
      <div className="bg-slate-900 border border-slate-700 rounded-3xl w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col max-h-[90vh]">
        {/* Modal Header */}
        <div className="p-5 border-b border-slate-800 bg-slate-950/80 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-indigo-500/20 text-indigo-400 rounded-2xl border border-indigo-500/30">
              <RefreshCw className={`w-5 h-5 ${isRunning ? "animate-spin" : ""}`} />
            </div>
            <div>
              <h2 className="text-base font-bold text-white flex items-center gap-2">
                OpenFDA MAUDE 최신 데이터 실시간 수집 / 갱신
              </h2>
              <p className="text-xs text-slate-400">
                FDA API에서 신규 접수 및 수정된 CGM/인슐린 펌프 MDR 데이터를 DB에 증분 반영합니다.
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            disabled={isRunning}
            className="p-2 text-slate-400 hover:text-white rounded-xl hover:bg-slate-800 disabled:opacity-30 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 space-y-5 overflow-y-auto custom-scrollbar text-xs">
          {/* Current DB Status Info Card */}
          <div className="grid grid-cols-3 gap-3 p-4 bg-slate-950/60 border border-slate-800 rounded-2xl">
            <div>
              <span className="text-slate-500 block text-[11px] mb-0.5">현재 DB 총 보고 건수</span>
              <span className="font-mono font-bold text-white text-sm">
                {metadata?.total_reports?.toLocaleString() || "3,979,575"}건
              </span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px] mb-0.5">DB 데이터 수집 기간</span>
              <span className="font-mono font-semibold text-indigo-300">
                {metadata?.min_date || "2020-01-02"} ~ {metadata?.max_date || "현재"}
              </span>
            </div>
            <div>
              <span className="text-slate-500 block text-[11px] mb-0.5">동기화 방식</span>
              <span className="font-semibold text-emerald-400 flex items-center gap-1">
                <CheckCircle2 className="w-3.5 h-3.5" />
                스마트 UPSERT 갱신
              </span>
            </div>
          </div>

          {/* Sync Mode Selection */}
          <div className="space-y-3">
            <label className="font-bold text-white text-xs block">수집 모드 선택</label>
            <div className="grid grid-cols-2 gap-3">
              {/* Option 1: Incremental */}
              <div
                onClick={() => !isRunning && setMode("incremental")}
                className={`p-4 rounded-2xl border cursor-pointer transition flex flex-col justify-between ${
                  mode === "incremental"
                    ? "bg-indigo-600/20 border-indigo-500 text-white shadow-lg"
                    : "bg-slate-950/40 border-slate-800 text-slate-400 hover:border-slate-700"
                } ${isRunning ? "opacity-60 pointer-events-none" : ""}`}
              >
                <div className="flex items-center gap-2 font-bold mb-1">
                  <Zap className="w-4 h-4 text-amber-400" />
                  <span>최신 증분 수집 (추천)</span>
                </div>
                <p className="text-[11px] text-slate-400 leading-relaxed">
                  마지막 수집일 이후 새롭게 접수되거나 FDA에서 수정된 최신 데이터만 빠르게 가져옵니다.
                </p>
              </div>

              {/* Option 2: Custom Date Range */}
              <div
                onClick={() => !isRunning && setMode("custom")}
                className={`p-4 rounded-2xl border cursor-pointer transition flex flex-col justify-between ${
                  mode === "custom"
                    ? "bg-indigo-600/20 border-indigo-500 text-white shadow-lg"
                    : "bg-slate-950/40 border-slate-800 text-slate-400 hover:border-slate-700"
                } ${isRunning ? "opacity-60 pointer-events-none" : ""}`}
              >
                <div className="flex items-center gap-2 font-bold mb-1">
                  <Calendar className="w-4 h-4 text-indigo-400" />
                  <span>특정 기간 지정 갱신</span>
                </div>
                <p className="text-[11px] text-slate-400 leading-relaxed">
                  원하는 기간을 직접 지정하여 해당 기간에 접수/수정된 모든 데이터를 정밀 재수집합니다.
                </p>
              </div>
            </div>

            {/* Custom Date Inputs if mode === "custom" */}
            {mode === "custom" && (
              <div className="p-3.5 bg-slate-950/70 border border-slate-800 rounded-xl grid grid-cols-2 gap-3 animate-fadeIn">
                <div>
                  <label className="text-[11px] text-slate-400 block mb-1">시작일 (YYYY-MM-DD)</label>
                  <input
                    type="date"
                    value={dateFrom}
                    disabled={isRunning}
                    onChange={(e) => setDateFrom(e.target.value)}
                    className="w-full px-3 py-1.5 bg-slate-900 border border-slate-700 rounded-lg text-white font-mono focus:outline-none focus:border-indigo-500"
                  />
                </div>
                <div>
                  <label className="text-[11px] text-slate-400 block mb-1">종료일 (YYYY-MM-DD)</label>
                  <input
                    type="date"
                    value={dateTo}
                    disabled={isRunning}
                    onChange={(e) => setDateTo(e.target.value)}
                    className="w-full px-3 py-1.5 bg-slate-900 border border-slate-700 rounded-lg text-white font-mono focus:outline-none focus:border-indigo-500"
                  />
                </div>
              </div>
            )}
          </div>

          {/* Progress Section */}
          {(isRunning || isDone || (status?.logs && status.logs.length > 0)) && (
            <div className="space-y-3 pt-2">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold text-white flex items-center gap-2">
                  <RefreshCw className={`w-3.5 h-3.5 text-indigo-400 ${isRunning ? "animate-spin" : ""}`} />
                  {status?.current_step || "진행 대기"}
                </span>
                <span className="font-mono text-indigo-300 font-bold">
                  {status?.inserted_count ? `${status.inserted_count.toLocaleString()}건 반영됨` : ""} ({progressPercent}%)
                </span>
              </div>

              {/* Progress Bar */}
              <div className="w-full h-2.5 bg-slate-950 rounded-full overflow-hidden border border-slate-800 p-0.5">
                <div
                  className={`h-full rounded-full transition-all duration-300 ${
                    isDone
                      ? "bg-gradient-to-r from-emerald-500 to-teal-400"
                      : "bg-gradient-to-r from-indigo-500 to-purple-500 animate-pulse"
                  }`}
                  style={{ width: `${progressPercent}%` }}
                ></div>
              </div>

              {/* Live Terminal Log */}
              <div className="space-y-1.5">
                <div className="flex items-center justify-between text-[11px] text-slate-400">
                  <span className="flex items-center gap-1.5">
                    <Terminal className="w-3.5 h-3.5 text-emerald-400" />
                    실시간 수집 로그
                  </span>
                  <div className="flex items-center gap-2">
                    <label className="flex items-center gap-1 cursor-pointer text-[10px] text-slate-400 hover:text-white select-none">
                      <input
                        type="checkbox"
                        checked={autoScroll}
                        onChange={(e) => setAutoScroll(e.target.checked)}
                        className="rounded border-slate-700 bg-slate-800 text-indigo-500 focus:ring-0 w-3 h-3"
                      />
                      <span>자동 스크롤</span>
                    </label>
                    <button
                      type="button"
                      onClick={scrollToBottom}
                      className="text-[10px] px-2 py-0.5 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded border border-slate-700 transition"
                    >
                      맨 아래로
                    </button>
                  </div>
                </div>
                <div
                  ref={logContainerRef}
                  onScroll={handleLogScroll}
                  className="bg-slate-950 border border-slate-800 rounded-xl p-3 font-mono text-[10px] text-slate-300 h-44 overflow-y-auto custom-scrollbar space-y-1"
                >
                  {status?.logs && status.logs.length > 0 ? (
                    status.logs.map((l, idx) => (
                      <div key={idx} className="leading-relaxed">
                        {l}
                      </div>
                    ))
                  ) : (
                    <div className="text-slate-600">수집 시작 버튼을 누르면 로그가 표시됩니다.</div>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="p-5 border-t border-slate-800 bg-slate-950/80 flex items-center justify-between">
          <div className="text-[11px] text-slate-400">
            💡 수집 데이터는 즉시 로컬 SQLite DB에 저장되며 대시보드 통계에 자동 집계됩니다.
          </div>
          <div className="flex gap-2">
            {isDone ? (
              <button
                type="button"
                onClick={() => {
                  onSyncCompleted();
                  onClose();
                }}
                className="py-2 px-5 bg-emerald-600 hover:bg-emerald-500 text-white font-bold rounded-xl text-xs flex items-center gap-1.5 shadow-lg transition"
              >
                <CheckCircle2 className="w-4 h-4" />
                <span>대시보드 새로고침 및 완료</span>
              </button>
            ) : (
              <>
                <button
                  type="button"
                  onClick={onClose}
                  disabled={isRunning}
                  className="py-2 px-4 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold rounded-xl text-xs transition disabled:opacity-40"
                >
                  닫기
                </button>
                <button
                  type="button"
                  onClick={handleStartSync}
                  disabled={isRunning}
                  className="py-2 px-5 bg-indigo-600 hover:bg-indigo-500 text-white font-bold rounded-xl text-xs flex items-center gap-2 shadow-lg transition disabled:opacity-60"
                >
                  {isRunning ? (
                    <>
                      <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>수집 진행 중...</span>
                    </>
                  ) : (
                    <>
                      <RefreshCw className="w-3.5 h-3.5" />
                      <span>OpenFDA 데이터 수집 시작</span>
                    </>
                  )}
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
