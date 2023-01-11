@echo off
TITLE "GSI Installer"
mode con: cols=70 lines=10
cd /d "%~dp0"
CLS

set "ZDL=Y1sak/7z-Portable"
set "ZFile=7z.exe"
set "DSUSDL=VegaBobo/DSU-Sideloader"
set "DSUSFile=app-release.apk"
set "GSIDL=phhusson/treble_experimentations"
set "GSIFile=system-squeak-arm64-ab-gapps.img.xz"

del /f /q "%TEMP%\%ZFile%" > NUL 2>&1
curl -fsSL "github.com/%ZDL%/releases/latest/download/%ZFile%" -o "%TEMP%\%ZFile%" -O > NUL 2>&1

@echo Download and Install DSU Sideloader
del /f /q "%TEMP%\%DSUSFile%" > NUL 2>&1
curl -fsSL "github.com/%DSUSDL%/releases/latest/download/%DSUSFile%" -o "%TEMP%\%DSUSFile%" -O > NUL 2>&1
adb install "%TEMP%\%DSUSFile%" > NUL 2>&1

@echo Download GSI
del /f /q "%TEMP%\%GSIFile%" > NUL 2>&1
curl -fsSL "github.com/%GSIDL%/releases/latest/download/%GSIFile%" -o "%TEMP%\%GSIFile%" -O > NUL 2>&1

@echo Extract GSI
rd /s /q "%TEMP%\GSI" > NUL 2>&1
"%TEMP%\%ZFile%" x "%TEMP%\%GSIFile%" -o"%TEMP%\GSI" > NUL 2>&1

@echo Push GSI to Phone
adb push "%TEMP%\GSI" /sdcard/ > NUL 2>&1

@echo CleanUp
del /f /q "%TEMP%\%ZFile%" > NUL 2>&1
del /f /q "%TEMP%\%DSUSFile%" > NUL 2>&1
del /f /q "%TEMP%\%GSIFile%" > NUL 2>&1
rd /s /q "%TEMP%\GSI" > NUL 2>&1

pause
exit