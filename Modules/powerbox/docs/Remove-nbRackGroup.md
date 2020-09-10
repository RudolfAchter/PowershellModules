```

NAME
    Remove-nbRackGroup
    
ÜBERSICHT
    Deletes a RackGroup in Netbox
    
    
SYNTAX
    Remove-nbRackGroup [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox RackGroup by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the RackGroup to delete
        
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
    
    PS C:\># Remove the RackGroup by id
    
    Remove-nbRackGroup -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove RackGroup returned from a get-nbRackGroup
    
    Get-NbRackGroup -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRackGroup -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

