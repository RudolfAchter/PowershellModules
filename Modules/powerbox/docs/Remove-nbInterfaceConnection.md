```

NAME
    Remove-nbInterfaceConnection
    
ÜBERSICHT
    Deletes a InterfaceConnection in Netbox
    
    
SYNTAX
    Remove-nbInterfaceConnection [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox InterfaceConnection by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the InterfaceConnection to delete
        
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
    
    PS C:\># Remove the InterfaceConnection by id
    
    Remove-nbInterfaceConnection -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove InterfaceConnection returned from a get-nbInterfaceConnection
    
    Get-NbInterfaceConnection -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbInterfaceConnection -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

