<#
.SYNOPSIS
Modul mit nützlichen Funktionen.
.DESCRIPTION
Module mit nützlichen Funktionen zur Verwaltung von Homedirectory, DFS-Ordner-Berechtigungen, Datenmigration usw..
.NOTES
Version:      14
Autor:        Matthias Absmeier, ZIM Universität Passau
Installation: unter C:\Program Files\WindowsPowerShell\Modules\zim_Utilities\zim_Utilities.psm1 speichern
installiert auf admin, dc1test
#>

<#
Parameter-Validierung:
DutyEmail [ValidatePattern('^.*(\.|-).*@uni-passau\.de$')]
Group     [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
User      [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
#>

function zim_Add-DfsnAccess {
<#
.SYNOPSIS
Fügt Leseberechtigung zu DFS-Ordner hinzu.
.DESCRIPTION
Fügt Leseberechtigung für angegebene Kennung oder Gruppe zu DFS-Ordner hinzu.
.PARAMETER Path
Pfad des DFS-Ordner
.PARAMETER User
Zu berechtigende Kennung oder Gruppe
.EXAMPLE
zim_Add-DfsnAccess -Path \\ADS\grp\Q001 -User Q001
Fügt Leseberechtigung für Gruppe Q001 zu DFS-Ordner \\ADS\grp\Q001 hinzu.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [String]
        $User
    )

    dfsutil.exe property SD grant ($Path) ($User + ':RX') protect
}

function zim_Create-GroupDirectory {
<#
.SYNOPSIS
Legt ein Gruppen-Directory an.
.DESCRIPTION
Legt ein Gruppen-Directory für die angegebene Gruppe an und setzt Vollzugriff für die Gruppe bei den NTFS-Rechten.
.PARAMETER Group
Name der Gruppe
.PARAMETER Protected
$true um für Daten mit hohem Schutzbedarf auf anderes Volume umzuleiten
.EXAMPLE
zim_Create-GroupDirectory -Group "V042" -Protected $true
Legt Gruppen-Directory für Gruppe V042 auf Volume mit hohem Schutzbedarf an.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
        [String]
        $Group,
        [Parameter(Mandatory=$false)]
        [Boolean]
        $Protected
    )

    $GroupPath = zim_Generate-DefaultGroupDirectoryPath -Group $Group -Protected $Protected
    # Anlegen, wenn nicht vorhanden
    if(-Not(Test-Path($GroupPath))) {
        "Ordner $GroupPath anlegen..."
        New-Item -ItemType Directory -Path $GroupPath
    }
    # Rechte setzen, wenn nötig
    $FolderACL = Get-Acl -Path $GroupPath
    if(-Not($FolderACL.Access | ? { $_.IdentityReference -eq "$env:USERDOMAIN\$Group" -and $_.FileSystemRights -eq "FullControl" })) {
        "Vollzugriff für $Group auf $GroupPath eintragen..."
        $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERDOMAIN\$Group","FullControl","ContainerInherit, ObjectInherit", "None", "Allow") 
        $FolderACL.SetAccessRule($Rule)
        Set-Acl -Path $GroupPath -AclObject $FolderACL
    }
}

function zim_Create-GroupAndDirectory {
<#
.SYNOPSIS
Legt IDM-Gruppe und Gruppen-Directory an.
.DESCRIPTION
Legt IDM-Gruppe und Gruppen-Directory an und setzt Vollzugriff für die Gruppe bei den NTFS-Rechten.
.PARAMETER Group
Name der Gruppe
.EXAMPLE
zim_Create-GroupAndDirectory -Group "V042"
Legt Gruppe und Ordner V042 an.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
        [String]
        $Group
    )

    Import-Module ActiveDirectory -ErrorAction Stop
    New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security -Path "ou=group,ou=idm,dc=$env:USERDOMAIN,dc=uni-passau,dc=de"
    Get-ADGroup -Identity $Group | Set-ADObject -ProtectedFromAccidentalDeletion $true
    zim_Create-GroupDirectory -Group $Group
}

function zim_Create-HomeDirectory {
<#
.SYNOPSIS
Legt ein HomeDirectory an.
.DESCRIPTION
Legt ein HomeDirectory für den angegebenen Benutzer an, setzt NTFS-Rechte und das AD-Attribut HomeDirectory, falls noch nicht passiert.
.PARAMETER User
Name des Benutzers
.PARAMETER Csv
Pfad zu CSV-Datei mit Benutzernamen, Überschrift "User".
.PARAMETER InZim
$true um für ZIM-Mitarbeiter auf anderes Volume umzuleiten
.PARAMETER DontSetADAttribute
Schalter um HomeDirectory anzulegen, aber nicht im AD zu setzen (z.B. bei Migration)
.EXAMPLE
zim_Create-HomeDirectory -User "tester42" -InZim $true
Legt HomeDirectory für Benutzer tester42 auf dem ZIM-Volume an.
#>
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,    
        [Parameter(Mandatory=$false,ParameterSetName='Path')]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]
        $Csv,
        [Parameter(Mandatory=$false)]
        [Boolean]
        $InZIM,
        [Parameter(Mandatory=$false)]
        [Switch]
        $DontSetADAttribute
    )

    if(!$Csv){
        $entries = New-Object psobject -Property @{User=$User}
    } else {
        $entries = Import-Csv -Delimiter ';' -Path $Csv
        foreach($Entry in $entries) { # trim whitespace
            foreach($Prop in $Entry.PSObject.Properties) {
                $Prop.Value = $Prop.Value.Trim()
            }
        }
    }
    foreach ($entry in $entries) {
        $HomePath = (zim_Generate-DefaultHomeDirectoryBasePath -InZIM $InZIM) + '\' + $entry.User
        # Anlegen, wenn nicht vorhanden
        if(-Not(Test-Path($HomePath))) {
            "Ordner $HomePath anlegen..."
            New-Item -ItemType Directory -Path $HomePath
        }
        # Rechte setzen, wenn nötig
        $FolderACL = Get-Acl -Path $HomePath
        if(-Not($FolderACL.Access | ? { $_.IdentityReference -eq "$env:USERDOMAIN\$($entry.User)" -and $_.FileSystemRights -eq 'FullControl' })) {
            "Vollzugriff für $($entry.User) auf $HomePath eintragen..."
            $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERDOMAIN\$($entry.User)",'FullControl','ContainerInherit, ObjectInherit', 'None', 'Allow') 
            $FolderACL.SetAccessRule($Rule)
            Set-Acl -Path $HomePath -AclObject $FolderACL
        }
        # Pfad in AD-Benutzer setzen
        if(-Not($DontSetADAttribute)) {
            zim_Register-HomeDirectory -User $entry.User -Path $HomePath
        }
    }
}

function zim_Delete-HomeDirectory {
<#
.SYNOPSIS
Löscht ein HomeDirectory.
.DESCRIPTION
Löscht das angegebene HomeDirectory, falls es auf einem Windows-Fileserver ist.
.PARAMETER Path
Vollständiger UNC-Pfad zum HomeDirectory
.EXAMPLE
zim_Delete-HomeDirectory -Path "\\winf2\home\tester42"
Löscht das HomeDirectory unter \\winf2\home\tester42.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

    # nur löschen, wenn auf Windows-Fileserver
    if($Path -match '^\\\\(winfs|dc1test).*') {
        Remove-Item -Path $Path -Recurse -Force
    }
}

