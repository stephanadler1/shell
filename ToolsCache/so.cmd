@call powershell -nologo -noprofile -executionPolicy RemoteSigned -mta -file "%~dp0scripts\open-webpage.ps1" "https://stackoverflow.com/questions/tagged/csharp" %*
