```

NAME
    VIM-MT-AddVLAN
    
ÜBERSICHT
    Erstellt ein neues VLAN in der kompletten VMWare Umgebung von Megatech
    
    
SYNTAX
    VIM-MT-AddVLAN [-vlan_name] <String> [-vlan_id] <Int32> [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Script holt sich alle vSwitches der Hosts auf denen virtuelle Maschinen laufen.
    Auf diesen vSwitches wird eine neue Portgroup für virtuelle Maschinen angelegt.
    Dieses Cmdlet ist Hardcoded spezifisch für Megatech
    

PARAMETER
    -vlan_name <String>
        Name des neuen VLAN
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -vlan_id <Int32>
        ID des neuen VLAN
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 0
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
    
    PS C:\>VIM-MT-AddVLAN -vlan_name "DMZ-01" -vlan_id "2502"
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-MT-AddVLAN



```