function zim_Disable-EdirGroupDirectory {
<#
.SYNOPSIS
Bereinigt das eDirectory-Gruppen-Directory nach Umzug auf Windows Server.
.DESCRIPTION
Hängt an den Ordnernamen vorne "__" an und kommentiert die Kommandos im Novell-LoginScript des Profil-Objektes aus.
Mehr zu LDAP-Operationen mit Powershell: https://msdn.microsoft.com/en-us/library/bb332056.aspx
.PARAMETER GroupDirectoryUNC
UNC-Pfad zum Gruppen-Directory
.PARAMETER IdmmasterNovellPassword
Passwort von eDirectory-Benutzer idmmaster
.EXAMPLE
zim_Disable-EdirGroupDirectory -GroupDirectoryUNC "\\fs1.uni-passau.de\grp1\VW"
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $GroupDirectoryUNC,
        [Parameter(Mandatory=$true)]
        [String]
        $IdmmasterNovellPassword
    )

    # Ordner umbenennen
    $BasePath = Split-Path -Path $GroupDirectoryUNC -Parent
    $DirName = Split-Path -Path $GroupDirectoryUNC.ToUpper() -Leaf
    if(!(Test-Path($BasePath))) {
        zim_Map-Share -Path $BasePath -User 'idmmaster' -Password $IdmmasterNovellPassword
        if(!(Test-Path($HomeDirBasePath))) {
            return
        }
    }
    "$GroupDirectoryUNC umbenennen in __$DirName..."
    Rename-Item -Path $GroupDirectoryUNC -NewName "__$DirName"
    # Profil suchen
    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols") | Out-Null    
    if($env:USERDOMAIN -eq 'ADS') {
        $LdapServerPort = 'edir-idm.uni-passau.de:636'    
    } else {
        $LdapServerPort = 'edir-idm-test.uni-passau.de:636'  
    }
    $DirName = Split-Path -Path $GroupDirectoryUNC -Leaf
    $Connection = New-Object System.DirectoryServices.Protocols.LdapConnection $LdapServerPort
    $Connection.SessionOptions.ProtocolVersion = 3
    $Connection.SessionOptions.SecureSocketLayer = $true
    $Connection.SessionOptions.VerifyServerCertificate = { return $true }
    $Connection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic
    $Connection.Credential = New-Object 'System.Net.NetworkCredential' -ArgumentList 'cn=idmmaster,ou=idm,o=uni-passau',$IdmmasterNovellPassword
    $connection.Bind()
    $BaseDN = 'o=uni-passau'
    $Filter = "(&(objectClass=Profile)(cn=$DirName))"
    $Scope = [System.DirectoryServices.Protocols.SearchScope]::SubTree
    $SearchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest -ArgumentList $BaseDN,$Filter,$Scope,'loginScript'
    $SearchResult = $Connection.SendRequest($SearchRequest)
    if($SearchResult.Entries.Count -eq 0 -or !($SearchResult.Entries.Attributes['loginScript'])) {
        "Profil $DirName nicht gefunden oder kein LoginScript vorhanden"
    } else { # LoginScript auskommentieren
        $NewLoginScript = ''
        forEach($Line in $SearchResult.Entries.Attributes['loginScript'].GetValues('string') -split "`r`n") {
            $NewLoginScript += ";$line`r`n"
        }
        $ModifyType = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
        "loginScript von Profil $($SearchResult.Entries[0].DistinguishedName) auskommentieren:"
        $NewLoginScript
        $ModifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest -ArgumentList $SearchResult.Entries[0].DistinguishedName,$ModifyType,'loginScript',$NewLoginScript
        $ModifyResponse = $Connection.SendRequest($ModifyRequest)
        $ModifyResponse.ResultCode
    }
}

function zim_Disable-EdirHomeDirectory {
<#
.SYNOPSIS
Bereinigt das eDirectory-HomeDirectory nach Umzug auf Windows Server.
.DESCRIPTION
Liest den HomeDirectory-Pfad aus dem eDirectory-Objekt, hängt an den Ordnernamen vorne "__" an und entfernt den HomeDirectory-Pfad aus dem eDirectory-Objekt.
Optional: Ergänzt Novell-LoginScript um Mapping des neuen HomeDirectory's.
Mehr zu LDAP-Operationen mit Powershell: https://msdn.microsoft.com/en-us/library/bb332056.aspx
.PARAMETER User
Name des Benutzers
.PARAMETER Csv
Pfad zu CSV-Datei mit Benutzernamen, Überschrift "User".
.PARAMETER InZim
$true um für ZIM-Mitarbeiter auf anderes Volume umzuleiten
.PARAMETER IdmmasterNovellPassword
Passwort von eDirectory-Benutzer idmmaster
.PARAMETER UpdateNovellLoginScript
Schalter, um Mapping des neuen HomeDirectory's ins Novell-Loginscript einzutragen
.EXAMPLE
zim_Disable-EdirHomeDirectory -User "tester42"
#>
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Single')]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,
        [Parameter(Mandatory=$true,ParameterSetName='Csv')]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]
        $Csv,
        [Parameter(Mandatory=$false)]
        [Boolean]
        $InZim,
        [Parameter(Mandatory=$true)]
        [String]
        $IdmmasterNovellPassword,
        [Parameter(Mandatory=$false)]
        [Switch]
        $UpdateNovellLoginScript
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols") | Out-Null 
    if(!$Csv){
        $Cns = New-Object psobject -Property @{User=$User}
    } else {
        $Cns = Import-Csv -Delimiter ';' -Path $Csv
        foreach($Entry in $Cns) { # trim whitespace
            foreach($Prop in $Entry.PSObject.Properties) {
                $Prop.Value = $Prop.Value.Trim()
            }
        }
    }       
    if($env:USERDOMAIN -eq 'ADS') {
        $LdapServerPort = 'edir-idm.uni-passau.de:636'    
    } else {
        $LdapServerPort = 'edir-idm-test.uni-passau.de:636'  
    }
    $LoginScriptCommand = '#cmd /c net use h: ' + (zim_Generate-DefaultHomeDirectoryBasePath -InZIM $InZim) + `
        "\%NWUSERNAME% /user:$env:USERDNSDOMAIN\%NWUSERNAME% /persistent:no`r`nset HOMEDRIVE=`"H:`"`r`nset HOMEPATH=`"\\`""
    $Connection = New-Object System.DirectoryServices.Protocols.LdapConnection $LdapServerPort
    $Connection.SessionOptions.ProtocolVersion = 3
    $Connection.SessionOptions.SecureSocketLayer = $true
    $Connection.SessionOptions.VerifyServerCertificate = { return $true }
    $Connection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic
    $Connection.Credential = New-Object 'System.Net.NetworkCredential' -ArgumentList 'cn=idmmaster,ou=idm,o=uni-passau',$IdmmasterNovellPassword
    $connection.Bind()
    $BaseDN = 'o=uni-passau'
    $Filter = '(|(cn=' + ($cns.User -join ')(cn=') + '))'
    $Scope = [System.DirectoryServices.Protocols.SearchScope]::SubTree
    $SearchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest -ArgumentList $BaseDN,$Filter,$Scope,'*'
    $SearchResult = $Connection.SendRequest($SearchRequest)
    foreach($Entry in $SearchResult.Entries) {
        if($Entry.Attributes['ndsHomeDirectory']) {
            $HomeDirArr = $Entry.Attributes['ndsHomeDirectory'].GetValues('string').split(',')
            $HomeDirBasePath = '\\' + $HomeDirArr[0].Substring(3).Replace('_','.uni-passau.de\')
            if(!(Test-Path($HomeDirBasePath))) {
                zim_Map-Share -Path $HomeDirBasePath -User 'idmmaster' -Password $IdmmasterNovellPassword
                if(!(Test-Path($HomeDirBasePath))) {
                    return
                }
            }
            $HomeDirName = $HomeDirArr[2].split('#')[2]            
            $HomeDirPath = "$HomeDirBasePath\$HomeDirName"         
            "$HomeDirPath umbenennen in __$HomeDirName..."
            Rename-Item -Path $HomeDirPath -NewName "__$HomeDirName"
            "ndsHomeDirectory von $($Entry.DistinguishedName) entfernen..."
            $ModifyType = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Delete
            $ModifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest -ArgumentList $Entry.DistinguishedName,$ModifyType,'ndsHomeDirectory'
            $ModifyResponse = $Connection.SendRequest($ModifyRequest)
            $ModifyResponse.ResultCode
            if($UpdateNovellLoginScript) {
                $ModifyType = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Add
                $NewLoginScript = $LoginScriptCommand
                if($Entry.Attributes['loginScript']) { # LoginScript existiert: vorne anfügen
                    $Entry.Attributes['loginScript'].GetValues('string')
                    $ModifyType = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
                    $NewLoginScript = $LoginScriptCommand + "`r`n" + $Entry.Attributes['loginScript'].GetValues('string')
                }
                "loginScript von $($Entry.DistinguishedName) um Mapping ergänzen..."            
                $ModifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest -ArgumentList $Entry.DistinguishedName,$ModifyType,'loginScript',$NewLoginScript
                $ModifyResponse = $Connection.SendRequest($ModifyRequest)
                $ModifyResponse.ResultCode
            }
        } else {
            "$($Entry.DistinguishedName) hat kein ndsHomeDirectory"
        }
    }    
}

