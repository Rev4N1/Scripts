@echo off
title "Toggle Bufferbloat Remover"
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


netsh int tcp show global | findstr "normal"
if %errorlevel% EQU 1 (
	cls
	color 4
	netsh int tcp set global autotuninglevel=normal > NUL 2>&1
	@echo Bufferbloat Reseted.
) else (
	cls
	color A
	netsh int tcp set global autotuninglevel=disabled > NUL 2>&1
	@echo Bufferbloat Removed.
)

timeout 3 /NoBreak > NUL 2>&1

exit