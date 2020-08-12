#
# Modulmanifest für das Modul "PSGet_Virtual-Infrastructure-Management"
#
# Generiert von: Achter, Rudolf <rudolf.achter@megatech-communication.de>
#
# Generiert am: 13.12.2019
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
RootModule = 'Virtual-Infrastructure-Management.psm1'

# Die Versionsnummer dieses Moduls
ModuleVersion = '4.2'

# Unterstützte PSEditions
# CompatiblePSEditions = @()

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = '060edba7-fb7f-4b48-8ac6-53b51c753ba9'

# Autor dieses Moduls
Author = 'Achter, Rudolf <rudolf.achter@megatech-communication.de>'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = 'Unbekannt'

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2019 Achter, Rudolf <rudolf.achter@megatech-communication.de>. Alle Rechte vorbehalten.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'Virtual Infrastructure Management and Addons by rudolf.achter@megatech-communication.de'

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
# PowerShellVersion = ''

# Der Name des für dieses Modul erforderlichen Windows PowerShell-Hosts
# PowerShellHostName = ''

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Hosts
# PowerShellHostVersion = ''

# Die für dieses Modul mindestens erforderliche Microsoft .NET Framework-Version. Diese erforderliche Komponente ist nur für die PowerShell Desktop-Edition gültig.
# DotNetFrameworkVersion = ''

# Die für dieses Modul mindestens erforderliche Version der CLR (Common Language Runtime). Diese erforderliche Komponente ist nur für die PowerShell Desktop-Edition gültig.
# CLRVersion = ''

# Die für dieses Modul erforderliche Prozessorarchitektur ("Keine", "X86", "Amd64").
# ProcessorArchitecture = ''

