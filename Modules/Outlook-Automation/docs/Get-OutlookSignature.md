```

NAME
    Get-OutlookSignature
    
ÜBERSICHT
    Generiert E-Mail Signaturen anhand von HTML Templates die unter $SignatureTemplatesPath
    abgelegt sind
    
    
SYNTAX
    Get-OutlookSignature [[-User] <Object>] [-TargetPath <Object>] [-SignatureTemplatesPath <Object>] 
    [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -User <Object>
        Für welchen User (samAccountName oder Email (der Teil vorm @)
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $env:username
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -TargetPath <Object>
        Hier hin werden alle Files geschrieben (Fotos und HTML Dateien)
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $env:APPDATA+"\microsoft\signatures"
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SignatureTemplatesPath <Object>
        Von hier werden die Templates genommen. Als Namenskonvention haben die Templates:
        *.template.htm
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $global:SignatureTemplatesPath
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

