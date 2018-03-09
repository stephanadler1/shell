# Setting Up Developer Workstations

This collection of scripts and folder layout is a solution for a problem of mine: 
How do I create the same experience on multiple developer workstations (desktop, lap/notebooks, even work machines)
and keep all the different tools up-to-date without installing them on each and every computer?

The solution, after many detours (see below), is this:

- I'm using peer sync software, like [Resilio Sync](https://www.resilio.com/), [OneDrive](https://www.onedrive.com/), ..., to get this folder and it's tools on all my workstations.
- When I setup a new machine, I run the `configure-os.ps1` script, usually through `configure-os.cmd`. It applies my most frequently changed OS settings. Afterwards, on touch-enabled machines, I run `configure-user.cmd`, to change the alignment of the menus back to "normal".
- To initially configure **or re-configure** the machine, I run the `install.ps1` script, usually through `install.cmd`. To learn more about the configuration, run `help install.ps1` or invoke `install - help.cmd`.
- In addition to having many tools available, I don't want to have my systems slow down because of all their deployment folders show up in PATH. An easy way to solve this was to use invocation scripts (all in .\ToolsCache). This has the nice side effect that I can use abbreviations to invoke tools, like `n` (instead of Notepad++) or `b` (instead of msbuild). Similar to the git customizations, where I can use `git nb branchname` instead of `git checkout -b dev/stephan/branchname`.

The command shortcuts available in Windows (e.g. Windows+R, always requires the added `.cmd`), Windows Command Prompt or Windows PowerShell command prompt:

- Shortcuts for **msbuild** are: `b` (incremental build), `bcc` (clean build, historic for `build.exe -cC`), `msb` (incremental build with reduced log output). All commands use the multi-threaded build option (`/m`).
- Shortcuts to **calculate file hashes** are: `md5` (MD5), `sha1`, `sha256`. Use `sha256 filename expected_hash` to compare the calculcated hash to the expected hash.
- `dc`: Windows Management console including the most frequently used snap-ins. Opens file `.\ToolsCache\Scripts\DeveloperConsole.msc`.
- `dig`: Invokes Bind Dig tool.
- `e`: Opens the Windows Explorer from the current location, or any other location with `e path`.
- `ilspy`: Invokes ILSpy.
- `n`: Invokes Notepad++, to open a file use `n file1 [file2...]`
- `nant`: Invokes NAnt.
- `ncat`: Invokes NCat.
- `nmap`: Invokes NMap.
- `nuget`: Invokes NuGet command line client.
- `open`: If you have Microsoft's VSMSBuild or SlnGen tool, generates a `.sln` file based on a `dirs.proj` hierarchy and opens the generated solution in Visual Studio.
- `openssl`: Invokes OpenSSL.
- `python`: Invokes Python.
- `vs`: Opens Visual Studio from the current path.

The folder layout:

<table>
<tr><th>Path</th>
    <th>In Search PATH</th>
    <th>Description</th></tr>
<tr><td>.\</td>
    <td>No</td>
    <td>Contains this file and the installers.</td></tr>
<tr><td>.\ToolsCache</td>
    <td>Yes</td>
    <td>Root path for all tools and invocation scripts for lesser used tools, like openssl.cmd or n.cmd</td></tr>
<tr><td>.\ToolsCache\ConEmu</td>
    <td>No</td>
    <td>My preferred console host on Windows. Still lightyears ahead of the default console, even on Windows 10.</td></tr>
<tr><td>.\ToolsCache\Dig</td>
    <td>No</td>
    <td>A "better" version of <code>nslookup</code>.</td></tr>
<tr><td>.\ToolsCache\Git.portable</td>
    <td>Kind Of</td>
    <td>A copy of portable Git, including modifications to the authentication to allow handling of Visual Studio online. Like in a normal Git installation, <code>.\ToolsCache\Git.portable\cmd</code> is added to the PATH.</td></tr>
<tr><td>.\ToolsCache\Git.portable.prev</td>
    <td>No</td>
    <td>A secondary copy of Git, for peer sync software that isn't as quick as a BitTorrent based solution (hello OneDrive!).</td></tr>
<tr><td>.\ToolsCache\GnuWin32.CoreTools</td>
    <td>Kind Of</td>
    <td>Copy of the GnuWin core tools. <code>.\ToolsCache\GnuWin32.CoreTools\bin</code> is added to the PATH.</td></tr>
