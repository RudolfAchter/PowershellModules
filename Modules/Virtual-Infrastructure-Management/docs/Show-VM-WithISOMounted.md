```

NAME
    Show-VM-WithISOMounted
    
ÜBERSICHT
    Zeigt VMs mit gemounteter ISO an
    
    
SYNTAX
    Show-VM-WithISOMounted [[-VM] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Sucht in allen VMs die im Parameter VM übergeben wurden nach Kandidaten die ein
    ISO gemounted (eine CDROM / DVD in ihrem virtuellen Laufwerk eingelegt haben)
    
    Die zurückgegebenen Objekte sind KEINE VM Objekte sondern dienen lediglich der Anzeige
    welche ISO gemountet ist. Nicht in einer Pipe weiterverwenden
    Wenn du Aktionen mit den gefundenen VMs durchführen willst, dann verwende:
    
    Get-VM-WithISOMounted
    

PARAMETER
    -VM <Object>
        Liste von virtuellen Maschinen die durchsucht werden sollen
        
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
    
    PS C:\>Show-VM-WithISOMounted
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-Folder "Test" | Get-VM | Show-VM-WithISOMounted
    
    
    
    
    
    
    
VERWANDTE LINKS



```

