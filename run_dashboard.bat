@echo off
setlocal
chcp 65001 >NUL
cd /d "%~dp0"

echo.
echo [1/3] Ready Python runtime check...

set "PY_EXE="
set "PY_ARGS="

REM Use the local virtual environment only when dashboard packages are ready.
if exist "%~dp0.venv\Scripts\python.exe" (
    "%~dp0.venv\Scripts\python.exe" -c "import streamlit, pandas, openpyxl" 1>NUL 2>NUL
    if not errorlevel 1 (
        set "PY_EXE=%~dp0.venv\Scripts\python.exe"
        goto pyfound
    )
)

REM Otherwise prefer an already prepared system runtime without installing first.
py -3 -c "import streamlit, pandas, openpyxl" 1>NUL 2>NUL
if not errorlevel 1 (
    set "PY_EXE=py"
    set "PY_ARGS=-3"
    goto pyfound
)
python -c "import streamlit, pandas, openpyxl" 1>NUL 2>NUL
if not errorlevel 1 (
    set "PY_EXE=python"
    goto pyfound
)
python3 -c "import streamlit, pandas, openpyxl" 1>NUL 2>NUL
if not errorlevel 1 (
    set "PY_EXE=python3"
    goto pyfound
)

REM No prepared runtime: install once into the local virtual environment.
if not exist "%~dp0.venv\Scripts\python.exe" (
    py -3 -m venv "%~dp0.venv"
    if errorlevel 1 (
        echo [ERROR] Python was not found. Run diagnose.bat and check the environment.
        pause
        exit /b 1
    )
)
set "PY_EXE=%~dp0.venv\Scripts\python.exe"

echo.
echo [2/3] Installing required packages once...
"%PY_EXE%" -m pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Package installation failed.
    pause
    exit /b 1
)

:pyfound
echo [OK] Python: "%PY_EXE%" %PY_ARGS%
"%PY_EXE%" %PY_ARGS% --version

echo.
echo [3/3] Starting dashboard...
echo Press Ctrl+C in this window to stop.
echo.
set "PYTHONUTF8=1"
"%PY_EXE%" %PY_ARGS% -m streamlit run maude_dashboard.py --server.fileWatcherType none --browser.gatherUsageStats false

if errorlevel 1 (
    echo.
    echo [ERROR] Dashboard startup failed.
    pause
    exit /b 1
)
