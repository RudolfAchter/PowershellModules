```

NAME
    Send-MailMessageAdvanced
    
ÜBERSICHT
    Embed inline attachments into HTML bodies with a new Send-MailMessage function.
    
    
SYNTAX
    Send-MailMessageAdvanced [-Attachments <String[]>] [-InlineAttachments <Hashtable>] [-Bcc <MailAddress[]>] 
    [[-Body] <String>] [-BodyAsHtml] [-Cc <MailAddress[]>] [-DeliveryNotificationOption {None | OnSuccess | OnFailure 
    | Delay | Never}] -From <MailAddress> [-SmtpServer] <String> [-Priority {Normal | Low | High}] [-Subject] <String> 
    [-To] <MailAddress[]> [-Credential <PSCredential>] [-UseSsl] [-Port <Int32>] [<CommonParameters>]
    
    
BESCHREIBUNG
    The Send-MailMessage cmdlet exposes most of the basic functionality for sending email, 
    but you don't get a lot of control over things like attachments or alternate views. 
    Someone on the TechNet forums was asking how to embed images into an HTML mail message, 
    and I decided to write a version of Send-MailMessage that supports this.  
    I started with a proxy function for the Send-MailMessage cmdlet, so all of the parameters and usage should be 
    intact.  
    The main difference is that I added an -InlineAttachments argument, which accepts a hashtable of pairs in the 
    format 
    'ContentId'='FilePath'.  
    You can then embed the resources into an HTML body by using URLs of the format "cid:ContentId".
    

PARAMETER
    -Attachments <String[]>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -InlineAttachments <Hashtable>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Bcc <MailAddress[]>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Body <String>
        
        Erforderlich?                false
        Position?                    3
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -BodyAsHtml [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Cc <MailAddress[]>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -DeliveryNotificationOption
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -From <MailAddress>
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SmtpServer <String>
        
        Erforderlich?                true
        Position?                    4
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Priority
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Subject <String>
        
        Erforderlich?                true
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -To <MailAddress[]>
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Credential <PSCredential>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -UseSsl [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Port <Int32>
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 25
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
    
    PS C:\>$images = @{
    
    image1 = 'c:\temp\test.jpg' 
        image2 = 'C:\temp\test2.png' 
    }  
      
    $body = @' 
    <html>  
      <body>  
        <img src="cid:image1"><br> 
        <img src="cid:image2"> 
      </body>  
    </html>  
    '@  
      
    $params = @{ 
        InlineAttachments = $images 
        Attachments = 'C:\temp\attachment1.txt', 'C:\temp\attachment2.txt' 
        Body = $body 
        BodyAsHtml = $true 
        Subject = 'Test email' 
        From = 'username@gmail.com' 
        To = 'recipient@domain.com' 
        Cc = 'recipient2@domain.com', 'recipient3@domain.com' 
        SmtpServer = 'smtp.gmail.com' 
        Port = 587 
        Credential = (Get-Credential) 
        UseSsl = $true 
    } 
     
    Send-MailMessage @params
    
    
    
    
    
VERWANDTE LINKS



```

