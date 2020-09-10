```

NAME
    VIM-Get-VM-OldArchived
    
ÜBERSICHT
    Liefert VMs zurück die älter sind als Angegeben (x Days)
    
    
SYNTAX
    VIM-Get-VM-OldArchived [[-Days] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Wenn eine VM von VIM-Archive-VM archiviert wird, wird unter anderem das Property VIM.ArchiveDateArchived erfasst.
    mit "VIM.ArchiveDateArchived" kann dann der Zeitraum ermittelt werden wie lange die VM schon archiviert ist.
    Standardmäßig gibt diese Funktion VMs zurück die alter als 365 Tag (1 Jahr) sind
    

PARAMETER
    -Days <Int32>
        VMs zurück geben die älter als n Days sind
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 365
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
    
    PS C:\>VIM-Get-VM-OldArchived | Remove-VM -DeletePermanently
    
    #Löscht alte VMs
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    -OldArchived



```

