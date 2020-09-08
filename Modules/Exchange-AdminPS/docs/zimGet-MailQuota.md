```

NAME
    zimGet-MailQuota
    
ÜBERSICHT
    Zeigt verschiedene Quotas an.
    
    
SYNTAX
    zimGet-MailQuota [-QuotaUser] <String[]> [<CommonParameters>]
    
    
BESCHREIBUNG
    Mit diesem Cmdlet werden die Quotas für Warning, ProhibitSend sowie ProhibitSendReceive von den Mailboxen der übergebenen Benutzer angezeigt.
    

PARAMETER
    -QuotaUser <String[]>
        Spezifiziert den Benutzer bzw. die Benutzer.
        
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
    
    PS C:\>zimGet-MailQuota -QuotaUser Test_User
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>zimGet-MailQuota -QuotaUser Test_User1,Test_User2,Test_User3
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>zimGet-MailQuota -QuotaUser (Get-ChildItem Users.txt)
    
    Übergeben einer Textdatei in der die Benutzer aufgelistet sind. Pro Zeile nur ein Benutzer zulässig.
    
    
    
    
    
VERWANDTE LINKS



```

