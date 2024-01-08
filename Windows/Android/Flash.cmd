@echo off
title "Flash Utility"
mode con | findstr "9001 3000 120" > NUL 2>&1 && mode con lines=10 cols=70
cd /d "%~dp0"

set "Global=%cd%\Global"

adb start-server > NUL 2>&1

call :DEVICE
goto %Device%

@echo Connect a Supported Device
timeout 5 /NoBreak > NUL 2>&1

exit

:oriole
set "DType=AB"
set "DFolder=%cd%\Pixel 6"

call :FLASH "FB" "Recovery" "%DFolder%\1 Recovery"

call :FLASH "ADB" "ROM" "%DFolder%\2 Hentai-14.zip"

call :generic

goto :system_reboot

:gta4xlwifi
set "DType=A"
set "DFolder=%cd%\Tab S6 Lite"

set command1=heimdall flash --CM "%DFolder%\!Utils\Firmware\cm.bin" --KEYSTORAGE "%DFolder%\!Utils\Firmware\keystorage.bin" --BOOTLOADER "%DFolder%\!Utils\Firmware\sboot.bin" --UH "%DFolder%\!Utils\Firmware\uh.bin" --UP_PARAM "%DFolder%\!Utils\up_param.bin" --RECOVERY "%DFolder%\1 Recovery.img"
call :FLASH "DL" "Firmware, Clean BootSplash and Recovery"

call :FLASH "ADB" "ROM" "%DFolder%\2 Lineage-21.zip"

call :FLASH "ADB" "GApps" "%Global%\GApps-14.zip"

call :generic

goto :system_reboot

:walleye
set "DType=AB"
set "DFolder=%cd%\Pixel 2"

call :FLASH "FB" "Firmware" "%DFolder%\!Utils\Firmware"

call :FLASH "FB" "Recovery" "%DFolder%\1 Recovery"

call :SLOT "Save"

call :FLASH "ADB" "ROM" "%DFolder%\2 Lineage-20.zip"

call :SLOT "Restore"

call :FLASH "ADB" "GApps" "%Global%\GApps-13.zip"

call :generic

goto :system_reboot

:panther
set "DType=AB"
set "DFolder=%cd%\Pixel 7"

call :FLASH "FB" "Firmware" "%DFolder%\!Utils\Firmware"

set command1=fastboot update "%DFolder%\!Utils\Factory Image.zip"
call :FLASH "FB" "Factory Image"

call :generic

call :DEVICE
choice /C YN /N /M "SafetyNet Fix? [Y/N]"
if %errorlevel% EQU 1 (
	call :root_setup "Fix"
)

call :cleanup

goto :EOL

:ginkgo
set "DType=A"
set "DFolder=%cd%\Redmi Note 8"

set command1=fastboot flash recovery "%DFolder%\1 Recovery.img"
set command2=fastboot reboot recovery
call :FLASH "FB" "Recovery"

call :FLASH "ADB" "Firmware" "%DFolder%\2 Firmware.zip"

call :FLASH "ADB" "ROM" "%DFolder%\3 Arrow-13.zip"

call :FLASH "ADB" "GApps" "%Global%\GApps-13.zip"

call :generic

goto :system_reboot

:generic
if exist "%DFolder%\patched.img" (
	for /F "tokens=*" %%a in ('dir "%DFolder%" /b ^| findstr "boot.img"') do (
		set command1=fastboot flash %%~na "%DFolder%\patched.img"
		call :FLASH "FB" "Patched Image"
	)
) else (
	if "%DType%" EQU "AB" call :FLASH "ADB" "Magisk" "%Global%\Magisk.apk"
	if "%DType%" EQU "A" call :FLASH "ADB" "Lygisk" "%Global%\Lygisk.apk"
)

exit /b

:system_reboot
cls
@echo Reboot to System
@echo.
@echo Connect USB Cable And Enable USB Debugging
:adb_query
adb devices | findstr /LIE "device" > NUL 2>&1
if %errorlevel% EQU 1 (
	timeout 1 /NoBreak > NUL 2>&1
	goto :adb_query
)

call :DEVICE
choice /C YN /N /M "Debloat, Apps, Settings and Root Modules? [Y/N]"
if %errorlevel% EQU 1 (
	call :apps_debloat

	call :apps_install

	call :settings

	call :root_setup

	call :cleanup
)

:EOL
adb kill-server > NUL 2>&1
exit


