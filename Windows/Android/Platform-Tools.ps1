if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
$host.ui.RawUI.WindowTitle = 'ADB & Driver Installer'

Write-Host "#########################################" -ForegroundColor Green
Write-Host "#         ADB & Driver Installer        #" -ForegroundColor Green
Write-Host "#########################################" -ForegroundColor Green

function DownloadADB {
  # PROMPT FOR USER for download 
  ($InstallorNOT) = Read-Host "`nDo you want to install ADB and Fastboot (Recommended)[Y/N]?"
  while ("y", "n" -notcontains $InstallorNOT ) {
    $InstallorNOT = Read-Host "`nPlease enter your response [Y/N]"
  }
  if ($InstallorNOT -eq "N") {
    Write-Host "`nSkipping download ADB part"
    InstallDriver
  }

  if ($InstallorNOT -eq "Y") {
    # Make sure that there is no ADB folder before downloading
    $ADBFILES = "$PSScriptRoot\adb" 
    $ADBExists = Test-Path $ADBFILES
    if ($ADBExists -eq $true) {
      Remove-item $ADBFILES -Recurse -Force 

    }
    # Download ADB
    Write-Host "`nDownloading the latest Official ADB & Fastboot files"

    $url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    $DownloadDestinationADB = "$PSScriptRoot\platform-tools-latest-windows.zip"
    $UnzipDestinationADB = "$PSScriptRoot\platform-tools-latest-windows"
    $start_time = Get-Date

    Invoke-WebRequest -Uri $url -OutFile $DownloadDestinationADB
    Write-Output "Download time: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    # Unzip
    Write-Host "Extracting now"
    Expand-Archive -Path $DownloadDestinationADB -DestinationPath $UnzipDestinationADB 

    # Copy
    [string]$sourceDirectory = "$PSScriptRoot\platform-tools-latest-windows\platform-tools\"
    [string]$destinationDirectory = "$PSScriptRoot\adb"
    Copy-item -Force -Recurse $sourceDirectory -Destination $destinationDirectory 

    # Remove ADB folder and zip
    $RemoveADBFiles = "$PSScriptRoot\platform-tools-latest-windows.zip", "$PSScriptRoot\platform-tools-latest-windows"
    Remove-Item $RemoveADBFiles -Recurse -Force

    #Go To Heimdall Installation
    Heimdall
  }
}

function Heimdall {
  # PROMPT FOR USER for download 
  ($InstallorNOT) = Read-Host "`nDo you want to install Heimdall (Recommended)[Y/N]?"
  while ("y", "n" -notcontains $InstallorNOT ) {
    $InstallorNOT = Read-Host "`nPlease enter your response [Y/N]"
  }
  if ($InstallorNOT -eq "N") {
    Write-Host "`nSkipping Heimdall"
    ADBsystemwide
  }

  if ($InstallorNOT -eq "Y") {
    # Download Heimdall
    Write-Host "`nDownloading the latest Official Heimdall files"
    $url = "https://github.com/Y1sak/Heimdall/releases/download/v2.0.2/win-build.zip"
    $DownloadDestinationHeimdall = "$PSScriptRoot\heimdall.zip"
    $UnzipDestinationHeimdall = "$PSScriptRoot\heimdall"
    $start_time = Get-Date

    Invoke-WebRequest -Uri $url -OutFile $DownloadDestinationHeimdall
    Write-Output "Download time: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    # Unzip
    Write-Host "Extracting now"
    Expand-Archive -Path $DownloadDestinationHeimdall -DestinationPath $UnzipDestinationHeimdall 

    # Copy
    [string]$sourceDirectory = "$PSScriptRoot\heimdall\*"
    [string]$destinationDirectory = "$PSScriptRoot\adb"
    Copy-item -Force -Recurse $sourceDirectory -Destination $destinationDirectory 

    # Remove Heimdall folder and zip
    $RemoveHeimdallFiles = "$PSScriptRoot\heimdall.zip", "$PSScriptRoot\heimdall"
    Remove-Item $RemoveHeimdallFiles -Recurse -Force

    #Go To System-Wide Installation
    ADBsystemwide
  }
}

function ADBsystemwide {
  # PROMPT FOR SYSTEM-wide ADB or CURRENT DIRECTORY
  $SystemADBinstall = Read-Host "`nDo you want to install ADB System-wide [Y/N]?"
  while ("y", "n" -notcontains $SystemADBinstall ) {
    $SystemADBinstall = Read-Host "`nPlease enter your response [Y/N]"
  }
  if ($SystemADBinstall -eq "N") {
    Write-Host "You choose to not install ADB system-wide"
    ADBuserOnly
  }
  if ($SystemADBinstall -eq "Y") {        
    $ADBFILES = "$PSScriptRoot\adb" 
    $ADBExists = Test-Path $ADBFILES
    while ($ADBExists -eq $false) {
      Write-Host "`nADB directory is not detected in $PSScriptRoot you most select yes in the previous step to continue, or you can close the window to exit"
      DownloadADB
    }

    if ($ADBExists -eq $true) {
      Write-Host "`nCopy ADB files to $env:HOMEDRIVE\adb"

      # Make sure that there is no ADB folder 
      $ADBinC = "$env:HOMEDRIVE\adb" 
      $ADBExistsinC = Test-Path $ADBinC
      if ($ADBExistsinC -eq $true) {
        Remove-item $ADBinC -Recurse -Force 
      }

      # Copy
      [string]$sourceDirectory = "$PSScriptRoot\adb"
      [string]$destinationDirectory = "$env:HOMEDRIVE\adb"
      Copy-item -Force -Recurse $sourceDirectory -Destination $destinationDirectory 

      # Set Path
      $INCLUDE = "$destinationDirectory"
      $OLDPATH = [System.Environment]::GetEnvironmentVariable('PATH','Machine')
      $NEWPATH = "$OLDPATH;$INCLUDE"
      [Environment]::SetEnvironmentVariable("PATH", "$NEWPATH", "Machine")

      #Remove ADB folder
      $RemoveADBFiles = "$PSScriptRoot\adb"
      Remove-Item $RemoveADBFiles -Recurse -Force

      #Go To Install Driver
      InstallDriver
    }
  }
}


