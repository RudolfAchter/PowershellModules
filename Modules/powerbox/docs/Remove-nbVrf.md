```

NAME
    Remove-nbVrf
    
ÜBERSICHT
    Deletes a Vrf in Netbox
    
    
SYNTAX
    Remove-nbVrf [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Vrf by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Vrf to delete
        
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
    
    PS C:\># Remove the Vrf by id
    
    Remove-nbVrf -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Vrf returned from a get-nbVrf
    
    Get-NbVrf -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbVrf -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