:apps_debloat
@echo Debloating ROM
for %%a in (
	:: General
	com.android.inputmethod.latin com.android.messaging com.android.dialer com.android.calculator2 com.android.calendar com.android.camera2 com.android.deskclock com.android.contacts com.android.gallery3d
	:: Google
	com.google.android.apps.chromecast.app com.google.android.apps.docs.editors.docs com.google.android.apps.betterbug com.google.android.apps.magazines com.google.android.apps.podcasts com.google.android.apps.subscriptions.red com.google.android.apps.tachyon com.google.android.apps.wearables.maestro.companion com.google.android.videos com.google.android.apps.tips com.fitbit.FitbitMobile com.google.android.apps.wear.companion
	:: LineageOS
	org.lineageos.jelly org.lineageos.etar org.lineageos.snap org.lineageos.aperture org.lineageos.eleven org.lineageos.recorder
	:: ArrowOS
	com.simplemobiletools.calendar.pro com.simplemobiletools.gallery.pro com.duckduckgo.mobile.android
) do adb shell pm uninstall --user 0 %%a > NUL 2>&1

exit /b


:apps_install
@echo Installing Apps
for /F "tokens=*" %%a in ('dir "%Global%\Apps" /b /s ^| findstr ".apk" ^| findstr /VI "Twitch TikTok Reddit"') do adb install "%%a" > NUL 2>&1

if exist "%Global%\Camera\*%Device%*" (
	@echo Installing GCam
	for /F "tokens=*" %%i in ('dir "%Global%\Camera\*%Device%*" /b /s') do (
		for /F "tokens=*" %%a in ('dir "%%i" /b /s ^| findstr ".apk"') do adb install -d -r "%%a" > NUL 2>&1
		for /F "tokens=*" %%a in ('dir "%%i" /b /ad') do adb push "%%i\%%a" "/sdcard/" > NUL 2>&1
	)
)

if "%DType%" EQU "AB" echo Installing Magisk & adb install "%Global%\Magisk.apk" > NUL 2>&1
if "%DType%" EQU "A" echo Installing Lygisk & adb install "%Global%\Lygisk.apk" > NUL 2>&1

exit /b


:settings
@echo Faster Animations
adb shell settings put global animator_duration_scale 0.5 > NUL 2>&1
adb shell settings put global transition_animation_scale 0.5 > NUL 2>&1
adb shell settings put global window_animation_scale 0.5 > NUL 2>&1

@echo Disable Mobile Data Always Active
adb shell settings put global mobile_data_always_on 0 > NUL 2>&1

exit /b


:root_setup
@echo Root DenyList Configuration
adb shell "su -c 'magisk --denylist disable'"
for %%a in (
	"com.bbva.bbvacontigo com.bbva.bbvacontigo"
	"com.bbva.bbvacontigo com.bbva.bbvacontigo:magiskProcess"
	"com.bbva.bbvacontigo com.bbva.bbvacontigo:rootProcess"
	"isolated com.bbva.bbvacontigo:magiskProcess:com.bbva.ethermobilesdk.devicechecker.magisk.service.MagiskService"
	"isolated com.bbva.bbvacontigo:rootProcess:com.bbva.ethermobilesdk.devicechecker.root.service.RootService"
	"com.disney.disneyplus com.disney.disneyplus"
	"com.fnmt.bono.cultura com.fnmt.bono.cultura"
) do adb shell "su -c 'magisk --denylist add %%a'" > NUL 2>&1

@echo Apply Play Integrity Fix Config
adb shell rm -r "/sdcard/custom.pif.json" > NUL 2>&1
adb push "%Global%\Modules\custom.pif.json" "/sdcard/custom.pif.json" > NUL 2>&1
adb shell "su -c 'mkdir /data/adb/modules/playintegrityfix'" > NUL 2>&1
adb shell "su -c 'rm -r /data/adb/modules/playintegrityfix/custom.pif.json'" > NUL 2>&1
adb shell "su -c 'mv /sdcard/custom.pif.json /data/adb/modules/playintegrityfix/custom.pif.json'" > NUL 2>&1
adb shell "su -c 'killall com.google.android.gms.unstable'" > NUL 2>&1

@echo Install Modules
for /F "tokens=*" %%a in ('dir "%Global%\Modules" /b ^| findstr "%~1.zip"') do (
	adb push "%Global%\Modules\%%a" "/sdcard/Download/%%a" > NUL 2>&1
	adb shell "su -c 'magisk --install-module "/sdcard/Download/%%a"'" > NUL 2>&1
	adb shell rm -r "/sdcard/Download/%%a" > NUL 2>&1
)

