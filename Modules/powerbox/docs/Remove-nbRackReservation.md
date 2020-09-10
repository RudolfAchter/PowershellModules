```

NAME
    Remove-nbRackReservation
    
ÜBERSICHT
    Deletes a RackReservation in Netbox
    
    
SYNTAX
    Remove-nbRackReservation [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox RackReservation by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the RackReservation to delete
        
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
    
    PS C:\># Remove the RackReservation by id
    
    Remove-nbRackReservation -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove RackReservation returned from a get-nbRackReservation
    
    Get-NbRackReservation -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRackReservation -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

