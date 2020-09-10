```

NAME
    Remove-nbVlanGroup
    
ÜBERSICHT
    Deletes a VlanGroup in Netbox
    
    
SYNTAX
    Remove-nbVlanGroup [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox VlanGroup by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the VlanGroup to delete
        
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
    
    PS C:\># Remove the VlanGroup by id
    
    Remove-nbVlanGroup -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove VlanGroup returned from a get-nbVlanGroup
    
    Get-NbVlanGroup -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbVlanGroup -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

