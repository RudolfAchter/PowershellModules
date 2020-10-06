```

NAME
    Connect-Exchange
    
ÜBERSICHT
    Verbindet sich mit einem Exchange Server zur Administration.
    Du bekommst nur die Commandlets zur Verfügung auf die du auch
    berechtigt bist.
    
    
SYNTAX
    Connect-Exchange [[-ExchangeServer] <Object>] [[-Credential] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Commandlet verbindet sich über PS-Remoting mit einem Exchange Server.
    Die notwendigen Module zur Administration werden vom Exchange Server geladen
    es muss keine zusätzliche Software an deinem Client installiert werden
    

PARAMETER
    -ExchangeServer <Object>
        Hostname eines Exchange ClientAccess Servers über den gemanaged
        werden soll. Standardmäßig wird der Server aus dem Config File verwendet
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $Global:Exchange.DefaultHost
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Credential <Object>
        Credential mit dem sich am Exchange Server angemeldet wird. Standardmäßig
        wird das Credential vom User mit Get-Credential abgefragt. Wenn du das
        Credential explizit auf $null setzt wird eine Berechtigung deiner aktuellen
        Powershell Sitzung verwendet
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 (Get-Credential)
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Connect-Exchange -Credential $null
    
    #Fragt nach keinen Credentials. Verwendet Rechte der aktuellen Powershell Sitzung
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Connect-Exchange -Exchangeserver host.domain.com
    
    #Verbindet sich mittels Powershell Remoting auf den Exchange CAS host.domain.com
    
    
    
    
    
VERWANDTE LINKS
    https://docs.microsoft.com/de-de/powershell/exchange/connect-to-exchange-servers-using-remote-powershell?view=excha
    nge-ps
    https://www.msxfaq.de/code/powershell/psexremote.htm
    https://social.technet.microsoft.com/Forums/ie/en-US/529bd0ef-5e88-4808-a5ac-dc07ca8660f3/importpssession-is-not-im
    porting-cmdlets-when-used-in-a-custom-module?forum=winserverpowershell



```

