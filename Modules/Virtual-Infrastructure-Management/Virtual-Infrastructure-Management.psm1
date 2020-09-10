$global:thisModuleName="Virtual-Infrastructure-Management"


#Laden Der VMWare Power CLI
<#
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
    . "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}
#>

#VMWare.PowerCLI sicherstellen
#Über das Manifest geht das nicht, da es von einer anderen Gallery kommt
Import-Module VMware.VimAutomation.Core
$result=Get-Module VMware.VimAutomation.Core
if($result -eq $null){
    Write-Host -ForegroundColor Yellow "Es scheint so als wäre VMWare.PowerCLI nicht installiert."
    Write-Host -ForegroundColor Yellow "Ich kann das Modul jetzt automatisch für deinen User installieren."
    Write-Host -ForegroundColor Yellow "Wenn du das Modul für das gesamte System installieren willst, dann mach"
    Write-Host -ForegroundColor Yellow "das manuell in einer 'Administrator' Powershell."
    $input=Read-Host -Prompt 'VMWare.PowerCLI Jetzt für diesen User installieren? (Y/N)'

    if($input -match '^([yY](es)*)$'){
        Install-Module -Name VMware.PowerCLI -Scope CurrentUser -AllowClobber
    }
    else{
        Write-Error("VMware.PowerCLI wird für die Verwendung von Virtual-Infrastructure-Management benötigt.`r`nBitte installieren: https://www.powershellgallery.com/packages/VMware.PowerCLI")
    }

}



#'HTML-Formatting', 'MailMessageAdvanced'


#Ermittlung wo dieses Modul liegt
if($PSScriptRoot -eq ""){
    $ModuleHome=$env:USERPROFILE + "\Documents\WindowsPowershell\Modules\" + $global:thisModuleName
}
else{
    $ModuleHome=$PSScriptRoot
}


<#
VMWare Virtual-Infrastructure-Management
Funktionen mit denen eine VMWare Umgebung schneller, besser gemanaged werden kann


PREREQUISITES
*https://www.powershellgallery.com/packages/VMware.PowerCLI


//XXX Todo
* VIM.DeleteMarkerDate -> Wann wurde die VM zum löschen markiert
* Abgelaufene VMs automatisch herunterfahren

#>

$global:mail_smtp_server="exchange.megatech.local"
$global:mail_sender="virtual-infrastructure-management@megatech-communication.de"
#//XXX ToDO in Zukunft durch $global:vim_ad_admingroup E-Mail-Addressen ersetzen
$global:mail_default_recipient="rudolf.achter@megatech-communication.de"


$global:vim_custom_attributes =     @(
                                   #@{  "Name" = "Ansprechpartner";       "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.DateCreated";                "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.DateUsedUntil";              "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.CreationMethod";             "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.CreationUser";               "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.ArchiveOrigDatastore";      "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.ArchiveDateArchived";       "TargetType" = @("VMHost", "VirtualMachine")}
                                    @{  "Name" = "VIM.ArchiveOrigFolderPath";       "TargetType" = @("VMHost", "VirtualMachine")}
                                    )
<#
$global:vim_tags
Tag Kategorien die für alle VMs benötigt werden
ACHTUNG nur für die virtuellen Maschinen selbst
#>
$global:vim_tags = @(
                        "Ansprechpartner"
                        "Creator"
                        "Applikation"
                        "Stage"
                        "Kunde"
                        "Backup Plan"
                    )


$global:vim_VM_DaysToUsedUntil=30

<#
$global:vim_ad_domain
    Mit dieser Active Directory Domain wird gearbeitet
#>
$global:vim_ad_domain="MEGATECH.LOCAL"

<#
    $global:vim_ad_groups
    Die User in dieser Gruppe
        * Werden als Ansprechpartner und Creator Sychronisiert (VIM-Sync-Contacts)
        * Email-Addressen der AD-User werden als Kontaktaddressen verwendet
#>
$global:vim_ad_groups=@("VMWare-MainUsers","VMWare-Administrators", "VMware-VmrcUsers.GG")


<#
    $global:vim_ad_admingroup
    User dieser AD-Gruppe sind Admnistratoren der vCenter Umgebung
    Diese werden:
        * Benachrichtigt wenn sonst kein Ansprechpartner für einen Task verfügbar ist
        * Als Standard Ansprechpartner für das vCenter Backup eingetragen
#>
$global:vim_ad_admingroup="VMWare-Administrators"
$global:vim_ad_usergroup="VMWare-MainUsers"

<#
vim_archive_*_role
    Diese Rollen werden verwendet um das starten von archivierten VMs zu verhindern
    Siehe Function VIM-Archive-VM-EndOfLife
#>
$global:vim_archive_admin_role="Administrator NoStart"
$global:vim_archive_user_role="Virtual Machine Deployer NoStart"

<#
    $global:vim_backup_path
    Pfad in den alle Backups gesichert werden
#>
$global:vim_backup_path="\\deslnsrvbackup\Image\VMWare"

<#
    $global:vim_focus
    Manchmal will ich immer mit einem bestimmten Host, Datastore, Netzwerk usw arbeiten
    Das wird in dieser Hashtable gespeichert
#>
$global:vim_focus =@{
    VMHost=$null;
    Datastore=$null;
    Network=$null;
    Folder=$null;
    VM=$null;
}

<#
Progress IDs für Write-Progess
#>
$global:progress_vm_count=1
$global:progress_cur_action=2


#Types Beginn##############################################
Add-Type -AssemblyName System.Web


#Types Ende################################################


