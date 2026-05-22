@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ==================================================
REM  FDA MAUDE API 진단 - 데이터 지연 구간 파악용
REM  연도별 건수를 출력해서 어느 기간에 데이터가 있는지 확인
REM ==================================================

set "PY="
py --version
if not errorlevel 1 (
    set "PY=py -3"
    goto :pyfound
)
python --version
if not errorlevel 1 (
    set "PY=python"
    goto :pyfound
)
echo [오류] Python 을 찾을 수 없습니다. run_collector.bat 과 동일한 방법으로 설치하세요.
pause
exit /b 1

:pyfound
echo [확인] 사용할 Python: !PY!
echo.
!PY! fda_maude_collector.py --test
echo.
pause
endlocal
