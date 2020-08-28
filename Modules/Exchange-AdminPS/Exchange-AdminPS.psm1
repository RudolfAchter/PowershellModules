﻿<#
$Global:LdapConnection=@{
    server=$null
    port=636
    credential=$null
    connection=$null
}

$Global:Postfix=@{
    Host="tom.rz.uni-passau.de"
    VirtualTable="/etc/postfix/virtual"
}

$Global:Exchange=@{
    DefaultHost="msxpo1.ads.uni-passau.de"
}
#>

$Global:PowershellConfigDir=($env:USERPROFILE + "\Documents\WindowsPowerShell\Config")

If (-not (Test-Path $Global:PowershellConfigDir)){
    mkdir $Global:PowershellConfigDir
}

#Konfig File schreiben

If(-not (Test-Path ($Global:PowershellConfigDir + "\Exchange-AdminPS.config.ps1"))){
    Set-Content -Path ($Global:PowershellConfigDir + "\Exchange-AdminPS.config.ps1") -Value (@'
$Global:LdapConnection=@{
    server=$null
    port=636
    credential=$null
    connection=$null
}

$Global:Postfix=@{
    Host="localhost"
    Table=@{
		Virtual = "/etc/postfix/virtual"
		SenderCanonical = "/etc/postfix/sender_canonical"
	}
}

$Global:SSH=@{
    PrivateKeyFile="$env:USERPROFILE\Documents\ssh\openssh.key"
}

$Global:Exchange=@{
    DefaultHost="localhost"
}
'@)

}
#Wenn Konfig File bereits existiert, Konfig File holen
else{
. ($Global:PowershellConfigDir + "\Exchange-AdminPS.config.ps1")
}



$Global:LdapAutocompleters = @{
    BaseDN={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        $results=Get-LdapSearchEntries -BaseDN '' -Filter '(|(objectclass=organizationalunit)(objectclass=organization))'

        if($wordToComplete -ne ''){
            $results=$results | ? {$_.DistinguishedName -like ("*"+$wordToComplete+"*")}
        }

        $results | ForEach-Object {
            $result=$_
            ('"' + $result.DistinguishedName + '"')
        }

    }
}


$Global:AdAutocompleters = @{

    User={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        $results=@()

        if($wordToComplete -ne ''){
            $results+=Get-ADUser -LDAPFilter ('(&(objectclass=user)(|(cn=' + $wordToComplete + ')(displayName=' + $wordToComplete + ')))') -SearchBase 'OU=account,OU=idm,DC=ads,DC=uni-passau,DC=de' -Properties displayName,mail
            $results+=Get-ADUser -LDAPFilter ('(&(objectclass=user)(|(cn=*' + $wordToComplete + '*)(displayName=*' + $wordToComplete + '*)))') -SearchBase 'OU=account,OU=idm,DC=ads,DC=uni-passau,DC=de' -Properties displayName,mail
        }
        else{
            $results+=Get-ADUser -LDAPFilter ('(objectclass=user)') -SearchBase 'OU=account,OU=idm,DC=ads,DC=uni-passau,DC=de' -Properties displayName,mail
        }

        $results | ForEach-Object {
            $result=$_
            ('"' + $result.Name + '" <#' + $result.DisplayName + '#>')
        }
    }

    <#
        Sucht nach Teams (W...,S...) in unserem Active Directory 
        uni-passau.de/idm/group
    #>
    Team={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        

        if($wordToComplete -ne ''){
            $results=Get-ADGroup -LDAPFilter ('(&(objectclass=group)(|(cn=*' + $wordToComplete + '*)(description=*' + $wordToComplete + '*)))') -SearchBase 'OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de' -Properties cn,description
        }
        else{
            $results=Get-ADGroup -LDAPFilter ('(objectclass=group)') -SearchBase 'OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de' -Properties cn,description
        }

        $results | ForEach-Object {
            $result=$_
            ('"' + $result.CN + '" <#' + $result.Description + '#>')
        }
    }

    TeamMember={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        

        if($wordToComplete -ne ''){
            $results=Get-ADGroup $fakeBoundParameters.Team | Get-ADGroupMember | Get-ADUser -Properties mail,displayName | Where-Object {
                $_.SamAccountName -like ('*' + $wordToComplete + '*') -or
                $_.displayName -like ('*' + $wordToComplete + '*') -or
                $_.mail -like ('*' + $wordToComplete + '*')
            }
        }
        else{
            $results=Get-ADGroup $fakeBoundParameters.Team | Get-ADGroupMember | Get-ADUser -Properties mail,displayName
        }

        if($results -ne $null){
            $results | ForEach-Object {
                $result=$_
                ('"' + $result.SamAccountName + '" <#' + $result.displayName + '#>')
            }
        }
        else{
            '<#No Teammembers found#>'
        }

    }

    DistributionGroup={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        if($wordToComplete -ne ''){
                $results=Get-DistributionGroup | Where-Object {$_.DisplayName -like '*' + $wordToComplete + '*'}
        }
        else{
            $results=Get-DistributionGroup
        }

        if($results -ne $null){
            $results | ForEach-Object {
                $result=$_
                ('"' + $result.Name + '" <#' + $result.DisplayName + '#>')
            }
        }
        else{
            '<#No DistributionGroup found#>'
        }


    }

    Mailbox={
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        if($wordToComplete -ne ''){
            $results=Get-Mailbox -Filter ('displayName -like "*' + $wordToComplete + '*" -or Name -like "*' + $wordToComplete + '*"')
        }
        else{
            $results=Get-Mailbox
        }

        if($results -ne $null){
            $results | ForEach-Object {
                $result=$_
                ('"' + $result.Name + '" <#' + $result.DisplayName + '#>')
            }
        }
        else{
            '<#No Mailbox found#>'
        }

    }

}


Function Connect-Exchange {
<#
.SYNOPSIS
    Verbindet sich mit einem Exchange Server zur Administration.
    Du musst Exchange Admin bzw Domain Admin sein.
.DESCRIPTION
    Das Commandlet verbindet sich über PS-Remoting mit einem Exchange Server.
    Die notwendigen Module zur Administration werden vom Exchange Server geladen
    es muss keine zusätzliche Software an deinem Client installiert werden
.LINK
    https://docs.microsoft.com/de-de/powershell/exchange/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps
.LINK
    https://www.msxfaq.de/code/powershell/psexremote.htm
.LINK
    https://social.technet.microsoft.com/Forums/ie/en-US/529bd0ef-5e88-4808-a5ac-dc07ca8660f3/importpssession-is-not-importing-cmdlets-when-used-in-a-custom-module?forum=winserverpowershell
#>
    param(
        $ExchangeServer=$Global:Exchange.DefaultHost,
        $Credential=(Get-Credential)
    )
    # Anmeldung mit aktuellen Benutzer im gleichen Forest
    
    $session = new-pssession `
       -ConfigurationName "Microsoft.Exchange" `
       -ConnectionUri ("http://" + $ExchangeServer + "/PowerShell/") `
       -Authentication Kerberos `
       -Credential $Credential


    # Session einbinden
    Import-Module(import-pssession -Session $session -AllowClobber) -Global
    #Import-PSSession $session -DisableNameChecking
    
    <#

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://msxpo1.ads.uni-passau.de/PowerShell/ -Authentication Kerberos -Credential $Credential
    Import-PSSession $Session -DisableNameChecking

    $session = New-PSSession -ComputerName $ExchangeServer -Credential $Credential
    Invoke-Command -Session $session {param($ExchangeServer);. 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -ServerFqdn $ExchangeServer } -ArgumentList $ExchangeServer
    #>


}


#ExchangeArgumentCompleters für Exchange-AdminPS.psm1
Set-Variable -Name "ExchangeArgumentCompleters" -Scope global `
    -Description "Argument Completers für Exchange-AdminPS.psm1" `
    -Value @{ #Alle Argument Completer Kommen in diese Hashtable
        ADUser={#ScriptBlock <- Das ist einfach nur ein Kommentar. Ein Scriptblock wird einfach mit "{" eingeleitet
            <#
            $Command            Command bei dem wir gerade sind
            $Parameter          Parameter bei dem wir gerade sind
            $WordToComplete     Das Wort das der User gerade schreibt (als er auf TAB gedrückt hat)
            $CommandAst         Ich weiß es jedes mal wieder nicht -> einfach testen
            $FakeBoundParams    Hash Table von Parameter die bisher schon angegeben wurden
                                z.B. für so was:
                                Parameter "Datastore" wurde schon angegeben
                                Liefere mir NUR die VMs zurück auf die auf "Datastore" liegen
            #>                               
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            Get-ADUser -Filter ('SamAccountName -like "*'+ $WordToComplete +'*"') | ForEach-Object {('"'+$_.SamAccountName+'"')}
        }
    }




#("melanie.kreipl","sabrina.maier","nergis.bayrak").GetType()

Function Get-ADUsers {
    param(
        [System.Array]$samaccountnames
    )

    Begin{
        $a_users=@()
    }

    Process{
        $samaccountnames | ForEach-Object{
            $a_users+=Get-ADUser -Identity ([string]$_)
        }
    }

    End{
        $a_users
    }

}


#Exchange Management Laden
<#
. 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'
Connect-ExchangeServer -auto -ClientApplication:ManagementShell 
#>



Function Connect-LDAP {
<#
.SYNOPSIS
    Verbindet sich mit einem LDAP Verzeichnis
.DESCRIPTION
    Verbindet sich mit einem LDAP Verzeichnis.
    Verbidungsinformationen werden in der Hashtable $Global:LdapConnection gespeichert
    In diesem Kontext kann dann weiter gearbeitet werden
.PARAMETER BindCredential
    Credential mit dem man sich mit dem LDAP Verbindet (User, Passwort)
.PARAMETER LdapHost
    LdapHost
.PARAMETER LdapPort
    Port des LDAP Servers
.PARAMETER LdapVersion
    Ldap Protokoll Version
.PARAMETER LdapSSL
    Bestimmt ob SSL / TLS verwendet werden soll. (Default: $true)
#>

    [CmdletBinding()]
    param(
    $BindCredential=(Get-Credential -Message "Authenticate for LDAP Connection"),
    [ValidateSet('edir-idm.uni-passau.de','edir-idm-test.uni-passau.de')]
    $LdapHost='edir-idm.uni-passau.de',
    $LdapPort=636,
    $LdapVersion=3,
    [switch]$LdapSSL=$true
    )

   [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols") | Out-Null 

    $Global:LdapConnection.server=$LdapHost
    $Global:LdapConnection.Port=$LdapPort
    $Global:LdapConnection.credential=$BindCredential
    
    $Connection = New-Object System.DirectoryServices.Protocols.LdapConnection ($LdapHost + ':' + $LdapPort)
    $Connection.SessionOptions.ProtocolVersion = $LdapVersion
    $Connection.SessionOptions.SecureSocketLayer = $LdapSSL
    $Connection.SessionOptions.VerifyServerCertificate = { return $true }
    $Connection.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic
    $Connection.Credential = New-Object 'System.Net.NetworkCredential' -ArgumentList ('cn=' + $BindCredential.UserName +',ou=rz,o=uni-passau'),$BindCredential.GetNetworkCredential().password
    $Connection.Bind()
    
    $Global:LdapConnection.connection=$Connection
    $Connection
}


Function Get-LdapSearchEntries {
<#
.SYNOPSIS
    Sucht nach Einträgen in einem LDAP und liefet die Search Entry Liste zurück
.PARAMETER cn
    Common Name nach dem gesucht werden soll
.PARAMETER Connection
    LDAP Verbindung die für diese Query verwendet werden soll
    Default $Global:LdapConnection
#>

    param(
        $cn='',
        $Connection=$Global:LdapConnection.connection,
        $BaseDN='o=uni-passau',
        $Filter=''
    )
    
    #$BaseDN = 'o=uni-passau'
    #$Filter = '(|(cn=' + ($cns.User -join ')(cn=') + '))'

    If($Filter -eq ''){
        $Filter = '(|(cn='+$cn+'))'
    }
    <#
    else{
        $Filter
    }
    #>

    $Scope = [System.DirectoryServices.Protocols.SearchScope]::SubTree
    $SearchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest -ArgumentList $BaseDN,$Filter,$Scope,'*'
    $SearchResult = $Connection.SendRequest($SearchRequest)
    #$SearchResult
    $SearchResult.Entries
}




Function Add-TeamMailboxPermissions {
    
    param(
        $Team,
        $FullAccess,
        $SendAs
    )

    Begin{

    }

    Process{

    }

    End {
        $mb=Get-Mailbox ($Team + '_Team')
        $MbAdUser=Get-ADUser ($Team + '_Team') -Properties mail,displayName


        #FullAccess wird in der Mailbox gesetzt
        ForEach($user in $FullAccess){
            $mb | Add-MailboxPermission -AccessRights 'FullAccess' -User (Get-ADUser $user).SamAccountName
        }
        
        #SendAs ist ein Extended AD Right
        ForEach($user in $SendAs){
            Add-ADPermission -Identity $MbAdUser.DistinguishedName -User (Get-ADUser $user).SamAccountName -AccessRights ExtendedRight -ExtendedRights "Send As"
        }
    }


}

Function Add-TeamDistributionGroupPermissions {
    
    param(
        $Team,
        $DistributionGroup,
        $Owner,
        $Member,
        $SendAs,
        $SendOnBehalf
    )

    Begin{

    }

    Process{

    }

    End {
        $distriGroup=Get-DistributionGroup $DistributionGroup
        #$distriADUser=Get-ADUser $DistributionGroup.Name

        #ForEach($user in $Owner){
        if($Owner -ne $null){
            $distriGroup | Set-DistributionGroup -ManagedBy @{Add=$Owner}
        }
        #}

        ForEach($user in $Member){
            $distriGroup | Add-DistributionGroupMember -Member $user
        }

        #SendAs wird im AD als Recht gesetzt
        ForEach($user in $SendAs){
            $distriGroup | Add-ADPermission -AccessRights ExtendedRight -ExtendedRights 'Send As' -User $user
        }

        #SendOnBehalf wird in Distribution Group als Recht gesetzt
        ForEach($user in $SendOnBehalf){
            $distriGroup | Set-DistributionGroup -GrantSendOnBehalfTo @{add=$user}
            #Add-ADPermission -AccessRights ExtendedRight -ExtendedRights 'Send OnBehalf' -User $user
        }

    }

}

Function Get-PostfixSession {

    [CmdletBinding()]

    param(
        $TargetHost=$Global:Postfix.Host,
        $User="root",
        $PrivateKeyFile=$Global:SSH.PrivateKeyFile
    )

    #//XXX Todo. Alternativ Login mit Passwort wenn ich keinen private Key habe
    if((Test-Path $PrivateKeyFile)){
        $pwd = "XXXXXXXXX"
        $secure_pwd = $pwd | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $User, $secure_pwd
        New-SSHSession -ComputerName $TargetHost -KeyFile $PrivateKeyFile -Credential $Credential
    }
    else{
        $Credential=Get-Credential -UserName $User -Message "Login to Postfix"
        New-SSHSession -ComputerName $TargetHost -Credential $Credential
    }
}


Function Get-PostfixTable {
    [CmdletBinding()]
    param(
        $PostfixHost=$Global:Postfix.Host,
        [ValidateSet("Virtual","SenderCanonical")]
        $PostfixTable,
        $SSHPrivateKey=$Global:SSH.PrivateKeyFile
    )

    $session=Get-PostfixSession -TargetHost $PostfixHost -User root -PrivateKeyFile $SSHPrivateKey


    #$Global:Postfix.VirtualTable
    $i=0

    Switch($PostfixTable){
        "Virtual" {

            $config_file=$Global:Postfix.Table.$PostfixTable
            $result=Invoke-SSHCommand -SSHSession $session -Command "cat $config_file"
            $content=$result.Output

            $content -match '^[^#].*$' | ForEach-Object {
                $line=$_
                $match=$line | Select-String -Pattern '^([^\s]+)\s+([^\s]+)'
        
                New-Object -TypeName PSObject -Property ([ordered]@{
                    VirtualAddress=$match.Matches.Groups[1].Value
                    Recipients=$match.Matches.Groups[2].Value -split ","
                })        
            }
        }

        "SenderCanonical" {
            $config_file=$Global:Postfix.Table.$PostfixTable
            $result=Invoke-SSHCommand -SSHSession $session -Command "cat $config_file"
            $content=$result.Output

            $content -match '^[^#].*$' | ForEach-Object {
                $line=$_
                $match=$line | Select-String -Pattern '^([^\s]+)\s+([^\s]+)'
        
                New-Object -TypeName PSObject -Property ([ordered]@{
                    Sender=$match.Matches.Groups[1].Value
                    Canonical=$match.Matches.Groups[2].Value -split ","
                })        
            }
        }


    }


    $session.Disconnect()
}

Function New-PostfixEntry {
    [CmdletBinding()]
    param(
        [ValidateSet("Virtual","SenderCanonical")]
        $PostfixTable,
        $Entry,
        $Session
    )

    #(Get-PostfixSession -TargetHost $Global:Postfix.Host -User root -PrivateKeyFile $Global:SSH.PrivateKeyFile)
    Write-Host ("Erstelle Postfix Eintrag: "+$Entry)
    Invoke-SSHCommand -SSHSession $Session -Command ("echo '" + $Entry + "' >> " + $Global:Postfix.Table.$PostfixTable)

}

Function Invoke-Postmap{
    [CmdletBinding()]
    param(
        [ValidateSet("Virtual","SenderCanonical")]
        $PostfixTable,
        $Session
    )

    Write-Host ("Führe Postmap aus: " + $Global:Postfix.Table.$PostfixTable)
    Invoke-SSHCommand -SSHSession $Session -Command ("postmap " + $Global:Postfix.Table.$PostfixTable)

}



Function Search-PostfixTable {
    [CmdletBinding()]
    param(
        $PostfixHost=$Global:Postfix.Host,
        [ValidateSet("Virtual","SenderCanonical")]
        $PostfixTable,
        $Search,
        $SSHPrivateKey=$Global:SSH.PrivateKeyFile
    )

    $session=Get-PostfixSession -TargetHost $PostfixHost -User root -PrivateKeyFile $SSHPrivateKey


    #$Global:Postfix.VirtualTable
    $i=0

    if($PostfixTable -ne $null){
        $config_file=$Global:Postfix.Table.$PostfixTable
        $result=Invoke-SSHCommand -SSHSession $session -Command ("cat $config_file | grep -i '" + $Search + "'")
        $content=$result.Output
    }


    Switch($PostfixTable){
        "Virtual" {
            $content -match '^[^#].*$' | ForEach-Object {
                $line=$_
                $match=$line | Select-String -Pattern '^([^\s]+)\s+([^\s]+)'
        
                New-Object -TypeName PSObject -Property ([ordered]@{
                    VirtualAddress=$match.Matches.Groups[1].Value
                    Recipients=$match.Matches.Groups[2].Value -split ","
                })        
            }
        }

        "SenderCanonical" {
            $content -match '^[^#].*$' | ForEach-Object {
                $line=$_
                $match=$line | Select-String -Pattern '^([^\s]+)\s+([^\s]+)'
        
                New-Object -TypeName PSObject -Property ([ordered]@{
                    Sender=$match.Matches.Groups[1].Value
                    Canonical=$match.Matches.Groups[2].Value -split ","
                })        
            }
        }


    }


    $session.Disconnect()
}


Function Check-ExchangePostfixTables {

    [CmdletBinding()]
    param(
        [switch]$Detailed
    )

    Write-Progress -Activity "Vergleiche Postfix virtual und sender_canonical mit Exchange" -Status ("Hole Postfix Tabellen") -PercentComplete 0

    $PostfixVirtual=Get-PostfixTable -PostfixTable Virtual
    $PostfixSenderCanonical=Get-PostfixTable -PostfixTable SenderCanonical

    Write-Progress -Activity "Vergleiche Postfix virtual und sender_canonical mit Exchange" -Status ("Zähle Recipients") -PercentComplete 0
    $recipient_count=(Get-Recipient -ResultSize Unlimited | Measure-Object).Count

    $i=0
    Get-Recipient -ResultSize Unlimited | ForEach-Object {
        $o_recipient=$_

        $i_percent=$i / $recipient_count * 100
        Write-Progress -Activity "Vergleiche Postfix virtual und sender_canonical mit Exchange" -Status ("Arbeite an " + $o_recipient.DisplayName + " $i von $recipient_count") -PercentComplete $i_percent

        #Email Addressen im Exchange
        $a_uni_address=$o_recipient.EmailAddresses -match "(smtp|SMTP:)[^@]+@uni-passau\.de"
        $a_uni_plain=$a_uni_address -replace "^(smtp:|SMTP:)",""

        $a_ads_address=$o_recipient.EmailAddresses -match "(smtp|SMTP:)[^@]+@(ads|gw|pers|stud)\.uni-passau\.de"
        $a_ads_plain=$a_ads_address -replace "^(smtp:|SMTP:)",""

        #$a_uni_address
        #$a_uni_address.Count

        if($a_uni_address.Count -gt 0){
            $sender_canonical_check=$true
        }
        else{
            $sender_canonical_check=$false
        }

        #Virtual Check
        ForEach($address in $a_uni_address){
            $a_address_components=$address -split ":"
            if($a_address_components[1] -ne $null){

                if($a_address_components[0] -ceq "SMTP"){
                    $address_type="Primary"
                }
                else{
                    $address_type="Secondary"
                }

                $o_exchange_address=New-Object -TypeName PSObject -Property ([ordered]@{
                    Type=$address_type
                    Address=$a_address_components[1]
                })

                #Write-Host ("Arbeite an: " + $s_exchange_address)
                $a_ex_vals=$o_exchange_address.Address -split "@"
                $result=$PostfixVirtual | Where-Object{$_.VirtualAddress -eq $o_exchange_address.Address}
                $error_object=$false
                if($result -eq $null){
                    #Write-Host ("Keine VirtualAddress für " + $o_exchange_address.Address + " gefunden!")
                    $ErrorMessage=("Entry for "+ $o_exchange_address.Address + " Missing")
                    $error_object=$true
                }
                #Wenn wir den Postfix Eintrag auf sein "SOLL" überprüfen wollen
                elseif($Detailed){
                    if(-not ($result.VirtualAddress -eq $o_exchange_address.Address -and $result.Recipients -contains ($o_recipient.Name + "@ads.uni-passau.de"))){
                        $ErrorMessage=("Entry for "+ $o_exchange_address.Address + " Wrong: " + $result.VirtualAddress + " " + ($result.Recipients -join ","))
                        $error_object=$true
                    }
                }

                if($error_object){
                    New-Object -TypeName PSObject -Property ([ordered]@{
                                        Recipient=$o_recipient.DistinguishedName
                                        Address=$o_exchange_address.Address
                                        PfTable="Virtual"
                                        Message=$ErrorMessage
                                        EntryShouldBe=($o_exchange_address.Address + "`t" + ($o_recipient.Name + "@ads.uni-passau.de"))
                                        
                                    })
                }
            }

        }

        if($sender_canonical_check){

            #SenderCanonical Check
            ForEach($address in $a_ads_address){
                $a_address_components=$address -split ":"
                if($a_address_components[1] -ne $null){

                    if($a_address_components[0] -ceq "SMTP"){
                        $address_type="Primary"
                    }
                    else{
                        $address_type="Secondary"
                    }

                    $o_exchange_address=New-Object -TypeName PSObject -Property ([ordered]@{
                        Type=$address_type
                        Address=$a_address_components[1]
                    })

                    #Bei primären SMTP Addressen versenden wir eh schon mit dieser Adresse und benötigen somit keinen SenderCanonical Eintrag
                    #Für Sekundäre SMTP Addressen muss ich allerdings den SenderCanonical prüfen
                    $error_object=$false
                    if($o_exchange_address.Type -eq "Primary"){
                        $a_ex_vals=$o_exchange_address.Address -split "@"
                        $result=$PostfixSenderCanonical | Where-Object {$_.Sender -eq $o_exchange_address.Address}
                        if($result -eq $null){
                            #Write-Host ("Keinen SenderCanonical Eintrag für " + $o_exchange_address.Address + " gefunden!")
                            $ErrorMessage=("Entry for "+ $o_exchange_address.Address + " Missing")
                            $error_object=$true
                        }
                        #Wenn wir den Postfix Eintrag auf sein "SOLL" überprüfen wollen
                        elseif($Detailed){
                            if( -not ($result.Sender -eq $o_exchange_address.Address -and $a_uni_plain -contains $result.Canonical)){
                                $ErrorMessage=("Entry for "+ $o_exchange_address.Address + " Wrong: " + $result.Sender + " " + ($result.Canonical -join ","))
                                $error_object=$true
                            }
                        }


                        if($error_object){
                            New-Object -TypeName PSObject -Property ([ordered]@{
                                                Recipient=$o_recipient.DistinguishedName
                                                Address=$o_exchange_address.Address
                                                PfTable="SenderCanonical"
                                                Message=$ErrorMessage
                                                EntryShouldBe=($o_exchange_address.Address + "`t" + $a_uni_plain)
                                            })
                        }


                    }
                }
            }

        }


        $i++
    }

}





function Get-RandomCharacters($length, $characters) { 
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length } 
    $private:ofs="" 
    return [String]$characters[$random]
}

function Get-RandomPassword{

    $chars=@{
        a2Z = 'ABCDEFGHKLMNOPRSTUVWXYZabcdefghiklmnoprstuvwxyz'
        numbers= '1234567890'
        spChars= '!"§$%&/()=?}][{@#*+'

    }

    $password += Get-RandomCharacters -length 8 -characters $chars.a2Z
    $password += Get-RandomCharacters -length 3 -characters $chars.numbers
    $password += Get-RandomCharacters -length 2 -characters $chars.spChars
    $password += Get-RandomCharacters -length 5 -characters $chars.a2Z

    $password
}


Function ConvertTo-RegularMailbox {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline=$True, Mandatory=$true)]
        $Mailbox,
        $AdCredential=(Get-Credential -Message "Credential to Perform Active Directory Actions"),
        [switch]$enableAdUser
    )

    Begin{}

    Process{
        $Mailbox | ForEach-Object {

            $mb=Get-Mailbox -Identity $_.Identity

            #Nur Ausführen wenn eindeutig
            if(($mb | Measure-Object).Count -eq 1){
                $adUser=Get-ADUser $mb.SamAccountName
                $adUser | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText (Get-RandomPassword) -Force) -Credential $AdCredential

                $mb | Set-Mailbox -Type Regular

                if(-not $enableADUser){
                    $adUser | Disable-ADAccount -Credential $AdCredential
                }

            }
            

        }
    }

    End{}


}


