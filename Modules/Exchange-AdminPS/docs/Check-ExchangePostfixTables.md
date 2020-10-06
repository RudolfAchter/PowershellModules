```

NAME
    Check-ExchangePostfixTables
    
ÜBERSICHT
    Führt einen Plausibilitäts Check zwischen Exchange / ActiveDirectory
    Email Adressen und unseren Postfix Tabellen durch
    
    
SYNTAX
    Check-ExchangePostfixTables [-Detailed] [<CommonParameters>]
    
    
BESCHREIBUNG
    Alle uni-passau.de E-Mail Adressen "(smtp|SMTP:)[^@]+@uni-passau\.de"
    werden daraufhin überprüftr, dass in der Postfix virtual Tabelle
    ein entsprechender Verweis auf die @ads.uni-passau.de Adresse vorhanden ist
    
    Alle primären E-Mail Adressen (Antwort Adressen)
    (SMTP:)[^@]+@(ads|gw|pers|stud)\.uni-passau\.de
    werden auf einen evtl notwendigen Eintrag in der sender_canonical überprüft,
    damit die Adresse in die Entsprechende DutyEmail @uni-passau.de umgeschrieben wird
    Alle DutyEmail Adressen sollten über kurz oder lang sowieso auf Primary umgestellt werden
    notwendig wegen E-Mail Signatur
    

PARAMETER
    -Detailed [<SwitchParameter>]
        (Optional) Überprüft die Postfix Einträge genauer. Bei z.B. Team Email Adresse sind Einträge zwar vorhanden
        zeigen aber nicht immer auf das korrekte AD-Objekt. Das wird hier zusätzlich überprüft
        
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
    
    
VERWANDTE LINKS



```

