@echo off
setlocal
cd /d "%~dp0"

title FDA MAUDE Surveillance Platform

echo =================================================================
echo   FDA MAUDE Medical Device Adverse Events Surveillance Platform
echo   - Backend: FastAPI + Uvicorn
echo   - Frontend: React 19 + TailwindCSS [Production Built]
echo   - URL: http://localhost:8000
echo =================================================================
echo.

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Python virtual environment .venv not found.
    pause
    exit /b 1
)

echo [*] Starting Server at http://localhost:8000 ...
echo [*] Web browser will open automatically once the server is ready.
echo.

".venv\Scripts\python.exe" -m uvicorn server.main:app --host 127.0.0.1 --port 8000 --reload

echo.
echo [INFO] Server has stopped.
pause
