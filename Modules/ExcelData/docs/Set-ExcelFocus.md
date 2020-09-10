```

NAME
    Set-ExcelFocus
    
ÜBERSICHT
    Setzt den Focus von Excel auf ein Dokument und bestimmte Tabellenblätter
    (Sheet Angabe mit Wildcard (*) möglich)
    
    
SYNTAX
    Set-ExcelFocus [-DocName] <Object> [-SheetName] <Object> [[-Mode] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -DocName <Object>
        Name des Dokuments das Fokussiert werden soll. Das Dokument muss mit dem selben
        User, in dem diese Powershell Instanz läuft, in Excel geöffnet sein
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SheetName <Object>
        Name des Sheets innerhalb des Excel Dokuments. Es wird die erste Tabelle
        (also wirklich als Tabelle Formatierte Tabelle) selektiert die in diesem
        Sheet gefunden wird
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Mode <Object>
        [ValidateSet("CurrentOpenExcel","File")]
        Es gibt diese Modi
            CurrentOpenExcel:   die Daten werden aus einer Tabelle der gerade geöffneten Excel Instanz geladen
            File:               die angegebene Excel Datei wird geöffnet und die Daten daraus entnommen
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 $global:current_excel_mode
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

