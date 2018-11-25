@echo off
if defined MSBUILD_ENABLELOGGING set MSBUILD_ENABLELOGGING=&echo MSBuild logging is off.&goto :EOF
if not defined MSBUILD_ENABLELOGGING set MSBUILD_ENABLELOGGING=1&echo MSBuild logging is on.&goto :EOF
