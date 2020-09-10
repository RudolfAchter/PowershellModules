```

NAME
    Remove-nbRack
    
ÜBERSICHT
    Deletes a Rack in Netbox
    
    
SYNTAX
    Remove-nbRack [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Rack by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Rack to delete
        
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
    
    PS C:\># Remove the Rack by id
    
    Remove-nbRack -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Rack returned from a get-nbRack
    
    Get-NbRack -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRack -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

