```

NAME
    VIM-Copy-TagStructure
    
ÜBERSICHT
    Kopiert die Virtual Infrastructure Management Tag Struktur
    von einem vCenter in ein anderes
    
    
SYNTAX
    VIM-Copy-TagStructure [-oldVCenter] <Object> [-newVCenter] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    Verwendet VIM-Import-TagCategory und VIM-Import-Tag um alle Tag Kategorien vom alten vCenter zunächst zu 
    importieren
    Verbindet sich dann auf das neue vCenter und importiert alle Kategorien und Tags
    Danach kann manuell die Tag-Zuordnung im neuen vCenter gemacht werden
    

PARAMETER
    -oldVCenter <Object>
        Hostname oder IP-Addresse des alten vCenter Servers. Von diesem werden die Tags exportiert
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -newVCenter <Object>
        Hostname oder IP-Addresse des neuen vCenter Servers. dieser bekommt die Tags importiert
        
        Erforderlich?                true
        Position?                    2
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
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Copy-TagStructure



```

