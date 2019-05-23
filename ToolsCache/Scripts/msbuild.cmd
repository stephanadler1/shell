@call Powershell.exe -nologo -noprofile -executionPolicy RemoteSigned -outputFormat Text -mta -file "%~dp0msbuild.ps1" "%*" "%CD%" -prefer64Bit -lowerPriority
