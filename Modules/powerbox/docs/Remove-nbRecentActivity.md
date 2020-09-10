```

NAME
    Remove-nbRecentActivity
    
ÜBERSICHT
    Deletes a RecentActivity in Netbox
    
    
SYNTAX
    Remove-nbRecentActivity [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox RecentActivity by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the RecentActivity to delete
        
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
    
    PS C:\># Remove the RecentActivity by id
    
    Remove-nbRecentActivity -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove RecentActivity returned from a get-nbRecentActivity
    
    Get-NbRecentActivity -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbRecentActivity -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

