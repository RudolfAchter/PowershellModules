```

NAME
    New-TeamSharedMailbox
    
ÜBERSICHT
    Erstellt SharedMailbox.
    
    
SYNTAX
    New-TeamSharedMailbox -RequestID <String> [-RequestFrom <Object>] -Team <String> [-Name <String>] -Owners 
    <String[]> [-Members <String[]>] [-SendAsUsers <String[]>] [-EmailAddresses <String[]>] [-NoQuota] [-UsedUntil 
    <Object>] [-InformUsers] [-NoPostfixEntry] [<CommonParameters>]
    
    
BESCHREIBUNG
    Erstellt SharedMailboxes anhand der angegebenen Parameter.
    

PARAMETER
    -RequestID <String>
        Ticket in dem die Mailbox angefordert wird
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -RequestFrom <Object>
        System in dem die Anforderung gestellt worden ist (sollte das mal was anderes als "kix" sein)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 kix
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Team <String>
        Team (z.B. S001) für das die Mailbox erstellt wird
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Name <String>
        Spezifiziert den Namen, Displaynamen sowie das Alias der SharedMailbox.
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Owners <String[]>
        Besitzer der Mailbox
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Members <String[]>
        Mitglieder. Diese können als "Publishing Editor" zugreifen
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SendAsUsers <String[]>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -EmailAddresses <String[]>
        EmailAdressen die auf diese Mailbox verweisen. Für jede Email Adresse wird eine Distribution Group mit dem 
        Namen der Email Adresse erstellt
        um die Email Adresse auch als Versand Adresse verwenden zu können
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -NoQuota [<SwitchParameter>]
        Würde die Quota Richtlinie auslassen Standard (Warning: 9,5GB; Send: 9,9GB; SendReceive: 10GB)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -UsedUntil <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -InformUsers [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -NoPostfixEntry [<SwitchParameter>]
        
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
    
    PS C:\>New-TeamSharedMailbox -RequestID "10163644" -RequestFrom kix -Team J009 -Name J009_support.fet.jura -Owners 
    "nauman11","kramer16" -Members "gashi03","nauman11" -SendAsUsers "gashi03","nauman11" -EmailAddresses 
    support.fet.jura@uni-passau.de -InformUsers
    
    Erstellt eine neue SharedMailbox bei der die Owners FullAccess haben die Members PublishinEditor sind, und die 
    SendASUsers SendAS Berechtigungen haben
    InformUsers sagt aus, dass die User über ihre neue Mailbox benachrichtigt werden sollen. Das erstellt eine neue 
    Mail in Outlook die in einem neuen Fenster geöffnet wird und editiert werden kann bevor diese versendet wird
    
    
    
    
    
VERWANDTE LINKS



```

