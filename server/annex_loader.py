# -*- coding: utf-8 -*-
"""FDA Annex A~G Problem Code Loader & Mapper."""
from __future__ import annotations

import json
import logging
import re
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

import pandas as pd

log = logging.getLogger("annex_loader")

BASE_DIR = Path(__file__).resolve().parent.parent
ANNEX_XLSX_PATH = BASE_DIR / "fda-annexes-a-g-2025.xlsx"
PROBLEM_CODE_MAP_PATH = BASE_DIR / "problem_code_map.json"

# Global caches
_PATIENT_TERM_TO_CODE: Dict[str, str] = {}
_DEVICE_TERM_TO_CODE: Dict[str, str] = {}
_PATIENT_CODE_TO_TERM: Dict[str, str] = {}
_DEVICE_CODE_TO_TERM: Dict[str, str] = {}
_KNOWN_PATIENT_TERMS: Set[str] = set()
_KNOWN_DEVICE_TERMS: Set[str] = set()
_LOADED = False


def normalize_term(term: str) -> str:
    """Normalize term for case-insensitive lookup."""
    return re.sub(r"\s+", " ", str(term or "").strip()).casefold()


def load_annex_codes(force: bool = False) -> Tuple[Dict[str, str], Dict[str, str]]:
    """Loads Annex A and Annex E code dictionaries."""
    global _PATIENT_TERM_TO_CODE, _DEVICE_TERM_TO_CODE
    global _PATIENT_CODE_TO_TERM, _DEVICE_CODE_TO_TERM
    global _KNOWN_PATIENT_TERMS, _KNOWN_DEVICE_TERMS, _LOADED

    if _LOADED and not force:
        return _PATIENT_TERM_TO_CODE, _DEVICE_TERM_TO_CODE

    patient_map: Dict[str, str] = {}
    device_map: Dict[str, str] = {}
    patient_rev: Dict[str, str] = {}
    device_rev: Dict[str, str] = {}

    # 1. Load from problem_code_map.json (baseline)
    if PROBLEM_CODE_MAP_PATH.exists():
        try:
            with open(PROBLEM_CODE_MAP_PATH, "r", encoding="utf-8") as f:
                data = json.load(f)
                for term, code in data.get("patient", {}).items():
                    patient_map[normalize_term(term)] = str(code).strip()
                    patient_rev[str(code).strip()] = term
                for term, code in data.get("device", {}).items():
                    device_map[normalize_term(term)] = str(code).strip()
                    device_rev[str(code).strip()] = term
        except Exception as e:
            log.warning(f"Failed to load problem_code_map.json: {e}")

    # 2. Load from fda-annexes-a-g-2025.xlsx if present
    if ANNEX_XLSX_PATH.exists():
        try:
            excel = pd.ExcelFile(ANNEX_XLSX_PATH)
            sheet_names = excel.sheet_names

            # Target sheets: Annex A / Annex E or Combined
            for sname in sheet_names:
                df = excel.parse(sname)
                cols = [str(c).strip().lower() for c in df.columns]

                # Look for term and code columns
                code_col = None
                term_col = None
                annex_type_col = None

                for orig_c, norm_c in zip(df.columns, cols):
                    if "code" in norm_c and not code_col:
                        code_col = orig_c
                    if any(k in norm_c for k in ["term", "preferred", "name", "concept"]) and not term_col:
                        term_col = orig_c
                    if "annex" in norm_c or "type" in norm_c or "category" in norm_c:
                        annex_type_col = orig_c

                if code_col and term_col:
                    for _, row in df.iterrows():
                        code = str(row[code_col] or "").strip()
                        term = str(row[term_col] or "").strip()
                        if not code or not term or code.lower() in ("nan", "none") or term.lower() in ("nan", "none"):
                            continue
                        
                        annex_val = str(row[annex_type_col] if annex_type_col else sname).upper()
                        
                        if "ANNEX A" in annex_val or "DEVICE" in annex_val or "A" == annex_val.strip():
                            device_map[normalize_term(term)] = code
                            if code not in device_rev:
                                device_rev[code] = term
                        elif "ANNEX E" in annex_val or "HEALTH" in annex_val or "CLINICAL" in annex_val or "E" == annex_val.strip():
                            patient_map[normalize_term(term)] = code
                            if code not in patient_rev:
                                patient_rev[code] = term
                        else:
                            # fallback: add to both if generic
                            if normalize_term(term) not in patient_map:
                                patient_map[normalize_term(term)] = code
                            if normalize_term(term) not in device_map:
                                device_map[normalize_term(term)] = code
        except Exception as e:
            log.warning(f"Failed to load Excel annexes: {e}")

    _PATIENT_TERM_TO_CODE = patient_map
    _DEVICE_TERM_TO_CODE = device_map
    _PATIENT_CODE_TO_TERM = patient_rev
    _DEVICE_CODE_TO_TERM = device_rev
    _KNOWN_PATIENT_TERMS = set(patient_map.keys())
    _KNOWN_DEVICE_TERMS = set(device_map.keys())
    _LOADED = True

    return _PATIENT_TERM_TO_CODE, _DEVICE_TERM_TO_CODE


def split_problem_terms(raw: str, problem_type: str = "patient") -> List[str]:
    """Splits comma/semicolon delimited problem strings preserving known Annex terms with commas."""
    if not raw or not str(raw).strip():
        return []
    
    load_annex_codes()
    text = str(raw).strip()
    
    # Check if text contains semicolons
    if ";" in text:
        return [t.strip() for t in text.split(";") if t.strip()]

    # If comma separated, check against known multi-word terms
    tokens = [t.strip() for t in text.split(",") if t.strip()]
    if len(tokens) <= 1:
        return tokens

    known_terms = _KNOWN_PATIENT_TERMS if problem_type == "patient" else _KNOWN_DEVICE_TERMS
    result: List[str] = []
    i = 0
    while i < len(tokens):
        # Try matching 2 or 3 tokens merged
        merged_3 = f"{tokens[i]}, {tokens[i+1]}, {tokens[i+2]}" if i + 2 < len(tokens) else None
        merged_2 = f"{tokens[i]}, {tokens[i+1]}" if i + 1 < len(tokens) else None

        if merged_3 and normalize_term(merged_3) in known_terms:
            result.append(merged_3)
            i += 3
        elif merged_2 and normalize_term(merged_2) in known_terms:
            result.append(merged_2)
            i += 2
        else:
            result.append(tokens[i])
            i += 1
            
    return result


def get_patient_code(term: str) -> Optional[str]:
    """Resolve patient problem term to Annex E code."""
    load_annex_codes()
    return _PATIENT_TERM_TO_CODE.get(normalize_term(term))


def get_device_code(term: str) -> Optional[str]:
    """Resolve device problem term to Annex A code."""
    load_annex_codes()
    return _DEVICE_TERM_TO_CODE.get(normalize_term(term))


def get_term_by_code(code: str) -> Optional[str]:
    """Resolve code to term name."""
    load_annex_codes()
    c = str(code).strip()
    return _PATIENT_CODE_TO_TERM.get(c) or _DEVICE_CODE_TO_TERM.get(c)


# Preload on import
load_annex_codes()
