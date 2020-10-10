```

NAME
    VIM-Get-VM-without-Contact
    
ÜBERSICHT
    Sucht virtuelle Maschinen bei denen kein Responsible Tag gesetzt ist und gibt diese zurück
    
    
SYNTAX
    VIM-Get-VM-without-Contact [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Script ruft mit Get-VM alle virtuelle Maschinen im verbunden vCenter ab. Bei den virtuellen Maschinen
    werden die TagAssignments der Kategorie "Responsible" abgerufen. Wenn weniger als ein Responsible
    gesetzt ist, so wird die virtuelle Maschinen ausgegeben
    

PARAMETER
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Get-VM-wihtout-Contact
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Get-VM-wihtout-Contact | Out-Grid
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>VIM-Get-VM-wihtout-Contact | Out-Grid
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-without-Co
    ntact



```

