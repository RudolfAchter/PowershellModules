```

NAME
    Remove-nbConsoleServerPortTemplate
    
ÜBERSICHT
    Deletes a ConsoleServerPortTemplate in Netbox
    
    
SYNTAX
    Remove-nbConsoleServerPortTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ConsoleServerPortTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ConsoleServerPortTemplate to delete
        
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
    
    PS C:\># Remove the ConsoleServerPortTemplate by id
    
    Remove-nbConsoleServerPortTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ConsoleServerPortTemplate returned from a get-nbConsoleServerPortTemplate
    
    Get-NbConsoleServerPortTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbConsoleServerPortTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

