```

NAME
    VIM-Mail-VMEndOfLife
    
ÜBERSICHT
    Benachrichtigt über ablaufende VMs
    
    
SYNTAX
    VIM-Mail-VMEndOfLife [[-Contact] <String>] [[-DaysToUsedUntil] <Int32>] [-MailTo <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Durchsucht alle Ansprechpartner und benachrichtigt alle über ablaufende VMs.
    Über VMs die bereits archiviert wurden, wird nicht mehr benachrichtigt.
    

PARAMETER
    -Contact <String>
        Ansprechpartner Tag oder Ansprechpartner als String.
        
        Es können auch Wildcards verwendet werden. z.B.:
        VIM-Mail-VMEndOfLife -Contact "Achter*"
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DaysToUsedUntil <Int32>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 $global:vim_VM_DaysToUsedUntil
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -MailTo <Object>
        Ein Empfänger als String oder mehrere Empfänger als String Array.
        Standardmäßig wird diese Mail an die Ansprechpartner gesendet.
        Dieser Parameter dient als Umleitung (für Tests)
        
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
    
    PS C:\>VIM-Mail-VMEndOfLife -Contact "Achter*" -DaysToUsedUntil 60
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>VIM-Mail-VMEndOfLife -DaysToUsedUntil 100
    
    
    
    
    
    
    
VERWANDTE LINKS



```

