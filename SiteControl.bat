@echo off
:: --- AUTO ADMIN WITH FOCUS ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting admin rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -WindowStyle Normal"
    exit /B
)
:: ----------------------------
mode con: cols=50 lines=15
title Website Manager
:menu
cls
echo ==================================================
echo             UNIVERSAL WEBSITE MANAGER
echo ==================================================
echo  CURRENTLY BLOCKED:
if exist blocked_sites.txt (
    for /f "tokens=*" %%a in (blocked_sites.txt) do echo    - %%a
) else (
    echo    (None)
)
echo --------------------------------------------------
echo  1. BLOCK a new website
echo  2. UNBLOCK a website
echo  3. EXIT
echo ==================================================
set /p choice="Select an option (1-3): "

if "%choice%"=="3" exit
set /p target="Enter website: "

python web_manager.py "%target%" %choice%
ipconfig /flushdns >nul
pause
goto menu