#...................................
# Functions
#...................................

<#
//XXX das hier hat auch noch fehler. Also manche Posten so nen sch... ins Internet
#>

Function Convert-QuotaStringToKB() {

    Param(
    [Parameter( ValueFromPipeline=$True, Mandatory=$true)]
    [string]$CurrentQuota
    )

    [string]$CurrentQuota = ($CurrentQuota.Split("("))[1]
    [string]$CurrentQuota = ($CurrentQuota.Split(" bytes)"))[0]
    $CurrentQuota = $CurrentQuota.Replace(",","")
    [int]$CurrentQuotaInKB = "{0:F0}" -f ($CurrentQuota/1024)

    return $CurrentQuotaInKB
}


Function Get-MailboxQuota{
    [CmdletBinding()]
    param (

        [Parameter( ValueFromPipeline=$True, Mandatory=$true)]
        $Mailbox

	    )


    Begin {
    }

    Process {

        $Mailbox | ForEach-Object {
            $mb=$_

             $quota_issueWarning=$mb.IssueWarningQuota | Convert-QuotaStringToKB
             $quota_prohibitSend=$mb.ProhibitSendQuota | Convert-QuotaStringToKB
             $quota_prohibitSendReceive=$mb.ProhibitSendReceiveQuota | Convert-QuotaStringToKB
             $totalItemSize=$mbstats.TotalItemSize.Value | Convert-QuotaStringToKB
             $percent_used=$totalItemSize / $quota_prohibitSend * 100

             <#
             Write-Host ("Current Mailbox: " + $mb.Name + "(" + $mb.DisplayName + ")")
             Write-Host ("Current Quota (Prohibit Send Quota:" + $mb.ProhibitSendQuota)
             Write-Host ("Current Item Size:" + $mbstats.TotalItemSize.Value)
             Write-Host ("Percent Used: " + $percent_used + " %")
             #>

             $mb | Add-Member -MemberType NoteProperty -Name IssueWarningQuotaKB -Value $quota_issueWarning
             $mb | Add-Member -MemberType NoteProperty -Name prohibitSendQuotaKB -Value $quota_prohibitSend
             $mb | Add-Member -MemberType NoteProperty -Name prohibitSendReceiveQuotaKB -Value $quota_prohibitSendReceive
             $mb | Add-Member -MemberType NoteProperty -Name totalItemSize -Value $totalItemSize
             $mb | Add-Member -MemberType NoteProperty -Name percentUsed -Value $percent_used

             $mb | Select Identity,Name,displayName,IssueWarningQuota,IssueWarningQuotaKB,prohibitSendQuota,prohibitSendQuotaKB,prohibitSendReceiveQuota,prohibitSendReceiveQuotaKB,totalItemSize,percentUsed
        }
     }
     End{

     }
}


