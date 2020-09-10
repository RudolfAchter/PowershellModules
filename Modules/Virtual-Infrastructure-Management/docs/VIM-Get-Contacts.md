```

NAME
    VIM-Get-Contacts
    
ÜBERSICHT
    Liefert die Kontakte zu einer virtuellen Maschine
    
    
SYNTAX
    VIM-Get-Contacts [-VM] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    Erwartet als Parameter eine virtuelle Maschine. Es werden die relevanten Ansprechparnter
    für die virtuelle Maschine zurückgegeben (ARRAY). Und das in folgender Reihenfolge:
        1. Ansprechpartner im Ansprechpartner Tag
        2. Creator wenn kein Ansprechpartner vorhanden
        3. Admins wenn kein Creator vorhanden
    

PARAMETER
    -VM <Object>
        
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

