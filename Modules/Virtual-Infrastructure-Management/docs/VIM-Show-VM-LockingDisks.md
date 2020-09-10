```

NAME
    VIM-Show-VM-LockingDisks
    
ÜBERSICHT
    Zeigt virtuelle Maschinen die Disks der angegebenen virtuellen Maschine
    blockieren (lock)
    
    
SYNTAX
    VIM-Show-VM-LockingDisks [-VM] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    

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
    
    PS C:\>Get-VM deslntksm | VIM-Show-VM-LockingDisks
    
    #Ergebnis könnte so aussehen
    Name          DiskFileName                                
    ----          ------------                                
    deslnsrvvdp02 [VSA_TESTLAP_LUN01] deslntksm/deslntksm.vmdk
    
    
    
    
    
VERWANDTE LINKS



```