Function Set-MailboxQuota {

    [CmdletBinding()]
    param (

        [Parameter( ValueFromPipeline=$True, Mandatory=$true)]
        $Mailbox,

	    [Parameter( ParameterSetName='Increase' )]
	    [int]$IncreaseMB,

	    [Parameter( ParameterSetName='Decrease' )]
	    [int]$DecreaseMB

	    )


    Begin {
    }

    Process {

        $Mailbox | ForEach-Object {
            $mb=Get-Mailbox $_.Identity

             $quota_issueWarning=$mb.IssueWarningQuota | Convert-QuotaStringToKB
             $quota_prohibitSend=$mb.ProhibitSendQuota | Convert-QuotaStringToKB
             $quota_prohibitSendReceive=$mb.ProhibitSendReceiveQuota | Convert-QuotaStringToKB
             $totalItemSize=$mbstats.TotalItemSize.Value | Convert-QuotaStringToKB
             $percent_used=$totalItemSize / $quota_prohibitSend * 100

             Write-Host ("Current Mailbox: " + $mb.Name + "(" + $mb.DisplayName + ")")
             Write-Host ("Current Quota (Prohibit Send Quota:" + $mb.ProhibitSendQuota)
             Write-Host ("Current Item Size:" + $mbstats.TotalItemSize.Value)
             Write-Host ("Percent Used: " + $percent_used + " %")

             if($IncreaseMB -gt 0){
                $new_warning=($quota_issueWarning + ($IncreaseMB *1024)) *1024
                $new_prohibitSend=($quota_prohibitSend + ($IncreaseMB *1024)) *1024
                $new_prohibitSendReceive=($quota_prohibitSendReceive + ($IncreaseMB *1024)) *1024
             }
             if($DecreaseMB -gt 0){
                $new_warning=($quota_issueWarning - ($IncreaseMB *1024)) *1024
                $new_prohibitSend=($quota_prohibitSend - ($IncreaseMB *1024)) *1024
                $new_prohibitSendReceive=($quota_prohibitSendReceive - ($IncreaseMB *1024)) *1024
             }

             Write-Host ("#####################")
             Write-Host ("Setting new Quota")
             Write-Host ("#####################")

             $mb | Set-Mailbox -IssueWarningQuota $new_warning -ProhibitSendQuota $new_prohibitSend -ProhibitSendReceiveQuota $new_prohibitSendReceive
             $mb=Get-Mailbox $mb.Identity

             $quota_issueWarning=$mb.IssueWarningQuota | Convert-QuotaStringToKB
             $quota_prohibitSend=$mb.ProhibitSendQuota | Convert-QuotaStringToKB
             $quota_prohibitSendReceive=$mb.ProhibitSendReceiveQuota | Convert-QuotaStringToKB
             $totalItemSize=$mbstats.TotalItemSize.Value | Convert-QuotaStringToKB
             $percent_used=$totalItemSize / $quota_prohibitSend * 100

             Write-Host ("Mailbox: " + $mb.Name + "(" + $mb.DisplayName + ")")
             Write-Host ("New Quota (Prohibit Send Quota:" + $mb.ProhibitSendQuota)
             Write-Host ("New Item Size:" + $mbstats.TotalItemSize.Value)
             Write-Host ("New Percent Used: " + $percent_used + " %")


        }

    }

    End {

    }

}


