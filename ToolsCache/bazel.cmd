@if "%~1" equ "/?" (call "%~dp0%~n0\%~n0.exe" "/?") else (call "%~dp0%~n0\%~n0.exe" %* < nul)
