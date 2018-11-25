@if not defined _DEBUG echo off
setlocal
set _DIRARGS=/w /l /o /a:-s-h
if defined TOOLS_GIT             if exist "%TOOLS_GIT%"             dir %_DIRARGS% "%TOOLS_GIT%\*.exe"
if defined TOOLS_GNUWINCORETOOLS if exist "%TOOLS_GNUWINCORETOOLS%" dir %_DIRARGS% "%TOOLS_GNUWINCORETOOLS%\*.exe"
if defined TOOLS_SYSINTERNALS    if exist "%TOOLS_SYSINTERNALS%"    dir %_DIRARGS% "%TOOLS_SYSINTERNALS%\*.exe"
if defined TOOLS_VARIOUS         if exist "%TOOLS_VARIOUS%"         dir %_DIRARGS% "%TOOLS_VARIOUS%"
