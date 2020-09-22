
Function Get-ADUserLockouts {
<#
.SYNOPSIS
    Findet AD "Lockout" Events. Passiert wenn ein User gesperrt wird
.PARAMETER Credential
    Domain Admin Credentials
.PARAMETER DateFrom
    DateTime Objekt, ab wann suchen wir (mit Get-Date erzeugen)
    Default: Jetzt - 1 Tag
.PARAMETER DateTo
    DateTime Objekt, bis wann suche wir (mit Get-Date erzeugen)
    Default: Jetzt
.PARAMETER Whom
    Nur nach diesem User suchen
    Default $null bzw Alle User
.EXAMPLE
    Get-ADUserLockouts -Whom santam04 | Out-GridView
.EXAMPLE
    Get-ADUserLockouts | Out-GridView
#>
    param(
        $Credential=(Get-Credential -Message "Domain Admin Login"),
        $DateFrom=((Get-Date) - (New-TimeSpan -Days 1)),
        $DateTo=(Get-Date),
        $Whom
    )
    
    $Events=Find-Events -Report ADUserLockouts -DetectDC -Credential $Credential -DateFrom $DateFrom -DateTo $DateTo -Whom $Whom
    #Ausgabe
    $Events

}