function zim_Display-TooLongPaths {
<#
.SYNOPSIS
Zeigt zu lange Dateipfade an.
.DESCRIPTION
Zeigt ausgehend vom angegebenen Basis-Ordner zu lange Dateipfade an (>260 Zeichen).
.PARAMETER BasePath
Basis-Pfad der Dateien und Ordner
.PARAMETER LongerThan
max. erlaubte Pfadlänge (260 wenn nicht angegeben)
.EXAMPLE
zim_Display-TooLongPaths -BasePath \\winfs1\grp1\Q001
Zeigt alle Pfade unterhalb von \\winfs1\grp1\Q001, die insgesamt länger als 260 Zeichen sind.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $BasePath,
        [Parameter(Mandatory=$false)]
        [int]
        $LongerThan
    )

    if(-Not($LongerThan)) {
        $LongerThan = 260 # erst über 260 Zeichen gibt es Probleme
    }
    Get-ChildItem $BasePath -Recurse | select -Expand fullname | ? { $_.Length -gt $LongerThan } 
}

function zim_Error-Notify {
<#
.SYNOPSIS
Benachrichtigung bei Fehler
.DESCRIPTION
Benachrichtigt per E-Mail und gibt den Fehler auf der Standardausgabe aus.
.PARAMETER Message
Fehlernachricht
.EXAMPLE
zim_Error-Nofify -Message "Fehler xy"
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Message
    )

    $Message
    $ScriptName = Split-Path $PSCommandPath -Leaf
    zim_Send-Email -an 'matthias.absmeier@uni-passau.de' -Betreff "$ScriptName : Fehler aufgetreten" -Nachricht $Message
}

function zim_Generate-DefaultGroupDirectoryPath {
<#
.SYNOPSIS
Erzeugt den Standard-UNC-Pfad für die angegebene Gruppe.
.DESCRIPTION
Erzeugt den Standard-UNC-Pfad für die angebebene Gruppe abhängig von der aktuellen Domäne.
.PARAMETER Group
Name der Gruppe
.PARAMETER Protected
$true um für Daten mit hohem Schutzbedarf auf anderes Volume umzuleiten
.EXAMPLE
zim_Generate-DefaultGroupDirectoryBasePath
gibt "\\winfs1\grp1" zurück
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
        [String]
        $Group,
        [Parameter(Mandatory=$false)]
        [Boolean]
        $Protected
    )

    $Group = $Group.ToUpper()
    if($env:USERDOMAIN -eq 'ADS') {
        if($Protected) {
            return "\\winfs3\grp3\$Group-S"
        } else {
            return "\\winfs1\grp1\$Group"
        }      
    } else {
        if($Protected) {
            return "\\dc1test\grp3\$Group-S"
        } else {
            return "\\dc1test\grp1\$Group"
        }
    }
}

function zim_Generate-DefaultHomeDirectoryBasePath {
<#
.SYNOPSIS
Erzeugt den Standard-UNC-Basispfad für Benutzer.
.DESCRIPTION
Erzeugt den Standard-UNC-Basispfad für Benutzer abhängig von der aktuellen Domäne.
.PARAMETER InZim
$true um für ZIM-Mitarbeiter auf anderes Volume umzuleiten
.EXAMPLE
zim_Generate-DefaultHomeDirectoryBasePath
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

function zim_Generate-DefaultNovellHomeDirectoryQuota {
<#
.SYNOPSIS
Gibt die Standard-Quota für Novell-Benutzer in Bytes zurück.
.DESCRIPTION
Gibt die Standard-Quota für Novell-Benutzer in Bytes abhängig vom übergebenen DistinguishedName zurück.
.PARAMETER DistinguishedName
DistinguishedName des Benutzers
.EXAMPLE
zim_Generate-DefaultNovellHomeDirectoryQuota -DistinguishedName 'cn=test42,ou=sonst,o=uni-passau'
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $DistinguishedName
    )

    switch -Wildcard($DistinguishedName) {
        "*,ou=stud,*" { return 367001600 } # 350 MB
        "*,ou=rz,*" { return 9999999999999 } # unbegrenzt
        default { return 524288000 } # 500 MB
    }
}

function zim_Generate-DefaultNovellHomeDirectoryVolumeName {
<#
.SYNOPSIS
Gibt das Standard-Volume für Novell-Benutzer zurück.
.DESCRIPTION
Gibt das Standard-Volume für Novell-Benutzer abhängig vom übergebenen DistinguishedName zurück.
.PARAMETER DistinguishedName
DistinguishedName des Benutzers
.EXAMPLE
zim_Generate-DefaultNovellHomeDirectoryVolumeName -DistinguishedName 'cn=test42,ou=sonst,o=uni-passau'
gibt "fs1_USER1" zurück
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $DistinguishedName
    )

    if($env:USERDOMAIN -eq 'ADS') {
        switch -Wildcard($DistinguishedName) {
            "*,ou=a-h,ou=stud,*" { return 'fs2_USER1' }
            "*,ou=i-p,ou=stud,*" { return 'fs2_USER2' }
            "*,ou=q-z,ou=stud,*" { return 'fs2_USER3' }
            "*,ou=sonst,ou=stud,*" { return 'fs2_USER4' }
            "*,ou=rz,*" { return 'fs1_ZIM' }
            default { return 'fs1_USER1' }
        }    
    } else {
        switch -Wildcard($DistinguishedName) {
            "*,ou=i-p,ou=stud,*" { return 'edir-idm-test_USER2' }
            "*,ou=q-z,ou=stud,*" { return 'edir-idm-test_USER3' }
            "*,ou=sonst,ou=stud,*" { return 'edir-idm-test_USER4' }
            "*,ou=rz,*" { return 'edir-idm-test_ZIM' }
            default { return 'edir-idm-test_USER1' }
        }  
    }
}

function zim_Get-FolderSize {
<#
.SYNOPSIS
Gibt die Ordnergröße für den angegebenen Ordnerpfad in Bytes zurück.
.DESCRIPTION
Gibt die Ordnergröße für den angegebenen Ordnerpfad in Bytes zurück.
.PARAMETER FolderPath
UNC-Pfad zum Ordner
.EXAMPLE
zim_Get-FolderSize -FolderPath '\\winfs2\home\muster42'
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [String]
        $FolderPath
    )
    
    return (Get-ChildItem -Path $FolderPath -Recurse -Force | ? { !($_.PSIsContainer) } | Measure-Object -Property Length -Sum).Sum
}

function zim_Get-Quota {
<#
.SYNOPSIS
Gibt Quota von übergebenem UNC-Pfad zurück.
.DESCRIPTION
Gibt Quota von übergebenem UNC-Pfad zurück.
Erlaubte Pfade:
\\winfs2\home\*
\\winfs1\grp1\*
\\winfs3\grp3\*
\\winfs2\nas1\*
.PARAMETER Path
UNC-Pfad zu Ordner
.EXAMPLE
zim_Get-Quota -Path \\winfs2\home\muster42
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^\\\\winfs(2(\.ads\.uni-passau\.de)?\\(home|nas1)|1(\.ads\.uni-passau\.de)?\\grp1|3(\.ads\.uni-passau\.de)?\\grp3)\\.*$')]
        [String]
        $Path
    )
    if(Test-Path $Path -PathType Container) {
        $LocalPath = $Path -replace '^\\\\winfs2(\.ads\.uni-passau\.de)?\\home','f:' `
            -replace '^\\\\winfs1(\.ads\.uni-passau\.de)?\\grp1','g:' `
            -replace '^\\\\winfs(2|3)(\.ads\.uni-passau\.de)?\\(grp3|nas1)','e:'
        Invoke-Command -ComputerName $Path.Substring(2,6) { Get-FsrmQuota -Path $using:LocalPath -ErrorAction SilentlyContinue }
    } else {
        "$Path existiert nicht oder ist kein Ordner"
    }
}

