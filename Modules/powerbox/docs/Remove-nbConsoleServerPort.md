```

NAME
    Remove-nbConsoleServerPort
    
ÜBERSICHT
    Deletes a ConsoleServerPort in Netbox
    
    
SYNTAX
    Remove-nbConsoleServerPort [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ConsoleServerPort by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ConsoleServerPort to delete
        
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
    
    PS C:\># Remove the ConsoleServerPort by id
    
    Remove-nbConsoleServerPort -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ConsoleServerPort returned from a get-nbConsoleServerPort
    
    Get-NbConsoleServerPort -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbConsoleServerPort -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

