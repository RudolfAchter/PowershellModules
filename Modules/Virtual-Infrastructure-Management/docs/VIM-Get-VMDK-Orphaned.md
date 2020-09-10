```

NAME
    VIM-Get-VMDK-Orphaned
    
ÜBERSICHT
    Gibt Verwaiste VMDKs zurück. Also virtual Machine Disks die zu keiner virtuellen Maschine mehr zugeordnet sind
    
    
SYNTAX
    VIM-Get-VMDK-Orphaned [<CommonParameters>]
    
    
BESCHREIBUNG
    Der Tag DatastoreUsage / NoVM verhindert, dass eine Storage durchsucht wird
    

PARAMETER
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>$result=VIM-Get-VMDK-Orphaned
    
    $result
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    DK-Orphaned



```

