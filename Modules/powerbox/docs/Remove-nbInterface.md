```

NAME
    Remove-nbInterface
    
ÜBERSICHT
    Deletes a Interface in Netbox
    
    
SYNTAX
    Remove-nbInterface [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Interface by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Interface to delete
        
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
    
    PS C:\># Remove the Interface by id
    
    Remove-nbInterface -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Interface returned from a get-nbInterface
    
    Get-NbInterface -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbInterface -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

