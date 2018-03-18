@if not defined _DEBUG echo off

:: Opens the tools directory in the Visual Studio Code (VS Code) editor. If VS Code is not installed, 
:: it changes the current directory to it instead.

where code > nul 2>&1
if errorlevel 1 (
    pushd "%~dp0"
    exit /b 1
)

call code "%~dp0.."