```

NAME
    Get-VMRC-Url
    
ÜBERSICHT
    Zeigt die VMRC Url einer oder mehrerer VMs  zur weiteren Verwendung
    
    
SYNTAX
    Get-VMRC-Url [-VM] <Object> [-CloneTicket] [-UrlAsWikiLink] [-AsObject] [<CommonParameters>]
    
    
BESCHREIBUNG
    Zeigt die VMRC Url einer VM  zur weiteren Verwendung
    

PARAMETER
    -VM <Object>
        Name der virtuellen Maschine
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -CloneTicket [<SwitchParameter>]
        Wenn gesetzt wird die Aktuelle Authentifizierung der Powershell kopiert
        wenn bereits über Powershell Authentifiziert, kann die VMRC ohen Authentifizierung gestartet werden
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -UrlAsWikiLink [<SwitchParameter>]
        URL für Verwendung in WikiSyntax
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -AsObject [<SwitchParameter>]
        Gibt das VM Objekt mit vmrcURL als NoteProperty aus
        
        Erforderlich?                false
        Position?                    named
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
    
HINWEISE
    
    
        Author: Rudolf Achter
        Date:   2016-05-11
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Get-VMRC-Url win7vm
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-VMRC-Url (Get-VM) -Anonymous -UrlAsWikiLink
    
    #Alle VMs als VMRC-Url
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-Folder -Name Fernwartung | Get-VM | Get-VMRC-Url -Anonymous -UrlAsWikiLink
    
    
    
    
    
    
    
VERWANDTE LINKS



```

