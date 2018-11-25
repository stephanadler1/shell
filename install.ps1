# -----------------------------------------------------------------------
# <copyright file="install.ps1" company="Stephan Adler">
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
This script configures the host operating system usable for me (Stephan Adler).

.DESCRIPTION
The script configures the host operating system in a way that makes it consistent across all
my computers. It assumes that the system is partitioned into 2 drives/partitions:

* C:\ ($env:SYSTEMDRIVE) - the operating system drive
* D:\ ($dataDrive)       - the data drive

Instead of letting the script discover the $dataDrive, it can be provided as an input parameter to the script.

The following DESKTOP SHORTCUTS are being created

* Command Shell - The ConEmu version of the cmd.exe default shell.
* Developer Shell - The ConEmu version of the Visual Studio Developer Command Line.
* Developer Shell (PS) - The ConEmu PowerShell enabled Developer Shell (not quite ready yet!)
* PowerShell Shell - The ConEmu version of the Windows PowerShell.

The following FOLDERS are being created

* $dataDrive\dev                 - folder containing source code ($sourceCodeFolder)
* $dataDrive\packages\nuget      - the local NuGet package cache folder ($nugetCacheDirectory)
* $dataDrive\Symbols             - is setup as the cache folder for debug symbols ($symbolCacheDirectory)
* $dataDrive\users               - secondary folder for user profile data ($secondaryUsersFolder)
* $dataDrive\users\$env:USERNAME - the secondary $env:USERPROFILE folder for the current user, including ACL'ing consistent with $env:USERPROFILE ($secondaryUserFolder).

The following TOOLS are being installed into the $env:PATH and their own environment variables starting with TOOLS_*.

* Converts the user's $env:PATH to REG_EXPAND_SZ, usually it is REG_SZ.
* $toolsRootPath - is the root of the tools cache. It is being added to $env:PATH and $env:TOOLS. It contains many *.cmd files that hook up lesser used tools, like OpenSSL, Python, NMap, MSBuild, NuGet, Notepad++. This provides an easy way to extend the tools coverage without overloading $env:PATH and adversely affecting the system's performance.
* Sysinternals are installed into $env:PATH and $env:TOOLS_SYSINTERNALS.
* Gnu Tools are installed into $env:PATH and $env:TOOLS_GNUWINCORETOOLS.
* Git is installed into $env:PATH and $env:TOOLS_GIT.
* Various tools located in $toolsRootPath\Various are installed into $env:PATH and $env:TOOLS_VARIOUS.

The global GIT configuration is adjusted to

* user.name is set to 'Stephan Adler'
* user.email is set to the result of the GetEmailAddress method.
* Many useful aliases are created in the global scope, like nb (new branch), co (checkout), st (status), pause (pause work), start (start/resume work).

NUGET is preconfigured in the following way:

* It is available through $env:PATH.
* The cache folder is $nugetCacheDirectory and $env:NugetMachineInstallRoot.
* The $sourceCodeFolder contains a NuGet.config file (template is in $toolsRootPath\Scripts\NuGet.config.template.xml ($nugetConfigFile) that sets the cache directories to $nugetCacheDirectory.

The DEBUG SYMBOL CACHE is setup up

* in folder $symbolCacheDirectory
* and symbol servers are configured in $env:_NT_SYMBOL_PATH.

.LINK
https://github.com/stephanadler1/shell/blob/master/install.md
#>

param(
    # Provide a drive letter where you want to place your user data. D: is used if writeable otherwise $env:SYSTEMDRIVE is used.
    [Parameter(Mandatory = $false)]
    [ValidateScript({[System.IO.Directory]::Exists($_) -eq $true})]
    [string] $script:dataDrive = $null,

    # The default user name used for Git.
    [Parameter(Mandatory = $false)]
    [string] $script:userName = 'Stephan Adler',

    # The default email address used for Git.
    [Parameter(Mandatory = $false)]
    [string] $script:emailAddress = 'dev@example.com'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:rootPath = Split-Path $script:MyInvocation.MyCommand.Path -Parent
$script:toolsRootPath = ([System.IO.Path]::Combine($rootPath, 'ToolsCache'))
$script:pathEnvVar = 'PATH'
$script:enviromentUserScope = 'User'

$script:icaclsAddUser = @(
    '/grant', "$($env:USERDOMAIN)\$($env:USERNAME):(OI)(CI)(F)")

$script:icaclsUserOnly = @(
    '/grant:r', "NT AUTHORITY\SYSTEM:(OI)(CI)(F)",
    '/grant:r', "BUILTIN\Administrators:(OI)(CI)(F)"
    '/grant:r', "$($env:USERDOMAIN)\$($env:USERNAME):(OI)(CI)(F)",
    '/inheritance:r')

$iconLockScreen = '%WINDIR%\System32\Shell32.dll,47'
#$iconLego = ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\FolderIcon-Lego.ico'))
#$iconGroup = ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\FolderIcon-Group.ico'))
$iconLego = "$env:WINDIR\System32\Shell32.dll,80"
$iconGroup = "$env:WINDIR\System32\Shell32.dll,160"

if ([string]::IsNullOrWhiteSpace($env:OneDrive) -eq $false)
{
    if ($toolsRootPath.StartsWith($env:OneDrive))
    {
        $toolsRootPath = $toolsRootPath.Replace($env:OneDrive, '%OneDrive%')
    }
}

$script:toolsRootPathExpanded = [System.Environment]::ExpandEnvironmentVariables($toolsRootPath)

if ([string]::IsNullOrWhiteSpace($toolsRootPathExpanded) -eq $true)
{
    Write-Error '$toolsRootPathExpanded is empty.'
    return 1
}


if ([string]::IsNullOrEmpty($dataDrive) -eq $true)
{
    # Trying to auto-detect the data drive on D:
    if ([System.IO.Directory]::Exists('D:\') -eq $true)
    {
        $tempFileName = 'D:\' + [System.Guid]::NewGuid().ToString('N')
        try
        {
            # Check if the drive let's us write to it (DEV-SEAT-1 case with mapped drives from ARCTURUS)
            [System.IO.File]::WriteAllText($tempFileName, 'test')
            $dataDrive = 'D:\'
        }
        catch
        {
            # do nothing
        }
        finally
        {
            [System.IO.File]::Delete($tempFileName)
        }
    }

    if ([string]::IsNullOrEmpty($dataDrive) -eq $true)
    {
        # Auto-detection didn't work, assume the $env:SystemDrive, usually C:
        $dataDrive = $env:SystemDrive
    }
}

# Make sure the drive ends with \
$dataDrive = ($dataDrive.TrimEnd('\') + '\')

$script:sourceCodeFolder = [System.IO.Path]::Combine($dataDrive, 'dev')
$script:secondaryUsersFolder = $null
$script:packageCacheRoot = [System.IO.Path]::Combine($dataDrive, 'packages')
$script:nugetCacheDirectory = [System.IO.Path]::Combine($packageCacheRoot, 'nuget')


# -----------------------------------------------------------------------
# Import Business Machine
# -----------------------------------------------------------------------

Import-Module "$rootPath\install.psm1" -Scope Local
if ([System.IO.File]::Exists("$rootPath\install.$env:USERDOMAIN.psm1"))
{
    Import-Module "$rootPath\install.$env:USERDOMAIN.psm1" -Scope Local
}

$packageCacheRoot = $(GetPackageCacheRoot)
$nugetCacheDirectory = $(GetNugetCacheDirectory)


# -----------------------------------------------------------------------
# Scanning for threats
# -----------------------------------------------------------------------

ScanThreats $rootPath


# -----------------------------------------------------------------------
# Source Code Folder
# -----------------------------------------------------------------------

CreateOrUpdateFolder $sourceCodeFolder $iconLego 'Source code folder. Environment variable SOURCES_ROOT points to it.' @('+I')
& icacls $sourceCodeFolder $icaclsAddUser | Out-Null
[System.Environment]::SetEnvironmentVariable('SOURCES_ROOT', $sourceCodeFolder, $enviromentUserScope)

# Copy directory.build.(props|targets) files into the source code folders to detect poorly written code
$directoryBuildFile = [System.IO.Path]::Combine($sourceCodeFolder, 'directory.build.props')
if ([System.IO.File]::Exists($directoryBuildFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\directory.build.props.template.xml')) -Destination $directoryBuildFile -Force
    & attrib +R "$directoryBuildFile" | Out-Null
}

$directoryBuildFile = [System.IO.Path]::Combine($sourceCodeFolder, 'directory.build.targets')
if ([System.IO.File]::Exists($directoryBuildFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\directory.build.targets.template.xml')) -Destination $directoryBuildFile -Force
    & attrib +R "$directoryBuildFile" | Out-Null
}

$editorConfigFile = [System.IO.Path]::Combine($sourceCodeFolder, '.editorconfig')
if ([System.IO.File]::Exists($editorConfigFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\editorconfig.template.ini')) -Destination $editorConfigFile -Force
    & attrib +R "$editorConfigFile" | Out-Null
}


# -----------------------------------------------------------------------
# Secondary User Folder
# -----------------------------------------------------------------------

if (-not ($dataDrive.StartsWith($env:SystemDrive, [System.StringComparison]::OrdinalIgnoreCase)))
{
    # Only create a new user folder if it is not the SYSTEMDRIVE!
    $script:secondaryUsersFolder = [System.IO.Path]::Combine($dataDrive, 'Users')
    CreateOrUpdateFolder $secondaryUsersFolder $iconGroup 'Secondary user profile folder.'

    $secondaryUserFolder = [System.IO.Path]::Combine($secondaryUsersFolder, $env:USERNAME)
    if ([System.IO.Directory]::Exists($secondaryUserFolder) -ne $true)
    {
        [System.IO.Directory]::CreateDirectory($secondaryUserFolder) | Out-Null
        & icacls $secondaryUserFolder $icaclsUserOnly | Out-Null
    }
    else
    {
        Write-Host "$secondaryUserFolder $icaclsUserOnly"
    }
}


# -----------------------------------------------------------------------
# Add tools path to PATH environment variable
# -----------------------------------------------------------------------

Write-Host 'Installing tools in PATH...'
ConvertPathToRegExpandSz $pathEnvVar
AddPath2 $pathEnvVar $enviromentUserScope $toolsRootPath 'TOOLS' 'Tools'
AddPath2 $pathEnvVar $enviromentUserScope ([System.IO.Path]::Combine($toolsRootPath, 'Sysinternals')) 'TOOLS_SYSINTERNALS' 'Sysinternals'
AddPath2 $pathEnvVar $enviromentUserScope ([System.IO.Path]::Combine($toolsRootPath, 'Various')) 'TOOLS_VARIOUS' 'Various Tools'
AddPath2 $pathEnvVar $enviromentUserScope ([System.IO.Path]::Combine($toolsRootPath, 'GnuWin32.CoreTools\bin')) 'TOOLS_GNUWINCORETOOLS' 'GnuWin 32 Core Tools'

$script:gitPath = [System.IO.Path]::Combine($toolsRootPath, 'git.vsts\cmd')
if ([System.IO.Directory]::Exists([System.Environment]::ExpandEnvironmentVariables($gitPath)) -ne $true)
{
    $gitPath = [System.IO.Path]::Combine($toolsRootPath, 'git.portable\cmd')
    if ([System.IO.Directory]::Exists([System.Environment]::ExpandEnvironmentVariables($gitPath)) -ne $true)
    {
        $gitPath = [System.IO.Path]::Combine($toolsRootPath, 'git\cmd')
    }
}

AddPath2 $pathEnvVar $enviromentUserScope $gitPath 'TOOLS_GIT' 'Git'


# -----------------------------------------------------------------------
# Configure the command shell
# -----------------------------------------------------------------------

Write-Host 'Configuring command processor...'
[System.Environment]::SetEnvironmentVariable('DIRCMD', '/ogn', $enviromentUserScope)

if ([System.Environment]::OSVersion.Version.Major -ge 10)
{
    [System.Environment]::SetEnvironmentVariable('PROMPT', '$E[m$E[32m$T$S$E[92m$P$E[90m$_$E[90m$G$E[m$S$E]9;12$E\', $enviromentUserScope)
}
else
{
    # This is the original Windows command prompt
    [System.Environment]::SetEnvironmentVariable('PROMPT', '$P$G$S', $enviromentUserScope)
}


# -----------------------------------------------------------------------
# Create Desktop Shortcuts if ConEmu is available
# -----------------------------------------------------------------------

$script:conEmuPath = ([System.IO.Path]::Combine($toolsRootPath, 'ConEmu\ConEmu64.exe'))
if ([System.IO.File]::Exists([System.Environment]::ExpandEnvironmentVariables($conEmuPath)) -eq $true)
{
    Write-Host 'Set ConEmu Desktop shortcuts...'
    # AddDesktopShortcut 'Command Shell' $conEmuPath @('-run', "`"$env:COMSPEC`"") 'Command Processor in ConEmu64' 'd:\dev'
    # AddDesktopShortcut 'Developer Shell' $conEmuPath @('-run', "`"$env:COMSPEC`"", '/k', "`"$rootPath\initdev.cmd`"") 'Developer Command Processor in ConEmu64' 'd:\dev'
    AddDesktopShortcut 'Command Shell' $conEmuPath @('-run', '"%COMSPEC%"', '/d', '/k', "`"title Command Prompt`"") 'Command Processor in ConEmu64' "$env:HOMEDRIVE\$env:HOMEPATH"
    AddDesktopShortcut 'Developer Shell' $conEmuPath @('-run', '"%COMSPEC%"', '/d', '/s', '/k', "`"`"$rootPath\initdev.cmd`"`"") 'Developer Command Processor in ConEmu64' "$($dataDrive)dev"
    AddDesktopShortcut 'PowerShell Shell' $conEmuPath @('-run', 'powershell.exe') 'PowerShell in ConEmu64' 'd:\dev'
    AddDesktopShortcut 'Developer Shell (PS)' $conEmuPath @('-run', 'powershell.exe', '-NoLogo', '-NoExit', '-Mta', '-ExecutionPolicy RemoteSigned', '-File', "`"$rootPath\initdev.ps1`"") 'Developer Command Processor (PS) in ConEmu64' 'd:\dev'
}
else
{
    Write-Host "Unable to find ConEmu at '$conEmuPath'."
}

# https://www.tenforums.com/tutorials/77458-rundll32-commands-list-windows-10-a.html
# rundll32.exe user32.dll, LockWorkStation
AddDesktopShortcut 'Lock Computer' '%WINDIR%\System32\rundll32.exe' @('user32.dll,LockWorkStation') -iconLocation $iconLockScreen


# -----------------------------------------------------------------------
# Create Symbols directory and environment variables
# -----------------------------------------------------------------------

$script:symbolCacheDirectory = [System.IO.Path]::Combine($dataDrive, 'Symbols')
Write-Host "Configure Symbol cache to be $symbolCacheDirectory..."
[System.IO.Directory]::CreateDirectory($symbolCacheDirectory) | Out-Null

# Compress the folder, prevent indexing, give current user full access
& compact /c "$symbolCacheDirectory" | Out-Null
& attrib +I "$symbolCacheDirectory" /s /d | Out-Null
& icacls $symbolCacheDirectory $icaclsAddUser | Out-Null

$script:defaultSymbolPath = "SRV*$symbolCacheDirectory*https://msdl.microsoft.com/download/symbols;SRV*$symbolCacheDirectory*https://referencesource.microsoft.com/symbols"
# Invalid: ;SRV*$symbolCacheDirectory*http://srv.symbolsource.org/pdb/Public
SetSymbolServers $defaultSymbolPath $enviromentUserScope


# -----------------------------------------------------------------------
# Configure developer machine
# -----------------------------------------------------------------------

SpecificDeveloperMachineSetup

Write-Host "Enable minimal builds in Visual Studio for specific source repositories..."
[System.Environment]::SetEnvironmentVariable('MINIMAL_VS_BUILD', '1', $enviromentUserScope)


# -----------------------------------------------------------------------
# Setup NuGet cache directory
# -----------------------------------------------------------------------

if ($packageCacheRoot -ne $null)
{
    Write-Host "Configure package root to be $packageCacheRoot..."
    [System.IO.Directory]::CreateDirectory($packageCacheRoot) | Out-Null
    # Compress the folder, prevent indexing, give current user full access
    & compact /c "$packageCacheRoot" | Out-Null
    & attrib +I "$packageCacheRoot" /s /d | Out-Null
    & icacls $packageCacheRoot $icaclsAddUser | Out-Null
}

if ($nugetCacheDirectory -ne $null)
{
    Write-Host "Configure Nuget cache to be $nugetCacheDirectory..."
    [System.IO.Directory]::CreateDirectory($nugetCacheDirectory) | Out-Null
    [System.Environment]::SetEnvironmentVariable('NugetMachineInstallRoot', $nugetCacheDirectory, $enviromentUserScope)
    # Compress the folder, prevent indexing, give current user full access
    & compact /c "$nugetCacheDirectory" | Out-Null
    & attrib +I "$nugetCacheDirectory" /s /d | Out-Null
    & icacls $nugetCacheDirectory $icaclsAddUser | Out-Null
}

# Configure NuGet for the source code folder based on template file
$nugetConfigFile = [System.IO.Path]::Combine($sourceCodeFolder, 'NuGet.config')
if ([System.IO.File]::Exists($nugetConfigFile) -ne $true)
{
    Copy-Item ([System.IO.Path]::Combine($toolsRootPathExpanded, 'Scripts\NuGet.config.template.xml')) -Destination $nugetConfigFile -Force
}

# Set cache paths
& attrib -R "$nugetConfigFile" | Out-Null
& "$toolsRootPathExpanded\nuget.cmd" config -set "repositoryPath=$nugetCacheDirectory\r" -set "globalPackagesFolder=$nugetCacheDirectory\g"  -configFile $nugetConfigFile
& attrib +R "$nugetConfigFile" | Out-Null


# -----------------------------------------------------------------------
# Configure Git
# -----------------------------------------------------------------------

Write-Host "Configuring global Git settings for '$(GetUserName)'..."
# Environment variables to consider: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
# More aliases to consider
# http://haacked.com/archive/2014/07/28/github-flow-aliases/
# http://durdn.com/blog/2012/11/22/must-have-git-aliases-advanced-examples/
ConfigureGitGlobally $gitPath 'user.name' $(GetUserName)
ConfigureGitGlobally $gitPath 'user.email' $(GetEmailAddress)
ConfigureGitGlobally $gitPath 'alias.br' 'branch'
ConfigureGitGlobally $gitPath 'alias.co' 'checkout'
ConfigureGitGlobally $gitPath 'alias.com' 'checkout master'
ConfigureGitGlobally $gitPath 'alias.cod' 'checkout develop'
ConfigureGitGlobally $gitPath 'alias.gh' '!f() { cid=$(git rev-parse head); echo $cid; echo $cid | clip; }; f'
ConfigureGitGlobally $gitPath 'alias.hist' "log --pretty=format:'%C(yellow)%h %Cred%ad%Creset | %s%d %Cblue[%an]' --graph --date=short"
ConfigureGitGlobally $gitPath 'alias.lol' 'log --graph --oneline'
ConfigureGitGlobally $gitPath 'alias.nb' '!f() { bn=${1-zzz_temp$RANDOM}; un=${USERNAME,,}; git checkout -b dev/$un/$bn origin/master; git push --set-upstream origin dev/$un/$bn; }; f'
# ConfigureGitGlobally $gitPath 'alias.nb' '!f() { bn=${1-zzz_temp$RANDOM}; un=${USERNAME,,}; git checkout -b dev/$un/$bn master; git branch --set-upstream-to origin dev/$un/$bn; }; f'
ConfigureGitGlobally $gitPath 'alias.nf' '!f() { bn=${1-zzz_temp$RANDOM}; git checkout -b feature/$bn origin/master; git push --set-upstream origin feature/$bn; }; f'
# ConfigureGitGlobally $gitPath 'alias.nf' '!f() { bn=${1-zzz_temp$RANDOM}; git checkout -b feature/$bn master; git branch --set-upstream-to origin feature/$bn; }; f'
ConfigureGitGlobally $gitPath 'alias.st' 'status'
ConfigureGitGlobally $gitPath 'alias.up' "!f() { git pull --rebase --prune $@; git submodule update --init --recursive; }; f"
ConfigureGitGlobally $gitPath 'alias.wipe' "!f() { git add -A; git commit -qm '*** WIPED SAVEPOINT ***. Use git reflog to restore.'; git reset HEAD~1 --hard; }; f"
ConfigureGitGlobally $gitPath 'alias.pause' "!f() { git add -A; git commit -m '*** SAVEPOINT ***. Use git start to resume work.'; }; f"
ConfigureGitGlobally $gitPath 'alias.start' 'reset HEAD~1 --mixed'
# ConfigureGitGlobally $gitPath 'alias.nw' '!f() { bn=${1-zzz_temp$RANDOM}; un=${USERNAME,,}; git worktree add --track -b dev/$un/$bn \dev\$bn master; git branch --set-upstream-to origin dev/$un/$bn; }; f'


Write-Host 'Done.'

