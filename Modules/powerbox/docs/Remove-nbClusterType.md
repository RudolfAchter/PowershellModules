```

NAME
    Remove-nbClusterType
    
ÜBERSICHT
    Deletes a ClusterType in Netbox
    
    
SYNTAX
    Remove-nbClusterType [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ClusterType by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ClusterType to delete
        
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
    
    PS C:\># Remove the ClusterType by id
    
    Remove-nbClusterType -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ClusterType returned from a get-nbClusterType
    
    Get-NbClusterType -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbClusterType -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

