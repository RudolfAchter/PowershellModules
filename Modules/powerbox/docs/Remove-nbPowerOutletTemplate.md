```

NAME
    Remove-nbPowerOutletTemplate
    
ÜBERSICHT
    Deletes a PowerOutletTemplate in Netbox
    
    
SYNTAX
    Remove-nbPowerOutletTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox PowerOutletTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the PowerOutletTemplate to delete
        
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
    
    PS C:\># Remove the PowerOutletTemplate by id
    
    Remove-nbPowerOutletTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove PowerOutletTemplate returned from a get-nbPowerOutletTemplate
    
    Get-NbPowerOutletTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPowerOutletTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

