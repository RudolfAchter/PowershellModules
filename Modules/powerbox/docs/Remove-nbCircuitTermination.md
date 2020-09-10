```

NAME
    Remove-nbCircuitTermination
    
ÜBERSICHT
    Deletes a CircuitTermination in Netbox
    
    
SYNTAX
    Remove-nbCircuitTermination [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox CircuitTermination by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the CircuitTermination to delete
        
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
    
    PS C:\># Remove the CircuitTermination by id
    
    Remove-nbCircuitTermination -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove CircuitTermination returned from a get-nbCircuitTermination
    
    Get-NbCircuitTermination -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbCircuitTermination -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

