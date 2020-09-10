```

NAME
    Get-OvfConfigTemplateScript
    
ÜBERSICHT
    Erstellt ein Template Script für das Deployment eines OVA / OVF
    
    
SYNTAX
    Get-OvfConfigTemplateScript [[-ovfconfig] <Object>] [-withHeader] [-withFooter] [-withDescription] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    Dieses Cmdlet liest die Konfigurationsparameter aus einer OVA / OVF.
    Alle möglichen zu befüllenden Parameter werden übersichtlich in Powershell
    Syntax als ein Script ausgegeben. Standardmäßig wird das Script an StdOut
    ausgegeben. Die Ausgabe kann also entweder vom Bildschirm kopiert, oder
    direkt in eine Script Datei umgeleitet werden
    

PARAMETER
    -ovfconfig <Object>
        Ein OvfConfig Objekt das mittels Get-OvfConfiguration erstellt wurde
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -withHeader [<SwitchParameter>]
        Der Header des Scripts, der das Laden der Ovf zeigt (standardmäßig AN)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 True
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -withFooter [<SwitchParameter>]
        Der Footer des Scripts der das Deployment mit der erstellten Konfig zeigt (standardmäßig AN)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 True
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -withDescription [<SwitchParameter>]
        Die Beschreibung eines jeden Konfigurationsparameters wird als Kommentar in das Script eingefügt.
        Das Template Script wird dadurch sehr umfangreich bzw unübersichtlich (standardmäßig AUS)
        
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
    
    PS C:\>Get-OvfConfigTemplateScript -ovfconfig (Get-OvfConfiguration -Ovf ".\AAM\AAM-07.0.0.0.441-e55-0.ova")
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-OvfConfigTemplateScript -ovfconfig (Get-OvfConfiguration -Ovf 
    "SMGR\SMGR-7.1.0.0.1125193-e65-50\SMGR-7.1.0.0.1125193-e65-50.ovf")
    
    #Das SMGR .ova hatte Fehler. Daher hatte ich es entpackt, korrigiert. aber nicht mehr eingepackt, sondern direkt 
    das .ovf verwendet
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>#Das ganze geht natürlich auf auf mehrere Schritte
    
    $ovfconfig=Get-OvfConfiguration -Ovf ($ovapath + 
    "\SMGR\SMGR-7.1.0.0.1125193-e65-50\SMGR-7.1.0.0.1125193-e65-50.ovf")
    Get-OvfConfigTemplateScript -ovfconfig $ovfconfig | Out-File smgrDeployTest.ps1
    
    
    
    
    
VERWANDTE LINKS



```

