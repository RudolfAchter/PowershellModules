```

NAME
    Remove-nbExportTemplate
    
ÜBERSICHT
    Deletes a ExportTemplate in Netbox
    
    
SYNTAX
    Remove-nbExportTemplate [[-Id] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Deletes a netbox ExportTemplate by ID or via the pipeline.
    

PARAMETER
    -Id <Int32>
        ID of the ExportTemplate to delete
        
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
    
    PS C:\># Remove the ExportTemplate by id
    
    Remove-nbExportTemplate -id 1
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#Remove ExportTemplate returned from a get-nbExportTemplate
    
    Get-NbExportTemplate -search mything.contoso.com -Resource 'virtualization/virtual-machines' |
        Remove-nbExportTemplate -Resource 'virtualization/virtual-machines'
    
    
    
    
    
VERWANDTE LINKS



```

