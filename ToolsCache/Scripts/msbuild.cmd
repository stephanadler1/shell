@if not defined _DEBUG echo off

:: -----------------------------------------------------------------------
:: <copyright file="msbuild.cmd" company="Stephan Adler">
:: Copyright (c) Stephan Adler. All Rights Reserved.
:: </copyright>
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
:: 
::     http://www.apache.org/licenses/LICENSE-2.0
:: 
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
:: -----------------------------------------------------------------------

setlocal enabledelayedexpansion

:: Calculate parallelism
set /A _cpu=!NUMBER_OF_PROCESSORS! * !NUMBER_OF_PROCESSORS!

:: Set default application location
if defined MSBUILD set _MSBUILD=%MSBUILD%
if not defined _MSBUILD (
    call :SetTool msbuild.cmd _MSBUILD
)
if not defined _MSBUILD (
    call :SetTool msbuild.exe _MSBUILD
)

if not defined _MSBUILD goto ErrorMsBuildNotFound
if not exist "!_MSBUILD!" goto ErrorMsBuildNotFound

:: Set PATH to nothing, to detect poorly written build scripts, assuming tools to 
:: be accessible on the system, instead of relying on packages to provide them.
if not defined MSBUILD_DISABLEISOLATION call :SetupIsolation

echo.
echo Started !DATE! !TIME!

:: Set default arguments
set _MSBUILD_ARGS=/m:!_cpu! /nr:false

echo ^> "!_MSBUILD!" !_MSBUILD_ARGS! !MSBUILD_ARGS! %*
echo. 
call "!_MSBUILD!" !_MSBUILD_ARGS! !MSBUILD_ARGS! %*

:: Kill all still running instances of MSBuild
call "%TOOLS_SYSINTERNALS%\pskill.exe" -accepteula -t msbuild > nul 2>&1

if not defined MSBUILD_DISABLEISOLATION call :ReportIsolation

exit /b 0


:SetTool
    set %~2=%~f$PATH:1
    exit /b 0


:ErrorMsBuildNotFound
    echo.
    echo *** FATAL *** - MSBUILD.EXE was not found on the system. Cannot build.
    echo.
    exit /b 1

:AppendToolPath
    if defined PATH (set "PATH=%PATH%;%~dp1." ) else (set "PATH=%~dp1." )
    exit /b 0
    
:SetupIsolation
    set _TEMP=%TEMP%\wtf
    set _PATH=%_TEMP%\VGhpc0lz
    rem if exist "!_TEMP!" rd /s /q "!_TEMP!" > nul 2>&1
    if exist "%_TEMP%" rd /s /q "%_TEMP%" > nul 2>&1
    md "%_TEMP%" > nul 2>&1
    md "%_PATH%" > nul 2>&1

    rem PATH needs to be set to something. Some applications will through an exception otherwise.
    set PATH=%_PATH%
    rem set PATH=!PATH!;%SYSTEMROOT%\System32;%SYSTEMROOT%
    rem call :AppendToolPath "%_MSBUILD%"
    set TEMP=%_TEMP%
    set TMP=%_TEMP%
    set INCLUDE=%_PATH%
    set LIB=%_PATH%
    
    echo.
    echo *** BUILD ISOLATION ACTIVE ***
    echo To disable isolation mode, set MSBUILD_DISABLEISOLATION=1
    echo PATH     = !PATH!
    echo TEMP/TMP = !TEMP!
    echo INCLUDE  = !INCLUDE!
    echo LIB      = !LIB!
    echo ******************************
    exit /b 0
    
:ReportIsolation
    rem Check if there are any files in the TEMP location
    dir /b /s /a:-d "!_TEMP!" > nul 2>&1
    if errorlevel 1 exit /b 0

    rem There are really files there, let's enumerate them
    dir /b /s /a:-d "!_TEMP!" | "%WINDIR%\System32\findstr.exe" /i /r "^\S*" > nul 2>&1
    if errorlevel 1 echo.
    if errorlevel 0 (
        echo Ended !DATE! !TIME!
        echo.
        echo *** FILES WRITTEN OUTSIDE OF BUILD OUTPUT ***
        echo dir /b /s /a:-d "!_TEMP!"
        echo *********************************************
        echo.
    )
    exit /b 0

:EOF
    echo Ended !DATE! !TIME!
    exit /b 0

