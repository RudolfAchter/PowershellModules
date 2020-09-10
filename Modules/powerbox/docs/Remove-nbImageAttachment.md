```

NAME
    Remove-nbImageAttachment
    
ÜBERSICHT
    Deletes a ImageAttachment in Netbox
    
    
SYNTAX
    Remove-nbImageAttachment [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ImageAttachment by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ImageAttachment to delete
        
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
    
    PS C:\># Remove the ImageAttachment by id
    
    Remove-nbImageAttachment -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ImageAttachment returned from a get-nbImageAttachment
    
    Get-NbImageAttachment -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbImageAttachment -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

