```

NAME
    Invoke-nbApi
    
ÜBERSICHT
    Invokes the Netbox API
    
    
SYNTAX
    Invoke-nbApi [-Resource] <String> [-HttpVerb {Default | Get | Head | Post | Put | Delete | Trace | Options | Merge 
    | Patch}] [-Query <Hashtable>] [-Body <Object>] [-APIUrl <Uri>] [<CommonParameters>]
    
    Invoke-nbApi [-Body <Object>] [-rawUrl <Uri>] [<CommonParameters>]
    
    
BESCHREIBUNG
    This wraps the netbox API to make it a little simpler to work with in powershell.
    

PARAMETER
    -Resource <String>
        The resource path to connect to
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -HttpVerb
        The HTTP verb to use for this request
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 Get
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Query <Hashtable>
        Dictionary to be constructed into a QueryString
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Body <Object>
        Body of the request
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -APIUrl <Uri>
        URL to run it against (for unauthenticated get requests)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -rawUrl <Uri>
        
        Erforderlich?                false
        Position?                    named
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
    
    PS C:\>#Get devices from site 1
    
    Invoke-nbApi -Resource dcim/racks -Query @{site_id=1} -APIurl https://nb.contoso.com/ -token asd1239asd13lsdfs
    
    
    
    
    
VERWANDTE LINKS



```

