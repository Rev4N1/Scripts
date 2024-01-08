@echo off
title "Spoofer"
mode con | findstr "9001 3000 120" > NUL 2>&1 && mode con lines=10 cols=120
cd /d "%~dp0"

:: GitHub - */xiaomi_*_dump: *-user
:: https://github.com/althafvly/ih8sn/blob/master/system/etc
:: https://specdevice.com/unmoderated.php
set "ZDL=7-zip.org/a/7z2301-x64.exe"
set "PYVer=3.10"
set "PYDL=python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"


:fingerprint
:: Reset variables
set "MANUFACTURER="
set "MODEL="
set "FINGERPRINT="
set "SECURITY_PATCH="

if "%~1" NEQ "" goto :fullrom

:input
if "%FINGERPRINT%" NEQ "" if "%SECURITY_PATCH%" NEQ "" if "%MODEL%" NEQ "" (
	call :json
	goto :fingerprint
)
if "%FINGERPRINT%" NEQ "" if "%INPUT%" EQU "" (
	call :json
	goto :fingerprint
)
:: Ask user for fp
cls
@echo FP: %FINGERPRINT% ^| SP: %SECURITY_PATCH% ^| Model: %MODEL%
@echo.
set "INPUT="
set /P "INPUT=Fingerprint | Security Patch | Model: "
if "%INPUT%" EQU "" goto :input
echo %INPUT% | findstr /RC:"/*/*/*/*/*-keys" > NUL 2>&1
if %errorlevel% EQU 0 (
	set "FINGERPRINT=%INPUT%"
	goto :input
)
echo %INPUT% | findstr /RC:"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]" > NUL 2>&1
if %errorlevel% EQU 0 (
	set "SECURITY_PATCH=%INPUT%"
	goto :input
)
echo %INPUT% | findstr /V "\/ \: \\ =" > NUL 2>&1
if %errorlevel% EQU 0 (
	set "MODEL=%INPUT%"
	goto :input
)
goto :input


:fullrom
:: Install dependecies
"%ProgramFiles%\7-Zip\7z.exe" -version > NUL 2>&1
if %errorlevel% NEQ 7 (
	@echo Downloading 7-Zip
	del /f /q "%temp%\7z-Installer.exe" > NUL 2>&1
	curl -fsSL "%ZDL%" -o "%temp%\7z-Installer.exe" -O > NUL 2>&1

	@echo Installing 7-Zip
	"%temp%\7z-Installer.exe" /S > NUL 2>&1

	@echo Cleaning up 7-Zip Installer
	del /f /q "%temp%\7z-Installer.exe" > NUL 2>&1
)

py -%PYVer% --version > NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
	@echo Downloading Python %PYVer%
	del /f /q "%TEMP%\Python-%PYVer%-Installer.exe" > NUL 2>&1
	curl -fsSL "%PYDL%" -o "%TEMP%\Python-%PYVer%-Installer.exe" -O > NUL 2>&1

	@echo Installing Python %PYVer%
	"%TEMP%\Python-%PYVer%-Installer.exe" /quiet InstallAllUsers=1 PrependPath=1 > NUL 2>&1

	@echo Cleaning up Python Installer
	del /f /q "%TEMP%\Python-%PYVer%-Installer.exe" > NUL 2>&1

	exit
)

:: Generate initial folder
rd /s /q "%temp%\extract" > NUL 2>&1
call :7zip "%~1"
:extract
for /F "tokens=*" %%a in ('dir "%temp%\extract" /b /s ^| findstr /V ".zip\> .tar\> AP.*.tar.md5 payload.bin system.new.dat system.transfer.list \<system.img build.prop"') do (
	del /f /q /s "%%a" > NUL 2>&1
	rd /s /q "%%a" > NUL 2>&1
)
for /F "tokens=*" %%a in ('dir "%temp%\extract" /b /s') do (
	if "%%~xa" EQU ".zip" call :7zip "%%a"
	if "%%~xa" EQU ".tar" call :7zip "%%a"
	if "%%~xa" EQU ".md5" call :7zip "%%a"
	if "%%~xa" EQU ".bin" call :payloaddumper "%%a"
	if "%%~xa" EQU ".br" call :brotli "%%a"
	if "%%~xa" EQU ".dat" call :sdat2img "%%a"
	if "%%~xa" EQU ".list" call :sdat2img "%%a"
	if "%%~xa" EQU ".lz4" call :lz4 "%%a"
	if "%%~xa" EQU ".img" call :imgextractor "%%a"
)

if not exist "%temp%\extract\build.prop" goto :extract

