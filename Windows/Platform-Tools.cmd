@echo off
mode con | findstr "9001 3000 120" > NUL 2>&1 && (
	title "Platform Tools Installer"
	mode con lines=10 cols=70
	color F0
	cd /d "%~dp0"
)

REM Request administrator privileges
DISM > NUL 2>&1 || (
	PowerShell Start -Verb RunAs '%0' > NUL 2>&1 || (
		echo Error: Elevated permissions are required to run.
		pause
	)
	exit /b
)


set "PTDL=dl.google.com/android/repository/platform-tools-latest-windows.zip"
set "PTFile=platform-tools.zip"
set "HDDL=github.com/Rev4N1/Heimdall/releases/latest/download/win-build.zip"
set "HDFile=heimdall.zip"
REM https://github.com/pbatard/libwdi/releases
set "ZADL=github.com/pbatard/libwdi/releases/download/v1.5.1/zadig-2.9.exe"
set "ZAFile=zadig.exe"
REM https://developer.android.com/studio/run/win-usb
set "USBDL=dl.google.com/android/repository/usb_driver_r13-windows.zip"
set "USBFile=usb_driver.zip"


@echo Download Platform Tools
del /f /q "%temp%\%PTFile%" > NUL 2>&1
curl -fsSL "%PTDL%" -o "%temp%\%PTFile%" -O > NUL 2>&1
rd /s /q "%temp%\platform-tools" > NUL 2>&1
"%ProgramFiles%\7-Zip\7z.exe" x "%temp%\%PTFile%" -o"%temp%" > NUL 2>&1

@echo Download Heimdall
del /f /q "%temp%\%HDFile%" > NUL 2>&1
curl -fsSL "%HDDL%" -o "%temp%\%HDFile%" -O > NUL 2>&1
"%ProgramFiles%\7-Zip\7z.exe" x "%temp%\%HDFile%" -o"%temp%\platform-tools" > NUL 2>&1
curl -fsSL "%ZADL%" -o "%temp%\platform-tools\%ZAFile%" -O > NUL 2>&1

@echo Install Platform Tools
rd /s /q "%SystemDrive%\adb" > NUL 2>&1
robocopy "%temp%\platform-tools" "%SystemDrive%\adb" /NFL /NDL /NJH /NJS /NC /NS /NP /E /MOVE > NUL 2>&1
for /F "tokens=2,*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f "path" /e ^| findstr "path"') do (
	echo %%b | findstr "%SystemDrive%\adb" > NUL 2>&1 || setx PATH "%%b%SystemDrive%\adb;" /M > NUL 2>&1
)

@echo Download Google USB Driver
del /f /q "%temp%\%USBFile%" > NUL 2>&1
curl -fsSL "%USBDL%" -o "%temp%\%USBFile%" -O > NUL 2>&1
rd /s /q "%temp%\usb_driver" > NUL 2>&1
"%ProgramFiles%\7-Zip\7z.exe" x "%temp%\%USBFile%" -o"%temp%" > NUL 2>&1

@echo Download Google USB Driver
pnputil /add-driver "%temp%\usb_driver\*.inf" /install > NUL 2>&1

@echo Cleanup
for %%a in (
	"%temp%\%PTFile%"
	"%temp%\%HDFile%"
	"%temp%\%USBFile%"
) do del /f /q %%a > NUL 2>&1
rd /s /q "%temp%\usb_driver" > NUL 2>&1

pause
exit