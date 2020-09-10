```

NAME
    Remove-nbAggregate
    
ÜBERSICHT
    Deletes a Aggregate in Netbox
    
    
SYNTAX
    Remove-nbAggregate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Aggregate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Aggregate to delete
        
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
    
    PS C:\># Remove the Aggregate by id
    
    Remove-nbAggregate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Aggregate returned from a get-nbAggregate
    
    Get-NbAggregate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbAggregate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

