@if defined TOOLS_URL_VSO call powershell -nologo -noprofile -executionPolicy RemoteSigned -mta -file "%~dp0scripts\open-webpage.ps1" "%TOOLS_URL_VSO%" %*
