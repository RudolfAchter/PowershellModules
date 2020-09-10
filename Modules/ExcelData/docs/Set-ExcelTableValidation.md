```

NAME
    Set-ExcelTableValidation
    
ÜBERSICHT
    Setzt eine Validation Regel für eine Spalte in einem Excel Sheet
    
    
SYNTAX
    Set-ExcelTableValidation [[-DocName] <String>] [[-SheetName] <String>] [[-Mode] <String>] [-Column] <String> 
    [-Pattern] <String> [[-Type] <String>] [-NoAutoCompletion] [<CommonParameters>]
    
    
BESCHREIBUNG
    Für die angesprochene Excel Datei wird eine Datei Namens
    <Dateiname>.validateSet.xml angelegt. In dieser XML-Datei werden
    die Regeln für die Validierung der Excel Datei angelegt.
    
    Excel Data kann mit einer Tabelle pro Sheet umgehen, mehr geht
    aktuell leider nicht. Das sollte in der Regel aber meist ausreichen
    
    Set-ExcelTableValidation kann für jede Spalte im Excel einmal ausgeführt werden
    somit kann für jede Spalte eine Regel gespeichert werden.
    Aktuell werden nur Regular Expressions unterstützt
    Als "pattern" gibtst du somit eine Regular Expression an die auf die Spalte angewandt wird
    Solange die Regular Expression auf die gesamte Spalte "matched" sind die Daten valide
    
    Sollte die Regular Expression einmal nicht zutreffen, werden die Daten als INvalide deklariert
    und Get-ExcelTable gibt keine Daten mehr zurück
    

PARAMETER
    -DocName <String>
        Dateiname der offenen Excel Datei.
        Oder Pfad zur zu öffnenden Excel Datei (im Mode "File")
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $global:current_excel_doc_name
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SheetName <String>
        Tabellenblatt in dem nach einer Tabelle gesucht werden soll.
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 $global:current_excel_sheet_name
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Mode <String>
        [ValidateSet("CurrentOpenExcel","File")]
        Es gibt diese Modi
            CurrentOpenExcel:   die Daten werden aus einer Tabelle der gerade geöffneten Excel Instanz geladen
            File:               die angegebene Excel Datei wird geöffnet und die Daten daraus entnommen
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 $global:current_excel_mode
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Column <String>
        Spalte für die eine Regel festgelegt werden soll
        
        Erforderlich?                true
        Position?                    4
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Pattern <String>
        Pattern. In diesem Fall die Regular Expression die für die Spalte festgelegt werden soll
        
        Erforderlich?                true
        Position?                    5
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Type <String>
        Für spätere Weiterentwicklung. Aktuell IMMER "RegEx"
        
        Erforderlich?                false
        Position?                    6
        Standardwert                 RegEx
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -NoAutoCompletion [<SwitchParameter>]
        Die Regular Expression wird immer um den Anfang und das Ende ergänzt (da dies gern vergessen wird)
        Es wird immer so Ergänzt:
        
            ^RegEx$
        
        Dies führt dazu, dass der GESAMTE Wert in der Spalte der Regular Expression entsprechen muss anstatt nur
        ein Teilstring. Würde man z.B. nur nach einer Ziffer suchen 
        
            [0-9]+
        
        würde die Regel zutreffen, wenn nur IRGENDEINE Ziffer im String vorkommen würde z.B.:
        
            blaBlubb7Blubb
        
        das ist nicht Hilfreich wenn ich sicherstellen will, dass NUR Ziffern im String vorkommen.
        Sollte die Auto Vervollständigung mit ^ und $ nicht gewünscht sein kannst du das eben
        mit diesem NoAutoCompletion Schalter ausschalten
        
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

