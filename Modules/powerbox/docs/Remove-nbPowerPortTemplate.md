```

NAME
    Remove-nbPowerPortTemplate
    
ÜBERSICHT
    Deletes a PowerPortTemplate in Netbox
    
    
SYNTAX
    Remove-nbPowerPortTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox PowerPortTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the PowerPortTemplate to delete
        
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
    
    PS C:\># Remove the PowerPortTemplate by id
    
    Remove-nbPowerPortTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove PowerPortTemplate returned from a get-nbPowerPortTemplate
    
    Get-NbPowerPortTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPowerPortTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

