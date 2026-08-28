import React, { useState, useEffect, useMemo } from "react";
import {
  X,
  Plus,
  Trash2,
  Check,
  Search,
  Layers,
  Save,
  RefreshCw,
  Info,
  CheckCheck,
  XSquare,
  Tag,
} from "lucide-react";
import { getBrandGroups, updateBrandGroups } from "../../api/client";
import { matchMultiWordSearch } from "../../utils/search";

interface BrandGroupManagerModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSaved: () => void;
}

export const BrandGroupManagerModal: React.FC<BrandGroupManagerModalProps> = ({
  isOpen,
  onClose,
  onSaved,
}) => {
  const [groups, setGroups] = useState<Record<string, string[]>>({});
  const [groupCategories, setGroupCategories] = useState<Record<string, string>>({});
  const [allBrands, setAllBrands] = useState<string[]>([]);
  const [selectedGroup, setSelectedGroup] = useState<string>("");
  const [newGroupName, setNewGroupName] = useState("");
  const [newGroupCat, setNewGroupCat] = useState<"CGM" | "Insulin Pump">("CGM");
  const [searchQuery, setSearchQuery] = useState("");
  const [hideAssigned, setHideAssigned] = useState(true);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [statusMsg, setStatusMsg] = useState("");

  const loadData = async () => {
    setLoading(true);
    try {
      const data = await getBrandGroups();
      setGroups(data.groups || {});
      setGroupCategories(data.categories || {});
      setAllBrands(data.all_brands || []);
      const firstGroup = Object.keys(data.groups || {})[0] || "";
      setSelectedGroup(firstGroup);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isOpen) {
      loadData();
    }
  }, [isOpen]);

  // Set of all brands assigned to ANY group
  const allAssignedBrands = useMemo(() => {
    const set = new Set<string>();
    Object.values(groups).forEach((members) => {
      members.forEach((m) => set.add(m.trim().toUpperCase()));
    });
    return set;
  }, [groups]);

  // Current selected group members (set)
  const currentMembersSet = useMemo(() => {
    if (!selectedGroup || !groups[selectedGroup]) return new Set<string>();
    return new Set(groups[selectedGroup].map((m) => m.trim().toUpperCase()));
  }, [groups, selectedGroup]);

  // Filtered raw brands list using multi-word matching
  const filteredBrands = useMemo(() => {
    return allBrands.filter((b) => {
      const matchesSearch = matchMultiWordSearch(b, searchQuery);
      if (!matchesSearch) return false;

      const upper = b.trim().toUpperCase();
      if (hideAssigned) {
        // Show if it belongs to current group OR is not assigned to ANY group
        const isCurrentMember = currentMembersSet.has(upper);
        const isAssignedElsewhere = allAssignedBrands.has(upper) && !isCurrentMember;
        return !isAssignedElsewhere;
      }
      return true;
    });
  }, [allBrands, searchQuery, hideAssigned, allAssignedBrands, currentMembersSet]);

  const handleToggleBrand = (brand: string) => {
    if (!selectedGroup) return;
    const currentMembers = groups[selectedGroup] || [];
    const exists = currentMembers.includes(brand);

    let updated: string[];
    if (exists) {
      updated = currentMembers.filter((b) => b !== brand);
    } else {
      updated = [...currentMembers, brand];
    }

    setGroups({
      ...groups,
      [selectedGroup]: updated,
    });
  };

  // Bulk select all currently filtered brands into active group
  const handleBulkSelectFiltered = (select: boolean) => {
    if (!selectedGroup) return;
    const currentMembers = new Set(groups[selectedGroup] || []);
    if (select) {
      filteredBrands.forEach((b) => currentMembers.add(b));
    } else {
      filteredBrands.forEach((b) => currentMembers.delete(b));
    }
    setGroups({
      ...groups,
      [selectedGroup]: Array.from(currentMembers),
    });
  };

  const handleCreateGroup = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = newGroupName.trim();
    if (!trimmed) return;
    if (groups[trimmed]) {
      alert("이미 존재하는 그룹 이름입니다.");
      return;
    }

    setGroups({
      ...groups,
      [trimmed]: [],
    });
    setGroupCategories({
      ...groupCategories,
      [trimmed]: newGroupCat,
    });
    setSelectedGroup(trimmed);
    setNewGroupName("");
  };

  const handleDeleteGroup = (groupName: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (!confirm(`'${groupName}' 그룹을 삭제하시겠습니까?`)) return;

    const copy = { ...groups };
    const catCopy = { ...groupCategories };
    delete copy[groupName];
    delete catCopy[groupName];

    setGroups(copy);
    setGroupCategories(catCopy);

    if (selectedGroup === groupName) {
      const remaining = Object.keys(copy);
      setSelectedGroup(remaining[0] || "");
    }
  };

  const handleToggleCategory = (groupName: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const currentCat = groupCategories[groupName] || "CGM";
    const nextCat = currentCat === "CGM" ? "Insulin Pump" : "CGM";
    setGroupCategories({
      ...groupCategories,
      [groupName]: nextCat,
    });
  };

  const handleSave = async () => {
    setSaving(true);
    setStatusMsg("");
    try {
      await updateBrandGroups(groups, groupCategories);
      onSaved();
      const now = new Date().toLocaleTimeString();
      setStatusMsg(`✓ 저장되었습니다 (${now})`);
      setTimeout(() => setStatusMsg(""), 4000);
    } catch (err) {
      console.error("Failed to save brand groups:", err);
      alert("저장에 실패했습니다. 다시 시도해 주세요.");
    } finally {
      setSaving(false);
    }
  };

  if (!isOpen) return null;

  const currentMembers = groups[selectedGroup] || [];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-fadeIn">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl w-full max-w-5xl h-[88vh] flex flex-col shadow-2xl overflow-hidden">
        {/* Modal Header */}
        <div className="p-5 border-b border-slate-800 flex items-center justify-between bg-slate-900/80">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-indigo-500/10 text-indigo-400 border border-indigo-500/20 rounded-xl">
              <Layers className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white flex items-center gap-2">
                대표 브랜드 그룹 & 카테고리 관리자
              </h2>
              <p className="text-xs text-slate-400">
                1,700여 개 원본 제품명을 사용자 지정 대표 그룹 및 의료기기 카테고리(CGM / 인슐린 펌프)로 매핑합니다.
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-slate-400 hover:text-white p-2 rounded-lg hover:bg-slate-800 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body: Split Screen */}
        <div className="flex-1 flex overflow-hidden">
          {/* Left Column: Groups List & Creator (w-80) */}
          <div className="w-80 border-r border-slate-800 bg-slate-950/50 p-4 flex flex-col gap-3 shrink-0">
            {/* New Group Creator */}
            <form onSubmit={handleCreateGroup} className="space-y-2 pb-3 border-b border-slate-800">
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="새 대표 그룹명 입력..."
                  value={newGroupName}
                  onChange={(e) => setNewGroupName(e.target.value)}
                  className="flex-1 px-3 py-1.5 text-xs bg-slate-900 border border-slate-800 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500"
                />
                <button
                  type="submit"
                  disabled={!newGroupName.trim()}
                  className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 text-white text-xs font-semibold rounded-xl transition flex items-center gap-1 shrink-0"
                >
                  <Plus className="w-3.5 h-3.5" />
                  추가
                </button>
              </div>
              <div className="flex items-center gap-2 text-[11px]">
                <span className="text-slate-400">카테고리:</span>
                <button
                  type="button"
                  onClick={() => setNewGroupCat("CGM")}
                  className={`px-2 py-0.5 rounded ${
                    newGroupCat === "CGM"
                      ? "bg-indigo-600 text-white font-semibold"
                      : "bg-slate-800 text-slate-400"
                  }`}
                >
                  연속혈당 (CGM)
                </button>
                <button
                  type="button"
                  onClick={() => setNewGroupCat("Insulin Pump")}
                  className={`px-2 py-0.5 rounded ${
                    newGroupCat === "Insulin Pump"
                      ? "bg-indigo-600 text-white font-semibold"
                      : "bg-slate-800 text-slate-400"
                  }`}
                >
                  인슐린 펌프
                </button>
              </div>
            </form>

            <div className="flex items-center justify-between text-xs font-semibold text-slate-300 px-1">
              <span>대표 그룹 목록 ({Object.keys(groups).length})</span>
            </div>

            {/* Groups Scroll List */}
            <div className="flex-1 overflow-y-auto space-y-1.5 custom-scrollbar pr-1">
              {Object.keys(groups).length === 0 ? (
                <div className="text-center py-6 text-slate-500 text-xs">그룹이 없습니다.</div>
              ) : (
                Object.entries(groups).map(([groupName, members]) => {
                  const isSelected = selectedGroup === groupName;
                  const cat = groupCategories[groupName] || "CGM";
                  return (
                    <div
                      key={groupName}
                      onClick={() => setSelectedGroup(groupName)}
                      className={`group flex items-center justify-between px-3 py-2.5 rounded-xl cursor-pointer transition select-none ${
                        isSelected
                          ? "bg-indigo-600 text-white shadow-md font-semibold"
                          : "bg-slate-900/60 hover:bg-slate-800/80 text-slate-300 border border-slate-800/80"
                      }`}
                    >
                      <div className="truncate flex-1 pr-2">
                        <div className="truncate text-xs">{groupName}</div>
                        <div className="flex items-center gap-1.5 mt-0.5">
                          <span
                            onClick={(e) => handleToggleCategory(groupName, e)}
                            title="클릭하여 카테고리 변경 (CGM <-> 인슐린 펌프)"
                            className={`text-[10px] px-1.5 py-0.2 rounded font-sans cursor-pointer ${
                              isSelected
                                ? "bg-indigo-700/80 text-indigo-100"
                                : cat === "CGM"
                                ? "bg-indigo-950 text-indigo-400 border border-indigo-800/50"
                                : "bg-emerald-950 text-emerald-400 border border-emerald-800/50"
                            }`}
                          >
                            {cat === "CGM" ? "CGM" : "펌프"}
                          </span>
                          <span className={`text-[10px] ${isSelected ? "text-indigo-200" : "text-slate-500"}`}>
                            {members.length}개 원본 포함
                          </span>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={(e) => handleDeleteGroup(groupName, e)}
                        className={`opacity-0 group-hover:opacity-100 p-1 rounded hover:bg-rose-500 hover:text-white transition ${
                          isSelected ? "text-indigo-200" : "text-slate-500"
                        }`}
                        title="그룹 삭제"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  );
                })
              )}
            </div>
          </div>

          {/* Right Column: Raw Brands Assigning Workspace */}
          <div className="flex-1 p-5 flex flex-col gap-3 overflow-hidden bg-slate-900/40">
            {selectedGroup ? (
              <>
                {/* Active Group Banner */}
                <div className="flex flex-wrap items-center justify-between gap-3 p-3 bg-slate-950/80 border border-slate-800 rounded-xl">
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-slate-400">선택된 대표 그룹:</span>
                    <span className="text-sm font-bold text-indigo-400">{selectedGroup}</span>
                    <span className="text-xs px-2 py-0.5 bg-indigo-500/10 text-indigo-300 rounded border border-indigo-500/20 font-mono">
                      카테고리: {groupCategories[selectedGroup] || "CGM"}
                    </span>
                    <span className="text-xs px-2 py-0.5 bg-slate-800 text-slate-300 rounded font-mono">
                      포함된 원본: {currentMembers.length}개
                    </span>
                  </div>

                  <div className="flex items-center gap-2">
                    <label className="flex items-center gap-1.5 text-xs text-slate-400 cursor-pointer select-none">
                      <input
                        type="checkbox"
                        checked={hideAssigned}
                        onChange={(e) => setHideAssigned(e.target.checked)}
                        className="rounded border-slate-700 bg-slate-900 text-indigo-600 focus:ring-0"
                      />
                      <span>타 그룹에 할당된 원본 숨기기</span>
                    </label>
                  </div>
                </div>

                {/* Search Bar with Multi-word Rule Hint */}
                <div className="space-y-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-2.5 w-3.5 h-3.5 text-slate-500" />
                    <input
                      type="text"
                      placeholder="DB 원본 브랜드 검색 (예: dexcom sensor 또는 g6, g7)..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-950 border border-slate-800 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500 shadow-inner"
                    />
                  </div>
                  <div className="text-[11px] text-slate-500 px-1 leading-tight flex items-center gap-1">
                    <Info className="w-3 h-3 text-slate-500 shrink-0" />
                    <span>
                      💡 검색 규칙: 띄어쓰기(AND 동시포함: <span className="text-slate-400">dexcom sensor</span>) • 쉼표(,)(OR 다중선택: <span className="text-slate-400">g6, g7</span>)
                    </span>
                  </div>
                </div>

                {/* Bulk Actions & Count */}
                <div className="flex items-center justify-between text-xs text-slate-400 px-1">
                  <span>검색된 원본: {filteredBrands.length}개</span>
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => handleBulkSelectFiltered(true)}
                      className="flex items-center gap-1 px-2 py-1 bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 rounded border border-indigo-500/30 transition text-[11px]"
                    >
                      <CheckCheck className="w-3 h-3" />
                      검색 결과 전체 포함
                    </button>
                    <button
                      type="button"
                      onClick={() => handleBulkSelectFiltered(false)}
                      className="flex items-center gap-1 px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded transition text-[11px]"
                    >
                      <XSquare className="w-3 h-3" />
                      검색 결과 제외
                    </button>
                  </div>
                </div>

                {/* Raw Brands Selection Grid */}
                <div className="flex-1 overflow-y-auto border border-slate-800 rounded-xl p-3 bg-slate-950/60 custom-scrollbar">
                  {filteredBrands.length === 0 ? (
                    <div className="text-center py-12 text-slate-500 text-xs">
                      검색 조건에 일치하는 원본 브랜드가 없습니다.
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                      {filteredBrands.map((brand) => {
                        const isMember = currentMembersSet.has(brand.trim().toUpperCase());
                        return (
                          <div
                            key={brand}
                            onClick={() => handleToggleBrand(brand)}
                            title={brand}
                            className={`flex items-center justify-between px-3 py-2 rounded-xl text-xs cursor-pointer border transition select-none ${
                              isMember
                                ? "bg-indigo-600/20 border-indigo-500/60 text-indigo-200 font-medium"
                                : "bg-slate-900/60 border-slate-800/80 text-slate-400 hover:border-slate-700 hover:text-slate-200"
                            }`}
                          >
                            <span className="truncate pr-2 font-mono text-[11px]" title={brand}>
                              {brand}
                            </span>
                            <div
                              className={`w-4 h-4 rounded flex items-center justify-center shrink-0 border ${
                                isMember
                                  ? "bg-indigo-600 border-indigo-500 text-white"
                                  : "border-slate-700 bg-slate-950"
                              }`}
                            >
                              {isMember && <Check className="w-3 h-3" />}
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              </>
            ) : (
              <div className="flex-1 flex items-center justify-center text-slate-500 text-xs">
                좌측에서 대표 그룹을 선택하거나 새로 생성해 주세요.
              </div>
            )}
          </div>
        </div>

        {/* Modal Footer: Save & Close */}
        <div className="p-4 border-t border-slate-800 bg-slate-900 flex items-center justify-between">
          <div className="text-xs">
            {statusMsg ? (
              <span className="text-emerald-400 font-semibold flex items-center gap-1.5 animate-fadeIn">
                <Check className="w-4 h-4" />
                {statusMsg}
              </span>
            ) : (
              <span className="text-slate-500">
                변경 사항을 저장하면 모든 탭의 통계 그래프에 즉시 반영됩니다.
              </span>
            )}
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={onClose}
              className="px-4 py-2 text-xs font-semibold text-slate-400 hover:text-white hover:bg-slate-800 rounded-xl transition"
            >
              닫기
            </button>
            <button
              onClick={handleSave}
              disabled={saving}
              className="flex items-center gap-2 px-5 py-2 text-xs font-bold bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl shadow-lg transition disabled:opacity-50"
            >
              {saving ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Save className="w-3.5 h-3.5" />}
              <span>{saving ? "저장 중..." : "변경 사항 저장"}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
