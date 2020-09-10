```

NAME
    Set-nbRack
    
ÜBERSICHT
    Sets properties on a Rack in Netbox
    
    
SYNTAX
    Set-nbRack [-object] <Object> [[-Id] <Int32>] [[-CustomProperties] <String[]>] [[-Lookup] <Hashtable>] [-Patch] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    This should handle mapping a simple hashtable of values and looking up any references.
    

PARAMETER
    -object <Object>
        The Rack to set
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Id <Int32>
        ID of the Rack to set
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 0
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -CustomProperties <String[]>
        List of custom properties
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Lookup <Hashtable>
        List of properties to lookup
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Patch [<SwitchParameter>]
        Looks up the current object and only sets changed properties
        
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
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>$lookup = @{
    
    device_type='dcim/device-types'
        device_role='dcim/device-roles'
        site='organization/sites'
        status='dcim/_choices'
    }
    $Rack = @{
        name = 'example'
        serial = 'aka123457'
        device_type = 'dl380-g9'
        device_role = 'oracle'
        site = 'chicago'
        status = 'active'
    }
    Set-nbRack -id 22 -lookup $lookup $Rack
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-nbRack | Foreach {$_.site = 'Seattle'; $_} | Set-nbRack
    
    
    
    
    
    
    
VERWANDTE LINKS



```

