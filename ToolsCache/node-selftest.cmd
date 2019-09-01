@if not defined _DEBUG echo off
echo The current Node.js version is
call node --version
echo:

echo The current NPM version is
call npm version
echo:

call node "%~dp0scripts\node-selftest.js"
