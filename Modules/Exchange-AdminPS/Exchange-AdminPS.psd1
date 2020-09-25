﻿#
# Modulmanifest für das Modul "PSGet_Exchange-AdminPS"
#
# Generiert von: achter <Rudolf.Achter@uni-passau.de>
#
# Generiert am: 25.09.2020
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
RootModule = 'Exchange-AdminPS.psm1'

# Die Versionsnummer dieses Moduls
ModuleVersion = '1.10'

# Unterstützte PSEditions
# CompatiblePSEditions = @()

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = 'a96a23a3-639d-47f2-8a6c-d1ef62eadf16'

# Autor dieses Moduls
Author = 'achter <Rudolf.Achter@uni-passau.de>'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = 'Unbekannt'

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2019 Achter, Rudolf <rudolf.achter@megatech-communication.de>. Alle Rechte vorbehalten.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'Helper Modul für Exchange Administration aus normaler Powershell heraus'

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
FunctionsToExport = 'Show-ManagementRoles', 'Get-ServiceConnectionEndpoint', 
               'Get-MessageTrackingAllLogs', 'Connect-LDAP', 'Get-DiskInfo', 
               'Get-ManagedADObject', 'Sync-ExchangeRbacSelfManagement', 
               'Convert-QuotaStringToKB', 'Reload-OfflineAddressBook', 
               'Set-MailboxQuota', 'Search-PostfixTable', 'Get-MailboxQuota', 
               'Show-MailboxFolderPermissionRecursive', 'Get-QuestCMGLog', 
               'Test-MailFromExternal', 'ConvertTo-RegularMailbox', 
               'Add-TeamMailboxPermissions', 'Get-RandomCharacters', 
               'Get-MailboxFolderPermissionRecursive', 'Get-MailboxTopX', 
               'New-TeamDistributionGroup', 'Get-ADUsers', 
               'Check-ExchangePostfixTables', 'New-TeamSharedMailbox', 
               'Connect-Exchange', 'Add-TeamDistributionGroupPermissions', 
               'Get-RandomPassword', 'New-PostfixEntry', 'Get-MailboxDatabaseSize', 
               'Get-MailboxCalendarPermission', 'Get-PostfixTable', 
               'Search-MailAddress', 'Get-AutoMapping', 'Check-MailAddressExistance', 
               'Get-QuestCMGProcessedMessages', 'Get-PostfixSession', 
               'Invoke-Postmap', 'Invoke-DelayedAction', 
               'Sync-GroupPublicFolderPermissions', 'zimStart-Update', 
               'Sync-RbacSelfManagementRights', 
               'Copy-DistributionGroupMembersToSendOnBehalf', 'zimEnd-Update', 
               'Get-LdapSearchEntries', 'Move-ExchangeUser'

# Aus diesem Modul zu exportierende Cmdlets. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Cmdlets vorhanden sind.
CmdletsToExport = @()

# Die aus diesem Modul zu exportierenden Variablen
# VariablesToExport = @()

# Aus diesem Modul zu exportierende Aliase. Um optimale Leistung zu erzielen, verwenden Sie keine Platzhalter und löschen den Eintrag nicht. Verwenden Sie ein leeres Array, wenn keine zu exportierenden Aliase vorhanden sind.
AliasesToExport = 'Get-SCP'

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
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
# DefaultCommandPrefix = ''

}