# Die Module, die vor dem Importieren dieses Moduls in die globale Umgebung geladen werden müssen
RequiredModules = @('HTML-Formatting', 
               'MailMessageAdvanced')

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
FunctionsToExport = 'VIM-Import-TagCategory', 'VIM-Get-VM-WithSnapshot', 
               'VIM-Shutdown-VM', 'Get-VimCmdVM', 'VIM-Sync-Contacts', 
               'VIM-Get-Snapshot', 'VIM-Mail-VMDK-Orphaned', 'VIM-Get-vCenter', 
               'VIM-Get-Contacts', 'VIM-Mail-Snapshot', 'VIM-Export-TagStructure', 
               '_Get-Shapes', 'Export-VM-toOVFDir', 'VIM-Clone-vCenter', 
               'Import-VM-fromOVFDir', 'VIM-Get-ResourceReservation', 
               'VIM-Show-ResourceReservation', 'VIM-Get-VMDK-Orphaned', 
               'VIM-Create-CustomAttributes', 'VIM-Import-TagStructure', 
               'VIM-Download-VM', 'Get-ThinProvisioned', 'Get-VMX', 'Get-VMRC-Url', 
               'VIM-ReRegister-VM', 'VIM-Archive-VM-EndOfLife', 'VIM-UnArchive-VM', 
               'VIM-Mail-VM-MissingTags', 'Get-VMXFolder', 'Get-VMRootFolder', 
               'VIM-Import-Tag', 'VIM-Get-IPv4Pool', 'VIM-Get-ContactTag', 
               'VIM-Mail-VMEndOfLife', 'VIM-Show-VM-LockingDisks', 
               'VIM-Get-VM-MissingTags', 'Get-ESXSSHLogins', 'VIM-Get-vSwitch', 
               'VIM-Get-Folder-ToRoot', 'VIM-Annotation', 'VIM-Show-VM-MissingTags', 
               'VIM-Show-VM-Resources', 'VIM-Get-VM-without-Contact', 
               'VIM-Mail-VM-without-Contact', 'VIM-Get-VM-OnWrongStorage', 
               'VIM-Mail', 'VIM-Get-VM-NotStartable', 'Start-VMRC', 'VIM-Show-VMValue', 
               'VIM-Mail-VM-Archived', 'VIM-MT-DeleteVLAN', 'VIM-Check-Tags', 
               'VIM-Get-ContactAssignment', 'VIM-Move-VMTemplate', 
               'VIM-Calculate-DateUsedUntil', 'Get-VMCreationDate', 
               'VIM-Copy-TagStructure', 'VIM-Get-vSwitchPrimary', 
               'Get-ReplicationState', 'VIM-Backup-ESXServer', 'VIM-ConvertTo-HTML', 
               'VIM-Get-vSwitchCategories', 'Move-VMThin', 'VIM-Archive-VM', 
               'VIM-Set-CreationByEvent', 'VIM-Update-Visio', 'VIM-MT-AddVLAN', 
               'VIM-Show-VM-OnWrongStorage', '_Get-Shape-ByName', 'Get-VMEvents', 
               'VIM-Get-SnapshotSummary', 'VIM-Get-ContactsHash', 'Delete-VM', 
               'Copy-VM-viaOVFDir', 'Get-Network', 'VIM-Get-Admins', 
               'VIM-New-IPv4Pool', 'VIM-Get-VM-Swapping', 
               'VIM-Mail-VM-AffectedToContacts', 'VIM-Get-VM-OldArchived', 
               'Connect-VI', 'VIM-Mail-AffectedVMs', 'Export-VM-fromESX', 
               'VIM-Show-VMEndOfLife', 'VIM-Set-UsageTime', 'Unmount-VM-ISO', 
               'VIM-Get-VMValue', 'VIM-Show-VM-without-Contact', 'VIM-Set-VMValue', 
               'VIM-Get-VM-LockingDisks', 'Get-SnapshotTree', 'VIM-Remove-IPv4Pool', 
               'Show-VM-WithISOMounted', 'New-VMFromSnapshot', 'VIM-Check-EndOfLife', 
               'VIM-Get-VMEndOfLife', 'VIM-Show-Snapshot', 'Search-VM', 
               'Get-SnapshotExtra', 'Get-All-Urls', 'Publish-OVA', 'Report-VM', 
               'VIM-Get-VMEvents', 'Get-VMCreationEvent', 'Sync-VMDocumentation', 
               'Set-VMDocumentation', 'Get-VMDocumentation', 
               'Recover-VMDocumentationFromWiki', 'Export-VMCliXML', 
               'Shutdown-BusinessServiceVM', 'Start-BusinessServiceVM', 
               'Reduce-VMCpuReservation', 'Set-DatastoreFocus', 'Set-NetworkFocus', 
               'Set-FolderFocus', 'Set-VMFocus', 'Set-VMHostFocus', 'Set-VIMFocus', 
               'Get-VIMFocus', 'Deploy-Ovf', 'Get-OvfConfigTemplateScript','Get-VItemPath'

# Aus diesem Modul zu exportierende Cmdlets. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Cmdlets vorhanden sind.
CmdletsToExport = @()

# Die aus diesem Modul zu exportierenden Variablen
# VariablesToExport = @()

# Aus diesem Modul zu exportierende Aliase. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Aliase vorhanden sind.
AliasesToExport = 'VIM-Get-VM-EndOfLife', 'VIM-Mail-VM-EndOfLife', 
               'VIM-Show-VM-EndOfLife', 'VIM-Get-ESXSSHLogins', 
               'VIM-Get-ReplicationState', 'VIM-Get-VimCmdVM', 'VIM-Set-Value', 
               'Get-VMFolder-ToRoot', 'VIM-Search-VM', 'Get-VMEvents', 'Deploy-Ova', 
               'Get-OvaConfigTemplateScript'

# Aus diesem Modul zu exportierende DSC-Ressourcen
# DscResourcesToExport = @()

# Liste aller Module in diesem Modulpaket
# ModuleList = @()

# Liste aller Dateien in diesem Modulpaket
# FileList = @()

# Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen. Diese können auch eine PSData-Hashtabelle mit zusätzlichen von PowerShell verwendeten Modulmetadaten enthalten.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        ExternalModuleDependencies = 'VMware.PowerCLi'

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
# DefaultCommandPrefix = ''

}

