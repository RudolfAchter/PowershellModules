<#
VMWare_PowerCLI_Addons.psm1

generelle VMWare PowerCLI Addons. Hiervon sin alle anderen VMWare Addons abhängig
#>




<#
.SYNOPSIS
    Verschiebt Templates in einen anderen Datastore
.DESCRIPTION
    Um ein Template zu verschieben muss dieses zunächst in eine
    VM konvertiert werden, dann verschoben werden, dann wieder
    zurück in ein Template konvertiert werden. Dieser Job wird
    durch dieses Script vereinfacht
.PARAMETER Template
    Das zu verschiebende Template
.PARAMETER TargetDatastore
    Ziel Datastore
.EXAMPLE 
    VIM-Move-VMTemplate "Windows 7" "VSA_LUN01"
.EXAMPLE 
    Get-Template | VIM-Move-VMTemplate -TargetDatastore "NAS_THECUS_LUN01"
.EXAMPLE
    Get-Datastore TMP_MSA_iSCSI01 | Get-Template "Windows 7" | VIM-Move-VMTemplate -TargetDatastore NAS_THECUS_LUN01
    #Das Template Windows 7 Aus Datastore TMP_MSA_iSCSI01 wird verschoben
.EXAMPLE
    Get-Datastore TMP_MSA_iSCSI01 | Get-Template | VIM-Move-VMTemplate -TargetDatastore NAS_THECUS_LUN01
    #Alle Templates Aus Datastore TMP_MSA_iSCSI01 werden verschoben
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/VMWare_PowerCLI_Addons.psm1/VIM-Move-VMTemplate
.INPUTS
    VirtualMachineImpl
.NOTES
    Author: Rudolf Achter
    Date:   2016-05-19    
#>
function VIM-Move-VMTemplate{
	[CmdletBinding()]
    param( 
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]    
    $Template,
    [Parameter(Position=1, Mandatory=$true)]
    [Alias('Datastore')]
    $TargetDatastore
    
    
    )

    Begin {
        $a_templates=@()
        $datastore=Get-Datastore $TargetDatastore
        If(-not $datastore) {
            Write-Host "Datastore "
        }
    }

    Process {

        $Template | ForEach-Object {
            $a_templates += $_
        }
    }

    End {
        [int]$kb_tocopy=(Get-Template $a_templates | Get-HardDisk | Measure-Object CapacityKB -Sum).Sum
        
        #if($template -eq ""){Write-Host "Enter a Template name"}
        #if($datastore -ne ""){$svmotion = $true}
        
        [int]$kb_copied=0
        
        $a_templates | ForEach-Object {
            $template = Get-Template $_
            $percent = $kb_copied / $kb_tocopy * 100
            $kb_current=($template | Get-HardDisk | Measure-Object CapacityKB -Sum).Sum
            $kb_remaining=$kb_tocopy - $kb_copied

            Write-Progress -Activity "Moving Templates" -Status ("Template: " + $template.Name + " To Move: " + ("{0:N2}" -f  ($kb_current/1024/1024)) + "GB" + 
                " Total Remaining: " + ("{0:N2}" -f  ($kb_remaining/1024/1024)) + "GB") -PercentComplete $percent
            #Start-Sleep -Seconds 5 

            Write-Host "Converting $template to VM"

            Try{

                $vm = Set-Template -Template $template -ToVM 

                Write-Host "Migrate $template to $datastore"
                # Move-VM -VM (Get-VM $vm) -Destination (Get-VMHost $esx) -Datastore $datastore -Confirm:$false
                Move-VMThin (Get-VM $vm) $datastore

                Write-Host "Converting $template to template"
                Set-VM -VM $vm -ToTemplate -Confirm:$false | Out-Null

                $kb_copied+=$kb_current
                Write-Host "Template" $template.Name "GB Moved:" ("{0:N2}" -f ($kb_current/1024/1024)) "GB" "GB Moved SUM: " ("{0:N2}" -f ($kb_copied/1024/1024))
            }
            Catch {
                Write-Error ("ERROR While Moving Template:" + $template)
                $template = Set-VM -VM $vm -ToTemplate -Confirm:$false
            }
            
        }

    }
}