Function Get-AutoMapping{
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline=$True, Mandatory=$true)]
        $Mailbox
    )

    Begin{}

    Process{
        $Mailbox | ForEach-Object {
            $mb = Get-Mailbox $_.Identity
            $aduser=Get-ADUser $mb.DistinguishedName -Properties msExchDelegateListLink
            $mb | Add-Member -MemberType NoteProperty -Name msExchDelegateListLink -Value ($aduser.msExchDelegateListLink -join ";")
            #Write-Host ($mb.msExchDelegateListLink -join ";")

            $mb | Select Name,Alias,msExchDelegateListLink
        }
    }

    End{}

}




Function Get-QuestCMGLog {
    Get-Content 'T:\Program Files (x86)\Dell\Coexistence Manager for GroupWise\Mail Connector\Logs\CMG.wlog'
}



Class QuestCMGProcessedMessage{
    $DateTime
    $LogType
    $FromSystem
    $FromAddress
    $ToSystem
    $ToAddress
    $LogFrom
    $LogTo
    $MessageId
    $Sender
    $Recipient
    $MessageSubject
    $Recipientstatus
    $ServerHostname
    $ClientHostname
}

Function Get-QuestCMGProcessedMessages{

    [cmdletBinding()]
    param(
        $StartDate=((Get-Date) - (New-TimeSpan -Days 14))
    )


    Get-QuestCMGLog | ForEach-Object {
        $line=$_

        #$match=$line | Select-String -Pattern '^([0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+,[0-9]+) ([A-Za-z]+).*from ([^ ]+) \(([^\)]+)\) to ([^ ]+) \(([^\)]+)\): Processed Message ID: ([^ ]+).*$'
        $match=$line | Select-String -Pattern '^([0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+,[0-9]+) ([A-Za-z]+).*from ([^ ]+) \(([^\)]+)\) to ([^ ]+) \(([^\)]+)\): Processed Message ID: ([^ ]+).*From: ([^ ]+).*To: ([^ ]+).*$'

        if($match -ne $null){

            $log_date=(Get-Date ($match.Matches.Groups[1] -replace ',','.'))

            if($log_date -gt $StartDate){

                $skipEmpty=$false

                $o_log=New-Object -TypeName QuestCMGProcessedMessage
                $o_log.DateTime=$log_date
                $o_log.LogType=$match.Matches.Groups[2]
                $o_log.FromSystem=$match.Matches.Groups[3]
                $o_log.FromAddress=$match.Matches.Groups[4]
                $o_log.ToSystem=$match.Matches.Groups[5]
                $o_log.ToAddress=$match.Matches.Groups[6]
                $o_log.MessageId=$match.Matches.Groups[7]
                $o_log.LogFrom=$match.Matches.Groups[8]
                $o_log.LogTo=$match.Matches.Groups[9]

                Get-ExchangeServer | Where-Object {$_.ServerRole -eq 'Mailbox'} | ForEach-Object {
                    $exserver=$_
                    $exlog=Get-MessageTrackingLog -Server $exserver.Name -MessageId $o_log.MessageId -Source SMTP | Select-Object -First 1
                    if($exlog -ne $null){

                        $exlog.Recipients | ForEach-Object {
                            $recipient=$_
                            $o_log.Sender = $exlog.Sender
                            $o_log.Recipient = $recipient 
                            $o_log.MessageSubject = $exlog.MessageSubject
                            $o_log.RecipientStatus = $exlog.RecipientStatus -join ","
                            $o_log.ServerHostname = $exlog.ServerHostname
                            $o_log.ClientHostname = $exlog.ClientHostname

                            $o_log
                            $skipEmpty=$true
                        }
                    }
                }

                if(-not $skipEmpty){
                    $o_log
                }
            }
        }
    }
}


