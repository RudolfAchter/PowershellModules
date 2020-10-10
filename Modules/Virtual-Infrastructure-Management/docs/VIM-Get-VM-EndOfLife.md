```

NAME
    VIM-Get-VMEndOfLife
    
ÜBERSICHT
    Gibt VMs zurück die "EndOfLife" sind
    
    
SYNTAX
    VIM-Get-VMEndOfLife [[-DaysToUsedUntil] <Object>] [[-Contact] <Object>] [[-ShowArchived]] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -DaysToUsedUntil <Object>
        So viele Tage vor "UsedUntil" wird die Maschine gemeldet
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $global:vim_VM_DaysToUsedUntil
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Contact <Object>
        VMs von einem bestimmten Responsible anzeigen
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ShowArchived [<SwitchParameter>]
        Standardmäßig werden keine archivierten VMs mehr angezeigt
        mit -ShowArchived:$true kannst du dir diese VMs wieder anzeigen lassen
        
        Erforderlich?                false
        Position?                    3
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
    
    PS C:\>VIM-Get-VMEndOfLife | VIM-Show-VMValue
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Get-VMEndOfLife -Contact "*Fiedler*" | Shutdown-VMGuest
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>VIM-Get-VMEndOfLife -Contact "Fiedler*" | Stop-VM
    
    
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>VIM-Get-VMEndOfLife -Contact "Fiedler*" | Delete-VM
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    -EndOfLife



```