function Move-VMThin {
	[CmdletBinding()]
    PARAM(
         [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Virtual Machine Objects to Migrate")]
         [ValidateNotNullOrEmpty()]
            [System.String]$VM
        ,[Parameter(Mandatory=$true,HelpMessage="Destination Datastore")]
         [ValidateNotNullOrEmpty()]
            [System.String]$Datastore
    )

 Begin {
        #Nothing Necessary to process
 } #Begin

    Process {
        #Prepare Migration info, uses .NET API to specify a transformation to thin disk
        $vmView = Get-View -ViewType VirtualMachine -Filter @{"Name" = "$VM"}
        $dsView = Get-View -ViewType Datastore -Filter @{"Name" = "$Datastore"}

        #Abort Migration if free space on destination datastore is less than 50GB
        if (($dsView.info.freespace / 1GB) -lt 50) {throw "Move-ThinVM ERROR: Destination Datastore $Datastore has less than 50GB of free space. This script requires at least 50GB of free space for safety. Please free up space or use the VMWare Client to perform this Migration"}

        #Prepare VM Relocation Specificatoin
        $spec = New-Object VMware.Vim.VirtualMachineRelocateSpec
        $spec.datastore =  $dsView.MoRef
        $spec.transform = "sparse"

        #Perform Migration
        $vmView.RelocateVM($spec, $null)
    } #Process
}


function Get-ThinProvisioned {
	[CmdletBinding()]
	param()

	get-vm | get-view | %{
	 $vm = $_
	 $_.Config.Hardware.Device | where {$_.GetType().Name -eq "VirtualDisk"} | %{
	  if($_.Backing.ThinProvisioned){ 
	   $vm
	  }
	 }
	}
}

Function Get-VMRC-Url {
<#
.SYNOPSIS
    Zeigt die VMRC Url einer oder mehrerer VMs  zur weiteren Verwendung
.DESCRIPTION
    Zeigt die VMRC Url einer VM  zur weiteren Verwendung
.PARAMETER VM
    Name der virtuellen Maschine
.PARAMETER CloneTicket
    Wenn gesetzt wird die Aktuelle Authentifizierung der Powershell kopiert
    wenn bereits über Powershell Authentifiziert, kann die VMRC ohen Authentifizierung gestartet werden
.PARAMETER UrlAsWikiLink
    URL für Verwendung in WikiSyntax
.PARAMETER AsObject
    Gibt das VM Objekt mit vmrcURL als NoteProperty aus
.EXAMPLE 
    Get-VMRC-Url win7vm
.EXAMPLE
    Get-VMRC-Url (Get-VM) -Anonymous -UrlAsWikiLink
    #Alle VMs als VMRC-Url
.EXAMPLE
    Get-Folder -Name Fernwartung | Get-VM | Get-VMRC-Url -Anonymous -UrlAsWikiLink
.NOTES
    Author: Rudolf Achter
    Date:   2016-05-11    
#>

    [CmdletBinding()]

    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [switch]$CloneTicket,

    [switch]$UrlAsWikiLink,

    [switch]$AsObject

    )

    Begin {

        if(!$global:DefaultVIServers.name) {
            "You are not connected to any VMWare Server."
            Write-Host "Use Connect-VIServer first"
            return
        }
    #Variables
        $vCenterName = $global:DefaultVIServers.name
 
        #vCenterInstance ID
        $vCenterInstanceID =  $DefaultVIServers[0].InstanceUuid

        #Get vCenter ticket
        $SessionMgr = Get-View $global:DefaultVIServer.ExtensionData.Client.ServiceContent.SessionManager
        $Session = $SessionMgr.AcquireCloneTicket()

    }
    
    Process { 

        $VM | ForEach-Object {
            #Objects
            $vivm = Get-VM $_
            $vApp = "The vApp in vCloud Director"
 
            #VM MoRef -> required for Console URL and vSphere Summary URL
            $vmMoRef = $vivm.ExtensionData.MoRef.ToString()
            $vmMoRef = $vmMoRef.Substring(15,$vmMoRef.Length-15)

            $vmrcShortURL = "vmrc://" + $vCenterName + ":443/?moid=" + $vmMoRef
        
            if($CloneTicket) {
                $vmrcURL = "vmrc://clone:"+ $Session + "@" + $vCenterName + ":443/?moid=" + $vmMoRef
            }
            else
            {
                $vmrcURL = "vmrc://" + $vCenterName + ":443/?moid=" + $vmMoRef
            }

            if($UrlAsWikiLink)
            {
                $vmrcURL = '[' + $vmrcURL+ ' ' +$vivm.Name +']'
            }

            #$ConsoleURL
            #$vcloudURL
            #$vsphereURL

            #$vmrcShortURL
            #Write-Host ""

            If($AsObject){
            
                Add-Member -InputObject $vivm -MemberType NoteProperty -Name vmrcURL -Value $vmrcURL
                $vivm
            }
            else {
                $vmrcURL
            }
        }
    }

}


