set "__NODEPATH=%~dp0..\node-v10.16.3-win-x64"
if defined _DEBUG (call "%__NODEPATH%\nodevars.bat") else (call "%__NODEPATH%\nodevars.bat" > nul 2>&1)