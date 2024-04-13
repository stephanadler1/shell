@call Powershell.exe -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0%~n0.ps1"
if errorlevel 1 pause
