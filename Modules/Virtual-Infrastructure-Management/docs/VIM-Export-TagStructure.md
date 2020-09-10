```

NAME
    VIM-Export-TagStructure
    
ÜBERSICHT
    Exportiert die Virtual Infrastructure Management Tag Struktur in ein XML File (CliXML)
    Dieses File kann in ein anderes vCenter wieder importiert werden
    
    
SYNTAX
    VIM-Export-TagStructure [[-File] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Das exportierte File kannst du dann zum Beispiel zum Kunden kopieren und dort importieren.
    Beim Management System des Kunden muss entsprechend das Virtual-Infrastructure-Management Modul installiert sein
    

PARAMETER
    -File <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 TagStructure.cli.xml
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
    
    PS C:\>VIM-Export-TagStructure -File C:Temp\TagStructure.cli.xml
    
    
    
    
    
    
    
VERWANDTE LINKS



```

