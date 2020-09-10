```

NAME
    VIM-Show-VMValue
    
ÜBERSICHT
    Zeigt für Virtual Infrastructure Management Relevante Werte an
    
    
SYNTAX
    VIM-Show-VMValue [-VM] <Object> [-Grid] [-columns <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Nützlich um sich einen Überblick über die aktuellen VMs zu verschaffen
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Grid [<SwitchParameter>]
        Das können mehrere Parameter werden je nachdem wie ichs z.B. exportieren will
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -columns <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
HINWEISE
    
    
        Dieses CMDlet Script zeigt den Idealen Einsatz für eine Progress Bar (Statusanzeige, Fortschrittsbalken)
        Anhand dieses Beispiel kann ich vielleicht die anderen CMDlets umschreiben
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Show-VMValue (Get-VM)
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Show-VMValue (Get-VM) -Grid
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-Folder "Live" | Get-Folder "TK-Anlage" | Get-VM | VIM-Show-VMValue -Grid
    
    
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>VIM-Get-VMEndOfLife | VIM-Show-VMValue -Grid
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Show-V
    MValue



```

