<#
VMWare Virtual-Infrastructure-Management
Funktionen mit denen eine VMWare Umgebung schneller, besser gemanaged werden kann


PREREQUISITES
*https://github.com/rgel/PowerCLi

//XXX ToDo noch ein paar Dinge von mir sind Vorraussetzung, das weiß ich aber gerade nicht auswendig


Geplante Funktionen

*VIM-Export-Tags -xmlfile
    Exportiert Tag-Kategorie und Tags einer vCenter Umgebung in ein XML-File
    Tag Kategorien:
        *Kategoriename
        *Beschreibung
        *Kardinalität (1:n, n:m)
        *Zuweisbare Elemente (Hosts, VMs, Datenspeicher, Sonstiges, Alles)
    Tags
        *Tags mit zugehörigkeit zu Kategorie


*VIM-Import-Tags -xmlfile
    Importiert Tag-Kategorien und Tags anhand einer XML wie sie von VIM-Export-Tags generiert wurde

*VIM-Get-Contact-Assignment ERLEDIGT
	Zeigt Ansprechpartner einer VM

*VIM-Sync-Contact -AD ERLEDIGT
	Synchronisiert Ansprechpartner mit einer Active Directory OU

*VIM-Export-Tags -xmlfile
	Exportiert vorhandene Tags (ohne Assignments) in eine XML

*VIM-Import-Tags -xmlfile
	Importiert Tags aus einer XML

*VIM-Set-VMValue      Also Synchronisation danach "VIM-Sync-Values-To-Description" aufrufen
    -DateCreated      Schreibt Annotation VIM.DateCreated 
    -DateUsedUntil    Schreibt Annotation VIM.DateUsedUntil

*VIM-Sync-Values-To-Description
    Synchronisiert Annotations (evtl auch Tags und dergleichen) als XML in die Description

*VIM-Set-CreationByEvent ERLEDIGT
	Setzt DateCreated und DatedUsed Until anhand bisher vorhandener Informationen

*VIM-Get-VMEndOfLife -DaysToUsedUntil
	Zeigt VMs die bald ablaufen (DateUsedUntil)

*VIM-Get-vSwitch ERLEDIGT
	Holt alle vSwitche einer vCenter Umgebung anhand von Tags

*VIM-AddVLAN -vlan_name -vlan_id -vSwitchCategory
	Fügt ein VLAN zu einer vSwitchCategory hinzu (siehe VIM-Get-vSwitch)

*VIM-Backup-vCenter ERLEDIGT
    Erstellt ein Backup des vCenter Hosts indem er diesen klont

*VIM-Check-Tags ERLEDIGT


//XXX Todo
* VIM.DeleteMarkerDate -> Wann wurde die VM zum löschen markiert
* Abgelaufene VMs automatisch herunterfahren

#>

$global:mail_smtp_server="192.168.100.3"
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
$global:vim_ad_groups=@("VMWare-MainUsers","VMWare-Administrators")


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
Progress IDs für Write-Progess
#>
$global:progress_vm_count=1
$global:progress_cur_action=2


#Types Beginn##############################################
Add-Type -AssemblyName System.Web


