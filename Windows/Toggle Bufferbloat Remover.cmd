@echo off
TITLE "Toggle Bufferbloat Remover"
mode con: cols=70 lines=10
COLOR F0
cd /d "%~dp0"
CLS

@echo Automatically Get Admin Rights
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------


netsh int tcp show global | findstr "normal"
if errorlevel 1 (
	cls
	color 4
	netsh int tcp set global autotuninglevel=normal > NUL 2>&1
	echo Bufferbloat Reseted.
) else (
	cls
	color A
	netsh int tcp set global autotuninglevel=disabled > NUL 2>&1
	echo Bufferbloat Removed.
)

timeout /t 3 > NUL 2>&1
exit

exit