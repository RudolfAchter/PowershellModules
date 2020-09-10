```

NAME
    Export-VM-fromESX
    
ÜBERSICHT
    Exportiert VMs in ein Verzeichnis im OVA Format.
    
    Soll in Zukunft mit Standalone ESX-Server und auch mit vCenter Funktionieren
    
    
SYNTAX
    Export-VM-fromESX [-VM] <Object> [-User <Object>] [-Password <Object>] [-WithSameHardwareIDs] [-ExportDestination 
    <Object>] [-TempCloneToDatastore <Object>] [-ovftool <Object>] [-openssl <Object>] [-vCenter] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        Zu exportierende VMs
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -User <Object>
        User mit dem sich zu ESX-Server verbunden wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Password <Object>
        Passwort mit dem sich zu ESX-Server verbunden wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -WithSameHardwareIDs [<SwitchParameter>]
        Wenn dieser Switch gesetzt ist, werden Hardware Informationen
        wie Bios Seriennummer (UUID) und MAC-Addressen mit exportiert
        ACHTUNG: Diese Option verringert die Portabilität der VM
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ExportDestination <Object>
        Hier werden die OVF Folder gespeichert
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 .
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TempCloneToDatastore <Object>
        Wenn die VM "PoweredOn" ist kann sie normalerweise nicht exportiert werden.
        Soll Sie dennoch exportiert werden kann sie hiermit Temporär auf einen
        Datastore geklont werden bevor sie exportiert wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ovftool <Object>
        Pfad zur ovftool.exe falls du eine andere Version verwenden willst
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:ovftool
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -openssl <Object>
        Openssl wird benötigt um eine Manifest Datei zu erstellen. Noch nicht vollständig implementiert
        Es geht auch ohne Manifest
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $PSScriptRoot + "\bin\openssl.exe"
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -vCenter [<SwitchParameter>]
        ist die Source ein vCenter oder nicht. Sollte in Zukunft automatisch ermittelt werden
        
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
    
    
VERWANDTE LINKS
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Export-VM
    -toOVFDir
    https://www.vmware.com/support/developer/ovf/



```

