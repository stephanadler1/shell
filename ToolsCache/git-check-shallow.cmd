@if not defined _DEBUG echo off

echo:
echo Is the Git repository a shallow clone?
call g rev-parse --is-shallow-repository

echo:
echo You can unshallow the clone with
echo   git fetch --unshallow
