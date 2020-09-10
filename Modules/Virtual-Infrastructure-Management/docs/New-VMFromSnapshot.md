```

NAME
    New-VMFromSnapshot
    
ÜBERSICHT
    Function to create a clone from a snapshot of a VM.
    
    
SYNTAX
    New-VMFromSnapshot -SourceVM <PSObject> -CloneName <String> [-Cluster <String>] [-Datastore <String>] [-VMFolder 
    <String>] [-LinkedClone] [<CommonParameters>]
    
    New-VMFromSnapshot -SourceVM <PSObject> -CloneName <String> -SnapshotName <String> [-Cluster <String>] [-Datastore 
    <String>] [-VMFolder <String>] [-LinkedClone] [<CommonParameters>]
    
    
BESCHREIBUNG
    Function to create a clone from a snapshot of a VM.
       //XXX nicht von mir (RAC)
       //XXX ToDo Implementation passt nicht zu den restlichen CMDlets
       das hier gehört nochmal neu geschrieben im RAC Style
    

PARAMETER
    -SourceVM <PSObject>
        VM to clone from.
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -CloneName <String>
        Name of the clone to create
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -SnapshotName <String>
        Name of the snapshot to clone from
        
        Erforderlich?                true
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Cluster <String>
        Name of the cluster to place the clone in
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Datastore <String>
        Name of the datastore to place the clone in
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -VMFolder <String>
        Name of the Virtual Machine folder to put the VM in
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -LinkedClone [<SwitchParameter>]
        Create a linked clone from the snapshot, rather than a full clone
        
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
    String.
    System.Management.Automation.PSObject.
    
    
AUSGABEN
    VMware.Vim.ManagedObjectReference.
    
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS>New-VMFromSnapshot -SourceVM VM01 -CloneName "Clone01" -Cluster "Test Cluster" -Datastore "Datastore01"
    
    
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS>New-VMFromSnapshot -SourceVM VM01 -CloneName "Clone01" -SnapshotName "Testing" -Cluster "Test Cluster" 
    -Datastore "Datastore01" -VMFolder "Test Clones" -LinkedClone
    
    
    
    
    
    
    
VERWANDTE LINKS



```

