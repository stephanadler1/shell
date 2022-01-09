@if not defined _DEBUG echo off
setlocal

if not exist "%APPDATA%\Microsoft\Start Menu\Programs\Startup" md "%APPDATA%\Microsoft\Start Menu\Programs\Startup"
call explorer "%APPDATA%\Microsoft\Start Menu\Programs\Startup"
