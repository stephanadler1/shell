@echo off
if defined MSBUILD_DISABLEISOLATION set "MSBUILD_DISABLEISOLATION="&echo MSBuild build isolation is on.&goto :EOF
if not defined MSBUILD_DISABLEISOLATION set "MSBUILD_DISABLEISOLATION=1"&echo MSBuild build isolation is off.&goto :EOF
