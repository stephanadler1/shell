@if "%~1" equ "/?" (call "%~dp0Scripts\msbuild.cmd" "/?") else (call "%~dp0Scripts\msbuild.cmd" /t:rebuild /consoleloggerparameters:verbosity=normal %* < nul)
