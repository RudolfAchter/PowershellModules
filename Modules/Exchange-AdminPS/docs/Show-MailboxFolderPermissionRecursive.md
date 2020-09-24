```

NAME
    Show-MailboxFolderPermissionRecursive
    
ÜBERSICHT
    Zeigt MailboxFolderPermissions mit sinnvollen Spalten an
    
    
SYNTAX
    Show-MailboxFolderPermissionRecursive [-mailboxName] <Object> [-GridView] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -mailboxName <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -GridView [<SwitchParameter>]
        
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
    
    PS C:\>Show-MailboxFolderPermissionRecursive -mailboxName J009_Team | Where-Object User -like "Hofmann*" | ft 
    -AutoSize
    
    
    
    
    
    
    
VERWANDTE LINKS



```

