```

NAME
    VIM-Archive-VM
    
ÜBERSICHT
    Archiviert angegebene VMs
    
    
SYNTAX
    VIM-Archive-VM [-VM] <Object> [-Confirm] [-SoftShutdownSeconds <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    die VMs werden wie folgt archiviert
    1. Heruntergefahren
    2. das Starten verhindert (mit einer ACL)
    3. Auf einen billigen Datastore archiviert
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Confirm [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SoftShutdownSeconds <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 300
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Archiv
    e-VM



```

