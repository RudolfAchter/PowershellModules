```

NAME
    Remove-nbPowerOutlet
    
ÜBERSICHT
    Deletes a PowerOutlet in Netbox
    
    
SYNTAX
    Remove-nbPowerOutlet [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox PowerOutlet by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the PowerOutlet to delete
        
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
    
    PS C:\># Remove the PowerOutlet by id
    
    Remove-nbPowerOutlet -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove PowerOutlet returned from a get-nbPowerOutlet
    
    Get-NbPowerOutlet -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPowerOutlet -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

