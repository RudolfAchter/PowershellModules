```

NAME
    Get-NetworkSummary
    
ÜBERSICHT
    Provides all Necessary Network Information in an Object
    Network is provided either by IP-Address/cidr or IP-Address and Mask
    
    
SYNTAX
    Get-NetworkSummary [[-IP] <String>] [[-Mask] <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -IP <String>
        IP-Address oder IP/cidr
        for Example
        -IP 192.168.10.20 -Mask 255.255.255.128
        -IP "192.168.10.20/25"
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Mask <String>
        
        Erforderlich?                false
        Position?                    2
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
    
    PS C:\>Get-NetworkSummary 192.168.70.20/28
    
    
    
    
    
    
    
VERWANDTE LINKS



```

