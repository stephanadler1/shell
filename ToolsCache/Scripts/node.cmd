set "__NODEPATH=%~dp0..\node-v15.7.0-win-x64"
if defined _DEBUG (call "%__NODEPATH%\nodevars.bat") else (call "%__NODEPATH%\nodevars.bat" > nul 2>&1)
