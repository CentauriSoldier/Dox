@echo off
setlocal
where node >nul 2>nul
if errorlevel 1 (
  echo Node is required for the optional local server. Open docs\Examples.html directly instead.
  pause
  exit /b 1
)
node "%~dp0api\workbench\server.cjs" --open
if errorlevel 1 pause
