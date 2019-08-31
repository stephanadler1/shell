@if not defined _DEBUG echo off
set "__CHANGEDIRTO="
if "%~1" neq "" for /f "usebackq tokens=*" %%o in (`@call powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0Scripts\change-directory.ps1" -option shortcut -relativePath "%~1"`) do set "__CHANGEDIRTO=%%~o"
if "%~1" equ "" call powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0Scripts\change-directory.ps1" -option shortcut
if defined __CHANGEDIRTO pushd "%__CHANGEDIRTO%"
set __CHANGEDIRTO=
