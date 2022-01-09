@if not defined _DEBUG echo off
setlocal

if /i "%~1" equ "" exit /b 1
if not exist "%~1" exit /b 1

call exiftool -all:all= -overwrite_original_in_place -r "%~1"
call exiftool "%~1"
