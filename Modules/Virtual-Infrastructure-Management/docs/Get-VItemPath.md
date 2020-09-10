```

NAME
    Get-VItemPath
    
ÜBERSICHT
    Returns the folderpath for a folder
    
    
SYNTAX
    Get-VItemPath [[-Item] <Object>] [-ShowHidden] [<CommonParameters>]
    
    
BESCHREIBUNG
    The function will return the complete folderpath for
    a given folder, optionally with the "hidden" folders
    included. The function also indicats if it is a "blue"
    or "yellow" folder.
    

PARAMETER
    -Item <Object>
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    -ShowHidden [<SwitchParameter>]
        Switch to specify if "hidden" folders should be included
        in the returned path. The default is $false.
        
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
    
HINWEISE
    
    
        Authors:	Luc Dekens
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS>Get-FolderPath -Folder (Get-Folder -Name "MyFolder")
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS>Get-Folder | Get-FolderPath -ShowHidden:$true
    
    
    
    
    
    
    
VERWANDTE LINKS
    http://www.lucd.info/2010/10/21/get-the-folderpath/



```

