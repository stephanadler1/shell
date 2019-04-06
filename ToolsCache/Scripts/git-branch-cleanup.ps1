Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
} 




$list = & git @('branch', '-l', '--format', '%(refname:lstrip=2)')
$list | ForEach-Object { if ($_ -ne 'master') { $branch = $_; Write-Host "Removing branch '$branch'"; & git @('push', 'origin', '--delete', $branch); & git @('branch', '-D', $branch); Write-Host '.';} }

& git @('remote', 'prune', 'origin')
& git @('gc')

