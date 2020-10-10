```

NAME
    VIM-Get-ContactTag
    
ÜBERSICHT
    Liefert den Tag eines Responsibles
    
    
SYNTAX
    VIM-Get-ContactTag [[-Name] <Object>] [[-Category] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Liefert den Tag eines Responsibles
    Hauptsächlich zur internen Verwendung im Virtual-Infrastructure-Management Modul
    Vielleicht aber auch als Standalone Cmdlet nützlich
    
    Die Display Names sehen im Active Directory ja so aus:
    Achter, Rudolf
    
    Die Tags in vCenter heissen z.B. so
    
    Achter, Rudolf; Responsible
    Achter, Rudolf; Creator
    
    Dieses Cmdlet vereinfacht hierzu einfach die Handhabung
    

PARAMETER
    -Name <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Category <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 Responsible
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

