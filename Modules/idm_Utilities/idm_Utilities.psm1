<#
.SYNOPSIS
Modul mit nützlichen Funktionen für NetIQ Identity Manager.
.DESCRIPTION
Module mit nützlichen Funktionen für NetIQ Identity Manager zur Verwaltung von Homedirectory und Exchange.
.NOTES
Version:      5
Autor:        Matthias Absmeier, ZIM Universität Passau
Installation: unter C:\Program Files\WindowsPowerShell\Modules\idm_Utilities\idm_Utilities.psm1 speichern
installiert auf dc2, dc1test
#>

function idm_Create-HomeDirectory {
<#
.SYNOPSIS
Legt ein HomeDirectory an.
.DESCRIPTION
Legt ein HomeDirectory für den angegebenen Benutzer an, setzt NTFS-Rechte und das AD-Attribut HomeDirectory, falls noch nicht passiert.
.PARAMETER User
Name des Benutzers
.PARAMETER InZim
$true um für ZIM-Mitarbeiter auf anderes Volume umzuleiten
.EXAMPLE
idm_Create-HomeDirectory -User "tester42" -InZim $true
Legt HomeDirectory für Benutzer tester42 auf dem ZIM-Volume an.
#>
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,    
        [Parameter(Mandatory=$false)]
        [Boolean]
        $InZIM
    )

    $HomePath = (idm_Generate-DefaultHomeDirectoryBasePath -InZIM $InZIM) + '\' + $User
    # Anlegen, wenn nicht vorhanden
    if(-Not(Test-Path($HomePath))) {
        "Ordner $HomePath anlegen..."
        New-Item -ItemType Directory -Path $HomePath
    }
    # Rechte setzen, wenn nötig
    $FolderACL = Get-Acl -Path $HomePath
    if(-Not($FolderACL.Access | ? { $_.IdentityReference -eq "$env:USERDOMAIN\$User" -and $_.FileSystemRights -eq 'FullControl' })) {
        "Vollzugriff für $User auf $HomePath eintragen..."
        $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERDOMAIN\$User",'FullControl','ContainerInherit, ObjectInherit', 'None', 'Allow') 
        $FolderACL.SetAccessRule($Rule)
        Set-Acl -Path $HomePath -AclObject $FolderACL
    }
    Import-Module ActiveDirectory -ErrorAction Stop
    "$Path als HomeDirectory bei $User setzen..."
    Set-ADUser -Identity $User -HomeDirectory $HomePath -HomeDrive 'H:'
}

function idm_Delete-HomeDirectory {
<#
.SYNOPSIS
Löscht ein HomeDirectory.
.DESCRIPTION
Löscht das angegebene HomeDirectory oder fügt vorne "__" an, falls das Löschen fehlgeschlagen ist.
.PARAMETER Path
Vollständiger UNC-Pfad zum HomeDirectory
.EXAMPLE
idm_Delete-HomeDirectory -Path "\\winf2\home\tester42"
Löscht das HomeDirectory unter \\winf2\home\tester42.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

    Remove-Item -Path $Path -Recurse -Force
    if(Test-Path -Path $Path) { # Umbenennen wenn Löschen fehlgeschlagen
        Rename-Item -Path $Path -NewName "__$(Split-Path -Path $Path -Leaf)"
    }
}

function idm_Disable-Exchange {
<#
.SYNOPSIS
Deaktiviert eine Exchange-Mailbox.
.DESCRIPTION
Deaktiviert die Exchange-Mailbox für den angegebenen Benutzer.
.PARAMETER User
Name des Benutzers
.EXAMPLE
idm_Disable-Exchange -User "tester42"
Deaktiviert die Exchange-Mailbox für Benutzer tester42.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User
    )

    Disable-Mailbox -Identity $User -Confirm:$false
}

