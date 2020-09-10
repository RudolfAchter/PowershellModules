```

NAME
    Remove-nbManufacturer
    
ÜBERSICHT
    Deletes a Manufacturer in Netbox
    
    
SYNTAX
    Remove-nbManufacturer [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Manufacturer by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Manufacturer to delete
        
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
    
    PS C:\># Remove the Manufacturer by id
    
    Remove-nbManufacturer -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Manufacturer returned from a get-nbManufacturer
    
    Get-NbManufacturer -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbManufacturer -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

