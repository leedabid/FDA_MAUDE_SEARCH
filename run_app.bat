@echo off
setlocal enabledelayedexpansion

title FDA MAUDE High-Speed Dashboard
echo =================================================================
echo   FDA MAUDE Medical Device Adverse Events Dashboard (FastAPI+React)
echo   - Backend: FastAPI + Uvicorn
echo   - Engine: DuckDB / SQLite (FTS5 Indexed)
echo   - URL: http://localhost:8000
echo =================================================================
echo.

cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Virtual environment .venv not found.
    pause
    exit /b 1
)

echo [*] Starting server on http://localhost:8000 ...
echo [*] Browser will open automatically once the server is ready.
echo.

.\.venv\Scripts\python.exe -m uvicorn server.main:app --host 127.0.0.1 --port 8000

endlocal
