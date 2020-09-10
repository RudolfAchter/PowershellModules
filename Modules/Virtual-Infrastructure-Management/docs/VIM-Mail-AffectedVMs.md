```

NAME
    VIM-Mail-AffectedVMs
    
ÜBERSICHT
    Mailt VMs die von einer Wartung betroffen sind
    
    
SYNTAX
    VIM-Mail-AffectedVMs [-VMHost] <Object> [-To <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Holt Informationen von allen VMs auf dem / den angegebenen Hosts
    

PARAMETER
    -VMHost <Object>
        Host der Von Wartung betroffen ist
        Kann auch ein Array von VMHosts sein (Get-VMHost)
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -To <String>
        E-Mail-Addresse an die das Ergebnis übermittelt werden soll
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 rudolf.achter@megatech-communication.de
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

