@if not defined _DEBUG echo off
setlocal

set _TARGETDIR=%~dp0ToolsCache\Nuget

call "%_TARGETDIR%\nuget.exe" update -self

pause
