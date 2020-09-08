```

NAME
    zimSet-MailQuota
    
ÜBERSICHT
    Setzt verschiedene Quotas auf die Mailbox des Users.
    
    
SYNTAX
    zimSet-MailQuota [-QuotaUser] <String[]> [<CommonParameters>]
    
    
BESCHREIBUNG
    Mit diesem Cmdlet werden die Quotas für Warning, ProhibitSend sowie ProhibitSendReceive auf die Mailboxen der übergebenen Benutzer eingestellt.
    

PARAMETER
    -QuotaUser <String[]>
        Spezifiziert den Benutzer bzw. die Benutzer. Mehrere Benutzer sind durch Kommata getrennt anzugeben.
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>zimSet-MailQuota -QuotaUser Test_User
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>zimSet-MailQuota -QuotaUser Test_User1,Test_User2,Test_User3
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>zimSet-MailQuota -QuotaUser (Get-ChildItem Users.txt)
    
    Übergeben einer Textdatei in der die Benutzer aufgelistet sind. Pro Zeile nur ein Benutzer zulässig.
    
    
    
    
    
VERWANDTE LINKS



```

