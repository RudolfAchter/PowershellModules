```

NAME
    VIM-Get-VM-NotStartable
    
ÜBERSICHT
    Gibt VMs zurück die aus unerklärlichen Gründen nicht gestartet werden können
    
    
SYNTAX
    VIM-Get-VM-NotStartable [<CommonParameters>]
    
    
BESCHREIBUNG
    Bei ESX-Server Abstürzen, Storage Problemen und dergleichen, kann es vorkommen, dass die
    vCenter Datenbank nicht mehr den richtigen Status über die Startbarkeit von virtuellen Maschinen
    wiedergibt. Dadurch wird der Start der virtuellen Maschine verhindert obwohl diese wieder voll
    Einsatzbereit ist.
    In vielen Fällen ist es dann notwendig diese VM komplett aus dem vCenter Bestand zu entfernen und
    wieder neu zu registrieren. Es gibt zwar Workarounds derartige Probleme direkt in der vCenter Postgres
    Datenbank zu beheben. Derartige Arbeiten könnten aber zu inkosistenzen in der vCenter Datenbank führen.
    Daher ist es empfehlenswerter eine Lösung über die vCenter API anzustreben
    

PARAMETER
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Get-VM-NotStartable
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>#DAS HIER IST MIT VORSICHT ZU GENIESSEN!!!
    
    VIM-Get-VM-NotStartable | VIM-ReRegister-VM
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM
    -NotStartable



```

