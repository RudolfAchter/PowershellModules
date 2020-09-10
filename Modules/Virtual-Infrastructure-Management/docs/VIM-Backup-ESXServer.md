```

NAME
    VIM-Backup-ESXServer
    
ÜBERSICHT
    Sichert die Konfiguration aller aktiven ESX-Server der verbundenen vCenter Umgebung
    
    
SYNTAX
    VIM-Backup-ESXServer [[-Destination] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    vCenter wird benötigt. Es werden alle "Connected" ESX-Server aus vCenter ausgelesen
    aus diesen ESX-Servern wird das ConfigBundle runtergeladen und gespeichert
    
    Gesichert wird nach: $global:vim_backup_path
    

PARAMETER
    -Destination <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $global:vim_backup_path
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
    
    PS C:\>VIM-Backup-ESXServer
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>$global:vim_backup_path="\\deslnsrvbackup\Image\VMWare"
    
    
    
    
    
    
    
VERWANDTE LINKS



```

