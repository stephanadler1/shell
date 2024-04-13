@if not defined _DEBUG echo off
if /i "%TreatWarningsAsErrors%" equ "false" set "TreatWarningsAsErrors=" & echo TreatWarningsAsErrors: Default behavior restored. & goto :EOF
if NOT DEFINED TreatWarningsAsErrors set "TreatWarningsAsErrors=false" & echo TreatWarningsAsErrors: Treated as warnings. & goto :EOF
