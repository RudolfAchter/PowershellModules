```

NAME
    Where-FileAge
    
ÜBERSICHT
    Filtert Dateien nach ihrem Alter
    
    
SYNTAX
    Where-FileAge [-Files] <Object> [[-AgeType] <String>] [[-AgeValue] <Object>] [[-AgeProperty] <String>] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    Eine Vereinfachte Möglichkeit Dateien nach ihrem Alter zu Filtern.
    Prinzipiell macht es dasselbe wie Where-Object.Nur hier sind diverse
    Parameter mit sinnvollen Vorbelegungen versehen und die Filter Anweisung
    kann etwas kürzer geschrieben werden
    

PARAMETER
    -Files <Object>
        Dateien aus der Pipe
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 (Get-Item *)
        Pipelineeingaben akzeptieren?true (ByValue)
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
        Position?                    2
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
        Position?                    3
        Standardwert                 (New-Timespan)
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -AgeProperty <String>
        Anhand welcher Property soll das Alter der Datei bestimmt werden
        z.B.
        -AgeProperty CreationTime
        
        Erforderlich?                false
        Position?                    4
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
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Get-Item * | Where-FileAge -AgeType NewerEqual -AgeValue (New-TimeSpan -Days -7)
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Mit Where-FileAge habe ich anscheinend ein Performance Problem.
    
    #Files die über die Pipe übergeben werden, werden anscheinend im Arbeitsspeicher gepuffert
    #Das führt bei einer riesigen Anzahl an Dateien zu Problemen
    #z.B. Problematischer Befehl
    Get-Item \\deslnsrvmention\MENTION\mention_produktiv\logfiles-xml\* | Where-FileAge -AgeType OlderEqual -AgeValue 
    (New-Timespan -Days -180)
    #Das hier könnte Performater sein
    Get-Item \\deslnsrvmention\MENTION\mention_produktiv\logfiles-xml\* | Where-Object {$_.LastWriteTime -le 
    ((Get-Date)+(New-Timespan -Days -180))}
    
    
    
    
    
VERWANDTE LINKS
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/File-Management.psm1/Where-FileAge



```

