```

NAME
    VIM-Get-VM-LockingDisks
    
ÜBERSICHT
    Sucht die virtuellen Maschinen die Disks der angegebenen virtuellen Maschine
    blockieren (lock)
    
    
SYNTAX
    VIM-Get-VM-LockingDisks [-VM] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    Es werden alle Files der angegebenen Maschine durchsucht.
    Es werden alle VMs gesucht die Disks der angegebenen Maschine gemounted haben
    Die Maschinen die diese zusätzlichen Mounts haben werden zurückgegeben
    Als zusätzliches NoteProperty wird der DiskFileName der gemounteten Disk zurückgegeben
    

PARAMETER
    -VM <Object>
        VM von der eine Disk gelocked ist
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Get-VM-LockingDisks -VM $VM | FT -AutoSize Name,DiskFileName
    
    
    
    
    
    
    
VERWANDTE LINKS



```

