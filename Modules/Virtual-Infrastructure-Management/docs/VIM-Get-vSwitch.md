```

NAME
    VIM-Get-vSwitch
    
ÜBERSICHT
    Holt vSwitches in der vCenter Umgebung anhand der angegebenen Kategorie
    
    
SYNTAX
    VIM-Get-vSwitch [[-tag_category] <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    gibt vSwitches zurück die mit der entsprechenden Kategorie getagged wurden
    die Tags werden auf die ESX-Hosts gesetzt da vSwitche direkt nicht getagged
    werden können
    
    Diese Funktion kann später als Helper verwendet werden um ein VLAN
    auf allen primären vSwitches zu erstellen
    
    geplante Kategorien:
    * vSwitchPrimary
    * vSwitchStorage
    * vSwitchInterlink
    * vSwitchMgmt
    * vSwitchHA
    * vSwitchFT
    
    Wichtige Tags:
        Tags werden auf ESX-HOST Objekte zugewiesen
        Category: vSwitchPrimary          Tag:vswitch0 (1) (2) usw    vSwitch für die primären Guest VLANs
        Category: vSwitchStorage          Tag:vswitch?                vSwitch für das Storage Netz
        Category: vSwitchInterlink        Tag:vswitch?                vSwitch der die Hosts direkt verbindet,
                                                                      oder auch Interlink für Guests 
                                                                      (Cluster HA Netz oder dergleichen)
        Category: vSwitchMgmt             Tag:vswitch?                hier ist das ESX Mgmt Netz drauf
        Category: vSwitchHA               Tag:vswitch?                hier drauf läuft HA
                                                                      (kann man Zukünftig evtl direkt aus vSwitch 
    auslesen)
        Category: vSwitchFT               Tag:vswitch?                hier drauf läuft Fault Tolerance
                                                                      (evtl auslesen)
    

PARAMETER
    -tag_category <String>
        Tag-Kategorie der gesuchten vSwitche, diese werden zurückgegeben
        
        Erforderlich?                false
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
    
    PS C:\>VIM-Get-vSwitch -tag_category vSwitchPrimary
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>$vswitch=VIM-Get-vSwitch -tag_category vSwitchPrimary
    
    $vswitch | Select VMHost,Name
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>$vswitch=VIM-Get-vSwitch
    
    $vswitch | Select VMHost,Category,Name
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-vSwitch



```

