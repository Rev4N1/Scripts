@echo off
TITLE "Scaling Changer"
mode con: cols=70 lines=10
cd /d "%~dp0"
CLS

echo Choose Scaling:
echo.
echo [1] FullScreen Stretch	[2] Maintain Aspect Ratio
echo.
choice /c:12 /n > NUL 2>&1
if errorlevel 2 set Scale=4
if errorlevel 1 set Scale=3

for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration" /f "Scaling" /s /e ^| findstr /LI "HKEY"') do (
	reg add "%%i" /v "Scaling" /t REG_DWORD /d "%Scale%" /f
)

exit