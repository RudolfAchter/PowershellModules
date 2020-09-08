
$ex_cred=Get-Credential

#Aktuellen Status der HubTransport aller Server sehen
Get-ExchangeServer | ForEach-Object {

    $exsrv=$_
    Get-ServerComponentState -Identity $exsrv.Name -Component HubTransport

}

#Fokus auf einen bestimmten Server
$current_server="MSXPO5.ads.uni-passau.de"
#HubTransport ausleeren aber keine neuen Nachrichten mehr annehmen
Set-ServerComponentState -Identity $current_server -Component HubTransport -State Draining -Requester Maintenance

#In einer Powershell Session auf dem Server
$ex_session=New-PSSession -ComputerName $current_server -Credential $ex_cred

#Seine Transport Services neu starten (zur Sicherheit)
Invoke-Command -Session $ex_session -ScriptBlock {Restart-Service MSExchangeTransport}
Invoke-Command -Session $ex_session -ScriptBlock {Get-Service MSExchangeTransport}

Invoke-Command -Session $ex_session -ScriptBlock {Restart-Service MSExchangeFrontEndTransport}
Invoke-Command -Session $ex_session -ScriptBlock {Get-Service MSExchangeFrontEndTransport}

#Mail Queue von diesem Server wird auf den nächsten Server verlagert
Redirect-Message -Server $current_server -Target MSXPO1.ads.uni-passau.de -Confirm:$false


#Hier Server Neu starten
#Hier Maintenance Mode wieder aufheben

Set-ServerComponentState -Identity $current_server -Component HubTransport -State Active -Requester Maintenance