#Types Ende################################################


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

    [string]$ArchiveDateArchived=""

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
                } Catch {}   
            }
            if(-not $DateUsedUntil      -eq "") { 
                Try{
                    $s_DateUsedUntil=Get-Date -format "yyyy-MM-dd HH:mm" $DateUsedUntil
                    $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.DateUsedUntil"      -Value $s_DateUsedUntil 
                } Catch{}
            
            }
            if(-not $CreationMethod       -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.CreationMethod"       -Value $CreationMethod }
            if(-not $CreationUser         -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.CreationUser"         -Value $CreationUser }
            if(-not $ArchiveOrigDatastore -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.ArchiveOrigDatastore" -Value $ArchiveOrigDatastore}
            if(-not $ArchiveDateArchived  -eq "") { $o_vm = VIM-Annotation -VM $o_vm -Attribute "VIM.ArchiveDateArchived"  -Value $ArchiveDateArchived}
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
    
    Begin {}

    Process {
        $VM | ForEach-Object {
            
            if($_.GetType().Name -eq "String")
            {
                $o_vm = Get-VM ($_ -replace '/','%2f')
            }
            else
            {
                $o_vm = $_
            }

            if($StageByFolder){
                $o_vm = VIM-Check-Tags -VM $o_vm -StageByFolder 
            }
            else {
                $o_vm = VIM-Check-Tags -VM $o_vm
            }

            ForEach ($att in $vim_custom_attributes){
                Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $att.Name -Value (Get-Annotation -Entity $o_vm -Name $att.Name).Value -Force
            }
            
            $o_vm
        }
    }

    End {}
        
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
        $count=($p_vm | Measure-Object).Count
        $p_vm | ForEach-Object {
            $o_vm = $_
            $o_vm = VIM-Get-VMValue -VM $o_vm
            $a_vm += $o_vm
            
            $i++
            #Status Zwischenbereicht
            $percent=$i / $count * 100
            # + $percent + " %"
            Write-Progress -Activity "Collecting Information" -Status ([string]$i + " VMs ") -PercentComplete $percent
        } #//XXX Mit Grid könnte ich hier evtl eine Pipeline dran hängen, für Schnellere Ausgabe

        #Formatierte Ausgabe
        if ($Grid){
            $a_vm | Select $columns | Out-GridView
        }
        else {
            $a_vm | Format-Table $columns -AutoSize
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

                $o_vm | Get-VMCreationDate | ForEach-Object {
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
                    }
                }
                Catch {
                    Write-Host $("VIM.CreationUser:'" + $s_VIMCreationUser + "': AD-User wurde nicht gefunden")
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
            $a_missing_tags = @()
            ForEach($category in $a_needed_tag_category){
                $tags=$false
                $tags=$($o_vm | Get-TagAssignment -Category $category)

                $a_vals=@()
                ForEach($tag in $tags){
                    $a_vals+=$tag.Tag.Name
                }
                Add-Member -InputObject $o_vm -MemberType NoteProperty -Name $category -Value $a_vals -ErrorAction SilentlyContinue

                if(-not $tags)
                {
                    $a_missing_tags+=$category
                }
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
        if($Contact.GetType().Name -eq "TagImpl")
        {
            $vm = Get-VM -Tag $Contact 
        }
        else
        {
            $tag = Get-Tag -Category "Ansprechpartner" -Name $Contact
            $vm = Get-VM -Tag $tag
        }

    }
    else {
        $vm = Get-VM 
    }
    $vm | VIM-Get-VMValue -StageByFolder:$true | ?{$_.missingTags.Length -gt 0}
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

    VIM-Get-VM-MissingTags |
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
            Catch {}
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
                    }
                }

            }
            Catch{
                Write-Error $_
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

            $thisModuleDir = Split-Path (Get-Module -ListAvailable Virtual-Infrastructure-Management).Path -parent
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
    . "$thisModuleDir\resources\vCheck-vSphere\Plugins\60 VM\02 Snapshot Information.ps1"

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
                @{Expression={[int]$_.UsedSpaceGB};Label="SpaceGB_Provisioned";Width=20}

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
        
        [switch]$Confirm=$false
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
        VIM-Shutdown-VM -VM $vms

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

            if($current_datastore -ne $archive_datastore.Name){
                #Speichern auf welchem Datastore die VM war
                $vm | VIM-Set-VMValue -ArchiveOrigDatastore $current_datastore -ArchiveDateArchived ([string](Get-Date -format "yyyy-MM-dd HH:mm"))

                #Die Stage auf "Archiv" wechseln
                Remove-TagAssignment -TagAssignment (Get-TagAssignment -Entity $vm -Category "Stage") -Confirm:$false
                New-TagAssignment -Tag (Get-Tag -Category "Stage" -Name "Archiv Stage") -Entity $vm

                #Zu guter letzt die VM umziehen
                $vm | Move-VM -Datastore (Get-Datastore $archive_datastore) -DiskStorageFormat Thin -RunAsync -Confirm:$Confirm
            }
        }


        #Wir benachrichtigen die Besitzer, dass die VMs archiviert wurden
        $vms | VIM-Mail-VM-Archived


    }
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
.EXAMPLE
    Get-VM deslnvmowncl | VIM-UnArchive-VM
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
        $VM,
        [Parameter(Mandatory=$true)][ValidateSet("Test","Live","Development")]$ToStage,
        <#
            Zu dieser Storage wird die VM wiederhergestellt (Name, wie in der vCenter Speicher Ansicht)
            Wird $ToStorage nicht angegeben, wird die zuvor gespeicherte Storage verwendet
        #>
        [Parameter(Mandatory=$false)]$ToStorage="",
        
        <#
            Auf diesem ESX-Host wird die VM dann wieder gestartet
        #>
        [Parameter(Mandatory=$false)]$ToHost="",

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
            $vm=$_



            Try {

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

                $vm=Move-VM -VM $vm -Destination $TargetHost -Datastore $TargetStorage -ErrorAction Stop

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
                            Remove-VIPermission -Confirm:$false
                }

                ForEach ($acc in $user_acc){
                    Get-VIPermission -Entity $vm -Principal $acc | 
                        Where-Object { $_.Entity.Uid -eq $vm.Uid } |
                            Remove-VIPermission -Confirm:$false
                }

                #Die Stage auf zum "Ziel" wechseln
                Remove-TagAssignment -TagAssignment (Get-TagAssignment -Entity $vm -Category "Stage") -Confirm:$false
                New-TagAssignment -Tag (Get-Tag -Category "Stage" -Name $ToStage) -Entity $vm

                if($StartImmediately){
                    $vm = Get-VM $vm
                    Start-VM $vm
                }
            }
            Catch{
                Write-Error "VM konnte nicht erfolgreich UnArchiviert werden"
            }


        }
    }

}

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
    $VM
    )

    Begin {}

    Process{
        $VM | ForEach-Object {
            $o_vm = $_

            #Notwendige Daten der VM merken
            $vm_name=$o_vm.Name
            $vm_host=$o_vm.VMHost.Name
            $vmx_path=$o_vm.ExtensionData.Config.Files.VmPathName

            $vm_folder=$o_vm.Folder


            Write-Host ("ReRegister VM: '"+$vm_name + "' with VMX path: '" + $vmx_path + "' on Host: '" + $vm_host + "'")

            $o_annotations = Get-Annotation -Entity $o_vm
            $o_tagass = Get-TagAssignment -Entity $o_vm


            #VM neu registrieren
            $remove_result=$o_vm | Remove-VM -Confirm:$false
            $new_vm=New-VM -Name $vm_name -VMHost $vm_host -VMFilePath $vmx_path -Location $vm_folder


            #Alle Annotations und Tags der VM wieder setzen
            ForEach($annotation in $o_annotations)
            {
                   $temp=$new_vm | Set-Annotation -CustomAttribute $annotation.Name -Value $annotation.Value
            }

            ForEach($tagass in $o_tagass){
                $temp=New-TagAssignment -Entity $new_vm -Tag $tagass.Tag
            }

            #VM zurück Geben
            Get-VM $new_vm.Name

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

$global:ovftool="C:\Program Files\VMware\VMware OVF Tool\ovftool.exe"


<#
.SYNOPSIS
    Exportiert VMs in ein Verzeichnis im OVF Format.
.DESCRIPTION
    Exportiert VMs in ein Verzeichnis im OVF Format. Es werden Zusatzinformationen
    in .cli.xml exportiert um eine Übernahme von Hardware IDs (BIOS Seriennummer,
    Mac-Addressen) sicherstellen zu können.
    Der Export mit OVFTool über dieses Commandlet scheint besser zu funtionieren als die
    Export-OVA Funktion in vSphere Client.
    
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
.PARAMETER ovftool
    Pfad zur ovftool.exe falls du eine andere Version verwenden willst
.PARAMETER openssl
    Openssl wird benötigt um eine Manifest Datei zu erstellen. Noch nicht vollständig implementiert
    Es geht auch ohne Manifest
#>
Function Export-VM-toOVFDir {
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

            #Wenn ich Geklonte VMs kopieren will, aber die Hardware IDs von der Original VM haben möchte
            if($vmparam.GetType().Name -eq "Hashtable"){
                $o_vm=Get-VM $vmparam.VM
                $o_hwvm=Get-VM $vmparam.HWFrom
            }
            else{
                #Wenn der Parameter ein String oder ein VM Objek ist, geht das hier beides
                $o_vm=Get-VM $vmparam
                $o_hwvm=Get-VM $vmparam
            }

            $percent=$i / $a_vm.Count * 100

            #Write-Host ("Working on: "+$o_vm.Name)
            $start_time=Get-Date
            Write-Progress -Id 10 -Activity ("Exporting VMs to OVA - Started: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss" $start_time)) -Status ("Working on: "+$o_vm.Name + " - " + $i + " of " + $a_vm.Count) -PercentComplete $percent

            $session = Get-View -Id SessionManager
            $ticket = $session.AcquireCloneTicket()

            if($WithSameHardwareIDs){
                $export_flags="--exportFlags=mac,uuid"
            }
            else{
                $export_flags=""
            }

            #Das ist der eigentliche Export Befehl
            . $ovftool $export_flags --overwrite --acceptAllEulas --skipManifestGeneration --noSSLVerify ("--I:sourceSessionTicket="+$ticket) ("vi://" + $SourceVCenter + "?moref=vim.VirtualMachine:" + $o_vm.ExtensionData.MoRef.Value) (Get-Item $ExportDestination).FullName | ForEach-Object {
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

            $out_dir=Get-Item ($ExportDestination + "\" + $o_vm.Name)
            $out_dir

            $i++
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
    https://www.vmware.com/support/developer/ovf/ovftool-430-userguide.pdf
#>
Function Import-VM-fromOVFDir {
    param(
        [Parameter(
            Position=0, 
            ValueFromPipeline=$true,
            Mandatory=$true)
        ]
        $OVFDir,
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

            $o_TargetHost=Get-VMHost $TargetHost


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


Export-ModuleMember -Alias * -Function *
