@if not defined _DEBUG echo off
setlocal

if "%~1" equ "" goto :EOF
if not exist "%~1" goto :EOF
if not exist "%~1\notepad++.exe" goto :EOF

call robocopy "%~1" "%~dp0.\ToolsCache\npp" *.* /MIR /XD backup /XF config.xml stylers.model.xml stylers.xml session.xml

pause
