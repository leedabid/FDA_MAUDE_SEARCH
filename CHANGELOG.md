# Changelog

Notable changes to the FDA MAUDE CGM dashboard (`maude_dashboard.py`).
Newest entries first.

---

## 2026-05-28

### [Fix] "Hide already-grouped brands" toggle — corrected meaning + reliability (resolves earlier Known Issue)

- **What the user actually wanted:** `그룹에 이미 포함된 브랜드는 제외하기` should hide
  brands that are **already assigned to a saved group**, so that when building a
  **new** group the list shows only *unassigned* brands. The previous build hid only
  brands *checked in the current session*, so in `새 그룹 만들기` mode (nothing checked)
  the toggle did nothing — all grouped brands kept showing.
- **New behavior:**
  - Hides every brand that is a member of any **saved** group in `brand_groups.json`,
    **except** the group currently being edited (its own members stay visible so you
    can edit them). Brands you check in the current session also stay visible.
  - New-group mode: enabling the toggle hides all grouped brands; only unassigned
    brands remain to pick from.
- **Reliability root cause (also fixed):** visibility used the per-checkbox *widget*
  state (`brand_group_member_cb::<brand>`), which Streamlit garbage-collects for
  non-rendered widgets → hidden members reappeared on later reruns. The selection's
  single source of truth is now the plain session key `brand_group_members`; the
  hide set is computed from saved groups. All comparisons use `_norm_member`
  (strip + collapse-space + upper). Each checkbox's state is synced from the source
  of truth immediately before instantiation.
- **Also fixed:** loading an existing group matches saved members against actual DB
  brand names with the same normalized comparison (handles spacing/case drift).
- **Verified** with Streamlit `AppTest` (headless): (A) new-group mode — visible
  members dropped 200→52 with 0 grouped brands leaking; (B) editing `Omnipod5` —
  its 12 own members stayed visible while every other group's members were hidden.
  No exceptions.

### [Known Issue] Brand-group hide-selected toggle not working reliably *(superseded by the Fix above)*

- User reported that `그룹에 이미 포함된 브랜드는 제외하기` did not hide
  already-included brands in some flows (especially `새 그룹 만들기` mode).
- Resolved 2026-05-28 — see the `[Fix]` entry above.

### [Dashboard] Brand group member-list visibility toggle

- Added sidebar option `그룹에 이미 포함된 브랜드는 제외하기` in the brand group editor.
- When enabled, already-selected members are hidden from the checkbox list;
  when disabled, they are shown again.
- Fixed member comparison to use normalized values (`strip + upper`) so hiding
  works even when spacing/case differs.

### [Change] Collection target policy switched to manufacturer + brand

- Updated collector search scope to:
  - `device.manufacturer_d_name`: `TANDEM`, `TANDEM DIABETES CARE`, `INSULET`
  - `device.brand_name`: `MINIMED 780G`
- Main search now uses `(manufacturer OR brand)` as the primary clause.
- Updated fallback manufacturer list accordingly.

### [Change] Device category mapping for pump-focused scope

- Updated `BRAND_CATEGORY_MAP` to classify pump-related terms including
  `MINIMED 780G`, `INSULET`, `TANDEM`, `T:SLIM`, `OMNIPOD` as `Insulin Pump`.

### [Docs] README policy sync

- Rewrote configuration and query examples to document the new
  `SEARCH_MANUFACTURERS` + `SEARCH_BRANDS` model.

### [Update] Dual-scope collection (CGM + Insulin Pump) enabled

- Expanded default manufacturer/brand lists to collect CGM and insulin pump
  together on every incremental run.
- Restored CGM category mapping (`DEXCOM`, `FREESTYLE LIBRE`) while keeping pump
  mappings (`OMNIPOD`, `T:SLIM`, `TANDEM`, `INSULET`, `MINIMED 780G`).

## 2026-05-27

### [Add] Insulin pump collection scope (Insulet Omnipod, Tandem t:slim X2 / MOBI / Control-IQ+)

- Expanded `CGM_BRANDS` with `OMNIPOD`, `TANDEM`, `T:SLIM`.
- Skipped standalone `MOBI` because it mostly matched ZimVie MOBI-C implant reports;
  Tandem MOBI reports are captured via the `TANDEM` search.
- Added `BRAND_CATEGORY_MAP` + `_resolve_device_category(brand_name)`.

### [Schema] `device_category` column on `maude_reports`

- Auto-migrated via `_migrate_schema()` for existing DBs.
- Added index `idx_device_category`.
- Excel export now includes `DEVICE_CATEGORY`.

### [Dashboard] Device Category filter

- Added `query_brands_by_category()` cache query.
- Added sidebar `🩺 Device Category` multiselect (intersects with brand filter).
- Added `DEVICE_CATEGORY` to report table and individual report detail panel.

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
