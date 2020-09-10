```

NAME
    Export-VMCliXML
    
ÜBERSICHT
    Exportiert die Metadaten einer virtuellen Maschine in eine XML-Datei (CliXML)
    
    
SYNTAX
    Export-VMCliXML [-VM] <Object> [-ToDir <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Mit dieser Funktion können die Metadaten einer virtuellen Maschine gesichert werden.
    Im Falle einer Fehlfunktion der vCenter Datenbank können diese Daten dann (komplett oder teilweise) mittels
    Powershell wieder importiert werden.
    Im Einfachsten Fall wird die Virtuelle Maschine dann einfach mit folgendem Befehl wieder registriert
    
    VIM-ReRegister-VM -File (Get-Item *.ReRegister.Save.xml)
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -ToDir <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 .
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

