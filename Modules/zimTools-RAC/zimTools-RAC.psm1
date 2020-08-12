﻿Function zimMove-User{
    [cmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)][string]$User,
        [Parameter(Mandatory=$True)][string]$Database
        )
    New-MoveRequest -identity $User -batchname $user+"_"+$(Get-Date -format dd-MM-yyyy) -targetdatabase $Database -whatif


}

function zimGet-DiskInfo{
    [CmdletBinding()]    Param(    [Parameter(Mandatory=$True)][string]$ComputerName,    [int]$DriveType = 3    )
    Write-Verbose "Getting drive types of $DriveType from $ComputerName"        Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=$DriveType" -ComputerName $ComputerName |        Select-Object -Property @{n='DriveLetter';e={$PSItem.DeviceID}},                            @{n='FreeSpace(MB)';e={"{0:N2}" -f ($PSItem.FreeSpace / 1MB)}},                            @{n='Size(GB)';e={"{0:N2}" -f ($PSItem.Size / 1GB)}},                            @{n='FreePercent';e={"{0:N2}%" -f ($PSItem.FreeSpace / $PSItem.Size * 100)}}}function zimGet-TopTen{        Param (
        [string]$Database
        )        if($Database){            get-mailbox -Database $Database -ResultSize Unlimited|Get-MailboxStatistics|sort-object -Property totalitemsize -descending |select -first 10|ft -Property displayname, itemcount, totalitemsize, database            }         else{            get-mailbox -ResultSize Unlimited|Get-MailboxStatistics|sort-object -Property totalitemsize -descending |select -first 10|ft -Property displayname, itemcount, totalitemsize, database                        }}function zimGet-DatabaseSize{        Param (
        [string]$Database
        )        if($Database){            Get-MailboxDatabase -Identity $Database -Status| select ServerName,Name,DatabaseSize            }         else{            Get-MailboxDatabase -Status| select ServerName,Name,DatabaseSize            }}<#function zimNew-HomeDir{      Param (
        [Parameter(Mandatory=$True)][string]$TargetPath,
        [Parameter(Mandatory=$True)][string]$User,
        [Parameter(Mandatory=$True)][string]$Rights
        )        new-item -Path $TargetPath -ItemType Directory          $acl=get-acl -Path $TargetPath        $rule=new-object System.Security.AccessControl.FileSystemAccessRule("adstest\$User","$Rights","ContainerInherit, ObjectInherit", "None", "Allow")        $acl.SetAccessRule($rule)        set-acl $TargetPath $acl}#><#function zimSet-FSQuota{        Param(        [Parameter(Mandatory=$True)][string]$TargetPath,        [Parameter(Mandatory=$True)][int64]$Size        )        invoke-command -ComputerName ki-extest -ScriptBlock {param($p1, $p2) get-FsrmQuota -Path $p1|%{if($_.MatchesTemplate -match $true){set-FsrmQuota -Path $p1 -size $p2}}} -ArgumentList $TargetPath,$Size}#>function zimSet-MailQuota{        <#        .Synopsis        Setzt verschiedene Quotas auf die Mailbox des Users.        .Description        Mit diesem Cmdlet werden die Quotas für Warning, ProhibitSend sowie ProhibitSendReceive auf die Mailboxen der übergebenen Benutzer eingestellt.        .Parameter QuotaUser        Spezifiziert den Benutzer bzw. die Benutzer. Mehrere Benutzer sind durch Kommata getrennt anzugeben.        .Example        zimSet-MailQuota -QuotaUser Test_User        .Example        zimSet-MailQuota -QuotaUser Test_User1,Test_User2,Test_User3        .Example        zimSet-MailQuota -QuotaUser (Get-ChildItem Users.txt)        Übergeben einer Textdatei in der die Benutzer aufgelistet sind. Pro Zeile nur ein Benutzer zulässig.        #>                Param(        [Parameter(Mandatory=$True,ValueFromPipeline=$True)][String[]]$QuotaUser        )        process {        #Counter für Fortschrittsbalken        $i=1        #Schleife zum verarbeiten aller übergebenen Benutzer        foreach($User in $QuotaUser){            #Fortschrittsbalken            
            Write-Progress -Activity "Working" -Status "Quotas gesetzt: $i" -PercentComplete ($i*100 / $QuotaUser.count) -CurrentOperation $User            $i++            
            #ermitteln der aktuellen Größe der Mailbox und umwandeln in Byte zum weiteren verarbeiten
            $actsize=Get-MailboxStatistics $user|select -Property totalitemsize
            [int64]$size=$actsize.TotalItemSize.Value.ToBytes()

            #Festlegen welche Grenzen eingestellt werden
            if ($size -gt 3GB){
                $warn=$size + 1GB
                $send=$size + 1.4GB
                $receive=$size + 1.5GB
            } else {
                    $warn=3.5GB
                    $send=3.9GB
                    $receive=4.0GB
            }

            #Quotas auf Mailbox setzen
            set-mailbox $user -UseDatabaseQuotaDefaults $false -ProhibitSendQuota ($send) -IssueWarningQuota ($warn) -ProhibitSendReceiveQuota ($receive)                }#Schleifenende        #Bildschirmausgabe der neu eingestellten Grenzen        ($QuotaUser)|Get-Mailbox|select -Property DisplayName,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota        }}function zimGet-MailQuota{<#.SYNOPSISZeigt verschiedene Quotas an..DESCRIPTIONMit diesem Cmdlet werden die Quotas für Warning, ProhibitSend sowie ProhibitSendReceive von den Mailboxen der übergebenen Benutzer angezeigt..PARAMETER QuotaUserSpezifiziert den Benutzer bzw. die Benutzer..EXAMPLEzimGet-MailQuota -QuotaUser Test_User.EXAMPLEzimGet-MailQuota -QuotaUser Test_User1,Test_User2,Test_User3.EXAMPLEzimGet-MailQuota -QuotaUser (Get-ChildItem Users.txt)Übergeben einer Textdatei in der die Benutzer aufgelistet sind. Pro Zeile nur ein Benutzer zulässig.#>    Param(    [Parameter(Mandatory=$True,ValueFromPipeline=$True)][String[]]$QuotaUser    )    process {        foreach($User in $QuotaUser){            Get-Mailbox $User|select -Property DisplayName,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota            }            }}function New-TeamDistributionGroup{<#.SYNOPSISErstellt Distributiongroups..DESCRIPTIONErstellt Distributiongroups anhand der angegebenen Parameter oder anhand einer Semikolon separierten Datei..PARAMETER NameSpezifiziert den System- bzw. DisplayName..PARAMETER AliasSpezifiziert den Aliasnamen. Am besten wird Gruppenname gefolt von Unterstrich und Präfix Emailadresse verwendet (z.B.: S001_Sekretariat).PARAMETER OwnerSpezifiziert den Besitzer der DistributionGroup. Hier wird der Einrichtungsleiter eingetragen..PARAMETER MembersSpezifiziert die Mitglieder der DistributionGroup. In unserem Fall wird hier nur die SharedMailbox eingetragen (z.B.: S001_Team).PARAMETER SendOnBehalfUsersSpezifiziert die Benutzer welche im Namen der DistributionGroup senden dürfen. Angabe der Benutzer mit kurzem Benutzernamen und via Komma getrennt.PARAMETER EmailAddressesSpezifiziert die EmailAdresse der DistributionGroup. Angabe von mehreren Emails durch Komma getrennt möglich. Die als erstes genannte EmailAdresse wird die Hauptadresse. Die Standard ADS-Adresse (z.B.: Sekretaria@ads.uni-passau.de) wird automatisch erzeugt. .EXAMPLEzimNew-DistributionGroup -Name ZIM-Sekretariat -Alias S001_Sekretariat -Owner User1 -Members S001_Team -SendOnBehalfUsers User2,User3 -EmailAddresses Zim-Sekretariat@uni-passau.de,ExampleTest@uni-passau.de.EXAMPLEzimNew-DistributionGroup -Path DistributionGroups.csv#>    Param(    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String]$Name,    [Parameter(Mandatory=$false,ParameterSetName='Normal')]$Alias,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String[]]$Owner,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String[]]$Members,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String[]]$SendOnBehalfUsers,    [Parameter(Mandatory=$false,ParameterSetName='Normal')][String[]]$EmailAddresses,    [Parameter(Mandatory=$false,ParameterSetName='Path')][String]$Path    )                If($Alias -eq $null){            $Alias=$Name        }        if ($Name){            #@ads.uni-passau.de-EmailAdresse dem Array hinzufügen (neues erstellen)            $EmailAddress = $EmailAddresses += $Name + "@ads.uni-passau.de"            #Anlegen einer einzelnen DistributionGroup            new-DistributionGroup -name $Name -DisplayName $EmailAddress[0] -alias $Alias -managedby $Owner -members $Members -OrganizationalUnit "ads.uni-passau.de/exchange" -MemberJoinRestriction Closed -MemberDepartRestriction Closed -RequireSenderAuthenticationEnabled $false -Type Distribution|Set-DistributionGroup -EmailAddressPolicyEnabled $false -GrantSendOnBehalfTo $SendOnBehalfUsers -EmailAddresses $EmailAddress             #new-DistributionGroup -name $Name -DisplayName $EmailAddress[0] -alias $Alias -managedby $Owner -members $Members -OrganizationalUnit "adstest.uni-passau.de/up_test/exgroup" -MemberJoinRestriction Closed -MemberDepartRestriction Closed -RequireSenderAuthenticationEnabled $false -Type Distribution|Set-DistributionGroup -EmailAddressPolicyEnabled $false -GrantSendOnBehalfTo $SendOnBehalfUsers -EmailAddresses $EmailAddress         } else {            #Anlegen mehrerer DistributionGroups via CSV            $list=Import-Csv -Delimiter ";" -Path $path            foreach ($DG in $list){                $Owner=($DG.Owner).split(",")                $Members=($DG.Members).split(",")                $SendOnBehalfUsers=($DG.SendOnBehalfUsers).split(",")                if ($DG.EmailAddresses){                    $EmailAddresses=($DG.EmailAddresses).split(",")                }                $EmailAddress = $EmailAddresses += $DG.Name + "@ads.uni-passau.de"                new-DistributionGroup -name $DG.Name -DisplayName $EmailAddress[0] -alias $DG.Alias -managedby $Owner -members $Members -OrganizationalUnit "ads.uni-passau.de/exchange" -MemberJoinRestriction Closed -MemberDepartRestriction Closed -RequireSenderAuthenticationEnabled $false -Type Distribution|Set-DistributionGroup -EmailAddressPolicyEnabled $false -GrantSendOnBehalfTo $SendOnBehalfUsers -EmailAddresses $EmailAddress                #new-DistributionGroup -name $DG.Name -DisplayName $EmailAddress[0] -alias $DG.Alias -managedby $Owner -members $Members -OrganizationalUnit "adstest.uni-passau.de/up_test/exgroup" -MemberJoinRestriction Closed -MemberDepartRestriction Closed -RequireSenderAuthenticationEnabled $false -Type Distribution|Set-DistributionGroup -EmailAddressPolicyEnabled $false -GrantSendOnBehalfTo $SendOnBehalfUsers -EmailAddresses $EmailAddress            }        }}
