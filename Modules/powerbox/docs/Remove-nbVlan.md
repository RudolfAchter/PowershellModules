```

NAME
    Remove-nbVlan
    
ÜBERSICHT
    Deletes a Vlan in Netbox
    
    
SYNTAX
    Remove-nbVlan [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Vlan by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Vlan to delete
        
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
    
    PS C:\># Remove the Vlan by id
    
    Remove-nbVlan -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Vlan returned from a get-nbVlan
    
    Get-NbVlan -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbVlan -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

