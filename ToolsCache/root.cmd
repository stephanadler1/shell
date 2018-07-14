@if not defined _DEBUG echo off
for /f "usebackq tokens=*" %%o in (`powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\change-directory.ps1" -option root %1`) do (
    if "%%~o" neq "" pushd "%%~o"
)
