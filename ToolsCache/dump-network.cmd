@if not defined _DEBUG echo off
setlocal

set "_OUTFILE=%USERPROFILE%\Desktop\Netwroking-%COMPUTERNAME%.txt"

(
    echo Started %DATE% %TIME%
    echo:
) > "%_OUTFILE%"

call ipconfig /all >> "%_OUTFILE%"

(
    echo:
    echo Ended %DATE% %TIME%
) >> "%_OUTFILE%"

call start "" "%_OUTFILE%"
