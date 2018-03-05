@if not defined _DEBUG echo off
if /i "%~1" equ "" (
    call explorer "%CD%"
) else (
    call explorer "%~1"
)