```

NAME
    ConvertTo-nbID
    
ÜBERSICHT
    Helper function to lookup ids for a given lookup.
    
    
SYNTAX
    ConvertTo-nbID [-Source] <String> [-Value] <String> [<CommonParameters>]
    
    
BESCHREIBUNG
    Got a device type and need the ID? here's your guy. You could do it yourself, but let's face it - that's work.
    

PARAMETER
    -Source <String>
        The resource to lookup the thing.
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Value <String>
        The value to lookup
        
        Erforderlich?                true
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
    System.String
    
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>ConvertTo-nbID -source dcim/_choices/device:status -value Active
    
    
    
    
    
    
    
VERWANDTE LINKS



```

