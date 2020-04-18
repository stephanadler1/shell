@if not defined _DEBUG echo off
setlocal
set _DIRARGS=/d /l /o /a:-s-h-d
if defined TOOLS                 if exist "%TOOLS%"                 echo: & dir %_DIRARGS% "%TOOLS%\*.*"
if defined TOOLS_GIT             if exist "%TOOLS_GIT%"             echo: & dir %_DIRARGS% "%TOOLS_GIT%\*.exe"
if defined TOOLS_GIT             if exist "%TOOLS_GIT%"             echo: & call git config --global --get-regexp alias. | sort
if defined TOOLS_GNUWINCORETOOLS if exist "%TOOLS_GNUWINCORETOOLS%" echo: & dir %_DIRARGS% "%TOOLS_GNUWINCORETOOLS%\*.exe"
if defined TOOLS_SYSINTERNALS    if exist "%TOOLS_SYSINTERNALS%"    echo: & dir %_DIRARGS% "%TOOLS_SYSINTERNALS%\*.exe"
if defined TOOLS_VARIOUS         if exist "%TOOLS_VARIOUS%"         echo: & dir %_DIRARGS% "%TOOLS_VARIOUS%"
