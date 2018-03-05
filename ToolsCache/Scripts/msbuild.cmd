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
if not exist "%_MSBUILD%" goto ErrorMsBuildNotFound

echo.
echo Started !DATE! !TIME!

:: Set default arguments
set _MSBUILD_ARGS=/m:!_cpu! /nr:false

echo ^> "%_MSBUILD%" %_MSBUILD_ARGS% %MSBUILD_ARGS% %*
echo. 
call "%_MSBUILD%" %_MSBUILD_ARGS% %MSBUILD_ARGS% %*

:: Kill all still running instances of MSBuild
pskill -accepteula -t msbuild > nul 2>&1

goto EOF


:SetTool
    set %~2=%~f$PATH:1
    goto :EOF


:ErrorMsBuildNotFound
    echo.
    echo *** FATAL *** - MSBUILD.EXE was not found on the system. Cannot build.
    echo.
    exit /b 1
    goto EOF



:EOF
    echo Ended !DATE! !TIME!
    exit /b 0

