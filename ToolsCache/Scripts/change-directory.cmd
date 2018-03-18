@if not defined _DEBUG echo off
for /f "usebackq tokens=*" %%o in (`powershell -nologo -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0change-directory.ps1" -option dev -relativePath "%~1"`) do (
    if "%%~o" neq "" pushd "%%~o"
)
