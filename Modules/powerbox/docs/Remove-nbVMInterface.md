```

NAME
    Remove-nbVMInterface
    
ÜBERSICHT
    Deletes a VMInterface in Netbox
    
    
SYNTAX
    Remove-nbVMInterface [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox VMInterface by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the VMInterface to delete
        
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
    
    PS C:\># Remove the VMInterface by id
    
    Remove-nbVMInterface -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove VMInterface returned from a get-nbVMInterface
    
    Get-NbVMInterface -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbVMInterface -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

