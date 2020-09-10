```

NAME
    VIM-Get-VM-OnWrongStorage
    
ÜBERSICHT
    Sucht VMs die auf der falschen Storage gehostet werden
    
    
SYNTAX
    VIM-Get-VM-OnWrongStorage [[-VM] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    //XXX Todo:
    Kategorisierung reicht nicht aus. Dachte hier an sowas
    Category: Storage Redundancy -> (Bronze Redundancy, Silver Redundancy, Gold Redundancy)
    Category: Storage Performance -> (Brnoze Performance, Silver Performance, Gold Performance)
    
    
    Wichtige Tags:
        Category: Stage          Tag:Live           produktive VMs primär auf LeftHand Cluster
        Category: Stage          Tag:Test           Test VMs primär auf TestESX lokales Raid5
        Category: Stage          Tag:Development    VMs für die Entwickler
    
        Die Caetgory Storage Stage wird verwendet um einer Storage MEHRERE mögliche Stages zuweisen
        (mehrfache Kardinalität)
    
        Category: Storage Stage          Tag:Live           produktive VMs primär auf LeftHand Cluster
        Category: Storage Stage          Tag:Test           Test VMs primär auf TestESX lokales Raid5
        Category: Storage Stage          Tag:Development    VMs für die Entwickler
    
    
    Vergleicht die Tags der VMs mit den Tags der Storages auf denen sie gehostet sind.
    Ist die Storage einem anderen Tag zugeordnet, wird die VM zurückgegeben
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $(Get-VM)
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    -OnWrongStorage



```