function zim_Manage-Quota {
<#
.SYNOPSIS
Interaktive Verwaltung von Quotas.
.DESCRIPTION
Interaktive Verwaltung von Quotas.
Man kann Gruppe, Benutzer oder UNC-Pfad übergeben, oder wird danach gefragt.
Erst wird die aktuelle Quota angezeigt, die man dann ändern kann.
- bei Angabe von Gruppe:
  \\winfs1\grp1\[Gruppe]
  \\winfs3\grp3\[Gruppe]-S
  \\winfs2\nas1\[Gruppe]-BigData
- bei Angabe von Benutzer:
  \\winfs2\home\[Benutzer]
Erlaubte Pfade:
\\winfs2\home\*
\\winfs1\grp1\*
\\winfs3\grp3\*
\\winfs2\nas1\*
.PARAMETER UserInput
Gruppe, Benutzer oder UNC-Pfad
.EXAMPLE
zim_Manage-Quota P042
zim_Manage-Quota muster42
zim_manage-Quota \\winfs2\nas1\P042-BigData
#>
    Param(
        [Parameter(Mandatory=$false)]
        [String]
        $UserInput
    )
    if($env:USERDOMAIN -ne 'ADS') {
        'Das funktioniert nur in Domäne ADS :('
        return
    }
    if(!$UserInput) {
        $UserInput = Read-Host -Prompt 'Kennung, Gruppe oder UNC-Pfad angeben'
    }
    if(!$UserInput) {
        return
    }
    switch -Regex ($UserInput) {
        '^(I|J|P|S|V|W)[0-9]{3}$' {
            foreach($Path in "\\winfs1\grp1\$UserInput","\\winfs3\grp3\$UserInput-S","\\winfs2\nas1\$UserInput-BigData") {
                $Quota = zim_Get-Quota -Path $Path
                if($Quota.GetType().Name -eq 'CimInstance') {
                    "$Path`: Quota $([math]::Round($Quota.Size / 1GB, 1)) GB, $([math]::Round($Quota.Usage * 100 / $Quota.Size)) % belegt ($($Quota.Template))"
                    $NewQuotaInGB = Read-Host -Prompt 'Neue Quota in GB angeben (Enter zum Überspringen)'
                    if($NewQuotaInGB) {
                        zim_Set-Quota -Path $Path -SizeInGB $NewQuotaInGB
                    }
                } else {
                    $Quota
                }
            }
        }
        '^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$' {
            $Quota = zim_Get-Quota -Path "\\winfs2\home\$UserInput"
            if($Quota.GetType().Name -eq 'CimInstance') {
                "\\winfs2\home\$UserInput`: Quota $([math]::Round($Quota.Size / 1GB, 1)) GB, $([math]::Round($Quota.Usage * 100 / $Quota.Size)) % belegt ($($Quota.Template))"
                $NewQuotaInGB = Read-Host -Prompt 'Neue Quota in GB angeben (Enter zum Überspringen)'
                if($NewQuotaInGB) {
                    zim_Set-Quota -Path "\\winfs2\home\$UserInput" -SizeInGB $NewQuotaInGB
                }
            } else {
                $Quota
            }
        }
        '^\\\\winfs(2(\.ads\.uni-passau\.de)?\\(home|nas1)|1(\.ads\.uni-passau\.de)?\\grp1|3(\.ads\.uni-passau\.de)?\\grp3)\\.*$' {
            $Quota = zim_Get-Quota -Path $UserInput
            if($Quota.GetType().Name -eq 'CimInstance') {
                "$UserInput`: Quota $([math]::Round($Quota.Size / 1GB, 1)) GB, $([math]::Round($Quota.Usage * 100 / $Quota.Size)) % belegt ($($Quota.Template))"
                $NewQuotaInGB = Read-Host -Prompt 'Neue Quota in GB angeben (Enter zum Überspringen)'
                if($NewQuotaInGB) {
                    zim_Set-Quota -Path $UserInput -SizeInGB $NewQuotaInGB
                }
            } else {
                $Quota
            }
        }
        default { "Keine Quota möglich für $UserInput" }
    }
}

function zim_Map-Share {
<#
.SYNOPSIS
Verbindet eine Freigabe mit dem angegebenen Benutzer und Passwort.
.DESCRIPTION
Verbindet eine Freigabe mit dem angegebenen Benutzer und Passwort.
.PARAMETER Path
UNC-Pfad der Freigabe
.PARAMETER User
Name des Benutzers
.PARAMETER Password
Passwort des Benutzers
.EXAMPLE
zim_Map-Share -Path "\\fs1.uni-passau.de\user1" -User "muster42" -Password "******"
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [String]
        $User,
        [Parameter(Mandatory=$true)]
        [String]
        $Password
    )

    "$Path wird gemappt..."
    net use $Path $Password /USER:$User /PERSISTENT:NO
}

function zim_Migrate-GroupDirectoryFromNovellToWindows {
<#
.SYNOPSIS
Migriert ein GruppenDirectory von Novell zu Windows.
.DESCRIPTION
Migriert ein GruppenDirectory von Novell zu Windows. Legt ein Gruppen-Directory für die angegebene Gruppe an, falls noch nicht vorhanden, 
setzt NTFS-Rechte und kopiert die Inhalte des Novell-Directory der angegebenen Novell-Gruppe.
Ist der Parameter Finalize gesetzt wird außerdem das Novell-Gruppen-Directory umbenannt und das Loginscript des Novell-Profils deaktiviert.
.PARAMETER Group
Name der Gruppe
.PARAMETER NovellGroup
Name der Novell-Gruppe ohne "_GRP"
.PARAMETER IdmmasterNovellPassword
Passwort von eDirectory-Benutzer idmmaster
.PARAMETER Log
Pfad zur Log-Datei für robocopy
.PARAMETER Finalize
Schalter um das Novell-Gruppen-Directory umzubenennen und das Loginscript des Novell-Profils zu deaktivieren.
.EXAMPLE
zim_Migrate-GroupDirectoryFromNovellToWindows -Group "V042" -NovellGroup "VK" -Finalize
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
        [String]
        $Group,
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^((D|I|J|K|P|Q|S|V|W)[a-z]|RZ|UB)$')]
        [String]
        $NovellGroup,
        [Parameter(Mandatory=$true)]
        [String]
        $IdmmasterNovellPassword,
        [Parameter(Mandatory=$false)]
        [ValidateScript({(Split-Path -Path $_ -Parent) -and (Test-Path -Path (Split-Path -Path $_ -Parent))})]
        [String]
        $Log,
        [Parameter(Mandatory=$false)]
        [Switch]
        $Finalize
    )

    if($Log) {
        # Output auf Logdatei umleiten
        Start-Transcript -Append -Path $Log
    }
    if($env:USERDOMAIN -eq 'ADS') {
        $NovellServerUNC = '\\fs1.uni-passau.de'    
    } else {
        $NovellServerUNC = '\\edir-idm-test.uni-passau.de' 
    }
    # Novell Gruppen-Directory finden
    $NovellGroupDirectoryUNC = ''
    forEach ($NovellVolume in 'grp1','grp2') {
        if(!(Test-Path("$NovellServerUNC\$NovellVolume"))) {
            zim_Map-Share -Path "$NovellServerUNC\$NovellVolume" -User 'idmmaster' -Password $IdmmasterNovellPassword
            if(!(Test-Path("$NovellServerUNC\$NovellVolume"))) {
                if($Log) {
                    Stop-Transcript
                }
                return
            }
        }
        if(Test-Path("$NovellServerUNC\$NovellVolume\$NovellGroup")) {
            $NovellGroupDirectoryUNC = "$NovellServerUNC\$NovellVolume\$NovellGroup"
            break
        }
    }
    if($NovellGroupDirectoryUNC -eq '') {
        "Kein Novell-Gruppen-Directory für $NovellGroup gefunden"
        if($Log) {
            Stop-Transcript
        }
        return
    }
    # neues Gruppen-Directory anlegen
    $GroupDirectoryUNC = zim_Generate-DefaultGroupDirectoryPath -Group $Group
    if(!(Test-Path($GroupDirectoryUNC))) {
        zim_Create-GroupDirectory -Group $Group
    }
    # wenn neues Gruppendirectory noch leer, Belegung in altem Gruppendirectory abfragen und Quota so setzen, dass die Daten hineinpassen
    if((Get-ChildItem -Path $GroupDirectoryUNC).count -eq 0) {
        "Belegung von $NovellGroupDirectoryUNC abrufen..."
        $NovellGroupDirectorySize = zim_Get-FolderSize -FolderPath $NovellGroupDirectoryUNC
        if($NovellGroupDirectorySize -gt 5GB) {
            "Belegung des alten Gruppendirectory mit $([math]::Round($NovellGroupDirectorySize / 1GB,2)) GB größer als Standardquota 5 GB"
            zim_Set-Quota -Path $GroupDirectoryUNC -SizeInGB $([math]::Truncate($NovellGroupDirectorySize / 1GB) + 1)
            'ggfs. Novell-Quota nachschauen und auf neues Gruppendirectory übertragen'
        }
    }
    zim_Sync-Folder -Source $NovellGroupDirectoryUNC -Target $GroupDirectoryUNC
    if($Finalize) {
        # DFS-Links anlegen
        zim_New-DfsnFolders -Group $Group        
        # Novell-Gruppen-Directory bereinigen
        zim_Disable-EdirGroupDirectory -GroupDirectoryUNC $NovellGroupDirectoryUNC -IdmmasterNovellPassword $IdmmasterNovellPassword
        # Gruppe aus Gruppe DFS Mapping Disabled entfernen
        Import-Module ActiveDirectory -ErrorAction Stop
        if($Group -in (Get-ADGroupMember -Identity 'DFS Mapping Disabled').Name) {
            "Gruppe $Group aus Gruppe DFS Mapping Disabled entfernen..."
            Remove-ADGroupMember -Identity 'DFS Mapping Disabled' -Members $Group -Confirm:$false
            'Nicht vergessen!'
            '- Mapping-Befehle aus GPOs B_Laufwerkzuordungen_W7/10 loeschen'
            '- Netzwerkordner auf windat anlegen'
            "- Novell-Trustees von $(Split-Path -Path $NovellGroupDirectoryUNC -Parent)\__$NovellGroup entfernen"
        }
    }
    if($Log) {
        Stop-Transcript
    }
}

