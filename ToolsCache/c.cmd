@if not defined _DEBUG echo off
set "__CHANGEDIRTO="
if "%~1" neq "" for /f "usebackq tokens=*" %%o in (`@call powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0Scripts\change-directory.ps1" -option shortcut -relativePath "%~1" -subfolder "%~2"`) do set "__CHANGEDIRTO=%%~o"
if "%~1" equ "" call powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0Scripts\change-directory.ps1" -option shortcut
if not defined __CHANGEDIRTO goto end
if not exist "%__CHANGEDIRTO%" goto end
pushd "%__CHANGEDIRTO%"

:end
set "__CHANGEDIRTO="
