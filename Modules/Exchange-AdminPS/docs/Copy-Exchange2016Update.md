```

NAME
    Copy-Exchange2016Update
    
ÜBERSICHT
    Aktuell "Semi Automatisiertes" Cumulative Update
    
    
SYNTAX
    Copy-Exchange2016Update [[-Server] <Object>] [[-IsoUncPath] <Object>] [[-CredentialForExchangeAdmin] <Object>] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Commandlet Kopiert die angegebene ISO zum Remote Server und bereitet ein Script zur Unattendet Installation
    vor und legt dieses in das selbe Verzeichnis C:\Install
    

PARAMETER
    -Server <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -IsoUncPath <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -CredentialForExchangeAdmin <Object>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 (Get-Credential -Message "Account mit Admin Rechten am Exchange Server (Voller 
        UserPrincipalName)")
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



```

