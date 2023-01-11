@echo off
TITLE "Flash Utility"
mode con: cols=70 lines=10
cd /d "%~dp0"
CLS

set "Global=%cd%\Global"
set "P2=%cd%\Pixel 2"
set "P6=%cd%\Pixel 6"
set "P7=%cd%\Pixel 7"
set "RN8=%cd%\Redmi Note 8"
set "TS6L=%cd%\Tab S6 Lite"

adb start-server > NUL 2>&1

call :DEVICE

goto %Device%

@echo Connect a Supported Device
TIMEOUT 5 /NoBreak > NUL 2>&1

exit

:oriole
set "DType=AB"

call :FLASH "FB" "Firmware" "%P6%\!Utils\Firmware"

call :FLASH "FB" "Recovery" "%P6%\1 Recovery"

call :FLASH "ADB" "ROM" "%P6%\2 HentaiOS-13.zip"

set command1=fastboot flash boot "%P6%\3 Magisk.img"
call :FLASH "FB" "Magisk"

goto :reboot

:gta4xlwifi
set "DType=A"

set command1=heimdall flash --CM "%TS6L%\!Utils\Firmware\cm.bin" --KEYSTORAGE "%TS6L%\!Utils\Firmware\keystorage.bin" --BOOTLOADER "%TS6L%\!Utils\Firmware\sboot.bin" --UH "%TS6L%\!Utils\Firmware\uh.bin" --UP_PARAM "%TS6L%\!Utils\up_param.bin" --RECOVERY "%TS6L%\1 Recovery.img"
call :FLASH "DL" "Firmware, Clean BootSplash and Recovery"

call :FLASH "ADB" "ROM" "%TS6L%\2 Lineage-20.zip"

call :FLASH "ADB" "GApps" "%Global%\GApps-13.zip"

call :generic

goto :reboot

:walleye
set "DType=AB"

call :FLASH "FB" "Firmware" "%P2%\!Utils\Firmware"

set command1=fastboot flash --slot all boot "%P2%\1 Recovery.img"
call :FLASH "FB" "Recovery"

call :FLASH "ADB" "ROM" "%P2%\2 Lineage-20.zip"

call :generic

goto :reboot

:panther
set "DType=AB"

call :FLASH "FB" "Firmware" "%P7%\!Utils\Firmware"

set command1=fastboot update "%P7%\1 Factory Image.zip"
call :FLASH "FB" "Factory Image"

set command1=fastboot flash init_boot "%P7%\2 Magisk.img"
call :FLASH "FB" "Magisk"

cls
call :DEVICE
CHOICE /C YN /M "Install Magisk App"?
if %ERRORLEVEL% EQU 1 (
	echo Installing Magisk & adb install "%Global%\Magisk.apk" > NUL 2>&1
)

exit

:ginkgo
set "DType=A"

set command1=fastboot flash recovery "%RN8%\1 Recovery.img"
set command2=fastboot reboot recovery
call :FLASH "FB" "Recovery"

call :FLASH "ADB" "Firmware" "%RN8%\2 Firmware.zip"

call :FLASH "ADB" "ROM" "%RN8%\3 Arrow-13.zip"

call :FLASH "ADB" "GApps" "%Global%\GApps-13.zip"

call :FLASH "ADB" "Pie Chromatix Libs Patcher" "%RN8%\4 ChromatixLibs.zip"

call :generic

goto :reboot

:generic
if "%DType%" EQU "AB" call :FLASH "ADB" "Magisk" "%Global%\Magisk.apk"
if "%DType%" EQU "A" call :FLASH "ADB" "Lygisk" "%Global%\Lygisk.apk"

exit /b

:reboot
cls
@echo Reboot to System
@echo.
@echo Connect USB Cable And Enable USB Debugging
adb devices | findstr /LIE "device" > NUL 2>&1
if %ERRORLEVEL% EQU 1 (
	TIMEOUT 1 /NoBreak > NUL 2>&1
	goto :reboot
)

cls
call :DEVICE
CHOICE /C YN /M "Debloat ROM"?
if %ERRORLEVEL% EQU 1 (
	for %%a in (
		:: General
		com.android.inputmethod.latin com.android.messaging com.android.dialer com.android.calculator2 com.android.calendar com.android.camera2 com.android.deskclock com.android.contacts com.android.gallery3d
		:: LineageOS
		org.lineageos.jelly org.lineageos.etar org.lineageos.snap org.lineageos.eleven org.lineageos.recorder
		:: crDroid
		org.omnirom.logcat
		:: Arrow
		com.simplemobiletools.calendar.pro com.simplemobiletools.gallery.pro com.duckduckgo.mobile.android
		:: ProtonAOSP
		app.grapheneos.camera
		:: Google
		com.google.android.apps.chromecast.app com.google.android.apps.docs.editors.docs com.google.android.apps.betterbug com.google.android.apps.magazines com.google.android.apps.podcasts com.google.android.apps.subscriptions.red com.google.android.apps.tachyon com.google.android.apps.wearables.maestro.companion com.google.android.videos com.google.android.apps.tips com.google.android.apps.youtube.music
	) do adb shell pm uninstall --user 0 %%a > NUL 2>&1
)

