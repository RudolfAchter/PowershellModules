```

NAME
    Remove-nbTenant
    
ÜBERSICHT
    Deletes a Tenant in Netbox
    
    
SYNTAX
    Remove-nbTenant [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Tenant by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Tenant to delete
        
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
    
    PS C:\># Remove the Tenant by id
    
    Remove-nbTenant -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Tenant returned from a get-nbTenant
    
    Get-NbTenant -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbTenant -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

