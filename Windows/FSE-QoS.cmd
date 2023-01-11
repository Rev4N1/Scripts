@echo off
TITLE "FSE-QoS Utility"
mode con: cols=70 lines=10
cd /d "%~dp0"
CLS

:: Set Windows Version And Build
for /F "tokens=3" %%a in ('WMIC OS Get Caption /Value') do set "OSVersion=%%a"
for /F "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ReleaseId" /s ^| findstr "ReleaseId"') do set "OSBuild=%%a"

:SETPATH
cls
@echo Select the main game exe you would like to configure
for /F "tokens=* delims=" %%i in ('mshta.exe "about:<input type=file id=FILE><script>FILE.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);close();resizeTo(0,0);</script>"') do set "Application=%%i"
for /F "usebackq delims=" %%a in ('"%Application%"') do set "ProgramName=%%~na"
if not exist "%Application%" goto :SETPATH

cls
CHOICE /N /M "Set DSCP 46 QoS policy to %ProgramName%? [Y/N]"
if %errorlevel% EQU 1 (
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Version" /t REG_SZ /d "1.0" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Application Name" /t REG_SZ /d "%Application%" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Protocol" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Local Port" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Local IP" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Remote Port" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Remote IP" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "DSCP Value" /t REG_SZ /d "46" /f > NUL 2>&1
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\%ProgramName%" /v "Throttle Rate" /t REG_SZ /d "-1" /f > NUL 2>&1
)

if %OSVersion% LSS 10 exit 
if %OSBuild% LSS 1703 exit

cls
CHOICE /N /M "Disable fullscreen optimizations to %ProgramName%? [Y/N]"
if %errorlevel% EQU 1 reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%Application%" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f

exit