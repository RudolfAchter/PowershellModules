```

NAME
    Remove-nbConsolePortTemplate
    
ÜBERSICHT
    Deletes a ConsolePortTemplate in Netbox
    
    
SYNTAX
    Remove-nbConsolePortTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ConsolePortTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ConsolePortTemplate to delete
        
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
    
    PS C:\># Remove the ConsolePortTemplate by id
    
    Remove-nbConsolePortTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ConsolePortTemplate returned from a get-nbConsolePortTemplate
    
    Get-NbConsolePortTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbConsolePortTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