<tr><td>.\ToolsCache\ILSpy</td>
    <td>No</td>
    <td>Invoke through ilspy.cmd.</td></tr>
<tr><td>.\ToolsCache\NAnt</td>
    <td>No</td>
    <td>Invoke through nant.cmd.</td></tr>
<tr><td>.\ToolsCache\NMap</td>
    <td>No</td>
    <td>Invoke through nmap.cmd and ncat.cmd.</td></tr>
<tr><td>.\ToolsCache\npp.7.5.4.bin.x64</td>
    <td>No</td>
    <td>Notepad++. Invoke through n.cmd.</td></tr>
<tr><td>.\ToolsCache\Nuget</td>
    <td>No</td>
    <td>Invoke through nuget.cmd.</td></tr>
<tr><td>.\ToolsCache\OpenSSL</td>
    <td>No</td>
    <td>Invoke through openssl.cmd.</td></tr>
<tr><td>.\ToolsCache\Python</td>
    <td>No</td>
    <td>Invoke through python.cmd.</td></tr>
<tr><td>.\ToolsCache\Sysinternals</td>
    <td>Yes</td>
    <td>Copy of the Sysinternals suite.</td></tr>
<tr><td>.\ToolsCache\Various</td>
    <td>Yes</td>
    <td>Various other tools. Will always be last in PATH.</td></tr>
</table>


## License and Copyright

Copyright &copy; Stephan Adler. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


## Discounted Approaches To Solve This Problem

When I started at Microsoft back in 2008, I was shocked to learn that they are still using the command line for software development. At the time, I had been using Visual Studio and before that IBM's VisualAge C++ on OS/2. However, the developer command line (called [CoReXT](http://code.dblock.org/2014/04/28/why-one-giant-source-control-repository-is-bad-for-you-and-facebook.html) or Razzle) had some interesting advantages:

1. It kept the tool chain in sync and up-to-date accross all machines.
2. It allowed for source repo specific tool chains and versions independent of the tools installed on the machine.
3. The tools used on your developer workstation are the same used in the build lab.
4. It came with a "standardized approach" to build script customization in terms of signing, code analysis, ..., at least for the purpose of this article.

Juggling with at least 3 computers at home, I wanted to have something similar.

1. **Check the tools into the your version control system.** My first project at Microsoft used that approach. That was before the explosion of package managers today. With Source Depot/[Perforce](https://www.perforce.com/) the tools where actually in their own repo, which was mapped as a client view into every consuming branch. Anyway, the version control systems I was using, didn't support these kind of view mappings.

2. **Consume your tools through a package manager.** Eventually CoReXT evolved from client view mappings to using NuGet packages. However, at the time, no tool was distributed through NuGet packages. This lead to a creation of internal NuGet packages for every SDK and MSBuild tools version. Also not something that would work in the long run. I still have SVN repros around that followed that approach.

3. **[Chocolatey](https://chocolatey.org/).** Yes, the security improved over the years. However, the community curated feeds are not really trustworthy. Just consider that it downloads a NuGet packages, sometimes over HTTP, and blindly executes a powershell script inside (unsigned), that in itself downloads arbitrary code (mostly over HTTP) and installs it on your machine without validating file hashes under local administrator privileges! Not good, apart from the fact that I would still need to manually invoke it on every machine to pull the latest tool versions. 

4. **Finally Microsoft publishes tools via NuGet.** Great, finally I can consume the tools packages from the manufacturer. But what should I do with all the other stuff that I want/need: [ConEmu](https://conemu.github.io/), [Notepad++](https://notepad-plus-plus.org/), [Git](https://git-scm.com/), [NuGet](https://www.nuget.org/downloads), [SysInternals](https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite), [Dig](https://www.isc.org/downloads/bind/), [OpenSSL](https://www.openssl.org/), ... No solution for these, and they should be agnostic to the machine and not the source repository. 

5. **ABEshell.** Over the years I had my own version of enlistment windows combined with package managers which even supported machine wide applications. But nothing was really easy to maintain without requiring to create my own packages.

So finally this approach was born.

<!--
[The latest supported Visual C++ downloads](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads)
or through [MSDN Subscriber Downloads](https://my.visualstudio.com/Downloads?q=redistributable)
-->