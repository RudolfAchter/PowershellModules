```

NAME
    New-TeamDistributionGroup
    
ÜBERSICHT
    Erstellt Distributiongroups. Notwendige "virtual" Einträge am Postfix Server werden automatisch ergänzt
    
    
SYNTAX
    New-TeamDistributionGroup -Name <String> [-Alias <Object>] -Owner <String[]> -Members <String[]> -SendOnBehalfUsers <String[]> [-EmailAddresses <String[]>] [<CommonParameters>]
    
    New-TeamDistributionGroup [-Path <String>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Erstellt Distributiongroups anhand der angegebenen Parameter. Es wird überprüft ob die E-Mail-Addresse bereits existiert
    und gegebenenfalls abgebrochen. @uni-passau.de E-Mail-Addresse wird am Postfix Server (tom) ergänzt und ein Postmap
    durchgeführt
    

PARAMETER
    -Name <String>
        Spezifiziert den System- bzw. DisplayName.
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Alias <Object>
        Spezifiziert den Aliasnamen. Am besten wird Gruppenname gefolt von Unterstrich und Präfix Emailadresse verwendet (z.B.: S001_Sekretariat)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Owner <String[]>
        Spezifiziert den Besitzer der DistributionGroup. Hier wird der Einrichtungsleiter eingetragen.
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Members <String[]>
        Spezifiziert die Mitglieder der DistributionGroup. In unserem Fall wird hier nur die SharedMailbox eingetragen (z.B.: S001_Team)
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SendOnBehalfUsers <String[]>
        Spezifiziert die Benutzer welche im Namen der DistributionGroup senden dürfen. Angabe der Benutzer mit kurzem Benutzernamen und via Komma getrennt
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -EmailAddresses <String[]>
        Spezifiziert die EmailAdresse der DistributionGroup. Angabe von mehreren Emails durch Komma getrennt möglich. Die als erstes genannte EmailAdresse wird die Hauptadresse. Die Standard ADS-Adresse (z.B.: Sekretaria@ads.uni-passau.de) wird automatisch 
        erzeugt.
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Path <String>
        
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
    
    PS C:\>zimNew-DistributionGroup -Name ZIM-Sekretariat -Alias S001_Sekretariat -Owner User1 -Members S001_Team -SendOnBehalfUsers User2,User3 -EmailAddresses Zim-Sekretariat@uni-passau.de,ExampleTest@uni-passau.de
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>zimNew-DistributionGroup -Path DistributionGroups.csv
    
    
    
    
    
    
    
VERWANDTE LINKS



```