Function zimMove-User{
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
            set-mailbox $user -UseDatabaseQuotaDefaults $false -ProhibitSendQuota ($send) -IssueWarningQuota ($warn) -ProhibitSendReceiveQuota ($receive)                }#Schleifenende        #Bildschirmausgabe der neu eingestellten Grenzen        ($QuotaUser)|Get-Mailbox|select -Property DisplayName,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota        }}function zimGet-MailQuota{<#.SYNOPSISZeigt verschiedene Quotas an..DESCRIPTIONMit diesem Cmdlet werden die Quotas für Warning, ProhibitSend sowie ProhibitSendReceive von den Mailboxen der übergebenen Benutzer angezeigt..PARAMETER QuotaUserSpezifiziert den Benutzer bzw. die Benutzer..EXAMPLEzimGet-MailQuota -QuotaUser Test_User.EXAMPLEzimGet-MailQuota -QuotaUser Test_User1,Test_User2,Test_User3.EXAMPLEzimGet-MailQuota -QuotaUser (Get-ChildItem Users.txt)Übergeben einer Textdatei in der die Benutzer aufgelistet sind. Pro Zeile nur ein Benutzer zulässig.#>    Param(    [Parameter(Mandatory=$True,ValueFromPipeline=$True)][String[]]$QuotaUser    )    process {        foreach($User in $QuotaUser){            Get-Mailbox $User|select -Property DisplayName,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota            }            }}function New-TeamDistributionGroup{<#.SYNOPSIS    Erstellt Distributiongroups. Notwendige "virtual" Einträge am Postfix Server werden automatisch ergänzt.DESCRIPTION    Erstellt Distributiongroups anhand der angegebenen Parameter. Es wird überprüft ob die E-Mail-Addresse bereits existiert    und gegebenenfalls abgebrochen. @uni-passau.de E-Mail-Addresse wird am Postfix Server (tom) ergänzt und ein Postmap    durchgeführt.PARAMETER NameSpezifiziert den System- bzw. DisplayName..PARAMETER AliasSpezifiziert den Aliasnamen. Am besten wird Gruppenname gefolt von Unterstrich und Präfix Emailadresse verwendet (z.B.: S001_Sekretariat).PARAMETER OwnerSpezifiziert den Besitzer der DistributionGroup. Hier wird der Einrichtungsleiter eingetragen..PARAMETER MembersSpezifiziert die Mitglieder der DistributionGroup. In unserem Fall wird hier nur die SharedMailbox eingetragen (z.B.: S001_Team).PARAMETER SendOnBehalfUsersSpezifiziert die Benutzer welche im Namen der DistributionGroup senden dürfen. Angabe der Benutzer mit kurzem Benutzernamen und via Komma getrennt.PARAMETER EmailAddressesSpezifiziert die EmailAdresse der DistributionGroup. Angabe von mehreren Emails durch Komma getrennt möglich. Die als erstes genannte EmailAdresse wird die Hauptadresse. Die Standard ADS-Adresse (z.B.: Sekretaria@ads.uni-passau.de) wird automatisch erzeugt. .EXAMPLEzimNew-DistributionGroup -Name ZIM-Sekretariat -Alias S001_Sekretariat -Owner User1 -Members S001_Team -SendOnBehalfUsers User2,User3 -EmailAddresses Zim-Sekretariat@uni-passau.de,ExampleTest@uni-passau.de.EXAMPLEzimNew-DistributionGroup -Path DistributionGroups.csv#>    Param(    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String]$Name,    [Parameter(Mandatory=$false,ParameterSetName='Normal')]$Alias,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String[]]$Owner,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String[]]$Members,    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String[]]$SendOnBehalfUsers,    [Parameter(Mandatory=$false,ParameterSetName='Normal')][String[]]$EmailAddresses,    [Parameter(Mandatory=$false,ParameterSetName='Path')][String]$Path    )            If($Alias -eq $null){        $Alias=$Name    }    $DisplayName=($Name + "@uni-passau.de")    if ($Name){        $EmailAddress=@()        #@ads.uni-passau.de-EmailAdresse dem Array hinzufügen (neues erstellen)        #= $EmailAddresses += $Name + "@ads.uni-passau.de"        $EmailAddress+=("SMTP:" + $Name + "@uni-passau.de")        $EmailAddress+=("smtp:" + $Name + "@ads.uni-passau.de")        #Zusätzliche Email Adressen        ForEach($addr in $EmailAddresses){            $EmailAddress+=("smtp:" + $addr)        }        $a_search_addresses=($EmailAddress -match "smtp:.*" -replace "^smtp:","")        #Postfix Check        $do_postfix_entry=$true        ForEach($search_address in $a_search_addresses){            $postfix_result=Search-PostfixTable -PostfixTable Virtual -Search $search_address            ForEach($item in $postfix_result){                Write-Warning("Postfix Eintrag in virtual existiert bereits: " + $item.VirtualAddress + "`t" + ($item.Recipients -join ","))                $do_postfix_entry=$false            }        }        #Exchange Check        $do_create=$true        ForEach($search_address in $a_search_addresses){            if(Check-MailAddressExistance -MailAddress $search_address){                Write-Error($search_address + " existiert bereits in Exchange. Distribution Group wird nicht angelegt")                $do_create=$false            }        }        #Wenn die Checks erfolgreich sind, dann DistributionGroup anlegen        if($do_create){            #Anlegen einer einzelnen DistributionGroup            new-DistributionGroup -name $Name -DisplayName $DisplayName -alias $Alias -managedby $Owner -members $Members -OrganizationalUnit "ads.uni-passau.de/exchange" `                -MemberJoinRestriction Closed -MemberDepartRestriction Closed -RequireSenderAuthenticationEnabled $false -Type Distribution |                     Set-DistributionGroup -EmailAddressPolicyEnabled $false -GrantSendOnBehalfTo $SendOnBehalfUsers -EmailAddresses $EmailAddress                         if($do_postfix_entry){                #Dann können wir uns hier auch noch um den Postfix kümmern                $postfix_session=Get-PostfixSession                New-PostfixEntry -Session $postfix_session -PostfixTable Virtual -Entry ($Name + "@uni-passau.de" + "`t" + $Name + "@ads.uni-passau.de")                Invoke-Postmap -Session $postfix_session -PostfixTable Virtual                $postfix_session.Disconnect()                Remove-SSHSession -SSHSession $postfix_session            }        }    } }Function Search-MailAddress{    [CmdletBinding()]    param(        $MailAddress    )    $result=Get-Recipient -Filter "EMailAddresses -eq '$MailAddress'"    $result}Function Check-MailAddressExistance {    [CmdletBinding()]    param(        $MailAddress    )    Write-Host "Prüfe Active Directory auf existenz der Mail Adresse $MailAddress"    $result=Search-MailAddress -MailAddress $MailAddress    if($result -ne $null){        Write-Host ("Adresse $MailAddress existiert bereits in AD-Objekt: " + $result.DistinguishedName)        $true    }    else{        $false    }}
