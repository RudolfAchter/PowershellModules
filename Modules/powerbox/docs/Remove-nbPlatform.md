```

NAME
    Remove-nbPlatform
    
ÜBERSICHT
    Deletes a Platform in Netbox
    
    
SYNTAX
    Remove-nbPlatform [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Platform by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Platform to delete
        
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
    
    PS C:\># Remove the Platform by id
    
    Remove-nbPlatform -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Platform returned from a get-nbPlatform
    
    Get-NbPlatform -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPlatform -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

