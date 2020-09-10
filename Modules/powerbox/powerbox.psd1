#
# Modulmanifest für das Modul "PSGet_powerbox"
#
# Generiert von: achter <Rudolf.Achter@uni-passau.de>
#
# Generiert am: 10.09.2020
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
RootModule = 'powerbox.psm1'

# Die Versionsnummer dieses Moduls
ModuleVersion = '2.4'

# Unterstützte PSEditions
# CompatiblePSEditions = @()

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = '1e8270f5-6b38-4cbb-b814-58ec2599da36'

# Autor dieses Moduls
Author = 'achter <Rudolf.Achter@uni-passau.de>'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = 'NA'

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2018 batmanama. All rights reserved.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'Interact with netbox, the easy way'

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
PowerShellVersion = '5.0'

# Der Name des für dieses Modul erforderlichen Windows PowerShell-Hosts
# PowerShellHostName = ''

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Hosts
# PowerShellHostVersion = ''

# Die für dieses Modul mindestens erforderliche Microsoft .NET Framework-Version. Diese erforderliche Komponente ist nur für die PowerShell Desktop-Edition gültig.
DotNetFrameworkVersion = '4.0'

# Die für dieses Modul mindestens erforderliche Version der CLR (Common Language Runtime). Diese erforderliche Komponente ist nur für die PowerShell Desktop-Edition gültig.
CLRVersion = '4.0'

# Die für dieses Modul erforderliche Prozessorarchitektur ("Keine", "X86", "Amd64").
# ProcessorArchitecture = ''

# Die Module, die vor dem Importieren dieses Moduls in die globale Umgebung geladen werden müssen
# RequiredModules = @()

# Die Assemblys, die vor dem Importieren dieses Moduls geladen werden müssen
# RequiredAssemblies = @()

# Die Skriptdateien (PS1-Dateien), die vor dem Importieren dieses Moduls in der Umgebung des Aufrufers ausgeführt werden.
# ScriptsToProcess = @()

# Die Typdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# TypesToProcess = @()

# Die Formatdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# FormatsToProcess = @()

# Die Module, die als geschachtelte Module des in "RootModule/ModuleToProcess" angegebenen Moduls importiert werden sollen.
# NestedModules = @()

