@if not defined _DEBUG echo off
setlocal

call :CompressFolder "%~dp0ToolsCache\Bazel"
call :CompressFolder "%~dp0ToolsCache\Benchmark"
call :CompressFolder "%~dp0ToolsCache\Dig"
call :CompressFolder "%~dp0ToolsCache\glogg"
call :CompressFolder "%~dp0ToolsCache\GnuWin32.CoreTools"
call :CompressFolder "%~dp0ToolsCache\GraphViz"
call :CompressFolder "%~dp0ToolsCache\gvim"
call :CompressFolder "%~dp0ToolsCache\ILSpy"
call :CompressFolder "%~dp0ToolsCache\Java"
call :CompressFolder "%~dp0ToolsCache\jdk-19.0.2"
call :CompressFolder "%~dp0ToolsCache\MiKTeX"
call :CompressFolder "%~dp0ToolsCache\Mimikatz"
call :CompressFolder "%~dp0ToolsCache\NAnt"
call :CompressFolder "%~dp0ToolsCache\NMap"
call :CompressFolder "%~dp0ToolsCache\OpenSSL"
call :CompressFolder "%~dp0ToolsCache\Python"
call :CompressFolder "%~dp0ToolsCache\Python2"
call :CompressFolder "%~dp0ToolsCache\Sysinternals"
call :CompressFolder "%~dp0ToolsCache\Various"
call :CompressFolder "%~dp0ToolsCache\WinRAR"

pause
goto :EOF


:CompressFolder
    echo Compress folder %~1
    if /i "%~1" equ "" goto :EOF
    if not exist "%~1" goto :EOF
    call compact /c "%~1" > nul 2>&1
    pushd "%~1"
    call compact /i /c /s /f *.* > nul 2>&1
    popd
    goto :EOF
