```

NAME
    Show-ManagementRoles
    
ÜBERSICHT
    Zeigt Exchange Management Rechte eines Users an
    
    
SYNTAX
    Show-ManagementRoles [[-ExUser] <Object>] [-Details] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -ExUser <Object>
        AdUser für den die Rechte angezeigt werden sollen. Kann Via Pipe übergeben werden
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -Details [<SwitchParameter>]
        Switch ob Details angezeigt werden sollen. Bei den Details werden alle Cmdlets für die Rolle (RBAC) angezeigt
        (ManagementRoleEntries)
        
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
    
    PS C:\>Get-ADUser -Identity "fesl16" | Show-ManagementRoles -Details | Out-GridView
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-ADUser -Identity "fesl16" | Show-ManagementRoles -Details | ? RoleCmdlet -NotLike "Get-*" | Out-GridView
    
    
    
    
    
    
    
VERWANDTE LINKS



```

