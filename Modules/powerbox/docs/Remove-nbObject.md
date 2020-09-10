```

NAME
    Remove-nbObject
    
ÜBERSICHT
    Deletes an object from netbox
    
    
SYNTAX
    Remove-nbObject [-Id] <Int32> [-Resource] <String> [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox object by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        Which resource to delete
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 0
        Pipelineeingaben akzeptieren?true (ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Resource <String>
        Which resource type to delete
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 
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
    
    PS C:\># Remove the object by id
    
    Remove-nbObject -id 1 -Resource 'virtualization/virtual-machines'
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove an object from a get-nbobject
    
    Get-NbObject -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbObject -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

