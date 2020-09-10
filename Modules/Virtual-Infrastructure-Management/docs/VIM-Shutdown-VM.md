```

NAME
    VIM-Shutdown-VM
    
ÜBERSICHT
    Versucht VMs korrekt herunterzufahren.
    Wenn das nicht funktioniert, werden sie hart ausgeschaltet
    
    
SYNTAX
    VIM-Shutdown-VM [-VM] <Object> [-SoftShutdownSeconds <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    Der Shutdown Prozess verläuft immer Synchron. Das heisst es wird immer gewartet
    bis die VM heruntergefahren ist, bevor mit dem nächsten Schritt fotgefahren wird.
    Somit kann dieses Cmdlet in Scripts verwendet werden und nachfolgenden Aktionen
    können einfach dran gehängt werden, ohne sich weitere Gedanken zu machen
    

PARAMETER
    -VM <Object>
        VMs die heruntergefahren werden sollen
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue, ByPropertyName)
        Platzhalterzeichen akzeptieren?false
        
    -SoftShutdownSeconds <Object>
        Nach dieser Zeit werden die VMs hart ausgeschaltet
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 300
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

