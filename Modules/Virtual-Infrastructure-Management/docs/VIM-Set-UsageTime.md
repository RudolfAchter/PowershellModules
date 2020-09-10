```

NAME
    VIM-Set-UsageTime
    
ÜBERSICHT
    Setzt "VIM.DateUsedUntil" Ab Heute + n
    
    
SYNTAX
    VIM-Set-UsageTime -VM <Object> [[-Value] <Int32>] [[-Unit] <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Dieses CMDlet nimmt den heutigen Tag und addiert n Tage, Monate, Jahre
    je nach Auswahl
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Value <Int32>
        n=$Value
        So Viele Tage, Monate, Jahre (je nach Unit) werden ab Heute addiert
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 0
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Unit <String>
        "Day"     +n Tage ab Heute
        "Month"   +n Monate ab Heute
        "Year"    +n Jahre ab Heute
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
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
    
    PS C:\>Get-VM deslnsrvfile01 | VIM-Set-UsageTime 100 Day | VIM-Show-VMValue
    
    #Setzt "DateUsedUntil" 100 Tage in die Zukunft ab heute
    #Und zeigt auch gleich das Ergebnis an
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-VM "*faxtest03*" | VIM-Set-UsageTime -Unit Month -Value 3 | VIM-Show-VMValue
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Set-Us
    ageTime



```

