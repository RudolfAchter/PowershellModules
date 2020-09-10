```

NAME
    Get-VMCreationDate
    
ÜBERSICHT
    Gets where possible vm creation date.
    
    
SYNTAX
    Get-VMCreationDate [-VMnames] <Object[]> [<CommonParameters>]
    
    
BESCHREIBUNG
    This function will return object with information about  creation time, method, month,
    creator for particular vm. 
    VMname         : SomeVM12
    CreatedTime    : 8/10/2012 11:48:18 AM
    CreatedMonth   : August
    CreationMethod : Cloned
    Creator         : office\greg
     
    This function will display NoEvent value in properties in case when your VC does no
    longer have information about those particular events, or your vm events no longer have
    entries about being created. If your VC database has longer retension date it is more possible
    that you will find this event.
    

PARAMETER
    -VMnames <Object[]>
        This parameter should contain virtual machine objects or strings that represents vm
        names. It is possible to feed this function wiith VM objects that come from get-vm or
        from get-view.
        
        Erforderlich?                true
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?true (ByValue)
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
HINWEISE
    
    
        NAME:  Get-VMCreationdate
        
        AUTHOR: Grzegorz Kulikowski
        
        LASTEDIT: 27/11/2012
         
        NOT WORKING ? #powercli @ irc.freenode.net
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Get-VMCreationdate -VMnames "my_vm1","My_otherVM"
    
    This will return objects that contain creation date information for vms with names
    myvm1 and myvm2
    
    
    
    
    -------------------------- BEISPIEL 2 --------------------------
    
    PS C:\>Get-VM -Location 'Cluster1' |Get-VMCreationdate
    
    This will return objects that contain creation date information for vms that are
    located in Cluster1
    
    
    
    
    -------------------------- BEISPIEL 3 --------------------------
    
    PS C:\>Get-view -viewtype virtualmachine -SearchRoot (get-datacenter 'mydc').id|Get-VMCreationDate
    
    This will return objects that contain creation date information for vms that are
    located in datacenter container 'mydc'. If you are using this function within existing loop where you
    have vms from get-view cmdlet, you can pass them via pipe or as VMnames parameter.
    
    
    
    
    -------------------------- BEISPIEL 4 --------------------------
    
    PS C:\>$report=get-cluster 'cl-01'|Get-VMCreationdate
    
    $report | export-csv c:\myreport.csv
    Will store all reported creationtimes object in $report array variable and export report to csv file.
    You can also filter the report before writing it to csv file using select
    $report | Where-Object {$_.CreatedMonth -eq "October"} | Select VMName,CreatedMonth
    So that you will see only vms that were created in October.
    
    
    
    
    -------------------------- BEISPIEL 5 --------------------------
    
    PS C:\>get-vmcreationdate -VMnames "my_vm1",testvm55
    
    WARNING: my_vm1 could not be found, typo?
    VMname         : testvm55
    CreatedTime    : 10/5/2012 2:24:03 PM
    CreatedMonth   : October
    CreationMethod : NewVM
    Creator        : home\greg
    In case when you privided vm that does not exists in yor infrastructure, a warning will be displayed.
    You can still store the whole report in $report variable, but it will not include any information about
    missing vm creation dates. A warning will be still displayed only for your information that there was
    probably a typo in the vm name.
    
    
    
    
    -------------------------- BEISPIEL 6 --------------------------
    
    PS C:\>Get-VM | get-vmcreationdate | Sort-Object -Property CreatedTime -Descending | ft
    
    
    
    
    
    
    
VERWANDTE LINKS
    https://psvmware.wordpress.com



```

