
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
        $ExchangeServer="msxpo1.ads.uni-passau.de",
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

Register-ArgumentCompleter -CommandName Get-ADUsers -ParameterName samaccountnames -ScriptBlock $global:ExchangeArgumentCompleters.ADUser