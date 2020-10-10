```

NAME
    VIM-Sync-Contacts
    
ÜBERSICHT
    Synchronisiert Kontakte Tags im vCenter mit ActiveDirectory-User
    
    
SYNTAX
    VIM-Sync-Contacts [[-ADGroups] <Object>] [[-TagCategories] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    PREREQUISITE
    Active-Directory Windows Powershell Modul wird benötigt
    (Teil der Remoteserver-Verwaltungstools)
    
    - User die noch nicht als Tag in vCenter bekannt sind werden neu angelegt
    - Es werden keine User gelöscht
    - Bei bestehenden Usern wird dafür gesorgt, dass die Email Addresse in der Tag Description 
      mit der Email Addresse im Active Directory übereinstimmt um Versand an ungültüge Email-Addresse
      zu vermeiden
    

PARAMETER
    -ADGroups <Object>
        ARRAY Active Directory Gruppen die nach VMWare Usern durchsucht werden
        Standard: @("VMWare-MainUsers","VMWare-Administrators")
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $global:vim_ad_groups
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TagCategories <Object>
        Tag Kategorien mit denen diese User Synchronisiert werden 
        Es können also mehrere Tag-Kategorien diese Kontakte enthalten
        Standard: @("Responsible","Creator")
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 @("Responsible","Creator")
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
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Sync-C
    ontacts



```

