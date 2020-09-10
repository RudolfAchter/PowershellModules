```

NAME
    Remove-nbIpAddress
    
ÜBERSICHT
    Deletes a IpAddress in Netbox
    
    
SYNTAX
    Remove-nbIpAddress [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox IpAddress by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the IpAddress to delete
        
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
    
    PS C:\># Remove the IpAddress by id
    
    Remove-nbIpAddress -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove IpAddress returned from a get-nbIpAddress
    
    Get-NbIpAddress -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbIpAddress -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

