```

NAME
    Get-IP-NetworkMembership
    
ÜBERSICHT
    Checks Membership of IP-Address in a particular Network
    Returns true When IP is Member
    Returns false wehon IP is not Member
    
    
SYNTAX
    Get-IP-NetworkMembership [[-IP] <String>] [[-network] <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -IP <String>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -network <String>
        
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
    
    PS C:\>Get-IP-NetworkMembership -IP 192.168.10.5 -network 192.168.10.0/24
    
    #True
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-IP-NetworkMembership -IP 172.16.10.200 -network 172.16.10.0/25
    
    #False
    
    
    
    
    
VERWANDTE LINKS



```

