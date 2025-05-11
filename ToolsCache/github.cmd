@if defined TOOLS_URL_GITHUB call "%TOOLS_PS%" -nologo -noprofile -executionPolicy RemoteSigned -mta -file "%~dp0scripts\open-webpage.ps1" "%TOOLS_URL_GITHUB%" %*
