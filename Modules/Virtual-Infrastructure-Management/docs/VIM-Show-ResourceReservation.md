```

NAME
    VIM-Show-ResourceReservation
    
ÜBERSICHT
    Zeigt ResourceConfiguration aller VMs (nur für die VMs die eine Reservierung haben)
    
    
SYNTAX
    VIM-Show-ResourceReservation [[-VM] <Object>] [-Presentation <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 (Get-VM)
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Presentation <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 Text
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
    
    PS C:\>VIM-Show-ResourceReservation -Presentation "GridWithVMValue"
    
    
    
    
    
    
    
VERWANDTE LINKS



```