function New-TeamSharedMailbox{<#.SYNOPSISErstellt SharedMailbox..DESCRIPTIONErstellt SharedMailboxes anhand der angegebenen Parameter..PARAMETER NameSpezifiziert den Namen, Displaynamen sowie das Alias der SharedMailbox..PARAMETER UsersSpezifiziert die Benutzer welche FullAccess sowie "Send As"-Rechte auf die SharedMailbox erhalten. Automapping wird zugleich deaktiviert..PARAMETER EmailAddressesSpezifiziert weitere Email-Adressen welche der SharedMailbox zugeordnet werden. Die Primäre bleibt dabei die ADS-Adresse (z.B.: S001_Team@ads.uni-passau.de).PARAMETER QuotaSetzt die Quota-Richtlinie um (Warning: 9,5GB; Send: 9,9GB; SendReceive: 10GB).EXAMPLEzimNew-SharedMailbox -Name S001_Team -User User1,User2 -EmailAddresses Example1@uni-passau.de,Example2@uni-passau.de -QuotaErstellt eine neue SharedMailbox bei der die angegebenen Benutzer FullAccess- sowie SendAs-Rechte besitzen, die weiteren Email-Adressen eingetragen werden und die Quotas gesetzt werden.#>    Param(    [Parameter(Mandatory=$true,ParameterSetName='Normal')][String]$Team,    [Parameter(Mandatory=$false,ParameterSetName='Normal')][String]$Name='',    [Parameter(Mandatory=$true,ParameterSetName='Normal')][Alias('TeamMember')][String[]]$Users,    [Parameter(ParameterSetName='Normal')][String[]]$EmailAddresses,    [Parameter(ParameterSetName='Normal')][Switch]$Quota    )    if($Name -eq ''){        $Name=$Team + '_Team'    }    #Mailbox erstellen    write-host "Neues Team mit dem Namen $Name anlegen..." -ForegroundColor Yellow    New-Mailbox -Name $Name -OrganizationalUnit ads.uni-passau.de/exchange -Shared|out-null        foreach ($User in $Users){        #Berechtigungen eintragen        #FullAccess        write-host "Berechtigungen für $User setzen..." -ForegroundColor Yellow        Add-MailboxPermission $Name -User $User -AccessRights FullAccess –AutoMapping $False|out-null        #SendAs        Add-ADPermission $Name -User $User -ExtendedRights "Send As"|out-null    }    #Quota setzen wenn angegeben    if ($Quota -eq $true){        write-host "Quota für $Name setzen..." -ForegroundColor Yellow        set-mailbox $Name -UseDatabaseQuotaDefaults $false -IssueWarningQuota ([math]::Floor(9.5 * 1024 * 1024 * 1024)) -ProhibitSendQuota ([math]::Floor(9.9 * 1024 * 1024 * 1024)) -ProhibitSendReceiveQuota ([math]::Floor(10 * 1024 * 1024 * 1024))    }    #Weitere Email-Adressen eintragen wenn angegeben    if ($EmailAddresses){        write-host "Weitere Email-Adressen hinzufügen..." -ForegroundColor Yellow        Set-Mailbox $name -EmailAddresses $EmailAddresses|out-null    }}function zimStart-Update{<#.SYNOPSISStellt den Server in den Wartungsmodus..DESCRIPTIONStellt den Server in den Wartungsmodus, z. B. für Updates, wobei per Parameter geregelt werden kann, auf welchen Server die Queue umverteilt werden soll..PARAMETER TargetDer Zielserver für die Mail-Queue (Standard: MSXRESTORE bzw. MSXPO1 auf MSXRESTORE)#>    Param(    [String]$Target = "msxrestore.ads.uni-passau.de"    )    Set-ServerComponentState $env:COMPUTERNAME -Component HubTransport -State Draining -Requester Maintenance    Redirect-Message -Server $env:COMPUTERNAME -Target $Target -Confirm:$false    Set-ServerComponentState $env:COMPUTERNAME -Component ServerWideOffline -State Inactive -Requester Maintenance}function zimEnd-Update{<#.SYNOPSISStellt den Server vom Wartungsmodus zurück in den Online-Modus..DESCRIPTIONStellt den Server vom Wartungsmodus zurück in den Online-Modus.#>    Set-ServerComponentState $env:COMPUTERNAME -Component ServerWideOffline -State Active -Requester Maintenance    Set-ServerComponentState $env:COMPUTERNAME -Component HubTransport -State Active -Requester Maintenance}function Reload-OfflineAddressBook {    Get-OfflineAddressBook | Update-OfflineAddressBook    Get-OfflineAddressBook}<#.EXAMPLEGet-Mailbox V012_Team | Get-MailboxCalendarPermissionAdd-MailboxFolderPermission -Identity V012_Team@ads.uni-passau.de:\Kalender -User achter@ads.uni-passau.de -AccessRights Editor#>function Get-MailboxCalendarPermission {    [cmdletBinding()]    param(    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]    $Mailbox    )    $mb_address=(Get-Mailbox $Mailbox).PrimarySMTPAddress.Address    Get-MailboxFolderPermission -Identity ($mb_address +":\Kalender")}

Function Copy-DistributionGroupMembersToSendOnBehalf {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $DistributionGroup
    )

    Begin{}

    Process{
        $DistributionGroup | ForEach-Object {
            $dg=Get-DistributionGroup $DistributionGroup.Identity
            $members=Get-DistributionGroupMember -Identity $dg.Identity

            $members | ForEach-Object {
                $member=$_
                $dg | Set-DistributionGroup -GrantSendOnBehalfTo @{Add=$member.Name}
            }
        }
    }

    End{}

}