function ADBuserOnly {
  # PROMPT FOR User-wide ADB or CURRENT DIRECTORY
  $ADBuserOnly = Read-Host "`nDo you want to install ADB User-wide (Recommended)[Y/N]?"
  while ("y", "n" -notcontains $ADBuserOnly) {
    $ADBuserOnly = Read-Host "`nPlease enter your response [Y/N]"
  }
  if ($ADBuserOnly -eq "N") {
    Write-Host "You choose to not install ADB User-wide"
    ADBsystemwide
  }


  if ($ADBuserOnly -eq "Y") {        
    $ADBFILES = "$PSScriptRoot\adb" 
    $ADBExists = Test-Path $ADBFILES
    while ($ADBExists -eq $false) {
      Write-Host "`nADB is not detected in $PSScriptRoot you most select yes in the previous step to continue, or you can close the window to exit"
      DownloadADB
    }

    if ($ADBExists -eq $true) {
      Write-Host "`nCopy ADB files to $env:USERPROFILE\ADB"

      # Make sure that there is no ADB folder 
      $ADBInuser = "$env:USERPROFILE\adb"
      $ADBExistsInUser = Test-Path $ADBInuser
      if ($ADBExistsInUser -eq $true) {
        Remove-item $ADBInuser -Recurse -Force 
      }

      # Copy
      [string]$sourceDirectory = "$PSScriptRoot\adb"
      [string]$destinationDirectory = "$env:USERPROFILE\adb"
      Copy-item -Force -Recurse $sourceDirectory -Destination $destinationDirectory 

      # Set Path
      $INCLUDE = "$destinationDirectory"
      $OLDPATH = [System.Environment]::GetEnvironmentVariable('PATH','USER')
      $NEWPATH = "$OLDPATH;$INCLUDE"
      [Environment]::SetEnvironmentVariable("PATH", "$NEWPATH", "USER")

      #Remove ADB folder
      $RemoveADBFiles = "$PSScriptRoot\adb"
      Remove-Item $RemoveADBFiles -Recurse -Force

      #Go To Install Driver
      InstallDriver
    }
  }
}


function InstallDriver {
  # PROMPT FOR USER for download 
  ($InstallorNOT) = Read-Host "`nDo you want to install device drivers (Reccomended)[Y/N]?"
  while ("y", "n" -notcontains $InstallorNOT ) {
    $InstallorNOT = Read-Host "`nPlease enter your response [Y/N]"
  }
  if ($InstallorNOT -eq "N") {
    Write-Host "`nSkipping installing driver part"
  }

  if ($InstallorNOT -eq "Y") {
    # Make sure that there is no ADB folder 
    $Driveristhere = "$PSScriptRoot\ADBDriver\"
    $ADBDriverExists = Test-Path $Driveristhere
    if ($ADBDriverExists -eq $true) {
      Remove-item $Driveristhere -Recurse -Force         
    }
    # Download device drivers
    Write-Host "`nDownloading the latest Official Driver"

    $url = "https://dl.google.com/android/repository/usb_driver_r13-windows.zip"
    $DownloadDestinationDriver = "$PSScriptRoot\latest_usb_driver_windows.zip"
    $UnzipDestinationDriver = "$PSScriptRoot\latest_usb_driver_windows"
    $start_time = Get-Date

    Invoke-WebRequest -Uri $url -OutFile $DownloadDestinationDriver
    Write-Output "Download time: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    # Unzip
    Write-Host "Extracting now"
    Expand-Archive -Path $DownloadDestinationDriver -DestinationPath $UnzipDestinationDriver

    # Copy
    [string]$sourceDirectoryDriver = "$PSScriptRoot\latest_usb_driver_windows\usb_driver\"
    [string]$destinationDirectoryDriver = "$PSScriptRoot\ADBDriver\"
    Copy-item -Force -Recurse $sourceDirectoryDriver -Destination $destinationDirectoryDriver 

    Write-Host "`nFollow the instructions on the screen to install the driver"

    pnputil.exe /i /a $destinationDirectoryDriver\android_winusb.inf

    # Remove driver directory
    $RemoveDriver = "$PSScriptRoot\latest_usb_driver_windows\" , "$PSScriptRoot\latest_usb_driver_windows.zip" , "$PSScriptRoot\ADBDriver\"
    Remove-Item $RemoveDriver -Recurse -Force
  }
}

DownloadADB


Write-Host "#########################################" -ForegroundColor Red
Write-Host "#            Happy flashing!            #" -ForegroundColor Red
Write-Host "#########################################" -ForegroundColor Red

Pause