<#
.SYNOPSIS
    Startet VMRC Konsole für eine VM
.DESCRIPTION
    Startet eine VMRC Konsole von der, oder den VMs die an das Cmdlet Übergeben wurden.
    Die VMs werden als Objekt aus der PowerCLI an dieses Cmdlet übergeben
.EXAMPLE 
    Get-VM "MeineVM" | Start-VMRC
.EXAMPLE 
    Get-Folder "Meine-VM-Gruppe" | Get-VM | Start-VMRC
.LINK
    http://wiki.megatech.local/mediawiki/index.php/PSCmdlet:Start-VMRC
.INPUTS
    VirtualMachineImpl
.NOTES
    Author: Rudolf Achter
    Date:   2016-02-18    
#>
Function Start-VMRC {
    
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM
    )

    Begin{}


    Process{
        $VM | ForEach-Object {
            $_
            $vm=Get-VM $_
            if($vm.GetType().Name -eq "UniversalVirtualMachineImpl")
                {
                    #Write-Host "VM Input"
                    [string]$url=Get-VMRC-Url $vm.Name -CloneTicket
                    $url
                    start $url
                }
        }
    }

    End{}
}



Function Get-All-Urls {
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true)] [string]$s_vm)


#Variables
    $vCenterName = $global:DefaultVIServers.name
 
    #vCenterInstance ID
    $vCenterInstanceID =  $DefaultVIServers[0].InstanceUuid
 
    #Objects
    $vivm = Get-VM $s_vm
    $vApp = "The vApp in vCloud Director"
 
    #VM MoRef -> required for Console URL and vSphere Summary URL
    $vmMoRef = $vivm.ExtensionData.MoRef.ToString()
    $vmMoRef = $vmMoRef.Substring(15,$vmMoRef.Length-15)
 
    #vAppMoRef and OrgMoRef, required for the vCloud Director vApp URL
    #$vAppMoRef = $vApp.Id
    #$vAppMoRef = $vAppMoRef.Substring(16,$vAppMoRef.Length-16)
    #$OrgMoRef = $vApp.Org.Id
    #$OrgMoRef = $OrgMoRef.Substring(15,$OrgMoRef.Length-15)

    #Get vCenter ticket
    $SessionMgr = Get-View $global:DefaultVIServer.ExtensionData.Client.ServiceContent.SessionManager
    $Session = $SessionMgr.AcquireCloneTicket()
	
    #Console URL
    $ConsoleURL = "https://" + $vCenterName + ":9443/vsphere-client/vmrc/vmrc.jsp?vm=urn:vmomi:VirtualMachine:" + $vmMoRef + ":" + $vCenterInstanceID.ToUpper()
                       
    #vCloud vApp URL
    #$vcloudURL = "https://" + $vCloudDirName + "/cloud/#/vAppDiagram?vapp=" + $vAppMoRef + "&org=" + $OrgMoRef                     
                       
    #vSphere Summary URL
    $vsphereURL = "https://" + $vCenterName + ":9443/vsphere-client/#extensionId=vsphere.core.vm.summary;context=com.vmware.core.model%3A%3AServerObjectRef~" + $vCenterInstanceID.ToUpper() + "%3AVirtualMachine%3A" + $vmMoRef + "~core"



    $vmrcURL = "vmrc://clone:" + $Session + "@" + $vCenterName + ":443/?moid=" + $vmMoRef

    $ConsoleURL
    $vcloudURL
    $vsphereURL
    $Session
    $vmrcURL


}


