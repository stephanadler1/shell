@if not defined _DEBUG echo off
for /f "usebackq tokens=*" %%o in (`powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\change-directory.ps1" -option self -relativePath "%~1"`) do (
    if "%%~o" neq "" pushd "%%~o"
)