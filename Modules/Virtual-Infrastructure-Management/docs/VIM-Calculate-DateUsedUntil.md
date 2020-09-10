```

NAME
    VIM-Calculate-DateUsedUntil
    
ÜBERSICHT
    Wenn noch nicht vorhanden. Berechnet die initiale "VIM.DateUsedUntil"
    
    
SYNTAX
    VIM-Calculate-DateUsedUntil [-VM] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    Wenn noch kein "VIM.DateUsedUntil" gesetzt ist, wird folgendes Berechnet
    
        - Live          VIM.DateCreated + 5 Jahre
        - Development   VIM.DateCreated + 3 Jahre
        - Test          VIM.DateCreated + 3 Monate (Quartal)
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
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

