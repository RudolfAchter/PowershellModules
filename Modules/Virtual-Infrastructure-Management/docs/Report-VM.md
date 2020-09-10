```

NAME
    Report-VM
    
ÜBERSICHT
    Reportet virtuelle Maschinen bei denen ein bestimmter Event aufgetreten ist
    
    
SYNTAX
    Report-VM [[-EventMessage] <Object>] [[-Start] <Object>] [[-End] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Für ale Virtuelle Maschinen wird "Get-VIEvent" ausgeführt und diese Messages werden
    nach einem Event gefiltert. Maschinen die gefunden werden, werden zurückgegeben
    

PARAMETER
    -EventMessage <Object>
        EventMessage nach der gesucht wird. Kann mit Wildcard "*" gefiltert werden.
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Start <Object>
        DateTime Zeitpunkt ab dem gesucht wird
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 (Get-Date).AddDays(-1)
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -End <Object>
        DateTime Zeitpunkt bis zu dem gesucht wird
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 (Get-Date)
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
    
    PS C:\>Report-VM -EventMessage "vSphere HA restarted virtual machine*" -Start ((Get-Date).AddDays(-4))
    
    
    
    
    
    
    
VERWANDTE LINKS



```

