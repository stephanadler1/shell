# Copyright (c) Stephan Adler.

@{
    RootModule = 'parsifal.core.psm1'
    ModuleVersion = '0.0.4.0'
    GUID = '1B427DAF-1599-4343-8820-3D025ABFEE66'

    CompatiblePSEditions = @("Core", "Desktop")
    PowershellVersion = "5.1"

    Author = 'Stephan Adler'
    CompanyName = 'Stephan Adler'
    Copyright = 'Copyright (c) Stephan Adler.'

    Description = "Core functions"

    NestedModules = @()

    RequiredAssemblies = @()

    FunctionsToExport = @(
        'Invoke-Tool',

        'Remove-FileSecure',
        
        'Test-ForThreats',
        'Test-ToolExists'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # License for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # An icon representing this module.
            IconUri = 'https://stephanadler1.github.io/images/Nuget/Parsifal.png'

            Tags = @('PowerShell Module', 'Parsifal', 'Core')
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
