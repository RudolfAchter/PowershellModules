```

NAME
    VIM-Get-ContactAssignment
    
ÜBERSICHT
    Zeigt Responsible einer VM an
    
    
SYNTAX
    VIM-Get-ContactAssignment [-VM] <Object> [-Category <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Zeigt Responsible einer VM an
    
    geplante Kategorien:
    
    Wichtige Tags:
        Tags werden auf ESX-HOST Objekte zugewiesen
        Category: Responsible         Tag:*                       Responsible. Beschreibung des Responsibles ist die 
    E-Mail-Addresse
        Category: Creator                 Tag:*                       Ersteller der VM. Beschreibung des Responsibles 
    ist die E-Mail-Addresse
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine als Objekt oder String
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -Category <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 Responsible
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
    
    PS C:\>VIM-Get-ContactAssignment "deslnclivisio2k16"
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Get-ContactAssignment (Get-VM deslnclivisio2k16)
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-VM "deslnclivisio2k16" | VIM-Get-ContactAssignment
    
    
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>VIM-Get-ContactAssignment -VM deslnclivisio2k16 -Category Creator
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-ContactAssign
    ment



```

