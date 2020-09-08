```

NAME
    Connect-Exchange
    
ÜBERSICHT
    Verbindet sich mit einem Exchange Server zur Administration.
    Du musst Exchange Admin bzw Domain Admin sein.
    
    
SYNTAX
    Connect-Exchange [[-ExchangeServer] <Object>] [[-Credential] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Commandlet verbindet sich über PS-Remoting mit einem Exchange Server.
    Die notwendigen Module zur Administration werden vom Exchange Server geladen
    es muss keine zusätzliche Software an deinem Client installiert werden
    

PARAMETER
    -ExchangeServer <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $Global:Exchange.DefaultHost
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Credential <Object>
        
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
    
    
VERWANDTE LINKS
    https://docs.microsoft.com/de-de/powershell/exchange/connect-to-exchange-servers-using-remote-powershell?view=exchange-ps
    https://www.msxfaq.de/code/powershell/psexremote.htm
    https://social.technet.microsoft.com/Forums/ie/en-US/529bd0ef-5e88-4808-a5ac-dc07ca8660f3/importpssession-is-not-importing-cmdlets-when-used-in-a-custom-module?forum=winserverpowershell



```

