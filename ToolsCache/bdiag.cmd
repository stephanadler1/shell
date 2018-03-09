@call "%~dp0Scripts\msbuild.cmd" /t:rebuild "/pp:%CD%\msb-pp.txt" %* 
@echo.
@call "%~dp0Scripts\msbuild.cmd" /t:rebuild /fileLogger1 "/fileLoggerParameters1:LogFile=%CD%\msb-diag.txt;Verbosity=diagnostic;Encoding=UTF-8" %* 