function zim_Migrate-HomeDirectoryFromNovellToWindows {
<#
.SYNOPSIS
Migriert ein HomeDirectory von Novell zu Windows.
.DESCRIPTION
Migriert ein HomeDirectory von Novell zu Windows. Legt ein HomeDirectory für den angegebenen Benutzer an, falls noch nicht vorhanden, 
setzt NTFS-Rechte und kopiert die Inhalte des Novell-HomeDirectory.
Ist der Parameter Finalize gesetzt wird außerdem das HomeDirectory-Attribut im AD-Benutzerobjekt gesetzt, das Novell-Homedirectory
umbenannt und das HomeDirectory-Attribut im eDirectory-Benutzerobjekt entfernt.
.PARAMETER User
Name des Benutzers
.PARAMETER Csv
Pfad zu CSV-Datei mit Benutzernamen, Überschrift "User".
.PARAMETER InZim
$true um für ZIM-Mitarbeiter auf anderes Volume umzuleiten
.PARAMETER IdmmasterNovellPassword
Passwort von eDirectory-Benutzer idmmaster
.PARAMETER Log
Pfad zur Log-Datei für robocopy
.PARAMETER Finalize
Schalter um das HomeDirectory-Attribut im AD-Benutzerobjekt zu setzen, das Novell-Homedirectory
umzubenennen und das HomeDirectory-Attribut im eDirectory-Benutzerobjekt zu entfernen
.EXAMPLE
zim_Migrate-HomeDirectoryFromNovellToWindows -User "tester42" -Finalize
#>
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,    
        [Parameter(Mandatory=$false,ParameterSetName='Path')]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]
        $Csv,
        [Parameter(Mandatory=$false)]
        [Boolean]
        $InZim,
        [Parameter(Mandatory=$true)]
        [String]
        $IdmmasterNovellPassword,
        [Parameter(Mandatory=$false)]
        [ValidateScript({(Split-Path -Path $_ -Parent) -and (Test-Path -Path (Split-Path -Path $_ -Parent))})]
        [String]
        $Log,
        [Parameter(Mandatory=$false)]
        [Switch]
        $Finalize
    )

    if($Log) {
        # Output auf Logdatei umleiten
        Start-Transcript -Append -Path $Log
    }
    Import-Module ActiveDirectory -ErrorAction Stop
    if(!$Csv){
        $Entries = New-Object psobject -Property @{User=$User}
    } else {
        $Entries = Import-Csv -Delimiter ';' -Path $Csv
        foreach($Entry in $Entries) { # trim whitespace
            foreach($Prop in $Entry.PSObject.Properties) {
                $Prop.Value = $Prop.Value.Trim()
            }
        }
    }    
    foreach ($Entry in $Entries) {
        $CurrADUser = Get-ADUser -Filter "cn -eq '$($Entry.User)'" -Properties HomeDirectory
        if(!$CurrADUser) {
			"Fehler: Kein AD-Konto für $($Entry.User) vorhanden"
			continue
		}
		$OldHomeDir = $CurrADUser.HomeDirectory
		if(!$OldHomeDir) {
            "Fehler: Kein HomeDirectory für Benutzer $($Entry.User) vorhanden"
			continue
        }
        if($OldHomeDir -match "^\\\\(winfs|dc1test).*") {
            "HomeDirectory für Benutzer $($Entry.User) ist bereits auf $OldHomeDir"
			continue
        }
        if(!(Test-Path($OldHomeDir))) {
            zim_Map-Share -Path (Split-Path($OldHomeDir) -Parent) -User 'idmmaster' -Password $IdmmasterNovellPassword
            if(!(Test-Path($OldHomeDir))) {
                return
            }
        }
        $NewHomeDir = (zim_Generate-DefaultHomeDirectoryBasePath -InZIM $InZim) + '\' + $Entry.User
        if(!(Test-Path($NewHomeDir))) {
            zim_Create-HomeDirectory -User $Entry.User -InZim $InZim -DontSetADAttribute
        }
        # wenn neues Homedirectory noch leer, Belegung in altem Homedirectory abfragen und Quota so setzen, dass die Daten hineinpassen
        if((Get-ChildItem -Path $NewHomeDir).count -eq 0) {
            "Belegung von $OldHomeDir abrufen..."
            $OldHomeDirSize = zim_Get-FolderSize -FolderPath $OldHomeDir
            if($OldHomeDirSize -gt 1GB) {
                "Belegung des alten Homedirectory mit $([math]::Round($OldHomeDirSize / 1GB,2)) GB größer als Standardquota 1 GB"                
                zim_Set-Quota -Path $NewHomeDir -SizeInGB $([math]::Truncate($OldHomeDirSize / 1GB) + 1)
                'ggfs. Novell-Quota nachschauen und auf neues Homedirectory übertragen'
            }
        }
        zim_Sync-Folder -Source $OldHomeDir -Target $NewHomeDir -ExcludeFolders 'PMAIL'
        if($Finalize) {
            zim_Register-HomeDirectory -User $Entry.User -Path $NewHomeDir
            zim_Disable-EdirHomeDirectory -User $Entry.User -InZim $InZim -IdmmasterNovellPassword $IdmmasterNovellPassword -UpdateNovellLoginScript
            $mailaddr = Get-ADUser $Entry.User -Properties * | Select-Object -ExpandProperty emailaddress 
            $gwmailaddr = $($Entry.User)+"@gw.uni-passau.de"
			$subject = "Umzug Ihres persönlichen H-Laufwerks"  
            $body = "Sehr geehrte Benutzerin, sehr geehrter Benutzer,`r`n" 
            $body +="`nmit dieser E-Mail möchten wir Sie darüber informieren, dass Ihr`r`n"
            $body +="persönliches H-Laufwerk im Zuge der IT-Modernisierung auf neue Server`r`n"
            $body +="umgezogen wurde. Falls Sie innerhalb Ihres H-Laufwerks Freigaben für`r`n"
            $body +="andere Personen eingerichtet hatten, sind diese neu einzurichten.`r`n"
			$body +="Diese konnten aufgrund eines Systemwechsels nicht migriert werden.`r`n" 			
			$body +="Eine Anleitung dazu finden Sie in unserem Hilfe-Portal unter:`r`n"
			$body +="http://www.hilfe.uni-passau.de/netzlaufwerke/`r`n"
            $body +="oder direkt über den ZIM-Support unter der Durchwahl 1888.`r`n"
			$body +=" `r`n"
            $body +="Freundliche Grüße`r`n"
            $body +="Ihr ZIM-Support"
            zim_Send-Email -an $gwmailaddr -Betreff $subject -Nachricht $body
        }
    }
    if($Log) {
        Stop-Transcript
    }
}

