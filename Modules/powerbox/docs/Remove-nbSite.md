```

NAME
    Remove-nbSite
    
ÜBERSICHT
    Deletes a Site in Netbox
    
    
SYNTAX
    Remove-nbSite [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Site by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Site to delete
        
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
    
    PS C:\># Remove the Site by id
    
    Remove-nbSite -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Site returned from a get-nbSite
    
    Get-NbSite -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbSite -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

