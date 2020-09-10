```

NAME
    VIM-Show-VM-MissingTags
    
ÜBERSICHT
    Findet VMs mit fehlenden Tags
    
    
SYNTAX
    VIM-Show-VM-MissingTags [[-Contact] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Ruft VIM-Check-Tags für alle VMs auf und Formatiert die Ausgabe
    

PARAMETER
    -Contact <Object>
        
        Erforderlich?                false
        Position?                    1
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
    
    PS C:\>VIM-Get-VM-MissingTags | VIM-Show-VMValue
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Show-V
    M-MissingTags



```

