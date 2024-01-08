@echo off
title "uPnP Fix"
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

@echo Set Network Profile To Private
for /F "tokens=*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" /f "Category" /s ^| findstr "HKEY"') do reg add "%%a" /v "Category" /t REG_DWORD /d "1" /f > NUL 2>&1

@echo Enable DHCP (Disable Static IP)
for /F "tokens=*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /f "IPAddress" /s ^| findstr "HKEY"') do (
	reg delete "%%a" /v "IPAddress" /f > NUL 2>&1
	reg delete "%%a" /v "SubnetMask" /f > NUL 2>&1
	reg delete "%%a" /v "DefaultGateway" /f > NUL 2>&1
	reg add "%%a" /v "EnableDHCP" /t REG_DWORD /d "1" /f > NUL 2>&1
)

@echo Reset Firewall Rules
netsh advfirewall reset > NUL 2>&1

@echo Add Plutonium Firewall Rules
netsh advfirewall firewall delete rule name="plutonium-bootstrapper-win32.exe" > NUL 2>&1
netsh advfirewall firewall add rule name="plutonium-bootstrapper-win32.exe" program="%LocalAppData%\Plutonium\bin\plutonium-bootstrapper-win32.exe" dir=in protocol=TCP edge=deferuser action=allow > NUL 2>&1
netsh advfirewall firewall add rule name="plutonium-bootstrapper-win32.exe" program="%LocalAppData%\Plutonium\bin\plutonium-bootstrapper-win32.exe" dir=in protocol=UDP edge=deferuser action=allow > NUL 2>&1

@echo Enable uPnP Firewall Rules
for /F "tokens=2*" %%a in ('netsh advfirewall firewall show rule name^=all profile^=private ^| findstr /C:"Network Discovery" ^| findstr "Rule Name"') do (
	netsh advfirewall firewall set rule name="%%b" profile=private new enable=Yes > NUL 2>&1
)

@echo Enable Required Services
for %%a in (
	upnphost
	SSDPSRV
) do (
	sc config %%a start=demand > NUL 2>&1
	sc start %%a > NUL 2>&1
)

pause
exit