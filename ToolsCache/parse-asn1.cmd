@if not defined _DEBUG echo off
setlocal

set "_FILE=%~1"
if exist "%_FILE%" goto Parse

set "_TEMPFILE=%TEMP%\%RANDOM%.txt"
set "_FILE=%_TEMPFILE%"
if defined _DEBUG echo Created temp. file "%_TEMPFILE%"

(
    echo %~1
) > "%_TEMPFILE%"

if defined _DEBUG call more "%_TEMPFILE%"


:Parse
echo.
echo Try with OpenSSL:
call "%~dp0openssl.cmd" asn1parse -i -dump -in "%_FILE%"

echo.
echo Try with CertUtil:
call "certutil.exe" -gmt -asn "%_FILE%"

if defined _TEMPFILE call del /f /q "%_TEMPFILE%"
