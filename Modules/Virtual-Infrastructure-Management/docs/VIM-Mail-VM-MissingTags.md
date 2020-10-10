```

NAME
    VIM-Mail-VM-MissingTags
    
ÜBERSICHT
    Verschickt Mails für VMs bei denen Tags fehlen
    Primär werden die Responsible angeschrieben
    Sollte ein Responsible fehlen, wird die Mail an den Creator geschickt
    
    
SYNTAX
    VIM-Mail-VM-MissingTags [[-MailTo] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Die Funktion marschiert durch VIM-Get-VM-MissingTags
    Inhalte der zu versendenden Mails werden in HashTables für die Empfänger summiert
    Die Empfänger werden in dieser Reihenfolge ermittelt:
        1. Responsible
        2. Creator
        3. $global:vim_ad_groups
    

PARAMETER
    -MailTo <Object>
        Ein Empfänger als String oder mehrere Empfänger als String Array.
        Standardmäßig wird diese Mail an die Responsible gesendet.
        Dieser Parameter dient als Umleitung (für Tests)
        
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
    
    PS C:\>VIM-Mail-VM-MissingTags
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Mail-V
    M-MissingTags



```

