```

NAME
    Import-VM-fromOVFDir
    
ÜBERSICHT
    Importiert eine VM von einem OVF Verzeichnis das zuvor mit Export-VM-toOVFDir exportiert wurde
    Es können auch mehrere OVF Verzeichnisse in einer Pipe oder als Array übergeben werden
    
    
SYNTAX
    Import-VM-fromOVFDir [-OVFDir] <Object> [-TargetVMName <Object>] [-TargetLocation <Object>] [-TargetDatastore 
    <Object>] [-TargetFolder <Object>] [-TargetNetwork <Object>] [-TargetDiskStorageFormat <Object>] 
    [-WithSameHardwareIDs] [-ovftool <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Der Import funktioniert über ovftool. Aktuell muss für vSphere 6.5 OVFTool 4.3.0 installiert sein
    
    Vorher in Ziel vCenter einloggen (Connect-VIServer)
    Dann Import Befehl verwenden
    

PARAMETER
    -OVFDir <Object>
        Verzeichnis mit Virtueller Maschine im OVF Format. Kann einzeln, via Pipe oder als Array übergeben werden
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -TargetVMName <Object>
        Name der Ziel VM. Wird kein Name übergeben wird Name des OVF verwendet
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetLocation <Object>
        Eine Target Location kann sein
        - Ein ESX-Host
        - Ein Ressourcenpool
        - Ein ESX-Cluster
        Die Location muss als entsprechendes Objekt übergeben werden
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetDatastore <Object>
        Ziel Datastore als VI Objekt
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetFolder <Object>
        Ziel Folder als VI Objekt
        oder
        Ziel Folder Pfad mit "/" getrennt ab unterhalb des Datacenters
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetNetwork <Object>
        Ziel Netzwerk als VI Objekt. Mit diesem Netzwerk werden alle Netzwerkkarten der VM verbunden
        Wenn du unterschiedliche Netzwerke benötigst musst du diese noch manuell nach einspielen der VM verbinden
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetDiskStorageFormat <Object>
        VM Festplatten Format als 'Thick','Thin','EagerZeroedThick'
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 Thick
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -WithSameHardwareIDs [<SwitchParameter>]
        Damit das fuktioniert muss die VM auch vorher mit WithSameHardwareIDs exportiert worden sein
        hat aktuell keine spezielle Funktion. Vielleicht wirds noch gebraucht
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ovftool <Object>
        Pfad zur Executable von OVFTool. Falls du eine andere Version verwenden willst
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:ovftool
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
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Import-VM
    -fromOVFDir
    https://www.vmware.com/support/developer/ovf/



```

