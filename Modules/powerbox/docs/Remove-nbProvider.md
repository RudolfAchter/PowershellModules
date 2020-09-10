```

NAME
    Remove-nbProvider
    
ÜBERSICHT
    Deletes a Provider in Netbox
    
    
SYNTAX
    Remove-nbProvider [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Provider by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Provider to delete
        
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
    
    PS C:\># Remove the Provider by id
    
    Remove-nbProvider -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Provider returned from a get-nbProvider
    
    Get-NbProvider -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbProvider -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

