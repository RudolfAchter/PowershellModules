```

NAME
    Install-OwaDesign
    
ÜBERSICHT
    
    
SYNTAX
    Install-OwaDesign [-CasHosts] <Object> [[-CasCredential] <Object>] [[-FrontEndSourceFolder] <String>] 
    [[-BackEndSourceFolder] <String>] [[-TemporaryDrive] <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -CasHosts <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -CasCredential <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 (Get-Credential -Message "Admin für Exchange Server")
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -FrontEndSourceFolder <String>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 H:\git\intern\zim-config-files\msxpo1-test.adstest.uni-passau.de\C\Program 
        Files\Microsoft\Exchange Server\V15\FrontEnd\HttpProxy\owa\auth\themes\resources
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -BackEndSourceFolder <String>
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 H:\git\intern\zim-config-files\msxpo1-test.adstest.uni-passau.de\C\Program 
        Files\Microsoft\Exchange Server\V15\ClientAccess\Owa
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TemporaryDrive <String>
        
        Erforderlich?                false
        Position?                    5
        Standardwert                 O
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
    
    PS C:\>Get-ExchangeServer | Where-Object ServerRole -eq "Mailbox" | Install-OwaDesign
    
    
    
    
    
    
    
VERWANDTE LINKS



```

