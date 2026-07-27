@echo off
REM One-click Russian localization installer for Fusion 360 (Windows).
REM Thin wrapper: all logic lives in install-windows.ps1, which reliably finds
REM the build Fusion actually runs (via FusionLauncher.exe.ini) and copies the
REM translation there. Safe to run repeatedly. Re-run after every Fusion update.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"
echo.
pause
