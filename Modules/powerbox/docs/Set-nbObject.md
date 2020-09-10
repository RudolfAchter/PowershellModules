```

NAME
    Set-nbObject
    
ÜBERSICHT
    Sets properties on a object in Netbox
    
    
SYNTAX
    Set-nbObject [[-Id] <Int32>] [-Resource] <String> [[-CustomProperties] <String[]>] [[-Lookup] <Hashtable>] 
    [-Patch] [-Object] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    This should handle mapping a simple hashtable of values and looking up any references.
    

PARAMETER
    -Id <Int32>
        ID of the object to set
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 0
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Resource <String>
        Which resource to set
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 
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
        
    -Object <Object>
        The Object to set
        
        Erforderlich?                true
        Position?                    5
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
    
    PS C:\>$lookup = @{
    
    device_type='dcim/device-types'
        device_role='dcim/device-roles'
        site='organization/sites'
        status='dcim/_choices'
    }
    $device = @{
        name = 'example'
        serial = 'aka123457'
        device_type = 'dl380-g9'
        device_role = 'oracle'
        site = 'chicago'
        status = 'active'
    }
    Set-nbObject -resource dcim/devices -id 22 -lookup $lookup @device
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Set-nbObject -resource dcim/devices -id 22 -name example2 -serial madeup -device_type dl380-gen8 -site 
    chicago -lookup device_type,site
    
    
    
    
    
    
    
VERWANDTE LINKS



```

