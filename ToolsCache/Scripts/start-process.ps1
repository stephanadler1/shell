
[string] $script:msbuildTool = "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"

$script:args = ''

# Defining the priority class for the MSBuild process
[System.Diagnostics.ProcessPriorityClass] $script:priorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal
#if ($lowerPriority)
{
    $priorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
}
$priorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal



[System.Diagnostics.Process] $process = New-Object -TypeName 'System.Diagnostics.Process'
[int] $msbuildExitCode = 1

$startInfo = $process.StartInfo
$startInfo.CreateNoWindow = $false
$startInfo.FileName = $msbuildTool
$startInfo.UseShellExecute = $false
$startInfo.Arguments = $args
$startInfo.WorkingDirectory = $currentDirectory
$startInfo.LoadUserProfile = $false

Write-Host
Write-Host "> `"$msbuildTool`" $args" -ForegroundColor Yellow
Write-Host

$started = $process.Start()
if ($started)
{
    $process.PriorityClass = $priorityClass
    $process.WaitForExit()
    $msbuildExitCode = $process.ExitCode
}

$process.Dispose()

$host.SetShouldExit($msbuildExitCode)
[System.Environment]::Exit($msbuildExitCode)
exit $msbuildExitCode
