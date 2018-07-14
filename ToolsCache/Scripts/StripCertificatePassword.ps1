# -----------------------------------------------------------------------
# <copyright file="StripCertificatePassword.ps1" company="Stephan Adler">
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

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $in,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $password,

    [Parameter(Mandatory = $false)]
    [string] $out = $in + '.nopassword.pfx'
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    
    if ([System.IO.File]::Exists($in) -eq $false)
    {
        Write-Error "File '$in' not found."
        [System.Environment]::Exit(1)
    }
}

process {

    Write-Host ''
    Write-Host 'Stripping PFX/PCKS12 encoded certificate with private key of it''s password.'

    $flags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::UserKeySet
    $certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($in, $password, $flags)
    $binaryCertificate = $certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx)
    [System.IO.File]::WriteAllBytes($out, $binaryCertificate)

    Write-Host "Done. The new file is at '$out'."

    [System.Environment]::Exit(0)
}