```

NAME
    Get-MessageTrackingAllLogs
    
�BERSICHT
    Holt das MessageTrackingLog von allen Exchange Servern
    
    
SYNTAX
    Get-MessageTrackingAllLogs [[-Sender] <Object>] [[-Recipient] <Object>] [[-Start] <Object>] [[-End] <Object>] [[-EventId] <String>] [[-InternalMessageId] <Object>] [[-MessageId] <Object>] [[-MessageSubject] <Object>] [[-Recipients] <Object>] 
    [[-Reference] <Object>] [[-DomainController] <Object>] [[-ResultSize] <Object>] [-OnlySendEvents] [<CommonParameters>]
    
    
BESCHREIBUNG
    F�r den Transportdienst auf einem Postfachserver sowie f�r den Postfachtransportdienst auf einem Postfachserver und auf einem Edge-Transport-Server ist ein eindeutiges 
    Nachrichtenverfolgungsprotokoll vorhanden. Das Nachrichtenverfolgungsprotokoll ist eine CSV-Datei (Comma-Separated Value, durch Kommas getrennte Werte), die ausf�hrliche Informationen 
    zum Verlauf jeder E-Mail enth�lt, die einen Exchange-Server durchl�uft.
    
    Die in den Ergebnissen des Cmdlets Get-MessageTrackingLog angezeigten Feldnamen �hneln den tats�chlichen Feldnamen, die in den Nachrichtenverfolgungsprotokollen verwendet werden. Es 
    gibt folgende Unterschiede:
    
    * Die Striche werden aus den Feldnamen entfernt. Beispiel: internal-message-id wird angezeigt als InternalMessageId.
    * Das Feld date-time wird angezeigt als Timestamp.
    * Das Feld recipient-address wird als Recipients angezeigt.
    * Das Feld sender-address wird als Sender angezeigt.
    Bevor Sie dieses Cmdlet ausf�hren k�nnen, m�ssen Ihnen die entsprechenden Berechtigungen zugewiesen werden. In diesem Thema sind zwar alle Parameter f�r das Cmdlet aufgef�hrt, aber Sie 
    verf�gen m�glicherweise nicht �ber Zugriff auf einige Parameter, falls diese nicht in den Ihnen zugewiesenen Berechtigungen enthalten sind. Informationen zu den von Ihnen ben�tigten 
    Berechtigungen finden Sie unter "Nachrichtenverfolgung" im Thema Nachrichtenflussberechtigungen.
    

PARAMETER
    -Sender <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Recipient <Object>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Start <Object>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -End <Object>
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -EventId <String>
        
        Erforderlich?                false
        Position?                    5
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -InternalMessageId <Object>
        
        Erforderlich?                false
        Position?                    6
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -MessageId <Object>
        
        Erforderlich?                false
        Position?                    7
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -MessageSubject <Object>
        
        Erforderlich?                false
        Position?                    8
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Recipients <Object>
        
        Erforderlich?                false
        Position?                    9
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Reference <Object>
        
        Erforderlich?                false
        Position?                    10
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DomainController <Object>
        
        Erforderlich?                false
        Position?                    11
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -ResultSize <Object>
        
        Erforderlich?                false
        Position?                    12
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -OnlySendEvents [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterst�tzt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    
VERWANDTE LINKS



```
