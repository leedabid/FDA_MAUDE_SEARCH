@echo off
setlocal
cd /d "%~dp0"

echo ================================================
echo   Python 진단 스크립트
echo ================================================
echo.

echo [1] PATH 에서 python.exe 위치:
where python
echo.

echo [2] PATH 에서 py (Python 런처) 위치:
where py
echo.

echo [3] PATH 에서 python3 위치:
where python3
echo.

echo [4] python --version 실행 결과:
python --version
echo    (errorlevel = %errorlevel%)
echo.

echo [5] py --version 실행 결과:
py --version
echo    (errorlevel = %errorlevel%)
echo.

echo [6] py -0 (설치된 모든 파이썬 목록):
py -0
echo.

echo [7] 현재 PATH 환경변수:
echo %PATH%
echo.

echo ================================================
echo   이 화면을 캡처해서 공유해 주시면 원인을 바로 알 수 있습니다.
echo ================================================
pause
endlocal
