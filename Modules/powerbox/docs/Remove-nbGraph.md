```

NAME
    Remove-nbGraph
    
ÜBERSICHT
    Deletes a Graph in Netbox
    
    
SYNTAX
    Remove-nbGraph [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Graph by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Graph to delete
        
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
    
    PS C:\># Remove the Graph by id
    
    Remove-nbGraph -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Graph returned from a get-nbGraph
    
    Get-NbGraph -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbGraph -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

