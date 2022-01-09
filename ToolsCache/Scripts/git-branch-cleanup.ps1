# -----------------------------------------------------------------------
# <copyright file="git-branch-cleanup.ps1" company="Stephan Adler">
# Copyright (c) Stephan Adler. All Rights Reserved.
# </copyright>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------

<#
.SYNOPSIS
Cleaning up local Git branches that are no longer used.

.DESCRIPTION
Cleaning up local Git branches that are no longer needed. It is determined as the remote tracking branch
being missing, which usually happens when a pull request is accepted and the remote branch is being removed
automatically.
#>

[CmdletBinding()]
param(
    # Force the deletion of the not fully merged branch. Uses git branch -D!
    [Parameter(Mandatory = $false)]
    [Alias("force")]
    [switch] $forceBranchDelete = $false,

    # Run GIT GC to cleanup dangling nodes
    [Parameter(Mandatory = $false)]
    [Alias("gc")]
    [switch] $garbageCollection = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not ([System.String]::IsNullOrWhitespace($env:_DEBUG)))
{
    $DebugPreference = 'Continue'
    Write-Debug "PSVersion = $($PSVersionTable.PSVersion); PSEdition = $($PSVersionTable.PSEdition); ExecutionPolicy = $(Get-ExecutionPolicy)"
}

$branchDeleteArg = '-d'
if ($forceBranchDelete) {
    $branchDeleteArg = '-D'
}

$localBranches = & git @('branch', '-l', '--format', '%(refname:lstrip=2)')
$localBranches |  Write-Debug

$remoteBranches = & git @('branch', '-r', '--format', '%(refname:lstrip=2)')
$remoteBranches | Write-Debug

$removedBranch = $false

$localBranches | ForEach-Object {
    if ($_ -ne 'master') {
        $branch = $_

        if (-not ([System.Array]::Exists($remoteBranches, [System.Predicate[System.String]]{ $args[0] -eq "origin/$branch" })))
        {
            Write-Host "Removing local branch '$branch', since its not tracking a remote..."
            & git @('branch', $branchDeleteArg, $branch);
            Write-Host

            $removedBranch = $true
        }
    }
}

#$list | ForEach-Object { if ($_ -ne 'master') { $branch = $_; Write-Host "Removing branch '$branch'"; & git @('push', 'origin', '--delete', $branch); & git @('branch', '-D', $branch); Write-Host '.';} }

if ($removedBranch)
{
    Write-Host 'Repositoriy maintenance...'
    & git @('remote', 'prune', 'origin')

    if ($garbageCollection)
    {
        & git @('gc')
    }
}
