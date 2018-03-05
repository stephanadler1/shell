@if not defined _DEBUG echo off

:: -----------------------------------------------------------------------
:: <copyright file="initdev.cmd" company="Stephan Adler">
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

set _WORKINGDIR=%CD%

for %%v in ("Microsoft Visual Studio\2017" "Microsoft Visual Studio 14.0" "Microsoft Visual Studio 12.0" "Microsoft Visual Studio 11.0") do (
    for %%e in (Enterprise Community .) do (
        if exist "%ProgramFiles(x86)%\%%~v\%%~e\Common7\Tools\VsDevCmd.bat" (
            echo Initializing developer command prompt %%~v...
            echo.
            call "%ProgramFiles(x86)%\%%~v\%%~e\Common7\Tools\VsDevCmd.bat"
            echo.
            goto LoadAliases
        ) 
    )
)
echo No developer command prompt found.
echo.

:LoadAliases
if exist "%~dp0%~n0.doskey.alias.txt" doskey /MACROFILE="%~dp0%~n0.doskey.alias.txt"
if exist "%~dp0%~n0.doskey.powershell.txt" doskey /MACROFILE="%~dp0%~n0.doskey.powershell.txt"

echo COMMAND SHELL ALIASES
echo ---------------------
doskey /macros | sort
echo.
if "%TOOLS%" neq "" echo GLOBAL TOOLS && echo ------------ && dir /w "%TOOLS%\*.cmd"

echo.
if "%TOOLS_GIT%" neq "" echo GLOBAL GIT ALIASES && echo ------------------ && git config --global --get-regexp alias. | sort


title Developer Shell
pushd "%_WORKINGDIR%"
set _WORKINGDIR=

:SetCommandPrompt
if /i "%CONEMUANSI%" equ "ON" (
    set PROMPT=$E[m$E[32m$T$S$E[92m$P$E[90m$_$E[90m$G$E[m$S$E]9;12$E\
)


:YourScript
if "%~1" neq "" (
    echo call "%~1"
    if exist "%~1" call "%~1"
)