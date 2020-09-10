```

NAME
    Remove-nbRegion
    
ÜBERSICHT
    Deletes a Region in Netbox
    
    
SYNTAX
    Remove-nbRegion [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Region by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Region to delete
        
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
    
    PS C:\># Remove the Region by id
    
    Remove-nbRegion -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Region returned from a get-nbRegion
    
    Get-NbRegion -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRegion -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