#Zusätzliche Module laden
. ($ModuleHome + "\include\" + "02 Snapshot Information.ps1")
. ($ModuleHome + "\include\" + "VMWare-vSphere-Replication.ps1")
. ($ModuleHome + "\include\" + "VMWare_PowerCLI_Addons.ps1")






#VIMArgumentCompleters Argument Completers allgemein für das gesamte Infrastructure Management
Set-Variable -Name "VimArgumentCompleters" -Scope global `
    -Description "Argument Completers für Virtual-Infrastructure-Management" `
    -Value @{ #Alle Argument Completer Kommen in diese Hashtable
        VMHost={#ScriptBlock <- Das ist einfach nur ein Kommentar. Ein Scriptblock wird einfach mit "{" eingeleitet
            <#
            $Command            Command bei dem wir gerade sind
            $Parameter          Parameter bei dem wir gerade sind
            $WordToComplete     Das Wort das der User gerade schreibt (als er auf TAB gedrückt hat)
            $CommandAst         Ich weiß es jedes mal wieder nicht -> einfach testen
            $FakeBoundParams    Hash Table von Parameter die bisher schon angegeben wurden
                                z.B. für so was:
                                Parameter "Datastore" wurde schon angegeben
                                Liefere mir NUR die VMs zurück auf die auf "Datastore" liegen
            #>                               
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            Get-VMHost -Name ("*"+$WordToComplete+"*") | ForEach-Object {('"'+$_+'"')}
        }
        VM={#ScriptBlock
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            Get-VM -Name ("*"+$WordToComplete+"*") | ForEach-Object {('"'+$_+'"')}
        }
        Datastore={#ScriptBlock
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            Get-Datastore -Name ("*"+$WordToComplete+"*") | ForEach-Object {('"'+$_+'"')}
        }
        TagName={#ScriptBlock
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            (Get-Tag -Name ("*"+$WordToComplete+"*")).Name | ForEach-Object {('"'+$_+'"')}
        }
        TagCategory={#ScriptBlock
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            (Get-TagCategory -Name ("*"+$WordToComplete+"*")).Name | ForEach-Object {('"'+$_+'"')}
        }
        #//XXX ToDo Der Network Script Block funktioniert besser. Der Fall EmptyString "" muss gesondert
        #behandelt werden. Das hier noch bei den anderen ArgumentCompleters ergänzen
        Network={#ScriptBlock
            param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            if($WordToComplete -eq ""){
                (Get-Network).Name
            }
            else{
                (Get-Network -Name ("*"+$WordToComplete+"*")).Name | ForEach-Object {('"'+$_+'"')}
            }
        }
    }
#    -Option Constant `
    


#Default Verhalten
#Immer nur mit EINEM Server verbinden
Set-PowerCLIConfiguration -Scope User -DefaultVIServerMode Single -Confirm:$false
#SSL Zertifikate ignorieren
Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction Ignore -Confirm:$false
#Customer Experience Improvement Program
Set-PowerCLIConfiguration -Scope User -ParticipateInCeip $false -Confirm:$false

function Connect-VI{
	[CmdletBinding()]
    param(
        [Alias("Server")]
		[parameter(Mandatory=$true)] $vi,
        [string]$User="",
        [string]$Password=""


    )

    Write-Host "Virtual Infrastructure Management Connecting to:" $vi

    if($User -eq "" -and $Password -eq ""){
	    Connect-VIServer $vi
    }
    else{
        Connect-VIServer -Server $vi -User $User -Password $Password
    }
}



Function Set-DatastoreFocus {
    [cmdletBinding()]
    param($Datastore)

    if($Datastore.GetType().Name -eq "String"){
        if($ds=Get-Datastore $Datastore){
            $global:vim_focus.Datastore = $ds
        }
        else{
            Write-Error "Datastore '$Datastore' nicht gefunden"
        }
    }
    elseif($Datastore.GetType().Name -eq "VmfsDatastoreImpl"){
        $global:vim_focus.Datastore=$Datastore
    }
    else{
        Write-Error "Datastore Focus konnte nicht gesetzt werden. Es wurde kein gültiger Datastore übergeben. Es darf nur ein einzelnes Objekt als Focus gesetzt werden (keine Liste)"
    }

}

Function Set-NetworkFocus {
    [cmdletBinding()]
    param($Network)

    if($Network.GetType().Name -eq "String"){
        if($nw=Get-Network $Network){
            $global:vim_focus.Network =$nw.Name
        }
        else{
            Write-Error "Netzwerk '$Network' nicht gefunden"
        }
    }
    elseif($Network.GetType().Name -eq "PSCustomObject"){
        $global:vim_focus.Network=$Network.Name
    }

}

Function Set-FolderFocus {
    [cmdletBinding()]
    param($Folder)

    if($Folder.GetType().Name -eq "String"){
        if($fld=Get-Folder $Folder){
            if($fld.Count -eq 1){
                $global:vim_focus.Network=$fld
            }
            else{
                Write-Error "Folder '$Folder' ist nicht eindeutig"
            }
        }
        else {
            Write-Error "Folder '$Folder' nicht gefunden"
        }
    }
    elseif($Folder.GetType().Name -eq "FolderImpl"){
        $global:vim_focus.Folder=$Folder
    }
    else{
        Write-Error "Folder Focus konnte nicht gesetzt werden. Folder ist nicht eindeutig bzw wurde eine Liste übergeben?"
    }
}

Function Set-VMFocus {
    [cmdletBinding()]
    param($VM)

    if($VM.GetType().Name -eq "String"){
        if($o_vm=Get-VM $VM){
            if($o_vm.Count -eq 1){
                $global:vim_focus.VM=$o_vm
            }
            else{
                Write-Error "VM '$VM' ist nicht eindeutig"
            }
        }
        else{
            Write-Error "VM '$VM' nicht gefunden"
        }
    }
    elseif($VM.GetType().Name -eq "UniversalVirtualMachineImpl"){
        $global:vim_focus.VM=$VM
    }
    else{
        Write-Error "VM Focus konnte nicht gesetzt werden. VM ist nicht eindeutig, oder wurde eine Liste übergeben?"
    }
}

Function Set-VMHostFocus {
    [cmdletBinding()]
    param($VMHost)

    if($VMHost.GetType().Name -eq "String"){
        if($o_host=Get-VMHost $VMHost){
            if($o_host.Count -eq 1){
                $global:vim_focus.VMHost=$o_host
            }
            else{
                Write-Error "VMHost '$VMHost' ist nicht eindeutig"
            }
        }
        else{
            Write-Error "VMHost '$VMHost' nicht gefunden"
        }
    }
    elseif($VMHost.GetType().Name -eq "VMHostImpl"){
        $global:vim_focus.VMHost=$VMHost
    }
    else{
        Write-Error "VMHost Focus konnte nicht gesetzt werden. VMHost ist nicht eindeutig, oder wurde eine Liste übergeben?"
    }
}

Function Set-VIMFocus {
    [cmdletBinding()]
    param(
        $VMHost=$null,
        $VM=$null,
        $Folder=$null,
        $Network=$null,
        $Datastore=$null
    )

    if($VMHost -ne $null)    {Set-VMHostFocus    -VMHost $VMHost}
    if($VM -ne $null)        {Set-VMFocus        -VM $VM}
    if($Folder -ne $null)    {Set-FolderFocus    -Folder $Folder}
    if($Network -ne $null)   {Set-NetworkFocus   -Network $Network}
    if($Datastore -ne $null) {Set-DatastoreFocus -Datastore $Datastore}

}

Function Get-VIMFocus{
    [cmdletBinding()]
    param()

    $global:vim_focus
}


Function VIM-Get-VM-without-Contact {

<#
.SYNOPSIS

	Sucht virtuelle Maschinen bei denen kein Ansprechpartner Tag gesetzt ist und gibt diese zurück
.DESCRIPTION

	Das Script ruft mit Get-VM alle virtuelle Maschinen im verbunden vCenter ab. Bei den virtuellen Maschinen
	werden die TagAssignments der Kategorie "Ansprechpartner" abgerufen. Wenn weniger als ein Ansprechpartner
	gesetzt ist, so wird die virtuelle Maschinen ausgegeben
.PARAMETER none

Example Example
.PARAMETER none

	Provide a PARAMETER section for each parameter that your script or function accepts.
.EXAMPLE

	VIM-Get-VM-wihtout-Contact
.EXAMPLE

	VIM-Get-VM-wihtout-Contact | Out-Grid

.EXAMPLE

	VIM-Get-VM-wihtout-Contact | Out-Grid
.LINK
	http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-without-Contact
#>


    Get-VM | ForEach-Object {
        $tagass=$_ | Get-TagAssignment -Category "Ansprechpartner"
        if($tagass.Count -lt 1){
            #Das hier ist eine VM ohne Ansprechpartner
            $_
        }
    }
}

Function VIM-Show-VM-without-Contact {
    VIM-Get-VM-without-Contact | VIM-Check-Tags |
        Format-Table @{Expression={$_.Name};Label="Name";Width=30},
            @{Expression={$_.Stage};Label="Stage";Width=15},
            @{Expression={$_.Applikation};Label="Applikation";Width=30},
            @{Expression={$_.Ansprechpartner};Label="Ansprechpartner";Width=40},
            @{Expression={$_.MissingTags};Label="MissingTags";Width=80}
}

Function VIM-Get-ContactAssignment {
<#
.SYNOPSIS

    Zeigt Ansprechpartner einer VM an
.DESCRIPTION

    Zeigt Ansprechpartner einer VM an

    geplante Kategorien:

    Wichtige Tags:
        Tags werden auf ESX-HOST Objekte zugewiesen
        Category: Ansprechpartner         Tag:*                       Ansprechpartner. Beschreibung des Ansprechpartners ist die E-Mail-Addresse
        Category: Creator                 Tag:*                       Ersteller der VM. Beschreibung des Ansprechpartners ist die E-Mail-Addresse

.PARAMETER VM
    Virtuelle Maschine als Objekt oder String

.EXAMPLE
    VIM-Get-ContactAssignment "deslnclivisio2k16"
.EXAMPLE
    VIM-Get-ContactAssignment (Get-VM deslnclivisio2k16)
.EXAMPLE
    Get-VM "deslnclivisio2k16" | VIM-Get-ContactAssignment
.EXAMPLE
    VIM-Get-ContactAssignment -VM deslnclivisio2k16 -Category Creator
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-ContactAssignment

#>

    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [ValidateSet("Ansprechpartner","Creator")] $Category="Ansprechpartner"
    )
    Begin {}
    
    Process {

        $VM | ForEach-Object {
                #Wenn ein String angegeben wurde hol ich mir die VM mit dem Namen
                $item=Get-VM $_
                $item | Get-TagAssignment -Category $Category
            }
        }

    End {}
}


Function VIM-Get-ContactTag {
<#
.SYNOPSIS

    Liefert den Tag eines Ansprechpartners
.DESCRIPTION

    Liefert den Tag eines Ansprechpartners
    Hauptsächlich zur internen Verwendung im Virtual-Infrastructure-Management Modul
    Vielleicht aber auch als Standalone Cmdlet nützlich

    Die Display Names sehen im Active Directory ja so aus:
    Achter, Rudolf

    Die Tags in vCenter heissen z.B. so

    Achter, Rudolf; Ansprechpartner
    Achter, Rudolf; Creator

    Dieses Cmdlet vereinfacht hierzu einfach die Handhabung
#>
    param(
        $Name,

        [ValidateSet("Ansprechpartner","Creator","All")] $Category="Ansprechpartner"
    )

    Begin {}

    Process {}

    End {
        if($Category="All"){
            ForEach($Category in @("Ansprechpartner","Creator")){
                Get-Tag -Name $($Name + "; " + $Category) -Category $Category
            }
        }
        else{
            Get-Tag -Name $($Name + "; " + $Category) -Category $Category
        }
    }
    
}

Function VIM-Create-CustomAttributes {
<#
.SYNOPSIS
    Erstellt die CustomAttributes die für Virtual-Infrastructure-Management benötigt werden.
    Wenn Die CustomAttributes bereits vorhanden sind, werden sie kein zweites Mal angelegt
.EXAMPLE
    VIM-Create-CustomAttributes
.EXAMPLE
    VIM-Create-CustomAttributes
    VIM-Copy-TagStructure -oldVCenter oldvcenter.domain.local -newVCenter newvcenter.domain.local
#>
        $a_catt = $global:vim_custom_attributes


        ForEach ($att in $a_catt) {
            if(-not (Get-CustomAttribute -Name $att.Name -ErrorAction SilentlyContinue)) {
                New-CustomAttribute -Name $att.Name -TargetType $att.TargetType
            }
        }

}


Function VIM-Set-VMValue {
<#
.SYNOPSIS

	Setzt benutzerbefinierte Werte als Annotations in VMs
.DESCRIPTION

    Setzt benutzerbefinierte Werte als Annotations in VMs
.EXAMPLE
    VIM-Set-VMValue -VM $vm -DateUsedUntil "2017-01-01" | Get-Annotation
#>
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    $DateCreated="",

    $DateUsedUntil="",

    [string]$CreationMethod="",

    [string]$CreationUser="",

    [string]$ArchiveOrigDatastore="",

    [string]$ArchiveDateArchived="",

    [string]$ArchiveOrigFolderPath=""

    )
    
    Begin {
        #Sicherstellen, dass es die Attribute gibt die wir benötigen
        <#
            //XXX kann man später (bei Performance Problemen) vielleicht so erweitern, dass nur die benötigten
            Custom-Attributes geprüft werden:

            z.B:
            $a_catt | ?{$_.Name -eq "VIM.DateCreated"}

            Dann immer nur das eine (oder die paar benötigten) CustomAttribute ergänzen

        #>
        #VIM-Create-CustomAttributes
    }

    Process {
        $VM | ForEach-Object {
            $o_vm=$_
            <#
            if(-not $DateCreated        -eq "") { $o_vm | Set-Annotation -CustomAttribute "VIM.DateCreated"        -Value $DateCreated   }
            if(-not $DateUsedUntil      -eq "") { $o_vm | Set-Annotation -CustomAttribute "VIM.DateUsedUntil"      -Value $DateUsedUntil }
            if(-not $CreationMethod     -eq "") { $o_vm | Set-Annotation -CustomAttribute "VIM.CreationMethod"     -Value $CreationMethod }
            if(-not $CreationUser       -eq "") { $o_vm | Set-Annotation -CustomAttribute "VIM.CreationUser"       -Value $CreationUser }
            #>
            if(-not $DateCreated        -eq "") { 
                Try{
                    $s_DateCreated=Get-Date -format "yyyy-MM-dd HH:mm" $DateCreated
                    $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.DateCreated"        -Value $s_DateCreated
                } Catch {
                    Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                }   
            }
            if(-not $DateUsedUntil      -eq "") { 
                Try{
                    $s_DateUsedUntil=Get-Date -format "yyyy-MM-dd HH:mm" $DateUsedUntil
                    $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.DateUsedUntil"      -Value $s_DateUsedUntil 
                } Catch{
                    Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                }
            
            }
            if(-not $CreationMethod       -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.CreationMethod"       -Value $CreationMethod }
            if(-not $CreationUser         -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.CreationUser"         -Value $CreationUser }
            if(-not $ArchiveOrigDatastore -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.ArchiveOrigDatastore" -Value $ArchiveOrigDatastore}
            if(-not $ArchiveDateArchived  -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.ArchiveDateArchived"  -Value $ArchiveDateArchived}
            if(-not $ArchiveOrigFolderPath -eq ""){ $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.ArchiveOrigFolderPath"  -Value $ArchiveOrigFolderPath}
            $o_vm
        }
    }

    End {}
}

Set-Alias -Name "VIM-Set-Value" -Value "VIM-Set-VMValue"

Function VIM-Get-VMValue {
<#
.SYNOPSIS
    Holt alle für VMWare Infrastruktur Relevanten Werte
.DESCRIPTION
    ALLE Added Properties siehe im Modul-Script: 
    - $global:vim_tags
    - $global:vim_custom_attributes

    Added Properties:

                         Name                   Typ
                         ------------           -----------
                         missingTags            Array
                         Ansprechpartner        String
                         Applikation            String
                         Stage                  String
                         VIM.DateCreated        String
                         VIM.DateUsedUntil      String
                         VIM.CreationMethod     String

.EXAMPLE
    Get-VM | VIM-Get-VMValue | Select Name,Ansprechpartner,Applikation,Stage,VIM.DateCreated,VIM.DateUsedUntil | Out-GridView
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VMValue

#>

    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [Switch]$StageByFolder
    )
    
    Begin {
        $a_vm=@()
    }

    Process {
        $VM | ForEach-Object {
            $a_vm+=$_
        }
    }

    End {
        $i=0

        $a_vm | ForEach-Object{

            $percent=$i / $a_vm.Count * 100
            Write-Progress -Activity "Collecting VM Information" -Status ("VM " + $i + " of " + $a_vm.Count) -PercentComplete $percent

            $o_vm=$_

            if($o_vm.GetType().Name -eq "String")
            {
                $o_vm = Get-VM ($_ -replace '/','%2f')
            }

            #Tags zum Objekt als Noteproperty hinzufügen
            if($StageByFolder){
                $o_vm = VIM-Check-Tags -VM $o_vm -StageByFolder 
            }
            else {
                #$o_vm = VIM-Check-Tags -VM $o_vm
                $a_tagass=Get-TagAssignment -Entity $o_vm
                $a_missing_tags=@()
                ForEach($category in $global:vim_tags){
                    #$cat=$_

                    $tags=$a_tagass | ?{$_.Tag.Category.Name -eq $category}

                    $a_vals=@()
                    if($tags.Count -eq 0){
                        $a_missing_tags+=$category
                    }
                    else{
                        ForEach($tag in $tags){
                            $a_vals+=$tag.Tag.Name
                        }
                    }
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $category -Value $a_vals -Force
                }
                Add-Member -InputObject $o_vm -MemberType NoteProperty -Name missingTags -Value $a_missing_tags -Force
            }

            
            #Annotations zum Objekt als Noteproperty hinzufügen
            #//XXX hier weiter
            $a_annotations=Get-Annotation -Entity $o_vm

            ForEach ($att in $global:vim_custom_attributes){
                #Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $att.Name -Value (Get-Annotation -Entity $o_vm -Name $att.Name).Value -Force
                Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $att.Name -Value (($a_annotations | ?{$_.Name -eq $att.Name}).Value) -Force
            }


            #Ausgabe
            $o_vm
            #Zählen
            $i++
        }
    }
        
}



Function VIM-Show-VMValue {
<#
.SYNOPSIS
    Zeigt für Virtual Infrastructure Management Relevante Werte an
.DESCRIPTION
    Nützlich um sich einen Überblick über die aktuellen VMs zu verschaffen
.NOTES
    Dieses CMDlet Script zeigt den Idealen Einsatz für eine Progress Bar (Statusanzeige, Fortschrittsbalken)
    Anhand dieses Beispiel kann ich vielleicht die anderen CMDlets umschreiben
.PARAMETER columns
    
.EXAMPLE
    VIM-Show-VMValue (Get-VM)
.EXAMPLE
    VIM-Show-VMValue (Get-VM) -Grid
.EXAMPLE
    Get-Folder "Live" | Get-Folder "TK-Anlage" | Get-VM | VIM-Show-VMValue -Grid
.EXAMPLE
    VIM-Get-VMEndOfLife | VIM-Show-VMValue -Grid
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Show-VMValue
#>
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    #Das können mehrere Parameter werden je nachdem wie ichs z.B. exportieren will

    [Switch]$Grid,

    $columns=""
    )
    
    Begin {
        Write-Verbose ( "Columns BaseType:" + ($columns.GetType()).BaseType)

        if([string]($columns.GetType()).BaseType -eq "array"){
            Write-Verbose "VIM-Show-Value Using columns $columns"
        }
        else {
            $columns = @("Name")
            $columns += $global:vim_custom_attributes.Name
            $columns += $global:vim_tags
            $columns += @("missingTags")
        }
        
        #BEACHTE das unterschiedliche Verhalten von Pipe und Parameter!
        #Parameter: $VM wird als Array übergeben und ForEach-Object wird entsprechend oft ausgeführt
        #Pipe: $VM wird zerlegt und "Process" wird entsprechend oft ausgeführt
        $p_vm = @()
        $a_vm = @()
        $i=0
    }

    Process {
        #$VM | Measure-Object
        
        $VM | ForEach-Object {
            $p_vm += $_
        }
    }

    End {
        if($Grid){
            $p_vm | VIM-Get-VMValue | Select $columns | Out-GridView
        }
        else{
            $p_vm | VIM-Get-VMValue | Format-Table $columns -AutoSize
        }
    }
        
}


Function VIM-Set-UsageTime {
<#
.SYNOPSIS
    Setzt "VIM.DateUsedUntil" Ab Heute + n
.DESCRIPTION
    Dieses CMDlet nimmt den heutigen Tag und addiert n Tage, Monate, Jahre
    je nach Auswahl
.PARAMETER VM
    Virtuelle Maschine
.PARAMETER Unit
    "Day"     +n Tage ab Heute
    "Month"   +n Monate ab Heute
    "Year"    +n Jahre ab Heute
.PARAMETER Value
    n=$Value
    So Viele Tage, Monate, Jahre (je nach Unit) werden ab Heute addiert
.EXAMPLE
    Get-VM deslnsrvfile01 | VIM-Set-UsageTime 100 Day | VIM-Show-VMValue
    #Setzt "DateUsedUntil" 100 Tage in die Zukunft ab heute
    #Und zeigt auch gleich das Ergebnis an
.EXAMPLE
    Get-VM "*faxtest03*" | VIM-Set-UsageTime -Unit Month -Value 3 | VIM-Show-VMValue
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Set-UsageTime
#>

    param(
    [Parameter( 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [Parameter(Position=0)]
    [int]$Value,
        
    [Parameter(Position=1)]
    [string]
    [ValidateSet("Day","Month","Year")]
    $Unit

    )

    Begin {
        Switch($Unit){
            "Day" {
                $date=(Get-Date).AddDays($Value)
                break;
            }
            "Month" {
                $date=(Get-Date).AddMonths($Value)
                break;
            }
            "Year" {
                $date=(Get-Date).AddYears($Value)
                break;
            }
                
        }
    }

    Process {
        $VM | ForEach-Object {
            VIM-Set-VMValue -VM $_ -DateUsedUntil $date
        }
    }

    End {}
}

Function VIM-Annotation {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,
    [Parameter(Position=1)] $Attribute,
    [Parameter(Position=2)] $Value
    )
    
    Begin {}

    Process {
        $VM | ForEach-Object {
            $o_vm=$_
            $o_annotation=$o_vm | Set-Annotation -CustomAttribute $Attribute -Value $Value
            Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $Attribute -Value $Value -Force
            $o_vm
        }
    }

    End {}
        
}

Function VIM-Set-CreationByEvent {
<#
.SYNOPSIS
    Durchsucht Events nach VM Creation Events und setzt entsprechend die Attributes

.DESCRIPTION

.PARAMETER VM
    Virtuelle Maschine für die das CreationDate ermittelt wird

.PARAMETER CreationDateAlternative
    Wenn kein Event für ein CreationDate gefunden wird, dann dieses Datum als Alternative verwenden
.EXAMPLE
    $result=Get-VM | VIM-Set-CreationByEvent
    $result | VIM-Show-VMValue
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Set-CreationByEvent
#>

    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [string] $CreationDateAlternative
    )

    Begin {}

    Process {
        $VM | ForEach-Object {
            $o_vm = $_

            $vm_result=""

            #Nur Leere DateCreated Updaten
            if(($o_vm | Get-Annotation | ? -Property Name -EQ "VIM.DateCreated").Value -eq "" ){

                #RAC: Get-VMCreationEvent ist MEINE Funktion und nicht mehr die "Raubkopierte"
                $o_vm | Get-VMCreationEvent | ForEach-Object {
                    #$_

                    if($_.CreatedTime -ne "")
                    {
                        $s_timecreated = [string]($_.CreatedTime | Get-Date -format "yyyy-MM-dd HH:mm")
                        $s_creationmethod = [string]($_.CreationMethod)
                        $s_creationuser = [string]($_.Creator)
                        $vm_result=VIM-Set-VMValue -VM $o_vm -DateCreated $s_timecreated -CreationMethod $s_creationmethod -CreationUser $s_creationuser
                    }
                    elseif($CreationDateAlternative -ne "")
                    {
                        $s_timecreated = [string](Get-Date $CreationDateAlternative -format "yyyy-MM-dd HH:mm")
                        $s_creationmethod = "Unknown"
                        $s_creationuser = "Unknown"
                        $vm_result=VIM-Set-VMValue -VM $o_vm -DateCreated $s_timecreated -CreationMethod $s_creationmethod -CreationUser $s_creationuser
                    }


                }

            }

            #Wer noch keinen Creator hat
            #User im AD-Suchen und entsprechend richtigen Tag setzen
            if( -not $($o_vm | Get-TagAssignment -Category Creator -ErrorAction SilentlyContinue)){
                Write-Verbose $([string]$o_vm.Name + " Creator wird gesetzt")
                $s_VIMCreationUser=$($vm | Get-Annotation -Name VIM.CreationUser).Value
                Try {
                    $o_aduser = $s_VIMCreationUser | 
                        %{$($_ | Select-String -Pattern "(.*)\\(.*)").Matches.Groups[2].Value} | 
                        Get-ADUser -ErrorAction Stop

                    Write-Verbose $("VIM.CreationUser: "+ [string]$s_VIMCreationUser + " -> AD-User" + "DistinguishedName: " + [string]$o_aduser.DistinguishedName)

                    Try {
                        $user_tag_name=$o_aduser.Name + "; Creator"
                        $tag=Get-Tag -Category "Creator" -Name $user_tag_name -ErrorAction Stop
                        Write-Verbose $("Tag ->" + [string]$tag)
                        
                        #Endgueltiges Setzen des Tags
                        $tagass=New-TagAssignment -Entity $o_vm -Tag $tag
                        #Zurueckgeben der VM (zwecks Performance ohne VMValues)
                        $vm_result=VIM-Get-VMValue -VM $o_vm
                    }
                    Catch {
                        Write-Host $("AD-User Name: '" + $user_tag_name + "': Creator Tag wurde nicht gefunden")
                        Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                    }
                }
                Catch {
                    Write-Host $("VIM.CreationUser:'" + $s_VIMCreationUser + "': AD-User wurde nicht gefunden")
                    Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                }
            }
            else {
                Write-Verbose $([string]$o_vm + ": Creator wird NICHT gesetzt")
            }

            if($vm_result -ne ""){
                $vm_result
            }
        }
    }

    End {}

}

#Function Get-VMFolder-ToRoot {
Function VIM-Get-Folder-ToRoot {
<#
.SYNOPSIS
    Gibt alle Folder ab der VM aufwärts zurück
#>
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

    Begin {}

    Process {
        $VM | ForEach-Object {
            $o_folder=Get-Folder -Id ($_ | Get-View).Parent
            $o_folder
            if ($o_folder.Name -ne "vm"){
                Get-VMFolder-ToRoot $o_folder
                
            }
        }
    }

    End {}
}

Set-Alias -Name Get-VMFolder-ToRoot -Value VIM-Get-Folder-ToRoot


Function Get-VMFolderPath {
<#
.SYNOPSIS
    Liefert die VM zurück mit dem gesamten VMFolder Path
.DESCRIPTION
    Dieses CMDlet verfolgt die VMFolders zurück über "Parent"
    bis zum VMFolder "root". 
.PARAMETER VM
    Virtuelle Maschin die um den VMFolder Path ergänzt werden soll
#>
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
            $o_vm=$_

            $s_path=""
            $i=0

            #Wir lösen den VMFolder Pfad der VM Rückwärts auf und setzen
            #so einen String zusammen
            $o_vm | VIM-Get-Folder-ToRoot | Select-Object -SkipLast 1 | ForEach-Object {
                $o_folder=$_
                if($i -gt 0){
                    $s_path="/"+$s_path
                }
                $s_path=$o_folder.Name + $s_path
                $i++
            }

            #$s_path

            $o_vm | Add-Member -MemberType NoteProperty -Name VMFolderPath -Value $s_path

            #Ausgabe
            $o_vm

        }
    }

    End{}

}


Function Get-VMRootFolder {
<#
.SYNOPSIS
    Gibt Folder der obersten Ebene zu einer VM zurück
#>

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

    Begin {}

    Process {
        $VM | ForEach-Object {
            $o_folder=Get-Folder -Id ($_ | Get-View).Parent
            #$o_folder
            if ($o_folder.Name -eq "vm"){
                $_ 
            }
            else {
                Get-VMRootFolder $o_folder
            }

        }
    }

    End {}
}

Function VIM-Check-Tags {
<#
.SYNOPSIS 
    Prüft Ob mindest benötigte Tags einer VM gesetzt sind bzw versucht zu korrigieren
.DESCRIPTION
    Es wird auf für Virtal-Infrastructure Management aktuell mindest benötigte Tags geprüft.
    Das VM Objekt wird um das Property "missingTags" ergänzt. Das ist ein Array mit aktuell
    fehlenden Tags
    
    ALLE Added Properties siehe im Script: $global:vim_tags

                         Name              Typ
                         ------------      -----------
    Added-Property:      missingTags       Array
    Added-Property:      Ansprechpartner   String
    Added-Property:      Applikation       String
    Added-Property:      Stage             String
.PARAMETER VM
    Virtuelle Maschine

.PARAMETER StageByFolder
    Sollte keine "Stage" gesetzt sein, wird die "Stage" anhand des Ersten Folders
    gesetzt das unterhalb des Datacenters kommt (Root Folder)
    Also:
    vcenter
    |
    |-- megatech.local
        |
        |-- Development 
        |-- Live          <-- Die ganz oben im Baum sind entscheidend
        |-- Test
           |
           |-- Bla1
           |-- Bla2
     
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Check-Tags
#>

    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [switch]$StageByFolder

    )

    Begin {
        $a_needed_tag_category = $global:vim_tags

        $stages=Get-Tag -Category "Stage"

    }

    Process {
        $VM | ForEach-Object {
            $o_vm = $_
            #$o_vm

            #KORREKTUREN
            #StageByFolder
            if($StageByFolder) {
                if(-not $($o_vm | Get-TagAssignment -Category "Stage")){
                    $s_vmroot=Get-VMRootFolder $o_vm
                    if($stages.Name -contains $s_vmroot.Name){
                        Write-Verbose ("Stage wird Korrigiert auf: " + [string]$s_vmroot.Name)
                        $o_tag = Get-Tag -Category "Stage" -Name ([string]$s_vmroot.Name)
                        $tagass = $o_vm | New-TagAssignment -Tag $o_tag
                    }
                }
            }


            #KORREKTUREN ENDE

            #PRÜFUNG Start
            $a_tagass=Get-TagAssignment -Entity $o_vm
            $a_missing_tags = @()
            ForEach($category in $a_needed_tag_category){
                $tags=$false
                $tags=$a_tagass | ?{$_.Tag.Category.Name -eq $category}

                $a_vals=@()
                if($tags.Count -eq 0){
                    $a_missing_tags+=$category
                }
                else{
                    ForEach($tag in $tags){
                        $a_vals+=$tag.Tag.Name
                    }
                }
                Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $category -Value $a_vals -ErrorAction SilentlyContinue
            }
            Add-Member -InputObject $o_vm -MemberType NoteProperty -Name missingTags -Value $a_missing_tags -Force
            $o_vm
        }
    }

    End {}


}

Function VIM-Get-VM-MissingTags {
<#
.SYNOPSIS 
    Findet VMs mit fehlenden Tags
.DESCRIPTION
    Ruft VIM-Check-Tags für alle VMs und gibt die VMs zurück bei denen Tags fehlen
.PARAMETER Contact
    String oder Tag: Ansprechpartner für den VMs mit "MissingTags" gesucht werden. Wird ein Tag übergeben kann nach "Creator" oder "Ansprechpartner" unterschieden werden
.EXAMPLE
    VIM-Get-VM-MissingTags -Contact "Schneider*"
    #Zeigt VMs mit Schneider, Jens (oder alle die mit Schneider beginnen) als Ansprechpartner
.EXAMPLE
    VIM-Get-VM-MissingTags
.EXAMPLE
    $tag=Get-Tag -Category Creator -Name "Schneider*"
    VIM-Get-VM-MissingTags -Contact $tag
    #Zeigt VMs mit Schneider, Jens als Creator
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-MissingTags

#>
    param (
        $Contact = ""
    )


    if($Contact -ne ""){

        $Contact | ForEach-Object{
            $o_contact=$_

            if($o_contact.GetType().Name -ne "String")
            {
                $vm = Get-VM -Tag $Contact 
            }
            else
            {
                $tag = Get-Tag -Category "Ansprechpartner" -Name $Contact
                $vm = Get-VM -Tag $tag
            }
        }

    }
    else {
        $vm = Get-VM 
    }
    $vm | VIM-Get-VMValue | ?{$_.missingTags.Length -gt 0}
}

Function VIM-Show-VM-MissingTags {
<#
.SYNOPSIS 
    Findet VMs mit fehlenden Tags
.DESCRIPTION
    Ruft VIM-Check-Tags für alle VMs auf und Formatiert die Ausgabe
.EXAMPLE
    VIM-Get-VM-MissingTags | VIM-Show-VMValue
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Show-VM-MissingTags
#>
    param (
        $Contact = ""
    )


    VIM-Get-VM-MissingTags -Contact $Contact |
        Format-Table @{Expression={$_.Name};Label="Name";Width=30},
            @{Expression={$_.Stage};Label="Stage";Width=15},
            @{Expression={$_.Applikation};Label="Applikation";Width=30},
            @{Expression={$_.Creator};Label="Creator";Width=40},
            @{Expression={$_.Ansprechpartner};Label="Ansprechpartner";Width=40},
            @{Expression={$_.MissingTags};Label="MissingTags";Width=80}


}


Function VIM-Get-ContactsHash {
<#
.SYNOPSIS
    Liefert eine Hashtable mit allen Kontaktaddressen in der vCenter Umgebung
.DESCRIPTION
    Liefert eine Hashtable mit allen Kontaktaddressen in der vCenter Umgebung

    Die Hashtable ist wie folgt Aufgebaut

    contact1@megatech-communication.de
        Name = Name                  "Name" des Ansprechpartner Tag
        Address = E-mail-Addresse    "Description" Email-Addresse des Ansprechpartner Tags
        Data = @{}                   Eine Lere Hashtable zum Speichern von Ergebnissen für den Contact
.EXAMPLE
    $h_contacts=VIM-Get-ContactsHash
    $h_contacts.Keys | %{$h_contacts.Item($_)}
.EXAMPLE
    $h_contacts=VIM-Get-ContactsHash
    #...
    #Irgendeine Funktion befüllt $h_contacts
    #...
    #Daten von h_contacts anzeigen
    $h_contacts.Keys | %{($h_contacts.Item($_)).Data} | fl 
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-ContactsHash
.LINK
    http://stackoverflow.com/questions/9015138/powershell-looping-through-a-hash-or-using-an-array

#>
    $h_contacts=@{}
    ForEach ($t in Get-Tag -Category "Ansprechpartner"){
            
        if($t.Description -eq ""){
            Write-Host $("Bei " + $t.Name + " ist in der Description keine E-Mail-Addresse hinterlegt")
        }
        else{
            Try {
                
                If($h_contacts.($t.Description)){
                    Write-Verbose ($t.Description + " bereits im Contact Hash vorhanden. Jede E-Mail-Addresse wird nur einmal übernommen")
                }
                else{
                    $h_contacts.Add($t.Description,@{
                        Name=$t.Name;
                        Address=$t.Description;
                        Data=@();
                    })
                }
            }
            Catch{
                Write-Host $("Fehler beim Hinterlegen von " + $t.Name + " Email:" + $t.Description + "")
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
            }
        }
    }

    $h_contacts
}

Function VIM-Get-Contacts {
<#
.SYNOPSIS
    Liefert die Kontakte zu einer virtuellen Maschine

.DESCRIPTION
    Erwartet als Parameter eine virtuelle Maschine. Es werden die relevanten Ansprechparnter
    für die virtuelle Maschine zurückgegeben (ARRAY). Und das in folgender Reihenfolge:
        1. Ansprechpartner im Ansprechpartner Tag
        2. Creator wenn kein Ansprechpartner vorhanden
        3. Admins wenn kein Creator vorhanden

#>

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

    Begin {}

    Process {

        ForEach($o_vm in $VM) {

            $a_contacts=@()

            #Ansprechpartner Informieren
            if($tagass=$o_vm | Get-TagAssignment -Category "Ansprechpartner"){
                #$a_contact_email=$tagass.Tag.Description
                
                ForEach($ass in $tagass){
                    $contact = New-Object -TypeName PSObject -Property @{
                        Name    = $ass.Tag.Name;
                        Address = $ass.Tag.Description;
                    }
                    $a_contacts+=$contact
                }
            }
            #Wenn kein Ansprechpartner vorhanden dann Creator
            elseif($tagass=$o_vm | Get-TagAssignment -Category "Creator"){
                #$a_contact_email=$tagass.Tag.Description
                ForEach($ass in $tagass){
                    $contact = New-Object -TypeName PSObject -Property @{
                        Name    = $ass.Tag.Name;
                        Address = $ass.Tag.Description;
                    }
                    $a_contacts+=$contact
                }
            }
            #Wenn der nicht vorhanden dann VMWare Admins
            else {
                $adusers=Get-ADGroupMember $global:vim_ad_admingroup | Get-ADUser -Properties EmailAddress
                
                Foreach($user in $adusers){
                    $contact = New-Object -TypeName PSObject -Property @{
                        Name    = $user.DisplayName;
                        Address = $user.EmailAddress;
                    }
                    $a_contacts+=$contact
                }


            }

            $a_contacts

        }
    }

    End {}

}


Function VIM-Mail-VM-MissingTags 
{
<#
.SYNOPSIS 
    Verschickt Mails für VMs bei denen Tags fehlen
    Primär werden die Ansprechpartner angeschrieben
    Sollte ein Ansprechpartner fehlen, wird die Mail an den Creator geschickt
.DESCRIPTION
    Die Funktion marschiert durch VIM-Get-VM-MissingTags
    Inhalte der zu versendenden Mails werden in HashTables für die Empfänger summiert
    Die Empfänger werden in dieser Reihenfolge ermittelt:
        1. Ansprechpartner
        2. Creator
        3. $global:vim_ad_groups

.EXAMPLE
    VIM-Mail-VM-MissingTags
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Mail-VM-MissingTags
#>

    param(
        <#
            Ein Empfänger als String oder mehrere Empfänger als String Array.
            Standardmäßig wird diese Mail an die Ansprechpartner gesendet.
            Dieser Parameter dient als Umleitung (für Tests)
        #>
        $MailTo=""
    )


    Begin {}

    Process {}

    End {


        $h_contacts = @{}

        ForEach ($t in Get-Tag -Category "Ansprechpartner"){
            
            if($t.Description -eq ""){
                Write-Host $("Bei " + $t.Name + " ist in der Description keine E-Mail-Addresse hinterlegt")
            }
            else{
                Try {
                    $h_contacts.Add($t.Description,@())
                }
                Catch{
                    Write-Host $("Fehler beim Hinterlegen von " + $t.Name + " Email:" + $t.Description + "")
                    Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                }
            }
        }

        ForEach($o_vm in VIM-Get-VM-MissingTags) {
        #ForEach($o_vm in $vms) {
            #Ansprechpartner Informieren
            if($tagass=$o_vm | Get-TagAssignment -Category "Ansprechpartner"){
                $a_contact_email=$tagass.Tag.Description
            }
            #Wenn kein Ansprechpartner vorhanden dann Creator
            elseif($tagass=$o_vm | Get-TagAssignment -Category "Creator"){
                $a_contact_email=$tagass.Tag.Description
            }
            #Wenn der nicht vorhanden dann VMWare Admins
            else {
                $a_contact_email=$(Get-ADGroupMember $global:vim_ad_admingroup | Get-ADUser -Properties EmailAddress).EmailAddress
            }
            
            Write-Verbose $($o_vm.Name + ": " + $a_contact_email) 

            ForEach ($c in $a_contact_email) {
                $h_contacts.$c += $o_vm
            }

        }

        $h_contacts

        $h_contacts.GetEnumerator() | ForEach-Object {
            $item=$_
            #Write-Host "Test"
            #$item.Value

            if($item.Value.Length -gt 0){

                $description = "Virtuelle Maschinen bei denen Tags fehlen für : " + $item.Key +"<hr/>"
                $description += "Bitte Laut Dokumentation ergänzen <a href=""http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Deployment_Guide_f%C3%BCr_Techniker#Zuweisen_von_Tags_zu_virtuellen_Maschinen"">
                VMWare Deployment Guide f&uuml;r Techniker - Zuweisen von Tags</a>"

                #VMs für die HTML Tabellenausgabe vorbereiten
                $a_vms=@()
                ForEach($vm in $item.Value){

                    $o_vm=New-Object -TypeName PSObject -Property @{
                        Name                    =   $vm.Name;
                        Stage                   =   $vm.Stage -join ";" ;
                        "VIM.DateCreated"       =   $vm."VIM.DateCreated";
                        "VIM.DateUsedUntil"     =   $vm."VIM.DateUsedUntil";
                        MissingTags             =   $vm.MissingTags -join ";" ;
                        Description             =   $vm.Description;
                    }

                    $a_vms+=$o_vm 

                }
                
                
                #HTML vorbereiten
                $html = [string]($a_vms | Select Name,Stage,VIM.DateCreated,MissingTags | ConvertTo-Html -Fragment)
                    
                #Mail verschicken

                #-To $item.Name
                if($MailTo -ne ""){
                    $SendMailTo=$MailTo
                }
                else{
                    $SendMailTo=$item.Name
                }

                VIM-Mail -To $SendMailTo `
                        -Subject ("Virtuelle Maschinen bei denen Tags fehlen: " + $item.Key + " -- Bitte ergänzen") ` `
                        -Description $description `
                        -Html $html

                <#
                #-To $tag.Description `
                Send-MailMessage -SmtpServer $mail_smtp_server `
                                 -From "rudolf.achter@megatech-communication.de" `
                                 -To $item.Name `
                                 -Subject ("Virtuelle Maschinen bei denen Tags fehlen: " + $item.Key + " -- Bitte ergänzen") `
                                 -BodyAsHtml $html `
                                 -Encoding UTF8
                #>
            }
        }

    }

}


Function VIM-Calculate-DateUsedUntil {
<#
.SYNOPSIS
    Wenn noch nicht vorhanden. Berechnet die initiale "VIM.DateUsedUntil"
.DESCRIPTION
    Wenn noch kein "VIM.DateUsedUntil" gesetzt ist, wird folgendes Berechnet

        - Live          VIM.DateCreated + 5 Jahre
        - Development   VIM.DateCreated + 3 Jahre
        - Test          VIM.DateCreated + 3 Monate (Quartal)
.PARAMETER VM
    Virtuelle Maschine
#>

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

    Begin {}

    Process {
        $VM | ForEach-Object {
            $o_vm = $_ | VIM-Get-VMValue -StageByFolder:$true
            #$s_DateCreated = (Get-Annotation -Entity $o_vm -Name "VIM.DateCreated").Value
            #$s_DateUsedUntil_now = (Get-Annotation -Entity $o_vm -Name "VIM.DateUsedUntil").Value

            $s_DateCreated = $o_vm."VIM.DateCreated"
            $s_DateUsedUntil_now = $o_vm."VIM.DateUsedUntil"


            #DateUsedUntil nur dann Neu berechnen wenn wir ein DateCreated und KEIN DateUsedUntil haben
            if($s_DateCreated -ne "" -and $s_DateUsedUntil_now -eq ""){
                $t_datecreated = Get-Date $s_DateCreated
                                
                $s_Stage=(Get-TagAssignment -Entity $o_vm -Category "Stage").Tag.Name
                #$o_vm
                $s_DateUsedUntil=""

                #Live -> 5 Jahre
                if( $s_Stage -eq "Live"){
                    $s_DateUsedUntil = Get-Date -format "yyyy-MM-dd HH:mm" $t_datecreated.AddYears(5)
                }

                #Development -> 3 Jahre
                if( $s_Stage -eq "Development"){
                    $s_DateUsedUntil = Get-Date -format "yyyy-MM-dd HH:mm" $t_datecreated.AddYears(3)
                }

                #Test -> 3 Monate
                if( $s_Stage -eq "Test"){
                    $s_DateUsedUntil = Get-Date -format "yyyy-MM-dd HH:mm" $t_datecreated.AddMonths(3)
                }


                if($s_DateUsedUntil -ne ""){
                    $o_vm=VIM-Set-VMValue -VM $o_vm -DateUsedUntil $s_DateUsedUntil
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "Stage"   -Value $s_Stage -Force
                    #Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "VIM.DateCreated"   -Value $s_DateCreated -Force
                    #Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "VIM.DateUsedUntil" -Value $s_DateUsedUntil -Force
                    
                }

                $o_vm

            }

        }
    }
    

    End {}

}

Function VIM-Check-EndOfLife {
<#
.SYNOPSIS
    Prüft ob eine VM "EndOfLife" ist
.PARAMETER VM
    Virtuelle Maschine
.PARAMETER DaysToUsedUntil
    So viele Tage vor "UsedUntil" wird die Maschine gemeldet
.EXAMPLE
    Get-VM -Tag "Ring*" | VIM-Check-EndOfLife
.EXAMPLE
    $tag=Get-Tag -Category Ansprechpartner -Name "Achter*"
    Get-VM -Tag $tag | VIM-Check-EndOfLife
.EXAMPLE
    Get-VM "deslnclivisio2k16" | VIM-Check-EndOfLife
.EXAMPLE
    VIM-Check-EndOfLife -VM (Get-VM "deslnclivisio2k16")
#>
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM,

    [int]$DaysToUsedUntil=$global:vim_VM_DaysToUsedUntil
    )

    Begin{}

    Process {
        $VM | ForEach-Object {
            $o_vm = $_
            #Write-Host $o_vm.Name
            $s_Created = (Get-Annotation -Entity $o_vm -Name "VIM.DateCreated").Value
            $s_UsedUntil = (Get-Annotation -Entity $o_vm -Name "VIM.DateUsedUntil").Value
            
            Try {

                $t_Created = Get-Date $s_Created
                $t_UsedUntil = Get-Date $s_UsedUntil
                $t_Now = Get-Date

                $t_Remaining = New-TimeSpan -Start $t_Now -End $t_UsedUntil
                $t_DaysToUsedUntil = New-TimeSpan -Day $DaysToUsedUntil

                #Wenn die VM abläuft dann gib die VM zurück
                if($t_Remaining -le $t_DaysToUsedUntil)
                {
                    #Write-Host "Abgelaufene VM: " $o_vm.Name
                    $s_Stage=(Get-TagAssignment -Entity $o_vm -Category "Stage").Tag.Name -join "; "
                    $s_Application=(Get-TagAssignment -Entity $_ -Category "Applikation").Tag.Name -join "; "
                    $s_Ansprechpartner=(Get-TagAssignment -Entity $_ -Category "Ansprechpartner").Tag.Name -join "; "
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "Stage"             -Value $s_Stage
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "Ansprechpartner"   -Value $s_Ansprechpartner
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "Applikation"       -Value $s_Application
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "VIM.DateCreated"   -Value $s_Created
                    Add-Member -InputObject $o_vm -MemberType NoteProperty -Name "VIM.DateUsedUntil" -Value $s_UsedUntil

                    $o_vm
                }
            }
            Catch {
                Write-Host "DateCreated oder DateUsedUntil nicht korrekt gesetzt: " $o_vm.Name
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
            }

        }
    }

    End {}

}

Function VIM-Get-VMEndOfLife {
<#
.SYNOPSIS
    Gibt VMs zurück die "EndOfLife" sind
.PARAMETER DaysToUsedUntil
    So viele Tage vor "UsedUntil" wird die Maschine gemeldet
.PARAMETER Contact
    VMs von einem bestimmten Ansprechpartner anzeigen
.PARAMETER ShowArchived
    Standardmäßig werden keine archivierten VMs mehr angezeigt
    mit -ShowArchived:$true kannst du dir diese VMs wieder anzeigen lassen
.EXAMPLE
    VIM-Get-VMEndOfLife | VIM-Show-VMValue
.EXAMPLE
    VIM-Get-VMEndOfLife -Contact "*Fiedler*" | Shutdown-VMGuest
.EXAMPLE
    VIM-Get-VMEndOfLife -Contact "Fiedler*" | Stop-VM
.EXAMPLE
    VIM-Get-VMEndOfLife -Contact "Fiedler*" | Delete-VM
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-EndOfLife
#>


    param (
    [Parameter(Position=0)] $DaysToUsedUntil=$global:vim_VM_DaysToUsedUntil,
    [Parameter(Position=1)] $Contact="",
    [Parameter(Position=2)] [switch]$ShowArchived
    
    )

    #$vm=Get-VM
    #$a_oldvms=Get-VM | VIM-Check-EndOfLife -DaysToUsedUntil $DaysToUsedUntil

    if($Contact -ne ""){
        $tag=Get-Tag -Category "Ansprechpartner" -Name $Contact
        $vms_to_return=Get-VM -Tag $tag | VIM-Check-EndOfLife -DaysToUsedUntil $DaysToUsedUntil
        
    }
    else {
        $tags=Get-Tag -Category "Ansprechpartner" 
        $vms_to_return=Get-VM | VIM-Check-EndOfLife -DaysToUsedUntil $DaysToUsedUntil
    }

    #Archivierte VMs auch anzeigen?
    if($ShowArchived){
        $vms_to_return
    }
    else{
        $vms_to_return | ?{(Get-TagAssignment -Entity $_ -Category "Stage").Tag.Name -ne "Archiv Stage"}
    }
}
Set-Alias -Name VIM-Get-VM-EndOfLife -Value VIM-Get-VMEndOfLife

Function VIM-Show-VMEndOfLife {
<#
.SYNOPSIS
    Gibt VMs zurück die "EndOfLife" sind
.PARAMETER DaysToUsedUntil
    So viele Tage vor "UsedUntil" wird die Maschine gemeldet
.PARAMETER Contact
    VMs von einem bestimmten Ansprechpartner anzeigen
.PARAMETER ShowArchived
    Standardmäßig werden keine archivierten VMs mehr angezeigt
    mit -ShowArchived:$true kannst du dir diese VMs wieder anzeigen lassen
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Show-VM-EndOfLife
#>
    param (
    [Parameter(Position=0)] $DaysToUsedUntil=$global:vim_VM_DaysToUsedUntil,

    $Contact="",

    [switch]$ShowArchived
    )

    if($Contact -ne ""){
        $vm=VIM-Get-VMEndOfLife -DaysToUsedUntil $DaysToUsedUntil -Contact $Contact -ShowArchived:$ShowArchived
    }
    else {
        $vm=VIM-Get-VMEndOfLife -DaysToUsedUntil $DaysToUsedUntil -ShowArchived:$ShowArchived
    }


    $vm | VIM-Show-VMValue
}
Set-Alias -Name VIM-Show-VM-EndOfLife -Value VIM-Show-VMEndOfLife

Function VIM-Mail-VMEndOfLife {
<#
.SYNOPSIS 
    Benachrichtigt über ablaufende VMs
.DESCRIPTION
    Durchsucht alle Ansprechpartner und benachrichtigt alle über ablaufende VMs.
    Über VMs die bereits archiviert wurden, wird nicht mehr benachrichtigt.
.PARAMETER Contact
    Ansprechpartner Tag oder Ansprechpartner als String.

    Es können auch Wildcards verwendet werden. z.B.:
    VIM-Mail-VMEndOfLife -Contact "Achter*"
.PARAMETER DaysToUsedUntil
.EXAMPLE
    VIM-Mail-VMEndOfLife -Contact "Achter*" -DaysToUsedUntil 60
.EXAMPLE
    VIM-Mail-VMEndOfLife -DaysToUsedUntil 100
#>

    param (
    
    [Parameter(Position=0)][Alias('Ansprechpartner')][string] $Contact="",
    [Parameter(Position=1)] [int]$DaysToUsedUntil=$global:vim_VM_DaysToUsedUntil,
    <#
        Ein Empfänger als String oder mehrere Empfänger als String Array.
        Standardmäßig wird diese Mail an die Ansprechpartner gesendet.
        Dieser Parameter dient als Umleitung (für Tests)
    #>
    $MailTo=""
    )



    $a_oldvms=Get-VM | VIM-Check-EndOfLife -DaysToUsedUntil $DaysToUsedUntil | VIM-Get-VMValue | ? Stage -ne "Archiv Stage"

    if($Contact -ne ""){
        $tags=Get-Tag -Category "Ansprechpartner" -Name $Contact
    }
    else {
        $tags=Get-Tag -Category "Ansprechpartner" 
    }


    $tags | ForEach-Object {
        $tag=$_
        #VMs für User Sammeln
        $a_uservms=@()
        
        Write-Host "OldVMs für: " $tag.Description
        
        Get-TagAssignment -Category "Ansprechpartner"| ?{($_.Tag.Name -eq $tag.Name)} | ForEach-Object {
            $tagass = $_
            
            Try {
                $vm=Get-VM $tagass.Entity -ErrorAction SilentlyContinue
                Write-Verbose ("VM Name: " + $vm.Name + " : VMType: " + $vm.GetType().Name)
                if($vm.GetType().Name -eq "UniversalVirtualMachineImpl")
                {
                   $a_uservms+=$vm
                }
            }
            Catch {
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
            }
        }
        #$a_uservms

        #Old VMs für User ermitteln
        $a_useroldvms=$a_oldvms | ?{$_ -in $a_uservms}

        
        $a_useroldvms | Select Name,Stage,"VIM.DateCreated","VIM.DateUsedUntil" | ft

        #Nur Mails an User schicken deren VMs ablaufen
        if($a_useroldvms.Length -gt 0)
        {
            <#
            $head='
            <style>
            h1, h5, th { text-align: center; }
            body { font-family: Segoe UI }
            table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
            th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
            td { font-size: 11px; padding: 5px 20px; color: #000; }
            tr { background: #b8d1f3; }
            tr:nth-child(even) { background: #dae5f4; }
            tr:nth-child(odd) { background: #b8d1f3; }
            </style>
            '
            #>

            $out= "Virtuelle Maschinen End Of Life mit Ansprechpartner: " + $tag.Name +"<hr/>"
            $out+= "Der Nutzungszeitraum dieser virtueller Maschinen läuft ab (siehe DateUsedUntil). Melde dich bei deinem VMWare-Administrator
                    um den Nutzungszeitraum zu verlängern, oder die virtuellen Maschinen löschen zu lassen. Wenn der Nutzungszeitraum abgelaufen ist, werden diese VMs heruntergefahren und archiviert. Ein VMWare-Administrator kann die archivierten VMs dann wiederherstellen"
               

            $details = [string]($a_useroldvms | Select Name,Stage,"VIM.DateCreated","VIM.DateUsedUntil",Applikation,Notes | ConvertTo-Html -As List -Fragment)

            $html = [string]($a_useroldvms | Select Name,Stage,"VIM.DateCreated","VIM.DateUsedUntil",Applikation | 
                ConvertTo-Html -PreContent $out -PostContent ("<h1>Details:</h1><hr/>" + $details))

            
            if($MailTo -ne ""){
                $SendMailTo=$MailTo
            }
            else{
                $SendMailTo=$tag.Description
            }

            #-To $tag.Description `
            VIM-Mail         -To $SendMailTo `
                             -Subject ("Virtuelle Maschinen End-Of-Life: " + $tag.Name + " -- Verlängern oder löschen?") `
                             -Html $html 
        }

    }

    

}
Set-Alias -Name VIM-Mail-VM-EndOfLife -Value VIM-Mail-VMEndOfLife



Function Get-VMX { 
<#
.SYNOPSIS
    Liefert VMX-Datei der VM
.EXAMPLE
    Get-VMX -VM $vm
#> 

#Requires -Version 2.0  
[CmdletBinding()]  
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
  
    Begin  
    {  
        Write-Verbose "Retrieving VMX Path Info . . ."  
    }#Begin  
    Process  
    {  
        Get-VM $VM | ForEach-Object {
            $o_vm = $_
            $vmxpath      = $o_vm.extensiondata.config.files.vmpathname
            $vmxmatches   = $vmxpath | Select-String -Pattern '\[(.+)\] (.*\.vmx)'
            $s_datastore  = $vmxmatches.Matches.Groups[1].Value
            $s_dspath     = $vmxmatches.Matches.Groups[2].Value
            $s_datacenter = ($o_vm | Get-Datacenter).Name
            Add-Member -InputObject $o_vm -MemberType NoteProperty -Name 'VMXPath' -Value $vmxpath
            
            $s_path = "vmstores:\"
            $s_path+= $global:DefaultVIServer.Name + "@" + $global:DefaultVIServer.Port
            $s_path+= "\" + $s_datacenter + "\" + $s_datastore + "\" + $s_dspath

            #$s_path

            Get-Item $s_path
        }
    }
    End  
    {  
  
    }
  
}

Function Get-VMXFolder { 
<#
.SYNOPSIS
    Liefert Ordner der VMX-Datei der VM
.EXAMPLE
    Get-VMXFolder -VM $vm | Get-ChildItem
#>
 
#Requires -Version 2.0  
[CmdletBinding()]  
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
  
    Begin  
    {  
        Write-Verbose "Retrieving VMX Path Info . . ."  
    }#Begin  
    Process  
    {  
        Get-VM $VM | ForEach-Object {
            $o_vm = $_
            $vmxpath      = $o_vm.extensiondata.config.files.vmpathname
            $vmxmatches   = $vmxpath | Select-String -Pattern '\[(.+)\] (.*)\/'
            $s_datastore  = $vmxmatches.Matches.Groups[1].Value
            $s_dspath     = $vmxmatches.Matches.Groups[2].Value
            $s_datacenter = ($o_vm | Get-Datacenter).Name
            Add-Member -InputObject $o_vm -MemberType NoteProperty -Name 'VMXPath' -Value $vmxpath
            
            $s_path = "vmstores:\"
            $s_path+= $global:DefaultVIServer.Name + "@" + $global:DefaultVIServer.Port
            $s_path+= "\" + $s_datacenter + "\" + $s_datastore + "\" + $s_dspath

            #$s_path

            Get-Item $s_path
        }
    }
    End  
    {  
  
    }
  
}

Function VIM-Mail-VM-without-Contact {

<#
.SYNOPSIS

	Sendet eine E-Mail mit einer Auflistung der VMs bei denen kein Ansprechpartner gelistet ist
.DESCRIPTION

	Das Script holt sich die VMs von der Funktion "VIM-Get-VM-withoud-Contact" und formuliert eine
	übersichtliche E-Mail mit allen notwendigen Informationen für den Administrator
.EXAMPLE

	VIM-Mail-VM-without-Contact
.LINK
	http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Mail-VM-without-Contact
#>

    param(
        <#
            Ein Empfänger als String oder mehrere Empfänger als String Array.
            Standardmäßig wird diese Mail an die Administratoren gesenet.
            Dieser Parameter dient als Umleitung (für Tests)
        #>
        $MailTo=""
    )


    #Die VMs hol ich mir von einer Funktion
    $vm_wo_contact=VIM-Get-VM-without-Contact | VIM-Get-VMValue

    <#

    #Vorbereiten der Email Ausgabe in HTML
    $out=""
    $vm_wo_contact | ForEach-Object {

        #Name
        $out+= "<p>`n"
        $out+= "<strong>Name:</strong> " + $_.Name + "<br/>`n"

        
        #RAM
        $out+= "<strong>Arbeitsspeicher: </strong>" + $_.MemoryGB + "GB <br/>`n"
        
        #Festplatten
        $hdd_str = $_ | Get-HardDisk | Select "CapacityGB", "Persistence" | ConvertTo-Html -Fragment
        $out+= "<strong>Festplatten: </strong>" + $hdd_str + "<br/>`n"

        #Name, Beschreibung
        $out+= "<strong>Beschreibung:</strong> <br/>`n<pre>" + $_.Notes + "</pre><br/>`n"
        
        #Tags (Applikationen und dergleichen)
        $tags_str = $_ | Get-TagAssignment | Select "Tag" | ConvertTo-Html -Fragment
        $out+= "<strong>Tags:</strong>" + $tags_str  +"<br/>`n" 

        #Annotations
        $annotations_str = $_ | Get-Annotation | Select Name,Value | ConvertTo-Html -Fragment
        $out+= "<strong>Annotations:</strong>" + $annotations_str + "<br/>`n"
        $out+= "</p>`n"
        $out+= "<hr />`n"

    }

    Write-Verbose $out
    #>

    <#
    Send-MailMessage -SmtpServer $mail_smtp_server `
                     -From $mail_sender `
                     -To $mail_default_recipient `
                     -Subject "VMWare Infrastructure Management: Virtuelle Maschinen ohne Ansprechpartner" `
                     -BodyAsHtml $out `
                     -Encoding UTF8
     #>

    if($MailTo -ne ""){
        $SendMailTo=$MailTo
    }
    else{
        $SendMailTo=$mail_default_recipient
    }
<#
     VIM-Mail -To $SendMailTo `
              -Subject "VMWare Infrastructure Management: Virtuelle Maschinen ohne Ansprechpartner" `
              -Html $out
#>
    VIM-Mail -To $SendMailTo `
        -Subject "VMWare Infrastructure Management: Virtuelle Maschinen ohne Ansprechpartner" `
        -Objects ($vm_wo_contact | Select Name,VIM.DateCreated,Ansprechpartner,Creator,Applikation,Stage,missingTags) `
        -Description 'VMWare Infrastructure Management: Virtuelle Maschinen ohne Ansprechpartner. Hier m&uuml;ssen noch Ansprechpartner laut VMWare Infrastructure Management gesetzt werden: <br/><a href="http://wiki.megatech.local/mediawiki/index.php/Virtual_Infrastructure_Management#Daten_in_vCenter">Wiki: Virtual Infrastructure Management</a>'
        


}


$global:switch_commands_coreswitch=@()
$global:switch_commands_netvmware=@()
Function VIM-MT-AddVLAN {

<#
.SYNOPSIS

	Erstellt ein neues VLAN in der kompletten VMWare Umgebung von Megatech
.DESCRIPTION

	Das Script holt sich alle vSwitches der Hosts auf denen virtuelle Maschinen laufen.
	Auf diesen vSwitches wird eine neue Portgroup für virtuelle Maschinen angelegt.
	Dieses Cmdlet ist Hardcoded spezifisch für Megatech
.PARAMETER vlan_name
	Name des neuen VLAN

.PARAMETER vlan_id
	ID des neuen VLAN

.EXAMPLE

	VIM-MT-AddVLAN -vlan_name "DMZ-01" -vlan_id "2502"
.LINK
	http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-MT-AddVLAN
#>

    param (
            [parameter(Mandatory=$true)] [string]$vlan_name,
            [parameter(Mandatory=$true)] [int]$vlan_id)

    Write-Host "VLAN-Name: " $vlan_name
    Write-Host "VLAN-ID: " $vlan_id


    $vswitch =  Get-Cluster deslnsrvvmclu01 | Get-VMHost | Get-VirtualSwitch -Name "vSwitch2"
    $vswitch += Get-VMHost testlapffu.megatech.local | Get-VirtualSwitch -Name "vSwitch0"

    #$vswitch
    $vswitch | New-VirtualPortGroup -Name $vlan_name -VLanId $vlan_id

    $global:switch_commands_coreswitch+="create vlan $vlan_name tag $vlan_id"
    $global:switch_commands_coreswitch+="configure vlan $vlan_name add ports 1:43,1:44,1:48 tagged"

    $global:switch_commands_netvmware+="vlan create $vlan_id name $vlan_name type port"
    $global:switch_commands_netvmware+="vlan members add $vlan_id 1/1-3,1/23-24,2/1-3,2/23-24"
    

}

Function VIM-MT-DeleteVLAN {
<#
.SYNOPSIS

	Löscht ein VLAN in der kompletten VMWare Umgebung von Megatech
.DESCRIPTION

	Das Script holt sich alle vSwitches der Hosts auf denen virtuelle Maschinen laufen.
	Auf diesen vSwitches wird das definierte VLAN gelöscht
	Dieses Cmdlet ist Hardcoded spezifisch für Megatech
.PARAMETER vlan_name
	Name des neuen VLAN

.EXAMPLE

	VIM-MT-DeleteVLAN -vlan_name "DMZ-01"
.LINK
	http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-MT-DeleteVLAN
#>

    param (
            [parameter(Mandatory=$true)] [string]$vlan_name
            )

    Write-Host "VLAN-Name: " $vlan_name

    $vswitch =  Get-Cluster deslnsrvvmclu01 | Get-VMHost | Get-VirtualSwitch -Name "vSwitch2"
    $vswitch += Get-VMHost testlapffu.megatech.local | Get-VirtualSwitch -Name "vSwitch0"


    $vswitch | Get-VirtualPortGroup -Name $vlan_name | Remove-VirtualPortGroup

}

Function VIM-Get-vSwitchPrimary {
<#
.SYNOPSIS

	Holt die primären vSwitches 
.DESCRIPTION

	Holt die primären vSwitches in der aktuell verbundenen vCenter Umgebung

	Diese Funktion kann später als Helper verwendet werden um ein VLAN
	auf allen primären vSwitches zu erstellen.

    Wichtige Tags:
        Tags werden auf ESX-HOST Objekte zugewiesen
        Category: vSwitchPrimary          Tag:vswitch0 (1) (2) usw    vSwitch für die primären Guest VLANs

.PARAMETER nochKeiner

.EXAMPLE

	VIM-Get-PrimaryVswitch
.EXAMPLE

	$vswitch=VIM-Get-PrimaryVswitch
	$vswitch | Select VMHost,Name
.LINK
	http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-vSwitchPrimary
#>

    VIM-Get-vSwitch -tag_category vSwitchPrimary
}

Function VIM-Get-vSwitch {
<#
.SYNOPSIS

    Holt vSwitches in der vCenter Umgebung anhand der angegebenen Kategorie
.DESCRIPTION

    gibt vSwitches zurück die mit der entsprechenden Kategorie getagged wurden
    die Tags werden auf die ESX-Hosts gesetzt da vSwitche direkt nicht getagged
    werden können

    Diese Funktion kann später als Helper verwendet werden um ein VLAN
    auf allen primären vSwitches zu erstellen

    geplante Kategorien:
    * vSwitchPrimary
    * vSwitchStorage
    * vSwitchInterlink
    * vSwitchMgmt
    * vSwitchHA
    * vSwitchFT

    Wichtige Tags:
        Tags werden auf ESX-HOST Objekte zugewiesen
        Category: vSwitchPrimary          Tag:vswitch0 (1) (2) usw    vSwitch für die primären Guest VLANs
        Category: vSwitchStorage          Tag:vswitch?                vSwitch für das Storage Netz
        Category: vSwitchInterlink        Tag:vswitch?                vSwitch der die Hosts direkt verbindet,
                                                                      oder auch Interlink für Guests 
                                                                      (Cluster HA Netz oder dergleichen)
        Category: vSwitchMgmt             Tag:vswitch?                hier ist das ESX Mgmt Netz drauf
        Category: vSwitchHA               Tag:vswitch?                hier drauf läuft HA
                                                                      (kann man Zukünftig evtl direkt aus vSwitch auslesen)
        Category: vSwitchFT               Tag:vswitch?                hier drauf läuft Fault Tolerance
                                                                      (evtl auslesen)

.PARAMETER tag_category
    Tag-Kategorie der gesuchten vSwitche, diese werden zurückgegeben

.EXAMPLE
    VIM-Get-vSwitch -tag_category vSwitchPrimary
.EXAMPLE
    $vswitch=VIM-Get-vSwitch -tag_category vSwitchPrimary
    $vswitch | Select VMHost,Name
.EXAMPLE
    $vswitch=VIM-Get-vSwitch
    $vswitch | Select VMHost,Category,Name

.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-vSwitch

#>

    
    param (
        [parameter(Mandatory=$false)] [string]$tag_category
            )


    $a_vswitch=@()

    if( -not $tag_category -eq "")
    {
        Get-VMHost | ForEach-Object {
            $vswitch_tag = $_ | Get-TagAssignment -Category $tag_category -ErrorAction SilentlyContinue
            $s_hostname = $_.Name
            Try 
            {
                $o_vswitch = $_ | Get-VirtualSwitch -Name $vswitch_tag.Tag.Name
                Add-Member -InputObject $o_vswitch -MemberType NoteProperty -Name "VMHost" -Value $s_hostname -Force
                Add-Member -InputObject $o_vswitch -MemberType NoteProperty -Name "Category" -Value $tag_category -Force
                $a_vswitch += $o_vswitch
            }
            Catch
            {
                Write-Host $s_hostname "Hat keinen vSwitch in Kategorie:" $tag_category
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
            }
        }
    }
    else
    {
        Write-Host "All"
        VIM-Get-vSwitchCategories | ForEach-Object {
            $a_vswitch += VIM-Get-vSwitch -tag_category $_.Name
        }

    }
    $a_vswitch
}

Function VIM-Get-vSwitchCategories {
<#
.SYNOPSIS
    Holt vSwitch Kategorien
.DESCRIPTION
    Holt vSwitch Kategorien
.EXAMPLE
    VIM-Get-vSwitchCategories
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-vSwitchCategories
#>

    Get-TagCategory | Where-Object {$_.Name -match "vSwitch*"}
}

Function VIM-Get-vCenter {
<#
.SYNOPSIS
    Holt sich das aktuelle primäre vCenter
.DESCRIPTION
    Holt sich das aktuelle primäre vCenter

    Wichtige Tags:
        Category: Applikation          Tag:vCenterPrimary    Markierung für dem primären vCenter Host, dieser wird gesichert

.EXAMPLE
    $vcenter=VIM-Get-vCenter
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Get-vCenter
#>

    $tagass=Get-TagAssignment -Category "Applikation" | Where-Object {$_.Tag.Name -eq "vCenterPrimary"}
    Get-VM $tagass.Entity
}

Function VIM-Clone-vCenter {
<#
.SYNOPSIS
    Erstellt eine Sicherheitskopie von vCenter
.DESCRIPTION
    Erstellt eine Sicherheitskopie von vCenter
    Es müssen vorher Tags auf Objekte festgelegt worden sein damit das Backup funktioniert

    Wichtige Tags:
        Category: Applikation          Tag:vCenterPrimary    Markierung für dem primären vCenter Host, dieser wird gesichert
        Category: Applikation          Tag:vCenterBackup     Markierung für den vCenter Klon. Wenn das primäre vCenter ausgefallen ist
                                                             muss der vCenter Klon als "vCenterPrimary" markiert werden
        Category: DatastoreUsage       Tag:Backup            Auf diesen Datastore wird vCenter geklont
        Category: HostUsage            Tag:Backup            Auf diesen Host wird vCenter geklont
        
.EXAMPLE
    #Tags müssen vorher festgelegt worden sein. Siehe Description
    VIM-Clone-vCenter
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Clone-vCenter
#>

    #vCenter Server
    $vcenter=VIM-Get-vCenter

    if($vcenter.Count -gt 1){
        Write-Error "Es darf nur ein vCenterPrimary vorhanden sein. Bitte Tags Category: Applikation Tag:vCenterPrimary prüfen"
        return $false
    }

    $vmname= $vcenter.Name + " - Backup"

    #Altes Backup löschen

    Try {
        $oldvm=Get-VM -Name $vmname -ErrorAction Stop #$vmname

        Write-Host "Altes Backup von vCenter wird gelöscht"
        Remove-VM $oldvm -DeletePermanently -Confirm:$false
    }
    Catch
    {
        Write-Host "Kein altes Backup von vCenter vorhanden"
        Write-Host $_ -ForegroundColor Red -BackgroundColor Black
    }

    #vCenter Server Ordner
    $folder = $vcenter | Get-View | ForEach-Object { Get-Folder -Id $_.Parent }
    #Backup Datastore
    $datastore=Get-TagAssignment -Category "DatastoreUsage" | Where-Object {$_.Tag.Name -eq "Backup"} | %{$_.Entity} | Select-Object -First 1
    #Backup Host
    $vmhost=Get-TagAssignment -Category "HostUsage" | Where-Object {$_.Tag.Name -eq "Backup"} | %{$_.Entity} | Select-Object -First 1
    
    $vmname= $vcenter.Name + " - Backup"
    <#
        Beispiel zum Klonen einer VM:
        New-VM -VM $vcenter -VMHost "testlapffu.megatech.local" -Name "deslnsrvvcenter01 - BackupTest" -Datastore $datastore
    #>
    #//XXX TODO: Hier brauche ich eventuell die Möglichkeit für eine Asynchrone Variante um nachfolgende Scripte nicht aufzuhalten
    Write-Host "Neuer vCenter Klon wird erstellt"
    $vcenter_clone=New-VM -VM $vcenter -VMHost $vmhost -Name $vmname -Datastore $datastore -Location $folder

    #Setzen der notwendigen Tags für den neuen vCenter Klon
    $vcenter_clone | VIM-Set-CreationByEvent

    #Standardmäßig darf der vCenter Clone nicht Asynchron laufen, damit ich Sofort die richtigen Tags setzen kann
    Get-ADGroupMember $global:vim_ad_admingroup | %{VIM-Get-ContactTag -Name $_.Name -Category Ansprechpartner} | ForEach-Object {
        $tag=$_
        $dummy=New-TagAssignment -Entity $vcenter_clone -Tag $tag
    }

    $dummy=New-TagAssignment -Entity $vcenter_clone -Tag $(Get-Tag -Category "Creator" -Name "vmwarevdp; Creator")
    $dummy=New-TagAssignment -Entity $vcenter_clone -Tag $(Get-Tag -Category "Stage" -Name "Live")
    $dummy=New-TagAssignment -Entity $vcenter_clone -Tag $(Get-Tag -Category "Applikation" -Name "vCenterBackup")

    #Rückgabe des geklonten vCenter
    Get-VM $vcenter_clone
}

Function VIM-Download-VM (
    [Parameter( Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('VirtualMachine')]
    $VM,

    $Destination
)
<#
.SYNOPSIS
    Lädt eine VM zu einem Lokalen Pfad runter
.DESCRIPTION
    Lädt eine VM von einem VM-Datastore in der vCenter Umgebung zu einem lokalen Pfad herunter
    hie wird mittels "Copy-DatastoreItem" zwischen VMWare Datastore und Local Datastore überetzt

    WARNUNG!: Dieser Download funktioniert nur vernünftig mit AUSGESCHALTETEN VMs.
    es wird hier kein "Quiesce" "Volume Shadow Copy" oder dergleiche gemacht
    ich kopiere hier einfach nur die blanken Files der VM

    Ausserdem kann es sein, dass der Download unvollständig ist, sollte die VM über mehrere Datastores verteilt sein
    da muss ich mir möglicherweise noch Gedanken machen, wenn eine VM über verschiedenen Datastores verteilt ist
.PARAMETER VM
    Das VM Objekt das heruntergeladen werden soll. Es können mehrere VMs mittels Pipe oder Array übergeben werden
.PARAMETER Destination
    Pfad zu dem Verzeichnis in das Heruntergeladen werden soll
    
#>
{
    Begin {}

    Process {
        $VM | ForEach-Object {
            $v=$_
            Write-Host $v.Name

            $v_layout=$v | Get-View | %{$_.Layout}
            $v_disks=$v_layout | %{$_.Disk} | %{$_.DiskFile}

            $a_disks=@()
            $a_diskfolder=@()

            $vcenter=$global:DefaultVIServer
            $datacenter=($v | Get-Datacenter)


            $dest="Microsoft.PowerShell.Core\FileSystem::" + $Destination
            Try{
                $o_destdir=New-Item -Path $dest -Name $v.Name -ItemType Directory -ErrorAction Stop

                ForEach($disk in $v_disks) {
                    $match=$disk | Select-String -Pattern "\[([^\]]+)\] (.*)"

                    $o_disk = New-Object -TypeName PSObject -Property ([ordered]@{
                        datastore = $match.Matches.Groups[1].Value
                        diskpath  = $match.Matches.Groups[2].Value
                    })

                    $a_disks+=$o_disk

                    #$o_disk

                    
                    $o_diskfile=Get-Item ("vmstores:\" + $vcenter.Name + "@" + $vcenter.Port + "\" + $datacenter.Name + "\" + $o_disk.datastore + "\" +$o_disk.diskpath )
                    $o_diskfolder=Get-Item $o_diskfile.PSParentPath
                    
                    #$a_diskfolder+=$o_diskfolder

                    Try{
                        $o_subdir=New-Item -Path $o_destdir -ItemType Directory -Name $o_diskfolder.Datastore -ErrorAction Stop
                        Copy-DatastoreItem -Recurse -Item $o_diskfolder -Destination $o_subdir
                    }
                    Catch{
                        Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                    }
                }

            }
            Catch{
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                #Continue
            }

            


        }
    }

    End {
    }
}



Function VIM-Sync-Contacts {
<#
.SYNOPSIS
    Synchronisiert Kontakte Tags im vCenter mit ActiveDirectory-User
.DESCRIPTION
    PREREQUISITE
    Active-Directory Windows Powershell Modul wird benötigt
    (Teil der Remoteserver-Verwaltungstools)

    - User die noch nicht als Tag in vCenter bekannt sind werden neu angelegt
    - Es werden keine User gelöscht
    - Bei bestehenden Usern wird dafür gesorgt, dass die Email Addresse in der Tag Description 
      mit der Email Addresse im Active Directory übereinstimmt um Versand an ungültüge Email-Addresse
      zu vermeiden
.PARAMETER ADGroups
    ARRAY Active Directory Gruppen die nach VMWare Usern durchsucht werden
    Standard: @("VMWare-MainUsers","VMWare-Administrators")
.PARAMETER TagCategories
    Tag Kategorien mit denen diese User Synchronisiert werden 
    Es können also mehrere Tag-Kategorien diese Kontakte enthalten
    Standard: @("Ansprechpartner","Creator")
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Sync-Contacts
#>

    [CmdletBinding()]
    param(
    $ADGroups=$global:vim_ad_groups,
    $TagCategories=@("Ansprechpartner","Creator")
    )

    $aduser=@()

    $s_adgroups=$ADGroups -join(";")

    Write-Host ("Synchronisiere AD-Gruppen: " + $s_adgroups)

    ForEach($group in $ADGroups){
        $aduser+=Get-ADGroupMember $group | Get-ADUser -Properties "EmailAddress"
    }

    Write-Verbose ("Start")

    ForEach($cat in $TagCategories){
        Write-Verbose ("Tag Kategorie: " + [string]$cat)
        $tag=Get-Tag -Category $cat
        $a_tagname=$tag.Name

        #Write-Host "Tag-Name:" 
        #$a_tagname


        ForEach($user in $aduser){

            
            $user_tag_name=$user.Name + ($_.Name + "; " + $cat)
            #$user_tag_name

            Write-Verbose ("User-Tag-Name: " + [string]$user_tag_name)

            if($user_tag_name -notin  $a_tagname){
                Write-Verbose ("Tag: " + [string]$user_tag_name + " wird angelegt")
                New-Tag -Category $cat -Name $user_tag_name -Description $user.EmailAddress
            }
            else
            {
                Write-Verbose ("Tag: " + $user_tag_name + " bereits vorhanden")
                $curr_tag=$tag | Where-Object {$_.Name -eq $user_tag_name}
                If([string]$curr_tag.Description -ne [string]$user.EmailAddress){
                    Write-Verbose ($user_tag_name + " EMail-Addresse stimmt nicht überein. Wird angepasst auf " + $user.EmailAddress)
                    $curr_tag | Set-Tag -Description ([string]$user.EmailAddress)
                }
            }
        }


    }
    Write-Host "Synchronisation abgeschlossen"
}

Function VIM-Get-VM-OnWrongStorage {
<#
.SYNOPSIS
    Sucht VMs die auf der falschen Storage gehostet werden
.DESCRIPTION
    //XXX Todo:
    Kategorisierung reicht nicht aus. Dachte hier an sowas
    Category: Storage Redundancy -> (Bronze Redundancy, Silver Redundancy, Gold Redundancy)
    Category: Storage Performance -> (Brnoze Performance, Silver Performance, Gold Performance)


    Wichtige Tags:
        Category: Stage          Tag:Live           produktive VMs primär auf LeftHand Cluster
        Category: Stage          Tag:Test           Test VMs primär auf TestESX lokales Raid5
        Category: Stage          Tag:Development    VMs für die Entwickler

        Die Caetgory Storage Stage wird verwendet um einer Storage MEHRERE mögliche Stages zuweisen
        (mehrfache Kardinalität)

        Category: Storage Stage          Tag:Live           produktive VMs primär auf LeftHand Cluster
        Category: Storage Stage          Tag:Test           Test VMs primär auf TestESX lokales Raid5
        Category: Storage Stage          Tag:Development    VMs für die Entwickler


    Vergleicht die Tags der VMs mit den Tags der Storages auf denen sie gehostet sind.
    Ist die Storage einem anderen Tag zugeordnet, wird die VM zurückgegeben
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-OnWrongStorage
#>

    param(  
    [Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM=$(Get-VM)
    )


    Begin {}

    Process{
        $VM | ForEach-Object {
            $o_vm=$_

            $o_vmtagass=$($o_vm | Get-TagAssignment -Category Stage)
                       

            #Write-Verbose $("Virtual-Machine: " + $o_vm.Name)
            #Write-Verbose $("Virtual Machine Tag Assignment: " + $o_vmtagass.Tag.Name)

            $o_datastores=$o_vm | Get-HardDisk | %{$_ | Get-Datastore}
            $o_datastores_tagass= $o_datastores | Get-TagAssignment -Category "Storage Stage"

            
            #Write-Verbose $("Datastore: " + $o_datastores.Name)
            #Write-Verbose $("Datastore Tag Assosiation: " + $o_datastores_tagass.Tag.Name)

            #$("Datastore Tag Assosiation: " + $o_datastores_tagass.Tag.Name)

            if($o_vmtagass.Tag.Name -in $o_datastores_tagass.Tag.Name){
                Write-Verbose "Richtige Storage"
            }
            else {
                Write-Verbose "Falsche Storage"
                Add-Member -InputObject $o_vm -MemberType NoteProperty -Name Datastores -Value ($o_datastores.Name -join ",")
                $o_vm
                return
            }
            
        }
    }

    End{}

}

Function VIM-Show-VM-OnWrongStorage {
<#
.SYNOPSIS
    Zeigt VMs von VIM-Get-VM-OnWrongStorage vernünftig an
    Kann nicht in einer Pipe verwendet werden
#>

    VIM-Get-VM-OnWrongStorage | VIM-Show-VMValue -columns Name,Stage,Datastores

}



Function Delete-VM {

<#
.SYNOPSIS
    Löscht virtuelle Maschinen
    Ist ein Alias für das "Remove-VM" von VMWare da man bei Remove-VM das -DeletePermanently
    explizit angeben muss und das leicht vergessen werden kann
.EXAMPLE
    VIM-Get-VMEndOfLife -Contact "Fiedler*" | Delete-VM
#>

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

    Begin{
        $a_vm = @()
    }

    Process{
        
        $VM | ForEach-Object {
            $a_vm+=$_   
        }
    }

    End{
        #Write-Host "End"
        $a_vm | Remove-VM -DeletePermanently
    }
}


Function VIM-Get-VMDK-Orphaned {
<#
.SYNOPSIS
    Gibt Verwaiste VMDKs zurück. Also virtual Machine Disks die zu keiner virtuellen Maschine mehr zugeordnet sind
.DESCRIPTION
    Der Tag DatastoreUsage / NoVM verhindert, dass eine Storage durchsucht wird
.EXAMPLE
    $result=VIM-Get-VMDK-Orphaned
    $result
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VMDK-Orphaned
#>
    [CmdletBinding()]
    param()

    $report = @()
    $arrUsedDisks = Get-View -ViewType VirtualMachine | % {$_.Layout} | % {$_.Disk} | % {$_.DiskFile}

    $arrDS=Get-Datastore | ForEach-Object {
        $o_ds=$_

        If(($o_ds | Get-TagAssignment).Tag.Name -contains "NoVM"){
            Write-Verbose ($o_ds.Name + " Enthält NoVM Tag. Wird nicht durchsucht")
        }
        else {
            #Ansonsten Gebe ich den Datastore zurück
            $o_ds
        }
    } | Sort-Object -property Name

    #$arrDS = Get-Datastore | Sort-Object -property Name
    $datastore_index=0
    foreach ($strDatastore in $arrDS) {

        $datastore_percent = 100 / $arrDS.Length * $datastore_index
        Write-Progress -Activity "Searching Orphaned VMDKs in Datastore" -Status ("Datastore: " + $strDatastore.Name) -PercentComplete $datastore_percent

        Write-Host "Checking" $strDatastore.Name "..."
        $ds = Get-Datastore -Name $strDatastore.Name | % {Get-View $_.Id}
        $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
        $fileQueryFlags.FileSize = $true
        $fileQueryFlags.FileType = $true
        $fileQueryFlags.Modification = $true
        $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
        $searchSpec.details = $fileQueryFlags
        $searchSpec.matchPattern = "*.vmdk"
        $searchSpec.sortFoldersFirst = $true
        $dsBrowser = Get-View $ds.browser
        $rootPath = "[" + $ds.Name + "]"
        $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)

        #Write-Host "After Search"

        $folder_index=0
        foreach ($folder in $searchResult)
        {
            #$folder_percent = 100 / $searchResult.Length * $folder_index
            #Write-Progress -Activity "Searching in Folder" -Status ("Folder: " + $folder.FolderPath) -PercentComplete $folder_percent
            foreach ($fileResult in $folder.File)
            {
                if ($fileResult.Path)
                {
                    if (-not ($fileResult.Path.contains("ctk.vmdk"))) #Remove Change Tracking Files
                    {
                        if (-not ($arrUsedDisks -contains ($folder.FolderPath.trim('/') + '/' + $fileResult.Path)))
                        {
                            $row = "" | Select DS, Path, File, Size, ModDate
                            $row.DS = $strDatastore.Name
                            $row.Path = $folder.FolderPath
                            $row.File = $fileResult.Path
                            $row.Size = $fileResult.FileSize
                            $row.ModDate = $fileResult.Modification
                            $report += $row
                        }
                    }
                }
            }
            $folder_index++
        }
    $datastore_index++
    } 

    # Print report to console
    $report
}


function VIM-Mail-VMDK-Orphaned {
    param(
    $MailAddress=$(VIM-Get-Admins -WithEmail).EmailAddress
    )
    #$MailAddress='rudolf.achter@megatech-communication.de'
    
    $html=""
    #VIB-LAB Workaround
    $html+='<div style="background-color:#FFFF00;">#VIB-LAB Workaround Aktiv! Festplatten von .viblab.local werden aktuell ausgeblendet! Suche im Powershell Modul nach #VIB-LAB Workaround</div>'

    $html+=VIM-Get-VMDK-Orphaned | 
        #VIB-LAB Workaround
        ?{-not ($_.Path -match "viblab.local")} | 
        ConvertTo-Html -Fragment


    

    VIM-Mail -From rudolf.achter@megatech-communication.de `
            -To $MailAddress `
            -Subject "Nicht zugeordnete virtual Disks in der VMWare Infrastruktur (Orphaned VMDKs)" `
            -Description 'Diese VMDK-Dateien sind zu keiner virtuellen Maschine zugeornet. 
                        Diese sollten entweder gel&ouml;scht, als virtuelle Maschine registriert, 
                        oder an eine virtuelle Maschine angeh&auml;ngt werden' `
            -Html $html

}



Function VIM-Mail {
<#
.SYNOPSIS
    Allgemeine Mail funktion um Mails vom Virtual Infrastructure Management aus zu verschicken

.EXAMPLE
    $html='Mein Testcontent'
    VIM-Mail -From rudolf.achter@megatech-communication.de `
            -To $MailAddress `
            -Subject "Mail Subject (Betreff)" `
            -Description 'Beschreibung des Inhalts der Mail' `
            -Html $html
.PARAMETER Objects
    Wenn Objekte übergeben werden, Wird das an die Mail gehängt
.PARAMETER From

.PARAMETER To

.PARAMETER Subject

.PARAMETER Description

.PARAMETER Html

.PARAMETER SMTPServer
#>    

    param (
            [Parameter(
                Position=0, 
                Mandatory=$false, 
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)
            ]
            $Objects=$null,
            $From=$global:mail_sender,
            $To=$null,
            $Subject="VIM-Mail",
            $Description="Description",
            $Html="",
            $SMTPServer=$global:mail_smtp_server
            
    )
        Begin {
            $a_obj = @()
        }

        Process {
            
            ForEach($o in $Objects){
                $a_obj+=$o
            }
        }

        End {

            $Html+=$a_obj | VIM-ConvertTo-HTML

            $header='
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml">
   <head>
      <title>vCheck</title>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      <style type="text/css">
         body {
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
         }
         #content table	{
            margin: 0px;
            padding: 0px;
            width: 100%;
            border-collapse:collapse;
            background-color: #ffffff;
            /*border: 1px solid #1D6325;*/
         }
         tr:nth-child(even) { 
            background-color: #e5e5e5; 
         }
         #content td {
               vertical-align: top; 
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
               padding: 4px;
               background-color: #e9e9e9;
               border: 1px solid white;
         }
         #content th {
               vertical-align: top;  
               color: #018AC0; 
               text-align: left;
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
               padding: 4px;
               background-color: #cccccc;
               border: 1px solid white;
         }

         h1 {
               margin:0px;
               padding-left: 0px;
               padding-right: 0px;
               padding-top: 5px;
               padding-bottom: 5px;
               font-size: 14pt;
         }


         h2 {
               margin: 0px;
               padding-top: 5px;
               padding-bottom: 5px;
               padding-left: 0px;
               padding-right: 0px;
               font-size: 12pt;
         }

         h3 {
               margin: 0px;
               padding-top: 5px;
               padding-bottom: 5px;
               padding-left: 0px;
               padding-right: 0px;
               font-size: 11pt;
         }

         h4 {
               margin:0px;
               padding-top: 5px;
               padding-bottom: 5px;
               padding-left: 0px;
               padding-right: 0px;
               font-size: 10pt;
         }

         div {
               padding: 0px;
         }

         div.subject {
               vertical-align: top; 
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
               padding: 5px;
               margin: 0px;
               background-color: #1D6325;
               /*border: 1px solid #1D6325;*/
               font-weight: bold;
               color: #ffffff
         }

         div.subject a{
            color: #ffffff
         }

         div.description {
               vertical-align: top; 
               font-family: Tahoma, sans-serif;
               font-size: 8pt;
               padding: 5px;
               margin: 0px;
               background-color: #cccccc;
               /*border: 1px solid #1D6325;*/
               font-weight: normal;
               color: #000000
         }

         .warning { background: #FFFBAA !important }
         .critical { background: #FFDDDD !important }
   </style>
   </head>
   <body style="margin: 0px; font-family:Tahoma, sans-serif; ">
      <a name="top"></a>
      

      <table style="border: 1px solid #1D6325; border-collapse:collapse;">
      <tr>
        <td style="background-color:#0A77BA; padding:0px" >
            <img src="cid:header" alt="vCheck" />
        </td>
        <td style="background-color:#0A77BA; width: 171px; padding:0px">
            <img src="cid:header_vmware" alt="VMware" />
        </td>
      <tr>
        <td id="content" colspan="2" style="padding:0px">
               
            '



            $footer='
        </td>
      </tr>
    </table>
 </body>
</html>
'

            $thisModuleDir = Split-Path (Get-Module -ListAvailable Virtual-Infrastructure-Management | Select-Object -First 1).Path -parent
            #Write-Host $thisModuleDir

            $out= '<div class="subject"><br/><h1>' + $Subject +'</h1><br/></div>'
            $out+= '<div class="description"><br/>' + $Description + '<br/><br/></div>'

            #$out += [string](Get-VM | ConvertTo-Html -Fragment)
            $out += $Html


            $mail_html_content= $header + $out + $footer

            $images = @{ 
                            header           = $thisModuleDir + '\resources\Header.jpg'
                            header_vmware    = $thisModuleDir + '\resources\Header-vmware.png'
                        } 

            
            Send-MailMessageAdvanced -SmtpServer $global:mail_smtp_server `
                                     -From $From `
                                     -To $To `
                                     -Cc $From `
                                     -Subject $Subject `
                                     -BodyAsHtml $mail_html_content `
                                     -InlineAttachments $images 
        }
}


Function VIM-Get-Admins {

    param (
        [switch] $WithEmail
    )

    Begin{}

    Process {}

    End {
        if($WithEmail)
        {
            Get-ADGroupMember $global:vim_ad_admingroup | Get-ADUser -Properties EmailAddress | Where-Object {
                [string]$_.EmailAddress -ne ""
            }
        }
        else
        {
            Get-ADGroupMember $global:vim_ad_admingroup | Get-ADUser -Properties EmailAddress
        }
    }
}

Function VIM-Get-Snapshot {
<#
.SYNOPSIS
    Liefert alle Snapshots zurück
.DESCRIPTION
    Liefert alle Snapshots der VMWare Umgebung
    Wird Value und Unit angegeben werden Snapshots zurückgeliefert
    die älter als die angegebenen Day, Month, Year sind

    Return SNAPSHOT
.PARAMETER VM
    Eine oder mehrere virtuelle Maschinen für die Snapshots angezeigt werden
.PARAMETER Value
    Ein Wert fuer ein Alter
.PARAMETER Unit
    Eine Einheit für ein Alter (Day, Month, Year)
.EXAMPLE
    VIM-Get-Snapshot
.EXAMPLE
    VIM-Get-Snapshot | %{$_.VM}
    #Alle VMs mit Snapshots
#>

    param(
    [Parameter(
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM=(Get-VM),

    [Parameter(Position=0)]
    [int]$Value=3,
        
    [Parameter(Position=1)]
    [string]
    [ValidateSet("Day","Month","Year")]
    [string]$Unit="Month"

    )


    Begin {
        Switch($Unit){
            "Day" {
                $date=(Get-Date).AddDays(-$Value)
                break;
            }
            "Month" {
                $date=(Get-Date).AddMonths(-$Value)
                break;
            }
            "Year" {
                $date=(Get-Date).AddYears(-$Value)
                break;
            }
            default {
                $date=(Get-Date)
                break;
            }
                
        }
        
        $a_vm=@()           
    }

    Process {
        $VM | ForEach-Object {
            $a_vm+=$_
        }
    }

    End {
        $a_vm | Get-Snapshot | Where-Object {$_.Created -lt $date}
    }

}


Function VIM-Get-VM-WithSnapshot {
    param(
        [Parameter(Position=0)]
        [int]$Value=3,
        
        [Parameter(Position=1)]
        [string]
        [ValidateSet("Day","Month","Year")]
        $Unit="Month"
    )

    Begin {
        
    }

    Process {}

    End {
        $snaps=Get-VM | VIM-Get-Snapshot -Unit $Unit -Value $Value

        #$snaps
        
        $h_contacts = VIM-Get-ContactsHash

        $a_vm=@()

        #Snapshots in Contacts Hash Sammeln
        ForEach($snap in $snaps){
            #VMs nur EINMAL hinzufügen
            if($snap.VM.Name -notin $a_vm.Name){
                $a_vm += $snap.VM
            }
        }
        $a_vm

    }
}


Function VIM-Mail-Snapshot {

    param(
        [Parameter(Position=0)]
        [int]$Value=3,
        
        [Parameter(Position=1)]
        [string]
        [ValidateSet("Day","Month","Year")]
        $Unit="Month",
        <#
            Ein Empfänger als String oder mehrere Empfänger als String Array.
            Standardmäßig wird diese Mail an die Ansprechpartner gesendet.
            Dieser Parameter dient als Umleitung (für Tests)
        #>
        $MailTo=""
    )

    Begin {
        
    }

    Process {}

    End {
        $snap_vms=@()

        $snaps=VIM-Get-Snapshot -Unit $Unit -Value $Value

        #$snaps
        
        $h_contacts = VIM-Get-ContactsHash

        #Snapshots in Contacts Hash Sammeln
        ForEach($snap in $snaps){
            $vm = $snap.VM
            $contacts = $vm | VIM-Get-Contacts

            ForEach($contact in $contacts){
                #Write-Host $contact
                $h_contacts.$($contact.Address).Data+=$snap
            }
        }

        #Mails für alle Contacts verschicken
        
        $h_contacts.Keys | ForEach-Object {
            
            #Nur Email generieren und verschicken wenn auch wirklich Snapshots zu melden sind
            if((($h_contacts.Item($_)).Data | Measure-Object).Count -gt 0){
            
                $html=""
                $html+="Zu alte Snapshots f&uuml;r: "+ ($h_contacts.Item($_)).Name + "</br>" + "`n"
                $html+="Diese Snapshots sind &auml;lter als 3 Monate und sollten gel&ouml;scht werden" + "</br>" + "`n"
                $html+="Wenn es einen triftigen Grund gibt bestimmte Snapshots zu behalten, betrachte diese E-Mail als &Uuml;bersichtliche Information" + "</br>" + "`n"
                $html+=($h_contacts.Item($_)).Data | Select  VM, Name, Created, Description | ConvertTo-Html -Fragment

                Write-Host $html
                #//XXX hier weiter
                #Es gehört nur noch der Empfänger -To ausgetauscht
                #($h_contacts.Item($_)).Address

                if($MailTo -ne "") {
                    $DoMailTo=$MailTo
                }
                else {
                    $DoMailTo=($h_contacts.Item($_)).Address
                }

                VIM-Mail -To $DoMailTo `
                    -Subject ("Zu alte Snapshots für: "+ ($h_contacts.Item($_)).Name + " (Virtual Infrastructure Management)") `
                    -Html $html
            }
        }

    }

}

Function VIM-Show-Snapshot {

    param(
        [Parameter(Position=0)]
        [int]$Value=3,
        
        [Parameter(Position=1)]
        [string]
        [ValidateSet("Day","Month","Year")]
        $Unit="Month"
    )

    Begin {
        
    }

    Process {}

    End {
        $snap_vms=@()

        $snaps=VIM-Get-Snapshot -Unit $Unit -Value $Value

        #$snaps
        
        $h_contacts = VIM-Get-ContactsHash

        #Snapshots in Contacts Hash Sammeln#
        ForEach($snap in $snaps){
            $vm = $snap.VM
            $contacts = $vm | VIM-Get-Contacts

            $vm | Add-Member -MemberType NoteProperty -Name "SnapshotName" -Value $snap.Name
            $vm | Add-Member -MemberType NoteProperty -Name "SnapshotDescription" -Value $snap.Description
            $vm | Add-Member -MemberType NoteProperty -Name "SnapshotCreated" -Value $snap.Created
            $vm | Add-Member -MemberType NoteProperty -Name "Contacts" -Value ([string]$contacts.Name)

            $snap_vms+=$vm 
        }

        $snap_vms | Format-Table @{Expression={$_.Name};Label="VMName";Width=20},
            @{Expression={$_.SnapshotName};Label="SnapshotName";Width=30},
            @{Expression={$_.SnapshotDescription};Label="SnapshotDescription";Width=50},
            @{Expression={$_.SnapshotCreated};Label="SnapshotCreated";Width=25},
            @{Expression={$_.Contacts};Label="Contacts";Width=50}
    }
}


Function VIM-Get-SnapshotSummary {
<#
.SYNOPSIS
    Liefert VMs mit ihren aktuellen Snapshots
.DESCRIPTION
    Verwendet das "Snapshot Information" Plugin von vCheck
    ich könnte generell einige vCheck Plugins verwenden um schnell einige Informationen zu bekommen
.EXAMPLE
    VIM-Get-SnapshotSummary
#>    
    $VM=Get-VM
    $Date=Get-Date
    $thisModuleDir = Split-Path (Get-Module -ListAvailable Virtual-Infrastructure-Management).Path -parent
    . ($thisModuleDir + "\include\02 Snapshot Information.ps1")

    $Snapshots = @($VM | Get-Snapshot | Where {$_.Created -lt (($Date).AddDays(-$SnapshotAge))} | Get-SnapshotSummary | Where {$_.SnapName -notmatch $excludeName -and $_.Description -notmatch $excludeDesc -and $_.Creator -notmatch $excludeCreator})
    $Snapshots


}

Function VIM-Get-VM-Swapping {
<#
.SYNOPSIS
    Liefert VMs mit Swapping oder Ballooning
.DESCRIPTION
    Noch nix
.EXAMPLE
    VIM-Get-VM-Swapping
#>    

    Get-View -ViewType VirtualMachine | Where {-not $_.Config.Template} | Where {$_.runtime.PowerState -eq "PoweredOn" }| Select Name, @{N="SwapMB";E={$_.Summary.QuickStats.SwappedMemory}}, @{N="MemBalloonMB";E={$_.Summary.QuickStats.BalloonedMemory}} | 
    Where { ($_.MemBalloonMB -gt 0) -Or ($_.SwapMB -gt 0)}


}

Function VIM-Import-TagCategory {

<#
.SYNOPSIS
    Importiert Tag Kategorien in die aktuell verbundene vCenter Umgebung
.DESCRIPTION
    Importiert Tag Kategorien in die aktuell verbundene vCenter Umgebung
    
    Als Pipe Eingabe wird eine Liste von TagCategory Objekten erwartet,
    die in die neue vCenter Umgebung importiert werden

.PARAMETER TagCategory
    Liste von TagCategory Objekten
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Import-TagCategory
#>

    param(
    [Parameter(
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('TC')]
    $TagCategory
    )
    
    Begin{}

    Process{
        $TagCategory | ForEach-Object {
            $tc=$_
            New-TagCategory -Name $tc.Name -Cardinality $tc.Cardinality -Description $tc.Description -EntityType $tc.EntityType
        }
    
    }

    End{}

}

Function VIM-Import-Tag {
<#
.SYNOPSIS
    Importiert Tags in die aktuell verbundene vCenter Umgebung
.DESCRIPTION
    Importiert Tags in die aktuell verbundene vCenter Umgebung
    
    Als Pipe Eingabe wird eine Liste von Tag Objekten erwartet,
    die in die neue vCenter Umgebung importiert werden

.PARAMETER TagCategory
    Liste von Tags Objekten
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Import-Tag
#>

    param(
    [Parameter(
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    $Tag
    )

    Begin{}

    Process{
        $Tag | ForEach-Object {
            $t=$_
            #ACHTUNG Category.Name verwenden. Wenn ich das Category Objekt verwende,
            #versucht PowerCLI eine Beziehung zum Objekt des ALTEN vCenter Server herzustellen
            New-Tag -Name $t.Name -Category $t.Category.Name -Description $t.Description

        }
    }

    End{}

}

Function VIM-Copy-TagStructure {
<#
.SYNOPSIS
    Kopiert die Virtual Infrastructure Management Tag Struktur
    von einem vCenter in ein anderes
.DESCRIPTION
    Verwendet VIM-Import-TagCategory und VIM-Import-Tag um alle Tag Kategorien vom alten vCenter zunächst zu importieren
    Verbindet sich dann auf das neue vCenter und importiert alle Kategorien und Tags
    Danach kann manuell die Tag-Zuordnung im neuen vCenter gemacht werden
.PARAMETER oldVCenter
    Hostname oder IP-Addresse des alten vCenter Servers. Von diesem werden die Tags exportiert
.PARAMETER newVCenter
    Hostname oder IP-Addresse des neuen vCenter Servers. dieser bekommt die Tags importiert
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Virtual-Infrastructure-Management.psm1/VIM-Copy-TagStructure
#>

    param(

    [Parameter(
        Mandatory=$true, 
        ValueFromPipeline=$false
        )
    ]$oldVCenter,


    [Parameter(
        Mandatory=$true, 
        ValueFromPipeline=$false
        )
    ]$newVCenter
    )


    Begin{}

    Process{}

    End{

        Write-Host "Trenne aktuelle vCenter Verbindung..."

        Disconnect-ViServer -Confirm:$false
        Write-Host "Logge in altes vCenter ein... $oldVCenter"
        Connect-ViServer -Server $oldVCenter

        #Exportieren der Tags vom ALTEN vCenter
        $tag_category=Get-TagCategory
        
        $tags= Get-Tag -Category "Ansprechpartner"
        $tags+=Get-Tag -Category "Creator"
        $tags+=Get-Tag -Category "Applikation"
        $tags+=Get-Tag -Category "Storage Stage"
        $tags+=Get-Tag -Category "Kunde"
        $tags+=Get-Tag -Category "Backup Plan"
        $tags+=Get-Tag -Category "DatastoreUsage"
        $tags+=Get-Tag -Category "HostUsage"
        $tags+=Get-Tag -Category "Stage"


        Write-Host "Logge in neues vCenter ein... $newVCenter"
        Connect-ViServer -Server $newVCenter

        Write-Host "Importiere Tag Kategorien..."
        $tag_category | VIM-Import-TagCategory

        Write-Host "Importiere Tags"
        $tags | VIM-Import-Tag

        Write-Host "Erstelle Custom Attributes"
        VIM-Create-CustomAttributes
    
    }


}

Function VIM-Export-TagStructure{
<#
.SYNOPSIS
    Exportiert die Virtual Infrastructure Management Tag Struktur in ein XML File (CliXML)
    Dieses File kann in ein anderes vCenter wieder importiert werden
.DESCRIPTION
    Das exportierte File kannst du dann zum Beispiel zum Kunden kopieren und dort importieren.
    Beim Management System des Kunden muss entsprechend das Virtual-Infrastructure-Management Modul installiert sein
.EXAMPLE
    VIM-Export-TagStructure -File C:Temp\TagStructure.cli.xml
#>

    param($File="TagStructure.cli.xml")

    Begin{}

    Process{}

    End{
        $h_tags = @{}

        #Exportieren der Tags vom ALTEN vCenter
        $tag_category=Get-TagCategory
        
        $tags= Get-Tag -Category "Ansprechpartner"
        $tags+=Get-Tag -Category "Creator"
        $tags+=Get-Tag -Category "Applikation"
        $tags+=Get-Tag -Category "Storage Stage"
        $tags+=Get-Tag -Category "Kunde"
        $tags+=Get-Tag -Category "Backup Plan"
        $tags+=Get-Tag -Category "DatastoreUsage"
        $tags+=Get-Tag -Category "HostUsage"
        $tags+=Get-Tag -Category "Stage"

        $h_tags.Add("Category",$tag_category)
        $h_tags.Add("Tag",$tags)

        $h_tags | Export-Clixml -Path $File

        
    }


}


Function VIM-Import-TagStructure{
<#
.SYNOPSIS
    Importiert eine Virtual Infrastructure Management Tag Struktur
    Die vorher mit VIM-Export-TagStructure exportiert wurde
.EXAMPLE
    VIM-Import-TagStructure -File C:Temp\TagStructure.cli.xml
#>

    param($File="TagStructure.cli.xml")

    Begin{}

    Process{}

    End{
        $h_tags=Import-Clixml $File

        Write-Host "Importiere Tag Kategorien..."
        $h_tags.Category | VIM-Import-TagCategory

        Write-Host "Importiere Tags"#
        $h_tags.Tag | VIM-Import-Tag

        Write-Host "Erstelle Custom Attributes"
        VIM-Create-CustomAttributes

    }
}



Function VIM-Backup-ESXServer(
    $Destination=$global:vim_backup_path
)
{
<#
.SYNOPSIS
    Sichert die Konfiguration aller aktiven ESX-Server der verbundenen vCenter Umgebung
.DESCRIPTION
    vCenter wird benötigt. Es werden alle "Connected" ESX-Server aus vCenter ausgelesen
    aus diesen ESX-Servern wird das ConfigBundle runtergeladen und gespeichert

    Gesichert wird nach: $global:vim_backup_path
.EXAMPLE
    VIM-Backup-ESXServer
.EXAMPLE
    $global:vim_backup_path="\\deslnsrvbackup\Image\VMWare"  
#>
    Begin {}

    Process {}

    End {

        $parent_dir=Get-Item($Destination)     
        $target_dir=Get-Item($Destination + "\ESX-Server")

        
        if($target_dir -eq $null){
            $target_dir=New-Item -ItemType Directory -Path $parent_dir.PSPath -Name "ESX-Server"
        }
        
        if($target_dir.GetType().Name -eq "DirectoryInfo")
        {
            #Alle aktiven Hosts sichern
            Get-VMHost | ?{$_.ConnectionState -eq "Connected"} | ForEach-Object {
                $vmhost=$_
                Get-VMHostFirmware -VMHost $vmhost -BackupConfiguration -DestinationPath ($parent_dir.FullName + "\ESX-Server")
            }
        }
        else
        {
            Write-Error("Verzeichnis '"+ $parent_dir.PSPath + "\ESX-Server" + "' existiert nicht")
        }
        
    }
}



Function VIM-Show-VM-Resources(
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM
)
<#
.SYNOPSIS
    Liefert die VM mit ihren Provisionierten Ressourcen
.DESCRIPTION
    Erwartet als Eingabe eine VM oder eine Liste von VMs
.EXAMPLE
    $VM_TKAnlage=Get-Folder "Live"|Get-Folder "TK-Anlage"|Get-VM
    $VM_TKAnlage | VIM-Show-VM-Resources
.EXAMPLE
    Get-VM | VIM-Show-VM-Resources
.EXAMPLE
    VIM-Show-VM-Resources -VM (Get-VM)
#>
{
    Begin{
        $vms=@()
    }

    Process{
        $VM | ForEach-Object {
            $vms+=$_
        }
    }

    End{
        $vms=$vms | Sort-Object -Property Name

        $vms | Format-Table @{Expression={$_.Name};Label="Name";Width=30},
                @{Expression={$_.NumCpu};Label="Num_vCpu";Width=10},
                @{Expression={[int]$_.MemoryGB};Label="MemoryGB_Provisioned";Width=10},
                @{Expression={[int]$_.ProvisionedSpaceGB};Label="SpaceGB_Provisioned";Width=20},
                @{Expression={[int]$_.UsedSpaceGB};Label="SpaceGB_Used";Width=20}

        $vms | Measure-Object -Property NumCPU,MemoryGB,ProvisionedSpaceGB,UsedSpaceGB -Sum | Select Property, @{Expression={[int]$_.Sum};Label="Sum"} | ft -auto


    }
}

Function VIM-ConvertTo-HTML (
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    $obj
)
{
    Begin{
        $a_out = @()
    }

    Process{
        $obj | ForEach-Object {
            
            $o_out = New-Object -TypeName PSObject
            
            foreach ($property in $_.PSObject.Properties){ 
                #Write-Host "$($property.Name)=$($_.PSObject.properties[$property.Name].Value)"
                Add-Member -InputObject $o_out -MemberType NoteProperty -Name $property.Name -Value ([string]($_.PSObject.properties[$property.Name].Value -join "; "))
                
            }
            #Alle Normalisierten Objekte Sammeln
            $a_out+=$o_out
        }
    }

    End{
        #Alles als HTML Tabelle ausgeben
        $a_out | ConvertTo-HTML -Fragment
    }
}

<#
.SYNOPSIS
    Mailt VMs die von einer Wartung betroffen sind
.DESCRIPTION
    Holt Informationen von allen VMs auf dem / den angegebenen Hosts
#>
Function VIM-Mail-AffectedVMs (
    <#
    Host der Von Wartung betroffen ist
    Kann auch ein Array von VMHosts sein (Get-VMHost)
    #>
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    $VMHost,
    <#
    E-Mail-Addresse an die das Ergebnis übermittelt werden soll
    #>
    [string]$To="rudolf.achter@megatech-communication.de"
)
{
    Begin{
        $a_hosts=@()
    }

    Process{
        ForEach($vhost in $VMHost){
            $a_hosts+=Get-VMHost $vhost
        }
    }

    End{
        $a_hosts | Get-VM | ? PowerState -eq PoweredOn | VIM-Get-VMValue | Select VMHost,Name,Ansprechpartner,Applikation,Stage | 
            VIM-Mail -To $To -Subject "Von Wartung betroffene VMs" -Description "Betroffene VMs" 
    }
}

<#
.SYNOPSIS
    Versucht VMs korrekt herunterzufahren.
    Wenn das nicht funktioniert, werden sie hart ausgeschaltet
.DESCRIPTION
    Der Shutdown Prozess verläuft immer Synchron. Das heisst es wird immer gewartet
    bis die VM heruntergefahren ist, bevor mit dem nächsten Schritt fotgefahren wird.
    Somit kann dieses Cmdlet in Scripts verwendet werden und nachfolgenden Aktionen
    können einfach dran gehängt werden, ohne sich weitere Gedanken zu machen
#>
Function VIM-Shutdown-VM {
    param(
        #VMs die heruntergefahren werden sollen
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,

        #Nach dieser Zeit werden die VMs hart ausgeschaltet
        $SoftShutdownSeconds=300
    )

    Begin{
        #VMs die ich ausschalten muss
        $a_vms=@()

        #Alle VMs
        $all_vms=@()
    }

    Process{
        #Ich brauche nur VMs behandeln die eingeschaltet sind
        Get-VM $VM | ? PowerState -eq "PoweredOn" | ForEach-Object {
            $a_vms += $_
        }

        Get-VM $VM | ForEach-Object {
            $all_vms += $_
        }

    }

    End{
        
        if($a_vms.Length -lt 1){
            #Wenn wir nichts Herunterzufahren haben, können wir hier aufhören
            $all_vms
            return
        }

        $vmcount=$a_vms.Length    
        $i=0
        
        <#
            Erst mal allen VMs einen Shutdown Befehl geben
            dann können die erst mal versuchen herunterzufahren
        #>
        $a_vms | ForEach-Object {
            $vm=$_
            $i++
            $vmpercent=100/$vmcount*$i
            Write-Progress -Activity "Shutdown VM" -Status "$i von $vmcount" -Id $global:progress_vm_count -PercentComplete $vmpercent

            Write-Verbose ("Shutdown "+$vm.Name)

            $shutdown_vm=Shutdown-VMGuest -VM $vm -Confirm:$false

        }
        #Shutdown Befehle sind hiermit abgeschlossen
        Write-Progress -Activity "Shutdown VM" -Status "$i von $vmcount" -Id $global:progress_vm_count -PercentComplete $vmpercent -Completed


        $wait_start_time=Get-Date
        $wait_current_time=Get-Date
        $wait_timespan=$wait_current_time - $wait_start_time
        
        # Solange noch VMs eingeschaltet sind
        Do{
            Write-Progress -Activity "Waiting for VMs to shutdown" -Status ( [string]("{0:n1}" -f $wait_timespan.TotalSeconds) +" of " + [string]$SoftShutdownSeconds + " Seconds") `
                -Id $global:progress_cur_action -SecondsRemaining ($SoftShutdownSeconds - $wait_timespan.TotalSeconds) -PercentComplete (100/$SoftShutdownSeconds*$wait_timespan.TotalSeconds)

            #Get-VM $a_vms | Select Name,PowerState | ft
            Start-Sleep -Seconds 2

            $wait_current_time=Get-Date
            $wait_timespan=$wait_current_time - $wait_start_time
            
            #Weiter Ausführen so lange
            # - noch eine VM auf PoweredOn steht
            # - und der Wait Timer noch nicht abgelaufen ist
        }While((Get-VM $a_vms).PowerState -contains "PoweredOn" -and $wait_timespan.TotalSeconds -lt $SoftShutdownSeconds)

        Write-Progress -Activity "Waiting for VMs to shutdown" -Status "Completed" -Id $global:progress_cur_action -Completed

        #Wenn der Wait Timer abgelaufen ist: Wenn jetzt noch VMs an sind dann schalten wir die hart aus!
        Get-VM $a_vms | ? PowerState -eq "PoweredOn" | Stop-VM -Confirm:$false

        Get-VM $all_vms

    }

}

<#
.SYNOPSIS
    Archiviert abgelaufene VMs
.DESCRIPTION
    VMs deren Nutzungszeitraum "VIM.DateUsedUntil" abgelaufen ist werden
    mit VIM-Archive-VM heruntergefahren

    Zur Sicherheit Archiviere ich KEINE LIVE VMs automatisch
#>
Function VIM-Archive-VM-EndOfLife{
    param (
    [Parameter(Position=0)] $DaysToUsedUntil=0
    )
    
    $vms=VIM-Get-VM-EndOfLife -DaysToUsedUntil $DaysToUsedUntil | VIM-Get-VMValue | 
        ? Stage -ne "Live" | ? Stage -ne "Archiv Stage"
    
    if($vms.Count -gt 0){
        VIM-Archive-VM -VM $vms
    }
}


<#
.SYNOPSIS
    Archiviert angegebene VMs
.DESCRIPTION
    die VMs werden wie folgt archiviert
    1. Heruntergefahren
    2. das Starten verhindert (mit einer ACL)
    3. Auf einen billigen Datastore archiviert
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Archive-VM
#>
Function VIM-Archive-VM {
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,
        
        [switch]$Confirm=$false,

        $SoftShutdownSeconds=300
    )

    Begin{
        $vms=@()
    }

    Process {
        $VM | ForEach-Object {
            $vms +=$_
        }
    }

    End {
        #1. die abgelaufenen VMs werden heruntergefahren
        VIM-Shutdown-VM -VM $vms -SoftShutdownSeconds $SoftShutdownSeconds

        $vms=Get-VM $vms
    
        #2. Das starten wird verhindert
        #Hierzu wird eine ACL für sämtliche Gruppen gesetzt die mit den VMs arbeiten
        $admin_acc=Get-VIAccount -ID $global:vim_ad_admingroup -Domain $global:vim_ad_domain -Group
        $user_acc=Get-VIAccount -ID $global:vim_ad_usergroup -Domain $global:vim_ad_domain -Group

        #//XXX die Warnung die hier ausgegeben wird "This parameter no longer accepts multiple values"
        #Das ist offensichtlich eine Warnung die fälschlicherweise ausgegeben wird
        #Wird nicht weiter behandelt. So lange es funktioniert passts ja
        #Siehe auch: https://communities.vmware.com/thread/526610


        #New-VIPermission -Principal $admin_acc -Entity $vms -Role (Get-VIRole $global:vim_archive_admin_role)
        #New-VIPermission -Principal $user_acc -Entity $vms -Role (Get-VIRole $global:vim_archive_user_role)

        #Diese Version der New-VIPermission Befehle sorgt jedenfalls dafür, dass immer nur einzelne Parameter übergeben werden
        ForEach ($entity in $vms){
            ForEach ($acc in $admin_acc){
                New-VIPermission -Entity $entity.Name -Principal $acc.Name -Role $global:vim_archive_admin_role
            }
        }

        ForEach ($entity in $vms){
            ForEach ($acc in $user_acc){
                New-VIPermission -Entity $entity.Name -Principal $acc.Name -Role $global:vim_archive_user_role
            }
        }

        #//XXX hier weiter
        #Zum Archive Datastore verschieben
        $archive_datastore=Get-Datastore -Tag (Get-Tag -Category "DatastoreUsage" -Name "Archiv")

        $vms | ForEach-Object {
            $vm=$_

            $current_datastore=($vm | Get-Datastore) -join ";"

            $current_folderpath=($vm | Get-VItemPath).Path

            $vm | VIM-Set-VMValue -ArchiveOrigFolderPath $current_folderpath

            if($current_datastore -ne $archive_datastore.Name){
                #Speichern auf welchem Datastore die VM war
                $vm | VIM-Set-VMValue -ArchiveOrigDatastore $current_datastore -ArchiveDateArchived ([string](Get-Date -format "yyyy-MM-dd HH:mm"))

                #Die Stage auf "Archiv" wechseln
                Remove-TagAssignment -TagAssignment (Get-TagAssignment -Entity $vm -Category "Stage") -Confirm:$false
                New-TagAssignment -Tag (Get-Tag -Category "Stage" -Name "Archiv Stage") -Entity $vm

                <#
                Zu guter letzt die VM umziehen
                Es wird umgezogen
                    - Datastore
                    - InventoryLocation
                    - DiskStorageFormat wird auf Thin geändert

                #>
                $archiv_folder=Get-Folder -Id (Get-Item "vi:\megatech.local\vm\Archiv").Id
                $vm | Move-VM -Datastore (Get-Datastore $archive_datastore) -DiskStorageFormat Thin -InventoryLocation $archiv_folder -RunAsync -Confirm:$Confirm
            }
        }


        #Wir benachrichtigen die Besitzer, dass die VMs archiviert wurden
        $vms | VIM-Mail-VM-Archived


    }
}

function Get-VItemPath{
<#
.SYNOPSIS
	Returns the folderpath for a folder
.DESCRIPTION
	The function will return the complete folderpath for
	a given folder, optionally with the "hidden" folders
	included. The function also indicats if it is a "blue"
	or "yellow" folder.
.NOTES
	Authors:	Luc Dekens
.PARAMETER Folder
	On or more folders
.PARAMETER ShowHidden
	Switch to specify if "hidden" folders should be included
	in the returned path. The default is $false.
.EXAMPLE
	PS> Get-FolderPath -Folder (Get-Folder -Name "MyFolder")
.EXAMPLE
	PS> Get-Folder | Get-FolderPath -ShowHidden:$true
.LINK
    http://www.lucd.info/2010/10/21/get-the-folderpath/
#>
 
	param(
	[parameter(valuefrompipeline = $true,
	position = 0,
	HelpMessage = "Enter a folder")]
	$Item,
	[switch]$ShowHidden = $false
	)
 
	begin{
		$excludedNames = @("Datacenters")#,"vm","host"
	}
 
	process{
		$Item | %{
			$fld = $_.Extensiondata
			#$fldType = "yellow"
            
            #Write-Host("ChildType: " + $fld.ChildType)
            <#
			if($fld.ChildType -contains "VirtualMachine"){
				$fldType = "blue"
			}
            #>
			#$path = $fld.Name

			while($fld.Parent){
				$fld = Get-View $fld.Parent
                
                #VM selbst nicht in den Pfad aufnehmen

				if((!$ShowHidden -and $excludedNames -notcontains $fld.Name) -or $ShowHidden){
					$path = $fld.Name + "\" + $path
				}
                #$path = $fld.Name + "\" + $path

			}
            $path='vi:\'+$path


			$row = "" | Select Name,Path
			$row.Name = $_.Name
			$row.Path = $path
			#$row.Type = $fldType
			$row
		}
	}
}

<#
.SYNOPSIS
    Korrigiert die Situation wenn VMs mit einer alten Version von VIM-Archive-VM archiviert wurden
.DESCRITPTION
    Dokumentiert nur den VIM.ArchiveOrigFolderPath und verschiebt die VM ins Archiv Folder
#>
Function Move-VMtoArchiveCorrection {
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

    Begin{
        $archiv_folder=Get-Folder -Id (Get-Item "vi:\megatech.local\vm\Archiv").Id
    }

    Process{
        $VM | ForEach-Object{
            $o_vm=$_

            $current_folderpath=($o_vm | Get-VItemPath).Path
            $o_vm | VIM-Set-VMValue -ArchiveOrigFolderPath $current_folderpath | Out-Null
            $o_vm | Move-VM -InventoryLocation $archiv_folder

        }
    
    }

    End{}

}

Function VIM-Mail-VM-AffectedToContacts{
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,

        $Subject="Test",

        $Description="Test",

        $Columns=@("Name", "VIM.DateCreated", "VIM.DateUsedUntil", "Stage", "Applikation", "Notes"),

        $MailTo="",

        [switch]$PlainHTML=$false
        
        )

    Begin {
        $a_vm=@()
    }

    Process {
        #VMs in Array zusammen pressen
        Foreach($v in $VM){
            $a_vm += $v
        }
    }

    End{
        $h_contacts = VIM-Get-ContactsHash

        #VMs in Contacts Hash Sammeln
        ForEach ($vm in $a_vm){
            $contacts = $vm | VIM-Get-Contacts

            ForEach($contact in $contacts){
                #//XXX hier weiter
                $h_contacts.$($contact.Address).Data+=VIM-Get-VMValue $vm
                
            }
        }

        ForEach($ck in $h_contacts.Keys){
            if(($h_contacts.Item($ck).Data | Measure-Object).Count -gt 0){
                
                #$h_contacts.Item($ck)

                $subj=[System.Web.HttpUtility]::HtmlEncode( $Subject + " : "+ ($h_contacts.Item($ck)).Name)
                
                if($PlainHTML){
                    $desc=$Description
                }
                else{
                    $desc=[System.Web.HttpUtility]::HtmlEncode( $Description )
                }

                Write-Host ("Subject: $subj")
                Write-Host ("Description: $desc")
                #$h_contacts.Item($ck).Data

                $mail_objects=$h_contacts.Item($ck).Data | Select $Columns

                $h_cols=@{}

                #$mail_objects 
                #//XXX Empfänger korrigieren

                if($MailTo -eq ""){
                    $mail_recipient = $h_contacts.Item($ck).Address
                }
                else {
                    $mail_recipient = $MailTo
                }


                VIM-Mail -Objects $mail_objects -To $mail_recipient -Subject $subj -Description $desc

            }
        }
    }
}


Function VIM-Mail-VM-Archived{
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,

        $MailTo=""
        
        )

    Begin {
        $a_vm=@()
    }

    Process {
        ForEach($v in $VM){
            $a_vm+=$v
        }
    }

    End {
        $Subject="VMs die archiviert wurden"

        $Description = "<p>Diese VMs wurden archiviert und heruntergefahren, da ihr Nutzungszeitraum abgelaufen ist. </br>"
        $Description+= "Sollte hiervon eine VM wieder ben&ouml;tigt werden, wende dich bitte an einen VMWare-Administrator</p>"
        $Description+= 'F&uuml;r allgemeine Informationen zu diesem Prozess siehe: <a href="http://wiki.megatech.local/mediawiki/index.php/Standardprozess/Virtual_Machine_Lifecycle_Management">Standardprozess/Virtual Machine Lifecycle Management</a> im Wiki'

        VIM-Mail-VM-AffectedToContacts -VM $a_vm -Subject $Subject -Description $Description -MailTo $MailTo -PlainHTML
    }
}

<#
.SYNOPSIS
    Hebt den Archivierungszustand von VMs wieder auf
.DESCRIPTION
    Macht im Grunde das Umgekehrte von VIM-Archive-VM
    Genauere Beschreibung folgt noch
.PARAMETER VM
    (Get-VM) Objekt Virtuelle Maschine die wiederhergestellt wird
.PARAMETER ToStorage
    Datastore (Get-Datastore) / Storage Objekt auf das wiedhergestellt wird
.PARAMETER ToHost
    VMHost Objekt (Get-VMHost) zu dem wiederhergestellt wird
.PARAMETER ToFolder
    VMFolder (Get-Folder) Objekt zu dem wiederhergestellt wird
.PARAMETER StartImmediately
    Switch. Wenn gesetzt wird die VM unmittelbar nach der wiederherstellung gestartet
.PARAMETER Confirm
    Wird scheinbar in diesem Cmdlet nicht verwendet
.EXAMPLE
    Get-VM deslnvmowncl | VIM-UnArchive-VM
.EXAMPLE
    Get-VM "*.viblab.local" | ?{($_ | Get-Datastore).Name -contains "Netgear_LUN_Archive"} | VIM-Get-VMValue | ?{(Get-Date $_."VIM.ArchiveDateArchived") -gt (Get-Date "2019-11-17 00:00")} | Select-Object -First 1 
.EXAMPLE
    Get-VM "deslnonexatt03" | VIM-UnArchive-VM -ToStage Test -ToStorage (Get-Datastore "NFS_testesxnfs") -ToFolder (Get-Folder -Id (Get-Item vi:\megatech.local\vm\Test\Server\).Id)
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-UnArchive-VM
#>
Function VIM-UnArchive-VM{
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
		[ArgumentCompleter(
			{
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                Get-VM -Name ("*"+$WordToComplete+"*") -Tag (Get-Tag -Category "Stage" -Name "Archiv Stage")
            })
        ]
        $VM,
        [Parameter(Mandatory=$true)][ValidateSet("Test","Live","Development")]$ToStage,
        <#
            Zu dieser Storage wird die VM wiederhergestellt (Name, wie in der vCenter Speicher Ansicht)
            Wird $ToStorage nicht angegeben, wird die zuvor gespeicherte Storage verwendet
            #//XXX Hier mach ein Argument Completer Sinn

		[ArgumentCompleter(
			{
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
            //XXX hier weiter
        #>
		[ArgumentCompleter(
			{
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                Get-Datastore -Name ("*"+$WordToComplete+"*") | Sort-Object -Property "FreeSpaceGB" -Descending | ForEach-Object {
                    $s_storage_info="FreeSpace: " + [int]$_.FreeSpaceGB + "GB" #+  "Capacity: " + [int]$_.CapacityGB + "GB"
                    if($vm=Get-VM $FakeBoundParams.VM){
                        $s_storage_info+=" VMProvisionedSize: "+[string]([int]$vm.ProvisionedSpaceGB) + "GB"
                    }
                    [string]('"' + $_.Name + '"' + " <# " + $s_storage_info + " #>")
                }
            })
        ]
        [Parameter(Mandatory=$false)]$ToStorage="",
        
        <#
            Auf diesem ESX-Host wird die VM dann wieder gestartet
        #>
        #Argument Completer wird am ende dieser Funktion registriert
        [Parameter(Mandatory=$false)]$ToHost="",

        [Parameter(Mandatory=$false)]$ToFolder="",

        [switch]$StartImmediately=$false,

        [switch]$Confirm=$false
    )

    Begin {
        $vms=@()
    }

    Process {
        $VM | ForEach-Object {
            $vms+=$_
        }
    }

    End {

        $admin_acc=Get-VIAccount -ID $global:vim_ad_admingroup -Domain $global:vim_ad_domain -Group
        $user_acc=Get-VIAccount -ID $global:vim_ad_usergroup -Domain $global:vim_ad_domain -Group




        $vms | ForEach-Object {

            Try {
                $vm=Get-VM $_

                $vmvals=$vm | VIM-Get-VMValue -ErrorAction Stop

                if($ToStorage -eq ""){
                    $TargetStorage = Get-Datastore $vmvals."VIM.ArchiveOrigDatastore" -ErrorAction Stop
                }
                else{
                    $TargetStorage = Get-Datastore $ToStorage -ErrorAction Stop
                }

                if($ToHost -eq ""){
                    $TargetHost = Get-VMHost $vm.VMHost -ErrorAction Stop
                }
                else{
                    $TargetHost = Get-VMHost $ToHost -ErrorAction Stop
                }

                if($ToFolder -eq ""){

                    #Target Folder ermitteln
                    $TargetFolder=Get-Folder -Id (Get-Item $vm."VIM.ArchiveOrigFolderPath").Id

                    if($TargetFolder.Count -ne 1){
                        Write-Error "TargetFolder ist nicht eindeutig"
                    }

                    #Der eigentliche Move der VM
                    $vm=Move-VM -VM $vm -Destination $TargetHost -Datastore $TargetStorage -InventoryLocation $TargetFolder -ErrorAction Stop
                }
                else{
                    $vm=Move-VM -VM $vm -Destination $TargetHost -Datastore $TargetStorage -InventoryLocation $ToFolder -ErrorAction Stop
                }

                

                Start-Sleep -Seconds 5

                #Refresh der VM
                $vm = Get-VM $vm

                $vm | VIM-Set-VMValue -ArchiveOrigDatastore "" -ArchiveDateArchived ""

            
                #Permissions wieder Normal setzen
                ForEach ($acc in $admin_acc){
                    #VORSICHT! Wenn -Entity und -Principal bei Get-VIPermission NICHT matchen dann Matcht das nächstbeste
                    #In meinem Testfal war Das die Admin ACL für unsere "VMWare-Administrators"
                    #Deswegen noch der genauere Vergleich mit "Where-Object"
                    Get-VIPermission -Entity $vm -Principal $acc | 
                        Where-Object { $_.Entity.Uid -eq $vm.Uid } |
                            Remove-VIPermission -Confirm:$false | Out-Null
                }

                ForEach ($acc in $user_acc){
                    Get-VIPermission -Entity $vm -Principal $acc | 
                        Where-Object { $_.Entity.Uid -eq $vm.Uid } |
                            Remove-VIPermission -Confirm:$false | Out-Null
                }

                #Die Stage auf zum "Ziel" wechseln
                Remove-TagAssignment -TagAssignment (Get-TagAssignment -Entity $vm -Category "Stage") -Confirm:$false | Out-Null
                New-TagAssignment -Tag (Get-Tag -Category "Stage" -Name $ToStage) -Entity $vm | Out-Null

                if($StartImmediately){
                    $vm = Get-VM $vm
                    Start-VM $vm | Out-Null
                }
                #VM zurück geben
                Get-VM $vm
            }
            Catch{
                #Error Handling -> sollte man öfter so machen
                Write-Error "VM konnte nicht erfolgreich UnArchiviert werden"
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
            }


        }
    }

}

Register-ArgumentCompleter -CommandName VIM-UnArchive-VM -ParameterName ToHost -ScriptBlock $global:VimArgumentCompleters.VMHost

Function _Get-Shapes {
    param(
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $Shapes
    )

    Begin{}

    Process{
        $Shapes | ForEach-Object {
            $shape=$_
            #UnterShapes zurückgeben
            $shape.Shapes

            #Eigen Shapes zurückgeben
            $shape
        }
    }

    End {

    }
}


Function _Get-Shape-ByName {
    param(
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $VisioPage,
        
        [Parameter(Mandatory=$true)]
        $ShapeName
    )

    Begin{}

    Process{
        $VisioPage | ForEach-Object{
            $o_page=$_

            <#
                Wenn wir nach einem Array von Shape Names suchen dann muss der Name
                Nur mitglied in dem Array sein
            #>
            if($ShapeName.GetType().BaseType.Name -eq "Array"){
                Write-Verbose "_Get-Shape-ByName: Array Search"
                _Get-Shapes -Shapes $o_page.Shapes | Where-Object{ $ShapeName -contains $_.Name }
            }
            else{
                Write-Verbose "_Get-Shape-ByName: Basic Search"
                _Get-Shapes -Shapes $o_page.Shapes | Where-Object Name -eq $ShapeName
            }
        }
    }

    End{}

}

<#
.SYNOPSIS
    Aktualisiert ein Visio Dokument anhand von Werten die ich aus der
    VMWare Infrastrktur geholt habe
#>
Function VIM-Update-Visio{

    
    param(
        #$VisioDoc="M:\MEGATECH-Netzwerk\Umgebungen\Storage-Uebersicht-AutomateTestV2.vsdx"
        $DocName="Storage-Uebersicht-AutomateTestV2.vsdx"
    )

    If($DocName -eq "" -or $SheetName -eq ""){
        Write-Error("Kein Visio Dokument Fokussiert. Wähle zu erst mit Set-VisioFocus ein Dokument, dass du in Visio geöffnet hast")
        return
    }


    
    #$o_app = New-Object -ComObject Visio.Application

    $o_app = [Runtime.Interopservices.Marshal]::GetActiveObject('Visio.Application')

    $o_doc = $o_app.Documents | ?{$_.Name -eq $DocName}
    $o_page=$o_doc.Pages[1]

    $o_page.GetShapesLinkedToData


    $o_datastores=Get-Datastore

    $a_shapenames=@()
    
    #Ich suche nach Alle VMWARE_ Shapes
    Foreach($ds in $o_datastores){
        $a_shapenames+=("VMWARE_" + $ds.Name)
    }



    #Hier wird die eigentliche Suche durchgeführt
    $o_shapes=_Get-Shape-ByName -VisioPage $o_doc.Pages[1] -ShapeName  $a_shapenames #| ft Name,NameId,Text
    

    Get-Datastore | ForEach-Object {
        $o_datastore=$_

        $myshape=$o_shapes | ? Name -eq ("VMWARE_" + $o_datastore.Name)
        if($myshape){

            $ds_percent=($o_datastore.CapacityGB - $o_datastore.FreeSpaceGB) / $o_datastore.CapacityGB * 100

            #//XXX hier weiter

            $myshape.Cells("Prop.percent").Formula=$ds_percent
            $myshape.Cells("Prop.size_gb").Formula=$o_datastore.CapacityGB
            $myshape.Cells("Prop.free_gb").Formula=$o_datastore.FreeSpaceGB
            $myshape.Cells("Prop.used_gb").Formula=($o_datastore.CapacityGB - $o_datastore.FreeSpaceGB)
        }
    }
}

<#
.SYNOPSIS
    Sucht die virtuellen Maschinen die Disks der angegebenen virtuellen Maschine
    blockieren (lock)
.DESCRIPTION
    Es werden alle Files der angegebenen Maschine durchsucht.
    Es werden alle VMs gesucht die Disks der angegebenen Maschine gemounted haben
    Die Maschinen die diese zusätzlichen Mounts haben werden zurückgegeben
    Als zusätzliches NoteProperty wird der DiskFileName der gemounteten Disk zurückgegeben
.PARAMETER VM
    VM von der eine Disk gelocked ist
.EXAMPLE
    VIM-Get-VM-LockingDisks -VM $VM | FT -AutoSize Name,DiskFileName

#>
Function VIM-Get-VM-LockingDisks {
    
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
            $LockedVM=$_
            
            $LockedVM_Dirs=@()

            $LockedVM | Get-HardDisk | ForEach-Object {
                $HardDisk=$_

                $match=$HardDisk.Filename | Select-String -Pattern "^\[([^\]]+)\] (.*)?/(.*)$"

                $s_datastore=$match.Matches.Groups[1]
                $s_dir=$match.Matches.Groups[2]
                $s_filename=$match.Matches.Groups[3]

                $o_dir=New-Object -TypeName PSObject -Property @{
                                        Datastore = $s_datastore.Value;
                                        Path = $s_dir.Value;
                                    }

                <#
                If(-not [string]($LockedVM_Dirs.Datastore + "/" + $LockedVM_Dirs.Path) -contains ($o_dir.Datastore + "/" + $o_dir.Path)){
                    $LockedVM_Dirs+=$o_dir
                }
                #>
                $DoAdd=$true

                ForEach($dir in $LockedVM_Dirs){
                    if(
                        (
                        $dir.Datastore -eq $o_dir.Datastore -and
                        $dir.Path -eq $o_dir.Path
                        )
                      )
                    {
                        $DoAdd=$false
                    }

                }

                if($DoAdd){
                    $LockedVM_Dirs+=$o_dir
                }


            }

            $LockedVM_Dirs | ForEach-Object{
                
                $o_dir=$_

                $ds = Get-Datastore -Name $o_dir.Datastore | % {Get-View $_.Id}
                $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
                $fileQueryFlags.FileSize = $true
                $fileQueryFlags.FileType = $true
                $fileQueryFlags.Modification = $true
                $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
                $searchSpec.details = $fileQueryFlags
                $searchSpec.matchPattern = "*.vmdk"
                $searchSpec.sortFoldersFirst = $true
                $dsBrowser = Get-View $ds.browser
                $rootPath = "[" + $ds.Name + "]" + "/" + $o_dir.Path 
                $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)

                $a_files=@()

                ForEach($file in $searchResult.File){
                    $a_files+=($searchResult.FolderPath + "" + $file.Path)
                }

                Get-VM | ?{$_.Name -ne $LockedVM.Name} | ForEach-Object {
                    $vm=$_

                    $vm_disks=$vm | Get-HardDisk

                    ForEach($disk in $vm_disks){
                        if($a_files -contains $disk.Filename){
                            #//XXX hier weiter
                            $vm | Add-Member -MemberType NoteProperty -Name DiskFileName -Value $disk.FileName -Force
                            $vm
                        }
                    }
                }

            }
        }
    }

    End{}
}

<#
.SYNOPSIS
    Zeigt virtuelle Maschinen die Disks der angegebenen virtuellen Maschine
    blockieren (lock)
.PARAMETER VM
    VM von der eine Disk gelocked ist
.EXAMPLE
    Get-VM deslntksm | VIM-Show-VM-LockingDisks

    #Ergebnis könnte so aussehen
    Name          DiskFileName                                
    ----          ------------                                
    deslnsrvvdp02 [VSA_TESTLAP_LUN01] deslntksm/deslntksm.vmdk
#>

Function VIM-Show-VM-LockingDisks {

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

    VIM-Get-VM-LockingDisks -VM $VM | FT -AutoSize Name,DiskFileName
}

<#
.SYNOPSIS
    Erstellt einen neuen Netzwerk Pool
.PARAMETER Name

.PARAMETER Network

.PARAMETER Netmask

.PARAMETER Gateway

.PARAMETER DnsServer
    Leerzeichen getrennte DNS Server Liste
    z.B.:
    "192.168.100.16 192.168.100.22"
.PARAMETER Domain

.PARAMETER DnsSearchPath
    Leerzeichen Suchliste
    z.B.:
    "site1.viblab.local viblab.local"
.PARAMETER HostPrefix

.PARAMETER HttpProxy
#>
Function VIM-New-IPv4Pool {
    param(
        $Name,
        $Network,
        $Netmask,
        $Gateway="",
        $DnsServer="",
        $Domain="",
        $DnsSearchPath = "",
        $HostPrefix = "",
        $HttpProxy = ""
    )
    <#

    $ipPoolManager=Get-View -Id 'IPPoolManager'

    $ipPoolManager | Get-Member

    $pools=$ipPoolManager.QueryIpPools($dc)

    $dc=Get-Datacenter
    $dc.Id



    $pools | Get-Member


    $ipv4Config=New-Object VMware.Vim.IpPoolIpPoolConfigInfo

    $ipv4Config | Get-Member
    #>
    
    #DataCenter Managed Object Reference
    $dc=(Get-Datacenter).ExtensionData.MoRef

    #Eine neue IPv4 Konfig
    $ipv4Cfg=New-Object VMware.Vim.IpPoolIpPoolConfigInfo
    $ipv4Cfg.SubnetAddress=$Network
    $ipv4Cfg.Netmask=$Netmask
    $ipv4Cfg.Gateway=$Gateway
    $ipv4Cfg.Dns=$Dns

    #Eine Netzwerk Association
    $nwAss=New-Object VMware.Vim.IpPoolAssociation[] (1)
    $nwAss[0] = New-Object VMware.Vim.IpPoolAssociation
    $myNetwork=(Get-View -ViewType Network | ? Name -eq $Name)
    $nwAss[0].Network = $myNetwork.MoRef
    $nwAss[0].NetworkName = $myNetwork.Name

    #Und ein IpPool in dem Alles zusammen kommt

    $IpPool=New-Object VMware.Vim.IpPool
    $IpPool.Name = $Name
    $IpPool.DnsDomain = $Domain
    $IpPool.DnsSearchPath = $DnsSearchPath
    $IpPool.HostPrefix = $HostPrefix
    $IpPool.HttpProxy = $HttpProxy
    $IpPool.Ipv4Config = $ipv4Cfg
    $IpPool.NetworkAssociation = $nwAss

    $ipPoolManager=Get-View -Id 'IPPoolManager'

    $NewPoolId=$ipPoolManager.CreateIpPool($dc,$IpPool)
    #Ich gebe den soeben neu erstellten IPPool zurück
    $ipPoolManager.QueryIpPools($dc) | ? Id -eq $NewPoolId
}

Function VIM-Remove-IPv4Pool {
    param(
        $Name
    )

    $ipPool=VIM-Get-IPv4Pool -Name $Name
    $dc=(Get-Datacenter).ExtensionData.MoRef
    $ipPoolManager = Get-View -Id ‘IpPoolManager’

    $ipPoolManager.DestroyIpPool($dc,$ipPool.Id,$true)
}


Function VIM-Get-IPv4Pool {

    param(
        $Name=""
    )

    $ipPoolManager = Get-View -Id ‘IpPoolManager’

    #DataCenter Managed Object Reference
    $dc=(Get-Datacenter).ExtensionData.MoRef
    
    if($Name -ne ""){
        $ipPoolManager.QueryIpPools($dc) | ? Name -eq $Name
    }
    else{
        $ipPoolManager.QueryIpPools($dc)
    }
}


<#
.SYNOPSIS
    Holt die ResourceConfiguration aller VMs die eine Reservierung haben
    du bekommst also die Ressourcen Konfiguration aller VMs zurück die 
    bereits eine Reservierung haben
.EXAMPLE
    VIM-Get-ResourceReservation | Set-VMResourceConfiguration -CpuReservationMhz 0 -MemReservationMB 0
.EXAMPLE
    #In diesem Beispiel werden die CPU Reservierungen der Live VMs halbiert
    Get-VM -Tag (Get-Tag -Category "Stage" -Name "Live") | VIM-Get-ResourceReservation | %{Set-VMResourceConfiguration -Configuration $_ -CpuReservationMhz ([int]$_.CpuReservationMhz / 2)}
#>
Function VIM-Get-ResourceReservation {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)   
    )

    Begin{}

    Process{
        $VM | ForEach-Object {
            $o_vm=$_

            $o_vm | Get-VMResourceConfiguration | Where-Object {
                $_.CpuReservationMhz -gt 0 -or `
                $_.MemReservationMB -gt 0
            }
        }
    }

    End{}
}

<#
.SYNOPSIS
    Zeigt ResourceConfiguration aller VMs (nur für die VMs die eine Reservierung haben)
.EXAMPLE
    VIM-Show-ResourceReservation -Presentation "GridWithVMValue"
#>
Function VIM-Show-ResourceReservation {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM=(Get-VM),
        [ValidateSet("Text","Grid","GridWithVMValue")]$Presentation="Text"
    )

    Begin{
        $a_vm=@()
    }

    Process{
        $VM | ForEach-Object {
            $a_vm+=$_
        }
    }

    End{

        $showProps=@(
                    "VM","NumCpuShares","CpuReservationMhz",
                    "NumMemShares","MemSharesLevel","MemReservationMB"
                    )


        Switch($Presentation){
            "Text" {

                VIM-Get-ResourceReservation -VM $a_vm | Format-Table -AutoSize -Property $showProps
                Break
            }
            "Grid" {
                VIM-Get-ResourceReservation -VM $a_vm | Select-Object -Property $showProps | Out-GridView
                Break
            }
            "GridWithVMValue"{
                <#
                $columns = @("Name")
                $columns += $global:vim_custom_attributes.Name
                $columns += $global:vim_tags
                $columns += @("missingTags")
                #>

                $columns = @(
                    "Stage",
                    "Ansprechpartner",
                    "Creator",
                    "Applikation",
                    "VIM.DateUsedUntil"
                )

                VIM-Get-ResourceReservation -VM $a_vm | ForEach-Object {
                    $o_resource=$_
                    #$o_resource 
                    $vmvalue=VIM-Get-VMValue -VM ([string]$o_resource.VM)
                        
                    ForEach($column in $columns){
                        $o_resource | Add-Member -MemberType NoteProperty -Name $column -Value $vmvalue.$column -Force
                            
                    }
                    $o_resource
                    
                } | Select-Object -Property ($showProps + $columns)  | Out-GridView
                Break
            }
        }
    }
}

<#
.SYNOPSIS
    Gibt VMs zurück die aus unerklärlichen Gründen nicht gestartet werden können
.DESCRIPTION
    Bei ESX-Server Abstürzen, Storage Problemen und dergleichen, kann es vorkommen, dass die
    vCenter Datenbank nicht mehr den richtigen Status über die Startbarkeit von virtuellen Maschinen
    wiedergibt. Dadurch wird der Start der virtuellen Maschine verhindert obwohl diese wieder voll
    Einsatzbereit ist.
    In vielen Fällen ist es dann notwendig diese VM komplett aus dem vCenter Bestand zu entfernen und
    wieder neu zu registrieren. Es gibt zwar Workarounds derartige Probleme direkt in der vCenter Postgres
    Datenbank zu beheben. Derartige Arbeiten könnten aber zu inkosistenzen in der vCenter Datenbank führen.
    Daher ist es empfehlenswerter eine Lösung über die vCenter API anzustreben
.EXAMPLE
    VIM-Get-VM-NotStartable
.EXAMPLE
    #DAS HIER IST MIT VORSICHT ZU GENIESSEN!!!
    VIM-Get-VM-NotStartable | VIM-ReRegister-VM
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-NotStartable
#>
Function VIM-Get-VM-NotStartable {
    Get-VM | ? { $_.ExtensionData.DisabledMethod -contains "PowerOnVM_Task" -and $_.PowerState -eq "PoweredOff"}
}

<#
.SYNOPSIS
    Exportiert die Metadaten einer virtuellen Maschine in eine XML-Datei (CliXML)
.DESCRIPTION
    Mit dieser Funktion können die Metadaten einer virtuellen Maschine gesichert werden.
    Im Falle einer Fehlfunktion der vCenter Datenbank können diese Daten dann (komplett oder teilweise) mittels
    Powershell wieder importiert werden.
    Im Einfachsten Fall wird die Virtuelle Maschine dann einfach mit folgendem Befehl wieder registriert

    VIM-ReRegister-VM -File (Get-Item *.ReRegister.Save.xml)

#>
Function Export-VMCliXML {
    [CmdletBinding()]
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true)
    ]
    [Alias('VirtualMachine')]
    [Alias('File')]
    $VM,

    $ToDir="."
    )

        Begin{}

        Process{

            $VM | ForEach-Object {
                $o_vm=Get-VM $_

                #Notwendige Daten der VM merken
                $vm_name=$o_vm.Name
                $vm_host=$o_vm.VMHost.Name
                $vmx_path=$o_vm.ExtensionData.Config.Files.VmPathName
                
                $vm_folder=$o_vm.Folder


                Write-Host ("Getting information from VM: '"+$vm_name + "' with VMX path: '" + $vmx_path + "' on Host: '" + $vm_host + "'")
                
                #Ich speichere die VM daten, falls das ReRegister schief läuft
                $h_vmdata=@{
                    vm=$o_vm
                    vm_name=$vm_name
                    vm_host=$vm_host
                    vmx_path=$vmx_path
                    vm_folder=$vm_folder
                    annotations=@()
                    tagass=@()
                    vipermission=@()
                }
                
                $o_annotations = Get-Annotation -Entity $o_vm
                $o_tagass = Get-TagAssignment -Entity $o_vm
                $o_vipermission = Get-VIPermission -Entity $o_vm | Where-Object {$_.EntityID -eq $o_vm.Id}

                $h_vmdata.annotations = $o_annotations
                $h_vmdata.tagass = $o_tagass
                $h_vmdata.vipermission = $o_vipermission

                If(-not ($o_target_dir=Get-Item $ToDir)){
                    $o_target_dir=New-Item -Path $ToDir -ItemType Directory
                }

                $save_path=($ToDir + "\" + ($o_vm.Name -replace "[\\\/]","_")+".ReRegister.Save.xml")
                $h_vmdata | Export-Clixml -Path $save_path
                Write-Host("VM Definition was saved in: $save_path")

                $h_vmdata
            }

        }

        End{}
}


Function VIM-ReRegister-VM{
<#
.SYNOPSIS
    Registriert eine als Ungültig markierte VM am gleichen ESX Host Neu

    Es muss natürlich vorher die Storage erreichbar sein auf der die VMs gespeichert sind.
    Evtl hilft dir der Artikel:
    *http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Troubleshooting/vSphere_Infrastruktur_mit_VSA_Storage_nach_Stromausfall_wieder_in_Betrieb_nehmen

    ACHTUNG!
    Überprüfe vorher die VM auf dem ESX-Host auf mögliche Locks!!
    *https://kb.vmware.com/s/article/2110152
    
.DESCRIPTION
    1. Das CMDlet merkt sich vorher alle notwendigen Daten der VM
    - VM Name
    - VM Host
    - Pfad zur VMX Datei
    - Folder in vCenter
    - Annotations
    - Tags

    2. die VM wird dann von vCenter deRegistriert

    3. die VM wird von der VMX wieder registriert und in der VMs und Folder Ansicht im selben
    Folder wieder angelegt

    4. Annotations und Tags werden wieder gesetzt

    Situationen in denen so etwas notwendig ist entstehen manchmal bei Storage Ausfällen in ESX-Clustern.
    Auch wenn eine Storage temporär sauber heruntergefahren kann es sein, dass ich eine LUN mit einer neuen UID registriert.
    Wenn das passiert werden entsprechende VMs an "Invalid" oder "(inaccessible)" (Kein Zugriff möglich) markiert, obwohl
    die .vmx und .vmdk Dateien nicht gesperrt sind. Vorher ist aber trotzdem auf Locks zu prüfen
.EXAMPLE
    #DAS HIER IST MIT VORSICHT ZU GENIESSEN!!!
    VIM-Get-VM-NotStartable | VIM-ReRegister-VM
.EXAMPLE
    VIM-ReRegister-VM -VM (Get-Item deslnvmvpnquarz.ReRegister.Save.xml) -NewVMHost deslnsrvesx01.megatech.local
    #Das hier registriert eine VM von einem "Backup File" auf den Alternativen Cluster Host deslnsrvesx01.megatech.local
.PARAMETER VM
    "VM" oder "File"
    gib hier die neu zu registrierende VM an. Statt einer VM kannst du her auch ein File angeben. Passende Files sind:
    *.ReRegister.Save.xml   <- Das sind VM Metadaten Files die vorher mit Export-VMCliXML exportiert wurden
.PARAMETER NewVMHost
    Sollte der Ursprüngliche ESX-Server nicht mehr funktionieren, 
    kannst du hiermit versuchen die VM auf einem anderen ESX zu registrieren.
    Name des VMHost als String
.PARAMETER SaveOnly
    Exportiert nur eine XML Datei um alle Informationen zu haben
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-ReRegister-VM
.LINK
    http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Troubleshooting/Zugriff_auf_vmx_nicht_m%C3%B6glich
.LINK
    https://kb.vmware.com/kb/2110152
.LINK
    https://kb.vmware.com/kb/1026043
.LINK
    http://wiki.megatech.local/mediawiki/index.php/VMWare_Infrastruktur/Troubleshooting/vSphere_Infrastruktur_mit_VSA_Storage_nach_Stromausfall_wieder_in_Betrieb_nehmen
#>
    [CmdletBinding()]
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true)
    ]
    [Alias('VirtualMachine')]
    [Alias('File')]
    $VM,
    [string]$NewVMHost="",
    [switch]$SaveOnly
    )

    Begin {}

    Process{
        $VM | ForEach-Object {
            $o_vm = $_

            #Wenn Wir eine Virtuelle Maschine haben dann speichern wir diese und verarbeiten diese weiter
            if($o_vm.GetType().Name -eq "UniversalVirtualMachineImpl"){

                #Export-VMCliXML
                $h_vmdata=Export-VMCliXML -VM $o_vm
                $vm_name=$h_vmdata.vm_name
                $vm_host=$h_vmdata.vm_host
                $vmx_path=$h_vmdata.vmx_path
                $vm_folder=Get-Folder -Id $h_vmdata.vm_folder.Uid
                $o_annotations=$h_vmdata.annotations
                $o_tagass=$h_vmdata.tagass
                $o_vipermission=$h_vmdata.vipermission


                if($SaveOnly){
                    Write-Host("I do not Remove " +$o_vm.Name + " just Saving.")
                    return
                }
                Write-Host("Removing "+$o_vm.Name)

                if($o_vm.PowerState -eq "PoweredOn"){
                    Write-Host($o_vm.Name + "is Running. Trying Softshutdown. Then HardReset")
                    $o_vm | VIM-Shutdown-VM -SoftShutdownSeconds 60
                    $o_vm=Get-VM $o_vm
                }

                $remove_result=$o_vm | Remove-VM -Confirm:$false
            }
            #Wiederherstellen von DefinitionsDatei
            elseif($VM.GetType().Name -eq "FileInfo"){
                Write-Host("Using ReRegister VM Info from: "+$VM.FullName)
                Try{
                    $h_vmdata=Import-Clixml -Path $VM.FullName
                    
                    $vm_name=$h_vmdata.vm_name
                    $vm_host=$h_vmdata.vm_host
                    $vmx_path=$h_vmdata.vmx_path
                    $vm_folder=Get-Folder -Id $h_vmdata.vm_folder.Uid
                    $o_annotations=$h_vmdata.annotations
                    $o_tagass=$h_vmdata.tagass
                    $o_vipermission=$h_vmdata.vipermission
                                        
                }
                Catch{
                    Write-Error("*.ReRegister.Save.xml File expected. Error in working File Data.")
                    Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                }
            }
            else{
                Write-Error("No Valid VM or File detected")
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
                return
            }

            #VM neu registrieren
            Write-Host ("ReRegister VM: '"+$vm_name + "' with VMX path: '" + $vmx_path + "' on Host: '" + $vm_host + "'")
            Try{
                #Auf anderen Host registrieren wenn angegeben
                if($NewVMHost -ne ""){
                    $vm_host=$NewVMHost
                }
                $new_vm=New-VM -Name $vm_name -VMHost $vm_host -VMFilePath $vmx_path -Location $vm_folder
                #Alle Annotations und Tags der VM wieder setzen
                ForEach($annotation in $o_annotations)
                {
                    $temp=$new_vm | Set-Annotation -CustomAttribute $annotation.Name -Value $annotation.Value
                }

                ForEach($tagass in $o_tagass){
                    $temp=New-TagAssignment -Entity $new_vm -Tag (Get-Tag -Name $tagass.Tag.Name -Category $tagass.Tag.Category)
                }

                ForEach($vipermission in $o_vipermission ){

                    if($vipermission.IsGroup){
                        $principal=Get-VIAccount -Group $vipermission.Principal
                    }
                    else {
                        $principal=Get-VIAccount -User $vipermission.Principal
                    }

                    $temp=New-VIPermission -Entity $new_vm `
                        -Principal $principal `
                        -Role (Get-VIRole -Name $vipermission.Role)
                }

                #VM zurück Geben
                Get-VM $new_vm.Name
            }
            Catch{
                Write-Error("Error ReRegistering: "+ $vm_name)
                Write-Host $_ -ForegroundColor Red -BackgroundColor Black
            }

        }
    }

    End {

    }
}


<#
.SYNOPSIS
    Liefert VMs zurück die älter sind als Angegeben (x Days)
.DESCRIPTION
    Wenn eine VM von VIM-Archive-VM archiviert wird, wird unter anderem das Property VIM.ArchiveDateArchived erfasst.
    mit "VIM.ArchiveDateArchived" kann dann der Zeitraum ermittelt werden wie lange die VM schon archiviert ist.
    Standardmäßig gibt diese Funktion VMs zurück die alter als 365 Tag (1 Jahr) sind
.PARAMETER Days
    VMs zurück geben die älter als n Days sind
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/VIM-Get-VM-OldArchived
.EXAMPLE
    VIM-Get-VM-OldArchived | Remove-VM -DeletePermanently
    #Löscht alte VMs
#>
Function VIM-Get-VM-OldArchived {
    [CmdletBinding()]
    param(
        [int]$Days=365
    )

    Begin{}

    Process{}

    End{
        $vm=Get-VM -Tag (Get-Tag -Name "Archiv Stage") | VIM-Get-VMValue
        $vm | 
            Where-Object "VIM.ArchiveDateArchived" -ne "" | 
            Where-Object {(New-Timespan -Start (Get-Date $_."VIM.ArchiveDateArchived") -End (Get-Date)) -gt (New-TimeSpan -Days $Days)}
    }
}


if($IsLinux){
    $global:ovftool=. which ovftool
}
else{
    $global:ovftool="C:\Program Files\VMware\VMware OVF Tool\ovftool.exe"
}


<#
.SYNOPSIS
    Exportiert VMs in ein Verzeichnis im OVF Format.

    ACHTUNG FUNKTIONIERT NUR MIT vCenter
.DESCRIPTION
    Exportiert VMs in ein Verzeichnis im OVF Format. Es werden Zusatzinformationen
    in .cli.xml exportiert um eine Übernahme von Hardware IDs (BIOS Seriennummer,
    Mac-Addressen) sicherstellen zu können.
    Der Export mit OVFTool über dieses Commandlet scheint besser zu funtionieren als die
    Export-OVA Funktion in vSphere Client.

    Wenn eine VM bereits läuft, wird sie temporär auf dem vCenter geklont und dann heruntergeladen
    Verwende -TempCloneToDatastore um den Datastore zu bestimmen auf den die VM temporär geklont wird
    
.PARAMETER VM
    Kann sein
        - String
        - VM-Objekt
        - Hashtable in dieser Form
$VMs=@(
    @{ "VM"="VirtualMachine1_Clone";"HWFrom"="VirtualMachine1"}
    @{ "VM"="VirtualMachine2_Clone";"HWFrom"="VirtualMachine2"}
)

.PARAMETER WithSameHardwareIDs
    Wenn dieser Switch gesetzt ist, werden Hardware Informationen
    wie Bios Seriennummer (UUID) und MAC-Addressen mit exportiert
    ACHTUNG: Diese Option verringert die Portabilität der VM
.PARAMETER ExportDestination
    Hier werden die OVF Folder gespeichert
.PARAMETER TempCloneToDatastore
    Wenn die VM "PoweredOn" ist kann sie normalerweise nicht exportiert werden.
    Soll Sie dennoch exportiert werden kann sie hiermit Temporär auf einen
    Datastore geklont werden bevor sie exportiert wird
.PARAMETER ovftool
    Pfad zur ovftool.exe falls du eine andere Version verwenden willst
.PARAMETER openssl
    Openssl wird benötigt um eine Manifest Datei zu erstellen. Noch nicht vollständig implementiert
    Es geht auch ohne Manifest
.LINK
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Export-VM-toOVFDir
.LINK
    https://www.vmware.com/support/developer/ovf/
#>
Function Export-VM-toOVFDir {
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,
        [switch]$WithSameHardwareIDs,
        $ExportDestination=".",
        $TempCloneToDatastore="",
        $ovftool=$global:ovftool,
        $openssl=$PSScriptRoot + "\bin\openssl.exe"
    )

        <#
        $SourceVCenter,
        $SourceCredential=(Get-Credential -Message "Source vCenter Credential"),
        #>

    Begin{
        $a_vm=@()
    }

    Process{
        $VM | ForEach-Object {
            $a_vm+=$_
        }
    }

    End{
        
        $i=0

        $a_vm | ForEach-Object {
            $vmparam=$_
            $s_TempVMName=""

            #Wenn ich Geklonte VMs kopieren will, aber die Hardware IDs von der Original VM haben möchte
            if($vmparam.GetType().Name -eq "Hashtable"){
                $o_vm=Get-VM $vmparam.VM
                $o_hwvm=Get-VM $vmparam.HWFrom
            }
            else{
                #Wenn der Parameter ein String oder ein VM Objekt ist, geht das hier beides
                $o_vm=Get-VM $vmparam
                $o_hwvm=Get-VM $vmparam
            }

            #Wenn die zu klonende VM läuft und ich die temporär klonen kann
            if($o_vm.PowerState -eq "PoweredOn" -and $TempCloneToDatastore -ne ""){
                #Die Original VM ist die von der ich die Hardware haben will
                $o_hwvm=$o_vm

                $s_TempVMName=($o_hwvm.Name + "_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss"))
                $o_vm=New-VM -VM $o_hwvm -Name $s_TempVMName -VMHost $o_hwvm.VMHost -Datastore $TempCloneToDatastore -Location $o_hwvm.Folder

                if(-not $WithSameHardwareIDs){
                    $o_hwvm=$o_vm
                }
            }


            $percent=$i / $a_vm.Count * 100

            #Write-Host ("Working on: "+$o_vm.Name)
            $start_time=Get-Date
            Write-Progress -Id 10 -Activity ("Exporting VMs to OVA - Started: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss" $start_time)) -Status ("Working on: "+$o_vm.Name + " - " + $i + " of " + $a_vm.Count) -PercentComplete $percent

            $session = Get-View -Id SessionManager
            $ticket = $session.AcquireCloneTicket()
            $SourceVCenter=$global:DefaultVIServer.Name

            if($WithSameHardwareIDs){
                $export_flags="--exportFlags=mac,uuid"
            }
            else{
                $export_flags=""
            }

            #Das ist der eigentliche Export Befehl
            . $ovftool $export_flags --overwrite --acceptAllEulas --skipManifestGeneration --noSSLVerify ("--I:sourceSessionTicket="+$ticket) ("vi://" + $SourceVCenter + "/" +"?moref=vim.VirtualMachine:" + $o_vm.ExtensionData.MoRef.Value) (Get-Item $ExportDestination).FullName | ForEach-Object {
                #Das hier ist nur Ausgabe für den User
                $line=$_
                $match=$line | Select-String -Pattern 'Progress: ([0-9]+)%'
                if($line -eq ""){
                    $line="..."
                }

                if($match){
                    $vm_percent=$match.Matches.Groups[1].Value
                }
                else{
                    $vm_percent=0
                    Write-Host $line
                }
                $end_time=Get-Date
                $time_running=New-TimeSpan -Start $start_time -End $end_time
                Write-Progress -Id 20 -Activity ("Exporting VM " + $o_vm.Name) -Status ((Get-Date -Format "yyyy-MM-dd HH:mm:ss" $end_time)+" : " + $line + " - Time Running: {0:c}" -f $time_running) -PercentComplete $vm_percent
            }

            Write-Progress -Id 20 -Activity ("Exporting VM " + $o_vm.Name) -Status ((Get-Date -Format "yyyy-MM-dd HH:mm:ss" $end_time)+" : " + "Exporting Configuration and Hardware ID Information" + " - Time Running: {0:c}" -f $time_running) -PercentComplete 100

            #Exportieren von Hardware IDs
            $target_dir=Get-Item ((Get-Item $ExportDestination).FullName +"\"+ $o_vm.Name)
            $o_hwvm | Get-NetworkAdapter | Export-Clixml -Path ($target_dir.FullName + "\" + $o_vm.Name + ".NetworkAdapters.cli.xml")
            $o_hwvm | Get-AdvancedSetting | Export-Clixml -Path ($target_dir.FullName + "\" + $o_vm.Name + ".AdvancedSetting.cli.xml")
            $o_hwvm.ExtensionData.Config | Export-Clixml -Path ($target_dir.FullName + "\" + $o_vm.Name + ".ExtensionData.Config.cli.xml")


            if($WithSameHardwareIDs){
                #Wenn wir die selben Hardware IDs haben wollen, dann überschreiben wir das XML mit den Hardware IDs der gewünschten VM
                $ovf_file_path=($target_dir.FullName + "\" + $o_vm.Name + ".ovf")
                [xml]$ovf_content=Get-Content $ovf_file_path

                #XML Namespace
                $ns=@{ovf='http://schemas.dmtf.org/ovf/envelope/1'}
                
                #XML Namespace Manager
                $nsmgr = New-Object System.Xml.XmlNamespaceManager $ovf_content.NameTable
                $nsmgr.AddNamespace("root","http://schemas.dmtf.org/ovf/envelope/1")
                $nsmgr.AddNamespace("rasd","http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData")
                $nsmgr.AddNamespace("ovf","http://schemas.dmtf.org/ovf/envelope/1")
                $nsmgr.AddNamespace("cim","http://schemas.dmtf.org/wbem/wscim/1/common")
                $nsmgr.AddNamespace("vmw","http://www.vmware.com/schema/ovf")


                
                #$ovf_content.SelectNodes("//root:VirtualSystem//root:Item[rasd:ElementName='Network adapter 1']",$nsmgr).Address
                #Netzwerk Adapter Mac Addressen                
                $o_hwvm | Get-NetworkAdapter | ForEach-Object {
                    $nw_adapter=$_
                    #Wir setzen die MAC-Addresse der Netzwerkkarten auf die gewünschte der $o_hwvm
                    $ovf_content.SelectSingleNode("//root:VirtualSystem//root:Item[rasd:ElementName='" + $nw_adapter.Name + "']",$nsmgr).Address=$nw_adapter.MacAddress
                }

                #BIOS UUID
                $ovf_content.SelectSingleNode("//root:VirtualSystem//vmw:Config[@vmw:key='uuid']",$nsmgr).value=$o_hwvm.ExtensionData.Config.Uuid

                #Modifiziertes OVF speichern
                Move-Item $ovf_file_path ($ovf_file_path+".original") -Force -Confirm:$false
                $ovf_content.Save($ovf_file_path)

                <#
                Push-Location $target_dir.FullName
                . $openssl sha1 "*.vmdk" "*.ovf" | Out-File -Encoding utf8 -FilePath ($o_vm.Name +".mf") -Force -Confirm:$false
                Pop-Location
                #>

            }

            #Wenn ich einen temporären Klon angelegt habe, dann diesen wieder löschen
            if($s_TempVMName -ne ""){
                $remove_task=Get-VM $s_TempVMName | Remove-VM -DeletePermanently -Confirm:$false -RunAsync 
            }

            $out_dir=Get-Item ($ExportDestination + "\" + $o_vm.Name)
            $out_dir

            $i++
       }    
    }
}


Function Get-OVAProgress {
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        $OutLine,
        $Source="",
        $Target=""
    )
    Begin{
        $start_time=Get-Date
    }

    Process{

        $OutLine | ForEach-Object {
            #Das hier ist nur Ausgabe für den User
            $line=$_
            $match=$line | Select-String -Pattern 'Progress: ([0-9]+)%'
            if($line -eq ""){
                $line="..."
            }

            if($match){
                $vm_percent=$match.Matches.Groups[1].Value
            }
            else{
                $vm_percent=0
                Write-Host $line
            }
            $end_time=Get-Date
            $time_running=New-TimeSpan -Start $start_time -End $end_time
            Write-Progress -Id 20 -Activity ("OVA from $Source to $Target") -Status ((Get-Date -Format "yyyy-MM-dd HH:mm:ss" $end_time)+" : " + $line + " - Time Running: {0:c}" -f $time_running) -PercentComplete $vm_percent
        }
    }

    End{

    }


}


Function Publish-OVA {
<#
.EXAMPLE
    Get-VM utility-s2.site2* | Publish-OVA -Name "ubuntu_OpenSource_UtilityServer_v2.1_2019-03-14"
#>
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,
        [Parameter(Mandatory=$true)]
        $Name,
        $TargetDir=".",
        $TempDir=((Get-Item $env:Temp).FullName)+"\Publish-OVA",
        $TempCloneToDatastore="",
        [switch]$KeepTempDir,
        $ovftool=$global:ovftool,
        $openssl=$PSScriptRoot + "\bin\openssl.exe"
    )

    
    if(-not (Test-Path -Path $TempDir)){
        $o_tempdir=mkdir $TempDir
    }
    else{
        $o_tempdir=Get-Item $TempDir
    }

    $temp_ovfdir=Export-VM-toOVFDir -VM $VM -ExportDestination $TempDir -TempCloneToDatastore $TempCloneToDatastore -ovftool $ovftool -openssl $openssl

    $temp_ovf_file=Get-Item($temp_ovfdir.FullName+"\"+$temp_ovfdir.BaseName+".ovf")
    [xml]$ovf_xml=Get-Content $temp_ovf_file

    $nsmgr = New-Object System.Xml.XmlNamespaceManager $ovf_xml.NameTable
    #"xmlns"
    $nsmgr.AddNamespace("x",$ovf_xml.Envelope.xmlns)
    foreach($ns_name in @("cim","ovf","rasd","vmw","vssd","xsi")){
        #Write-Host($ns_name + " : " + $ovf_xml.Envelope.$ns_name)
        $nsmgr.AddNamespace($ns_name,$ovf_xml.Envelope.$ns_name)
    }

    #ProductSection mit ovf:required="false" ergänzen

    $attr=$ovf_xml.CreateAttribute("ovf","required",$nsmgr.LookupNamespace("ovf"))
    $attr.Value="false"

    $ovf_xml.SelectSingleNode("//x:Envelope//x:VirtualSystem//x:ProductSection",$nsmgr).Attributes.SetNamedItem($attr)

    #ExtraConfig entfernen
    #$node=$ovf_xml.SelectNodes("//x:Envelope//x:VirtualSystem",$nsmgr)
    while($node=$ovf_xml.SelectSingleNode("//x:Envelope//x:VirtualSystem//x:VirtualHardwareSection//vmw:ExtraConfig",$nsmgr)){
        $ovf_xml.Envelope.VirtualSystem.VirtualHardwareSection.RemoveChild($node)
    }
    $ovf_noExtraConfig=($temp_ovfdir.FullName+"\"+$temp_ovfdir.BaseName+"_noExtraConfig_" +".ovf")
    $ovf_xml.Save($ovf_noExtraConfig)
    
    #ProductSection (mit Properties) entfernen
    $node=$ovf_xml.SelectSingleNode("//x:Envelope//x:VirtualSystem//x:ProductSection",$nsmgr)
    $ovf_xml.Envelope.VirtualSystem.RemoveChild($node)

    $ovf_noProps=($temp_ovfdir.FullName+"\"+$temp_ovfdir.BaseName+"_noOvaProperties_" +".ovf")
    $ovf_xml.Save($ovf_noProps)

    #Erstellen der eigentlichen Ziel Archive
    #Zwecks Abwärtskompatibilität zu vSphere 6.0 ist sha1 unser Manifest Algorhytmus

    . $ovftool --shaAlgorithm=sha1 --overwrite $ovf_noExtraConfig ($TargetDir + "\" + $Name + "_WITH_OvaProperties"+".ova") | Get-OVAProgress -Source $ovf_noExtraConfig -Target ((Get-Item $TargetDir).FullName + "\" + $Name + "_WITH_OvaProperties"+".ova")
    . $ovftool --shaAlgorithm=sha1 --overwrite $ovf_noProps ($TargetDir + "\" + $Name + "_NO_OvaProperties"+".ova") | Get-OVAProgress -Source $ovf_noProps -Target ((Get-Item $TargetDir).FullName + "\" + $Name + "_NO_OvaProperties"+".ova")

    if(-not $KeepTempDir){
        $temp_ovfdir | Remove-Item -Recurse -Confirm:$false
    }

}

<#
.SYNOPSIS
    Exportiert VMs in ein Verzeichnis im OVA Format.

    Soll in Zukunft mit Standalone ESX-Server und auch mit vCenter Funktionieren
.PARAMETER VM
    Zu exportierende VMs
.PARAMETER User
    User mit dem sich zu ESX-Server verbunden wird
.PARAMETER Password
    Passwort mit dem sich zu ESX-Server verbunden wird
.PARAMETER WithSameHardwareIDs
    Wenn dieser Switch gesetzt ist, werden Hardware Informationen
    wie Bios Seriennummer (UUID) und MAC-Addressen mit exportiert
    ACHTUNG: Diese Option verringert die Portabilität der VM
.PARAMETER ExportDestination
    Hier werden die OVF Folder gespeichert
.PARAMETER TempCloneToDatastore
    Wenn die VM "PoweredOn" ist kann sie normalerweise nicht exportiert werden.
    Soll Sie dennoch exportiert werden kann sie hiermit Temporär auf einen
    Datastore geklont werden bevor sie exportiert wird
.PARAMETER ovftool
    Pfad zur ovftool.exe falls du eine andere Version verwenden willst
.PARAMETER openssl
    Openssl wird benötigt um eine Manifest Datei zu erstellen. Noch nicht vollständig implementiert
    Es geht auch ohne Manifest
.PARAMETER vCenter
    ist die Source ein vCenter oder nicht. Sollte in Zukunft automatisch ermittelt werden
.LINK
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Export-VM-toOVFDir
.LINK
    https://www.vmware.com/support/developer/ovf/

#>
Function Export-VM-fromESX {
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,
        $User,
        $Password,
        [switch]$WithSameHardwareIDs,
        $ExportDestination=".",
        $TempCloneToDatastore="",
        $ovftool=$global:ovftool,
        $openssl=$PSScriptRoot + "\bin\openssl.exe",
        [switch]$vCenter
    )
    
    Begin{
        $a_vm=@()
    }

    Process{
        $VM | ForEach-Object {
            $a_vm+=$_
        }
    }

    End{

        if($WithSameHardwareIDs){
            $export_flags="--exportFlags=mac,uuid"
        }
        else{
            $export_flags=""
        }

        $a_vm | ForEach-Object {
            $o_vm=$_
            if($vCenter){
                $dc_name=(Get-Datacenter | Select-Object -First 1).Name
                . $ovftool "--noSSLVerify" "--overwrite" $export_flags ("vi://"+$User+":"+$Password+"@"+$global:DefaultVIServer.Name+"/?moref=vim.VirtualMachine:"+$o_vm.ExtensionData.MoRef.Value) ($ExportDestination+"\"+$o_vm.Name+".ova")
            }
            else{
                . $ovftool "--noSSLVerify" "--overwrite" $export_flags ("vi://"+$User+":"+$Password+"@"+$global:DefaultVIServer.Name+"/"+$o_vm.Name+"") ($ExportDestination+"\"+$o_vm.Name+".ova")
            }
        }
    }
        
}


<#
        $TargetVCenter,
        $TargetCredential=(Get-Credential -Message "Target vCenter Credential"),

#>

<#
.SYNOPSIS
    Importiert eine VM von einem OVF Verzeichnis das zuvor mit Export-VM-toOVFDir exportiert wurde
    Es können auch mehrere OVF Verzeichnisse in einer Pipe oder als Array übergeben werden
.DESCRIPTION
    Der Import funktioniert über ovftool. Aktuell muss für vSphere 6.5 OVFTool 4.3.0 installiert sein

    Vorher in Ziel vCenter einloggen (Connect-VIServer)
    Dann Import Befehl verwenden
.PARAMETER OVFDir
    Verzeichnis mit Virtueller Maschine im OVF Format. Kann einzeln, via Pipe oder als Array übergeben werden
.PARAMETER TargetVMName
    Name der Ziel VM. Wird kein Name übergeben wird Name des OVF verwendet
.PARAMETER TargetLocation
    Eine Target Location kann sein
    - Ein ESX-Host
    - Ein Ressourcenpool
    - Ein ESX-Cluster
    Die Location muss als entsprechendes Objekt übergeben werden
.PARAMETER TargetDatastore
    Ziel Datastore als VI Objekt
.PARAMETER TargetFolder
    Ziel Folder als VI Objekt
    oder
    Ziel Folder Pfad mit "/" getrennt ab unterhalb des Datacenters
.PARAMETER TargetNetwork
    Ziel Netzwerk als VI Objekt. Mit diesem Netzwerk werden alle Netzwerkkarten der VM verbunden
    Wenn du unterschiedliche Netzwerke benötigst musst du diese noch manuell nach einspielen der VM verbinden
.PARAMETER TargetDiskStorageFormat
    VM Festplatten Format als 'Thick','Thin','EagerZeroedThick'
.PARAMETER WithSameHardwareIDs
    Damit das fuktioniert muss die VM auch vorher mit WithSameHardwareIDs exportiert worden sein
    hat aktuell keine spezielle Funktion. Vielleicht wirds noch gebraucht
.PARAMETER ovftool
    Pfad zur Executable von OVFTool. Falls du eine andere Version verwenden willst
.LINK
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Import-VM-fromOVFDir
.LINK
    https://www.vmware.com/support/developer/ovf/
#>
Function Import-VM-fromOVFDir {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        $OVFDir,
        #$TargetVcenter, #//XXX Todo hier ist / war ein Problem. Target VCenter muss automatisch von der Verbindung ermittelt werden 
        $TargetVMName="",
        $TargetLocation,
        $TargetDatastore,
        $TargetFolder,
        $TargetNetwork,
        [ValidateSet('Thick','Thin','EagerZeroedThick')]
        $TargetDiskStorageFormat="Thick",
        [switch]$WithSameHardwareIDs,
        $ovftool=$global:ovftool
    )

    Begin{
        $a_dirs=@()
        $start_time=Get-Date

        $TargetVcenter = $global:DefaultVIServer.Name
    }

    Process{
        $OVFDir | ForEach-Object {
            $a_dirs+=Get-Item $_
        }
    }

    End{
        $a_dirs | ForEach-Object {
            $o_ovfdir=$_

            $s_ovf_source=(Get-Item($o_ovfdir.FullName + "\*.ovf")).FullName
            $o_NetworkAdapters=Import-Clixml -Path ($o_ovfdir.FullName + "\*.NetworkAdapters.cli.xml")
            $o_Config=Import-Clixml -Path ($o_ovfdir.FullName + "\*.ExtensionData.Config.cli.xml")
            $o_AdvancedSetting=Import-Clixml -Path ($o_ovfdir.FullName + "\*.AdvancedSetting.cli.xml")

            #Wir nicht mehr benötigt, weil wir TargetLocation haben
            #$o_TargetHost=Get-VMHost $TargetHost


            #Ziel Folder finden
            #z.B. Live/Server
            If($TargetFolder.GetType().Name -eq "String"){
                $a_folders=$TargetFolder -split "/"

                $o_targetfolder=Get-Folder
                ForEach($s_folder in $a_folders){
                    $o_targetfolder=$o_targetfolder | Get-Folder $s_folder
                }
                $vmFolder_moref=($o_targetfolder | Get-View).MoRef
            }
            else {
                $vmFolder_moref=($TargetFolder | Get-View).MoRef
            }

            $datastore_moref=(Get-Datastore -Name $TargetDatastore | Get-View).MoRef

            if($TargetNetwork.GetType().Name -eq "PSCustomObject"){
                $TargetNetwork=$TargetNetwork.Name
            }

            $network_moref=(Get-View -ViewType Network | Where-Object{$_.Name -eq $TargetNetwork}).MoRef

            $location_moref=($TargetLocation | Get-View).MoRef

            <#
            --name <- VM Name
            --vmFolder
            --network
            --datastore

            --diskMode
            #>

            $session = Get-View -Id SessionManager
            $ticket = $session.AcquireCloneTicket()

            if($TargetVMName -eq ""){
                $s_target_vmname=$o_ovfdir.Name
            }
            else{
                $s_target_vmname=$TargetVMName
            }


            . $ovftool ("--X:logFile=" + $s_target_vmname + "ovftool.import.log.txt") --X:logLevel=verbose --skipManifestCheck --acceptAllEulas --noSSLVerify `
                ("--name="+$s_target_vmname) `
                ("--I:targetSessionTicket="+$ticket) ("--I:morefArgs") `
                ("--datastore=vim."+ $datastore_moref.Type + ":" + $datastore_moref.Value) `
                ("--network=vim."+ $network_moref.Type + ":" + $network_moref.Value) `
                ("--vmFolder=vim."+ $vmFolder_moref.Type + ":" + $vmFolder_moref.Value) `
                $s_ovf_source ("vi://" + $TargetVCenter + "?moref=vim."+ $location_moref.Type +":"+$location_moref.Value) | ForEach-Object {
                    #Das hier ist nur Ausgabe für den User
                    $line=$_
                    $match=$line | Select-String -Pattern 'Progress: ([0-9]+)%'
                    if($line -eq ""){
                        $line="..."
                    }

                    if($match){
                        $vm_percent=$match.Matches.Groups[1].Value
                    }
                    else{
                        $vm_percent=0
                        Write-Host $line
                    }
                    $end_time=Get-Date
                    $time_running=New-TimeSpan -Start $start_time -End $end_time
                    Write-Progress -Id 20 -Activity ("Importing VM " + $o_vm.Name) -Status ((Get-Date -Format "yyyy-MM-dd HH:mm:ss" $end_time)+" : " + $line ) -PercentComplete $vm_percent
                }
            #//XXX Hier weiter
            #//XXX ovftool importiert die VM richtig inklusive UUID
            #UUID muss nicht überschrieben werden
            <#
            If($WithSameHardwareIDs){
                $vm=Get-VM $o_ovfdir.Name 

              
                $o_NetworkAdapters | ForEach-Object {
                    $o_nwadapter=$_
                    $vm | Get-NetworkAdapter -Name $o_nwadapter.Name | ForEach-Object {
                        Set-NetworkAdapter -NetworkAdapter $_ -MacAddress $o_nwadapter.MacAddress 
                    }
                }
              

                #Wir überschreiben die UUID im Target vCenter
                $spec = New-Object VMWare.VIM.VirtualMachineConfigSpec
                $spec.Uuid=$o_config.Uuid

                $uuid_task=$vm.ExtensionData.ReconfigVM_Task($spec)
            }
            #>
        }
    }
}

<#
.SYNOPSIS
    Eine kleine Hilfsfunktion um Netzwerke in einem vCenter anzuzeigen
    PowerCLI liefert noch keinen eigenen Get-Network Befehl
#>
Function Get-Network{
    param(
        $Name=""
    )
    if($Name -eq ""){
        Get-View -ViewType Network | Select Name
    }
    else{
        Get-View -ViewType Network | Where-Object{$_.Name -eq $Name} | Select Name
    }
}

<#
.SYNOPSIS
    Exportiert VMs von einem vCenter als OVF
    und importiert diese ins nächste vCenter von OVF
.DESCRIPTION
    Dieses Cmdlet verwendet Export-VM-toOVFDir und Import-VM-fromOVFDir
    in Kombination um VMs von einem vCenter zu exportieren und sofort
    ins nächste vCenter zu importieren.
    Es werden sehr viele Parameter benötigt um dieses CMDlet automatisiert
    laufen zu lassen.

    Am besten vorher die ganzen benötigen Parameter in Variablen speichern
    und somit gleichzeitig auch überprüfen ob die angesprochenen Objekte auch
    korrekt sind. Das CMDlet geht meistens davon aus, dass die als Parameter
    übergebenen Objekte auch wirklich im Source bzw Target vCenter existent sind
.PARAMETER VM
    Virtuelle Maschine die kopiert wird
.PARAMETER SourceVCenter
    vCenter aus dem kopiert wird
.PARAMETER SourceCred
    Powershell Credential zur Anmeldung am SourceVcenter
.PARAMETER TargetVCenter
    vCenter in das kopiert wird
.PARAMETER TargetCred
    Powershell Credential zur Anmeldung am TargetVCenter
.PARAMETER WithSameHardwareIDs
    Die Hardware IDs (Mac-Addressen, BIOS UUID) der Quell-VM
    werden in das Ziel übernommen
.PARAMETER ExportDestination
    Lokaler Pfad an dem die OVF Verzeichnissse zwischengespeichert werden
.PARAMETER TempCloneToDatastore
    Wenn die VM im Quell vCenter Online (PoweredOn) ist kann sie normalerweise
    nicht exportiert werden. Mit einem temporären Klon in einen anderen
    Datastore geht das allerdings schon.
    Achtung die VM hat dann einen Status als wäre die Festplatte im laufenden
    Betrieb gezogen werden (also wie Snapshot ohne Arbeitsspeicher)
.PARAMETER TargetVMName
    So soll die VM am Ziel heissen
    ACHTUNG noch nicht implementiert um dies mit mehreren VMs gleichzeitig
    zu machen
.PARAMETER TargetLocation
    Ziel ESX-Host, Cluster, Resource-Pool
.PARAMETER TargetDatastore
    Ziel Datastore auf dem die VM dann importiert wird
.PARAMETER TargetFolder
    In diesem Folder wird die VM am Ziel angezeigt
.PARAMETER TargetNetwork
    Netzwerkkarten der VM werden am Ziel an dieses Netzwerk angeschlossen
.PARAMETER TargetDiskStorageFormat
    In diesem VM Festplatten Format wird die VM am Ziel gespeichert
    Standardmäßig Thick
.PARAMETER RemoveExportedOVF
    Die Exportierten Files werden nach Import am Ziel wieder gelöscht
.PARAMETER ovftool
    Pfad zur ovftool.exe (wenn etwas anderes als Default benötigt wird)
.PARAMETER openssl
    Wird aktuell nicht verwendet. Aber hat evtl Relevanz zur Erstellung von
    Manifest Files
.LINK
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Virtual-Infrastructure-Management.psm1/Copy-VM-viaOVFDir
.LINK
    https://www.vmware.com/support/developer/ovf/
#>
Function Copy-VM-viaOVFDir {
    [CmdletBinding()]
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        [Alias('VirtualMachine')]
        $VM,
        $SourceVCenter,
        $SourceCred,
        $TargetVCenter,
        $TargetCred,
        [switch]$WithSameHardwareIDs,
        $ExportDestination=".",
        $TempCloneToDatastore="",
        $TargetVMName="",
        $TargetLocation,
        $TargetDatastore,
        $TargetFolder,
        $TargetNetwork,
        [ValidateSet('Thick','Thin','EagerZeroedThick')]
        $TargetDiskStorageFormat="Thick",
        [switch]$RemoveExportedOVF,
        $ovftool=$global:ovftool,
        $openssl=$PSScriptRoot + "\bin\openssl.exe"
    )

    Begin{
        $a_vm=@()
        Set-PowerCLIConfiguration -DefaultVIServerMode Single -Confirm:$false
    }

    Process{
        $VM | ForEach-Object {
            $a_vm+=$_
        }
    }

    End{
        $a_vm | ForEach-Object {
            $o_vm=$_

            $source_conn=Connect-VIServer -Server $SourceVCenter -Credential $SourceCred
            $ovf_dir=Export-VM-toOVFDir -VM $o_vm -WithSameHardwareIDs:$WithSameHardwareIDs -ExportDestination $ExportDestination `
                -TempCloneToDatastore $TempCloneToDatastore -ovftool $ovftool -openssl $openssl

            Disconnect-VIServer -Server $SourceVCenter -Confirm:$false

            $target_conn=Connect-VIServer -Server $TargetVCenter -Credential $TargetCred

            Import-VM-fromOVFDir -OVFDir $ovf_dir -TargetVMName $TargetVMName -TargetLocation $TargetLocation -TargetDatastore $TargetDatastore `
                -TargetFolder $TargetFolder -TargetNetwork $TargetNetwork -TargetDiskStorageFormat $TargetDiskStorageFormat -WithSameHardwareIDs:$WithSameHardwareIDs `
                -ovftool $ovftool

            If($RemoveExportedOVF){
                $ovf_dir | Remove-Item -Recurse -Confirm:$false
            }

            Disconnect-VIServer -Server $TargetVCenter -Confirm:$false

        }

        Connect-VIServer -Server $SourceVCenter -Credential $SourceCred
    }
    
}

<#
.SYNOPSIS
    Gibt VMs mit gemounteter ISO zurück
.DESCRIPTION
    Sucht in allen VMs die im Parameter VM übergeben wurden nach Kandidaten die ein
    ISO gemounted (eine CDROM / DVD in ihrem virtuellen Laufwerk eingelegt haben)

    Es werden die VM Objekte zurückgegeben und können somit in einer Pipe wiederverwendet werden
.PARAMETER VM
    Liste von virtuellen Maschinen die durchsucht werden sollen
.EXAMPLE
    Get-VM-WithISOMounted | Unmount-VM-ISO
#>
Function Get-VM-WithISOMounted {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)
    )

    Begin {

    }

    Process {
        $VM | ForEach-Object {
            $o_vm=$_
            if($o_vm | Get-CDDrive | select @{N="VM";E="Parent"},IsoPath | where {$_.IsoPath -ne $null}){
                $o_vm
            }

        }
    }

    End {}
}

<#
.SYNOPSIS
    Zeigt VMs mit gemounteter ISO an
.DESCRIPTION
    Sucht in allen VMs die im Parameter VM übergeben wurden nach Kandidaten die ein
    ISO gemounted (eine CDROM / DVD in ihrem virtuellen Laufwerk eingelegt haben)

    Die zurückgegebenen Objekte sind KEINE VM Objekte sondern dienen lediglich der Anzeige
    welche ISO gemountet ist. Nicht in einer Pipe weiterverwenden
    Wenn du Aktionen mit den gefundenen VMs durchführen willst, dann verwende:

    Get-VM-WithISOMounted
.PARAMETER VM
    Liste von virtuellen Maschinen die durchsucht werden sollen
.EXAMPLE
    Show-VM-WithISOMounted
.EXAMPLE
    Get-Folder "Test" | Get-VM | Show-VM-WithISOMounted
#>
Function Show-VM-WithISOMounted {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)
    )

    Begin {

    }

    Process {
        $VM | ForEach-Object {
            $o_vm=$_
            $o_vm | Get-CDDrive | select @{N="VM";E="Parent"},IsoPath | where {$_.IsoPath -ne $null}

        }
    }

    End {}
}

Function Unmount-VM-ISO {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)
    )

    Begin {

    }

    Process {
        $VM | ForEach-Object {
            $o_vm=$_
            $o_vm | Get-CDDrive | where {$_.IsoPath -ne $null} | Set-CDDrive -NoMedia -Confirm:$False
        }
    }

    End{}

}

#//XXX Full Clone eines Snapshots einer VM
###############################################################################################
#//XXX nicht von mir (RAC)
#//XXX ToDo Implementation passt nicht zu den restlichen CMDlets
#das hier gehört nochmal neu geschrieben im RAC Style
#Danke an: 
# * https://www.jonathanmedd.net/2013/07/clone-a-vm-from-a-snapshot-using-powercli.html
# * https://gheywood.wordpress.com/2014/09/08/creating-a-clone-from-a-snapshot-on-vmware-vsphere/
# * http://www.vmdev.info/?p=202
###############################################################################################

function New-VMFromSnapshot {
<#
 .SYNOPSIS
 Function to create a clone from a snapshot of a VM.

 .DESCRIPTION
 Function to create a clone from a snapshot of a VM.
    //XXX nicht von mir (RAC)
    //XXX ToDo Implementation passt nicht zu den restlichen CMDlets
    das hier gehört nochmal neu geschrieben im RAC Style
 .PARAMETER SourceVM
 VM to clone from.

.PARAMETER CloneName
 Name of the clone to create

.PARAMETER SnapshotName
 Name of the snapshot to clone from

.PARAMETER CurrentSnapshot
 Use the current snapshot instead of a named snapshot

.PARAMETER Cluster
 Name of the cluster to place the clone in

.PARAMETER Datastore
 Name of the datastore to place the clone in

.PARAMETER VMFolder
 Name of the Virtual Machine folder to put the VM in

.PARAMETER LinkedClone
 Create a linked clone from the snapshot, rather than a full clone

.INPUTS
 String.
 System.Management.Automation.PSObject.

.OUTPUTS
 VMware.Vim.ManagedObjectReference.

.EXAMPLE
 PS> New-VMFromSnapshot -SourceVM VM01 -CloneName "Clone01" -Cluster "Test Cluster" -Datastore "Datastore01"

.EXAMPLE
 PS> New-VMFromSnapshot -SourceVM VM01 -CloneName "Clone01" -SnapshotName "Testing" -Cluster "Test Cluster" -Datastore "Datastore01" -VMFolder "Test Clones" -LinkedClone

#>
[CmdletBinding(DefaultParameterSetName=”Current Snapshot”)][OutputType('VMware.Vim.ManagedObjectReference')]

Param
 (

[parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]
 [PSObject]$SourceVM,

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]
 [String]$CloneName,

[parameter(Mandatory=$true,ParameterSetName="Named Snapshot")]
 [ValidateNotNullOrEmpty()]
 [String]$SnapshotName,

[parameter(Mandatory=$false)]
 [ValidateNotNullOrEmpty()]
 [String]$Cluster,

[parameter(Mandatory=$false)]
 [ValidateNotNullOrEmpty()]
 [String]$Datastore,

[parameter(Mandatory=$false)]
 [ValidateNotNullOrEmpty()]
 [String]$VMFolder,

[parameter(Mandatory=$false)]
 [ValidateNotNullOrEmpty()]
 [Switch]$LinkedClone
 )

# --- Retrieve snapshot tree using try / catch since if it doesn't exist, an exception is generated
 function Test-SnapshotExists ($SnapshotQuery) {

try {
 Write-Verbose "Testing $SnapshotQuery....`n"
 $TestSnapshot = Invoke-Expression $SnapshotQuery
 Write-Output $TestSnapshot
 }

catch [Exception]{

$TestSnapshot = $false
 Write-Output $TestSnapshot
 }
 }

try {

if ($SourceVM.GetType().Name -eq "string"){

 try {
 $SourceVM = Get-VM $SourceVM -ErrorAction Stop
 }
 catch [Exception]{
 Write-Warning "VM $SourceVM does not exist"
 }
 }

 elseif ($SourceVM -isnot [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]){
 Write-Warning "You did not pass a string or a VM object"
 Return
 }

 # --- Set values for the Clone Spec
 if ($PSBoundParameters.ContainsKey('Cluster')){

 $DefaultClusterResourcePoolMoRef = (Get-Cluster $Cluster | Get-ResourcePool "Resources").ExtensionData.MoRef
 }

if ($PSBoundParameters.ContainsKey('Datastore')){

$DatastoreMoRef = (Get-Datastore $Datastore).ExtensionData.MoRef
 }

if ($PSBoundParameters.ContainsKey('LinkedClone')){

$CloneType = "createNewChildDiskBacking"
 }
 else {

$CloneType = "moveAllDiskBackingsAndDisallowSharing"
 }

if ($PSBoundParameters.ContainsKey('VMFolder')){

try {

$Folder = Get-Folder $VMFolder -Type VM -ErrorAction Stop
 $CloneFolder = $Folder.ExtensionData.MoRef
 }
 catch [Exception] {

Write-Warning "VM Folder $VMFolder does not exist, using existing folder instead"
 $CloneFolder = $SourceVM.ExtensionData.Parent
 }
 }
 else {

$CloneFolder = $SourceVM.ExtensionData.Parent
 }

# --- Create CloneSpec and initiate Clone Task
 switch ($PsCmdlet.ParameterSetName)
 {
 "Named Snapshot" {

 $Snapshots = @()
 $SnapshotQuery = '$SourceVM.ExtensionData.Snapshot.RootSnapshotList[0]'

while ($Snapshot = Test-SnapshotExists -SnapshotQuery $SnapshotQuery){

$SnapshotQuery += '.ChildSnapshotList[0]'
 $Snapshots += $Snapshot
 }

$CloneSpec = New-Object Vmware.Vim.VirtualMachineCloneSpec
 $CloneSpec.Snapshot = ($Snapshots | Where-Object {$_.Name -eq $SnapshotName}).Snapshot
 $CloneSpec.Location = New-Object Vmware.Vim.VirtualMachineRelocateSpec
 $CloneSpec.Location.Pool = $DefaultClusterResourcePoolMoRef
 $CloneSpec.Location.Datastore = $DatastoreMoRef
 $CloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::$CloneType

$SourceVM.ExtensionData.CloneVM_Task($CloneFolder, $CloneName, $CloneSpec)
 }

"Current Snapshot" {

$CloneSpec = New-Object Vmware.Vim.VirtualMachineCloneSpec
 $CloneSpec.Snapshot = $SourceVM.ExtensionData.Snapshot.CurrentSnapshot
 $CloneSpec.Location = New-Object Vmware.Vim.VirtualMachineRelocateSpec
 $CloneSpec.Location.Pool = $DefaultClusterResourcePoolMoRef
 $CloneSpec.Location.Datastore = $DatastoreMoRef
 $CloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::$CloneType

$SourceVM.ExtensionData.CloneVM_Task($CloneFolder, $CloneName, $CloneSpec)
 }
 }
 }
 catch [Exception]{

 throw "Unable to deploy new VM from snapshot"
 }
}

###############################################################################################
#//XXX nicht von mir (RAC) ENDE
#Danke an: https://www.jonathanmedd.net/2013/07/clone-a-vm-from-a-snapshot-using-powercli.html
###############################################################################################




Function Search-VM{ 

    [CmdletBinding()]
    param(
    $IPAddress = "",
    $MacAddress = ""
    )

    Write-Progress -Activity "Searching VMs" -Status "Collecting VMs..."

    $a_vms=Get-VM

    $i=0
    
    $search_status_string="Searching with: "

    $a_status_strings=@()
    if($IPAddress -ne ""){
        $a_status_strings+="IP-Address $IPAddress"
    }
    if($MacAddress -ne ""){
        $a_status_strings+="Mac-Address $MacAddress"
    }

    $search_status_string+=$a_status_strings -join "; "


    $a_vms | %{
            $output_this_vm=$false

            $percent=$i / $a_vms.Count * 100

            Write-Progress -Activity "Searching VMs" -Status $search_status_string -PercentComplete $percent
            $vm=$_
            #$a_ips=@()
		    
            #Das wird eine ODER Verknüpfung
            #Wenn wir via IP-Addresse vinden
            if($IPAddress -ne ""){

                $vmIPs = $vm.Guest.IPAddress
                $vm | Add-Member -MemberType NoteProperty -Name IpAddresses -Value $vmIPs
		        foreach($ip in $vmIPs) {
			        if ($ip -eq $IPAddress) {
                        Write-Verbose("Found VM with matching IP address: {0}" -f $_.Name)
                        
                        $output_this_vm=$true
				
			        }
		        }
            }

            #ODER Wenn wir die VM via Mac-Addresse finden
            #//XXX Todo
            #(wir können das mit einem Parameter noch auf UND umbauen
            #
            if($MacAddress -ne ""){
                $vm | Add-Member -MemberType NoteProperty -Name MacAddresses -Value $vm.Guest.Nics.MacAddress
                ForEach($mac in $vm.Guest.Nics.MacAddress){
                    #//XXX Todo
                    #Hier die Suche vielleicht noch etwas "intelligenter" gestalten falls
                    #verschiedene Schreibweisen für die Mac-Addresse genutzt werden
                    if($mac -eq $MacAddress){
                        Write-Verbose("Found VM with matching Mac address: {0}" -f $_.Name)
                        $output_this_vm=$true
                    }
                }
                
            }


            if($output_this_vm){
                $vm
            }
            $i++
	    }

}


Function Report-VM {
<#
.SYNOPSIS
Reportet virtuelle Maschinen bei denen ein bestimmter Event aufgetreten ist

.DESCRIPTION
Für ale Virtuelle Maschinen wird "Get-VIEvent" ausgeführt und diese Messages werden
nach einem Event gefiltert. Maschinen die gefunden werden, werden zurückgegeben

.PARAMETER EventMessage
EventMessage nach der gesucht wird. Kann mit Wildcard "*" gefiltert werden.

.PARAMETER Start
DateTime Zeitpunkt ab dem gesucht wird

.PARAMETER End
DateTime Zeitpunkt bis zu dem gesucht wird

.EXAMPLE
Report-VM -EventMessage "vSphere HA restarted virtual machine*" -Start ((Get-Date).AddDays(-4))
#>

    param(
		[ArgumentCompleter(
			{
                param($Command,$Parameter,$WordToComplete,$CommandAst,$FakeBoundParams)
                
                $a_search_events=@(
                    '"vSphere HA restarted virtual machine*"',
                    '"Reconfigured*"'
                )

                $a_search_events | Where-Object {$_ -like ("*" + $WordToComplete + "*")}
                #$a_search_events

            }
        )]
        $EventMessage,
        $Start=(Get-Date).AddDays(-1),
        $End=(Get-Date)
    )

    Begin{}

    Process{}

    End{
        $report_objects=Get-VM | Where-Object{$_ | Get-VIEvent -Start $Start -Finish $End | 
            Where-Object{$_.FullFormattedMessage -match $EventMessage}} | VIM-Get-VMValue
        
         $report_objects | Select-Object Name,Ansprechpartner,Applikation,Stage | ConvertTo-StyledHTML | New-OutlookMail
    }

}



Function VIM-Get-VMEvents {

    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('VirtualMachine')]
        $VM
    )

    Begin{}

    Process{
        $VM | ForEach-Object {
            $o_vm=Get-VM $_

            $o_vm | Get-VIEvent | Sort-Object -Property CreatedTime | ForEach-Object {
                
                $evt=$_

                New-Object -TypeName PSObject -Property ([ordered]@{
                    VM=$evt.vm.Name
                    User=$evt.UserName
                    Type=$evt.gettype().Name
                    DateTime=$evt.CreatedTime
                    Message=$evt.FullFormattedMessage
                })

            }

        }
    }

    End{}
}

Set-Alias -Name Get-VMEvents -Value VIM-Get-VMEvents


Class VIM_VMCreation {
    $CreatedTime=""
    $CreationMethod=""
    $CreationUser=""
}


Function Get-VMCreationEvent {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('VirtualMachine')]
        $VM
    )

    Begin{}

    Process{
        $VM | ForEach-Object {
            $o_vm=$_

            $VMCreation=New-Object -TypeName VIM_VMCreation


            $o_vm | VIM-Get-VMEvents | ForEach-Object {
                $evt=$_
                if($evt.Type -in @('VmBeingDeployedEvent','VmRegisteredEvent','VmClonedEvent','VmBeingCreatedEvent')){
                    
                    if($VMCreation.CreatedTime -eq ""){
                        $VMCreation.CreatedTime=$evt.DateTime
                    }

                    switch ($evt.Type)
                    {
                        'VmClonedEvent' {$VMCreation.CreationMethod = 'Cloned'; break;} 
                        'VmRegisteredEvent' {$VMCreation.CreationMethod = 'RegisteredFromVMX'; break;} 
                        'VmBeingDeployedEvent' {$VMCreation.CreationMethod = 'VmFromTemplate'; break;}
                        'VmBeingCreatedEvent' {
                            <#
                                VmBeingCreatedEvent könnte auftreten bei
                                * NewVM
                                * OVADeployment (unter vSphere 6.7 macht das die vpxd-extension)
                            #>
                            $VMCreation.CreationMethod = 'NewVM';
                            
                            if($evt.User -like "VSPHERE.LOCAL\vpxd-extension-*"){
                                $VMCreation.CreationMethod = 'OvaDeployment'
                            }
                            break;
                        }
                        default {$CreationMethod='Unknown'; break;}
                    }   
                }

                if($VMCreation.CreationUser -eq ""){
                    $CreationUserParts=$evt.User -split '\',-1,'SimpleMatch'
                    $searchName=$CreationUserParts[1]

                    Write-Verbose("Event searchName in Active Directory: '"+$searchName + "'")

                    if(-not ($searchName -eq "" -or $null -eq $searchName)){
                        if($ADUser=Get-ADUser -Filter ('samAccountName -eq "'+ $searchName +'"')){
                            $VMCreation.CreationUser=$evt.User
                        }
                    }
                }
            }

            $VMCreation

        }
    }

    End{}
}




Function Sync-VMDocumentation {
    [CmdletBinding()]
    param()

    #Nicht mehr vorhandene VMs löschen
    Get-AllPages -namespace VM | ForEach-Object {
        $page=$_

        #$page

        #//XXX umstellen, dass ich die Informationen in ein Mediawiki Template schreibe
        #Das Template kann ich dann für den Sync wieder auslesen (und muss mich nicht alleine auf den Title verlassen)

        $match=$page.title | Select-String -Pattern 'VM:([^/]*)/(.*)'


        if($match){

            $o_page=New-Object -TypeName PSObject -Property ([ordered]@{
                datacenter=$match.Matches.Groups[1].Value
                vm=$match.Matches.Groups[2].Value
                #//XXX hier weiter
            })


            $o_pageinfo=Get-VMDocumentation -Page $page.title

            Write-Host("Fetching VM: Datacenter: "+$o_page.datacenter+ " VM: "+ $o_pageinfo.Name)

            #$old_error_pref=$ErrorActionPreference
            #$ErrorActionPreference = "Stop"
            Try{
                $vm=Get-Datacenter -Name $o_page.datacenter | Get-VM $o_pageinfo.Name
                if($vm){
                    Write-Host("VM Found: "+$page.title)
                }
                else {
                    Write-Host ("VM Not Found. Deleting Page: "+$page.title)
                    Remove-Page -title $page.title -reason ("VM '" + $page.title + "' does not exist")
                }
            }
            Catch{
                Write-Host $_.Exception.Message -ForegroundColor Red
                Write-Host $_.Exception.ItemName -ForegroundColor Red
                #Write-Host ("VM Not Found. Deleting Page: "+$page.title)
                #Remove-Page -title $page.title -reason ("VM '" + $page.title + "' does not exist")
            }

            #$ErrorActionPreference=$old_error_pref
        }
        else{

            Write-Verbose("'" + $page.title + "' does not match Regex (VM:Datacenter/VM)")

        }


    }

    Get-VM | Set-VMDocumentation

}

Function Get-VMDocumentation{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("VirtualMachine","VM")]
        $Page
    )

    Begin{}

    Process{
        $Page | ForEach-Object {
            $o_page = $_
            #$s_datacenter=($o_vm | Get-Datacenter).Name

            #Wenn ich eine VM übergeben bekommen habe, kann ich mir die Wiki Seite
            #dafür suchen
            if($o_page.GetType().Name -eq "VirtualMachineImpl"){
                $s_datacenter=$o_page | Get-Datacenter
                $wiki_content=Get-WikiPageFragment -title ("VM:"+$s_datacenter+"/"+$o_page.Name) -tag_id "vcenter_info"
            }
            else{
                $wiki_content=Get-WikiPageFragment -title $o_page -tag_id "vcenter_info"
                
            }

            $a_items=$wiki_content.Split("|")


            $o_vminfo=New-Object -TypeName PSObject
            #Erstes und letztes Item auslassen
            for($i=1;$i -lt ($a_items.Count -1); $i++){
                $a_vals=$a_items[$i].Split("=")
                $o_vminfo | Add-Member -MemberType NoteProperty -Name $a_vals[0] -Value $a_vals[1] -Force
            }

            $o_vminfo

        }
    }

    End{}
}

