:: CHECK GOG, ROCKSTAR, SPOTIFY, DISCORD, WHATSAPP
::@echo Google Chrome
::call :COPY "%LocalAppData%\Google"
@echo off
TITLE "Backup Utility"
MODE CON | findstr "9001 3000 120" > NUL 2>&1 && MODE CON lines=10 cols=70
cd /d "%~dp0"

set "Dir=%cd%"

@echo Delete Old Backup
rd /s /q "%Dir%\C" > NUL 2>&1
del /f /q /s "%Dir%\C.zip" > NUL 2>&1

@echo User Folders
call :COPY "%UserProfile%\Desktop"
call :COPY "%UserProfile%\Documents"
call :COPY "%UserProfile%\Videos"
call :COPY "%UserProfile%\Pictures"
:: Remove Duplicate Folders (1607)
rd /s /q "%Dir%\C\Users\%UserName%\Documents\My Videos" > NUL 2>&1
rd /s /q "%Dir%\C\Users\%UserName%\Documents\My Pictures" > NUL 2>&1

@echo Registry File on Desktop
echo Windows Registry Editor Version 5.00 > "%Dir%\C\Users\%UserName%\Desktop\Registry.reg"
echo. >> "%Dir%\C\Users\%UserName%\Desktop\Registry.reg"

:: Application Settings
@echo Discord
call :COPY "%AppData%\discord\Local Storage"
call :COPY "%AppData%\discord\domainMigrated"
call :COPY "%AppData%\discord\Local State"
call :COPY "%AppData%\discord\settings.json"

@echo OBS-Studio
call :COPY "%AppData%\obs-studio\basic"
call :COPY "%AppData%\obs-studio\global.ini"

@echo Spotify
call :COPY "%AppData%\Spotify\prefs"

:: Game Launchers Configs
@echo Battle.net
call :COPY "%ProgramData%\Battle.net\Agent\data\cache"
call :REGISTRY "HKEY_CURRENT_USER\Software\Blizzard Entertainment\Battle.net"
call :COPY "%AppData%\Battle.net\*.config"

@echo Battlestate Launcher
call :COPY "%AppData%\Battlestate Games"

@echo Epic Games Store
call :COPY "%LocalAppData%\EpicGamesLauncher\Saved\Config"
call :COPY "%ProgramData%\Epic\EpicGamesLauncher\Data\Manifests"

@echo GOG.com
call :COPY "%LocalAppData%\GOG.com"

@echo EA App / Origin
call :COPY "%ProgramData%\Electronic Arts\EA Services\License\*.dlf"
call :COPY "%AppData%\Origin\local*.xml"
call :COPY "%ProgramData%\Origin\local.xml"
call :COPY "%ProgramData%\Origin\LocalContent"
call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\Respawn"
call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Respawn"
call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Origin Games"

@echo Riot Games
call :COPY "%ProgramData%\Riot Games\RiotClientInstalls.json"
call :COPY "%LocalAppData%\Riot Games\Riot Client"

@echo Rockstar Games Launcher
call :COPY "%LocalAppData%\Rockstar Games\Launcher\firstrun.dat"
call :COPY "%LocalAppData%\Rockstar Games\Launcher\settings_user.dat"

@echo Steam
call :COPY "%ProgramFiles(x86)%\Steam\appcache\appinfo.vdf"
call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam\Apps"
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Valve\Steam"
call :COPY "%ProgramFiles(x86)%\Steam\config"
call :COPY "%ProgramFiles(x86)%\Steam\userdata"
call :COPY "%ProgramFiles(x86)%\Steam\steamapps\libraryfolders.vdf"
call :COPY "%ProgramFiles(x86)%\Steam\steam\games"
cd "%cd%\C\Program Files (x86)\Steam\userdata" && call :CLEAN "*remote*" && call :CLEAN "*cache*"

@echo Ubisoft Connect
call :COPY "%ProgramFiles(x86)%\Ubisoft\Ubisoft Game Launcher\cache\activations"
call :COPY "%ProgramFiles(x86)%\Ubisoft\Ubisoft Game Launcher\cache\configuration\configurations"
call :COPY "%ProgramFiles(x86)%\Ubisoft\Ubisoft Game Launcher\cache\ownership"
call :COPY "%ProgramFiles(x86)%\Ubisoft\Ubisoft Game Launcher\savegames"
call :COPY "%LocalAppData%\Ubisoft Game Launcher\settings.yml"

:: Games Configs
@echo Among Us
call :COPY "%UserProfile%\AppData\LocalLow\Innersloth\Among Us"
cd "%Dir%\C\Users\%UserName%\AppData\LocalLow\Innersloth\Among Us" && call :CLEAN "Unity"

@echo Aperture Hand Lab
call :REGISTRY "HKEY_CURRENT_USER\Software\Cloudhead Games, Ltd.\Knux"

@echo Apex Legends
call :COPY "%UserProfile%\Saved Games\Respawn\Apex\local"
call :COPY "%UserProfile%\Saved Games\Respawn\Apex\profile"

@echo BattleBit Remastered
call :COPY "%AppData%\BattleBitConfig.ini"
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\BattleBitDevTeam\BattleBit"

