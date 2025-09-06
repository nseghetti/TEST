@echo off
setlocal

REM Launch PowerShell helper with logs and permissive policy
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run.ps1" -Logs

echo.
echo Press any key to close this window...
pause >nul

