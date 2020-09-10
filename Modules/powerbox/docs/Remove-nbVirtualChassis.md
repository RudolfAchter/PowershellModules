```

NAME
    Remove-nbVirtualChassis
    
ÜBERSICHT
    Deletes a VirtualChassis in Netbox
    
    
SYNTAX
    Remove-nbVirtualChassis [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox VirtualChassis by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the VirtualChassis to delete
        
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
    
    PS C:\># Remove the VirtualChassis by id
    
    Remove-nbVirtualChassis -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove VirtualChassis returned from a get-nbVirtualChassis
    
    Get-NbVirtualChassis -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbVirtualChassis -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

