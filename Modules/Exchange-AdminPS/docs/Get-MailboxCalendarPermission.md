```

NAME
    Get-MailboxCalendarPermission
    
ÜBERSICHT
    
    
SYNTAX
    Get-MailboxCalendarPermission [-Mailbox] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Mailbox <Object>
        
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
    
    PS C:\>Get-Mailbox V012_Team | Get-MailboxCalendarPermission
    
    Add-MailboxFolderPermission -Identity V012_Team@ads.uni-passau.de:\Kalender -User achter@ads.uni-passau.de 
    -AccessRights Editor
    
    
    
    
    
VERWANDTE LINKS



```

