```

NAME
    New-OutlookMail
    
ÜBERSICHT
    Verschickt eine E-Mail mit Outlook
    
    
SYNTAX
    New-OutlookMail [-HTMLBody] <String> [[-Subject] <String>] [[-Recipients] <Object>] [-Send] [-WithSignature] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    Zum verschicken der Mail wird deine lokal Instalierte Outlook Instanz verwendet.
    Wenn du eine Default Signatur für eine E-Mail eingestellt hast, wird diese Signatur verwendet
    

PARAMETER
    -HTMLBody <String>
        Inhalt der Mail als HTML Formatiert. ACHTUNG. Damit das korrekt funktioniert muss HTMLBody ein
        vollständig Formatiertes HTML Dokument sein
        Also
        <html>
            <head></head>
            <body>
                Inhalt
            </body>
        </html>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -Subject <String>
        Der Betreff der Mail
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Recipients <Object>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Send [<SwitchParameter>]
        Switch zu versenden der Mail. Wenn "Send" nicht angegeben ist öffnet sich lediglich Outlook mit der
        E-Mail. Die E-Mail kann dann nochmal betrachtet und dann manuell versendet werden.
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -WithSignature [<SwitchParameter>]
        
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
    
    PS C:\>#Über Wartungsarbeiten an einem ESX-Host informieren (z.B.)
    
    Get-VM | ? PowerState -eq "PoweredOn" | VIM-Get-VMValue | Select Name,Ansprechpartner,Applikation,Notes| 
    ConvertTo-StyledHTML | New-OutlookMail -Subject "Test VMs werden pausiert"
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Outlook-Automation.psm1/New-OutlookMail



```

