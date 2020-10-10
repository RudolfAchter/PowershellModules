```

NAME
    VIM-Mail-VM-without-Contact
    
ÜBERSICHT
    Sendet eine E-Mail mit einer Auflistung der VMs bei denen kein Responsible gelistet ist
    
    
SYNTAX
    VIM-Mail-VM-without-Contact [[-MailTo] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Das Script holt sich die VMs von der Funktion "VIM-Get-VM-withoud-Contact" und formuliert eine
    übersichtliche E-Mail mit allen notwendigen Informationen für den Administrator
    

PARAMETER
    -MailTo <Object>
        Ein Empfänger als String oder mehrere Empfänger als String Array.
        Standardmäßig wird diese Mail an die Administratoren gesenet.
        Dieser Parameter dient als Umleitung (für Tests)
        
        Erforderlich?                false
        Position?                    1
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
    
    PS C:\>VIM-Mail-VM-without-Contact
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Mail-VM-without-C
    ontact



```