Function Set-VMDocumentation {
<#
.SYNOPSIS
    Erstellt die Dokumentation für eine Virtuelle Maschine
.PARAMETER VM
    VM für die Dokumentiert werden soll
.NOTES
   //XXX umstellen, dass ich die Informationen in ein Mediawiki Template schreibe
   Das Template kann ich dann für den Sync wieder auslesen (und muss mich nicht alleine auf den Title verlassen) 
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)
    )

    Begin{}

    Process{
        $VM | ForEach-Object {
            $o_vm = Get-VM $_ | VIM-Get-VMValue

            $a_tags=$o_vm | Get-TagAssignment

            $out="`r`n"

            $out+="= VM Informationen ="+ "`r`n"


            $out+='{{Template:VirtualMachine|'
            $out+='Name=' + $o_vm.Name + '|'
            $out+='Kunde=' + ($o_vm.Kunde -join ", ") + '|'
            $out+='BusinessService=' + (($a_tags.Tag | Where-Object {$_.Category -like "Business Service*"}).Name) + '|'
            $out+='Applikation=' + ($o_vm.Applikation -join ", ") + '|'
            $out+='Creator=' + ($o_vm.Creator -join ", ") + '|'
            $out+='Ansprechpartner=' + ($o_vm.Ansprechpartner -join ", ") + '|'
            $out+='Erstellt=' + ($o_vm."VIM.DateCreated") + '|'
            $out+='VerwendetBis=' + ($o_vm."VIM.DateUsedUntil") + '|'
            $out+='Beschreibung=' + ($o_vm."Notes") + '|'
            #//XXX Tags evtl aus dem Wiki Template rausnehmen und stattdessen eine Tabelle mit jeweils Name und Beschreibung rendern
            $out+='Tags=' + ($a_tags.Tag.Name -join ", ") + '|'
            $out+='VMRC=' + ($o_vm | Get-VMRC-Url) + '|'
            $out+='}}'
            $out+="`r`n"

            $datacenter=Get-Datacenter -VM $o_vm

            $wiki_title="VM:" + $datacenter + "/"+$o_vm.Name

            Set-WikiPageFragment -title $wiki_title -tag_id "vcenter_info" -content $out

        }
    }

    End{}

}


