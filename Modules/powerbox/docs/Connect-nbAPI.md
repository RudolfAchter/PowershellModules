```

NAME
    Connect-nbAPI
    
ÜBERSICHT
    Connects to the Netbox api for the other nb module commands
    
    
SYNTAX
    Connect-nbAPI [-Token] <SecureString> [-APIurl] <Uri> [[-QueryLimit] <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    This command saves the relevant information to be able to use the other Netbox commands from this module without 
    having to re-auth
    

PARAMETER
    -Token <SecureString>
        Token for this API
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -APIurl <Uri>
        APIurl for this API
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -QueryLimit <Int32>
        Size of pages returned by "Get-nb*" commands.
        I find the default 50 very slow as the overhead is absurd.
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 250
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
HINWEISE
    
    
        This command mainly takes the variable state information (APIURL and Token) and stores them in module level 
        variables so that further calls to functions will use them.
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>$Pass = Read-Host -AsSecureString
    
    Connect-nbAPI -APIurl Contoso -Token $pass
    
    This asks you for your token and then connects to the netbox API
    
    
    
    
    
VERWANDTE LINKS



```