function zim_Migrate-NovellHomeDirectoryAfterMove {
<#
.SYNOPSIS
Migriert ein HomeDirectory von einem Novell-Volume auf ein anderes anhand des aktuellen Novell-Containers.
.DESCRIPTION
Migriert ein HomeDirectory von einem Novell-Volume auf ein anderes. Anhand des Novell-Containers wird 
überprüft, ob das HomeDirectory auf dem richtigen Volume liegt. Wenn nicht wird es dorhin migriert.
Ist der Parameter Finalize gesetzt wird außerdem das HomeDirectory-Attribut in Novell- und AD-Benutzerobjekt gesetzt und
das alte Homedirectory umbenannt. Die Novell-Rechte werden dabei durch makehome nach Aktualisieren des Novell-HomeDirectory-Attributs gesetzt.
Mehr zu LDAP-Operationen mit Powershell: https://msdn.microsoft.com/en-us/library/bb332056.aspx
.PARAMETER User
Name des Benutzers
.PARAMETER IdmmasterNovellPassword
Passwort von eDirectory-Benutzer idmmaster
.PARAMETER Log
Pfad zur Log-Datei für robocopy
.PARAMETER Finalize
Schalter um das HomeDirectory-Attribut in Novell- und AD-Benutzerobjekt zu setzen und das alte Homedirectory
umzubenennen.
.EXAMPLE
zim_Migrate-NovellHomeDirectoryAfterMove -User "tester42" -Finalize
#>
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User, 
        [Parameter(Mandatory=$true)]
        [String]
        $IdmmasterNovellPassword,
        [Parameter(Mandatory=$false)]
        [ValidateScript({(Split-Path -Path $_ -Parent) -and (Test-Path -Path (Split-Path -Path $_ -Parent))})]
        [String]
        $Log,
        [Parameter(Mandatory=$false)]
        [Switch]
        $Finalize
    )

    if($Log) {
        # Output auf Logdatei umleiten
        Start-Transcript -Append -Path $Log
    }
    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols") | Out-Null    
    if($env:USERDOMAIN -eq 'ADS') {
        $LdapServerPort = 'edir-idm.uni-passau.de:636'    
    } else {
        $LdapServerPort = 'edir-idm-test.uni-passau.de:636'  
    }
    $Connection = New-Object System.DirectoryServices.Protocols.LdapConnection $LdapServerPort
    $Connection.SessionOptions.ProtocolVersion = 3
    $Connection.SessionOptions.SecureSocketLayer = $true
    $Connection.SessionOptions.VerifyServerCertificate = { return $true }
    $Connection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic
    $Connection.Credential = New-Object 'System.Net.NetworkCredential' -ArgumentList 'cn=idmmaster,ou=idm,o=uni-passau',$IdmmasterNovellPassword
    $connection.Bind()
    $BaseDN = 'o=uni-passau'
    $Filter = "(cn=$User)"
    $Scope = [System.DirectoryServices.Protocols.SearchScope]::SubTree
    $SearchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest -ArgumentList $BaseDN,$Filter,$Scope,'*'
    $SearchResult = $Connection.SendRequest($SearchRequest)    
    if($SearchResult.Entries[0].Attributes['ndsHomeDirectory']) {
        $OldHomeDirArr = $SearchResult.Entries[0].Attributes['ndsHomeDirectory'].GetValues('string').split('#')
        $NewHomeDirVolume = zim_Generate-DefaultNovellHomeDirectoryVolumeName -DistinguishedName $SearchResult.Entries[0].DistinguishedName
        if($OldHomeDirArr[0] -match $NewHomeDirVolume) {
            "Benutzer $($SearchResult.Entries[0].DistinguishedName) ist bereits auf Volume $NewHomeDirVolume"
        } else {
            $HomeDirArr = $SearchResult.Entries[0].Attributes['ndsHomeDirectory'].GetValues('string').split(',')
            $OldHomeDirBaseUNC = '\\' + $HomeDirArr[0].split(',')[0].Substring(3).Replace('_','.uni-passau.de\') 
            if(!(Test-Path($OldHomeDirBaseUNC))) {
                zim_Map-Share -Path $OldHomeDirBaseUNC -User 'idmmaster' -Password $IdmmasterNovellPassword
                if(!(Test-Path($OldHomeDirBaseUNC))) {
                    return
                }
            }            
            $OldHomeDirUNC = "$OldHomeDirBaseUNC\$($OldHomeDirArr[2])" 
            $NewHomeDirBaseUNC = '\\' + $NewHomeDirVolume.Replace('_','.uni-passau.de\')
            if(!(Test-Path($NewHomeDirBaseUNC))) {
                zim_Map-Share -Path $NewHomeDirBaseUNC -User 'idmmaster' -Password $IdmmasterNovellPassword
                if(!(Test-Path($NewHomeDirBaseUNC))) {
                    return
                }
            } 
            $NewHomeDirUNC = "$NewHomeDirBaseUNC\$($OldHomeDirArr[2])"
            if(!(Test-Path($NewHomeDirUNC))) {
                "Ordner $NewHomeDirUNC anlegen..."
                New-Item -ItemType Directory -Path $NewHomeDirUNC
                if(!(Test-Path($NewHomeDirUNC))) {
                    return
                }
            }
            zim_Sync-Folder -Source $OldHomeDirUNC -Target $NewHomeDirUNC -ExcludeFolders 'PMAIL'
            if($Finalize) {                
                "$OldHomeDirUNC umbenennen in __$($OldHomeDirArr[2])..."
                Rename-Item -Path $OldHomeDirUNC -NewName "__$($OldHomeDirArr[2])"
                $NewNdsHomeDirectory = "cn=$NewHomeDirVolume,ou=server,o=uni-passau",$OldHomeDirArr[1],$OldHomeDirArr[2] -join '#'
                "ndsHomeDirectory: $NewNdsHomeDirectory setzen... (makehome setzt die Rechte)"
                $ModifyType = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
                $ModifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest -ArgumentList $SearchResult.Entries[0].DistinguishedName,$ModifyType,'ndsHomeDirectory',$NewNdsHomeDirectory
                $ModifyResponse = $Connection.SendRequest($ModifyRequest)
                $ModifyResponse.ResultCode
                $NewMessageServer = "cn=$($NewHomeDirVolume.Split('_')[0]),ou=server,o=uni-passau"
                if($SearchResult.Entries[0].Attributes['messageServer'].GetValues('string') -ne $NewMessageServer) {
                    "messageServer auf $NewMessageServer setzen..."
                    $ModifyType = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
                    $ModifyRequest = New-Object System.DirectoryServices.Protocols.ModifyRequest -ArgumentList $SearchResult.Entries[0].DistinguishedName,$ModifyType,'messageServer',$NewMessageServer
                    $ModifyResponse = $Connection.SendRequest($ModifyRequest)
                    $ModifyResponse.ResultCode
                }
                zim_Register-HomeDirectory -User $User -Path $NewHomeDirUNC
                if((zim_Get-FolderSize -FolderPath $NewHomeDirUNC) -gt (zim_Generate-DefaultNovellHomeDirectoryQuota -DistinguishedName $SearchResult.Entries[0].DistinguishedName)) {
                    "Inhalt von $NewHomeDirUNC groesser als Standard-Quota: Bitte Quota manuell anpassen!"
                }
            }
        }
    } else {
        "Benutzer $($SearchResult.Entries[0].DistinguishedName) hat kein Novell-Home-Directory"
    }
    if($Log) {
        Stop-Transcript
    }
}

function zim_New-DfsnFolder {
<#
.SYNOPSIS
Erstellt einen neuen DFS-Ordner.
.DESCRIPTION
Erstellt einen neuen DFS-Ordner. Zugleich wird auch die Leseberechtigung für den angegebenen Benutzer oder die Gruppe gesetzt.
.PARAMETER DfsPath
Pfad für den DFS-Ordner.
.PARAMETER TargetPath
Pfad des Ziel-Ordners.
.PARAMETER DfsUser
Spezifiziert den Benutzer oder die Gruppe welche auf den DFS-Ordner Zugriff erhält.
.EXAMPLE
zim_New-DfsnFolder -DfsPath \\ads\grp\Q001 -TargetPath \\winfs1\grp1\Q001 -DfsUser Q001
Erstellt im Namespace \\ads\grp einen neuen DFS-Ordner Q001 und setzt für die angegebene Gruppe Q001 die Leseberechtigung.
#>
    
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $DfsPath,
        [Parameter(Mandatory=$true)]
        [String]
        $TargetPath,
        [Parameter(Mandatory=$true)]
        [String]
        $DfsUser
    )

    if(Test-Path ($TargetPath -replace '-s\\', '\')) {
        "DFS: $DfsPath -> $TargetPath..."
        New-DfsnFolder -Path $DfsPath -TargetPath $TargetPath -TimeToLiveSec 1800
        zim_Add-DfsnAccess -Path $DfsPath -User $DfsUser
    } else {
        zim_Error-Notify -Message ("Fehler beim Erstellen von $DfsPath : Ziel-Ordner $TargetPath ist nicht vorhanden")
    }
}
﻿
function zim_New-DfsnFolders {
<#
.SYNOPSIS
Erstellt neue DFS-Ordner.
.DESCRIPTION
Erstellt neue DFS-Ordner in den Namespaces grp, tun und zuv. Zugleich wird auch die entsprechende Berechtigung der angegebenen Gruppe gesetzt.
.PARAMETER Group
Spezifiziert die Gruppe welche auf den DFS-Ordner Zugriff erhält. Zugleich ist der Gruppenname auch der Name des Ordners.
.PARAMETER Csv
Pfad zu CSV-Datei mit hinterlegten Gruppennamen, Überschrift "Group".
.EXAMPLE
zim_New-DfsnFolders -Group Q001
Erstellt in den Namespaces grp, tun und zuv  einen neuen Ordner mit dem Namen der Gruppe (Q001) und setzt für die angegebene Gruppe die Leseberechtigung.
#>

    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
        [String]
        $Group,
        [Parameter(Mandatory=$false,ParameterSetName='Path')]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]
        $Csv
    )

    if($env:USERDOMAIN -eq 'ADS') {
        $S_Volume_tun = '\\winfs3-s\grp3'
        $S_Volume_zuv = '\\winfs3\grp3'
        $N_Volume = '\\winfs1\grp1'        
    } else {
        $S_Volume_tun = '\\dc1test-s\grp3'
        $S_Volume_zuv = '\\dc1test\grp3'
        $N_Volume = '\\dc1test\grp1'
    }          
    If (!$Csv) {
        $entries = New-Object psobject -Property @{Group=$Group}
    } else {
        $entries = Import-Csv -Delimiter ';' -Path $Csv
        foreach($Entry in $entries) { # trim whitespace
            foreach($Prop in $Entry.PSObject.Properties) {
                $Prop.Value = $Prop.Value.Trim()
            }
        }
    }    
    foreach ($entry in $entries) {
        foreach ($ns in 'grp','tun','zuv') {
            $fullns = "\\$env:USERDOMAIN\$ns"
            zim_New-DfsnFolder -DfsPath "$fullns\$($entry.Group)" -TargetPath "$N_Volume\$($entry.Group)" -DfsUser "$env:USERDOMAIN\$($entry.Group)"
            <#Switch ($ns) {
                tun {
                    zim_New-DfsnFolder -DfsPath "$fullns\$($entry.Group)-S" -TargetPath "$S_Volume_tun\$($entry.Group)-S" -DfsUser "$env:USERDOMAIN\$($entry.Group)"
                }
                zuv {
                    zim_New-DfsnFolder -DfsPath "$fullns\$($entry.Group)-S" -TargetPath "$S_Volume_zuv\$($entry.Group)-S" -DfsUser "$env:USERDOMAIN\$($entry.Group)"
                }
            }#>
        }
    }     
}

