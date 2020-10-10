```

NAME
    VIM-Get-VMValue
    
ÜBERSICHT
    Holt alle für VMWare Infrastruktur Relevanten Werte
    
    
SYNTAX
    VIM-Get-VMValue [-VM] <Object> [-StageByFolder] [<CommonParameters>]
    
    
BESCHREIBUNG
    ALLE Added Properties siehe im Modul-Script: 
    - $global:vim_tags
    - $global:vim_custom_attributes
    
    Added Properties:
    
                         Name                   Typ
                         ------------           -----------
                         missingTags            Array
                         Responsible        String
                         Application            String
                         Stage                  String
                         VIM.DateCreated        String
                         VIM.DateUsedUntil      String
                         VIM.CreationMethod     String
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -StageByFolder [<SwitchParameter>]
        
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
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Get-VM | VIM-Get-VMValue | Select Name,Responsible,Application,Stage,VIM.DateCreated,VIM.DateUsedUntil | 
    Out-GridView
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    Value



```