# Aus diesem Modul zu exportierende Funktionen. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Funktionen vorhanden sind.
FunctionsToExport = 'Connect-nbAPI', 'ConvertTo-nbID', 'Get-nbAggregate', 'Get-nbCircuit', 
               'Get-nbCircuitTermination', 'Get-nbCircuitType', 'Get-nbCluster', 
               'Get-nbClusterGroup', 'Get-nbClusterType', 'Get-nbConnectedDevice', 
               'Get-nbConsoleConnection', 'Get-nbConsolePort', 
               'Get-nbConsolePortTemplate', 'Get-nbConsoleServerPort', 
               'Get-nbConsoleServerPortTemplate', 'Get-nbDevice', 'Get-nbDevicebay', 
               'Get-nbDevicebayTemplate', 'Get-nbDeviceRole', 'Get-nbDeviceType', 
               'Get-nbExportTemplate', 'Get-nbGraph', 'Get-nbImageAttachment', 
               'Get-nbInterface', 'Get-nbInterfaceConnection', 
               'Get-nbInterfaceTemplate', 'Get-nbInventoryItem', 'Get-nbIpAddress', 
               'Get-nbManufacturer', 'Get-nbObject', 'Get-nbPlatform', 
               'Get-nbPowerConnection', 'Get-nbPowerOutlet', 
               'Get-nbPowerOutletTemplate', 'Get-nbPowerPort', 
               'Get-nbPowerPortTemplate', 'Get-nbPrefix', 'Get-nbProvider', 
               'Get-nbRack', 'Get-nbRackGroup', 'Get-nbRackReservation', 
               'Get-nbRackRole', 'Get-nbRecentActivity', 'Get-nbRegion', 
               'Get-nbReport', 'Get-nbRir', 'Get-nbRole', 'Get-nbService', 'Get-nbSite', 
               'Get-nbTenant', 'Get-nbTenantGroup', 'Get-nbTopologyMap', 
               'Get-nbVirtualChassis', 'Get-nbVirtualMachine', 'Get-nbVlan', 
               'Get-nbVlanGroup', 'Get-nbVMInterface', 'Get-nbVrf', 'Invoke-nbApi', 
               'New-nbAggregate', 'New-nbCircuit', 'New-nbCircuitTermination', 
               'New-nbCircuitType', 'New-nbCluster', 'New-nbClusterGroup', 
               'New-nbClusterType', 'New-nbConnectedDevice', 
               'New-nbConsoleConnection', 'New-nbConsolePort', 
               'New-nbConsolePortTemplate', 'New-nbConsoleServerPort', 
               'New-nbConsoleServerPortTemplate', 'New-nbDevice', 'New-nbDevicebay', 
               'New-nbDevicebayTemplate', 'New-nbDeviceRole', 'New-nbDeviceType', 
               'New-nbExportTemplate', 'New-nbGraph', 'New-nbImageAttachment', 
               'New-nbInterface', 'New-nbInterfaceConnection', 
               'New-nbInterfaceTemplate', 'New-nbInventoryItem', 'New-nbIpAddress', 
               'New-nbManufacturer', 'New-nbObject', 'New-nbPlatform', 
               'New-nbPowerConnection', 'New-nbPowerOutlet', 
               'New-nbPowerOutletTemplate', 'New-nbPowerPort', 
               'New-nbPowerPortTemplate', 'New-nbPrefix', 'New-nbProvider', 
               'New-nbRack', 'New-nbRackGroup', 'New-nbRackReservation', 
               'New-nbRackRole', 'New-nbRecentActivity', 'New-nbRegion', 
               'New-nbReport', 'New-nbRir', 'New-nbRole', 'New-nbService', 'New-nbSite', 
               'New-nbTenant', 'New-nbTenantGroup', 'New-nbTopologyMap', 
               'New-nbVirtualChassis', 'New-nbVirtualMachine', 'New-nbVlan', 
               'New-nbVlanGroup', 'New-nbVMInterface', 'New-nbVrf', 'Set-nbAggregate', 
               'Set-nbCircuit', 'Set-nbCircuitTermination', 'Set-nbCircuitType', 
               'Set-nbCluster', 'Set-nbClusterGroup', 'Set-nbClusterType', 
               'Set-nbConnectedDevice', 'Set-nbConsoleConnection', 
               'Set-nbConsolePort', 'Set-nbConsolePortTemplate', 
               'Set-nbConsoleServerPort', 'Set-nbConsoleServerPortTemplate', 
               'Set-nbDevice', 'Set-nbDevicebay', 'Set-nbDevicebayTemplate', 
               'Set-nbDeviceRole', 'Set-nbDeviceType', 'Set-nbExportTemplate', 
               'Set-nbGraph', 'Set-nbImageAttachment', 'Set-nbInterface', 
               'Set-nbInterfaceConnection', 'Set-nbInterfaceTemplate', 
               'Set-nbInventoryItem', 'Set-nbIpAddress', 'Set-nbManufacturer', 
               'Set-nbObject', 'Set-nbPlatform', 'Set-nbPowerConnection', 
               'Set-nbPowerOutlet', 'Set-nbPowerOutletTemplate', 'Set-nbPowerPort', 
               'Set-nbPowerPortTemplate', 'Set-nbPrefix', 'Set-nbProvider', 
               'Set-nbRack', 'Set-nbRackGroup', 'Set-nbRackReservation', 
               'Set-nbRackRole', 'Set-nbRecentActivity', 'Set-nbRegion', 
               'Set-nbReport', 'Set-nbRir', 'Set-nbRole', 'Set-nbService', 'Set-nbSite', 
               'Set-nbTenant', 'Set-nbTenantGroup', 'Set-nbTopologyMap', 
               'Set-nbVirtualChassis', 'Set-nbVirtualMachine', 'Set-nbVlan', 
               'Set-nbVlanGroup', 'Set-nbVMInterface', 'Set-nbVrf', 
               'Remove-nbAggregate', 'Remove-nbCircuit', 
               'Remove-nbCircuitTermination', 'Remove-nbCircuitType', 
               'Remove-nbCluster', 'Remove-nbClusterGroup', 'Remove-nbClusterType', 
               'Remove-nbConnectedDevice', 'Remove-nbConsoleConnection', 
               'Remove-nbConsolePort', 'Remove-nbConsolePortTemplate', 
               'Remove-nbConsoleServerPort', 'Remove-nbConsoleServerPortTemplate', 
               'Remove-nbDevice', 'Remove-nbDevicebay', 'Remove-nbDevicebayTemplate', 
               'Remove-nbDeviceRole', 'Remove-nbDeviceType', 
               'Remove-nbExportTemplate', 'Remove-nbGraph', 
               'Remove-nbImageAttachment', 'Remove-nbInterface', 
               'Remove-nbInterfaceConnection', 'Remove-nbInterfaceTemplate', 
               'Remove-nbInventoryItem', 'Remove-nbIpAddress', 
               'Remove-nbManufacturer', 'Remove-nbObject', 'Remove-nbPlatform', 
               'Remove-nbPowerConnection', 'Remove-nbPowerOutlet', 
               'Remove-nbPowerOutletTemplate', 'Remove-nbPowerPort', 
               'Remove-nbPowerPortTemplate', 'Remove-nbPrefix', 'Remove-nbProvider', 
               'Remove-nbRack', 'Remove-nbRackGroup', 'Remove-nbRackReservation', 
               'Remove-nbRackRole', 'Remove-nbRecentActivity', 'Remove-nbRegion', 
               'Remove-nbReport', 'Remove-nbRir', 'Remove-nbRole', 'Remove-nbService', 
               'Remove-nbSite', 'Remove-nbTenant', 'Remove-nbTenantGroup', 
               'Remove-nbTopologyMap', 'Remove-nbVirtualChassis', 
               'Remove-nbVirtualMachine', 'Remove-nbVlan', 'Remove-nbVlanGroup', 
               'Remove-nbVMInterface', 'Remove-nbVrf'

