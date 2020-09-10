```

NAME
    Remove-nbPrefix
    
ÜBERSICHT
    Deletes a Prefix in Netbox
    
    
SYNTAX
    Remove-nbPrefix [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox Prefix by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the Prefix to delete
        
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
    
    PS C:\># Remove the Prefix by id
    
    Remove-nbPrefix -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove Prefix returned from a get-nbPrefix
    
    Get-NbPrefix -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbPrefix -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

