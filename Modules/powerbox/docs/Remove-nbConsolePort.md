```

NAME
    Remove-nbConsolePort
    
ÜBERSICHT
    Deletes a ConsolePort in Netbox
    
    
SYNTAX
    Remove-nbConsolePort [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ConsolePort by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ConsolePort to delete
        
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
    
    PS C:\># Remove the ConsolePort by id
    
    Remove-nbConsolePort -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ConsolePort returned from a get-nbConsolePort
    
    Get-NbConsolePort -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbConsolePort -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

