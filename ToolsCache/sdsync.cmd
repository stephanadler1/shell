@if not defined _DEBUG echo off
if not defined INETROOT goto Check2
if exist "%INETROOT%\sd.ini" goto SourceDepot

:Check2
echo Error: Not a SourceDepot enlistment window.
goto EOF

:SourceDepot
call sd sync -w
call sd resolve -am
goto EOF

:EOF
