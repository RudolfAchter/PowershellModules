```

NAME
    VIM-Get-ResourceReservation
    
ÜBERSICHT
    Holt die ResourceConfiguration aller VMs die eine Reservierung haben
    du bekommst also die Ressourcen Konfiguration aller VMs zurück die 
    bereits eine Reservierung haben
    
    
SYNTAX
    VIM-Get-ResourceReservation [[-VM] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 (Get-VM)
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
    
    PS C:\>VIM-Get-ResourceReservation | Set-VMResourceConfiguration -CpuReservationMhz 0 -MemReservationMB 0
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#In diesem Beispiel werden die CPU Reservierungen der Live VMs halbiert
    
    Get-VM -Tag (Get-Tag -Category "Stage" -Name "Live") | VIM-Get-ResourceReservation | %{Set-VMResourceConfiguration 
    -Configuration $_ -CpuReservationMhz ([int]$_.CpuReservationMhz / 2)}
    
    
    
    
    
VERWANDTE LINKS



```

