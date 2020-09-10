```

NAME
    Remove-nbPowerConnection
    
ÜBERSICHT
    Deletes a PowerConnection in Netbox
    
    
SYNTAX
    Remove-nbPowerConnection [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox PowerConnection by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the PowerConnection to delete
        
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
    
    PS C:\># Remove the PowerConnection by id
    
    Remove-nbPowerConnection -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove PowerConnection returned from a get-nbPowerConnection
    
    Get-NbPowerConnection -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPowerConnection -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

