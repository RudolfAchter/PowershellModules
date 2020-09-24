```

NAME
    Add-TeamDistributionGroupPermissions
    
ÜBERSICHT
    
    
SYNTAX
    Add-TeamDistributionGroupPermissions [[-Team] <Object>] [[-DistributionGroup] <Object>] [[-Owner] <Object>] 
    [[-Member] <Object>] [[-SendAs] <Object>] [[-SendOnBehalf] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Team <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DistributionGroup <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Owner <Object>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Member <Object>
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SendAs <Object>
        
        Erforderlich?                false
        Position?                    5
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SendOnBehalf <Object>
        
        Erforderlich?                false
        Position?                    6
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
    
    PS C:\>$new_users=@("tornin01","degenh08","xu18","pollne04","gedig01","amthor02","schell25","pickha01","bauer224","
    kaufma23")
    
    Add-TeamDistributionGroupPermissions -Team "P093" -DistributionGroup "fachschaft-philo" -SendOnBehalf $new_users
    
    
    
    
    
VERWANDTE LINKS



```

