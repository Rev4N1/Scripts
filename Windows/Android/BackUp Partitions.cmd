@echo off
TITLE "BackUp Partitions"
mode con: cols=80 lines=10
cd /d "%~dp0"
CLS

cls
@echo Making BackUp Folder on Device
adb shell "su -c rm -r /sdcard/PartitionsBackUp" > NUL 2>&1
adb shell "su -c mkdir /sdcard/PartitionsBackUp" > NUL 2>&1

cls
@echo Copying Partition Images to BackUp Folder
set "Dir=/dev/block/bootdevice/by-name"
call :BUPart
if %errorlevel% EQU 1 (
	set "Dir=/dev/block/platform/13520000.ufs/by-name"
	call :BUPart
)

cls
@echo Removing Super, System, Vendor, Userdata Partitions
adb shell "su -c rm -r /sdcard/PartitionsBackUp/super*.img" > NUL 2>&1
adb shell "su -c rm -r /sdcard/PartitionsBackUp/system*.img" > NUL 2>&1
adb shell "su -c rm -r /sdcard/PartitionsBackUp/vendor*.img" > NUL 2>&1
adb shell "su -c rm -r /sdcard/PartitionsBackUp/userdata*.img" > NUL 2>&1

cls
@echo Pulling BackUp Folder to PC
adb pull "/sdcard/PartitionsBackUp" "%cd%\Partitions Backup"

cls
@echo Removing BackUp Folder from Device
adb shell "su -c rm -r /sdcard/PartitionsBackUp" > NUL 2>&1

cls
@echo Archiving BackUp Folder
"%ProgramFiles%\7-Zip\7z.exe" a "Partitions Backup.7z" "%cd%/Partitions Backup/*" > NUL 2>&1

cls
@echo Removing BackUp Folder from PC
rd /s /q "%cd%\Partitions Backup" > NUL 2>&1

exit

:BUPart
adb shell "su -c 'ls -1 %Dir% | grep -v userdata | grep -v super | while read f; do dd if=%Dir%/$f of=/sdcard/PartitionsBackUp/${f}.img; done'" | find /LI "No such file or directory" > NUL 2>&1

exit /b