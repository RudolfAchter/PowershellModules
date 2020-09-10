```

NAME
    Copy-VM-viaOVFDir
    
ÜBERSICHT
    Exportiert VMs von einem vCenter als OVF
    und importiert diese ins nächste vCenter von OVF
    
    
SYNTAX
    Copy-VM-viaOVFDir [-VM] <Object> [-SourceVCenter <Object>] [-SourceCred <Object>] [-TargetVCenter <Object>] 
    [-TargetCred <Object>] [-WithSameHardwareIDs] [-ExportDestination <Object>] [-TempCloneToDatastore <Object>] 
    [-TargetVMName <Object>] [-TargetLocation <Object>] [-TargetDatastore <Object>] [-TargetFolder <Object>] 
    [-TargetNetwork <Object>] [-TargetDiskStorageFormat <Object>] [-RemoveExportedOVF] [-ovftool <Object>] [-openssl 
    <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Dieses Cmdlet verwendet Export-VM-toOVFDir und Import-VM-fromOVFDir
    in Kombination um VMs von einem vCenter zu exportieren und sofort
    ins nächste vCenter zu importieren.
    Es werden sehr viele Parameter benötigt um dieses CMDlet automatisiert
    laufen zu lassen.
    
    Am besten vorher die ganzen benötigen Parameter in Variablen speichern
    und somit gleichzeitig auch überprüfen ob die angesprochenen Objekte auch
    korrekt sind. Das CMDlet geht meistens davon aus, dass die als Parameter
    übergebenen Objekte auch wirklich im Source bzw Target vCenter existent sind
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine die kopiert wird
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -SourceVCenter <Object>
        vCenter aus dem kopiert wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SourceCred <Object>
        Powershell Credential zur Anmeldung am SourceVcenter
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetVCenter <Object>
        vCenter in das kopiert wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetCred <Object>
        Powershell Credential zur Anmeldung am TargetVCenter
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -WithSameHardwareIDs [<SwitchParameter>]
        Die Hardware IDs (Mac-Addressen, BIOS UUID) der Quell-VM
        werden in das Ziel übernommen
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ExportDestination <Object>
        Lokaler Pfad an dem die OVF Verzeichnissse zwischengespeichert werden
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 .
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TempCloneToDatastore <Object>
        Wenn die VM im Quell vCenter Online (PoweredOn) ist kann sie normalerweise
        nicht exportiert werden. Mit einem temporären Klon in einen anderen
        Datastore geht das allerdings schon.
        Achtung die VM hat dann einen Status als wäre die Festplatte im laufenden
        Betrieb gezogen werden (also wie Snapshot ohne Arbeitsspeicher)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetVMName <Object>
        So soll die VM am Ziel heissen
        ACHTUNG noch nicht implementiert um dies mit mehreren VMs gleichzeitig
        zu machen
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetLocation <Object>
        Ziel ESX-Host, Cluster, Resource-Pool
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetDatastore <Object>
        Ziel Datastore auf dem die VM dann importiert wird
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetFolder <Object>
        In diesem Folder wird die VM am Ziel angezeigt
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetNetwork <Object>
        Netzwerkkarten der VM werden am Ziel an dieses Netzwerk angeschlossen
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetDiskStorageFormat <Object>
        In diesem VM Festplatten Format wird die VM am Ziel gespeichert
        Standardmäßig Thick
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 Thick
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -RemoveExportedOVF [<SwitchParameter>]
        Die Exportierten Files werden nach Import am Ziel wieder gelöscht
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ovftool <Object>
        Pfad zur ovftool.exe (wenn etwas anderes als Default benötigt wird)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:ovftool
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -openssl <Object>
        Wird aktuell nicht verwendet. Aber hat evtl Relevanz zur Erstellung von
        Manifest Files
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $PSScriptRoot + "\bin\openssl.exe"
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
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Copy-VM-v
    iaOVFDir
    https://www.vmware.com/support/developer/ovf/



```

