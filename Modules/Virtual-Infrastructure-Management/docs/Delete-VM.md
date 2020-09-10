```

NAME
    Delete-VM
    
ÜBERSICHT
    Löscht virtuelle Maschinen
    Ist ein Alias für das "Remove-VM" von VMWare da man bei Remove-VM das -DeletePermanently
    explizit angeben muss und das leicht vergessen werden kann
    
    
SYNTAX
    Delete-VM [-VM] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Get-VMEndOfLife -Contact "Fiedler*" | Delete-VM
    
    
    
    
    
    
    
VERWANDTE LINKS



```

