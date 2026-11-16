import React, { useState } from "react";
import { X, Plus, Trash2, Check, FolderPlus, Sparkles, Layers, CheckSquare, Square } from "lucide-react";

export interface CustomTrendGroup {
  id: string;
  name: string;
  brands: string[];
}

interface CustomTrendGroupModalProps {
  isOpen: boolean;
  onClose: () => void;
  availableBrands: string[];
  groups: CustomTrendGroup[];
  onSaveGroups: (groups: CustomTrendGroup[]) => void;
}

export const CustomTrendGroupModal: React.FC<CustomTrendGroupModalProps> = ({
  isOpen,
  onClose,
  availableBrands,
  groups: initialGroups,
  onSaveGroups,
}) => {
  const [groups, setGroups] = useState<CustomTrendGroup[]>(initialGroups);
  const [editingGroupId, setEditingGroupId] = useState<string | null>(null);
  const [groupNameInput, setGroupNameInput] = useState<string>("");
  const [selectedBrands, setSelectedBrands] = useState<string[]>([]);

  if (!isOpen) return null;

  // Start adding new group
  const handleStartAdd = () => {
    setEditingGroupId("new");
    setGroupNameInput("");
    setSelectedBrands([]);
  };

  // Start editing existing group
  const handleStartEdit = (group: CustomTrendGroup) => {
    setEditingGroupId(group.id);
    setGroupNameInput(group.name);
    setSelectedBrands(group.brands);
  };

  // Toggle brand in editing mode
  const handleToggleBrand = (brand: string) => {
    setSelectedBrands((prev) =>
      prev.includes(brand) ? prev.filter((b) => b !== brand) : [...prev, brand]
    );
  };

  // Save current editing group
  const handleSaveCurrentGroup = () => {
    const trimmed = groupNameInput.trim();
    if (!trimmed) {
      alert("그룹 이름을 입력해 주세요. (예: Dexcom, Abbott)");
      return;
    }
    if (selectedBrands.length === 0) {
      alert("그룹에 포함할 제품을 최소 1개 이상 선택해 주세요.");
      return;
    }

    if (editingGroupId === "new") {
      const newGroup: CustomTrendGroup = {
        id: `group_${Date.now()}`,
        name: trimmed,
        brands: selectedBrands,
      };
      setGroups([...groups, newGroup]);
    } else {
      setGroups(
        groups.map((g) =>
          g.id === editingGroupId ? { ...g, name: trimmed, brands: selectedBrands } : g
        )
      );
    }

    setEditingGroupId(null);
    setGroupNameInput("");
    setSelectedBrands([]);
  };

  // Delete a group
  const handleDeleteGroup = (id: string) => {
    setGroups(groups.filter((g) => g.id !== id));
    if (editingGroupId === id) {
      setEditingGroupId(null);
    }
  };

  // One-click preset template: Dexcom vs Abbott vs Insulet vs Tandem
  const handleApplyPresetTemplate = () => {
    const dexcomBrands = availableBrands.filter((b) => b.toLowerCase().includes("dexcom"));
    const abbottBrands = availableBrands.filter((b) => b.toLowerCase().includes("libre"));
    const insuletBrands = availableBrands.filter((b) => b.toLowerCase().includes("omnipod"));
    const tandemBrands = availableBrands.filter((b) =>
      b.toLowerCase().includes("tandem") || b.toLowerCase().includes("slim") || b.toLowerCase().includes("mobi")
    );

    const presetGroups: CustomTrendGroup[] = [];
    if (dexcomBrands.length > 0) {
      presetGroups.push({ id: "preset_dexcom", name: "Dexcom", brands: dexcomBrands });
    }
    if (abbottBrands.length > 0) {
      presetGroups.push({ id: "preset_abbott", name: "Abbott", brands: abbottBrands });
    }
    if (insuletBrands.length > 0) {
      presetGroups.push({ id: "preset_insulet", name: "Insulet (Omnipod)", brands: insuletBrands });
    }
    if (tandemBrands.length > 0) {
      presetGroups.push({ id: "preset_tandem", name: "Tandem", brands: tandemBrands });
    }

    setGroups(presetGroups);
    setEditingGroupId(null);
  };

  const handleApplyAndClose = () => {
    onSaveGroups(groups);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 backdrop-blur-md p-4 animate-fadeIn">
      <div className="bg-slate-900 border border-slate-700 rounded-3xl w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col max-h-[85vh] text-slate-200">
        {/* Header */}
        <div className="p-5 border-b border-slate-800 bg-slate-950/80 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-indigo-500/20 text-indigo-400 rounded-2xl border border-indigo-500/30">
              <Layers className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white flex items-center gap-2">
                월별 추이 커스텀 제품 묶음(그룹핑) 설정
              </h2>
              <p className="text-xs text-slate-400">
                여러 개별 제품을 사용자가 지정한 이름(예: Dexcom, Abbott)으로 묶어 100% 누적 비중 및 건수를 비교합니다.
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-white rounded-xl hover:bg-slate-800 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 space-y-5 overflow-y-auto custom-scrollbar flex-1 text-xs">
          {/* Top Preset Recommendation */}
          <div className="p-3.5 bg-indigo-950/40 border border-indigo-500/30 rounded-2xl flex items-center justify-between gap-3">
            <div className="flex items-center gap-2 text-indigo-300">
              <Sparkles className="w-4 h-4 text-indigo-400 shrink-0" />
              <span>
                <strong>원클릭 추천 템플릿:</strong> 제조사별(Dexcom / Abbott / Insulet / Tandem)로 즉시 묶으시겠습니까?
              </span>
            </div>
            <button
              type="button"
              onClick={handleApplyPresetTemplate}
              className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white font-bold rounded-xl text-xs transition shrink-0 shadow-md"
            >
              추천 템플릿 적용
            </button>
          </div>

          {/* Group Editor Card (Add or Edit) */}
          {editingGroupId !== null ? (
            <div className="p-4 bg-slate-950/90 border border-indigo-500/50 rounded-2xl space-y-3 shadow-lg animate-fadeIn">
              <div className="flex items-center justify-between">
                <span className="font-bold text-white text-xs flex items-center gap-1.5">
                  <FolderPlus className="w-4 h-4 text-indigo-400" />
                  {editingGroupId === "new" ? "새 묶음 그룹 만들기" : "그룹 수정"}
                </span>
                <button
                  type="button"
                  onClick={() => setEditingGroupId(null)}
                  className="text-slate-400 hover:text-white text-xs"
                >
                  취소
                </button>
              </div>

              {/* Group Name Input */}
              <div>
                <label className="text-[11px] text-slate-400 block mb-1">
                  그룹 이름 (예: Dexcom, Abbott, My CGM Group)
                </label>
                <input
                  type="text"
                  placeholder="그룹 이름을 입력하세요..."
                  value={groupNameInput}
                  onChange={(e) => setGroupNameInput(e.target.value)}
                  className="w-full px-3 py-2 bg-slate-900 border border-slate-700 rounded-xl text-white text-xs focus:outline-none focus:border-indigo-500 font-semibold"
                />
              </div>

              {/* Brand Selector Checklist */}
              <div>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-[11px] text-slate-400">
                    포함할 제품 선택 ({selectedBrands.length}개 선택됨):
                  </span>
                  <div className="flex items-center gap-2 text-[10px] text-slate-400">
                    <button
                      type="button"
                      onClick={() => setSelectedBrands([...availableBrands])}
                      className="hover:text-indigo-300"
                    >
                      전체 선택
                    </button>
                    <span>•</span>
                    <button
                      type="button"
                      onClick={() => setSelectedBrands([])}
                      className="hover:text-indigo-300"
                    >
                      전체 해제
                    </button>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto custom-scrollbar p-2 bg-slate-900/60 rounded-xl border border-slate-800">
                  {availableBrands.map((brand) => {
                    const isSelected = selectedBrands.includes(brand);
                    return (
                      <div
                        key={brand}
                        onClick={() => handleToggleBrand(brand)}
                        className={`p-2 rounded-lg border cursor-pointer transition flex items-center gap-2 select-none text-xs ${
                          isSelected
                            ? "bg-indigo-600/20 border-indigo-500 text-white font-semibold"
                            : "bg-slate-950/40 border-slate-800 text-slate-400 hover:border-slate-700"
                        }`}
                      >
                        {isSelected ? (
                          <CheckSquare className="w-3.5 h-3.5 text-indigo-400 shrink-0" />
                        ) : (
                          <Square className="w-3.5 h-3.5 text-slate-600 shrink-0" />
                        )}
                        <span className="truncate">{brand}</span>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Save Group Button */}
              <div className="flex justify-end pt-1">
                <button
                  type="button"
                  onClick={handleSaveCurrentGroup}
                  className="px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white font-bold rounded-xl text-xs transition shadow flex items-center gap-1.5"
                >
                  <Check className="w-3.5 h-3.5" />
                  <span>이 그룹 저장</span>
                </button>
              </div>
            </div>
          ) : (
            <button
              type="button"
              onClick={handleStartAdd}
              className="w-full py-2.5 px-4 bg-slate-800/80 hover:bg-slate-800 border border-dashed border-slate-700 hover:border-indigo-500 text-indigo-300 rounded-2xl text-xs font-semibold flex items-center justify-center gap-2 transition"
            >
              <Plus className="w-4 h-4" />
              <span>새로운 제품 묶음(그룹) 추가하기</span>
            </button>
          )}

          {/* Current Groups List */}
          <div className="space-y-3">
            <span className="font-bold text-white text-xs block">
              설정된 제품 묶음 목록 ({groups.length}개 그룹)
            </span>

            {groups.length === 0 ? (
              <div className="p-6 text-center text-slate-500 bg-slate-950/40 rounded-2xl border border-slate-800">
                아직 생성된 묶음이 없습니다. 위의 버튼을 눌러 그룹을 추가하거나 [추천 템플릿]을 적용해 보세요.
              </div>
            ) : (
              <div className="space-y-2.5">
                {groups.map((group, idx) => (
                  <div
                    key={group.id}
                    className="p-3.5 bg-slate-950/60 border border-slate-800 rounded-2xl flex items-start justify-between gap-3 group hover:border-slate-700 transition"
                  >
                    <div className="space-y-1.5 flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="w-2.5 h-2.5 rounded-full bg-indigo-500 shrink-0"></span>
                        <h4 className="font-bold text-white text-sm">{group.name}</h4>
                        <span className="text-[10px] text-indigo-300 font-mono bg-indigo-500/20 px-2 py-0.5 rounded-full border border-indigo-500/30">
                          {group.brands.length}개 제품 묶음
                        </span>
                      </div>
                      <div className="flex flex-wrap gap-1">
                        {group.brands.map((b) => (
                          <span
                            key={b}
                            className="px-2 py-0.5 bg-slate-900 text-slate-300 text-[10px] rounded-md border border-slate-800"
                          >
                            {b}
                          </span>
                        ))}
                      </div>
                    </div>

                    <div className="flex items-center gap-1 shrink-0">
                      <button
                        type="button"
                        onClick={() => handleStartEdit(group)}
                        className="px-2.5 py-1 text-slate-400 hover:text-white bg-slate-900 hover:bg-slate-800 rounded-lg border border-slate-800 transition text-[11px]"
                      >
                        편집
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDeleteGroup(group.id)}
                        className="p-1.5 text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 rounded-lg transition"
                        title="그룹 삭제"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-slate-800 bg-slate-950/80 flex items-center justify-between">
          <div className="text-[11px] text-slate-400">
            💡 설정된 그룹은 브라우저에 자동 저장되며 월별 100% 비중 및 건수 차트에 즉시 합산 반영됩니다.
          </div>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={onClose}
              className="py-2 px-4 bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold rounded-xl text-xs transition"
            >
              취소
            </button>
            <button
              type="button"
              onClick={handleApplyAndClose}
              className="py-2 px-5 bg-indigo-600 hover:bg-indigo-500 text-white font-bold rounded-xl text-xs flex items-center gap-1.5 shadow-lg transition"
            >
              <Check className="w-4 h-4" />
              <span>묶음 저장 및 차트 적용</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
