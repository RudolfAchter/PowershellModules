```

NAME
    Remove-nbDevice
    
ÜBERSICHT
    Deletes a Device in Netbox
    
    
SYNTAX
    Remove-nbDevice [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Device by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Device to delete
        
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
    
    PS C:\># Remove the Device by id
    
    Remove-nbDevice -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Device returned from a get-nbDevice
    
    Get-NbDevice -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbDevice -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

