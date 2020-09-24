```

NAME
    Add-TeamMailboxPermissions
    
ÜBERSICHT
    
    
SYNTAX
    Add-TeamMailboxPermissions [[-Team] <Object>] [[-FullAccess] <Object>] [[-SendAs] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Team <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -FullAccess <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SendAs <Object>
        
        Erforderlich?                false
        Position?                    3
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
    
    PS C:\>$new_users=@("tornin01","degenh08","xu18","pollne04","gedig01","amthor02","schell25","pickha01","bauer224","
    kaufma23")
    
    Add-TeamMailboxPermissions -Team "P093" -FullAccess $new_users
    
    
    
    
    
VERWANDTE LINKS



```

