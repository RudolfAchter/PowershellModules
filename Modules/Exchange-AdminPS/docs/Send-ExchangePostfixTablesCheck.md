```

NAME
    Send-ExchangePostfixTablesCheck
    
ÜBERSICHT
    Versendet die Ergebnisse von Check-ExchangePostfixTables per Mail
    
    
SYNTAX
    Send-ExchangePostfixTablesCheck [[-To] <Object>] [[-From] <Object>] [[-SmtpServer] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -To <Object>
        Mail Empfänger
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -From <Object>
        (Optional) Absender. Standardmäßig der User der dieses Cmdlet ausführt
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 $Global:Exchange.Notification.From
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SmtpServer <Object>
        (Optional) Über welchen SmtpServer wird versendet
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 $Global:Exchange.Notification.SmtpServer
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



```