# Aus diesem Modul zu exportierende Cmdlets. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Cmdlets vorhanden sind.
CmdletsToExport = @()

# Die aus diesem Modul zu exportierenden Variablen
# VariablesToExport = @()

# Aus diesem Modul zu exportierende Aliase. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Aliase vorhanden sind.
AliasesToExport = @()

# Aus diesem Modul zu exportierende DSC-Ressourcen
# DscResourcesToExport = @()

# Liste aller Module in diesem Modulpaket
# ModuleList = @()

# Liste aller Dateien in diesem Modulpaket
FileList = 'powerbox.psd1', 'powerbox.psm1', 'Version', 
               'Private\CreateCommands.ps1', 'Private\Get.txt', 'Private\New.txt', 
               'Private\ResourceMap.ps1', 'Private\Set.txt', 
               'Public\Connect-nbApi.ps1', 'Public\ConvertTo-nbId.ps1', 
               'Public\Get-nbObject.ps1', 'Public\Get-nbx.ps1', 
               'Public\Invoke-nbApi.ps1', 'Public\New-nbObject.ps1', 
               'Public\New-nbx.ps1', 'Public\Set-nbObject.ps1', 'Public\Set-nbx.ps1'

# Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen. Diese können auch eine PSData-Hashtabelle mit zusätzlichen von PowerShell verwendeten Modulmetadaten enthalten.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'netbox','DCIM','API'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/batmanama/powerbox/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/batmanama/powerbox'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'v2.3.5
Fix body hashtable detection. (#28)'

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
# DefaultCommandPrefix = ''

}

