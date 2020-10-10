```

NAME
    VIM-Clone-vCenter
    
ÜBERSICHT
    Erstellt eine Sicherheitskopie von vCenter
    
    
SYNTAX
    VIM-Clone-vCenter [<CommonParameters>]
    
    
BESCHREIBUNG
    Erstellt eine Sicherheitskopie von vCenter
    Es müssen vorher Tags auf Objekte festgelegt worden sein damit das Backup funktioniert
    
    Wichtige Tags:
        Category: Application          Tag:vCenterPrimary    Markierung für dem primären vCenter Host, dieser wird 
    gesichert
        Category: Application          Tag:vCenterBackup     Markierung für den vCenter Klon. Wenn das primäre vCenter 
    ausgefallen ist
                                                             muss der vCenter Klon als "vCenterPrimary" markiert werden
        Category: DatastoreUsage       Tag:Backup            Auf diesen Datastore wird vCenter geklont
        Category: HostUsage            Tag:Backup            Auf diesen Host wird vCenter geklont
    

PARAMETER
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>#Tags müssen vorher festgelegt worden sein. Siehe Description
    
    VIM-Clone-vCenter
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Clone-vCenter



```

