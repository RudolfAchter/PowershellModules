```

NAME
    Remove-nbService
    
ÜBERSICHT
    Deletes a Service in Netbox
    
    
SYNTAX
    Remove-nbService [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Service by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Service to delete
        
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
    
    PS C:\># Remove the Service by id
    
    Remove-nbService -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Service returned from a get-nbService
    
    Get-NbService -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbService -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

