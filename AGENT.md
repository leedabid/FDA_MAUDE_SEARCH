# AGENT.md

This file defines repository-local working rules for AI coding agents.

## Scope
- Applies to all files under this repository root.
- If a direct user instruction conflicts with this file, user instruction wins.

## Project Intent
- Maintain a single integrated MAUDE workflow for CGM + Insulin Pump.
- Keep collector (`fda_maude_collector.py`) and dashboard (`maude_dashboard.py`) behavior consistent.

## Required Practices
- Preserve checkpoint-based incremental collection behavior.
- Do not silently narrow collection scope from dual-scope (CGM + pump) unless explicitly requested.
- Keep `README.md` and `CHANGELOG.md` in sync with any user-visible behavior/config changes.
- Prefer non-destructive changes; do not delete historical DB content unless explicitly requested.

## Dashboard Rules
- Filters must never fall back to "all data" when user-selected intersections are empty.
- If DB file changes (replace/update/delete), metadata/filter lists must refresh automatically.
- Keep filter apply behavior single-click reliable.

## Brand Group UI Rules
- Support hiding already-selected members in group editor.
- Use normalized comparisons (`strip + upper`) for member matching to avoid case/spacing issues.

## Data Safety

### NEVER commit (hard rule)
The following must never be staged, committed, or pushed. They stay local only and
are listed in `.gitignore`. Before every commit, verify none of these are staged
(`git diff --cached --name-only`).
- **API keys / secrets** — `FDA_MAUDE_API_KEY.txt`, `api_key.txt`, `*.key`, `.env`.
- **Local databases** — `*.db` (incl. `fda_maude_cgm.db`), `*.sqlite*`.
- **Generated outputs** — `fda_maude_cgm.xlsx`, `maude_full_dashboard_*.xlsx`,
  `maude_insight_report_*.xlsx`, `*.log`.
- **Internal handoff doc** — `HANDOFF.md` (contains local paths + machine username).
- **Agent/editor local dirs** — `.claude/`, `.gemini/`, `.vscode/`, `.idea/`, `.venv/`.
- **Backups / old versions** — `*복사본*.py`, `raw_maude_dashboard.py`.
- **Personal analysis files** — `Dexcom_libre_*.xlsx`.

### Never leak personal info
- Do **not** write the author's real personal email, the local Windows username, or
  absolute local paths (e.g. `D:\...`, `C:\Users\...`) into any tracked/published file.
- If such a value is found in a file slated for commit, scrub it or keep the file local.
- The bundled annex spreadsheet must keep its document metadata stripped of any
  machine username (`docProps/core.xml` → empty `lastModifiedBy`).

### Git commit identity (IMPORTANT — recurring pitfall)
- The global git config carries the author's **real personal email**, which must
  never appear in public history.
- Every commit MUST be authored with the GitHub **noreply** email
  `leedabid@users.noreply.github.com`. Do **not** modify global git config; instead
  pass it per-commit:
  `git -c user.name="leedabid" -c user.email="leedabid@users.noreply.github.com" commit ...`
- After committing, verify: `git log -1 --format='%ae'` must show the noreply email.
  If a real email slipped in, amend with `--reset-author` (using the `-c` override)
  and force-push before anyone fetches.
