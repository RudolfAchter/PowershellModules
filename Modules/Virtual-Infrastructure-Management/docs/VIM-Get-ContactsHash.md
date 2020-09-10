```

NAME
    VIM-Get-ContactsHash
    
ÜBERSICHT
    Liefert eine Hashtable mit allen Kontaktaddressen in der vCenter Umgebung
    
    
SYNTAX
    VIM-Get-ContactsHash [<CommonParameters>]
    
    
BESCHREIBUNG
    Liefert eine Hashtable mit allen Kontaktaddressen in der vCenter Umgebung
    
    Die Hashtable ist wie folgt Aufgebaut
    
    contact1@megatech-communication.de
        Name = Name                  "Name" des Ansprechpartner Tag
        Address = E-mail-Addresse    "Description" Email-Addresse des Ansprechpartner Tags
        Data = @{}                   Eine Lere Hashtable zum Speichern von Ergebnissen für den Contact
    

PARAMETER
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>$h_contacts=VIM-Get-ContactsHash
    
    $h_contacts.Keys | %{$h_contacts.Item($_)}
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>$h_contacts=VIM-Get-ContactsHash
    
    #...
    #Irgendeine Funktion befüllt $h_contacts
    #...
    #Daten von h_contacts anzeigen
    $h_contacts.Keys | %{($h_contacts.Item($_)).Data} | fl
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-Co
    ntactsHash
    http://stackoverflow.com/questions/9015138/powershell-looping-through-a-hash-or-using-an-array



```

