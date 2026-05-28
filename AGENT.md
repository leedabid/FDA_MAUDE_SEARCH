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
- Never commit API keys, local DB files, logs, or generated report artifacts.
- Respect `.gitignore` and keep sensitive/local artifacts untracked.
