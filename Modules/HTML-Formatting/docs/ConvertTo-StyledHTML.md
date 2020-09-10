```

NAME
    ConvertTo-StyledHTML
    
ÜBERSICHT
    Erstellt HTML mit Stylesheet
    
    
SYNTAX
    ConvertTo-StyledHTML [-Item] <Object> [[-Style] <String>] [-Fragment] [<CommonParameters>]
    
    
BESCHREIBUNG
    Nimmt Items aus der Pipe und formatiert diese mit dem übergebenen Stylesheet
    Wennn Objekte übergeben werden, werden diese in einer Tabelle Formatiert
    
    Wenn ein String übergeben wurde, wird davon ausgegangen, dass dies ein HTML String ist
    und dieses HTML wird mit dem Stylesheet Formatiert
    

PARAMETER
    -Item <Object>
        Zu übergebene Powershell Objekte
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -Style <String>
        String mit Stylesheet Definitionen
        Du kannst auch einen Style mit:
        Get-Content("DeinStylesheet.css")
        laden
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 $global:MailStyle
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Fragment [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
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

