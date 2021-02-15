@if not defined _DEBUG echo off
for /f "usebackq tokens=*" %%o in (`powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\change-directory.ps1" -option dev %1`) do (
    if "%%~o" neq "" (

        pushd "%%~o"

        call :SetTitle "%%~o"

        if exist ".\sd.ini" (
            echo:
            echo *** This is a Source Depot enlistment. It might not work as expected.
            echo *** Source Depot enlistments usually require an init script to be executed.

            call :SetCorextEnvVars
        )

        if exist ".\.corext\corextboot.exe" (
            echo:
            echo *** This is a CoReXT based enlistment. It might not work as expected.
            echo *** CoReXT based enlistments usually require an init script to be executed.

            call :SetCorextEnvVars
        )
    )
)

goto :EOF

:SetTitle
    if /i "%~1" neq "" (title %~nx1 - Developer Shell)
    goto :EOF

:SetCorextEnvVars
    set "INETROOT=%CD%"

    goto :EOF
