```

NAME
    Remove-nbTopologyMap
    
ÜBERSICHT
    Deletes a TopologyMap in Netbox
    
    
SYNTAX
    Remove-nbTopologyMap [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox TopologyMap by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the TopologyMap to delete
        
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
    
    PS C:\># Remove the TopologyMap by id
    
    Remove-nbTopologyMap -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove TopologyMap returned from a get-nbTopologyMap
    
    Get-NbTopologyMap -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbTopologyMap -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

