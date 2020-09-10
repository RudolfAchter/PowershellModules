```

NAME
    Remove-nbClusterGroup
    
ÜBERSICHT
    Deletes a ClusterGroup in Netbox
    
    
SYNTAX
    Remove-nbClusterGroup [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ClusterGroup by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ClusterGroup to delete
        
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
    
    PS C:\># Remove the ClusterGroup by id
    
    Remove-nbClusterGroup -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ClusterGroup returned from a get-nbClusterGroup
    
    Get-NbClusterGroup -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbClusterGroup -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

