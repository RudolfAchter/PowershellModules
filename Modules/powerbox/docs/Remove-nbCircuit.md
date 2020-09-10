```

NAME
    Remove-nbCircuit
    
ÜBERSICHT
    Deletes a Circuit in Netbox
    
    
SYNTAX
    Remove-nbCircuit [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Circuit by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Circuit to delete
        
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
    
    PS C:\># Remove the Circuit by id
    
    Remove-nbCircuit -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Circuit returned from a get-nbCircuit
    
    Get-NbCircuit -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbCircuit -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

