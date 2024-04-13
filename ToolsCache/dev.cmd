@if not defined _DEBUG echo off

if defined _DEV_ENV_INIT (
    (
        echo:
        echo *** This environment was customized for use with the
		echo ***
        echo ***    %_DEV_ENV_INIT%
		echo ***
        echo *** working directory. Switching to a different repository might result in
        echo *** unexpected behavior especially if the PATH environment variable was modified.
    ) 1>&2

    pushd "%_DEV_ENV_INIT%"

    goto :EOF
)

for /f "usebackq tokens=*" %%o in (`powershell -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0scripts\change-directory.ps1" -option dev %1`) do (
    if "%%~o" neq "" (

        call :ResetCorextEnvVars

        pushd "%%~o"

        call :SetTitle "%%~o"

        if exist ".\sd.ini" (
            if exist ".\init.cmd" (

                call :InitCorext

            ) else (
                (
                    echo:
                    echo *** This is a Source Depot enlistment. It might not work as expected.
                    echo *** Source Depot enlistments usually require an init script to be executed.
                ) 1>&2
            )

            call :SetCorextEnvVars
        )

        if exist ".\.corext\corextboot.exe" (
            if exist ".\init.cmd" (

                call :InitCorext

            ) else (
                (
                    echo:
                    echo *** This is a CoReXT based enlistment. It might not work as expected.
                    echo *** CoReXT based enlistments usually require an init script to be executed.
                ) 1>&2
            )

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

:InitCorext
    set "_DEV_ENV_INIT=%CD%"
    call "%CD%\init.cmd"
    goto :EOF

:ResetCorextEnvVars
    set "INETROOT="
    set "SDPORT="
    set "SDCLIENT="
    set "SDROOT="
    set "_DEV_ENV_INIT="
    goto :EOF

:PrintRepositoryInformation
    if exist ".\.git" (
        setlocal enabledelayedexpansion

        echo:
        set "_USEREMAIL=NOT SET"
        set "_USERNAME=NOT SET"
        for /f "usebackq tokens=*" %%o in (`call git config user.email`) do (set "_USEREMAIL=%%o")
        for /f "usebackq tokens=*" %%o in (`call git config user.name`) do (set "_USERNAME=%%o")
        echo CURRENT USER: !_USERNAME! ^<!_USEREMAIL!^>

        set "_first=1"
        for /f "usebackq tokens=1,*" %%o in (`call git config --show-scope --get-regexp alias. ^| sort ^| findstr "^local"`) do (
            if defined _first (
                echo:
                echo LOCAL ALIASES:&set "_first="
            )

            echo %%p
        )

        echo:
        call git status -b -s
        endlocal
        goto :EOF
    )

    if exist ".\.svn" (
        echo:
        call svn info .
        echo:
        call svn status .
        goto :EOF
    )

    if exist ".\.hg" (
        setlocal enabledelayedexpansion

        echo:
        set "_USERNAME=NOT SET <EMAIL>"
        for /f "usebackq tokens=*" %%o in (`call hg config ui.username`) do (set "_USERNAME=%%o")
        echo CURRENT USER: !_USERNAME!

        echo:
        call hg summary
        echo:
        call hg status
        endlocal
        goto :EOF
    )
