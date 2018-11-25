@if not defined _DEBUG echo off

for %%p in ("%LOCALAPPDATA%\Programs\Microsoft VS Code Insiders\bin\" "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\" "%ProgramFiles%\Microsoft VS Code\bin\" "%ProgramFiles(x86)%\Microsoft VS Code\bin\") do (
    for %%a in (code-insiders.cmd code.cmd) do (
        if exist "%%~p%%~a" (
            call "%%~p%%~a" %*
			exit /b %ERRORLEVEL%
        ) 
    )
)

echo Visual Studio Code is not installed in any of its default locations.
exit /b 1