function New-TeamSharedMailbox{<#.SYNOPSISErstellt SharedMailbox..DESCRIPTIONErstellt SharedMailboxes anhand der angegebenen Parameter..PARAMETER NameSpezifiziert den Namen, Displaynamen sowie das Alias der SharedMailbox..PARAMETER UsersSpezifiziert die Benutzer welche FullAccess sowie "Send As"-Rechte auf die SharedMailbox erhalten. Automapping wird zugleich deaktiviert..PARAMETER EmailAddressesSpezifiziert weitere Email-Adressen welche der SharedMailbox zugeordnet werden. Die Primäre bleibt dabei die ADS-Adresse (z.B.: S001_Team@ads.uni-passau.de).PARAMETER QuotaSetzt die Quota-Richtlinie um (Warning: 9,5GB; Send: 9,9GB; SendReceive: 10GB).EXAMPLEzimNew-SharedMailbox -Name S001_Team -User User1,User2 -EmailAddresses Example1@uni-passau.de,Example2@uni-passau.de -QuotaErstellt eine neue SharedMailbox bei der die angegebenen Benutzer FullAccess- sowie SendAs-Rechte besitzen, die weiteren Email-Adressen eingetragen werden und die Quotas gesetzt werden.#>    Param(    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String]$Team,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][Alias('TeamMember')][String[]]$Users,    [Parameter(ParameterSetName='Normal')][String[]]$EmailAddresses,    [Parameter(ParameterSetName='Normal')][Switch]$Quota    )    $Name=$Team + '_Team'    #Mailbox erstellen    write-host "Neues Team mit dem Namen $Name anlegen..." -ForegroundColor Yellow    New-Mailbox -Name $Name -OrganizationalUnit ads.uni-passau.de/exchange -Shared|out-null        foreach ($User in $Users){        #Berechtigungen eintragen        #FullAccess        write-host "Berechtigungen für $User setzen..." -ForegroundColor Yellow        Add-MailboxPermission $Name -User $User -AccessRights FullAccess –AutoMapping $False|out-null        #SendAs        Add-ADPermission $Name -User $User -ExtendedRights "Send As"|out-null    }    #Quota setzen wenn angegeben    if ($Quota -eq $true){        write-host "Quota für $Name setzen..." -ForegroundColor Yellow        set-mailbox $Name -UseDatabaseQuotaDefaults $false -ProhibitSendQuota (9.9GB) -IssueWarningQuota (9.5GB) -ProhibitSendReceiveQuota (10GB)|out-null    }    #Weitere Email-Adressen eintragen wenn angegeben    if ($EmailAddresses){        write-host "Weitere Email-Adressen hinzufügen..." -ForegroundColor Yellow        Set-Mailbox $name -EmailAddresses $EmailAddresses|out-null    }}function zimStart-Update{<#.SYNOPSISStellt den Server in den Wartungsmodus..DESCRIPTIONStellt den Server in den Wartungsmodus, z. B. für Updates, wobei per Parameter geregelt werden kann, auf welchen Server die Queue umverteilt werden soll..PARAMETER TargetDer Zielserver für die Mail-Queue (Standard: MSXRESTORE bzw. MSXPO1 auf MSXRESTORE)#>    Param(    [String]$Target = "msxrestore.ads.uni-passau.de"    )    Set-ServerComponentState $env:COMPUTERNAME -Component HubTransport -State Draining -Requester Maintenance    Redirect-Message -Server $env:COMPUTERNAME -Target $Target -Confirm:$false    Set-ServerComponentState $env:COMPUTERNAME -Component ServerWideOffline -State Inactive -Requester Maintenance}function zimEnd-Update{<#.SYNOPSISStellt den Server vom Wartungsmodus zurück in den Online-Modus..DESCRIPTIONStellt den Server vom Wartungsmodus zurück in den Online-Modus.#>    Set-ServerComponentState $env:COMPUTERNAME -Component ServerWideOffline -State Active -Requester Maintenance    Set-ServerComponentState $env:COMPUTERNAME -Component HubTransport -State Active -Requester Maintenance}function Reload-OfflineAddressBook {    Get-OfflineAddressBook | Update-OfflineAddressBook    Get-OfflineAddressBook}<#.EXAMPLEGet-Mailbox V012_Team | Get-MailboxCalendarPermissionAdd-MailboxFolderPermission -Identity V012_Team@ads.uni-passau.de:\Kalender -User achter@ads.uni-passau.de -AccessRights Editor#>function Get-MailboxCalendarPermission {    [cmdletBinding()]    param(    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]    $Mailbox    )    $mb_address=(Get-Mailbox $Mailbox).PrimarySMTPAddress.Address    Get-MailboxFolderPermission -Identity ($mb_address +":\Kalender")}