@echo off
title "Display Settings"
mode con | findstr "9001 3000 120" > NUL 2>&1 && mode con lines=10 cols=70
cd /d "%~dp0"

:-------------------------------------
cacls "%WinDir%\system32\config\system" > NUL 2>&1
if %errorlevel% NEQ 0 (goto :UACPrompt) else (goto :gotAdmin)
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\GetAdmin.vbs"
set params = %*:"=""
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\GetAdmin.vbs"
"%temp%\GetAdmin.vbs"
del /f /q "%temp%\GetAdmin.vbs"
exit /B
:gotAdmin
pushd "%cd%"
cd /d "%~dp0"
:--------------------------------------

@echo Choose Scaling:
@echo [1] FullScreen Stretch	[2] Maintain Aspect Ratio
@echo.
choice /C 12 /N > NUL 2>&1
if %errorlevel% EQU 2 set Scale=4
if %errorlevel% EQU 1 set Scale=3
for /F "tokens=*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration" /f "Scaling" /s ^| findstr "HKEY"') do (
	reg add "%%a" /v "Scaling" /t REG_DWORD /d "%Scale%" /f > NUL 2>&1
)

@echo Set Resolution
start /w rundll32 display.dll,ShowAdapterSettings 0 > NUL 2>&1

exit