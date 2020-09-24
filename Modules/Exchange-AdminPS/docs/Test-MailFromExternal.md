```

NAME
    Test-MailFromExternal
    
ÜBERSICHT
    Erstellt eine Testmail von einem externen Konto
    
    
SYNTAX
    Test-MailFromExternal [[-Subject] <String>] [[-Body] <String>] [[-SmtpServer] <String>] [[-Port] <String>] 
    [[-User] <String>] [[-Password] <String>] [[-From] <String>] [[-To] <String[]>] [-UseSsl] [<CommonParameters>]
    
    
BESCHREIBUNG
    

PARAMETER
    -Subject <String>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Body <String>
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SmtpServer <String>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 $Global:Exchange.MailTest.FromExternal.SmtpServer
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Port <String>
        
        Erforderlich?                false
        Position?                    4
        Standardwert                 $Global:Exchange.MailTest.FromExternal.Port
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -User <String>
        
        Erforderlich?                false
        Position?                    5
        Standardwert                 $Global:Exchange.MailTest.FromExternal.User
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Password <String>
        
        Erforderlich?                false
        Position?                    6
        Standardwert                 $Global:Exchange.MailTest.FromExternal.Password
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -From <String>
        
        Erforderlich?                false
        Position?                    7
        Standardwert                 $Global:Exchange.MailTest.FromExternal.From
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -To <String[]>
        
        Erforderlich?                false
        Position?                    8
        Standardwert                 $Global:Exchange.MailTest.FromExternal.To
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -UseSsl [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 $Global:Exchange.MailTest.FromExternal.UseSsl
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
    
    PS C:\>#Mail versenden
    
    Test-MailFromExternal -Subject "Test an sekretariat.hartwig@uni-passau.de" -Body "Test an 
    sekretariat.hartwig@uni-passau.de" -To "sekretariat.hartwig@uni-passau.de"
    Sending Mail From rudolf.achter.unipassau.exttest@gmx.de To sekretariat.hartwig@uni-passau.de via mail.gmx.net
    #Überprüfen ob die Mail richtig angekommen ist
    Get-MessageTrackingAllLogs -Start 10:30 -MessageSubject "Test an sekretariat.hartwig@uni-passau.de"
    
    
    
    
    
VERWANDTE LINKS



```

