set "__NODEPATH=%~dp0..\node"

rem Node.js and MPM really don't like spaces in path names, therefore try to
rem use the path via the junction that is in the TOOLS environment variable,
rem because %~dp0 is the original path and not the junctioned variant.
if defined TOOLS set "__NODEPATH=%TOOLS%\node"
if defined _DEBUG (call "%__NODEPATH%\nodevars.bat") else (call "%__NODEPATH%\nodevars.bat" > nul 2>&1)
