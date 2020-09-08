```

NAME
    Connect-LDAP
    
ÜBERSICHT
    Verbindet sich mit einem LDAP Verzeichnis
    
    
SYNTAX
    Connect-LDAP [[-BindCredential] <Object>] [[-LdapHost] <Object>] [[-LdapPort] <Object>] [[-LdapVersion] <Object>] [-LdapSSL] [<CommonParameters>]
    
    
BESCHREIBUNG
    Verbindet sich mit einem LDAP Verzeichnis.
    Verbidungsinformationen werden in der Hashtable $Global:LdapConnection gespeichert
    In diesem Kontext kann dann weiter gearbeitet werden
    

PARAMETER
    -BindCredential <Object>
        Credential mit dem man sich mit dem LDAP Verbindet (User, Passwort)
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 (Get-Credential -Message "Authenticate for LDAP Connection")
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -LdapHost <Object>
        LdapHost
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 edir-idm.uni-passau.de
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -LdapPort <Object>
        Port des LDAP Servers
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 636
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -LdapVersion <Object>
        Ldap Protokoll Version
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 3
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -LdapSSL [<SwitchParameter>]
        Bestimmt ob SSL / TLS verwendet werden soll. (Default: $true)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 True
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

