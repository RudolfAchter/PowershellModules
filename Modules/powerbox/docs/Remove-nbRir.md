```

NAME
    Remove-nbRir
    
ÜBERSICHT
    Deletes a Rir in Netbox
    
    
SYNTAX
    Remove-nbRir [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Rir by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Rir to delete
        
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
    
    PS C:\># Remove the Rir by id
    
    Remove-nbRir -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Rir returned from a get-nbRir
    
    Get-NbRir -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRir -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

