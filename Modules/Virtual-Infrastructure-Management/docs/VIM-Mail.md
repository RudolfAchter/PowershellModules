```

NAME
    VIM-Mail
    
ÜBERSICHT
    Allgemeine Mail funktion um Mails vom Virtual Infrastructure Management aus zu verschicken
    
    
SYNTAX
    VIM-Mail [[-Objects] <Object>] [-From <Object>] [-To <Object>] [-Subject <Object>] [-Description <Object>] [-Html 
    <Object>] [-SMTPServer <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Objects <Object>
        Wenn Objekte übergeben werden, Wird das an die Mail gehängt
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -From <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:mail_sender
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -To <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Subject <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 VIM-Mail
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Description <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 Description
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Html <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SMTPServer <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:mail_smtp_server
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
    
    PS C:\>$html='Mein Testcontent'
    
    VIM-Mail -From rudolf.achter@megatech-communication.de `
            -To $MailAddress `
            -Subject "Mail Subject (Betreff)" `
            -Description 'Beschreibung des Inhalts der Mail' `
            -Html $html
    
    
    
    
    
VERWANDTE LINKS



```

