@if not defined _DEBUG echo off
for /f "usebackq tokens=*" %%o in (`powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\change-directory.ps1" -option dev %1`) do (
    if "%%~o" neq "" (pushd "%%~o" & call :SetTitle "%%~o")
)

exit /b 0

:SetTitle
    if /i "%~1" neq "" (title %~nx1 - Developer Shell)
    exit /b 0