@echo Battlefield 4 Remove Crap
cd "%Dir%\C\Users\%UserName%\Documents\Battlefield 4" && call :CLEAN "twinkle"

@echo Battalion 1994
call :COPY "%LocalAppData%\Battalion\Saved\Config\WindowsClient"

@echo BioShock
call :COPY "%AppData%\Bioshock"

@echo BioShock 2
call :COPY "%AppData%\Bioshock2Steam"

@echo BioShock Remastered
call :COPY "%AppData%\BioshockHD\Bioshock"

@echo BioShock 2 Remastered
call :COPY "%AppData%\BioshockHD\Bioshock2"

@echo Bridge Constructor Portal
call :COPY "%UserProfile%\AppData\LocalLow\ClockStone Software GmbH\Bridge Constructor Portal"

@echo Call of Duty 4: Modern Warfare
call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Activision\Call of Duty 4"
call :COPY "%LocalAppData%\CallofDuty4MW"

@echo Call of Duty: World at War
call :COPY "%LocalAppData%\Activision\CoDWaW\players\profiles"

@echo Dead by Daylight
call :COPY "%LocalAppData%\DeadByDaylight\Saved\Config\WindowsNoEditor"

@echo Diablo
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Blizzard Entertainment\Diablo"

@echo Diablo II
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Blizzard Entertainment\Diablo II"

@echo Escape From Tarkov
call :REGISTRY "HKEY_CURRENT_USER\Software\Battlestate Games\EscapeFromTarkov"

@echo FiveM
call :COPY "%AppData%\CitizenFX"
call :COPY "%LocalAppData%\DigitalEntitlements"

@echo Fortnite
call :COPY "%LocalAppData%\FortniteGame\Saved\Config\WindowsClient"
call :COPY "%LocalAppData%\FortniteGame\Saved\SaveGames"

@echo Friday 13th
call :COPY "%LocalAppData%\SummerCamp\Saved\Config\WindowsNoEditor"

@echo Gang Beasts
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Boneloaf\Gang Beasts"

@echo Grand Theft Auto
call :REGISTRY "HKEY_LOCAL_MACHINE\Software\DMA Design\Grand Theft Auto"

@echo Grand Theft Auto 2
call :REGISTRY "HKEY_LOCAL_MACHINE\Software\Wow6432Node\DMA Design Ltd\GTA2"

@echo Grand Theft Auto IV And Grand Theft Auto: Episodes from Liberty City
call :COPY "%LocalAppData%\Rockstar Games\GTA IV\Settings\SETTINGS.CFG"
call :COPY "%LocalAppData%\Rockstar Games\GTA IV\Settings\SETTINGS_EFLC.CFG"
call :COPY "%LocalAppData%\Rockstar Games\GTA IV\savegames"

@echo Half-Life
call :REGISTRY "HKEY_CURRENT_USER\Software\Valve\Half-Life"

@echo Half-Life 2: Year Long Alarm
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Valve\Source\yearlongalarm\Settings"

@echo League Of Legends
call :COPY "%ProgramData%\Riot Games\Metadata\league_of_legends.live\league_of_legends.live.product_settings.yaml"
call :COPY "%ProgramData%\Riot Games\Metadata\league_of_legends.live\league_of_legends.live.ico"
call :COPY "%ProgramData%\Riot Games\Metadata\league_of_legends.live\league_of_legends.live.db"

@echo Lethal Company
call :COPY "%UserProfile%\AppData\LocalLow\ZeekerssRBLX\Lethal Company"

@echo Life Is Strange 2
call :COPY "%LocalAppData%\Dontnod"

@echo Minecraft
call :COPY "%AppData%\.minecraft\options.txt"
call :COPY "%AppData%\.minecraft\optionsof.txt"
call :COPY "%AppData%\.minecraft\servers.dat"
call :COPY "%AppData%\.minecraft\saves" "%Dir%\C\Users\%UserName%\AppData\Roaming\.minecraft\saves"
call :COPY "%AppData%\.tlauncher\tlauncher-2.0.properties"

@echo Minecraft Dungeons
call :COPY "%LocalAppData%\Dungeons" "%Dir%\C\Users\%UserName%\AppData\Local\Dungeons"

@echo Overcooked!
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Ghost Town Games\Overcooked"
call :COPY "%UserProfile%\AppData\LocalLow\Ghost Town Games\Overcooked"

@echo Overcooked! 2
call :REGISTRY "HKEY_CURRENT_USER\Software\Team17\Overcooked2"
call :COPY "%UserProfile%\AppData\LocalLow\Team17\Overcooked2"

@echo Payday 2
call :COPY "%LocalAppData%\PAYDAY 2"

@echo Phasmophobia
call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Kinetic Games\Phasmophobia"
call :COPY "%UserProfile%\AppData\LocalLow\Kinetic Games\Phasmophobia\saveData.txt"

