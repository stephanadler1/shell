@echo off
if defined _DEBUG set _DEBUG=&echo Debug logging is off.&goto :EOF
if not defined _DEBUG set _DEBUG=1&echo Debug logging is on.&goto :EOF