function idm_Disable-ExchangeDelivery {
<#
.SYNOPSIS
Deaktiviert den E-Mail-Empfang in Exchange.
.DESCRIPTION
Deaktiviert den E-Mail-Empfang in Exchange, wenn die Kennung abgelaufen ist.
.PARAMETER User
Name des Benutzers
.EXAMPLE
idm_Disable-ExchangeDelivery -User "tester42"
Deaktiviert den E-Mail-Empfang in Exchange für Benutzer tester42.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User
    )

    Set-Mailbox -Identity $User -AcceptMessagesOnlyFrom @{Add=$User}
}

function idm_Enable-Exchange {
<#
.SYNOPSIS
Richtet eine neue Exchange-Mailbox ein.
.DESCRIPTION
Richtet eine neue Exchange-Mailbox für den angegebenen Benutzer ein, 
schaltet ihn sichtbar im Adressbuch und setzt die Quota auf 4 GB.
.PARAMETER User
Name des Benutzers
.PARAMETER Hidden
$true um im Adressbuch unsichtbar zu sein, $false sonst
.EXAMPLE
idm_Enable-Exchange -User "tester42" -Hidden $true
Richtet eine neue Exchange-Mailbox für Benutzer tester42 ein.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,    
        [Parameter(Mandatory=$true)]
        [Boolean]
        $Hidden
    )

    if($env:USERDOMAIN -eq 'ADS') { # Angabe des DC wegen nicht angelegten Mailboxen bei Erzeugung von Kurskennungen
        Enable-Mailbox -Identity $User -DomainController dc2.ads.uni-passau.de
        Set-Mailbox -Identity $User -DomainController dc2.ads.uni-passau.de -HiddenFromAddressListsEnabled $Hidden `
            -AddressBookPolicy 'UP_StandardABP' -OfflineAddressBook 'UP_OfflineAdressbuch' `
            -ProhibitSendReceiveQuota 4GB -ProhibitSendQuota 4089447KB -IssueWarningQuota 3584MB -UseDataBaseQuotaDefaults $false
    } else {
        Enable-Mailbox -Identity $User
        Set-Mailbox -Identity $User -HiddenFromAddressListsEnabled $false
    }    
}

function idm_Enable-ExchangeDelivery {
<#
.SYNOPSIS
Reaktiviert den E-Mail-Empfang in Exchange.
.DESCRIPTION
Reaktiviert den E-Mail-Empfang in Exchange, wenn eine abgelaufene Kennung verlängert wird.
.PARAMETER User
Name des Benutzers
.EXAMPLE
idm_Enable-ExchangeDelivery -User "tester42"
Reaktiviert den E-Mail-Empfang in Exchange für Benutzer tester42.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User
    )

    Set-Mailbox -Identity $User -AcceptMessagesOnlyFrom @{Remove=$User}
}

function idm_Generate-DefaultHomeDirectoryBasePath {
<#
.SYNOPSIS
Erzeugt den Standard-UNC-Basispfad für Benutzer.
.DESCRIPTION
Erzeugt den Standard-UNC-Basispfad für Benutzer abhängig von der aktuellen Domäne.
.PARAMETER InZim
$true um für ZIM-Mitarbeiter auf anderes Volume umzuleiten
.EXAMPLE
idm_Generate-DefaultHomeDirectoryBasePath
gibt "\\winfs2\home" zurück
#>
    Param(
        [Parameter(Mandatory=$false)]
        [Boolean]
        $InZIM
    )

    if($env:USERDOMAIN -eq 'ADS') {
        if($InZIM) {
            return '\\winfs1\zim'
        } else {
            return '\\winfs2\home'
        }      
    } else {
        if($InZIM) {
            return '\\dc1test\zim'
        } else {
            return '\\dc1test\home'
        }
    }
}

