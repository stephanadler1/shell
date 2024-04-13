@if not defined _DEBUG echo off
setlocal

if defined TOOLS_JAVA set "__EXEPATH=%TOOLS_JAVA%"
if defined JAVA_HOME set "__EXEPATH=%JAVA_HOME%\bin"
if defined JRE_HOME set "__EXEPATH=%JRE_HOME%\bin"

set "__EXEPATH=%__EXEPATH%\%~n0.exe"

if not exist "%__EXEPATH%" (
    echo "%~n0" is not installed at "%__EXEPATH%". Abort. 1>&2
    exit /b -1
)

echo:
if /i "%PROMPT:~0,4%" equ "$E[m" (
    if /i "%ConEmuANSI%" equ "ON" (
        echo [93m^> "%__EXEPATH%"[0m
    ) else (
        echo ^> "%__EXEPATH%"
    )
)

echo:
if /i "%~1" equ "/?" (
    call "%__EXEPATH%" "/?"
    exit /b %ERRORLEVEL%
) else (
    call "%__EXEPATH%" %*
    exit /b %ERRORLEVEL%
)

goto :EOF