:: Parse build.prop
for /F "tokens=1,* delims==" %%a in ('type "%temp%\extract\build.prop" ^| findstr /RC:"ro\..*\.manufacturer="') do set "MANUFACTURER=%%b"
::for /F "tokens=1,* delims==" %%a in ('type "%temp%\extract\build.prop" ^| findstr /RC:"ro\..*\.model="') do set "MODEL=%%b"
for /F "tokens=1,* delims==" %%a in ('type "%temp%\extract\build.prop" ^| findstr /RC:"ro\..*\.fingerprint=.*/.*/.*/.*/.*/.*-keys"') do set "FINGERPRINT=%%b"
for /F "tokens=1,* delims==" %%a in ('type "%temp%\extract\build.prop" ^| findstr /RC:"ro\..*\.security_patch=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"') do set "SECURITY_PATCH=%%b"
if "%FINGERPRINT%" EQU "" exit

:: Cleanup
rd /s /q "%temp%\extract" > NUL 2>&1

call :json

exit


:7zip
"%ProgramFiles%\7-Zip\7z.exe" e "%~1" -o"%temp%\extract" -y -p
if "%~dp1" EQU "%temp%\extract\" del /f /q "%~1" > NUL 2>&1

exit /b

:brotli
"%cd%\Utils\brotli.exe" -d "%~1"
del /f /q "%~1" > NUL 2>&1

exit /b

:imgextractor
start "" "%cd%\Utils\imgextractor.exe" "%~1"
:query_ie
timeout 3 /NoBreak > NUL 2>&1
if not exist "%temp%\extract\system_\system\build.prop" goto :query_ie
taskkill /IM "imgextractor.exe" /F > NUL 2>&1
move /Y "%temp%\extract\system_\system\build.prop" "%temp%\extract\build.prop" > NUL 2>&1
del /f /q "%~1" > NUL 2>&1

exit /b

:lz4
"%cd%\Utils\lz4.exe" "%~1"
del /f /q "%~1" > NUL 2>&1

exit /b

:payloaddumper
"%cd%\Utils\payloaddumper.exe" "%~1"
for /F "tokens=*" %%a in ('dir /b ^| findstr /RC:"extracted_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]"') do (
	move /Y "%cd%\%%a\system.img" "%~dp1system.img" > NUL 2>&1
	rd /s /q "%%a" > NUL 2>&1
)
del /f /q "%~1" > NUL 2>&1

exit /b

:sdat2img
"%cd%\Utils\sdat2img.py" "%~dp1system.transfer.list" "%~dp1system.new.dat"
move /Y "%cd%\system.img" "%~dp1system.img" > NUL 2>&1
del /f /q "%~dp1system.transfer.list" > NUL 2>&1
del /f /q "%~dp1system.new.dat" > NUL 2>&1

exit /b


:json
:: Json maker
cls
@echo FP: %FINGERPRINT% ^| SP: %SECURITY_PATCH%
@echo.
for /F "tokens=1,2,3 delims=/:" %%a in ('"echo %FINGERPRINT%"') do (
	if "%MANUFACTURER%" EQU "" set "MANUFACTURER=%%a"
	if "%MODEL%" EQU "" set "MODEL=%%c"
	if "%SECURITY_PATCH%" EQU "" set "SECURITY_PATCH=2018-04-05"
)
(
	echo {
	echo.  "MANUFACTURER": "%MANUFACTURER%",
	echo.  "MODEL": "%MODEL%",
	echo.  "FINGERPRINT": "%FINGERPRINT%",
	echo.  "SECURITY_PATCH": "%SECURITY_PATCH%",
	echo }
) > "%cd%\custom.pif.json"

:: Apply config
adb shell rm -r "/sdcard/custom.pif.json" > NUL 2>&1
adb push "%cd%\custom.pif.json" "/sdcard/custom.pif.json" > NUL 2>&1
adb shell "su -c 'rm -r /data/adb/modules/playintegrityfix/custom.pif.json'" > NUL 2>&1
adb shell "su -c 'rm -r /data/adb/modules/playintegrityfix/custom.pif.json.bak'" > NUL 2>&1
adb shell "su -c 'mv /sdcard/custom.pif.json /data/adb/modules/playintegrityfix/custom.pif.json'" > NUL 2>&1
adb shell "su -c 'sh /data/adb/modules/playintegrityfix/migrate.sh'" > NUL 2>&1
adb shell "su -c 'killall com.google.android.gms.unstable'" > NUL 2>&1

:: Check
@echo Check Play Integrity
CHOICE /C YN /N /M "Is fingerprint working? [Y/N]"
if %errorlevel% EQU 1 (
	if not exist "%cd%\Props\%BRAND%" mkdir "%cd%\Props\%BRAND%" > NUL 2>&1
	move /Y "%cd%\custom.pif.json" "%cd%\Props\%BRAND%\%PRODUCT% %MODEL% %SECURITY_PATCH%.json" > NUL 2>&1
)
if %errorlevel% EQU 2 (
	del /f /q "%cd%\custom.pif.json" > NUL 2>&1
)

exit /b