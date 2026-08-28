@echo off
setlocal enabledelayedexpansion

title FDA MAUDE High-Speed Surveillance Platform
echo =================================================================
echo   FDA MAUDE Medical Device Adverse Events Surveillance Platform
echo   - Backend: FastAPI + Uvicorn
echo   - Frontend: React 19 + TailwindCSS (Production Built)
echo   - Engine: SQLite / DuckDB (FTS5 Indexed)
echo   - URL: http://localhost:8000
echo =================================================================
echo.

cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Virtual environment .venv not found in %~dp0.
    echo Please ensure Python environment is properly set up.
    pause
    exit /b 1
)

:: Check and terminate existing orphan process on port 8000 if present
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8000" ^| findstr "LISTENING"') do (
    echo [*] Freeing port 8000 (Terminating existing process PID %%a)...
    taskkill /F /PID %%a >nul 2>&1
)

echo [*] Launching FDA MAUDE Server on http://localhost:8000 ...
echo [*] Opening default web browser in 2 seconds...
echo.

:: Launch browser in background after short delay
start "" cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:8000"

:: Start Uvicorn Server
.\.venv\Scripts\python.exe -m uvicorn server.main:app --host 127.0.0.1 --port 8000

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Server terminated with error code %ERRORLEVEL%.
    pause
)

endlocal
