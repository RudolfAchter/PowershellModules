```

NAME
    VIM-Get-Snapshot
    
ÜBERSICHT
    Liefert alle Snapshots zurück
    
    
SYNTAX
    VIM-Get-Snapshot [-VM <Object>] [[-Value] <Int32>] [[-Unit] <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Liefert alle Snapshots der VMWare Umgebung
    Wird Value und Unit angegeben werden Snapshots zurückgeliefert
    die älter als die angegebenen Day, Month, Year sind
    
    Return SNAPSHOT
    

PARAMETER
    -VM <Object>
        Eine oder mehrere virtuelle Maschinen für die Snapshots angezeigt werden
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 (Get-VM)
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Value <Int32>
        Ein Wert fuer ein Alter
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 3
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Unit <String>
        Eine Einheit für ein Alter (Day, Month, Year)
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 Month
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
    
    PS C:\>VIM-Get-Snapshot
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Get-Snapshot | %{$_.VM}
    
    #Alle VMs mit Snapshots
    
    
    
    
    
VERWANDTE LINKS



```

