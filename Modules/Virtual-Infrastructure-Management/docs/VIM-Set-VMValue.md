```

NAME
    VIM-Set-VMValue
    
ÜBERSICHT
    Setzt benutzerbefinierte Werte als Annotations in VMs
    
    
SYNTAX
    VIM-Set-VMValue [-VM] <Object> [-DateCreated <Object>] [-DateUsedUntil <Object>] [-CreationMethod <String>] 
    [-CreationUser <String>] [-ArchiveOrigDatastore <String>] [-ArchiveDateArchived <String>] [-ArchiveOrigFolderPath 
    <String>] [-Tenant <Object>] [-Application <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Setzt benutzerbefinierte Werte als Annotations in VMs
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -DateCreated <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DateUsedUntil <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -CreationMethod <String>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -CreationUser <String>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ArchiveOrigDatastore <String>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ArchiveDateArchived <String>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ArchiveOrigFolderPath <String>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Tenant <Object>
        ScriptBlock
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Application <Object>
        ScriptBlock
        
        Erforderlich?                false
        Position?                    named
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
    
    PS C:\>VIM-Set-VMValue -VM $vm -DateUsedUntil "2017-01-01" | Get-Annotation
    
    
    
    
    
    
    
VERWANDTE LINKS



```