for /F "tokens=*" %%a in ('dir "%DFolder%" /b ^| findstr "boot.img"') do if exist "%DFolder%\%%a" (
	@echo Backup Stock Boot.img
	adb shell rm -r "/sdcard/boot.img" > NUL 2>&1
	for /F "tokens=*" %%a in ('dir "%DFolder%" /b ^| findstr "boot.img"') do adb push "%DFolder%\%%a" "/sdcard/boot.img" > NUL 2>&1
	adb shell "gzip -9f /sdcard/boot.img" > NUL 2>&1
	adb shell "su -c 'find /data -name magisk_backup_* -exec rm -r {} +'" > NUL 2>&1
	adb shell "su -c 'mkdir /data/magisk_backup_$(cat $(magisk --path)/.magisk/config | grep SHA1 | cut -d '=' -f 2)'" > NUL 2>&1
	adb shell "su -c 'mv /sdcard/boot.img.gz /data/magisk_backup_$(cat $(magisk --path)/.magisk/config | grep SHA1 | cut -d '=' -f 2)/boot.img.gz'" > NUL 2>&1
	adb shell "su -c 'chmod -R 755 /data/magisk_backup_$(cat $(magisk --path)/.magisk/config | grep SHA1 | cut -d '=' -f 2)'" > NUL 2>&1
	adb shell "su -c 'chown -R root.root /data/magisk_backup_$(cat $(magisk --path)/.magisk/config | grep SHA1 | cut -d '=' -f 2)'" > NUL 2>&1
)

@echo Reboot Device
adb reboot > NUL 2>&1
:reboot_query
adb devices | findstr /LIE "device" > NUL 2>&1
if %errorlevel% EQU 1 (
	timeout 1 /NoBreak > NUL 2>&1
	goto :reboot_query
)

exit /b


:cleanup
@echo Clear All Apps Cache
adb shell pm trim-caches 128G > NUL 2>&1

@echo Opening Play Store
adb shell am start com.android.vending > NUL 2>&1

exit /b


:DEVICE
cls
@echo Connect USB Cable And Enable USB Debugging

fastboot devices | findstr /LIE "fastboot" > NUL 2>&1
if %errorlevel% EQU 0 (
	for /F "tokens=2" %%a in ('fastboot getvar product 2^>^&1 ^| findstr "product"') do set "Device=%%a"
	cls
	@echo Device: %Device%
	@echo.
	exit /b
)

adb devices | findstr /LIE "device" > NUL 2>&1
if %errorlevel% EQU 0 (
	for /F "delims=" %%a in ('adb shell getprop ro.build.product') do set "Device=%%a"
	cls
	@echo Device: %Device%
	@echo.
	exit /b
)

WMIC Path CIM_LogicalDevice Get /Value > NUL 2>&1 | findstr /C:"Gadget Serial" > NUL 2>&1
if %errorlevel% EQU 0 (
	set "Device=gta4xlwifi"
	cls
	@echo Device: %Device%
	@echo.
	exit /b
)

pnputil /enum-devices /connected | findstr /LIE "Gadget Serial" > NUL 2>&1
if %errorlevel% EQU 0 (
	set "Device=gta4xlwifi"
	cls
	@echo Device: %Device%
	@echo.
	exit /b
)

goto :DEVICE


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
choice /C YN /N /M "Flash %~2? [Y/N]"
if %errorlevel% EQU 1 (
	cls
	@echo Device: %Device%
	@echo.
	if "%~1" EQU "FB" (
		:fastboot
		fastboot devices | findstr /LIE "fastboot" > NUL 2>&1
		if %errorlevel% EQU 1 (
			timeout 1 /NoBreak > NUL 2>&1
			goto :fastboot
		)
	)
	if "%~1" EQU "DL" (
		:download
		pnputil /enum-devices /connected | findstr /LIE "Gadget Serial" > NUL 2>&1
		if %errorlevel% EQU 1 (
			timeout 1 /NoBreak > NUL 2>&1
			goto :download
		)
	)
	if "%~1" EQU "ADB" (
		:sideload
		adb devices | findstr /LIE "sideload" > NUL 2>&1
		if %errorlevel% EQU 1 (
			timeout 1 /NoBreak > NUL 2>&1
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


:SLOT
call :DEVICE

if "%~1" EQU "Save" (
	for /F "tokens=2" %%a in ('fastboot getvar current-slot 2^>^&1 ^| findstr "current-slot"') do set "Slot=%%a"
)

if "%~1" EQU "Restore" (
	if "%Slot%" EQU "a" fastboot --set-active=b
	if "%Slot%" EQU "b" fastboot --set-active=a
)

exit /b