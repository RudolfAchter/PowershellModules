```

NAME
    VIM-Set-CreationByEvent
    
ÜBERSICHT
    Durchsucht Events nach VM Creation Events und setzt entsprechend die Attributes
    
    
SYNTAX
    VIM-Set-CreationByEvent [-VM] <Object> [-CreationDateAlternative <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine für die das CreationDate ermittelt wird
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -CreationDateAlternative <String>
        Wenn kein Event für ein CreationDate gefunden wird, dann dieses Datum als Alternative verwenden
        
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
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>$result=Get-VM | VIM-Set-CreationByEvent
    
    $result | VIM-Show-VMValue
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Set-Cr
    eationByEvent



```

