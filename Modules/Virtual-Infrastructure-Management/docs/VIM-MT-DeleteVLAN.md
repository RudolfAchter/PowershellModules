```

NAME
    VIM-MT-DeleteVLAN
    
ÜBERSICHT
    Löscht ein VLAN in der kompletten VMWare Umgebung von Megatech
    
    
SYNTAX
    VIM-MT-DeleteVLAN [-vlan_name] <String> [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Script holt sich alle vSwitches der Hosts auf denen virtuelle Maschinen laufen.
    Auf diesen vSwitches wird das definierte VLAN gelöscht
    Dieses Cmdlet ist Hardcoded spezifisch für Megatech
    

PARAMETER
    -vlan_name <String>
        Name des neuen VLAN
        
        Erforderlich?                true
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
    
    PS C:\>VIM-MT-DeleteVLAN -vlan_name "DMZ-01"
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-MT-DeleteVLAN



```

