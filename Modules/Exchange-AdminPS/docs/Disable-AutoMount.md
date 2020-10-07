```

NAME
    Disable-AutoMount
    
ÜBERSICHT
    Schaltet Automount für eine SharedMailbox aus. Oder Schaltet dieses
    nur für bestimmte User aus
    
    
SYNTAX
    Disable-AutoMount [-Mailbox] <Object> [[-ForUser] <Object>] [[-Credential] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Mailbox <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -ForUser <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Credential <Object>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 $Global:exchange_current_ad_credential
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
    
    PS C:\>Get-Mailbox W040_Team | Disable-AutoMount -ForUser "achter","reitma04"
    
    
    
    
    
    
    
VERWANDTE LINKS



```

