```

NAME
    Remove-nbCircuitType
    
ÜBERSICHT
    Deletes a CircuitType in Netbox
    
    
SYNTAX
    Remove-nbCircuitType [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox CircuitType by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the CircuitType to delete
        
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
    
    PS C:\># Remove the CircuitType by id
    
    Remove-nbCircuitType -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove CircuitType returned from a get-nbCircuitType
    
    Get-NbCircuitType -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbCircuitType -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

