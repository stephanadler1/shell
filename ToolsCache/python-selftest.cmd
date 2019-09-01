@if not defined _DEBUG echo off
call python --version
echo:
call python "%~dp0Scripts\%~n0.py" %*
