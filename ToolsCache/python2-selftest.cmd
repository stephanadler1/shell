@if not defined _DEBUG echo off
call python2 --version
echo:
call python2 "%~dp0Scripts\python-selftest.py" %*
