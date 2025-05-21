@echo off
setlocal
title Firefox Complete Removal Script

:: Step 1: Define paths
set "DOWNLOAD_URL=https://www.nirsoft.net/utils/uninstallview.zip"
set "TOOLS_DIR=C:\Tools"
set "DEST_DIR=%TOOLS_DIR%\UninstallView"
set "ZIP_PATH=%TEMP%\uninstallview.zip"
set "UNINSTALLVIEW_EXE=%DEST_DIR%\UninstallView.exe"

:: Step 2: Create Tools directory
if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

:: Step 3: Download UninstallView
echo [INFO] Downloading UninstallView...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_PATH%'"

if not exist "%ZIP_PATH%" (
    echo [ERROR] Failed to download UninstallView.
    pause
    exit /b 1
)

:: Step 4: Extract UninstallView ZIP
echo [INFO] Extracting UninstallView...
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%DEST_DIR%' -Force"
del "%ZIP_PATH%"

if not exist "%UNINSTALLVIEW_EXE%" (
    echo [ERROR] UninstallView.exe not found after extraction.
    pause
    exit /b 1
)

:: Step 5: Uninstall Mozilla Firefox (all versions)
echo [INFO] Uninstalling all versions of Mozilla Firefox...
C:\Tools\UninstallView\UninstallView.exe /AllowDeleteRegKey 1 /quninstallwildcard "Mozilla Firefox*"

timeout /t 10 >nul

:: Step 6: Remove leftover folders
echo [INFO] Removing leftover files and folders...
rd /s /q "%ProgramFiles%\Mozilla Firefox"
rd /s /q "%ProgramFiles(x86)%\Mozilla Firefox"
rd /s /q "%AppData%\Mozilla"
rd /s /q "%LocalAppData%\Mozilla"

:: Step 7: Remove registry keys
echo [INFO] Cleaning Firefox-related registry entries...
reg delete "HKCU\Software\Mozilla" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Mozilla" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Wow6432Node\Mozilla" /f >nul 2>&1
reg delete "HKCU\Software\MozillaPlugins" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\MozillaPlugins" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Wow6432Node\MozillaPlugins" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox" /f >nul 2>&1

:: Step 8: Remove Start Menu shortcuts
echo [INFO] Removing Start Menu entries...
del /f /q "%AppData%\Microsoft\Windows\Start Menu\Programs\Mozilla Firefox.lnk" >nul 2>&1
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Mozilla Firefox.lnk" >nul 2>&1

echo.
echo  All versions of Mozilla Firefox have been uninstalled and cleaned.
pause
endlocal
