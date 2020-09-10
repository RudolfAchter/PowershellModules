```

NAME
    Remove-nbDevicebayTemplate
    
ÜBERSICHT
    Deletes a DevicebayTemplate in Netbox
    
    
SYNTAX
    Remove-nbDevicebayTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox DevicebayTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the DevicebayTemplate to delete
        
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
    
    PS C:\># Remove the DevicebayTemplate by id
    
    Remove-nbDevicebayTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove DevicebayTemplate returned from a get-nbDevicebayTemplate
    
    Get-NbDevicebayTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbDevicebayTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

