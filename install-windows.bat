@echo off
REM Install / restore Russian localization into Fusion 360 (Windows)
REM One-click, universal: always targets the ACTIVE build and re-applies files.
REM Safe to run any number of times (idempotent). Re-run it after every Fusion update.
REM Sources: .\files\ru-RU, .\files\ru-html, .\files\russian_ru.xml

setlocal enabledelayedexpansion
chcp 65001 >nul

set "SCRIPT_DIR=%~dp0"
set "FILES=%SCRIPT_DIR%files"
set "WEBDEPLOY=%LOCALAPPDATA%\Autodesk\webdeploy\production"

echo.
echo ==========================================
echo  Fusion 360 Russian Localization Installer
echo ==========================================
echo.

REM 1) Sanity checks
if not exist "%FILES%\ru-RU" (
  echo [ERROR] Missing translation files: %FILES%
  echo Run this .bat from the repo root ^(the folder that contains "files"^).
  pause
  exit /b 1
)

if not exist "%WEBDEPLOY%" (
  echo [ERROR] Fusion 360 install not found:
  echo     %WEBDEPLOY%
  echo Install Fusion from https://www.autodesk.com/products/fusion-360 first.
  pause
  exit /b 1
)

REM Check if Fusion is running
tasklist /FI "IMAGENAME eq Fusion360.exe" 2>nul | find /I "Fusion360.exe" >nul
if not errorlevel 1 (
  echo [ERROR] Fusion 360 is running. Close it completely and re-run this installer.
  pause
  exit /b 1
)

REM 2) Find the ACTIVE webdeploy build directory.
REM    The active build is the one Fusion actually runs from: it has BOTH
REM    Fusion360.exe AND a StringTable folder. A folder with StringTable but
REM    no Fusion360.exe is a stale/partial build - copying there does nothing.
REM    Directories are scanned newest-first, so the current build wins.
set "HASH_DIR="
set "HASH="
for /f "delims=" %%D in ('dir /b /ad /o-d "%WEBDEPLOY%" 2^>nul') do (
  if not defined HASH_DIR (
    if exist "%WEBDEPLOY%\%%D\Fusion360.exe" (
      if exist "%WEBDEPLOY%\%%D\StringTable" (
        set "HASH_DIR=%WEBDEPLOY%\%%D"
        set "HASH=%%D"
      )
    )
  )
)

if not defined HASH_DIR (
  echo [ERROR] Could not find an active Fusion build inside:
  echo     %WEBDEPLOY%
  echo No folder there has both Fusion360.exe and StringTable.
  echo Launch Fusion once so it finishes installing/updating, then re-run this.
  pause
  exit /b 1
)

echo Active Fusion build: %HASH%
echo Install root:        %HASH_DIR%

REM Report whether Russian is already present (fresh install vs refresh)
if exist "%HASH_DIR%\StringTable\ru-RU" (
  echo Status:              ru-RU already present - refreshing it.
) else (
  echo Status:              ru-RU not found in this build - installing it.
)
echo.

REM 3) Copy ru-RU into StringTable
echo [1/3] Copying ru-RU into StringTable...
xcopy /E /I /Y /Q "%FILES%\ru-RU" "%HASH_DIR%\StringTable\ru-RU" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy ru-RU. Try running as Administrator.
  pause
  exit /b 1
)

REM 4) Copy ru-html into Help (create the parent path if the build lacks it)
echo [2/3] Copying ru-html into NeuCAM Help...
if not exist "%HASH_DIR%\NeuCAM\UI\NeuCAMUI\Resources\Help" mkdir "%HASH_DIR%\NeuCAM\UI\NeuCAMUI\Resources\Help" 2>nul
xcopy /E /I /Y /Q "%FILES%\ru-html" "%HASH_DIR%\NeuCAM\UI\NeuCAMUI\Resources\Help\ru-html" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy ru-html.
  pause
  exit /b 1
)

REM 5) Copy russian_ru.xml into Translations (create the parent path if missing)
echo [3/3] Copying russian_ru.xml into Translations...
if not exist "%HASH_DIR%\Applications\CAM360\Data\Translations" mkdir "%HASH_DIR%\Applications\CAM360\Data\Translations" 2>nul
copy /Y "%FILES%\russian_ru.xml" "%HASH_DIR%\Applications\CAM360\Data\Translations\" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy russian_ru.xml.
  pause
  exit /b 1
)

REM 6) Verify: count the installed ru-RU XML files (expected 115)
set /a RUCOUNT=0
for %%F in ("%HASH_DIR%\StringTable\ru-RU\*.xml") do set /a RUCOUNT+=1

echo.
echo ==========================================
if %RUCOUNT% GEQ 100 (
  echo  Done. Russian installed - %RUCOUNT% UI files in place.
) else (
  echo  [WARNING] Only %RUCOUNT% ru-RU files found - expected ~115.
  echo  Something may have gone wrong; check the messages above.
)
echo ==========================================
echo.
echo Now launch Fusion 360 and go to:
echo     Preferences ^(Ctrl+,^) ^> General ^> User Language ^> Russian
echo Then confirm the restart prompt.
echo.
pause
