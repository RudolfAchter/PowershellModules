```

NAME
    Get-ExcelTable
    
ÜBERSICHT
    Holt aus Excel eine Tabelle aus einem Tabellen Blatt
    Eine Tabelle die auch als Tabelle formatiert wurde.
    Das zu liefernde Excel Tabellenblatt kann mit
    mit dem CMDlet Set-ExcelFocus "fokussiert" werden
    
    
SYNTAX
    Get-ExcelTable [[-DocName] <String>] [[-SheetName] <String>] [[-Mode] <String>] [-NoValidate] [<CommonParameters>]
    
    
BESCHREIBUNG
    Aktuell verbindet sich diese Funktion mit einer bereits laufenden
    Excel Instanz.
    Es ist denkbar diese Funktion so zu programmieren, dass man wahlweise
    eine bereits offene Excel Instanz verwenden kann oder eine gespeicherte
    Excel Datei öffnet.
    Die zurückgelieferten Daten werden als Powershell Objekt Array zurückgeliefert
    die Properties der Objekte bestehen aus den Excel Tabellen Spalten
    

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
        Tabellenblatt in dem nach einer Tabelle gesucht werden soll. Hier können 
        Wildcards verwendet werden z.B..
        VIB-*
        gibt dann alle Tabellen Blätter zurück die mit VIB-* beginnen.
        Die Tabellen sollten dann alle das gleiche Format haben (gleiche Spalten)
        weil die Tabellen dann für Powershell zu einer Tabelle zusammengefügt werden
        
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
        
    -NoValidate [<SwitchParameter>]
        
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
    keine Pipe Inputs
    
    
AUSGABEN
    Array aus Powershell Objekten. Properties sind die Spalten der Excel Tabelle
    
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>#tns_user_data.xlsx muss in Excel geöffnet sein
    
    Get-ExcelTable -DocName 'tns_user_data.xlsx' -SheetName 'user'
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-ExcelTable -Mode File -DocName 'L:\RAC\ToDo\2019-02-14 RZ Hann\tns_user_data.xlsx' -SheetName 'user'
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-ExcelTable -Mode File -DocName 'L:\RAC\ToDo\2019-02-14 RZ Hann\tns_user_data.xlsx' -SheetName 'user' | 
    Out-GridView
    
    
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>Get-ExcelTable -Mode File -DocName 'L:\RAC\ToDo\2019-02-14 RZ Hann\tns_user_data.xlsx' -SheetName 'user' | 
    Format-Table -AutoSize
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/ExcelData.psm1/Get-ExcelTable



```

