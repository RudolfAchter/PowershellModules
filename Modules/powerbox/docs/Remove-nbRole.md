```

NAME
    Remove-nbRole
    
ÜBERSICHT
    Deletes a Role in Netbox
    
    
SYNTAX
    Remove-nbRole [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Role by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Role to delete
        
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
    
    PS C:\># Remove the Role by id
    
    Remove-nbRole -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Role returned from a get-nbRole
    
    Get-NbRole -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRole -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

