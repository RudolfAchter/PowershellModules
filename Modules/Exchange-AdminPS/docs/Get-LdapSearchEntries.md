```

NAME
    Get-LdapSearchEntries
    
�BERSICHT
    Sucht nach Eintr�gen in einem LDAP und liefet die Search Entry Liste zur�ck
    
    
SYNTAX
    Get-LdapSearchEntries [[-cn] <Object>] [[-Connection] <Object>] [[-BaseDN] <Object>] [[-Filter] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -cn <Object>
        Common Name nach dem gesucht werden soll
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Connection <Object>
        LDAP Verbindung die f�r diese Query verwendet werden soll
        Default $Global:LdapConnection
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 $Global:LdapConnection.connection
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -BaseDN <Object>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 o=uni-passau
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Filter <Object>
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterst�tzt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    
VERWANDTE LINKS



```

