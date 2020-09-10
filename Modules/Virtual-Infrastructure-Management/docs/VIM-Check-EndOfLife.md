```

NAME
    VIM-Check-EndOfLife
    
ÜBERSICHT
    Prüft ob eine VM "EndOfLife" ist
    
    
SYNTAX
    VIM-Check-EndOfLife [-VM] <Object> [-DaysToUsedUntil <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        Virtuelle Maschine
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -DaysToUsedUntil <Int32>
        So viele Tage vor "UsedUntil" wird die Maschine gemeldet
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:vim_VM_DaysToUsedUntil
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
    
    PS C:\>Get-VM -Tag "Ring*" | VIM-Check-EndOfLife
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>$tag=Get-Tag -Category Ansprechpartner -Name "Achter*"
    
    Get-VM -Tag $tag | VIM-Check-EndOfLife
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-VM "deslnclivisio2k16" | VIM-Check-EndOfLife
    
    
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>VIM-Check-EndOfLife -VM (Get-VM "deslnclivisio2k16")
    
    
    
    
    
    
    
VERWANDTE LINKS



```

