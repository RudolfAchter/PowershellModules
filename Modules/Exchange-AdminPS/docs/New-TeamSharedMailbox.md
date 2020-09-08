```

NAME
    New-TeamSharedMailbox
    
ÜBERSICHT
    Erstellt SharedMailbox.
    
    
SYNTAX
    New-TeamSharedMailbox -Team <String> [-Name <String>] -Users <String[]> [-EmailAddresses <String[]>] [-Quota] [<CommonParameters>]
    
    
BESCHREIBUNG
    Erstellt SharedMailboxes anhand der angegebenen Parameter.
    

PARAMETER
    -Team <String>
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Name <String>
        Spezifiziert den Namen, Displaynamen sowie das Alias der SharedMailbox.
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Users <String[]>
        Spezifiziert die Benutzer welche FullAccess sowie "Send As"-Rechte auf die SharedMailbox erhalten. Automapping wird zugleich deaktiviert.
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -EmailAddresses <String[]>
        Spezifiziert weitere Email-Adressen welche der SharedMailbox zugeordnet werden. Die Primäre bleibt dabei die ADS-Adresse (z.B.: S001_Team@ads.uni-passau.de)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Quota [<SwitchParameter>]
        Setzt die Quota-Richtlinie um (Warning: 9,5GB; Send: 9,9GB; SendReceive: 10GB)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
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
    
    PS C:\>zimNew-SharedMailbox -Name S001_Team -User User1,User2 -EmailAddresses Example1@uni-passau.de,Example2@uni-passau.de -Quota
    
    Erstellt eine neue SharedMailbox bei der die angegebenen Benutzer FullAccess- sowie SendAs-Rechte besitzen, die weiteren Email-Adressen eingetragen werden und die Quotas gesetzt werden.
    
    
    
    
    
VERWANDTE LINKS



```

