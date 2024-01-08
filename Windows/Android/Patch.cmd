@echo off

for /F "tokens=*" %%a in ('dir /b ^| findstr "boot.img"') do (
	@echo Patch Stock Image
	adb shell rm -r "/sdcard/%%a" > NUL 2>&1
	adb shell "su -c 'rm -r /data/adb/magisk/new-boot.img'" > NUL 2>&1
	adb shell "su -c 'rm -r /data/adb/magisk/ramdisk.cpio'" > NUL 2>&1
	adb shell "su -c 'rm -r /data/adb/magisk/stock_boot.img'" > NUL 2>&1
	adb push "%cd%\%%a" "/sdcard/%%a" > NUL 2>&1
	adb shell "su -c 'sh /data/adb/magisk/boot_patch.sh /sdcard/%%a'"
	adb shell rm -r "/sdcard/%%a" > NUL 2>&1
	adb shell "su -c 'rm -r /data/adb/magisk/ramdisk.cpio'" > NUL 2>&1
	adb shell "su -c 'rm -r /data/adb/magisk/stock_boot.img'" > NUL 2>&1
	adb shell "su -c 'mv /data/adb/magisk/new-boot.img /sdcard/patched.img'" > NUL 2>&1
	adb pull "/sdcard/patched.img"
	adb shell rm -r "/sdcard/patched.img" > NUL 2>&1
)

pause
exit

adb shell rm -r "/sdcard/Magisk.apk"
adb shell rm -r "/sdcard/Magisk-Unziped"
adb shell rm -r "/sdcard/Magisk"
adb push "%cd%\Magisk.apk" "/sdcard/Magisk.apk"
adb shell unzip /sdcard/Magisk.apk -qod /sdcard/Magisk-Unziped
adb shell mkdir /sdcard/Magisk
adb shell find /sdcard/Magisk-Unziped/assets \( -name "*.sh" -o -name "*.apk" \) -exec mv {} /sdcard/Magisk \;
adb shell find /sdcard/Magisk-Unziped/lib/$(getprop ro.product.cpu.abi) -name "lib*" -exec mv {} /sdcard/Magisk \;
adb shell for file in /sdcard/magisk/lib*.so; do mv "$file" "/sdcard/magisk/$(basename "$file" | sed 's/^lib//;s/\.so$//')"; done
adb shell rm -r "/sdcard/boot.img"
for /F "tokens=*" %%a in ('dir /b ^| findstr "boot.img"') do adb push "%cd%\%%a" "/sdcard/boot.img"
adb shell chmod +x /sdcard/magisk/*
adb shell sh /sdcard/magisk/boot_patch.sh /sdcard/boot.img