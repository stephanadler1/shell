@if not defined _DEBUG echo off
for /f "usebackq tokens=*" %%o in (`powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\change-directory.ps1" -option dev %1`) do (
    if "%%~o" neq "" (

        call :ResetCorextEnvVars

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

        call :PrintRepositoryInformation
    )
)

goto :EOF

:SetTitle
    if /i "%~1" neq "" (title %~nx1 - Developer Shell)
    goto :EOF

:SetCorextEnvVars
    set "INETROOT=%CD%"
    goto :EOF

:ResetCorextEnvVars
    set "INETROOT="
    goto :EOF

:PrintRepositoryInformation
    if exist ".\.git" (
        setlocal enabledelayedexpansion

        echo:
        for /f "usebackq tokens=*" %%o in (`git config user.email`) do (set "_USEREMAIL=%%o")
        for /f "usebackq tokens=*" %%o in (`git config user.name`) do (set "_USERNAME=%%o")
        echo CURRENT USER: !_USERNAME! ^<!_USEREMAIL!^>

        set "_first=1"
        for /f "usebackq tokens=1,*" %%o in (`git config --show-scope --get-regexp alias. ^| sort ^| findstr "^local"`) do (
            if defined _first (
                echo:
                echo LOCAL ALIASES:&set "_first="
            )

            echo %%p
        )

        echo:
        git status -b -s
        endlocal
        goto :EOF
    )

    if exist ".\.svn" (
        echo:
        svn info .
        echo:
        svn status .
        goto :EOF
    )
