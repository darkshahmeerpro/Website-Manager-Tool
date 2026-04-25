@echo off
mode con: cols=50 lines=15

:: --- AUTOMATIC ADMIN ELEVATION ---
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' ( goto UACPrompt ) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: --- DOWNLOAD/UPDATE PYTHON SCRIPT ---
echo Checking for updates...
set "RAW_URL=https://githubusercontent.com"
curl -s -L -o web_manager.py %RAW_URL%

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