function zim_Register-HomeDirectory {
<#
.SYNOPSIS
Trägt den Pfad als HomeDirectory beim Benutzer ein.
.DESCRIPTION
Trägt den Pfad als HomeDirectory beim Benutzer ein.
.PARAMETER User
Name des Benutzers
.PARAMETER Path
Vollständiger UNC-Pfad zum HomeDirectory
.EXAMPLE
zim_Register-HomeDirectory -User "tester42" -Path "\\winfs2\home\tester42"
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

    Import-Module ActiveDirectory -ErrorAction Stop
    "$Path als HomeDirectory bei $User setzen..."
    Set-ADUser -Identity $User -HomeDirectory $Path -HomeDrive 'H:'
}

function zim_Remove-DfsnAccess {
<#
.SYNOPSIS
Entfernt Leseberechtigung von DFS-Ordner.
.DESCRIPTION
Entfernt Leseberechtigung für angegebene Kennung oder Gruppe von DFS-Ordner.
.PARAMETER Path
Pfad des DFS-Ordner
.PARAMETER User
Kennung oder Gruppe, der die Berechtigung entzogen werden soll
.EXAMPLE
zim_Remove-DfsnAccess -Path \\ADS\grp\Q001 -User Q001
Entfernt Leseberechtigung für Gruppe Q001 von DFS-Ordner \\ADS\grp\Q001.
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [String]
        $User
    )

    dfsutil.exe property SD revoke ($Path) ($User)
}

function zim_Send-Email {
<#
.SYNOPSIS
E-Mail über ZIM-SMTP-Server senden
.DESCRIPTION
E-Mail über ZIM-SMTP-Server senden
.PARAMETER an
Empfänger-E-Mail-Adresse
.PARAMETER von
Absender-E-Mail-Adresse, optional
.PARAMETER Betreff
Betreff
.PARAMETER Nachricht
Nachricht
.EXAMPLE
zim_Error-Nofify -Message "Fehler xy"
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $an,
        [Parameter(Mandatory=$false)]
        [String]
        $von,
        [Parameter(Mandatory=$true)]
        [String]
        $Betreff,
        [Parameter(Mandatory=$true)]
        [String]
        $Nachricht
    )

    if(!$von) {
        $von = 'support@zim.uni-passau.de'
    }
    Send-MailMessage -SmtpServer 'mail.rz.uni-passau.de' -to $an -from $von -Subject $Betreff -Body $Nachricht -Encoding ([System.Text.Encoding]::UTF8)
}

