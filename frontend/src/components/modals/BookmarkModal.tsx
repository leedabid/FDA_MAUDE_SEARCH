import React, { useState, useEffect } from "react";
import { X, Star, Tag, Folder, Plus, Trash2, Save, FileText } from "lucide-react";
import { getBookmarks, saveBookmark, deleteBookmark } from "../../api/client";
import type { BookmarkItem } from "../../types";

interface BookmarkModalProps {
  isOpen: boolean;
  onClose: () => void;
  reportNumber: string;
  brandName?: string;
  eventType?: string;
  onSaved: () => void;
}

const DEFAULT_PRESET_TAGS = [
  "센서접착불량",
  "측정오차(고혈당)",
  "측정오차(저혈당)",
  "중증상해",
  "어플리케이터오류",
  "신호두절(Signal Loss)",
  "피부발진/가려움",
  "제조사불량인정",
  "환자사용미숙",
];

export const BookmarkModal: React.FC<BookmarkModalProps> = ({
  isOpen,
  onClose,
  reportNumber,
  brandName,
  eventType,
  onSaved,
}) => {
  const [folders, setFolders] = useState<string[]>(["기본 보관함", "관심 보고서", "상해 의심 건", "센서 오작동"]);
  const [selectedFolder, setSelectedFolder] = useState<string>("기본 보관함");
  const [newFolderInput, setNewFolderInput] = useState<string>("");
  const [showNewFolder, setShowNewFolder] = useState<boolean>(false);
  const [tags, setTags] = useState<string[]>([]);
  const [newTagInput, setNewTagInput] = useState<string>("");
  const [note, setNote] = useState<string>("");
  const [isSaved, setIsSaved] = useState<boolean>(false);
  const [saving, setSaving] = useState<boolean>(false);

  useEffect(() => {
    if (!isOpen || !reportNumber) return;

    const load = async () => {
      try {
        const data = await getBookmarks();
        setFolders(data.folders || ["기본 보관함", "관심 보고서", "상해 의심 건", "센서 오작동"]);
        const existing = data.bookmarks?.[reportNumber];
        if (existing) {
          setSelectedFolder(existing.folder || "기본 보관함");
          setTags(existing.tags || []);
          setNote(existing.note || "");
          setIsSaved(true);
        } else {
          setSelectedFolder(data.folders?.[0] || "기본 보관함");
          setTags([]);
          setNote("");
          setIsSaved(false);
        }
      } catch (err) {
        console.error(err);
      }
    };
    load();
  }, [isOpen, reportNumber]);

  const handleAddTag = (tagToAdd: string) => {
    const trimmed = tagToAdd.trim().replace(/^#/, "");
    if (!trimmed) return;
    if (!tags.includes(trimmed)) {
      setTags([...tags, trimmed]);
    }
    setNewTagInput("");
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setTags(tags.filter((t) => t !== tagToRemove));
  };

  const handleAddFolder = () => {
    const trimmed = newFolderInput.trim();
    if (!trimmed) return;
    if (!folders.includes(trimmed)) {
      setFolders([...folders, trimmed]);
    }
    setSelectedFolder(trimmed);
    setNewFolderInput("");
    setShowNewFolder(false);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await saveBookmark(reportNumber, selectedFolder, tags, note);
      onSaved();
      onClose();
    } catch (err) {
      console.error(err);
      alert("북마크 저장 중 오류가 발생했습니다.");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!confirm("이 보고서를 보관함에서 삭제하시겠습니까?")) return;
    try {
      await deleteBookmark(reportNumber);
      onSaved();
      onClose();
    } catch (err) {
      console.error(err);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/75 backdrop-blur-sm p-4 animate-fadeIn">
      <div className="relative w-full max-w-lg bg-slate-900 border border-slate-700 rounded-2xl shadow-2xl overflow-hidden text-slate-200">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-800 bg-slate-950/70">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-amber-500/20 text-amber-400 rounded-lg border border-amber-500/30">
              <Star className="w-5 h-5 fill-amber-400" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white flex items-center gap-2">
                보고서 북마크 & 태그 저장
              </h2>
              <p className="text-xs text-slate-400 font-mono">
                MDR No. {reportNumber} {brandName && `• ${brandName}`}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <div className="p-6 space-y-5 text-xs">
          {/* Folder Selection */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <label className="font-semibold text-slate-300 flex items-center gap-1.5">
                <Folder className="w-4 h-4 text-indigo-400" />
                보관 폴더 (Group / Folder)
              </label>
              {!showNewFolder && (
                <button
                  type="button"
                  onClick={() => setShowNewFolder(true)}
                  className="text-indigo-400 hover:text-indigo-300 flex items-center gap-1 text-[11px]"
                >
                  <Plus className="w-3.5 h-3.5" /> 새 폴더 만들기
                </button>
              )}
            </div>

            {showNewFolder ? (
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="새 폴더 이름 (예: 2024년 4분기 핵심 분석)"
                  value={newFolderInput}
                  onChange={(e) => setNewFolderInput(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleAddFolder()}
                  className="flex-1 px-3 py-2 bg-slate-950 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-indigo-500"
                />
                <button
                  onClick={handleAddFolder}
                  className="px-3 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl font-medium"
                >
                  추가
                </button>
                <button
                  onClick={() => setShowNewFolder(false)}
                  className="px-3 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl"
                >
                  취소
                </button>
              </div>
            ) : (
              <select
                value={selectedFolder}
                onChange={(e) => setSelectedFolder(e.target.value)}
                className="w-full px-3 py-2.5 bg-slate-950 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-indigo-500"
              >
                {folders.map((f) => (
                  <option key={f} value={f}>
                    📁 {f}
                  </option>
                ))}
              </select>
            )}
          </div>

          {/* Tags */}
          <div>
            <label className="font-semibold text-slate-300 flex items-center gap-1.5 mb-2">
              <Tag className="w-4 h-4 text-emerald-400" />
              태그 (Tags)
            </label>

            {/* Selected Tags */}
            <div className="flex flex-wrap gap-1.5 mb-2 min-h-[32px] p-2 bg-slate-950/60 border border-slate-800 rounded-xl">
              {tags.length === 0 ? (
                <span className="text-slate-500 text-[11px] self-center">선택된 태그가 없습니다.</span>
              ) : (
                tags.map((t) => (
                  <span
                    key={t}
                    className="inline-flex items-center gap-1 px-2.5 py-1 bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 rounded-lg text-[11px] font-medium"
                  >
                    #{t}
                    <button
                      type="button"
                      onClick={() => handleRemoveTag(t)}
                      className="hover:text-white"
                    >
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                ))
              )}
            </div>

            {/* Tag Input */}
            <div className="flex gap-2 mb-2">
              <input
                type="text"
                placeholder="직접 태그 입력 후 Enter (예: 센서탈락)"
                value={newTagInput}
                onChange={(e) => setNewTagInput(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleAddTag(newTagInput)}
                className="flex-1 px-3 py-1.5 bg-slate-950 border border-slate-800 rounded-lg text-white focus:outline-none focus:border-emerald-500 text-xs"
              />
              <button
                type="button"
                onClick={() => handleAddTag(newTagInput)}
                className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs font-medium"
              >
                추가
              </button>
            </div>

            {/* Preset Tags Quick Select */}
            <div className="flex flex-wrap gap-1">
              {DEFAULT_PRESET_TAGS.map((pt) => {
                const isSelected = tags.includes(pt);
                return (
                  <button
                    key={pt}
                    type="button"
                    onClick={() => (isSelected ? handleRemoveTag(pt) : handleAddTag(pt))}
                    className={`px-2 py-0.5 rounded text-[10px] transition border ${
                      isSelected
                        ? "bg-emerald-600/30 border-emerald-500 text-emerald-200"
                        : "bg-slate-800/40 border-slate-800 text-slate-400 hover:bg-slate-800 hover:text-slate-200"
                    }`}
                  >
                    +{pt}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Private Notes */}
          <div>
            <label className="font-semibold text-slate-300 flex items-center gap-1.5 mb-2">
              <FileText className="w-4 h-4 text-amber-400" />
              메모 및 특이사항 (Private Notes)
            </label>
            <textarea
              rows={3}
              placeholder="해당 건에 대한 분석 의견이나 후속 조치 필요사항을 기록하세요..."
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="w-full px-3 py-2 bg-slate-950 border border-slate-800 rounded-xl text-white focus:outline-none focus:border-amber-500 text-xs resize-none placeholder-slate-600"
            />
          </div>
        </div>

        {/* Footer Actions */}
        <div className="flex items-center justify-between px-6 py-3.5 border-t border-slate-800 bg-slate-950/80">
          <div>
            {isSaved && (
              <button
                type="button"
                onClick={handleDelete}
                className="flex items-center gap-1.5 px-3 py-1.5 text-xs text-rose-400 hover:text-rose-300 hover:bg-rose-500/10 rounded-lg transition"
              >
                <Trash2 className="w-3.5 h-3.5" />
                보관함에서 삭제
              </button>
            )}
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={onClose}
              className="px-4 py-2 text-xs font-medium text-slate-400 hover:text-white rounded-xl hover:bg-slate-800 transition"
            >
              취소
            </button>
            <button
              onClick={handleSave}
              disabled={saving}
              className="flex items-center gap-1.5 px-5 py-2 text-xs font-semibold bg-amber-500 hover:bg-amber-400 text-slate-950 rounded-xl shadow-lg shadow-amber-500/20 transition font-medium"
            >
              <Save className="w-4 h-4" />
              {saving ? "저장 중..." : isSaved ? "수정 사항 저장" : "보관함에 저장"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
