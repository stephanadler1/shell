@if "%~1" equ "/?" (call "%~dp0Scripts\msbuild.cmd" "/?") else (call "%~dp0Scripts\msbuild.cmd" /nologo "/consoleloggerparameters:verbosity=minimal;summary" "/terminallogger:true" %* < nul)
