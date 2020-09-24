```

NAME
    Get-MailboxFolderPermissionRecursive
    
ÜBERSICHT
    Sucht MailboxFolder Berechtigungen in einer Mailbox
    
    
SYNTAX
    Get-MailboxFolderPermissionRecursive [-mailboxName] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -mailboxName <Object>
        
        Erforderlich?                true
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
    
    PS C:\>Get-MailboxFolderPermissionRecursive -mailboxName J009_Team | Where-Object User -like "Achter*" | 
    %{Remove-MailboxFolderPermission -Identity $_.Identity -User $_.User.ADRecipient.Name -Confirm:$false}
    
    #Das Beispiel entfernt Alle Berechtigungen für User Namens Achter* (achtung Wildcard) in Mailbox J009_Team
    
    
    
    
    
VERWANDTE LINKS



```

