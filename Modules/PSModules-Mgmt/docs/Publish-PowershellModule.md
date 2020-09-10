```

NAME
    Publish-PowershellModule
    
ÜBERSICHT
    Publiziert ein Powershell Modul nach Megatech Standard
    
    
SYNTAX
    Publish-PowershellModule [-Module] <String> [-RepositoryName] <Object> [[-Description] <Object>] [-MajorRelease] 
    [-FunctionsExportToDefault] [[-DocumentFormat] <Object>] [-NoDocument] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Module <String>
        Name des Moduls (wie in Get-Module angezeigt)
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -RepositoryName <Object>
        Name des Repositories an das Publiziert wird
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Description <Object>
        Beschreibung des Moduls. Beim ersten Publizieren muss die Description gesetzt werden
        bei einem Update kann man diesen Parameter weg lassen
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -MajorRelease [<SwitchParameter>]
        Ist dieser Switch gesetzt wird das Major Release um eins hoch gesetzt
        Minor Release fängt dann wieder bei 0 zu zählen an
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -FunctionsExportToDefault [<SwitchParameter>]
        Sorgt dafür dass einfach ALLE Funktionen exportiert werden
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DocumentFormat <Object>
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 markup
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -NoDocument [<SwitchParameter>]
        Normalerweise werden alle CMDlets des Moduls im Wiki dokumentiert.
        Mit diesem Switch wird das umgangen. Das ist eine Zeitersparniss, wenn keine neuen
        CMDlets hinzu gekommen sind sondern nur ein paar kleinere Bugfixes publiziert werden
        
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

