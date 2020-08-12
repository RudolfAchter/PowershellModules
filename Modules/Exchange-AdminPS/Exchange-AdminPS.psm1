


Function Connect-Exchange {
<#
.SYNOPSIS
    Verbindet sich mit einem Exchange Server zur Administration.
    Du musst Exchange Admin bzw Domain Admin sein.
#>
    . 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto -ClientApplication:ManagementShell 
}