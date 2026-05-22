@echo off
cd /d "%~dp0"

REM ==================================================
REM  FDA MAUDE CGM Dashboard (Streamlit)
REM
REM  브라우저에서 DB를 조회/검색/다운로드할 수 있는 대시보드.
REM  수집기(run_collector.bat)를 먼저 실행해 DB를 만든 뒤 사용.
REM ==================================================

echo.
echo [1/3] Python 런타임 탐색...

set "PY="
py -3 --version 1>NUL 2>NUL
if not errorlevel 1 (
    set "PY=py -3"
    goto pyfound
)
python --version 1>NUL 2>NUL
if not errorlevel 1 (
    set "PY=python"
    goto pyfound
)
python3 --version 1>NUL 2>NUL
if not errorlevel 1 (
    set "PY=python3"
    goto pyfound
)
echo.
echo [오류] Python 을 찾을 수 없습니다. diagnose.bat 실행하여 상태 확인
pause
exit /b 1

:pyfound
echo [확인] 사용할 Python: %PY%
%PY% --version

echo.
echo [2/3] 필수 패키지 확인...
%PY% -c "import streamlit, pandas, openpyxl" 1>NUL 2>NUL
if errorlevel 1 (
    echo 필수 패키지가 없어 자동 설치합니다...
    %PY% -m pip install -r requirements.txt
    if errorlevel 1 (
        echo [오류] 패키지 설치 실패
        pause
        exit /b 1
    )
)

echo.
echo [3/3] 대시보드 실행 (브라우저가 자동으로 열립니다)...
echo    종료하려면 이 창에서 Ctrl+C 를 누르세요.
echo.
%PY% -m streamlit run maude_dashboard.py

if errorlevel 1 (
    echo.
    echo [오류] 대시보드 실행 실패.
    pause
    exit /b 1
)
