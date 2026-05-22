# Changelog

Notable changes to the FDA MAUDE CGM dashboard (`maude_dashboard.py`).
Newest entries first.

---

## 2026-05-22

### Context: Problem Code display improvements (Annex A/E)

Of the 7 FDA eMDR Annex (2025) code categories, only **two are actually present**
in this project's openFDA-sourced `fda_maude_cgm.db`. They are now displayed with
their FDA code numbers.

| Annex | Title | DB column | Notes |
|-------|-------|-----------|-------|
| A | Medical Device Problem | `product_problems` | text only (no code numbers in raw data) |
| E | Health Effects – Clinical Signs/Symptoms/Conditions | `patient_problems` | text only. FDA MAUDE website label = "Health Effect - Clinical Code" |
| B/C/D/F/G | Cause Investigation (Type/Findings/Conclusion), Health Impact, Medical Device Component | — | **not provided by openFDA, absent from the DB** |

> Note: `raw_json.sequence_number_outcome` looks similar to Annex F (Health Impact)
> but is actually the legacy MDR Patient Outcome field (Required Intervention /
> Other / Hospitalization / Death …), mixing abbreviations (H/O/R/L/S/D) with full
> names, and does not map 1:1 to Annex F.

### [Fix] Show codes in the individual report detail + greatly expand code mapping

- **Symptom:** In Full reports → individual report detail, patient/device problems
  showed **text only, no code numbers**.
- **Cause:** The text→code map (`problem_code_map.json`) had only ~30 entries, so
  most terms got no code attached.
- **Change:**
  1. Added `load_annex_code_map()` which reads the `Combined` sheet of
     `fda-annexes-a-g-2025.xlsx` and auto-collects the full term→FDA Code mapping
     for **Annex A (487 terms) + Annex E (756 terms)**. Parsed once via
     `@st.cache_data`.
  2. Reworked `merged_problem_code_map()` merge priority to
     **manual JSON > Annex dictionary > DB auto-inference**.
  3. Fixed Annex terms whose names contain commas (e.g. "Incorrect, Inadequate or
     Imprecise Result or Readings" — 19 such terms) being split incorrectly:
     `_split_problem_terms()` now uses the Annex term list as protected phrases.
  4. Added two lines to the individual report detail panel:
     - `🧑 Health Effect - Clinical Code (Annex E)`
     - `⚙️ Medical Device Problem Code (Annex A)`
- **Result:** mapping coverage improved patient 18→191/198, device 12→106/119.
- **Files:** `maude_dashboard.py`
  - constant: added `ANNEX_XLSX_PATH`
  - functions: `load_annex_code_map()`, `_annex_xlsx_mtime()`, `_ANNEX_DOMAIN_BY_LETTER`
  - modified: `merged_problem_code_map()`, `_split_problem_terms()`
  - UI: "individual report detail" panel

### [Add] Standardize on the "Health Effect - Clinical Code" label

- Unified on the FDA MAUDE **website label** ("Health Effect - Clinical Code").
  (The original MDR/openFDA name is "Patient Problems".)
- Already applied globally via the `PATIENT_PROBLEM_LABEL` constant; verified no
  stale "Patient problem" labels remain in user-facing text.

### [Add] Per-code report drill-down (Full reports tab)

- New `📊 Code-based report explorer` section at the bottom of the Full reports tab.
- Same **left/right split view** as Insights §5(b) ("new problem codes in the last
  30 days"):
  - left: code / term / count table (rows are clickable)
  - right: reports containing the selected code + per-report detail
    (summary, event_description)
- Split into two sub-tabs:
  - `🧑 Health Effect - Clinical Code (Annex E)`
  - `⚙️ Medical Device Problem Code (Annex A)`
- Aggregates over the current sidebar-filtered result set (the top table).
- **File:** `maude_dashboard.py` — `_render_code_drilldown()` inside the Full reports tab.

### Verification

- Syntax check (`ast.parse`)
- Unit tests for Annex mapping / comma-split
- Drill-down data-flow test against 300 real DB rows
- Streamlit headless boot (health OK)
- Tab-2 render path mocking (no-selection / row-selected) — all passed
- Remaining edge case: a few abbreviated terms ("Appropriate Term / Code Not
  Available", "Defective Device") show as `(코드없음)` / "(no code)" — expected,
  only the code is absent.
