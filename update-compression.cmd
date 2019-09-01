@if not defined _DEBUG echo off
setlocal

call :CompressFolder "%~dp0ToolsCache\Dig"
call :CompressFolder "%~dp0ToolsCache\GnuWin32.CoreTools"
call :CompressFolder "%~dp0ToolsCache\GraphViz"
call :CompressFolder "%~dp0ToolsCache\gvim_8.1.1436_x64"
call :CompressFolder "%~dp0ToolsCache\ILSpy"
call :CompressFolder "%~dp0ToolsCache\Java"
call :CompressFolder "%~dp0ToolsCache\NAnt"
call :CompressFolder "%~dp0ToolsCache\NMap"
call :CompressFolder "%~dp0ToolsCache\OpenSSL"
call :CompressFolder "%~dp0ToolsCache\Python.3.7.3"
call :CompressFolder "%~dp0ToolsCache\Sysinternals"
call :CompressFolder "%~dp0ToolsCache\Various"
call :CompressFolder "%~dp0ToolsCache\WinRAR"

pause
goto :EOF


:CompressFolder
    echo Compress folder %~1
    if /i "%~1" equ "" goto :EOF
    if not exist "%~1" goto :EOF
    compact /c "%~1" > nul 2>&1
    pushd "%~1"
    compact /i /c /s /f *.* > nul 2>&1
    popd
    goto :EOF
