```

NAME
    VIM-Get-VM-MissingTags
    
ÜBERSICHT
    Findet VMs mit fehlenden Tags
    
    
SYNTAX
    VIM-Get-VM-MissingTags [[-Contact] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Ruft VIM-Check-Tags für alle VMs und gibt die VMs zurück bei denen Tags fehlen
    

PARAMETER
    -Contact <Object>
        String oder Tag: Responsible für den VMs mit "MissingTags" gesucht werden. Wird ein Tag übergeben kann nach 
        "Creator" oder "Responsible" unterschieden werden
        
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
    
    PS C:\>VIM-Get-VM-MissingTags -Contact "Schneider*"
    
    #Zeigt VMs mit Schneider, Jens (oder alle die mit Schneider beginnen) als Responsible
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Get-VM-MissingTags
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>$tag=Get-Tag -Category Creator -Name "Schneider*"
    
    VIM-Get-VM-MissingTags -Contact $tag
    #Zeigt VMs mit Schneider, Jens als Creator
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    -MissingTags



```

