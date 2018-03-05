@if not defined _DEBUG echo off
set __CHANGEDIRTO=
for /f "usebackq tokens=*" %%o in (`@powershell -executionpolicy bypass -nologo -file "%~dp0Scripts\change-directory.ps1" "%CD%" "%~1"`) do set "__CHANGEDIRTO=%%~o"
if defined __CHANGEDIRTO pushd "%__CHANGEDIRTO%"
set __CHANGEDIRTO=
