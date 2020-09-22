```

NAME
    Get-ADUserLockouts
    
ÜBERSICHT
    Findet AD "Lockout" Events. Passiert wenn ein User gesperrt wird
    
    
SYNTAX
    Get-ADUserLockouts [[-Credential] <Object>] [[-DateFrom] <Object>] [[-DateTo] <Object>] [[-Whom] <Object>] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Credential <Object>
        Domain Admin Credentials
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 (Get-Credential -Message "Domain Admin Login")
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DateFrom <Object>
        DateTime Objekt, ab wann suchen wir (mit Get-Date erzeugen)
        Default: Jetzt - 1 Tag
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 ((Get-Date) - (New-TimeSpan -Days 1))
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DateTo <Object>
        DateTime Objekt, bis wann suche wir (mit Get-Date erzeugen)
        Default: Jetzt
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 (Get-Date)
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Whom <Object>
        Nur nach diesem User suchen
        Default $null bzw Alle User
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 
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
    
    PS C:\>Get-ADUserLockouts -Whom santam04 | Out-GridView
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-ADUserLockouts | Out-GridView
    
    
    
    
    
    
    
VERWANDTE LINKS



```

