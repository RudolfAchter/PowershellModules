```

NAME
    Compress-SubFolders-GroupByTime
    
ÜBERSICHT
    Komprimiert Dateien in Unterordnern
    
    
SYNTAX
    Compress-SubFolders-GroupByTime [[-SourceFolder] <Object>] [[-TargetFolder] <Object>] [[-TimeGroupString] 
    <Object>] [-RemoveArchived] [[-AgeType] <String>] [[-AgeValue] <Object>] [[-AgeProperty] <Object>] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    Nehmen wir an du hast eine solche Struktur
    
    |--SourceFolder
    |  |
    |  |--SubFolder1
    |  |--|
    |  |  |--Datei1
    |  |  |--Datei2
    |  |--SubFolder2
    |  |--|
    |     |--Datei3
    |     |--Datei4
    |
    |--TargetFolder
    
    Du willst alle Dateien aus "SourceFolder" in "TargetFolder" Archivieren. 
    Du benötigst ale SubFolder aus "SourceFolder"
    Das Script legt alle SubFolder aus SourceFolder im TargetFolder an
    Die Dateien aus der Quelle werden gruppiert nach TimeGroupString im Target Folder abgelegt
    

PARAMETER
    -SourceFolder <Object>
        Hieraus werden die Dateien archiviert
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetFolder <Object>
        Hierhin werden die Dateien archiviert
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TimeGroupString <Object>
        Nach diesem DateTime String Muster werden die Archiv Gruppen generiert
        siehe: https://blogs.technet.microsoft.com/heyscriptingguy/2015/01/22/formatting-date-strings-with-powershell/
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 yyyy-MM
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -RemoveArchived [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -AgeType <String>
        Wie wird gefiltert
            OlderThan       Älter als Jetzt + Timespan
            OlderEqual      Älter oder gleich alt wie Jetzt + Timespan
            NewerThan       Neuer als Jetzt + Timespan
            NewerEqual      Neuer oder gleich wie Jetzt + Timespan
            BeforeDate      Älter als Angegebener DateTime
            BeforEqualDate  Älter oder gleich Alt wie angegebener DateTime
            AfterDate       Neuer als angegebener DateTime
            AfterEqualDate  Neuer oder gleich wie angegebener DateTime
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 OlderThan
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -AgeValue <Object>
        Ein TimeSpan oder DateTime der einen gesuchten Zeitpunkt beschreibt
        steht in Kombination mit "AgeType". ACHTUNG.
        Bei Timespans müssen Zeitpunkte in der Verganenheit als Negative
        Timespans angegeben werden z.B.:
        Das ist vor 7 Tagen (in der Vergangenheit)
        -AgeValue (New-Timespan -Days -7)
        
        Das ist in 7 Tagen (in der Zukunft)
        -AgeValue (New-Timespan -Days 7)
        
        Erforderlich?                false
        Position?                    5
        Standardwert                 0
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -AgeProperty <Object>
        Anhand welcher Property soll das Alter der Datei bestimmt werden
        z.B.
        -AgeProperty CreationTime
        
        Erforderlich?                false
        Position?                    6
        Standardwert                 LastWriteTime
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