function zim_Set-Quota {
<#
.SYNOPSIS
Setzt Quota für übergebenen UNC-Pfad.
.DESCRIPTION
Setzt Quota für übergebenen UNC-Pfad.
Erlaubte Pfade:
\\winfs2\home\*
\\winfs1\grp1\*
\\winfs3\grp3\*
\\winfs2\nas1\*
.PARAMETER Path
UNC-Pfad zu Ordner
.PARAMETER SizeInGB
neue Quota in GB
.EXAMPLE
zim_Set-Quota -Path \\winfs2\home\muster42 -SizeInGB 2
setzt die Quote für \\winfs2\home\muster42 auf 2 GB
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^\\\\winfs(2(\.ads\.uni-passau\.de)?\\(home|nas1)|1(\.ads\.uni-passau\.de)?\\grp1|3(\.ads\.uni-passau\.de)?\\grp3)\\.*$')]
        [String]
        $Path,
        [Parameter(Mandatory=$true)]
        [ValidateRange(1,1000000)]
        [int]
        $SizeInGB
    )
    if(Test-Path $Path -PathType Container) {
        $LocalPath = $Path -replace '^\\\\winfs2(\.ads\.uni-passau\.de)?\\home','f:' `
            -replace '^\\\\winfs1(\.ads\.uni-passau\.de)?\\grp1','g:' `
            -replace '^\\\\winfs(2|3)(\.ads\.uni-passau\.de)?\\(grp3|nas1)','e:'
        $Size = $SizeInGB * 1GB
        "Quota von $Path wird auf $SizeInGB GB gesetzt..."
        Invoke-Command -ComputerName $Path.Substring(2,6) { Set-FsrmQuota -Path $using:LocalPath -Size $using:Size }
    } else {
        "$Path existiert nicht oder ist kein Ordner"
    }
}

function zim_Sync-Folder {
<#
.SYNOPSIS
Synchronisiert Ordner.
.DESCRIPTION
Synchronisiert Ordner mit robocopy (ggf. mit Dateirechten, in der Quelle nicht vorhandene Dateien und Ordner werden im Ziel gelöscht).
.PARAMETER Source
Pfad zum Quell-Ordner
.PARAMETER Target
Pfad zum Ziel-Ordner
.PARAMETER Csv
Pfad zur Csv-Import-Datei mit Quellen (Source) und Zielen (Target), getrennt durch ";"
.PARAMETER Log
Pfad zur Log-Datei
.PARAMETER ExcludeFolders
Array ausgeschlossener Ordnernamen oder -pfade
.PARAMETER CopyRights
Schalter zur Aktivierung des Kopierens der Dateirechte
.EXAMPLE
zim_Sync-Folder -Source \\fs1\user1\tester42 -Target \\winfs2\home\tester42 -Log c:\temp\log.txt -ExcludeFolders "test1","test2"
Synchronisiert \\fs1\user1\tester42 nach \\winfs2\home\tester42 ohne Unterordner test1 und test2.
#>
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [String]
        $Source,
        [Parameter(Mandatory=$true,ParameterSetName='Normal')]
        [String]
        $Target,
        [Parameter(Mandatory=$true,ParameterSetName='Path')]
        [String]
        $Csv,
        [Parameter(Mandatory=$false)]
        [String]
        $Log,
        [Parameter(Mandatory=$false)]
        [String[]]
        $ExcludeFolders,
        [Parameter(Mandatory=$false)]
        [Switch]
        $CopyRights
    )

    if(!$Csv){
        $Entries = New-Object psobject -Property @{Source=$Source;Target=$Target}
    } else {
        $Entries = Import-Csv -Delimiter ';' -Path $Csv
        foreach($Entry in $Entries) { # trim whitespace
            foreach($Prop in $Entry.PSObject.Properties) {
                $Prop.Value = $Prop.Value.Trim()
            }
        }
    }    
    foreach ($Entry in $Entries) {
        $Expression = "robocopy.exe $($Entry.Source) $($entry.Target) /MIR /NFL /NDL /R:0 /W:0"
        if($Log) {
            $Expression += " /LOG+:$Log"
        }
        if($CopyRights) {
            $Expression += ' /SEC'
        }
        if($ExcludeFolders) {
            $Expression += '  /XD ' + ($ExcludeFolders -join ' ')
        }
        if(!(Test-Path -Path ($Entry.Source))) {
            "Quelle $($Entry.Source) existiert nicht"
        } elseif(!(Test-Path -Path ($Entry.Source + "\*"))) {
            "Quelle $($entry.Source) ist leer"
        } elseif(!(Split-Path -Path $Entry.Target -Parent) -or !(Test-Path -Path (Split-Path -Path $Entry.Target -Parent))) {
            'Ziel-Basis ' + (Split-Path -Path $Entry.Target -Parent) + ' existiert nicht'
        } elseif($Log -ne "" -and (!(Split-Path -Path $Log -Parent) -or !(Test-Path -Path (Split-Path -Path $Log -Parent)))) {
            'Logdatei-Basis ' + (Split-Path -Path $Log -Parent) + ' existiert nicht'
        } else {
            Invoke-Expression $Expression
        }
    }
}

function zim_Unmap-Share {
<#
.SYNOPSIS
Trennt eine verbundene Freigabe.
.DESCRIPTION
Trennt eine verbundene Freigabe.
.PARAMETER Path
UNC-Pfad der Freigabe
.EXAMPLE
zim_Unmap-Share -Path "\\fs1.uni-passau.de\user1"
#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )

    net use $Path /DELETE
}

function zim_getUserQuota {
<#
.SYNOPSIS
Ausgabe der aktuellen Benutzerquota in GB
.DESCRIPTION
Ausgabe der aktuellen Benutzerqouta in GB
.PARAMETER User
Benutzerkennung
.EXAMPLE
zim_get-UserQouta -User examp01
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User
    )
    $Path = "F:\"+$User
	Invoke-Command -ComputerName winfs2.ads.uni-passau.de {Get-FsrmQuota -Path $using:Path | Select Path, @{ Name="Usage in GB";Expression={$([math]::Round(($_.Usage / 1GB),2))}}, @{ Name="Quota in GB";Expression={$([math]::Round(($_.Size / 1GB),2))}}, Template } 
}

function zim_getGroupQuota {
<#
.SYNOPSIS
Ausgabe der aktuellen Quota auf dem Gruppenlaufwerk
.DESCRIPTION
Ausgabe der aktuellen Quota auf dem Gruppenlaufwerk
.PARAMETER Gruppe
Gruppenname
.EXAMPLE
zim_get-UserQouta -User examp01
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(I|J|P|S|V|W)[0-9]{3}$')]
        [String]
        $Group
    )
    $PathGRP1 = "G:\"+$Group
	$PathGRP3 = "E:\"+$Group +"-S"
	Invoke-Command -ComputerName winfs1.ads.uni-passau.de {Get-FsrmQuota -Path $using:PathGRP1 | Select Path, @{ Name="Usage in GB";Expression={$([math]::Round(($_.Usage / 1GB),2))}}, @{ Name="Quota in GB";Expression={$([math]::Round(($_.Size / 1GB),2))}}, Template } 
	Invoke-Command -ComputerName winfs3.ads.uni-passau.de {Get-FsrmQuota -Path $using:PathGRP3 | Select Path, @{ Name="Usage in GB";Expression={$([math]::Round(($_.Usage / 1GB),2))}}, @{ Name="Quota in GB";Expression={$([math]::Round(($_.Size / 1GB),2))}}, Template } 
}

function zim_setUserQuota {
<#
.SYNOPSIS
Setzt User Quota auf \\winfs2\home\.
.DESCRIPTION
Setzt User Quota auf \\winfs2\home\.
.PARAMETER User
Benutzerkennung
.PARAMETER SizeInGB
Groeße der neuen Quota in GB
.EXAMPLE
zim_set-UserQouta -User examp01 -SizeInGB 3.0GB
#>
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^([a-z\-]{2,6}[0-9]{2}|[a-z\-]{2,5}[0-9]{3}|[a-z]{2,8})$')]
        [String]
        $User,
        [Parameter(Mandatory=$true)]
        [UInt64]
        $SizeInGB
    )
    $Path = "F:\"+$User
	Invoke-Command -ComputerName winfs2.ads.uni-passau.de {Set-FsrmQuota -Path $using:Path -Size $using:SizeInGB }
}
