@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ==================================================
REM  FDA MAUDE CGM Collector
REM
REM  인자 없이 실행하면 자동으로:
REM    - 처음: 최근 2년치 수집 후 체크포인트 저장
REM    - 이후: 이전 체크포인트 - 1일 부터 오늘까지만 수집
REM  CGM_BRANDS 리스트가 바뀌면 자동으로 "최초 모드" 로 전환
REM
REM  옵션:
REM    run_collector.bat           (자동)
REM    run_collector.bat initial   (체크포인트 무시하고 2년 재수집)
REM    run_collector.bat test      (API 연결 진단만)
REM ==================================================

echo.
echo [1/3] Python 실행기 탐색...
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
python3 --version
if not errorlevel 1 (
    set "PY=python3"
    goto :pyfound
)
echo.
echo [오류] Python 을 찾을 수 없습니다. diagnose.bat 실행으로 원인 확인
pause
exit /b 1

:pyfound
echo [확인] 사용할 Python: !PY!
!PY! --version

echo.
echo [2/3] 필수 패키지 확인...
!PY! -c "import requests, pandas, openpyxl"
if errorlevel 1 (
    echo 필수 패키지가 없어 자동 설치합니다...
    !PY! -m pip install -r requirements.txt
    if errorlevel 1 (
        echo [오류] 패키지 설치 실패
        pause
        exit /b 1
    )
)

echo.
echo [3/3] 수집 시작...
if /i "%~1"=="test" (
    !PY! fda_maude_collector.py --test
) else if /i "%~1"=="initial" (
    echo [강제 초기화] 체크포인트 무시하고 최근 2년치 재수집합니다...
    !PY! fda_maude_collector.py --initial
) else (
    echo [자동 모드] 체크포인트 확인 후 필요한 범위만 수집합니다...
    !PY! fda_maude_collector.py
)

if errorlevel 1 (
    echo.
    echo [오류] 실행 실패. fda_maude_collector.log 를 확인하세요.
    pause
    exit /b 1
)

echo.
echo [완료] fda_maude_cgm.xlsx 파일을 확인하세요.
pause
endlocal
