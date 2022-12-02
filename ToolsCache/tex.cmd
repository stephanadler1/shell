@if not defined _DEBUG echo off
setlocal

set "__EDITORPATH=%~dp0MikTeX\texmfs\install\miktex\bin\x64"
set "__EDITORTOOL=miktex-texworks.exe"

set "__FILE=%~f1"
if not exist "%__FILE%" set "__FILE=%~f1.tex"
if not exist "%__FILE%" set "__FILE="

if defined __FILE (
    if exist "%__EDITORPATH%\%__EDITORTOOL%" (
        echo Starting the editor for file "%__FILE%"...
        start /D "%__EDITORPATH%" %__EDITORTOOL% "%__FILE%"
        if errorlevel 1 goto StartConsole
        goto :EOF
    )
)

:StartConsole
echo Starting the MiKTeX console...
call "%~dp0MikTeX\miktex-portable.cmd" %*
