@if "%~1" equ "/?" (call "%~dp0Scripts\msbuild.cmd" "/?") else (call "%~dp0Scripts\msbuild.cmd" /nologo /p:Configuration=Release /consoleloggerparameters:verbosity=minimal;summary %* < nul)
