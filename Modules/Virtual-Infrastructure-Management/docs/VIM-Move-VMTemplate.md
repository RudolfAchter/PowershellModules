```

NAME
    VIM-Move-VMTemplate
    
ÜBERSICHT
    Verschiebt Templates in einen anderen Datastore
    
    
SYNTAX
    VIM-Move-VMTemplate [-Template] <Object> [-TargetDatastore] <Object> [<CommonParameters>]
    
    
BESCHREIBUNG
    Um ein Template zu verschieben muss dieses zunächst in eine
    VM konvertiert werden, dann verschoben werden, dann wieder
    zurück in ein Template konvertiert werden. Dieser Job wird
    durch dieses Script vereinfacht
    

PARAMETER
    -Template <Object>
        Das zu verschiebende Template
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -TargetDatastore <Object>
        Ziel Datastore
        
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
    VirtualMachineImpl
    
    
AUSGABEN
    
HINWEISE
    
    
        Author: Rudolf Achter
        Date:   2016-05-19
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>VIM-Move-VMTemplate "Windows 7" "VSA_LUN01"
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-Template | VIM-Move-VMTemplate -TargetDatastore "NAS_THECUS_LUN01"
    
    
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-Datastore TMP_MSA_iSCSI01 | Get-Template "Windows 7" | VIM-Move-VMTemplate -TargetDatastore 
    NAS_THECUS_LUN01
    
    #Das Template Windows 7 Aus Datastore TMP_MSA_iSCSI01 wird verschoben
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>Get-Datastore TMP_MSA_iSCSI01 | Get-Template | VIM-Move-VMTemplate -TargetDatastore NAS_THECUS_LUN01
    
    #Alle Templates Aus Datastore TMP_MSA_iSCSI01 werden verschoben
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/VMWare_PowerCLI_Addons.psm1/VIM-Move-VMTemplate



```