Function Get-VMHardDiskLUNReport {

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)
    )
    
    Begin{}

    Process{
        $VM | ForEach-Object {
            $o_vm = $_
            $o_vm | Get-HardDisk | Select Parent, Name, CapacityGB, Filename, StorageFormat
        }
    }

    End{}

}

Function Get-VMDocAnsprechpartnerStrings {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        $VMDocumentation
    )

    Begin{}

    Process{

        $VMDocumentation | ForEach-Object {
            $o_vmdoc=$_
            $a_strings=$o_vmdoc.Ansprechpartner -split "; Ansprechpartner,{0,1} {0,1}"

            $a_strings | ForEach-Object {
                $str=$_
                if($str -ne ""){
                    $str
                }
            }
        }
    }

    End{}
}

Function Recover-VMDocumentationFromWiki {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('VirtualMachine')]
        $VM=(Get-VM)
    )

    Begin{}

    Process{

        $VM | ForEach-Object {
            $o_vm=Get-VM $_

            $o_vmdoc=$o_vm | Get-VMDocumentation

            #Kunden Tags holen
            $a_kunden=$o_vmdoc.Kunde -split ", "
            $o_kunden_tags=Get-Tag -Category "Kunde" -Name $a_kunden

            #Kunden Tags setzen
            $o_kunden_tags | ForEach-Object {$o_vm | New-TagAssignment -Tag $_}

            #Business Service Tags holen
            $a_val=$o_vmdoc.BusinessService -split ", "
            $o_val_tags=Get-Tag -Category "Business Service" -Name $a_val

            #Business Service Tags setzen
            $o_val_tags | ForEach-Object {$o_vm | New-TagAssignment -Tag $_}

            #Applikation Tags holen
            $a_val=$o_vmdoc.Applikation -split ", "
            $o_val_tags=Get-Tag -Category "Applikation" -Name $a_val

            #Business Service Tags setzen
            $o_val_tags | ForEach-Object {$o_vm | New-TagAssignment -Tag $_}


            #Creator Setzen
            $o_val_tag=Get-Tag -Category Creator -Name $o_vmdoc.Creator
            New-TagAssignment -Entity $o_vm -Tag $o_val_tag

            #Ansprechparnter setzen
            Get-VMDocAnsprechpartnerStrings -VMDocumentation $o_vmdoc | ForEach-Object {
                $o_val_tag = Get-Tag -Category Ansprechpartner -Name ($_+"; Ansprechpartner")
                New-TagAssignment -Entity $o_vm -Tag $o_val_tag
            }

            #Erstellt, UsedUntil usw
            $o_vm | VIM-Set-Value -DateCreated $o_vmdoc.Erstellt -DateUsedUntil $o_vmdoc.VerwendetBis -CreationMethod "Recovered" -CreationUser "vcenter"

        }
    }

    End{}

}


