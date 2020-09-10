```

NAME
    Remove-nbCluster
    
ÜBERSICHT
    Deletes a Cluster in Netbox
    
    
SYNTAX
    Remove-nbCluster [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Cluster by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Cluster to delete
        
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
    
    PS C:\># Remove the Cluster by id
    
    Remove-nbCluster -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Cluster returned from a get-nbCluster
    
    Get-NbCluster -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbCluster -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

