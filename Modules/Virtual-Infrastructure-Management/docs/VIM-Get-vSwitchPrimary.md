```

NAME
    VIM-Get-vSwitchPrimary
    
ÜBERSICHT
    Holt die primären vSwitches
    
    
SYNTAX
    VIM-Get-vSwitchPrimary [<CommonParameters>]
    
    
BESCHREIBUNG
    Holt die primären vSwitches in der aktuell verbundenen vCenter Umgebung
    
    Diese Funktion kann später als Helper verwendet werden um ein VLAN
    auf allen primären vSwitches zu erstellen.
    
       Wichtige Tags:
           Tags werden auf ESX-HOST Objekte zugewiesen
           Category: vSwitchPrimary          Tag:vswitch0 (1) (2) usw    vSwitch für die primären Guest VLANs
    

PARAMETER
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Get-PrimaryVswitch
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>$vswitch=VIM-Get-PrimaryVswitch
    
    $vswitch | Select VMHost,Name
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-vSwitchPrimar
    y



```

