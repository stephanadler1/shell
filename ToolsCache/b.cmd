@if "%~1" equ "/?" (call "%~dp0Scripts\msbuild.cmd" "/?") else (call "%~dp0Scripts\msbuild.cmd" /consoleloggerparameters:verbosity=normal %* < nul)
