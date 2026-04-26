@echo off
REM Install Russian localization into Fusion 360 (Windows)
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
  echo Run this .bat from the repo root.
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

REM 2) Find the active webdeploy hash directory (most recently modified)
set "HASH_DIR="
for /f "delims=" %%D in ('dir /b /ad /o-d "%WEBDEPLOY%" 2^>nul') do (
  if not defined HASH_DIR (
    REM Pick first dir that looks like a 40-char hex hash AND has StringTable subfolder
    if exist "%WEBDEPLOY%\%%D\StringTable" (
      set "HASH_DIR=%WEBDEPLOY%\%%D"
      set "HASH=%%D"
    )
  )
)

if not defined HASH_DIR (
  echo [ERROR] Could not find Fusion build directory inside %WEBDEPLOY%
  pause
  exit /b 1
)

echo Fusion build: %HASH%
echo Install root: %HASH_DIR%
echo.

REM 3) Copy ru-RU into StringTable
echo [1/3] Copying ru-RU into StringTable...
xcopy /E /I /Y /Q "%FILES%\ru-RU" "%HASH_DIR%\StringTable\ru-RU" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy ru-RU. Try running as Administrator.
  pause
  exit /b 1
)

REM 4) Copy ru-html into Help
echo [2/3] Copying ru-html into NeuCAM Help...
xcopy /E /I /Y /Q "%FILES%\ru-html" "%HASH_DIR%\NeuCAM\UI\NeuCAMUI\Resources\Help\ru-html" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy ru-html.
  pause
  exit /b 1
)

REM 5) Copy russian_ru.xml into Translations
echo [3/3] Copying russian_ru.xml into Translations...
copy /Y "%FILES%\russian_ru.xml" "%HASH_DIR%\Applications\CAM360\Data\Translations\" >nul
if errorlevel 1 (
  echo [ERROR] Failed to copy russian_ru.xml.
  pause
  exit /b 1
)

echo.
echo ==========================================
echo  Done! Russian files installed.
echo ==========================================
echo.
echo Now launch Fusion 360 and go to:
echo     Preferences ^(Ctrl+,^) ^> General ^> User Language ^> Russian
echo Then confirm the restart prompt.
echo.
pause
