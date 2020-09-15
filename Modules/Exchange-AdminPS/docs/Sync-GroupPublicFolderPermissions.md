```

NAME
    Sync-GroupPublicFolderPermissions
    
ÜBERSICHT
    Erstellt Public Folders für AD Gruppen und Berechtigt die Mitglieder der AD Gruppe
    
    
SYNTAX
    Sync-GroupPublicFolderPermissions [[-ADGroups] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Für alle AD Gruppen die übergeben wurden, wird ein PublicFolder in einer Public Folder
    Mailbox erstellt. Die Mailboxen werden gleichmäßig auf die bestehenden Mailbox Databases
    verteilt.
    Mitglieder der AD Gruppe erhalten per Default das Recht "PublishingEditor"
    

PARAMETER
    -ADGroups <Object>
        Gruppen für die die Aktion durchgeführt werden sollen. Per Default werden alle Gruppen 
        aus OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de verwendet
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 (Get-ADGroup -SearchBase "OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de" -Filter "*" 
        -Properties Description)
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    
VERWANDTE LINKS



```

