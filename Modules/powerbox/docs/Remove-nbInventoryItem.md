```

NAME
    Remove-nbInventoryItem
    
ÜBERSICHT
    Deletes a InventoryItem in Netbox
    
    
SYNTAX
    Remove-nbInventoryItem [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox InventoryItem by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the InventoryItem to delete
        
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
    
    PS C:\># Remove the InventoryItem by id
    
    Remove-nbInventoryItem -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove InventoryItem returned from a get-nbInventoryItem
    
    Get-NbInventoryItem -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbInventoryItem -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

