@if not defined _DEBUG echo off

:Git
    rem Git needs some more help, first check if it is a git repo, then asked for the root
    git rev-parse > nul 2>&1
    if errorlevel 1 goto Subversion
    for /f %%d in ('git rev-parse --show-cdup') do (
        if "%%~d" neq "" pushd "%%~d" 
        goto EOF 
    )

:Subversion
    svn info . > nul 2>&1
    if errorlevel 1 goto Mercurial
    for /f "delims=" %%d in ('svn info . ^| findstr /C:"Working Copy Root Path:" ') do (
        set _root=%%~d
        pushd "%_root:~24%" 
        goto EOF 
    )

:Mercurial
    rem Mercurial just has it
    hg root > nul 2>&1
    if errorlevel 1 goto CoreXT
    goto EOF

:CoreXT
    if defined INETROOT (
        rem The CoreXT case
        pushd "%INETROOT%"
        goto EOF
    )

echo.

:EOF
