# FDA MAUDE Diabetes Device Adverse Event Collector & Dashboard

Collect **adverse event reports (MDRs)** for diabetes devices using
manufacturer + brand targeting (CGM + insulin pump collected together) —
from the **FDA openFDA API (MAUDE)**,
store them in a local **SQLite database**, and explore them through an interactive
**Streamlit dashboard**.

> The collector pulls reports daily (incremental, checkpoint-based), and the
> dashboard provides filtering, search, problem-code analytics, severity
> drill-downs, early-warning signals, and Excel report export.

---

## Table of Contents

1. [Features](#1-features)
2. [How it works](#2-how-it-works)
3. [Requirements](#3-requirements)
4. [Quick start](#4-quick-start)
5. [**Getting an openFDA API key**](#5-getting-an-openfda-api-key-important) ← important
6. [Configuration](#6-configuration)
7. [Running the collector](#7-running-the-collector)
8. [Running the dashboard](#8-running-the-dashboard)
9. [Data fields](#9-data-fields)
10. [Problem codes (FDA Annex A–G)](#10-problem-codes-fda-annex-ag)
11. [Repository layout](#11-repository-layout)
12. [Notes & caveats](#12-notes--caveats)
13. [License](#13-license)

---

## 1. Features

- **Incremental daily collection** from openFDA with checkpoint logic — first run
  backfills ~2 years, later runs only fetch new reports.
- **Cursor pagination** that works around the openFDA `skip` ≤ 25,000 limit, so
  large date ranges collect reliably without manual month-splitting.
- **Smart filtering** — by default collects only patient-harm reports
  (`Death` / `Injury` / `Other` with `adverse_event_flag = Y`), skipping the huge
  volume of routine `Malfunction` reports.
- **SQLite storage** with `report_number` as primary key (automatic de-duplication).
- Legacy `device_category IS NULL` CGM rows are backfilled to `CGM` during DB initialization so category statistics do not undercount Dexcom / Libre history.
- **Streamlit dashboard** with:
  - sidebar filters (brand, event type, date range, keyword, code search) that apply on a single submit click,
  - brand-group management with an optional "hide already included brands" toggle,
  - an **Insights** tab (severity drill-down, escalation risk, manufacturer
    blind-spots, regulatory leading indicators, spike/new-code detection),
  - a **Full reports** tab with per-report detail and **per-code drill-down**,
  - problem-code analytics with **FDA Annex code numbers** attached to each term,
  - one-click Excel export (insight report or full dashboard dump with native charts).

> **Current status (2026-07-03):** the collector + dashboard pipeline is already usable end-to-end for the current CGM-focused workflow. The Python code handles checkpoint-based incremental collection, SQLite storage, Korean summaries, and dashboard exploration. For a true "every morning at 9" run, keep using an external scheduler (for example Windows Task Scheduler) to launch `run_collector.bat`; the repo intentionally keeps scheduling outside the Python collector.

---

## 2. How it works

```
┌─────────────────────┐      openFDA Device Event API (MAUDE)
│ fda_maude_collector  │ ───────────────────────────────────────┐
│  (Python script)     │                                         ▼
│  • checkpoint logic   │      https://api.fda.gov/device/event.json
│  • cursor pagination  │
└──────────┬───────────┘
           │ writes
           ▼
   fda_maude_cgm.db  (SQLite, NOT committed — generated locally)
           │ read-only (mode=ro)
           ▼
┌─────────────────────┐
│  maude_dashboard     │  Streamlit UI  →  http://localhost:8501
│  (Streamlit app)     │
└─────────────────────┘
```

The database and Excel outputs are **generated locally** and are intentionally
**not** part of this repository (see [.gitignore](.gitignore)). You build them by
running the collector.

---

## 3. Requirements

- **Python 3.9+** (developed/tested on Windows 11 with the `py` launcher)
- Packages in [requirements.txt](requirements.txt):
  - `requests`, `pandas`, `openpyxl`, `streamlit>=1.35`, `altair>=5.0`

Install:

```bash
pip install -r requirements.txt
```

> `streamlit >= 1.35` is required because the dashboard uses
> `st.dataframe(on_select=...)` for interactive row selection.

---

## 4. Quick start

```bash
# 1) Clone
git clone https://github.com/leedabid/FDA_MAUDE_SEARCH.git
cd FDA_MAUDE_SEARCH

# 2) Install dependencies
pip install -r requirements.txt

# 3) Set up your openFDA API key  (see section 5 — strongly recommended)
#    Copy the sample and paste your key into it:
#      cp api_key.txt.sample FDA_MAUDE_API_KEY.txt    # then edit the file
#    (Windows)  copy api_key.txt.sample FDA_MAUDE_API_KEY.txt

# 4) Collect data (first run backfills ~2 years)
python fda_maude_collector.py --initial

# 5) Launch the dashboard
python -m streamlit run maude_dashboard.py
```

On **Windows**, you can simply double-click the batch files instead:
`run_collector.bat`, then `run_dashboard.bat`.

---

## 5. Getting an openFDA API key (IMPORTANT)

> **The API key in the original author's local folder is private and is NOT
> included in this repository.** You must obtain your own free key.

openFDA is a **free public API operated by the U.S. FDA**. No payment, no credit
card. A key takes ~5 minutes and dramatically raises your rate limit.

### 5.1 Why you want a key

| | Without key | With key |
|---|---|---|
| Requests / minute | 40 | 240 |
| Requests / day | 1,000 | 120,000 |

The first run backfills ~2 years of data, which is **practically impossible**
within the 1,000/day no-key limit. **Get a key.**

### 5.2 How to get one

1. Go to **https://open.fda.gov/apis/authentication/**
2. Click **"Get your API key"** and enter your email address.
3. openFDA emails you a key instantly (a long alphanumeric string).

### 5.3 How to provide the key to the tool

The collector looks for the key in this order (first match wins):

1. **Command-line flag**

   ```bash
   python fda_maude_collector.py --api-key YOUR_API_KEY
   ```

2. **Environment variable** `OPENFDA_API_KEY`

   ```bash
   # macOS / Linux
   export OPENFDA_API_KEY=YOUR_API_KEY

   # Windows (PowerShell)
   $env:OPENFDA_API_KEY = "YOUR_API_KEY"
   ```

3. **Key file** in the project folder (recommended for daily use) — checked in
   this order:
   - `FDA_MAUDE_API_KEY.txt`  ← preferred name
   - `api_key.txt`            ← alternative name

   Create it from the provided template:

   ```bash
   cp api_key.txt.sample FDA_MAUDE_API_KEY.txt
   ```

   Then open `FDA_MAUDE_API_KEY.txt`, delete the comment lines, and leave **only
   your key on a single line**.

> **Security:** `FDA_MAUDE_API_KEY.txt` and `api_key.txt` are already listed in
> [.gitignore](.gitignore), so they will never be committed. **Never paste your
> key into any tracked file.** If you ever expose a key, revoke/rotate it at the
> openFDA site.

---

## 6. Configuration

All user-tunable settings live at the top of
[fda_maude_collector.py](fda_maude_collector.py) in the section marked
`★ 사용자 설정 영역 ★` ("user settings area"):

| Setting | Default | Meaning |
|---|---|---|
| `SEARCH_MANUFACTURERS` | `["DEXCOM", "ABBOTT", "ABBOTT DIABETES CARE", "TANDEM", "TANDEM DIABETES CARE", "INSULET"]` | Search terms matched against `device.manufacturer_d_name`. |
| `SEARCH_BRANDS` | `["FREESTYLE LIBRE", "DEXCOM", "OMNIPOD", "T:SLIM", "MINIMED 780G"]` | Search terms matched against `device.brand_name`. |
| `CGM_BRANDS` | `SEARCH_MANUFACTURERS + SEARCH_BRANDS` | Compatibility key used for checkpoint versioning. |
| `BRAND_CATEGORY_MAP` | built-in list | Maps brand_name patterns to `device_category` (e.g., `CGM`, `Insulin Pump`). |
| `EVENT_TYPES` | `["Death", "Injury", "Other"]` | Which MAUDE event types to collect. Add `"Malfunction"` to include routine device-malfunction reports (volume explodes). |
| `ONLY_ADVERSE_EVENTS` | `True` | If `True`, only reports with `adverse_event_flag = Y` (actual patient harm). |
| `USE_FALLBACK_FIELDS` | `True` | If a brand search returns 0 hits, also try `generic_name` / `manufacturer_d_name`. |
| DB migration | automatic | Adds composite indexes on `date_received`, `event_type`, `device_category + date_received`, `brand_name + date_received`, and `manufacturer_name + date_received` for faster filtering. |

Brand grouping/aliasing for the dashboard is configured in
[brand_groups.json](brand_groups.json). Manual term→code overrides live in
[problem_code_map.json](problem_code_map.json).
In the sidebar brand-group editor, you can toggle
`그룹에 이미 포함된 브랜드는 제외하기` to hide or show already-selected members.

### 6.1 Customizing WHAT you collect

By default this project searches diabetes-device reports using
**manufacturer OR brand** targeting for both **CGM + insulin pump** scope. You can
retarget it to any company, device category, or the whole MAUDE database by editing
the settings above. The search query the collector builds is roughly:

```
(
  device.manufacturer_d_name:(...SEARCH_MANUFACTURERS...)
  OR
  device.brand_name:(...SEARCH_BRANDS...)
)
AND date_received:[start TO end]
        AND event_type:(...EVENT_TYPES...) AND adverse_event_flag:Y
```

(see `build_search_query()` / `_filter_clauses()` in
[fda_maude_collector.py](fda_maude_collector.py)).

> **Important — re-collection after a change:**
> - Changing **`CGM_BRANDS`** changes the checkpoint key, so the next normal run
>   automatically switches to "first run" mode and re-backfills. Just run
>   `python fda_maude_collector.py`.
> - Changing **`EVENT_TYPES`** / **`ONLY_ADVERSE_EVENTS`** does **not** change the
>   checkpoint, so existing history won't be re-fetched. Force it with
>   `python fda_maude_collector.py --initial`.
> - Consider using a fresh DB file when you change scope significantly:
>   `python fda_maude_collector.py --initial --db my_search.db --excel my_search.xlsx`.

**Recipe A — a different company / product** (substring match on manufacturer/brand,
case-insensitive):

```python
SEARCH_MANUFACTURERS = ["MEDTRONIC"]                 # e.g. manufacturer scope
SEARCH_BRANDS = ["MINIMED 780G", "MINIMED 770G"]     # specific products
```

If a brand searches poorly (manufacturer ≠ brand string), also rely on the
manufacturer fallback:

```python
USE_FALLBACK_FIELDS  = True
FALLBACK_MANUFACTURERS = ["MEDTRONIC", "INSULET"]   # device.manufacturer_d_name
```

**Recipe B — a whole device category, any brand** (e.g. all CGMs regardless of
manufacturer): use generic names instead of brand names. The simplest approach is
to set broad brand terms, or edit `build_search_query()` to search
`device.generic_name`:

```python
# Replace the brand clause in build_search_query():
def build_search_query(start, end):
    primary = _build_or_clause("device.generic_name",
                               ["CONTINUOUS GLUCOSE", "GLUCOSE SENSOR"])
    return _compose_query(primary, start, end)
```

You can also target an FDA **product code** (the most precise way to capture a
device category — e.g. `QBJ`, `PZE`, `QLG` for integrated CGMs):

```python
def build_search_query(start, end):
    primary = _build_or_clause("device.device_report_product_code",
                               ["QBJ", "PZE", "QLG"])
    return _compose_query(primary, start, end)
```

**Recipe C — the entire MAUDE database (ALL devices)** — drop the brand filter
entirely. ⚠️ This is **millions of reports per year**; expect very long runs and a
large DB. Narrow the date range and/or `EVENT_TYPES` first.

```python
def build_search_query(start, end):
    # No brand clause — only date + event filters
    parts = [_date_clause(start, end)] + _filter_clauses()
    return " AND ".join(parts).replace(" ", "+")
```

**Recipe D — filter by event type / severity only:**

```python
EVENT_TYPES = ["Death"]                       # deaths only
EVENT_TYPES = ["Death", "Injury", "Other", "Malfunction"]   # everything
ONLY_ADVERSE_EVENTS = False                   # ignore the adverse_event_flag
```

**Useful openFDA fields** you can search on (for the recipes above):
`device.brand_name`, `device.generic_name`, `device.manufacturer_d_name`,
`device.device_report_product_code`, `event_type`, `adverse_event_flag`,
`date_received`. Full field reference:
<https://open.fda.gov/apis/device/event/searchable-fields/>.

> Tip: before a big collection, run `python fda_maude_collector.py --test` to see
> per-year counts for your new target and pick a sensible `--start`/`--end`.

---

## 7. Running the collector

```bash
python fda_maude_collector.py                 # auto / incremental (checkpoint-based)
python fda_maude_collector.py --initial       # force re-backfill (~2 years)
python fda_maude_collector.py --start 20240101 --end 20241231   # explicit range
python fda_maude_collector.py --initial-years 3   # change backfill window
python fda_maude_collector.py --test          # API diagnostics (yearly counts)
python fda_maude_collector.py --verbose       # log full request URLs
```

**Windows batch shortcuts:**

```
run_collector.bat            auto mode (checkpoint-based — recommended)
run_collector.bat initial    force ~2-year re-backfill
run_collector.bat test       API diagnostics only
test_api.bat                 same as `--test`
diagnose.bat                 print Python/PATH info (for troubleshooting)
```

### 7.1 Daily 9:00 automation

The collector is already safe to run once per day because it uses a checkpoint and a
1-day overlap. To automate the morning run, register `run_collector.bat` in your OS
scheduler and trigger it daily at `09:00`.

Suggested setup:

1. Trigger: daily at 09:00
2. Action: run `run_collector.bat` from the repository root
3. Output: keep the generated SQLite DB and Excel file local only

If you later want the schedule managed inside Python, that can be added as a
separate layer, but it is not required for the current workflow.

### Checkpoint logic

```
Run run_collector.bat → script checks the DB checkpoint
  ├─ no checkpoint (first run)        → backfill the last ~2 years
  ├─ checkpoint exists (normal run)   → from (last end date − 1 day) to today
  └─ SEARCH_MANUFACTURERS / SEARCH_BRANDS changed
                                      → switch to a new checkpoint, re-backfill
```

The 1-day overlap guards against partial same-day FDA updates; duplicate
`report_number`s are dropped by the SQLite primary key. A run that ends with 0
inserted reports invalidates its checkpoint so the next run retries the range.

---

## 8. Running the dashboard

```bash
python -m streamlit run maude_dashboard.py
# or
streamlit run maude_dashboard.py
# or (Windows) double-click run_dashboard.bat
```

Opens at `http://localhost:8501`. The dashboard opens the DB **read-only**
(`mode=ro`), so you can keep the collector running and the dashboard open at the
same time — press **F5** in the browser to pick up new data.

**Tabs:**

1. **Insights** — severity drill-down (Death/Injury), escalation risk by model,
   manufacturer blind-spots (source-type gap), regulatory leading indicators,
   spike detection & newly-appearing problem codes, and Excel report export.
2. **Full reports** — filtered table + Excel download, per-report detail
   (with Annex problem codes), and a **per-code drill-down** split view.
3. **Event type distribution** — counts + brand × type crosstab.
4. **Problem codes** — Health Effect (Clinical) and Medical Device Problem Top-N
   with FDA Annex code numbers, plus brand crosstab.
5. **Patient demographics** — sex / race / ethnicity / age.
6. **Manufacturer & country** — top manufacturers, countries, product codes.
7. **Monthly trend** — line/bar charts by event type.

---

## 9. Data fields

Key columns stored per report (see [fda_maude_collector.py](fda_maude_collector.py)):

| Column | Meaning |
|---|---|
| `report_number` | Unique MDR number (primary key) |
| `event_type` | Death / Injury / Malfunction / Other |
| `date_received` / `date_of_event` | FDA receipt date / actual event date |
| `brand_name` / `generic_name` | Product / generic name |
| `device_category` | Derived category label (e.g., `CGM`, `Insulin Pump`) |
| `manufacturer_name` / `manufacturer_country` | Manufacturer and country |
| `model_number` / `product_code` | Model and FDA product code |
| `source_type` | Reporter (Manufacturer / Consumer / HCP) |
| `patient_*` | Age / sex / race / ethnicity / weight |
| `patient_problems` | Clinical signs/symptoms (FDA Annex E — "Health Effect - Clinical Code") |
| `product_problems` | Device problems (FDA Annex A — "Medical Device Problem Code") |
| `event_description` / `manufacturer_narrative` | Original English narratives |
| `summary_*_kr` | Short Korean keyword summaries (complaint / response / conclusion) |

---

## 10. Problem codes (FDA Annex A–G)

The 2025 FDA eMDR taxonomy has 7 annexes (A–G). **openFDA only exposes two of
them, and only as text labels (not code numbers):**

- `product_problems` → **Annex A** (Medical Device Problem)
- `patient_problems` → **Annex E** (Health Effects – Clinical Signs/Symptoms/Conditions);
  the FDA MAUDE website labels this **"Health Effect - Clinical Code"**.

Annexes **B, C, D, F, G** (Cause Investigation type/findings/conclusion, Health
Impact, Medical Device Component) are **not present** in the openFDA data.

To show the missing **code numbers**, the dashboard maps each text term back to
its FDA Code using [fda-annexes-a-g-2025.xlsx](fda-annexes-a-g-2025.xlsx)
(the official annex spreadsheet, `Combined` sheet). This file **is** included so
the code lookup works out of the box. See [CHANGELOG.md](CHANGELOG.md) for details.

---

## 11. Repository layout

```
fda_maude_collector.py     Main collector (openFDA → SQLite + Excel)
maude_dashboard.py         Streamlit dashboard
requirements.txt           Python dependencies
brand_groups.json          Brand grouping/aliasing for the dashboard
problem_code_map.json      Manual term→code overrides
fda-annexes-a-g-2025.xlsx  FDA Annex code reference (used for code mapping)
api_key.txt.sample         Template for your API key file
run_collector.bat          Windows: run the collector
run_dashboard.bat          Windows: run the dashboard
test_api.bat / diagnose.bat  Windows helpers
README.md / CHANGELOG.md   Docs
LICENSE                    MIT license
.gitignore                 Excludes secrets, DB, generated outputs, etc.
```

**Not in the repo** (generated locally / private): `fda_maude_cgm.db`,
`fda_maude_cgm.xlsx`, `*.log`, exported report `*.xlsx`, and your API key file.

---

## 12. Notes & caveats

- openFDA MAUDE data lags **~1–6 months** behind real time. The most recent
  months will look sparse — that is FDA ingestion delay, not a bug.
- The same event is often reported multiple times (by manufacturer, user, and
  clinician) — that is normal.
- This tool is a **monitoring aid, not a medical or regulatory decision tool.**
- If you collect 0 reports, run `python fda_maude_collector.py --test` to check
  per-year counts and confirm your API key and date range.

---

## 13. License

Released under the [MIT License](LICENSE).

Data retrieved from openFDA is U.S. Government public data; review the openFDA
[terms of service](https://open.fda.gov/terms/) for usage conditions.