function idm_Rename-HomeDirectoryAndMailNickname {
<#
.SYNOPSIS
Benennt das HomeDirectory um und aktualisiert die Attribute homeDirectory und mailNickname im AD.
.DESCRIPTION
Benennt das HomeDirectory um und aktualisiert die Attribute homeDirectory und mailNickname im AD. Diese Aktion muss ausgeführt werden, wenn das AD-Objekt schon umbenannt ist.
.PARAMETER OldUserName
alter Benutzername
.PARAMETER NewUserName
neuer Benutzername
.EXAMPLE
idm_Rename-HomeDirectoryAndMailNickname -OldUserName "tester42" -NewUserName "tester43"
Benennt das HomeDirectory um und aktualisiert die Attribute homeDirectory und mailNickname im AD.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $OldUserName,
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $NewUserName
    )

    Import-Module ActiveDirectory -ErrorAction Stop
    $ADUser = Get-AdUser -Identity $NewUserName -Properties HomeDirectory,mailNickname
    $OldHomePath = $ADUser.HomeDirectory
    if((Split-Path -Path $OldHomePath -Leaf) -ne $NewUserName) {
        # Ordner umbenennen
	    if($OldHomePath -match '^\\\\(winfs|dc1test).*') { # nur bei Windows-Fileserver
	        Rename-Item -Path $OldHomePath -NewName $NewUserName
        }
        # HomeDirectory-Attribut aktualisieren
        Set-ADUser -Identity $NewUserName -HomeDirectory ((Split-Path -Path $OldHomePath -Parent) + "\$NewUserName") -HomeDrive 'H:'
    }
    # mailNickname aktualisieren, ändert auch die primäre E-Mail-Adresse falls die Default-Policy aktiv ist, 
    # die alte E-Mail-Adresse bleibt als sekundäre Adresse erhalten
    if($ADUser.mailNickname -and $ADUser.mailNickname -ne $NewUserName) { 
        Set-Mailbox -Identity $NewUserName -Alias $NewUserName
    }
}

function idm_Set-ExchangeDutyEmail {
<#
.SYNOPSIS
Setzt eine Dienstliche E-Mail-Adresse
.DESCRIPTION
Setzt eine Dienstliche E-Mail-Adresse in Exchange, deaktiviert die Standard-Policy und aktiviert die Adressbuchsichtbarkeit.
.PARAMETER User
Name des Benutzers
.PARAMETER DutyEmail
Dienstliche E-Mail-Adresse ^.*(\.|-).*@uni-passau\.de$
.EXAMPLE
idm_Set-ExchangeDutyEmail -User "tester42"
Reaktiviert den E-Mail-Empfang in Exchange für Benutzer tester42.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^.*(\.|-).*@uni-passau\.de$')]
        [String]
        $DutyEmail
    )

    #SMTP GROSS Geschrieben ist die Primary E-Mail
    Set-Mailbox -Identity $User -EmailAddresses @{Add="SMTP:$DutyEmail"} -HiddenFromAddressListsEnabled $false -CustomAttribute10 $DutyEmail
}

function idm_Set-HomeQuota {
<#
.SYNOPSIS
Setzt Quota für Benutzer-Homedirectory.
.DESCRIPTION
Setzt Quota für Benutzer-Homedirectory auf übergebenem Wert.
.PARAMETER User
Name des Benutzers
.PARAMETER SizeInGB
neue Quota in GB
.EXAMPLE
idm_Set-HomeQuota -User muster42 -SizeInGB 2
setzt die Quota für \\winfs2\home\muster42 auf 2 GB
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,
        [Parameter(Mandatory=$true)]
        [ValidateRange(1,1000000)]
        [int]
        $SizeInGB
    )

    Import-Module ActiveDirectory -ErrorAction Stop
    $ADUser = Get-AdUser -Identity $User -Properties HomeDirectory
    $HomePath = $ADUser.HomeDirectory
    if($HomePath) {
        $LocalPath = $HomePath -replace '^\\\\dc1test(\.adstest\.uni-passau\.de)?\\home','C:\freigaben\HOME' `
            -replace '^\\\\winfs2(\.ads\.uni-passau\.de)?\\home','f:'
        $Size = $SizeInGB * 1GB
        "Quota von $HomePath wird auf $SizeInGB GB gesetzt..."
        Invoke-Command -ComputerName $(($HomePath -split '\\')[2]) { Set-FsrmQuota -Path $using:LocalPath -Size $using:Size }
    } else {
        "$HomePath existiert nicht oder ist kein Ordner"
    }
}