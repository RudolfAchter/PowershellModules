```

NAME
    ConvertTo-Mask
    
ÜBERSICHT
    Returns a dotted decimal subnet mask from a mask length.
    
    
SYNTAX
    ConvertTo-Mask [-MaskLength] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    ConvertTo-Mask returns a subnet mask in dotted decimal format from an integer value ranging 
    between 0 and 32. ConvertTo-Mask first creates a binary string from the length, converts 
    that to an unsigned 32-bit integer then calls ConvertTo-DottedDecimalIP to complete the operation.
    

PARAMETER
    -MaskLength <Object>
        The number of bits which must be masked.
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
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

