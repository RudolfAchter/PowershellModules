```

NAME
    VIM-UnArchive-VM
    
ÜBERSICHT
    Hebt den Archivierungszustand von VMs wieder auf
    
    
SYNTAX
    VIM-UnArchive-VM [-VM] <Object> -ToStage <Object> [-ToStorage <Object>] [-ToHost <Object>] [-ToFolder <Object>] 
    [-StartImmediately] [-Confirm] [<CommonParameters>]
    
    
BESCHREIBUNG
    Macht im Grunde das Umgekehrte von VIM-Archive-VM
    Genauere Beschreibung folgt noch
    

PARAMETER
    -VM <Object>
        (Get-VM) Objekt Virtuelle Maschine die wiederhergestellt wird
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -ToStage <Object>
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ToStorage <Object>
        Datastore (Get-Datastore) / Storage Objekt auf das wiedhergestellt wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ToHost <Object>
        VMHost Objekt (Get-VMHost) zu dem wiederhergestellt wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ToFolder <Object>
        VMFolder (Get-Folder) Objekt zu dem wiederhergestellt wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -StartImmediately [<SwitchParameter>]
        Switch. Wenn gesetzt wird die VM unmittelbar nach der wiederherstellung gestartet
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Confirm [<SwitchParameter>]
        Wird scheinbar in diesem Cmdlet nicht verwendet
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
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
    
    PS C:\>Get-VM deslnvmowncl | VIM-UnArchive-VM
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-VM "*.viblab.local" | ?{($_ | Get-Datastore).Name -contains "Netgear_LUN_Archive"} | VIM-Get-VMValue | 
    ?{(Get-Date $_."VIM.ArchiveDateArchived") -gt (Get-Date "2019-11-17 00:00")} | Select-Object -First 1
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-VM "deslnonexatt03" | VIM-UnArchive-VM -ToStage Test -ToStorage (Get-Datastore "NFS_testesxnfs") 
    -ToFolder (Get-Folder -Id (Get-Item vi:\megatech.local\vm\Test\Server\).Id)
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-UnArch
    ive-VM



```

