```

NAME
    VIM-Check-Tags
    
ÜBERSICHT
    Prüft Ob mindest benötigte Tags einer VM gesetzt sind bzw versucht zu korrigieren
    
    
SYNTAX
    VIM-Check-Tags [-VM] <Object> [-StageByFolder] [<CommonParameters>]
    
    
BESCHREIBUNG
    Es wird auf für Virtal-Infrastructure Management aktuell mindest benötigte Tags geprüft.
    Das VM Objekt wird um das Property "missingTags" ergänzt. Das ist ein Array mit aktuell
    fehlenden Tags
    
    ALLE Added Properties siehe im Script: $global:vim_tags
    
                         Name              Typ
                         ------------      -----------
    Added-Property:      missingTags       Array
    Added-Property:      Ansprechpartner   String
    Added-Property:      Applikation       String
    Added-Property:      Stage             String
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -StageByFolder [<SwitchParameter>]
        Sollte keine "Stage" gesetzt sein, wird die "Stage" anhand des Ersten Folders
        gesetzt das unterhalb des Datacenters kommt (Root Folder)
        Also:
        vcenter
        |
        |-- megatech.local
            |
            |-- Development 
            |-- Live          <-- Die ganz oben im Baum sind entscheidend
            |-- Test
               |
               |-- Bla1
               |-- Bla2
        
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
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Check-
    Tags



```

