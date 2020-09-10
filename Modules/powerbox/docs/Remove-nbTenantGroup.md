```

NAME
    Remove-nbTenantGroup
    
ÜBERSICHT
    Deletes a TenantGroup in Netbox
    
    
SYNTAX
    Remove-nbTenantGroup [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox TenantGroup by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the TenantGroup to delete
        
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
    
    PS C:\># Remove the TenantGroup by id
    
    Remove-nbTenantGroup -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove TenantGroup returned from a get-nbTenantGroup
    
    Get-NbTenantGroup -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbTenantGroup -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

