```

NAME
    Remove-nbDevicebay
    
ÜBERSICHT
    Deletes a Devicebay in Netbox
    
    
SYNTAX
    Remove-nbDevicebay [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Devicebay by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Devicebay to delete
        
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
    
    PS C:\># Remove the Devicebay by id
    
    Remove-nbDevicebay -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Devicebay returned from a get-nbDevicebay
    
    Get-NbDevicebay -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbDevicebay -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