#//XXX hier weiter
Function Shutdown-BusinessServiceVM {
    param(
        $BusinessService
    )

    Get-VM -Tag (Get-Tag -Category "Business Service" -Name $BusinessService) | VIM-Shutdown-VM
}

Function Start-BusinessServiceVM {
    param(
        $BusinessService
    )

    Get-VM -Tag (Get-Tag -Category "Business Service" -Name $BusinessService) | Start-VM
}

Function Reduce-VMCpuReservation {

    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('VirtualMachine')]
        $VM=(Get-VM),
        $percent=0
    )


    Begin{}

    Process{
        $VM | ForEach-Object {
            $o_vm=$_

            $o_vm | VIM-Get-ResourceReservation | ForEach-Object{
                Set-VMResourceConfiguration -Configuration $_ -CpuReservationMhz ([int]$_.CpuReservationMhz * ($percent / 100))
            }
        }
    }

    End{}

}


Function Deploy-Ovf {
    [cmdletBinding()]
    param(
        $OvfConfig,
        $VMName,
        [ValidateSet("Thick","Thin","EagerZeroedThick")]
        $DiskStorageFormat,

        $VMHost=$global:vim_focus.VMHost,
        $Folder=$global:vim_focus.Folder,
        $Datastore=$global:vim_focus.Datastore,
        [switch]$RemoveReservations,
        [switch]$StartImmediately
    )

    $vm=Import-VApp -Source $OvfConfig.Source -OvfConfiguration $OvfConfig -Name $OvfConfig.Common.hostname `
        -InventoryLocation $Folder `
        -VMHost $VMHost `
        -Datastore $Datastore `
        -DiskStorageFormat $DiskStorageFormat

    if($RemoveReservations){
        #Es kann sein, dass ich keine Reservierungen brauchen kann
        $reservation_result=$vm | VIM-Get-ResourceReservation | %{Set-VMResourceConfiguration -Configuration $_ -CpuReservationMhz 0 -MemReservationGB 0}
    }
    
    if($StartImmediately){
        $vm=Get-VM $vm | Start-VM
    }

    #Hier könnte so etwas wie "Calculate Reservations" kommen. aber initial erst mal nicht

    #Ausgabe
    Get-VM $vm
}

