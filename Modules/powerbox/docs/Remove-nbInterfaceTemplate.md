```

NAME
    Remove-nbInterfaceTemplate
    
ÜBERSICHT
    Deletes a InterfaceTemplate in Netbox
    
    
SYNTAX
    Remove-nbInterfaceTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox InterfaceTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the InterfaceTemplate to delete
        
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
    
    PS C:\># Remove the InterfaceTemplate by id
    
    Remove-nbInterfaceTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove InterfaceTemplate returned from a get-nbInterfaceTemplate
    
    Get-NbInterfaceTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbInterfaceTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