Function Show-ManagementRoles {
<#
.SYNOPSIS
    Zeigt Exchange Management Rechte eines Users an
.PARAMETER ExUser
    AdUser für den die Rechte angezeigt werden sollen. Kann Via Pipe übergeben werden
.PARAMETER Details
    Switch ob Details angezeigt werden sollen. Bei den Details werden alle Cmdlets für die Rolle (RBAC) angezeigt
    (ManagementRoleEntries)
.EXAMPLE
    Get-ADUser -Identity "fesl16" | Show-ManagementRoles -Details | Out-GridView
.EXAMPLE
    Get-ADUser -Identity "fesl16" | Show-ManagementRoles -Details | ? RoleCmdlet -NotLike "Get-*" | Out-GridView
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $ExUser,
        [switch]$Details
    )

    Begin{}

    Process{
        $ExUser | ForEach-Object {
            if($_.GetType().Name -eq "String"){
                $adUser=Get-ADUser $_
            }
            elseif($_.GetType().Name -eq "ADUser"){
                $adUser=$_
            }
            else{
                $adUser=$null
            }
            
            if($adUser -ne $null){
                #Write-Host "start"

                $roleGroups=(Get-RoleGroup -Filter ('Members -eq "' + $adUser.DistinguishedName + '"'))

                $roleGroups | ForEach-Object {
                    $roleGroup=$_

                    $roleGroup.RoleAssignments | ForEach-Object {
                        $roleAssignment=$_

                        #$roleAssignment
                        #//XXX hier weiter

                        #$roleAssignment | Add-Member -MemberType NoteProperty -Name User -Value $adUser.Name
                        $o_roleAssignment=Get-ManagementRoleAssignment -Identity $roleAssignment

                        $o_mgmtScope=$null
                        if($o_roleAssignment.CustomRecipientWriteScope -ne $null){
                            $o_mgmtScope=Get-ManagementScope -Identity $o_roleAssignment.CustomRecipientWriteScope
                        }

                        $o_roleAssignment | Add-Member -MemberType NoteProperty -Name User -Value $adUser.Name -Force

                        if($o_mgmtScope -ne $null){
                            $o_roleAssignment | Add-Member -MemberType NoteProperty -Name RecipientFilter -Value $o_mgmtScope.RecipientFilter -Force
                        }

                        if($Details){
                            

                            Get-ManagementRoleEntry ((Get-ManagementRoleAssignment -Identity $roleAssignment).Role + "\*") | ForEach-Object {
                                $o_roleEntry=$_

                                $o_roleAssignment | Add-Member -MemberType NoteProperty -Name RoleCmdlet -Value $o_roleEntry.Name -Force
                                $o_roleAssignment | Add-Member -MemberType NoteProperty -Name CmdletParameters -Value $o_roleEntry.Parameters -Force
                                $o_roleAssignment | Select User,RoleAssigneeName,Role,RecipientWriteScope,CustomRecipientWriteScope,RecipientFilter,RoleCmdlet,CmdletParameters


                            }
                        }
                        else{
                            
                            $o_roleAssignment | Select User,RoleAssigneeName,Role,RecipientWriteScope,CustomRecipientWriteScope,RecipientFilter
                        }

                    }
                }

            }
            else{
                Write-Error "User nicht gefunden"
            }
        }
    }

    End{}
}


