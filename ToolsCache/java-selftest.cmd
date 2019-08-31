@if not defined _DEBUG echo off
call java -version
call java "%~dp0Scripts\%~n0.java" %*
