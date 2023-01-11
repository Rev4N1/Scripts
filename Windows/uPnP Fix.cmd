@echo off
TITLE "uPnP Fix"
mode con: cols=70 lines=10
cd /d "%~dp0"
CLS

if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)

@echo Set Network Profile To Private
for /F "delims=" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" /f "Category" /s ^| findstr /L "HKEY_LOCAL_MACHINE"') do (
reg add "%%i" /v "Category" /t REG_DWORD /d "1" /f > NUL 2>&1
)

@echo Enable DHCP (Disable Static IP)
for /F %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /f "IPAddress" /s ^| findstr /L "HKEY_LOCAL_MACHINE"') do (
reg delete "%%i" /v "IPAddress" /f > NUL 2>&1
reg delete "%%i" /v "SubnetMask" /f > NUL 2>&1
reg delete "%%i" /v "DefaultGateway" /f > NUL 2>&1
reg add "%%i" /v "EnableDHCP" /t REG_DWORD /d "1" /f > NUL 2>&1
)

@echo Reset Firewall Rules
netsh advfirewall reset > NUL 2>&1

@echo Add Plutonium Firewall Rules
netsh advfirewall firewall delete rule name="plutonium-bootstrapper-win32.exe" > NUL 2>&1
netsh advfirewall firewall add rule name="plutonium-bootstrapper-win32.exe" program="%LocalAppData%\Plutonium\bin\plutonium-bootstrapper-win32.exe" dir=in protocol=TCP edge=deferuser action=allow > NUL 2>&1
netsh advfirewall firewall add rule name="plutonium-bootstrapper-win32.exe" program="%LocalAppData%\Plutonium\bin\plutonium-bootstrapper-win32.exe" dir=in protocol=UDP edge=deferuser action=allow > NUL 2>&1

@echo Enable uPnP Firewall Rules
for /F "tokens=2*" %%a in ('netsh advfirewall firewall show rule name^=all profile^=private ^| findstr /C:"Network Discovery" ^| findstr /L "Rule Name"') do (
netsh advfirewall firewall set rule name="%%b" profile=private new enable=Yes > NUL 2>&1
)

@echo Enable Required Services
SC Config upnphost start=demand > NUL 2>&1
SC Start upnphost > NUL 2>&1
SC Config SSDPSRV start=demand > NUL 2>&1
SC Start SSDPSRV > NUL 2>&1

pause
exit