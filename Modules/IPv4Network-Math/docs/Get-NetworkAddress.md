```

NAME
    Get-NetworkAddress
    
ÜBERSICHT
    Takes an IP address and subnet mask then calculates the network address for the range.
    
    
SYNTAX
    Get-NetworkAddress [-IPAddress] <IPAddress> [-SubnetMask] <IPAddress> [<CommonParameters>]
    
    
BESCHREIBUNG
    Get-NetworkAddress returns the network address for a subnet by performing a bitwise AND 
    operation against the decimal forms of the IP address and subnet mask. Get-NetworkAddress 
    expects both the IP address and subnet mask in dotted decimal format.
    

PARAMETER
    -IPAddress <IPAddress>
        Any IP address within the network range.
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -SubnetMask <IPAddress>
        The subnet mask for the network.
        
        Erforderlich?                true
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
    
    
VERWANDTE LINKS



```

