@echo off
REM One-time setup: creates a Desktop shortcut that runs install-windows.bat.
REM After that, restoring Russian after a Fusion update is a single double-click.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0create-shortcut-windows.ps1"
pause
