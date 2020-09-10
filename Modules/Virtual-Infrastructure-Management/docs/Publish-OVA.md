```

NAME
    Publish-OVA
    
ÜBERSICHT
    
    
SYNTAX
    Publish-OVA [-VM] <Object> -Name <Object> [-TargetDir <Object>] [-TempDir <Object>] [-TempCloneToDatastore 
    <Object>] [-KeepTempDir] [-ovftool <Object>] [-openssl <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -VM <Object>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -Name <Object>
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TargetDir <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 .
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TempDir <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 ((Get-Item $env:Temp).FullName)+"\Publish-OVA"
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -TempCloneToDatastore <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -KeepTempDir [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ovftool <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:ovftool
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -openssl <Object>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $PSScriptRoot + "\bin\openssl.exe"
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
    
    PS C:\>Get-VM utility-s2.site2* | Publish-OVA -Name "ubuntu_OpenSource_UtilityServer_v2.1_2019-03-14"
    
    
    
    
    
    
    
VERWANDTE LINKS



```

