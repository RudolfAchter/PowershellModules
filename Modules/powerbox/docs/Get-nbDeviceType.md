﻿```

NAME
    Get-nbDeviceType
    
ÜBERSICHT
    Gets a DeviceType from Netbox
    
    
SYNTAX
    Get-nbDeviceType [[-Search] <String>] [-Query <Hashtable>] [-UnFlatten] [-APIUrl <Uri>] [<CommonParameters>]
    
    Get-nbDeviceType [-Id] <Int32> [-UnFlatten] [-APIUrl <Uri>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Rerieves DeviceType objects from netbox and automatically flattens them and
    preps them for further processing
    

PARAMETER
    -Search <String>
        Simple string based search
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Id <Int32>
        ID of the object to set
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 0
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Query <Hashtable>
        Query to find what you want
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -UnFlatten [<SwitchParameter>]
        Don't flatten the object
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -APIUrl <Uri>
        API Url for running without connecting
        
        Erforderlich?                false
        Position?                    named
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
    
    PS C:\>Get-nbDeviceType -id 22
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-nbDeviceType -query @{name='myDeviceType'}
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-nbDeviceType myDeviceType
    
    
    
    
    
    
    
VERWANDTE LINKS



```

