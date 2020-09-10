```

NAME
    Remove-nbPowerPort
    
ÜBERSICHT
    Deletes a PowerPort in Netbox
    
    
SYNTAX
    Remove-nbPowerPort [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox PowerPort by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the PowerPort to delete
        
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
    
    PS C:\># Remove the PowerPort by id
    
    Remove-nbPowerPort -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove PowerPort returned from a get-nbPowerPort
    
    Get-NbPowerPort -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPowerPort -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

