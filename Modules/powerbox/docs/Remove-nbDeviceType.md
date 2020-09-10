```

NAME
    Remove-nbDeviceType
    
ÜBERSICHT
    Deletes a DeviceType in Netbox
    
    
SYNTAX
    Remove-nbDeviceType [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox DeviceType by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the DeviceType to delete
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 0
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
    
    PS C:\># Remove the DeviceType by id
    
    Remove-nbDeviceType -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove DeviceType returned from a get-nbDeviceType
    
    Get-NbDeviceType -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbDeviceType -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

