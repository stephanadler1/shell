@echo off
echo:
call type "%~dp0scripts\ascii\%~n0.txt"
call status yellow > nul 2>&1
