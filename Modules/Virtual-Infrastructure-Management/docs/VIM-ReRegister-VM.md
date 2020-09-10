```

NAME
    VIM-ReRegister-VM
    
ÜBERSICHT
    Registriert eine als Ungültig markierte VM am gleichen ESX Host Neu
    
    Es muss natürlich vorher die Storage erreichbar sein auf der die VMs gespeichert sind.
    Evtl hilft dir der Artikel:
    *http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Troubleshooting/vSphere_Infrastruktur_mit_VSA_
    Storage_nach_Stromausfall_wieder_in_Betrieb_nehmen
    
    ACHTUNG!
    Überprüfe vorher die VM auf dem ESX-Host auf mögliche Locks!!
    *https://kb.vmware.com/s/article/2110152
    
    
SYNTAX
    VIM-ReRegister-VM [-VM] <Object> [-NewVMHost <String>] [-SaveOnly] [<CommonParameters>]
    
    
BESCHREIBUNG
    1. Das CMDlet merkt sich vorher alle notwendigen Daten der VM
    - VM Name
    - VM Host
    - Pfad zur VMX Datei
    - Folder in vCenter
    - Annotations
    - Tags
    
    2. die VM wird dann von vCenter deRegistriert
    
    3. die VM wird von der VMX wieder registriert und in der VMs und Folder Ansicht im selben
    Folder wieder angelegt
    
    4. Annotations und Tags werden wieder gesetzt
    
    Situationen in denen so etwas notwendig ist entstehen manchmal bei Storage Ausfällen in ESX-Clustern.
    Auch wenn eine Storage temporär sauber heruntergefahren kann es sein, dass ich eine LUN mit einer neuen UID 
    registriert.
    Wenn das passiert werden entsprechende VMs an "Invalid" oder "(inaccessible)" (Kein Zugriff möglich) markiert, 
    obwohl
    die .vmx und .vmdk Dateien nicht gesperrt sind. Vorher ist aber trotzdem auf Locks zu prüfen
    

PARAMETER
    -VM <Object>
        "VM" oder "File"
        gib hier die neu zu registrierende VM an. Statt einer VM kannst du her auch ein File angeben. Passende Files 
        sind:
        *.ReRegister.Save.xml   <- Das sind VM Metadaten Files die vorher mit Export-VMCliXML exportiert wurden
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -NewVMHost <String>
        Sollte der Ursprüngliche ESX-Server nicht mehr funktionieren, 
        kannst du hiermit versuchen die VM auf einem anderen ESX zu registrieren.
        Name des VMHost als String
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SaveOnly [<SwitchParameter>]
        Exportiert nur eine XML Datei um alle Informationen zu haben
        
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
    
    PS C:\>#DAS HIER IST MIT VORSICHT ZU GENIESSEN!!!
    
    VIM-Get-VM-NotStartable | VIM-ReRegister-VM
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-ReRegister-VM -VM (Get-Item deslnvmvpnquarz.ReRegister.Save.xml) -NewVMHost deslnsrvesx01.megatech.local
    
    #Das hier registriert eine VM von einem "Backup File" auf den Alternativen Cluster Host 
    deslnsrvesx01.megatech.local
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-ReRegi
    ster-VM
    http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Troubleshooting/Zugriff_auf_vmx_nicht_m%C3%B6gl
    ich
    https://kb.vmware.com/kb/2110152
    https://kb.vmware.com/kb/1026043
    http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Troubleshooting/vSphere_Infrastruktur_mit_VSA_S
    torage_nach_Stromausfall_wieder_in_Betrieb_nehmen



```