@echo Plutonium
call :COPY "%LocalAppData%\Plutonium\config.json"
call :COPY "%LocalAppData%\Plutonium\storage\demonware"
call :COPY "%LocalAppData%\Plutonium\storage\iw5\players"
call :COPY "%LocalAppData%\Plutonium\storage\t4\players"
call :COPY "%LocalAppData%\Plutonium\storage\t5\players"
call :COPY "%LocalAppData%\Plutonium\storage\t6\players"
cd "%Dir%\C\Users\%UserName%\AppData\Local\Plutonium\storage\demonware" && call :CLEAN "pub"

@echo Project Zomboid
call :COPY "%UserProfile%\Zomboid\Lua"
call :COPY "%UserProfile%\Zomboid\Saves"
call :COPY "%UserProfile%\Zomboid\Server"
call :COPY "%UserProfile%\Zomboid\options.ini"

@echo PUBG
call :COPY "%LocalAppData%\TslGame\Saved\Config\WindowsNoEditor"

@echo Quake Champions
call :COPY "%LocalAppData%\id Software\Quake Champions"

@echo Quake Live
call :COPY "%UserProfile%\AppData\LocalLow\id Software\quakelive\home\baseq3"

@echo Rainbow Six Siege
call :REGISTRY "HKEY_CURRENT_USER\Software\Ubisoft\Rainbow Six - Siege"

@echo Sons Of The Forest
call :COPY "%UserProfile%\AppData\LocalLow\Endnight\SonsOfTheForest"

@echo Super Animal Royale
call :REGISTRY "HKEY_CURRENT_USER\Software\Pixile Inc\Super Animal Royale"

@echo The Escapists 2
call :REGISTRY "HKEY_CURRENT_USER\Software\Team 17 Digital ltd.\The Escapists 2"
call :COPY "%UserProfile%\AppData\LocalLow\Team 17 Digital ltd_\The Escapists 2\Saves"

@echo The Elder Scrolls III: Morrowind
call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Bethesda Softworks\Morrowind"

@echo The Elder Scrolls: Legends
call :REGISTRY "HKEY_CURRENT_USER\Software\Bethesda Softworks LLC\Legends"

@echo The Lab
call :COPY "%UserProfile%\AppData\LocalLow\Valve\TheLab\PlayerData.txt"

@echo Unturned
call :REGISTRY "HKEY_CURRENT_USER\Software\Smartly Dressed Games\Unturned"

@echo Valorant
call :COPY "%LocalAppData%\VALORANT\Saved\Config"
call :COPY "%ProgramData%\Riot Games\Metadata\valorant.live\valorant.live.product_settings.yaml"
call :COPY "%ProgramData%\Riot Games\Metadata\valorant.live\valorant.live.ico"
call :COPY "%ProgramData%\Riot Games\Metadata\valorant.live\valorant.live.db"

:: Windows Settings
::@echo QoS Profiles
::call :REGISTRY "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\QoS"

::@echo Fullscreen Settings
::call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

::@echo GPU Preferences
::call :REGISTRY "HKEY_CURRENT_USER\SOFTWARE\Microsoft\cdectX\UserGpuPreferences"

@echo Remove Not Necessary Files
cd "%Dir%\C"
call :CLEAN "*logs*"
call :CLEAN "*crash*"
call :CLEAN "*log"
call :CLEAN "*old"
call :CLEAN "*bak"

cd "%Dir%\C\Users"
call :CLEAN "*cache*"

@echo Removing Empty Diretories
cd "%Dir%\C"
for /F "delims=" %%a in ('dir /s /b /ad ^| sort /r') do rd "%%a" > NUL 2>&1

if exist "%ProgramFiles%\7-Zip\7z.exe" (
	@echo Creating Archive With 7-Zip
	cd "%Dir%"
	"%ProgramFiles%\7-Zip\7z.exe" a -tzip C.zip "%cd%\*" > NUL 2>&1
	rd /s /q "C" > NUL 2>&1
)

pause
exit

:COPY
:: Get Source
set "Source=%~1"
:: Get Destination
for /F "tokens=2,* delims=:" %%a in ("%Source%") do set "Destination=%Dir%\C%%a"
:: Remove File
set "File="
:: Get FileName
if not exist "%Source%\*" (for %%a in ("%Source:\=" "%") do set File=%%a)
if not exist "%Source%\*" set File=%File:"=%
:: If Not Exist Exit
if not exist "%Source%" exit /b

if exist "%File%\*" robocopy "%Source%" "%Destination%" /NFL /NDL /NJH /NJS /NC /NS /NP /E > NUL 2>&1
if not exist "%File%\*" echo F | xcopy "%Source%" "%Destination%" /H /C /K /R /Y > NUL 2>&1

exit /b

:REGISTRY
reg query "%~1" > NUL 2>&1
if %ERRORLEVEL% EQU 0 (
	regedit /e Registry.reg "%~1" > NUL 2>&1
	type Registry.reg | find /v "Windows Registry Editor Version 5.00" >> "%Dir%\C\Users\%UserName%\Desktop\Registry.reg"
	del Registry.reg > NUL 2>&1
)

exit /b

:CLEAN
for /D /R . %%a in ("%~1") do rd /s /q "%%a" > NUL 2>&1
del /f /q /s "%~1" > NUL 2>&1

exit /b