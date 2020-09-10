```

NAME
    Create-MyOutlookSignature
    
ÜBERSICHT
    Erstellt Outlook Signaturen anhand eigener ActiveDirectory Informationen.
    
    
SYNTAX
    Create-MyOutlookSignature [-SetAsDefault] [-SetAsDefaultAnswer] [[-SignatureTemplatesPath] <Object>] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    Es wird eine Signatur mit Foto und eine Signatur ohne Foto erstellt
    Als Default Signatur wird zunächst diese ohne Foto verwendet.
    Die Signaturen werden nicht erzwungen, der User kann also auch andere
    Signaturen verwenden.
    Das Foto wird aus dem Active Diretory Feld "thumbnailPhoto" verwendet
    Sollte für die E-Mail Signatur ein anderes Foto (evtl anders Formatiert) gewünscht werden,
    könnten wir uch das Attribut "photo" verwenden
    

PARAMETER
    -SetAsDefault [<SwitchParameter>]
        Wenn gesetzt wird die Signatur ohne Foto als Default Signatur für neue Emails eingestellt
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SetAsDefaultAnswer [<SwitchParameter>]
        Wenn auf true gesetzt, wird die Signatur ohne Foto als Default Signatur für Antworten eingestellt.
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SignatureTemplatesPath <Object>
        In diesem Verzeichnis liegen die Vorlagen für die Signaturen
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $global:SignatureTemplatesPath
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
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Outlook-Automation.psm1/Create-MyOutlookSignature



```

