@echo off
TITLE "Payload Extractor"
mode con: cols=70 lines=10
cd /d "%~dp0"

if "%~1" NEQ "" (
	cd "%cd%\PayloadDumper"
	goto :extract
)

set "PYVer=3.10"
set "PYDL=python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe"
set "PDDL=vm03/payload_dumper"

py -%PYVer% --version > NUL 2>&1
if %ERRORLEVEL% EQU 0 (
    @echo Python %PYVer% is already installed
) else (
	@echo Downloading Python %PYVer%
	del /f /q "%TEMP%\Python-%PYVer%-Installer.exe" > NUL 2>&1
	curl -fsSL "%PYDL%" -o "%TEMP%\Python-%PYVer%-Installer.exe" -O > NUL 2>&1

	@echo Installing Python %PYVer%
	"%TEMP%\Python-%PYVer%-Installer.exe" /quiet InstallAllUsers=1 PrependPath=1 > NUL 2>&1

	@echo Cleaning up Python Installer
	del /f /q "%TEMP%\Python-%PYVer%-Installer.exe" > NUL 2>&1
)

@echo Download Payload Dumper
rd /s /q "%cd%\PayloadDumper" > NUL 2>&1
mkdir "%cd%\PayloadDumper" > NUL 2>&1
for %%a in (
	update_metadata_pb2.py
	payload_dumper.py
) do curl -fsSL "raw.githubusercontent.com/%PDDL%/master/%%a" -o "%cd%\PayloadDumper\%%a" -O > NUL 2>&1
curl -fsSL "raw.githubusercontent.com/Fabian42/payload_dumper/patch-1/requirements.txt" -o "%cd%\PayloadDumper\requirements.txt" -O > NUL 2>&1

cd "%cd%\PayloadDumper"

@echo Create Virtual Enviroment
py -%PYVer% -m venv venv

@echo Updating Requirements Packages
"%cd%\venv\Scripts\python.exe" -m pip install --upgrade pip > NUL 2>&1

@echo Installing Payload Dumper Requirements
"%cd%\venv\Scripts\pip.exe" install -r ./requirements.txt > NUL 2>&1

pause
exit

:extract
if not exist "%cd%\old" (
	"%cd%\venv\Scripts\python.exe" payload_dumper.py --image boot --out old "%~1"
) else (
	"%cd%\venv\Scripts\python.exe" payload_dumper.py --diff --image boot "%~1"
)

pause
exit