function Get-VMEvents {
 <#
   .Synopsis
 
    Get events for an entity or for query all events.
 
   .Description
 
    This function returns events for entities. It's very similar to 
    get-vievent cmdlet.Note that get-VMEvent can handle 1 vm at a time.
    You can not send array of vms in this version of the script.
 
    .Example
 
    Get-VMEvents 0All -types "VmCreatedEvent","VmDeployedEvent","VmClonedEvent"
 
    This will receive ALL events of types "VmCreatedEvent","VmDeployedEvent",
    "VmClonedEvent". 
     
   .Example
 
    Get-VMEvents -name 'vm1' -types "VmCreatedEvent"
 
    Will ouput creation events for vm : 'vm1'. This was is faster than piping vms from
    get-vm result. There is no need to use get-vm to pass names to get-vmevents.
    Still, it is ok when you will do it, it will make it just a little bit slower??
     
   .Example
 
    Get-VMEvents -name 'vm1' -category 'warning'
 
    Will ouput all events for vm : 'vm1'. This was is faster than piping names from
    get-vm cmdlet. Category will make get-vmevent to search only defined category
    events. 
     
   .Example
 
    get-vm 'vm1' | Get-VMEvents -types "VmCreatedEvent","VmMacAssignedEvent"
 
    Will display events from vm1 which will be regarding creation events,
    and events when when/which mac address was assigned
 
 
    .Parameter VM
 
    This parameter is a single string representing vm name. It expects single vm name that
    exists in virtual center. At this moment in early script version it will handle only a case
    where there is 1 instance of vm of selected name. In future it will handle multiple as 
    well.
     
   .Parameter types
 
    If none specified it will return all events. If specified will return
    only events with selected types. For example : "VmCreatedEvent",
    "VmDeployedEvent", "VmMacAssignedEvent" "VmClonedEvent" , etc...
     
    .Parameter category
 
    Possible categories are : warning, info, error. Please use this parameter if you
    want to filter events.
     
    .Parameter All
 
    If you will set this parameter, as a result command will query all events from
    virtual center server regarding virtual machines. 
 
   .Notes
 
    NAME:  VMEvents
 
    AUTHOR: Grzegorz Kulikowski
 
    LASTEDIT: 11/09/2012
     
    NOT WORKING ? #powercli @ irc.freenode.net 
 
   .Link
 
    https://psvmware.wordpress.com
 
 #>
 
param(
[Parameter(ValueFromPipeline=$true)]
[ValidatenotNullOrEmpty()]
$VM,
[String[]]$types,
[string]$category,
[switch]$All
)
    $si=get-view ServiceInstance
    $em= get-view $si.Content.EventManager
    $EventFilterSpec = New-Object VMware.Vim.EventFilterSpec
    $EventFilterSpec.Type = $types
    if($category){
    $EventFilterSpec.Category = $category
    }
     
    if ($VM){
    $EventFilterSpec.Entity = New-Object VMware.Vim.EventFilterSpecByEntity
    switch ($VM) {
<#
        {$_ -is [VMware.Vim.VirtualMachine]} {$VMmoref=$vm.moref}
        {$_ -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]}{$VMmoref=$vm.Extensiondata.moref}
        default {$vmmoref=(get-view -ViewType virtualmachine -Filter @{'name'=$VM}).moref }
#>

        {($_.GetType()).Name -eq "String"} {
            $vmmoref=(get-view -ViewType virtualmachine -Filter @{'name'=$VM}).moref 
        }
        default {
            $vmmoref=$VM.ExtensionData.MoRef
        }

    }
    $EventFilterSpec.Entity.Entity = $vmmoref
        $em.QueryEvents($EventFilterSpec) 
    }
    if ($All) {
    $em.QueryEvents($EventFilterSpec)
    }
}




