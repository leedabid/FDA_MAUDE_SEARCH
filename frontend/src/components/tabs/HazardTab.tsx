import React, { useState, useEffect } from "react";
import {
  ShieldAlert,
  AlertTriangle,
  CheckCircle,
  FileText,
  Search,
  ExternalLink,
  Sparkles,
  ArrowRight,
  Download,
  FileSpreadsheet,
  Tag,
  UserCheck,
  RotateCcw,
  Trash2,
  BookmarkCheck,
  Layers,
  HelpCircle,
} from "lucide-react";
import { getHazards, saveHazardReview, downloadHazardsExcel, deleteHazard } from "../../api/client";
import { TabGuide } from "../common/TabGuide";
import type { HazardItem } from "../../types";

interface HazardTabProps {
  onSelectReport: (reportNumber: string) => void;
}

export const HazardTab: React.FC<HazardTabProps> = ({ onSelectReport }) => {
  const [hazards, setHazards] = useState<HazardItem[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [riskFilter, setRiskFilter] = useState<string>("");
  const [minAidScore, setMinAidScore] = useState<number>(0);
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [adoptionFilter, setAdoptionFilter] = useState<string>("");
  const [useModeFilter, setUseModeFilter] = useState<string>("");
  const [keyword, setKeyword] = useState<string>("");
  const [selectedHazard, setSelectedHazard] = useState<HazardItem | null>(null);

  // Review Edit State
  const [workflowStatus, setWorkflowStatus] = useState<string>("검토완료");
  const [adoptionDecision, setAdoptionDecision] = useState<string>("");
  const [adoptionReason, setAdoptionReason] = useState<string>("");
  const [futureAidRisk, setFutureAidRisk] = useState<string>("");
  const [decisionReason, setDecisionReason] = useState<string>("");
  const [useMode, setUseMode] = useState<string>("향후 AID 연동");
  const [pptInclude, setPptInclude] = useState<string>("N");
  const [pptId, setPptId] = useState<string>("");
  const [reviewerName, setReviewerName] = useState<string>("");
  const [reviewNote, setReviewNote] = useState<string>("");
  const [internalTags, setInternalTags] = useState<string>("");
  const [savingReview, setSavingReview] = useState<boolean>(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const fetchHazards = async () => {
    setLoading(true);
    try {
      const data = await getHazards({
        risk_level: riskFilter || undefined,
        min_aid_score: minAidScore || undefined,
        workflow_status: statusFilter || undefined,
        adoption_decision: adoptionFilter || undefined,
        use_mode: useModeFilter || undefined,
        keyword: keyword || undefined,
      });
      setHazards(data);
    } catch (err) {
      console.error("Failed to load hazards:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHazards();
  }, [riskFilter, minAidScore, statusFilter, adoptionFilter, useModeFilter, keyword]);

  const handleOpenReview = (hz: HazardItem) => {
    setSelectedHazard(hz);
    setWorkflowStatus(hz.workflow_status || "검토완료");
    setAdoptionDecision(hz.adoption_decision || "");
    setAdoptionReason(hz.adoption_reason || "");
    setFutureAidRisk(hz.future_aid_risk || "");
    setDecisionReason(hz.decision_reason || "");
    setUseMode(hz.use_mode || "향후 AID 연동");
    setPptInclude(hz.ppt_include || "N");
    setPptId(hz.ppt_id || "");
    setReviewerName(hz.reviewer_name || "");
    setReviewNote(hz.review_note || "");
    setInternalTags(hz.internal_tags || "");
  };

  const handleSaveReview = async () => {
    if (!selectedHazard) return;

    // ISO 14971 Section 2.2 Validation
    if (adoptionDecision === "채택") {
      if (!adoptionReason.trim()) {
        alert("위해 요인을 [채택]할 때는 '채택 사유(왜 중요한가)'를 반드시 입력해야 합니다.");
        return;
      }
      if (!futureAidRisk.trim()) {
        alert("위해 요인을 [채택]할 때는 '차세대 AID 영향(어떻게 위험한가)'을 반드시 입력해야 합니다.");
        return;
      }
    }

    setSavingReview(true);
    try {
      await saveHazardReview(selectedHazard.hazard_row_id, {
        workflow_status: workflowStatus,
        adoption_decision: adoptionDecision,
        adoption_reason: adoptionReason,
        future_aid_risk: futureAidRisk,
        decision_reason: decisionReason,
        use_mode: useMode,
        ppt_include: pptInclude,
        ppt_id: pptId,
        reviewer_name: reviewerName,
        review_note: reviewNote,
        internal_tags: internalTags,
        client_updated_at: selectedHazard.updated_at,
      });
      await fetchHazards();
      setSelectedHazard(null);
    } catch (err: any) {
      const errMsg = err?.response?.data?.detail || err?.message || String(err);
      alert("검토 상태 저장 실패: " + errMsg);
    } finally {
      setSavingReview(false);
    }
  };

  const handleDeleteHazard = async (hazardRowId: string, hazardKo?: string, isProtected?: boolean) => {
    if (isProtected) {
      alert("검토 또는 판단(채택/보류/제외)이 완료된 위해 요인은 삭제할 수 없습니다. 대신 [제외] 판단으로 전환해주세요.");
      return;
    }
    if (
      !confirm(
        `이 위해 분석(Hazard) 항목을 삭제하시겠습니까?\n${hazardKo ? `[${hazardKo}]\n` : ""}미검토 데이터만 영구 삭제됩니다.`
      )
    ) {
      return;
    }
    setDeletingId(hazardRowId);
    try {
      await deleteHazard(hazardRowId);
      if (selectedHazard && selectedHazard.hazard_row_id === hazardRowId) {
        setSelectedHazard(null);
      }
      await fetchHazards();
    } catch (err: any) {
      const errMsg = err?.response?.data?.detail || err?.message || String(err);
      alert("위해 분석 항목 삭제 실패: " + errMsg);
    } finally {
      setDeletingId(null);
    }
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

  const getAdoptionBadgeColor = (decision?: string) => {
    switch (decision) {
      case "채택":
        return "bg-emerald-950 text-emerald-300 border-emerald-500 font-bold";
      case "보류":
        return "bg-amber-950 text-amber-300 border-amber-500";
      case "제외":
        return "bg-slate-800 text-slate-400 border-slate-600";
      default:
        return "bg-slate-900 text-slate-400 border-slate-700";
    }
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Collapsible Tab Guide */}
      <TabGuide
        tabKey="hazards"
        title="위해 분석 (ISO 14971) 탭 가이드 & 라벨 정의"
        subtitle="라벨 식별 코드 체계, 위험 수준, 3단계 인과 사슬 및 AID 연동 시사점 안내"
        purpose="FDA MAUDE 의료기기 부작용/불만 보고서로부터 ISO 14971 위험관리 표준에 따라 위해 요인을 추출하고, CareSens Air 및 차세대 AID(인공췌장) 시스템의 사전 설계 예방 통제안(Preventive Controls)을 수립하기 위한 전문 분석 공간입니다."
        items={[
          {
            term: "MDR 보고서 번호 (Report Number)",
            badge: "FDA Key",
            badgeColor: "indigo",
            description: "FDA MAUDE 데이터베이스에 등록된 고유 식별 번호입니다. 클릭 시 원문 불만/제조사 내러티브 상세 모달을 즉시 조회할 수 있습니다.",
          },
          {
            term: "로컬 위해 요인 코드 (Hazard ID)",
            badge: "HZ-xx",
            badgeColor: "cyan",
            description: "보고서 내부에서 식별된 위해 요인의 순번 식별자입니다. 시스템 내 고유 키는 'MAUDE_{보고서번호}_{HZ-xx}'로 관리됩니다.",
          },
          {
            term: "위험 수준 (Risk Level: 높음 / 중간 / 낮음)",
            badge: "S×P Matrix (1~25)",
            badgeColor: "rose",
            description: "심각도(Catastrophic~Negligible, 1~5)와 발생확률(Frequent~Improbable, 1~5)의 곱으로 산정됩니다: 15~25점은 '높음', 8~14점은 '중간', 1~7점은 '낮음'으로 표준화 분류됩니다.",
          },
          {
            term: "채택 판단 (Adoption Decision)",
            badge: "채택 | 보류 | 제외",
            badgeColor: "emerald",
            description: "[채택] 선택 시 사내 위험관리 파일(RMF) 및 최종 확정 위해 항목에 공식 등재되며, 채택 사유 및 차세대 AID 영향 기술이 의무화됩니다.",
          },
          {
            term: "3단계 인과 사슬 (ISO 14971 Causal Sequence)",
            badge: "원인 -> 상황 -> 위해",
            badgeColor: "amber",
            description: "1.최초 유발 사건(공정/센서/환자 결함) -> 2.위해 상황(실제 저혈당 미표시 등 노출) -> 3.환자 위해(저혈당 쇼크, 부적절 인슐린 주입 등 최종 상해)의 인과 경로입니다.",
          },
        ]}
        tips={[
          "각 위해 요인 카드의 [검토 / 채택 판단] 버튼을 누르면 채택 여부, 사용 모드, PPT 게재 여부 및 사유를 입력할 수 있습니다.",
          "[최종 Hazard 엑셀] 버튼을 누르면 채택 완료된 위해 항목, 운영 매트릭스, 월별 요약, 버전 이력, 감사 로그가 포함된 다중 시트 표준 엑셀이 생성됩니다.",
        ]}
      />

      {/* Header & Filter Controls */}
      <div className="bg-slate-900/70 border border-slate-800 rounded-2xl p-6 backdrop-blur-md shadow-lg space-y-4">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-red-500/10 rounded-xl border border-red-500/20">
              <ShieldAlert className="w-6 h-6 text-red-400" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <span>ISO 14971 잠재적 위해 요인 분석 (Hazard Identification)</span>
                <span className="text-xs font-normal px-2.5 py-0.5 rounded-full bg-red-950 text-red-400 border border-red-800/80">
                  Risk Management
                </span>
              </h2>
              <p className="text-xs text-slate-400 mt-1">
                FDA MAUDE 부작용 보고서 기반 인과 사슬 분석 및 CareSens Air / AID 시스템 사전 예방 설계 통제안
              </p>
            </div>
          </div>
        </div>

        {/* Filters & Export Buttons */}
        <div className="flex flex-wrap items-center gap-2.5 text-xs pt-2 border-t border-slate-800">
          {/* Keyword Search */}
          <div className="relative w-48">
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="위해 요인, 제품명 검색..."
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              className="w-full pl-9 pr-3 py-1.5 bg-slate-950/80 border border-slate-700 rounded-xl text-slate-200 placeholder-slate-500 focus:outline-none focus:border-red-500 text-xs"
            />
          </div>

          {/* Adoption Decision Filter */}
          <select
            value={adoptionFilter}
            onChange={(e) => setAdoptionFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-xl text-slate-200 focus:outline-none focus:border-red-500"
          >
            <option value="">채택 판단 (전체)</option>
            <option value="채택">채택 완료</option>
            <option value="보류">보류</option>
            <option value="제외">제외</option>
            <option value="미결정">미결정</option>
          </select>

          {/* Risk Level */}
          <select
            value={riskFilter}
            onChange={(e) => setRiskFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-xl text-slate-200 focus:outline-none focus:border-red-500"
          >
            <option value="">위험 수준 (전체)</option>
            <option value="높음">높음 (High Risk, 15~25)</option>
            <option value="중간">중간 (Medium Risk, 8~14)</option>
            <option value="낮음">낮음 (Low Risk, 1~7)</option>
          </select>

          {/* Use Mode Filter (v0.3 4 standard categories) */}
          <select
            value={useModeFilter}
            onChange={(e) => setUseModeFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-xl text-slate-200 focus:outline-none focus:border-red-500"
          >
            <option value="">사용 모드 (전체)</option>
            <option value="향후 AID 연동">향후 AID 연동</option>
            <option value="CGM 단독·수동 치료">CGM 단독·수동 치료</option>
            <option value="제품 안전·임상·보호자">제품 안전·임상·보호자</option>
            <option value="펌프 단독 참고">펌프 단독 참고</option>
          </select>

          {/* Min AID Score */}
          <select
            value={minAidScore}
            onChange={(e) => setMinAidScore(Number(e.target.value))}
            className="px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-xl text-slate-200 focus:outline-none focus:border-red-500"
          >
            <option value="0">AID 관련도 (전체)</option>
            <option value="4">AID 4점 이상 (핵심 위험)</option>
            <option value="3">AID 3점 이상</option>
            <option value="1">AID 1점 이상</option>
          </select>

          {/* Workflow Status */}
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-xl text-slate-200 focus:outline-none focus:border-red-500"
          >
            <option value="">검토 상태 (전체)</option>
            <option value="미검토">미검토</option>
            <option value="검토완료">검토완료</option>
            <option value="확정">확정</option>
          </select>

          <span className="text-xs font-mono font-bold text-slate-400 px-2.5 py-1 bg-slate-950 rounded-lg border border-slate-800 ml-auto">
            총 {hazards.length}건
          </span>

          {/* Excel Export Buttons */}
          <button
            onClick={() =>
              downloadHazardsExcel("final", {
                risk_level: riskFilter || undefined,
                min_aid_score: minAidScore || undefined,
                workflow_status: statusFilter || undefined,
                keyword: keyword || undefined,
              })
            }
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl font-bold bg-emerald-600 hover:bg-emerald-500 text-white shadow-md shadow-emerald-900/30 transition cursor-pointer"
            title="ISO 14971 RMF 채택 항목 및 다중 시트 표준 엑셀 다운로드"
          >
            <Download className="w-3.5 h-3.5" />
            <span>최종 Hazard 엑셀</span>
          </button>

          <button
            onClick={() =>
              downloadHazardsExcel("operations", {
                risk_level: riskFilter || undefined,
                min_aid_score: minAidScore || undefined,
                workflow_status: statusFilter || undefined,
                keyword: keyword || undefined,
              })
            }
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl font-semibold bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 shadow-sm transition cursor-pointer"
            title="전체 위해 분석 운영 매트릭스 엑셀 다운로드"
          >
            <FileSpreadsheet className="w-3.5 h-3.5 text-emerald-400" />
            <span>운영 뷰 엑셀</span>
          </button>
        </div>
      </div>

      {/* Hazard Cards List */}
      {loading ? (
        <div className="p-16 text-center text-slate-400 bg-slate-900/30 rounded-2xl border border-slate-800">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-red-500 mb-3" />
          <p className="text-sm">위해 분석 데이터를 불러오는 중입니다...</p>
        </div>
      ) : hazards.length === 0 ? (
        <div className="p-16 text-center text-slate-400 bg-slate-900/30 rounded-2xl border border-slate-800">
          <ShieldAlert className="w-12 h-12 text-slate-600 mx-auto mb-3" />
          <h3 className="text-base font-semibold text-slate-300">표시할 위해 분석 데이터가 없습니다</h3>
          <p className="text-xs text-slate-500 mt-1">
            필터 조건을 변경하거나 [전체 보고서] 탭에서 중요한 MDR 보고서를 선택한 후 [AI 위해 분석]을 실행해주세요.
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {hazards.map((hz) => (
            <div
              key={hz.hazard_row_id}
              className={`p-5 rounded-2xl border transition shadow-sm ${
                hz.adoption_decision === "채택"
                  ? "bg-slate-900/90 border-emerald-500/50 hover:border-emerald-400 shadow-emerald-950/20"
                  : "bg-slate-900/60 border-slate-800 hover:border-slate-700 hover:bg-slate-900/80"
              }`}
            >
              {/* Card Header */}
              <div className="flex flex-wrap items-center justify-between gap-3 border-b border-slate-800/80 pb-3">
                <div className="flex flex-wrap items-center gap-2">
                  {/* Local Hazard ID */}
                  <span className="font-mono text-xs px-2.5 py-0.5 rounded-lg bg-indigo-950/80 text-indigo-300 border border-indigo-800/60 font-bold">
                    {hz.hazard_id_local}
                  </span>

                  {/* Adoption Decision Badge */}
                  <span
                    className={`text-xs px-2.5 py-0.5 rounded-lg border ${getAdoptionBadgeColor(
                      hz.adoption_decision
                    )}`}
                  >
                    {hz.adoption_decision ? `판단: ${hz.adoption_decision}` : "판단: 미결정"}
                  </span>

                  {/* PPT Badge if marked */}
                  {hz.ppt_include === "Y" && (
                    <span className="text-xs px-2 py-0.5 rounded-lg bg-purple-950 text-purple-300 border border-purple-700 font-bold">
                      PPT 게재 {hz.ppt_id ? `(${hz.ppt_id})` : ""}
                    </span>
                  )}

                  {/* Standardized Risk Level & Score */}
                  <span
                    className={`text-xs px-2.5 py-0.5 rounded-lg border font-bold ${getRiskBadgeColor(
                      hz.risk_level
                    )}`}
                  >
                    위험도: {hz.risk_level} (점수: {hz.risk_score || "-"}점 | S: {hz.severity_level} / P:{" "}
                    {hz.probability_level})
                  </span>

                  {/* Use Mode */}
                  <span className="text-xs px-2 py-0.5 rounded-lg bg-slate-950 text-slate-300 border border-slate-800">
                    모드: {hz.use_mode || "향후 AID 연동"}
                  </span>

                  {/* AID Score */}
                  <span className="text-xs px-2 py-0.5 rounded-lg bg-amber-950/70 text-amber-300 border border-amber-800/60 font-semibold">
                    AID 관련도: {hz.aid_relevance_score}/5
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

                  <button
                    onClick={() => handleOpenReview(hz)}
                    className="flex items-center gap-1.5 px-3 py-1 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-xs shadow-sm transition cursor-pointer"
                    title="검토 상태 및 채택 판단 저장"
                  >
                    <UserCheck className="w-3.5 h-3.5" />
                    <span>검토 / 채택 판단</span>
                  </button>

                  <button
                    onClick={() =>
                      handleDeleteHazard(hz.hazard_row_id, hz.hazard_ko, hz.adoption_decision === "채택")
                    }
                    disabled={deletingId === hz.hazard_row_id}
                    className="p-1 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-rose-950/40 border border-transparent hover:border-rose-900/50 transition cursor-pointer"
                    title="위해 요인 삭제 (채택 완료 항목은 보호됨)"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Title & Metadata */}
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

              {/* Adoption Reasons Display if 채택 */}
              {hz.adoption_decision === "채택" && (
                <div className="mt-3 p-3 rounded-xl bg-emerald-950/30 border border-emerald-500/40 text-xs space-y-1.5">
                  <div className="flex items-center gap-1 font-bold text-emerald-400">
                    <CheckCircle className="w-3.5 h-3.5" />
                    <span>RMF 채택 확정 요인</span>
                  </div>
                  {hz.adoption_reason && (
                    <p className="text-slate-200 leading-relaxed">
                      <strong className="text-emerald-300">채택 사유:</strong> {hz.adoption_reason}
                    </p>
                  )}
                  {hz.future_aid_risk && (
                    <p className="text-slate-300 leading-relaxed">
                      <strong className="text-cyan-300">차세대 AID 영향:</strong> {hz.future_aid_risk}
                    </p>
                  )}
                </div>
              )}

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

              {/* CareSens Air / AID Implication Box */}
              <div className="p-3.5 rounded-xl bg-emerald-950/20 border border-emerald-900/40 text-xs space-y-2">
                <div className="flex items-center gap-1.5 font-bold text-emerald-400">
                  <Sparkles className="w-3.5 h-3.5" />
                  <span>CareSens Air & AID 시스템 위험 통제 시사점</span>
                </div>
                <p className="text-slate-300 leading-relaxed">
                  <strong className="text-slate-200">설계 시사점:</strong> {hz.care_sens_implication_ko}
                </p>
                {hz.recommended_preventive_controls && (
                  <p className="text-slate-400 leading-relaxed">
                    <strong className="text-emerald-300">권장 설계 예방 통제안:</strong>{" "}
                    {hz.recommended_preventive_controls}
                  </p>
                )}
                {hz.isens_preparation_ko && (
                  <p className="text-slate-400 leading-relaxed">
                    <strong className="text-cyan-300">사내 시험평가 준비사항:</strong> {hz.isens_preparation_ko}
                  </p>
                )}
              </div>

              {/* Reviewer Stamp */}
              {(hz.reviewer_name || hz.review_note || hz.internal_tags || hz.finalized_version) && (
                <div className="mt-3 pt-2.5 border-t border-slate-800/80 flex flex-wrap items-center justify-between text-xs text-slate-400">
                  <div className="flex items-center gap-2">
                    {hz.reviewer_name && (
                      <span>
                        검토자: <strong className="text-slate-300">{hz.reviewer_name}</strong>
                      </span>
                    )}
                    {hz.review_note && (
                      <span className="text-slate-300">| 의견: "{hz.review_note}"</span>
                    )}
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
              )}
            </div>
          ))}
        </div>
      )}

      {/* Review & Adoption Modal */}
      {selectedHazard && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/75 backdrop-blur-sm p-4 overflow-y-auto">
          <div className="bg-slate-900 border border-slate-700 rounded-2xl w-full max-w-xl p-6 shadow-2xl space-y-4 my-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                <UserCheck className="w-5 h-5 text-indigo-400" />
                <span>위해 분석 검토 및 채택 판단 (ISO 14971)</span>
              </h3>
              <button
                onClick={() => setSelectedHazard(null)}
                className="text-slate-400 hover:text-white cursor-pointer"
              >
                ✕
              </button>
            </div>

            <div className="space-y-1 text-xs">
              <p className="text-slate-400">
                MDR 번호: <strong className="text-cyan-400">{selectedHazard.report_number}</strong> | 코드:{" "}
                <strong className="text-white">{selectedHazard.hazard_id_local}</strong>
              </p>
              <p className="text-slate-300 font-semibold">{selectedHazard.hazard_ko}</p>
            </div>

            {/* Adoption Decision Selector */}
            <div className="p-3.5 rounded-xl bg-slate-950 border border-slate-800 space-y-2">
              <label className="text-xs font-bold text-white block">
                1. 사내 위해 관리(RMF) 채택 여부 <span className="text-rose-400">*</span>
              </label>
              <div className="grid grid-cols-4 gap-2 text-xs">
                {[
                  { id: "채택", label: "채택 (RMF 등재)", color: "border-emerald-500 text-emerald-400 bg-emerald-950/50" },
                  { id: "보류", label: "보류 (추가 조사)", color: "border-amber-500 text-amber-400 bg-amber-950/50" },
                  { id: "제외", label: "제외 (미적용)", color: "border-slate-500 text-slate-400 bg-slate-800/50" },
                  { id: "", label: "미결정", color: "border-slate-700 text-slate-400 bg-slate-900" },
                ].map((s) => (
                  <button
                    key={s.id}
                    type="button"
                    onClick={() => setAdoptionDecision(s.id)}
                    className={`py-2 px-2 text-center rounded-xl border text-xs font-semibold transition cursor-pointer ${
                      adoptionDecision === s.id
                        ? s.color + " ring-2 ring-indigo-500"
                        : "border-slate-800 text-slate-400 bg-slate-900 hover:bg-slate-800"
                    }`}
                  >
                    {s.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Mandatory Adoption Reasons (Shown if 채택) */}
            {adoptionDecision === "채택" && (
              <div className="p-3.5 rounded-xl bg-emerald-950/20 border border-emerald-500/40 space-y-3">
                <div>
                  <label className="text-xs font-bold text-emerald-300 block mb-1">
                    채택 사유 (왜 중요한가) <span className="text-rose-400">*필수</span>
                  </label>
                  <textarea
                    value={adoptionReason}
                    onChange={(e) => setAdoptionReason(e.target.value)}
                    rows={2}
                    placeholder="CareSens Air 및 당사 제품 개발 관점에서 왜 채택해야 하는지 구체적인 위험 사유를 입력하세요."
                    className="w-full px-3 py-2 bg-slate-950 border border-emerald-600/50 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-emerald-400"
                  />
                </div>

                <div>
                  <label className="text-xs font-bold text-cyan-300 block mb-1">
                    차세대 AID 영향 (어떻게 위험한가) <span className="text-rose-400">*필수</span>
                  </label>
                  <textarea
                    value={futureAidRisk}
                    onChange={(e) => setFutureAidRisk(e.target.value)}
                    rows={2}
                    placeholder="인슐린 펌프 연동 시 혈당 과대/과소 측정으로 인한 인슐린 오주입 및 저·고혈당 쇼크 경로를 입력하세요."
                    className="w-full px-3 py-2 bg-slate-950 border border-cyan-600/50 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-cyan-400"
                  />
                </div>
              </div>
            )}

            {/* Use Mode & PPT Options */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
              <div>
                <label className="font-semibold text-slate-300 block mb-1">사용 모드 (Use Mode)</label>
                <select
                  value={useMode}
                  onChange={(e) => setUseMode(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
                >
                  <option value="향후 AID 연동">향후 AID 연동</option>
                  <option value="CGM 단독·수동 치료">CGM 단독·수동 치료</option>
                  <option value="제품 안전·임상·보호자">제품 안전·임상·보호자</option>
                  <option value="펌프 단독 참고">펌프 단독 참고</option>
                </select>
              </div>

              <div>
                <label className="font-semibold text-slate-300 block mb-1">보고용 PPT 게재</label>
                <div className="flex items-center gap-2">
                  <select
                    value={pptInclude}
                    onChange={(e) => setPptInclude(e.target.value)}
                    className="w-24 px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
                  >
                    <option value="N">미포함 (N)</option>
                    <option value="Y">포함 (Y)</option>
                  </select>
                  <input
                    type="text"
                    value={pptId}
                    onChange={(e) => setPptId(e.target.value)}
                    placeholder="PPT ID (예: PPT-HZ-01)"
                    className="flex-1 px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
                  />
                </div>
              </div>
            </div>

            {/* Workflow Status Radio */}
            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1.5">
                검토 상태 (Workflow Status)
              </label>
              <div className="grid grid-cols-3 gap-2 text-xs">
                {[
                  { id: "검토완료", label: "검토완료", color: "border-indigo-500 text-indigo-400 bg-indigo-950/40" },
                  { id: "확정", label: "확정", color: "border-emerald-500 text-emerald-400 bg-emerald-950/40" },
                  { id: "미검토", label: "미검토", color: "border-slate-600 text-slate-300 bg-slate-900" },
                ].map((s) => (
                  <button
                    key={s.id}
                    type="button"
                    onClick={() => setWorkflowStatus(s.id)}
                    className={`py-2 px-2 text-center rounded-xl border text-xs font-semibold transition cursor-pointer ${
                      workflowStatus === s.id ? s.color + " ring-2 ring-indigo-500" : "border-slate-800 text-slate-400 bg-slate-950 hover:bg-slate-800"
                    }`}
                  >
                    {s.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Reviewer Name */}
            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1">
                검토자 이름 (Reviewer)
              </label>
              <input
                type="text"
                value={reviewerName}
                onChange={(e) => setReviewerName(e.target.value)}
                placeholder="예: 홍길동 책임연구원 (RA/QA)"
                className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
              />
            </div>

            {/* Internal Tags */}
            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1">
                사내 관리 태그 (Internal Tags)
              </label>
              <input
                type="text"
                value={internalTags}
                onChange={(e) => setInternalTags(e.target.value)}
                placeholder="예: 알고리즘개선, 센서전극, 2026-Q4"
                className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
              />
            </div>

            {/* Review Note */}
            <div>
              <label className="text-xs font-semibold text-slate-300 block mb-1">
                검토 의견 및 설계 예방 대책 메모 (Review Note)
              </label>
              <textarea
                value={reviewNote}
                onChange={(e) => setReviewNote(e.target.value)}
                rows={3}
                placeholder="검토 의견 및 후속 조치 사항을 작성하세요."
                className="w-full px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-xs text-slate-200 focus:outline-none focus:border-indigo-500"
              />
            </div>

            <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setSelectedHazard(null)}
                className="px-4 py-2 rounded-xl text-xs text-slate-400 hover:text-white hover:bg-slate-800 transition cursor-pointer"
              >
                취소
              </button>
              <button
                type="button"
                onClick={handleSaveReview}
                disabled={savingReview}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-indigo-600 hover:bg-indigo-500 text-white shadow-lg shadow-indigo-900/40 transition cursor-pointer disabled:opacity-50"
              >
                {savingReview ? "저장 중..." : "검토 및 판단 저장"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
