```

NAME
    Remove-nbVirtualMachine
    
ÜBERSICHT
    Deletes a VirtualMachine in Netbox
    
    
SYNTAX
    Remove-nbVirtualMachine [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox VirtualMachine by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the VirtualMachine to delete
        
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
    
    PS C:\># Remove the VirtualMachine by id
    
    Remove-nbVirtualMachine -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove VirtualMachine returned from a get-nbVirtualMachine
    
    Get-NbVirtualMachine -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbVirtualMachine -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