function Get-VMCreationDate {
<#
   .Synopsis
 
    Gets where possible vm creation date.
 
   .Description
 
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
 
    .Example
 
    Get-VMCreationdate -VMnames "my_vm1","My_otherVM"
 
    This will return objects that contain creation date information for vms with names
    myvm1 and myvm2
     
   .Example
 
    Get-VM -Location 'Cluster1' |Get-VMCreationdate
 
    This will return objects that contain creation date information for vms that are
    located in Cluster1
     
   .Example
 
    Get-view -viewtype virtualmachine -SearchRoot (get-datacenter 'mydc').id|Get-VMCreationDate
 
    This will return objects that contain creation date information for vms that are
    located in datacenter container 'mydc'. If you are using this function within existing loop where you
    have vms from get-view cmdlet, you can pass them via pipe or as VMnames parameter.
 
    .Example
 
    $report=get-cluster 'cl-01'|Get-VMCreationdate
    $report | export-csv c:\myreport.csv
    Will store all reported creationtimes object in $report array variable and export report to csv file.
    You can also filter the report before writing it to csv file using select
    $report | Where-Object {$_.CreatedMonth -eq "October"} | Select VMName,CreatedMonth
    So that you will see only vms that were created in October.
 
 
    .Example
    get-vmcreationdate -VMnames "my_vm1",testvm55
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

    .EXAMPLE
    Get-VM | get-vmcreationdate | Sort-Object -Property CreatedTime -Descending | ft
     
    .Parameter VMnames
 
    This parameter should contain virtual machine objects or strings that represents vm
    names. It is possible to feed this function wiith VM objects that come from get-vm or
    from get-view. 
 
 
   .Notes
 
    NAME:  Get-VMCreationdate
 
    AUTHOR: Grzegorz Kulikowski
 
    LASTEDIT: 27/11/2012
     
    NOT WORKING ? #powercli @ irc.freenode.net 
 
   .Link
 
    https://psvmware.wordpress.com
 
 #>
  
param(
[Parameter(ValueFromPipeline=$true,Mandatory = $true)]
[ValidateNotNullOrEmpty()] 
[Object[]]$VMnames
)
process {
foreach ($vm in $VMnames){
$ReportedVM = ""|Select VMname,CreatedTime,CreatedMonth,CreationMethod,Creator
if ($CollectedEvent=$vm|Get-VMEvents -types 'VmBeingDeployedEvent','VmRegisteredEvent','VmClonedEvent','VmBeingCreatedEvent' -ErrorAction SilentlyContinue)
    {
    if($CollectedEvent.gettype().isArray){$CollectedEvent=$CollectedEvent|?{$_ -is [vmware.vim.VmRegisteredEvent]}}
    $CollectedEventType=$CollectedEvent.gettype().name
    $CollectedEventMonth = "{0:MMMM}" -f $CollectedEvent.CreatedTime
    $CollectedEventCreationDate=$CollectedEvent.CreatedTime
    $CollectedEventCreator=$CollectedEvent.Username
        switch ($CollectedEventType)
        {
        'VmClonedEvent' {$CreationMethod = 'Cloned'} 
        'VmRegisteredEvent' {$CreationMethod = 'RegisteredFromVMX'} 
        'VmBeingDeployedEvent' {$CreationMethod = 'VmFromTemplate'}
        'VmBeingCreatedEvent'  {$CreationMethod = 'NewVM'}
        default {$CreationMethod='Error'}
        }
    $ReportedVM.VMname=$CollectedEvent.vm.Name
    $ReportedVM.CreatedTime=$CollectedEventCreationDate
    $ReportedVM.CreatedMonth=$CollectedEventMonth
    $ReportedVM.CreationMethod=$CreationMethod
    $ReportedVM.Creator=$CollectedEventCreator
    }else {
        if ($?) {
            if($vm -is [VMware.Vim.VirtualMachine]){$ReportedVM.VMname=$vm.name} else {$ReportedVM.VMname=$vm.ToString()}
            $ReportedVM.CreatedTime = ''
            $ReportedVM.CreatedMonth = ''
            $ReportedVM.CreationMethod = ''
            $ReportedVM.Creator = ''
             
        } else {
            $ReportedVM = $null
            Write-Warning "$VM could not be found, typo?"
        }
    }
    $ReportedVM
}
}
}