cls
call :DEVICE
CHOICE /C YN /M "Install Apps"?
if %ERRORLEVEL% EQU 1 (
	@echo Installing Apps
	for /F "tokens=*" %%a in ('dir "%Global%\Apps" /b /s ^| findstr ".apk"') do adb install "%%a" > NUL 2>&1

	if exist "%Global%\Camera\*%Device%*" (
		@echo Installing GCam
		for /F "tokens=*" %%i in ('dir "%Global%\Camera\*%Device%*" /b /s') do (
			for /F "tokens=*" %%a in ('dir "%%i" /b /s ^| findstr ".apk"') do adb install -d -r "%%a" > NUL 2>&1
			for /F "tokens=*" %%a in ('dir "%%i" /b /ad') do adb push "%%i\%%a" "/sdcard/" > NUL 2>&1
		)
	)

	if "%DType%" EQU "AB" echo Installing Magisk & adb install "%Global%\Magisk.apk" > NUL 2>&1
	if "%DType%" EQU "A" echo Installing Lygisk & adb install "%Global%\Lygisk.apk" > NUL 2>&1
)

cls
call :DEVICE
CHOICE /C YN /M "Import Settings"?
if %ERRORLEVEL% EQU 1 (
	adb shell settings put global animator_duration_scale 0.5 > NUL 2>&1
	adb shell settings put global transition_animation_scale 0.5 > NUL 2>&1
	adb shell settings put global window_animation_scale 0.5 > NUL 2>&1
	adb shell settings put global mobile_data_always_on 0 > NUL 2>&1
	@echo Rebuilding Play Store Data
	adb shell pm clear com.android.vending > NUL 2>&1
	adb shell am start com.android.vending > NUL 2>&1
	@echo Pushing Modules
	adb push "%Global%\Modules" "/sdcard/Download/Modules" > NUL 2>&1
)

cls
call :DEVICE
@echo Install Magisk Modules and Restart
@echo.
CHOICE /C YN /M "Import Magisk Modules Config?"
if %ERRORLEVEL% EQU 1 (
	adb shell cmd package set-home-activity "com.google.android.apps.nexuslauncher" > NUL 2>&1
)
::if "%Device%" NEQ "gta4xlwifi" 
::if "%Device%" EQU "gta4xlwifi" adb shell "su -c 'pixelify --disable pixellauncher'" > NUL 2>&1

cls
call :DEVICE
@echo Removing Modules
adb shell rm -r "/sdcard/Download/Modules" > NUL 2>&1
@echo Opening Play Store
adb shell am start com.android.vending > NUL 2>&1

adb kill-server > NUL 2>&1
exit

:FLASH
set "File="
set "Source=%~3"
if not exist "%Source%\*" (
	for %%a in ("%Source:\=" "%") do (
		set File=%%a
		set File=%File:"=%
	)
)

if "%~1" EQU "FB" (
	set "RQ=Enter Fastboot Mode"
)
if "%~1" EQU "DL" (
	set "RQ=Enter Download Mode"
)
if "%~1" EQU "ADB" (
	set "RQ=Enable ADB Sideload"
	set "CM=adb sideload"
	if not exist "%~3" exit /b
)

cls
@echo Device: %Device%
@echo.
@echo %RQ%
@echo.
CHOICE /C YN /M "Flash %~2"?
if %ERRORLEVEL% EQU 1 (
	cls
	@echo Device: %Device%
	@echo.
	if "%~1" EQU "FB" (
		:fastboot
		fastboot devices | findstr /LIE "fastboot" > NUL 2>&1
		if %ERRORLEVEL% EQU 1 (
			TIMEOUT 1 /NoBreak > NUL 2>&1
			goto :fastboot
		)
	)
	if "%~1" EQU "DL" (
		:download
		pnputil /enum-devices /connected | findstr /LIE "Gadget Serial" > NUL 2>&1
		if %ERRORLEVEL% EQU 1 (
			TIMEOUT 1 /NoBreak > NUL 2>&1
			goto :download
		)
	)
	if "%~1" EQU "ADB" (
		:sideload
		adb devices | findstr /LIE "sideload" > NUL 2>&1
		if %ERRORLEVEL% EQU 1 (
			TIMEOUT 1 /NoBreak > NUL 2>&1
			goto :sideload
		)
	)
	@echo Flashing %~2
	if "%~1" EQU "FB" (
		for /F "tokens=*" %%a in ('dir "%~3" /b ^| findstr ".img"') do (
			if "%DType%" EQU "A" fastboot flash %%~na "%~3\%%a"
			if "%DType%" EQU "AB" fastboot flash --slot=all %%~na "%~3\%%a"
			fastboot reboot-bootloader
			ping -n 5 127.0.0.1 > NUL 2>&1
		)
	)		
	if "%~1" EQU "ADB" (
		%CM% "%~3"
	)
	%command1%
	%command2%
)

set "command1="
set "command2="

exit /b

:DEVICE
cls

fastboot devices | findstr /LIE "fastboot" > NUL 2>&1
if %ERRORLEVEL% EQU 0 (
	for /F "tokens=2" %%a in ('fastboot getvar product 2^>^&1 ^| findstr "product"') do set "Device=%%a"
	@echo Device: %Device%
	@echo.
	exit /b
)

adb devices | findstr /LIE "device" > NUL 2>&1
if %ERRORLEVEL% EQU 0 (
	for /F "delims=" %%a in ('adb shell getprop ro.build.product') do set "Device=%%a"
	@echo Device: %Device%
	@echo.
	exit /b
)

pnputil /enum-devices /connected | findstr /LIE "Gadget Serial" > NUL 2>&1
if %ERRORLEVEL% EQU 0 (
	set "Device=gta4xlwifi"
	@echo Device: %Device%
	@echo.
	exit /b
)

@echo Connect USB Cable And Enable USB Debugging
TIMEOUT 1 /NoBreak > NUL 2>&1
goto :DEVICE