Set-Alias -Name Deploy-Ova -Value Deploy-Ovf

<#
.SYNOPSIS
    Erstellt ein Template Script für das Deployment eines OVA / OVF
.DESCRIPTION
    Dieses Cmdlet liest die Konfigurationsparameter aus einer OVA / OVF.
    Alle möglichen zu befüllenden Parameter werden übersichtlich in Powershell
    Syntax als ein Script ausgegeben. Standardmäßig wird das Script an StdOut
    ausgegeben. Die Ausgabe kann also entweder vom Bildschirm kopiert, oder
    direkt in eine Script Datei umgeleitet werden
.PARAMETER ovfconfig
    Ein OvfConfig Objekt das mittels Get-OvfConfiguration erstellt wurde
.PARAMETER withHeader
    Der Header des Scripts, der das Laden der Ovf zeigt (standardmäßig AN)
.PARAMETER withFooter
    Der Footer des Scripts der das Deployment mit der erstellten Konfig zeigt (standardmäßig AN)
.PARAMETER withDescription
    Die Beschreibung eines jeden Konfigurationsparameters wird als Kommentar in das Script eingefügt.
    Das Template Script wird dadurch sehr umfangreich bzw unübersichtlich (standardmäßig AUS)
.EXAMPLE
    Get-OvfConfigTemplateScript -ovfconfig (Get-OvfConfiguration -Ovf ".\AAM\AAM-07.0.0.0.441-e55-0.ova")
