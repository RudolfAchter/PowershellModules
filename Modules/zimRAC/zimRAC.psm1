$Global:LdapConnection=@{
    server=$null
    port=636
    credential=$null
    connection=$null
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

}


#Exchange Management Laden

. 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'
Connect-ExchangeServer -auto -ClientApplication:ManagementShell 




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

