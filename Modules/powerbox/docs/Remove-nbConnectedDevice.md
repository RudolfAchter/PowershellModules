```

NAME
    Remove-nbConnectedDevice
    
ÜBERSICHT
    Deletes a ConnectedDevice in Netbox
    
    
SYNTAX
    Remove-nbConnectedDevice [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ConnectedDevice by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ConnectedDevice to delete
        
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
    
    PS C:\># Remove the ConnectedDevice by id
    
    Remove-nbConnectedDevice -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ConnectedDevice returned from a get-nbConnectedDevice
    
    Get-NbConnectedDevice -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbConnectedDevice -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