.EXAMPLE
    Get-OvfConfigTemplateScript -ovfconfig (Get-OvfConfiguration -Ovf "SMGR\SMGR-7.1.0.0.1125193-e65-50\SMGR-7.1.0.0.1125193-e65-50.ovf")
    #Das SMGR .ova hatte Fehler. Daher hatte ich es entpackt, korrigiert. aber nicht mehr eingepackt, sondern direkt das .ovf verwendet
.EXAMPLE
    #Das ganze geht natürlich auf auf mehrere Schritte
    $ovfconfig=Get-OvfConfiguration -Ovf ($ovapath + "\SMGR\SMGR-7.1.0.0.1125193-e65-50\SMGR-7.1.0.0.1125193-e65-50.ovf")
    Get-OvfConfigTemplateScript -ovfconfig $ovfconfig | Out-File smgrDeployTest.ps1
#>
Function Get-OvfConfigTemplateScript {
    [cmdletBinding()]
    param(
        $ovfconfig,
        [switch]$withHeader=$true,
        [switch]$withFooter=$true,
        [switch]$withDescription=$false
    )

    #$ovfconfig=Get-OvfConfiguration -Ovf ($ovapath + "\CM\CM-Duplex-07.1.0.0.532-e65-0.ova")
    #Header
    #Im Header laden wir die Config
    if($withHeader){
        $line='$ovfconfig=Get-OvfConfiguration -Ovf '''+ $ovfconfig.Source +''''
        $line
        ''
    }

    #DeploymentOption ist ein Sonderfall
    $line='{0,-60}{1,-2}{2}' -f 
        ('$ovfconfig.DeploymentOption.Value'),
        '=',
        ("'"+$ovfconfig.DeploymentOption.DefaultValue+"'")
    $line

    #Jetzt gehen wir durch die restlichen Properties in der ovfconfig
    $ovfconfig.PSObject.Properties | 
        Where-Object {$_.Name -notin @("Source","DeploymentOption")} | 
        ForEach-Object {
            $catProp=$_
            #Eine leere Zeile :)
            ''
            $line=("#Category: " + $catProp.Name)
            $line
        
        
            #$catProp

            $catProp.Value.PSObject.Properties | ForEach-Object {
                $setProp=$_

                #$ovfconfig.($catProp.Name).($setProp.Name).DefaultValue -eq ''
                #$defConfValue
                if($ovfconfig.($catProp.Name).($setProp.Name).DefaultValue -ne ''){
                    $defConfValue="'"+$ovfconfig.($catProp.Name).($setProp.Name).DefaultValue+"'"
                }
                else{
                    $defConfValue='$null'
                }
                <#
                #Nur die ersten 10 Zeichen der Description
                $desc=$ovfconfig.($catProp.Name).($setProp.Name).Description
                $out_desc=$desc.substring(0,[System.Math]::Min(10,$desc.Length))
                #>

                #$ovfconfig.($catProp.Name).($setProp.Name).Description



                if($withDescription){
                    ''
                    '<#'
                    'Description:'
                    $ovfconfig.($catProp.Name).($setProp.Name).Description
                    ''
                    'OvfTypeDescription:'
                    $ovfconfig.($catProp.Name).($setProp.Name).OvfTypeDescription
                    '#>'
                }

                $line='{0,-60}{1,-2}{2}' -f 
                    ('$ovfconfig.'+ $catProp.Name + '.' + $setProp.Name + '.Value'),
                    '=',
                    ($defConfValue)
                

                $line
            }

        }


    if($withFooter){
'
Deploy-OVA -OvfConfig $ovfconfig `
    -VMName "NewVmName" `
    -DiskStorageFormat Thin `
    -RemoveReservations `
    -StartImmediately 
'
    }


}

Set-Alias -Name Get-OvaConfigTemplateScript -Value Get-OvfConfigTemplateScript
Set-Alias -Name VIM-Search-VM -Value Search-VM


function New-VIAccount($principal) {
    $flags = `
        [System.Reflection.BindingFlags]::NonPublic    -bor
        [System.Reflection.BindingFlags]::Public       -bor
        [System.Reflection.BindingFlags]::DeclaredOnly -bor
        [System.Reflection.BindingFlags]::Instance

    $method = $global:defaultviserver.GetType().GetMethods($flags) | where { $_.Name -eq "GetClient" }
    #where { $_.Name -eq "VMware.VimAutomation.Types.VIObjectCore.get_Client" }

    $client = $method.Invoke($global:DefaultVIServer, $null)
    Write-Output (New-Object VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.VIUserAccountImpl  -ArgumentList $principal, "", $client)

}




<#
Argument Completers fürd die gesamte VMWare.PowerCLI
So hängt man an bestehende Funktionen einen Argument Completer "dran" du kannst also z.B. auch Get-AD User mit einem Argument Completer erweitern
ohne dass du Get-ADUser bearbeiten können musst

Das hier ist scheinbar auch die einzige Möglichkeit um Argument Completer VORHER in einer Konstante zu definieren und dann einfach
mittels Variable anzuhängen.

Die hier drüber definierten VimArgumentCompleters kann icht nicht Inline in den params() angeben, allerdings geht trotzdem das anhängen mittels
Register-ArgumentCompleter 
#>
Register-ArgumentCompleter -CommandName Get-VMHost -ParameterName Name -ScriptBlock $global:VimArgumentCompleters.VMHost
Register-ArgumentCompleter -CommandName Get-VM -ParameterName Name -ScriptBlock $global:VimArgumentCompleters.VM
Register-ArgumentCompleter -CommandName Get-Datastore -ParameterName Name -ScriptBlock $global:VimArgumentCompleters.Datastore
Register-ArgumentCompleter -CommandName Get-Tag -ParameterName Name -ScriptBlock $global:VimArgumentCompleters.TagName
Register-ArgumentCompleter -CommandName Get-Tag -ParameterName Category -ScriptBlock $global:VimArgumentCompleters.TagCategory
Register-ArgumentCompleter -CommandName New-TagAssignment -ParameterName Entity -ScriptBlock $global:VimArgumentCompleters.VM
Register-ArgumentCompleter -CommandName New-TagAssignment -ParameterName Tag -ScriptBlock $global:VimArgumentCompleters.TagName
Register-ArgumentCompleter -CommandName VIM-ReRegister-VM -ParameterName NewVMHost -ScriptBlock $global:VimArgumentCompleters.VMHost
Register-ArgumentCompleter -CommandName VIM-Set-DatastoreFocus -ParameterName Datastore -ScriptBlock $global:VimArgumentCompleters.Datastore
Register-ArgumentCompleter -CommandName Get-Network -ParameterName Name -ScriptBlock $global:VimArgumentCompleters.Network

Register-ArgumentCompleter -CommandName Set-VMHostFocus -ParameterName VMHost -ScriptBlock $global:VimArgumentCompleters.VMHost
Register-ArgumentCompleter -CommandName Set-DatastoreFocus -ParameterName Datastore -ScriptBlock $global:VimArgumentCompleters.Datastore
Register-ArgumentCompleter -CommandName Set-NetworkFocus -ParameterName Network -ScriptBlock $global:VimArgumentCompleters.Network
Register-ArgumentCompleter -CommandName Set-VMFocus -ParameterName VM -ScriptBlock $global:VimArgumentCompleters.VM
#Register-ArgumentCompleter -CommandName VIM-ReRegister-VM -ParameterName VM -ScriptBlock $global:VimArgumentCompleters.VM


Export-ModuleMember -Alias * -Function *



