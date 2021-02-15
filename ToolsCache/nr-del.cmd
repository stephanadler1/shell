@if not defined _DEBUG echo off
call del packages.lock.json /f /s /q
call "%~dp0nr.cmd" %*
