import React, { useState, useEffect } from "react";
import {
  ShieldCheck,
  CheckCircle2,
  Search,
  Download,
  ExternalLink,
  Sparkles,
  AlertTriangle,
  FileSpreadsheet,
  ArrowRight,
  Tag,
  UserCheck,
  History,
  BookmarkCheck,
  Layers,
  Award,
} from "lucide-react";
import {
  getConfirmedHazards,
  downloadHazardsExcel,
  finalizeHazardVersion,
  getHazardVersions,
} from "../../api/client";
import { TabGuide } from "../common/TabGuide";
import type { HazardItem, HazardVersion } from "../../types";

interface ConfirmedHazardsTabProps {
  onSelectReport: (reportNumber: string) => void;
}

export const ConfirmedHazardsTab: React.FC<ConfirmedHazardsTabProps> = ({ onSelectReport }) => {
  const [hazards, setHazards] = useState<HazardItem[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [keyword, setKeyword] = useState<string>("");

  // Finalize Version Modal State
  const [isFinalizeOpen, setIsFinalizeOpen] = useState<boolean>(false);
  const [versionTag, setVersionTag] = useState<string>("v0.2");
  const [finalizedBy, setFinalizedBy] = useState<string>("위험관리 책임자");
  const [summaryNotes, setSummaryNotes] = useState<string>("");
  const [isFinalizing, setIsFinalizing] = useState<boolean>(false);

  // Version History Modal State
  const [isHistoryOpen, setIsHistoryOpen] = useState<boolean>(false);
  const [versions, setVersions] = useState<HazardVersion[]>([]);
  const [loadingVersions, setLoadingVersions] = useState<boolean>(false);

  const fetchConfirmed = async () => {
    setLoading(true);
    try {
      const data = await getConfirmedHazards({ keyword: keyword || undefined });
      setHazards(data);
    } catch (err) {
      console.error("Failed to load confirmed hazards:", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchVersions = async () => {
    setLoadingVersions(true);
    try {
      const data = await getHazardVersions();
      setVersions(data);
      if (data.length > 0) {
        // Suggest next minor version if possible
        const latest = data[0].version_tag;
        const match = latest.match(/^v(\d+)\.(\d+)$/);
        if (match) {
          setVersionTag(`v${match[1]}.${parseInt(match[2], 10) + 1}`);
        }
      }
    } catch (err) {
      console.error("Failed to load hazard versions:", err);
    } finally {
      setLoadingVersions(false);
    }
  };

  useEffect(() => {
    fetchConfirmed();
  }, [keyword]);

  const handleFinalizeSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (hazards.length === 0) {
      alert("채택된 위해 요인이 0건이므로 확정할 수 없습니다. 최소 1건 이상의 위해 요인을 [채택]해야 합니다.");
      return;
    }
    if (!versionTag.trim()) {
      alert("버전 태그(예: v0.2, v0.3)를 입력하세요.");
      return;
    }
    setIsFinalizing(true);
    try {
      const res = await finalizeHazardVersion(versionTag.trim(), finalizedBy.trim(), summaryNotes.trim());
      alert(
        `위해 관리 버전 [${res.version_tag}]이 성공적으로 확정되었습니다!\n총 ${res.adopted_hazards}건의 채택 위해 항목이 스냅샷에 보존되었습니다.`
      );
      setIsFinalizeOpen(false);
      setSummaryNotes("");
      await fetchConfirmed();
    } catch (err: any) {
      const errMsg = err?.response?.data?.detail || err?.message || String(err);
      alert("버전 확정 실패: " + errMsg);
    } finally {
      setIsFinalizing(false);
    }
  };

  const handleOpenHistory = async () => {
    setIsHistoryOpen(true);
    await fetchVersions();
  };

  const getRiskBadgeColor = (risk: string) => {
    const r = (risk || "").toLowerCase();
    if (r === "high" || r === "높음") {
      return "bg-rose-950/70 text-rose-400 border-rose-800/80";
    }
    if (r === "medium" || r === "중간") {
      return "bg-amber-950/70 text-amber-400 border-amber-800/80";
    }
    if (r === "low" || r === "낮음") {
      return "bg-sky-950/70 text-sky-400 border-sky-800/80";
    }
    return "bg-slate-800 text-slate-300 border-slate-700";
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Collapsible Tab Guide */}
      <TabGuide
        tabKey="confirmed_hazards"
        title="확정 위해 항목 (Confirmed Hazards Matrix) 가이드"
        subtitle="R&D 및 RA 팀 검토 승인 완료 항목, 설계 예방 통제안(Preventive Controls) 관리"
        purpose="[위해 분석] 탭에서 사내 연구원 및 RA 규제 전문가가 검토를 완료하고 [채택] 판단을 내린 최종 RMF(위험관리 파일) 등재 확정 항목들을 모아 체계적으로 관리하는 공간입니다."
        items={[
          {
            term: "채택 확정 항목 (Adopted Hazards)",
            badge: "Adoption: 채택",
            badgeColor: "emerald",
            description: "FDA MAUDE 부작용 원인 및 위해 사슬에 대해 사내 검토를 마치고 실제 CareSens Air 제품 설계 및 RMF에 반영하기로 공식 채택한 항목들만 엄격히 표시됩니다.",
          },
          {
            term: "버전 확정 및 스냅샷 (Version Finalize)",
            badge: "Version Snapshot",
            badgeColor: "indigo",
            description: "현재 채택된 위해 항목 전체의 정적 스냅샷을 생성하여 hazard_versions에 영구 보존하고 버전 번호(v0.2, v0.3 등)를 부여합니다.",
          },
          {
            term: "최종 Hazard 엑셀 다운로드",
            badge: "ISO 14971 RMF",
            badgeColor: "emerald",
            description: "채택 사유, 차세대 AID 영향, 인과 사슬, 심각도, 발생확률, 위험 수준, 권장 설계 통제안 및 부록이 포함된 다중 시트 표준 RMF 엑셀입니다.",
          },
        ]}
        tips={[
          "우측 상단의 '최종 Hazard 엑셀' 버튼을 통해 즉시 표준 양식 엑셀(.xlsx) 파일로 내보낼 수 있습니다.",
          "의사결정이 마무리된 시점에 '버전 확정'을 실행하면 규제 당국 제출 및 사내 형상 관리를 위한 고정 스냅샷이 생성됩니다.",
        ]}
      />

      {/* Header */}
      <div className="bg-slate-900/70 border border-emerald-500/30 rounded-2xl p-6 backdrop-blur-md shadow-lg flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-emerald-500/10 rounded-xl border border-emerald-500/20">
            <ShieldCheck className="w-6 h-6 text-emerald-400" />
          </div>
          <div>
            <h2 className="text-lg font-bold text-white flex items-center gap-2">
              <span>사내 RMF 등재 확정 위해 요인 (Confirmed Hazards)</span>
              <span className="text-xs font-normal px-2.5 py-0.5 rounded-full bg-emerald-950 text-emerald-400 border border-emerald-800/80 font-bold">
                공식 채택 {hazards.length}건
              </span>
            </h2>
            <p className="text-xs text-slate-400 mt-1">
              연구소 및 RA 부서에서 [채택] 완료된 핵심 위험 항목 및 차세대 AID 통제 설계 매트릭스
            </p>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex flex-wrap items-center gap-2.5 text-xs">
          <div className="relative w-48">
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="확정 항목 검색..."
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              className="w-full pl-9 pr-3 py-1.5 bg-slate-950/80 border border-slate-700 rounded-xl text-slate-200 placeholder-slate-500 focus:outline-none focus:border-emerald-500 text-xs"
            />
          </div>

          {/* Version History Button */}
          <button
            onClick={handleOpenHistory}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl font-semibold bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 transition cursor-pointer"
            title="이전에 확정된 버전 목록 및 스냅샷 이력 확인"
          >
            <History className="w-3.5 h-3.5 text-indigo-400" />
            <span>버전 이력</span>
          </button>

          {/* Finalize Version Button */}
          <button
            onClick={() => {
              if (hazards.length === 0) {
                alert("채택된 위해 요인이 0건이므로 확정할 수 없습니다. 먼저 위해 분석 탭에서 위해 요인을 [채택]해주세요.");
                return;
              }
              setIsFinalizeOpen(true);
              fetchVersions();
            }}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl font-bold bg-indigo-600 hover:bg-indigo-500 text-white shadow-md shadow-indigo-900/30 transition cursor-pointer"
            title="현재 채택된 위해 항목들을 공식 버전으로 확정 스냅샷 저장"
          >
            <Award className="w-3.5 h-3.5" />
            <span>버전 확정 (Finalize)</span>
          </button>

          {/* Excel Export */}
          <button
            onClick={() => downloadHazardsExcel("final", { confirmed_only: true, keyword: keyword || undefined })}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl font-bold bg-emerald-600 hover:bg-emerald-500 text-white shadow-md shadow-emerald-900/30 transition cursor-pointer"
            title="ISO 14971 RMF 최종 확정 다중 시트 엑셀 다운로드"
          >
            <Download className="w-3.5 h-3.5" />
            <span>최종 Hazard 엑셀</span>
          </button>
        </div>
      </div>

      {/* Confirmed Cards List */}
      {loading ? (
        <div className="p-16 text-center text-slate-400 bg-slate-900/30 rounded-2xl border border-slate-800">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-500 mb-3" />
          <p className="text-sm">확정 위해 항목을 불러오는 중입니다...</p>
        </div>
      ) : hazards.length === 0 ? (
        <div className="p-16 text-center text-slate-400 bg-slate-900/30 rounded-2xl border border-slate-800">
          <CheckCircle2 className="w-12 h-12 text-slate-600 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-300">현재 공식 [채택] 완료된 위해 항목이 없습니다</h3>
          <p className="text-xs text-slate-500 mt-1">
            [위해 분석] 탭에서 중요한 위해 요인을 검토한 후 [채택 (RMF 등재)] 판단을 저장해주세요.
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {hazards.map((hz) => (
            <div
              key={hz.hazard_row_id}
              className="p-5 rounded-2xl border border-emerald-500/40 bg-slate-900/90 shadow-md shadow-emerald-950/20 hover:border-emerald-400 transition"
            >
              {/* Top Meta Line */}
              <div className="flex flex-wrap items-center justify-between gap-3 border-b border-slate-800 pb-3">
                <div className="flex flex-wrap items-center gap-2">
                  <span className="font-mono text-xs px-2.5 py-0.5 rounded-lg bg-indigo-950/80 text-indigo-300 border border-indigo-800/60 font-bold">
                    {hz.hazard_id_local}
                  </span>

                  {hz.ppt_id && (
                    <span className="text-xs px-2.5 py-0.5 rounded-lg bg-purple-950 text-purple-300 border border-purple-700 font-bold">
                      PPT ID: {hz.ppt_id}
                    </span>
                  )}

                  <span
                    className={`text-xs px-2.5 py-0.5 rounded-lg border font-bold ${getRiskBadgeColor(
                      hz.risk_level
                    )}`}
                  >
                    위험도: {hz.risk_level} (점수: {hz.risk_score || "-"}점 | S: {hz.severity_level} / P:{" "}
                    {hz.probability_level})
                  </span>

                  <span className="text-xs px-2 py-0.5 rounded-lg bg-slate-950 text-slate-300 border border-slate-800">
                    모드: {hz.use_mode || "향후 AID 연동"}
                  </span>

                  <span className="text-xs px-2.5 py-0.5 rounded-full bg-amber-950/70 text-amber-300 border border-amber-800/60 font-semibold">
                    AID 점수: {hz.aid_relevance_score}/5
                  </span>

                  <span className="text-xs px-2.5 py-0.5 rounded-full bg-emerald-950 text-emerald-400 border border-emerald-500/50 font-semibold flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3" />
                    <span>채택 승인 완료</span>
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => onSelectReport(hz.report_number)}
                    className="flex items-center gap-1 px-2.5 py-1 rounded-lg bg-cyan-950/70 hover:bg-cyan-900 text-cyan-300 border border-cyan-800/60 text-xs transition cursor-pointer"
                    title="원문 MDR 보고서 상세 보기"
                  >
                    <span>MDR: {hz.report_number}</span>
                    <ExternalLink className="w-3 h-3" />
                  </button>
                </div>
              </div>

              {/* Title & Info */}
              <div className="mt-3">
                <div className="flex items-center gap-2">
                  <span className="text-xs text-slate-400 bg-slate-950 px-2 py-0.5 rounded border border-slate-800">
                    {hz.hazard_category_primary}
                  </span>
                  <span className="text-xs text-slate-400">
                    제품명: <strong className="text-slate-200">{hz.brand_name}</strong> | 접수일:{" "}
                    {hz.date_received} | 최초수집월: <strong className="text-slate-300">{hz.first_ingest_month || "-"}</strong>
                  </span>
                </div>
                <h3 className="text-base font-bold text-slate-100 mt-1.5 flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0" />
                  {hz.hazard_ko}
                </h3>
              </div>

              {/* Adoption Reasons */}
              <div className="mt-3 p-3.5 rounded-xl bg-emerald-950/30 border border-emerald-500/40 text-xs space-y-2">
                <div className="flex items-center gap-1.5 font-bold text-emerald-400">
                  <Sparkles className="w-3.5 h-3.5" />
                  <span>공식 채택 사유 및 차세대 AID 영향</span>
                </div>
                {hz.adoption_reason && (
                  <p className="text-slate-200 leading-relaxed">
                    <strong className="text-emerald-300">채택 사유:</strong> {hz.adoption_reason}
                  </p>
                )}
                {hz.future_aid_risk && (
                  <p className="text-slate-300 leading-relaxed">
                    <strong className="text-cyan-300">차세대 AID 오제어 경로:</strong> {hz.future_aid_risk}
                  </p>
                )}
              </div>

              {/* 3-Stage ISO 14971 Causal Sequence */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3 my-4 p-4 rounded-xl bg-slate-950/80 border border-slate-800/80 text-xs">
                <div className="space-y-1">
                  <div className="font-semibold text-indigo-300 flex items-center gap-1">
                    <span>1. 원인 사건 (Initiating Event)</span>
                    <ArrowRight className="w-3 h-3 text-slate-500 hidden md:inline ml-auto" />
                  </div>
                  <p className="text-slate-300 leading-relaxed">{hz.initiating_event_ko}</p>
                </div>

                <div className="space-y-1">
                  <div className="font-semibold text-amber-300 flex items-center gap-1">
                    <span>2. 위해 상황 (Hazardous Situation)</span>
                    <ArrowRight className="w-3 h-3 text-slate-500 hidden md:inline ml-auto" />
                  </div>
                  <p className="text-slate-300 leading-relaxed">{hz.hazardous_situation_ko}</p>
                </div>

                <div className="space-y-1">
                  <div className="font-semibold text-rose-300">
                    <span>3. 환자 위해 (Harm)</span>
                  </div>
                  <p className="text-slate-300 leading-relaxed font-medium">{hz.harm_ko}</p>
                </div>
              </div>

              {/* Engineering Implication & Controls */}
              <div className="p-3.5 rounded-xl bg-slate-950/70 border border-slate-800 text-xs space-y-2">
                <div className="flex items-center gap-1.5 font-bold text-slate-300">
                  <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
                  <span>CareSens Air & AID 시스템 설계 예방 통제안</span>
                </div>
                <p className="text-slate-300 leading-relaxed">
                  <strong className="text-slate-200">설계 시사점:</strong> {hz.care_sens_implication_ko}
                </p>
                {hz.recommended_preventive_controls && (
                  <p className="text-slate-300 leading-relaxed">
                    <strong className="text-emerald-300">권장 사전 예방 설계 통제안:</strong>{" "}
                    {hz.recommended_preventive_controls}
                  </p>
                )}
                {hz.recommended_recall_controls && (
                  <p className="text-slate-400 leading-relaxed">
                    <strong className="text-amber-300">권장 시장 시정/조치안:</strong>{" "}
                    {hz.recommended_recall_controls}
                  </p>
                )}
              </div>

              {/* Reviewer Stamp */}
              <div className="mt-3 pt-2.5 border-t border-slate-800/80 flex flex-wrap items-center justify-between text-xs text-slate-400">
                <div className="flex items-center gap-2">
                  <UserCheck className="w-3.5 h-3.5 text-emerald-400" />
                  <span>
                    검토/채택 승인자:{" "}
                    <strong className="text-emerald-300">{hz.reviewer_name || "사내 위험관리 담당자"}</strong>
                  </span>
                  {hz.review_note && <span className="text-slate-300">| 검토의견: "{hz.review_note}"</span>}
                  {hz.finalized_version && (
                    <span className="px-2 py-0.5 rounded bg-indigo-950 text-indigo-300 border border-indigo-800 font-bold">
                      확정 버전: {hz.finalized_version}
                    </span>
                  )}
                </div>
                {hz.internal_tags && (
                  <span className="flex items-center gap-1 text-slate-400 bg-slate-950 px-2 py-0.5 rounded border border-slate-800">
                    <Tag className="w-3 h-3 text-slate-500" />
                    {hz.internal_tags}
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Finalize Version Modal */}
      {isFinalizeOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/75 backdrop-blur-sm p-4">
          <form
            onSubmit={handleFinalizeSubmit}
            className="bg-slate-900 border border-indigo-500/50 rounded-2xl w-full max-w-lg p-6 shadow-2xl space-y-4"
          >
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                <Award className="w-5 h-5 text-indigo-400" />
                <span>위해 관리 버전 확정 및 스냅샷 (Version Finalize)</span>
              </h3>
              <button
                type="button"
                onClick={() => setIsFinalizeOpen(false)}
                className="text-slate-400 hover:text-white cursor-pointer"
              >
                ✕
              </button>
            </div>

            <p className="text-xs text-slate-300 leading-relaxed">
              현재 공식 채택된 <strong className="text-emerald-400">{hazards.length}건</strong>의 위해 항목에 대한
              스냅샷을 생성하고 버전 번호를 영구 부여합니다. 확정 후에도 신규 수집 보고서에 대해 계속해서 위해 요인을
              추가할 수 있습니다.
            </p>

            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1">
                버전 태그 (Version Tag) <span className="text-rose-400">*</span>
              </label>
              <input
                type="text"
                value={versionTag}
                onChange={(e) => setVersionTag(e.target.value)}
                placeholder="예: v0.2, v0.3"
                className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
                required
              />
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1">
                확정 승인 책임자 (Finalized By)
              </label>
              <input
                type="text"
                value={finalizedBy}
                onChange={(e) => setFinalizedBy(e.target.value)}
                placeholder="예: 위험관리 책임자"
                className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1">
                버전 확정 요약 및 변경 사유 (Summary Notes)
              </label>
              <textarea
                value={summaryNotes}
                onChange={(e) => setSummaryNotes(e.target.value)}
                rows={3}
                placeholder="예: 2026년 4분기 Dexcom G7 및 Libre 3 부작용 분석 결과 반영, 고위험 3건 채택 완료."
                className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setIsFinalizeOpen(false)}
                className="px-4 py-2 rounded-xl text-xs text-slate-400 hover:text-white hover:bg-slate-800 transition cursor-pointer"
              >
                취소
              </button>
              <button
                type="submit"
                disabled={isFinalizing}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-indigo-600 hover:bg-indigo-500 text-white shadow-lg shadow-indigo-900/40 transition cursor-pointer disabled:opacity-50"
              >
                {isFinalizing ? "확정 처리 중..." : "버전 확정 및 스냅샷 보존"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Version History Modal */}
      {isHistoryOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/75 backdrop-blur-sm p-4">
          <div className="bg-slate-900 border border-slate-700 rounded-2xl w-full max-w-2xl p-6 shadow-2xl space-y-4 max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                <History className="w-5 h-5 text-indigo-400" />
                <span>위해 관리 버전 이력 (Finalized Versions)</span>
              </h3>
              <button
                type="button"
                onClick={() => setIsHistoryOpen(false)}
                className="text-slate-400 hover:text-white cursor-pointer"
              >
                ✕
              </button>
            </div>

            <div className="flex-1 overflow-y-auto space-y-3">
              {loadingVersions ? (
                <div className="py-12 text-center text-slate-400 text-xs">버전 이력을 불러오는 중입니다...</div>
              ) : versions.length === 0 ? (
                <div className="py-12 text-center text-slate-500 text-xs">확정된 버전 이력이 아직 없습니다.</div>
              ) : (
                versions.map((v) => (
                  <div key={v.version_id} className="p-4 rounded-xl bg-slate-950 border border-slate-800 text-xs space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-indigo-400 text-sm">{v.version_tag}</span>
                        <span className="text-slate-400">({v.finalized_at})</span>
                      </div>
                      <span className="px-2 py-0.5 rounded bg-emerald-950 text-emerald-300 border border-emerald-800 font-semibold">
                        채택 항목 {v.adopted_hazards}건 (전체 {v.total_hazards}건)
                      </span>
                    </div>

                    <div className="flex items-center gap-3 text-slate-400">
                      <span>책임자: <strong className="text-slate-300">{v.finalized_by}</strong></span>
                      <span>|</span>
                      <span>고위험: <strong className="text-rose-400">{v.high_risk_count}</strong></span>
                      <span>중간위험: <strong className="text-amber-400">{v.medium_risk_count}</strong></span>
                      <span>저위험: <strong className="text-sky-400">{v.low_risk_count}</strong></span>
                    </div>

                    {v.summary_notes && (
                      <p className="text-slate-300 pt-1 border-t border-slate-800/60 leading-relaxed">
                        {v.summary_notes}
                      </p>
                    )}
                  </div>
                ))
              )}
            </div>

            <div className="flex justify-end pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setIsHistoryOpen(false)}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-slate-200 transition cursor-pointer"
              >
                닫기
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
