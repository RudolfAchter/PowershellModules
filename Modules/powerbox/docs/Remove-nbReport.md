```

NAME
    Remove-nbReport
    
ÜBERSICHT
    Deletes a Report in Netbox
    
    
SYNTAX
    Remove-nbReport [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Report by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Report to delete
        
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
    
    PS C:\># Remove the Report by id
    
    Remove-nbReport -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Report returned from a get-nbReport
    
    Get-NbReport -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbReport -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

