```

NAME
    Remove-nbConsoleConnection
    
ÜBERSICHT
    Deletes a ConsoleConnection in Netbox
    
    
SYNTAX
    Remove-nbConsoleConnection [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ConsoleConnection by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ConsoleConnection to delete
        
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
    
    PS C:\># Remove the ConsoleConnection by id
    
    Remove-nbConsoleConnection -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ConsoleConnection returned from a get-nbConsoleConnection
    
    Get-NbConsoleConnection -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbConsoleConnection -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