Function Get-MessageTrackingAllLogs {

    Get-ExchangeServer | ? ServerRole -eq Mailbox | ForEach-Object {
        $exsrv=$_
        Get-MessageTrackingLog -Server $exsrv.Name -Start "2020-07-27" -End "2020-07-30" -Sender "Schoeb06@ads.Uni-Passau.De"# -Recipient "Schoeb06@ads.Uni-Passau.De"
    } | Where-Object EventId -eq "SEND" | Sort-Object -Property Timestamp | Select-Object -First 100


}



Register-ArgumentCompleter -CommandName Get-LdapSearchEntries -ParameterName BaseDN -ScriptBlock $Global:LdapAutocompleters.BaseDN

Register-ArgumentCompleter -CommandName Add-TeamMailboxPermissions -ParameterName Team -ScriptBlock $Global:AdAutocompleters.Team
Register-ArgumentCompleter -CommandName Add-TeamMailboxPermissions -ParameterName FullAccess -ScriptBlock $Global:AdAutocompleters.TeamMember
Register-ArgumentCompleter -CommandName Add-TeamMailboxPermissions -ParameterName SendAs -ScriptBlock $Global:AdAutocompleters.TeamMember

Register-ArgumentCompleter -CommandName Add-TeamDistributionGroupPermissions -ParameterName Team -ScriptBlock $Global:AdAutocompleters.Team
Register-ArgumentCompleter -CommandName Add-TeamDistributionGroupPermissions -ParameterName DistributionGroup -ScriptBlock $Global:AdAutocompleters.DistributionGroup
Register-ArgumentCompleter -CommandName Add-TeamDistributionGroupPermissions -ParameterName Owner -ScriptBlock $Global:AdAutocompleters.TeamMember
Register-ArgumentCompleter -CommandName Add-TeamDistributionGroupPermissions -ParameterName Member -ScriptBlock $Global:AdAutocompleters.TeamMember
Register-ArgumentCompleter -CommandName Add-TeamDistributionGroupPermissions -ParameterName SendAs -ScriptBlock $Global:AdAutocompleters.TeamMember
Register-ArgumentCompleter -CommandName Add-TeamDistributionGroupPermissions -ParameterName SendOnBehalf -ScriptBlock $Global:AdAutocompleters.TeamMember


Register-ArgumentCompleter -CommandName New-TeamSharedMailbox -ParameterName Team -ScriptBlock $Global:AdAutocompleters.Team
Register-ArgumentCompleter -CommandName New-TeamSharedMailbox -ParameterName Users -ScriptBlock $Global:AdAutocompleters.TeamMember

Register-ArgumentCompleter -CommandName New-TeamDistributionGroup -ParameterName Owner -ScriptBlock $Global:AdAutocompleters.Mailbox
Register-ArgumentCompleter -CommandName New-TeamDistributionGroup -ParameterName Members -ScriptBlock $Global:AdAutocompleters.Mailbox
Register-ArgumentCompleter -CommandName New-TeamDistributionGroup -ParameterName SendOnBehalfUsers -ScriptBlock $Global:AdAutocompleters.Mailbox

Register-ArgumentCompleter -CommandName idm_Set-ExchangeDutyEmail -ParameterName User -ScriptBlock $Global:AdAutocompleters.User

Register-ArgumentCompleter -CommandName Get-Mailbox -ParameterName Identity -ScriptBlock $Global:AdAutocompleters.Mailbox
Register-ArgumentCompleter -CommandName Get-Mailbox -ScriptBlock $Global:AdAutocompleters.Mailbox


Register-ArgumentCompleter -CommandName Get-DistributionGroup -ParameterName Identity -ScriptBlock $Global:AdAutocompleters.DistributionGroup




Register-ArgumentCompleter -CommandName Get-ADUser -ParameterName Identity -ScriptBlock $Global:AdAutocompleters.User