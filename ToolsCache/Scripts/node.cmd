set "__NODEPATH=%~dp0..\node-v14.4.0-win-x64"
if defined _DEBUG (call "%__NODEPATH%\nodevars.bat") else (call "%__NODEPATH%\nodevars.bat" > nul 2>&1)