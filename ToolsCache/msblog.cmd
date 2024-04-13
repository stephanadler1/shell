@if not defined _DEBUG echo off
setlocal
rem set "__EXEPATH=%~dp0msbuildlog\app-2.1.174"
set "__EXETOOL=StructuredLogViewer.exe"

set "__OPENFILE=%CD%\%~1"
if not "%~1" equ "" if exist "%~1" set "__OPENFILE=%~1"
if "%~1" equ "" set "__OPENFILE=%CD%\msbuild-log.binlog"
if not exist "%__OPENFILE%" set "__OPENFILE="

for /F %%f in ('dir "%~dp0msbuildlog\app-*" /b /o-n') do (
    set "__EXEPATH=%~dp0msbuildlog\%%f"
    goto Found
)

:Found
if not exist "%__EXEPATH%\%__EXETOOL%" (
    echo "%~n0" is not installed at "%__EXEPATH%\%__EXETOOL%". Abort. 1>&2
    exit /b -1
)

if /i "%~1" equ "/?" (
    call start /d "%__EXEPATH%" %__EXETOOL% /?
) else (
	  tasklist | findstr /ic:"%__EXETOOL%" > nul 2>&1
	  if errorlevel 1 (
        if defined __OPENFILE (
    		    call start /d "%__EXEPATH%" %__EXETOOL% "%__OPENFILE%"
        ) else (
    		    echo *** Please provide a log file to open as the first parameter. 1>&2
            exit /b 1
        )
	  )
)
