

if(!(Get-Module VMWare.VimAutomation.Core))
{
	Add-PSSnapin -Name VMWare.VimAutomation.Core
}

#Default Verhalten
#Immer nur mit EINEM Server verbinden
Set-PowerCLIConfiguration -Scope User -DefaultVIServerMode Single -Confirm:$false
#SSL Zertifikate ignorieren
Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction Ignore -Confirm:$false

#VIB-Configure-Cluster-Servers Konfiguriert alle Server die in der XML angegeben sind
#Cluster Konfiguration kann erst stattfinden wenn ich ein vCenter zur Verfügung habe

<#
.SYNOPSIS
    Konfiguriert Cluster
.DESCRIPTION
    Test
.PARAMETER xml
    Pfad zu einer XML Datei in der die zu bauende virtuelle Umgebung beschrieben ist
.PARAMETER cluster
    Cluster für den die Konfiguration durchgeführt werden soll
    das Script verbindet sich DIREKT mit root Credentials zu den Hosts
    und konfiguriert diese
.EXAMPLE
    VIB-Configure-Cluster-Servers -xml customer.vib.xml -cluster CustomerCluster
.LINK
    http://wiki.megatech.local/mediawiki/index.php/PSCmdlet:VIB-Configure-Cluster-Servers
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Virtual_Infrastructure_Builder
.NOTES
    Author: Rudolf Achter
    Date:   2015-11-01
#>
Function VIB-Configure-Cluster-Servers {
    [CmdletBinding()]
    param (
            [parameter(Mandatory=$true)] [string]$xml,
            [parameter(Mandatory=$true)] [string]$cluster)

    [xml]$x_vib=Get-Content $xml

    $x_datacenter=$x_vib.vib.vcenter.datacenter


    $x_vib.vib.vcenter.datacenter.clusters.cluster | Where-Object {$_.name -eq $cluster} | ForEach-Object {
        Write-Host "Konfiguriere Cluster Server für " $_.name
        $x_cluster=$_
        $x_credentials = $x_cluster.servers.credentials
        $x_cluster.servers.server | ForEach-Object {
            $x_server=$_            
            #Hier wird EIN ESX Server konfiguriert
            _VIB-Configure-Host

        }
    }
}

#_VIB-Configure-Host Konfiguriert einen einzelnen Server
#Wird von VIB-Configure-Cluster-Servers aufgerufen
Function _VIB-Configure-Host
{
    param()

    $s_hostname = $x_datacenter.networks.settings.standard.hostname_prefix + "esx" + $x_server.name_suffix
    Write-Host "Verbinde mit Host" $s_hostname $x_datacenter.networks.settings.standard $x_server.mgmt_ip
    $server=Connect-VIServer -Server $x_server.mgmt_ip -User $x_credentials.user -Password $x_credentials.password
    

    Write-Host "Verbunden mit Host" $x_server.mgmt_ip

    $x_cluster.settings | ForEach-Object {
        $_.vswitch | ForEach-Object {
            $x_vswitch=$_
            
            _VIB-Configure-Host-vSwitch
            #//iSCSI
            _VIB-Configure-Host-iSCSI

            #//XXX Virtuelle Portgruppen für virtuelle Maschinen anlegen
            
            #//XXX Set-NicTeamingPolicy Override für vpg für virtuelle Maschinen

        }
    }

    Disconnect-VIServer -Server $server -Confirm:$false

}

#_VIB-Configure-Host-vSwitch konfiguriert einen vSwitch eines Servers
#Wird von _VIB-Configure-Host aufgerufen
Function _VIB-Configure-Host-vSwitch {
    param ()
#//XXX Möglicher Override
            #Bei jedem Host könnten die vmnics anders heissen
            
            #$vswitch =  New-VirtualSwitch -VMHost 10.23.114.234 -Name VSwitch -Nic vmnic5,vmnic6
            #$vportgroup =  New-VirtualPortGroup -VirtualSwitch $vswitch -Name VPortGroup
            Write-Host "Konfiguriere vswitch:" $_.name "Mit vNICs" $($_.vmnic.name -join ',')

            if($vswitch = Get-VirtualSwitch -Server $server -Name $_.name -ErrorAction SilentlyContinue)
            {
                #vSwitch gib es bereits, editieren
                Write-Host "vSwitch" $vswitch "gibt es bereits"
                #Set-VirtualSwitch -VirtualSwitch $vswitch -Nic $_.vmnic.name
                $_.vmnic.name | ForEach-Object {
                    Add-VirtualSwitchPhysicalNetworkAdapter -Confirm:$false -VirtualSwitch $vswitch -VMHostPhysicalNic (Get-VMHostNetworkAdapter -Name $_)
                }
            }
            else
            {
                #vSwitch gibt es noch nicht, erstellen
                $vswitch = New-VirtualSwitch -Server $server -Name $_.name -Nic $_.vmnic.name
                            
            }

            
            $policy = $vswitch | Get-NicTeamingPolicy

            #Active Standby Unused Regeln für vSwitch Global
                        
            $_.vmnic | Where-Object {$_.teaming -eq "active"} | ForEach-Object {
                $policy | Set-NicTeamingPolicy -MakeNicActive $(Get-VMHostNetworkAdapter -Name $_.name)
            }

            $_.vmnic | Where-Object {$_.teaming -eq "standby"} | ForEach-Object {
                $policy | Set-NicTeamingPolicy -MakeNicStandby $(Get-VMHostNetworkAdapter -Name $_.name)
            }

            $_.vmnic | Where-Object {$_.teaming -eq "unused"} | ForEach-Object {
                $policy | Set-NicTeamingPolicy -MakeNicUnused $(Get-VMHostNetworkAdapter -Name $_.name)
            }


            #VM Kernel Ports konfigurieren

            $_.vmk | ForEach-Object {
                $x_vmk = $_
                #use the .Net System.Convert ToBoolean method:
                #[System.Convert]::ToBoolean
                $x_networksettings = $x_datacenter.networks.settings.standard
                $x_network = $x_datacenter.networks.network | Where-Object {$_.name -eq $x_vmk.network}

                $s_vlan_id = $x_networksettings.vlan_id_prefix + $x_network.vlan_id_suffix
                $s_ip = $x_network.ip_prefix + $x_server.ip_suffix
                $s_subnet_mask = $x_network.ip_mask

                Write-Host "VLAN-ID:" $s_vlan_id
                Write-Host "IPV4-Address:" $s_ip
                Write-Host "Management: " $([System.Convert]::ToBoolean($_.mgmt))

                if ($vpg = Get-VirtualPortGroup -Server $server -Name $_.network -ErrorAction SilentlyContinue)
                {
                    #PortGroup gibt es Bereits, VLAN ID anpassen
                    Set-VirtualPortGroup -VirtualPortGroup $vpg -VLanId $s_vlan_id -Confirm:$false
                }
                else
                {
                    #PortGroup neu Anlegen
                    $vpg = New-VirtualPortGroup -Server $server -VirtualSwitch $vswitch -Name $_.network -VLanId $s_vlan_id
                }

                #//XXX Set-NicTeamingPolicy Override für VMKernel vpg
                $policy = $vpg | Get-NicTeamingPolicy 

                $x_vmk.vmnic | Where-Object {$_.teaming -eq "active"} | ForEach-Object {
                    $x_vmnic = $_
                    $policy | Set-NicTeamingPolicy -MakeNicActive $(Get-VMHostNetworkAdapter -Name $x_vmnic.name)
                }

                $x_vmk.vmnic | Where-Object {$_.teaming -eq "standby"} | ForEach-Object {
                    $x_vmnic = $_
                    $policy | Set-NicTeamingPolicy -MakeNicStandby $(Get-VMHostNetworkAdapter -Name $x_vmnic.name)
                }

                $x_vmk.vmnic | Where-Object {$_.teaming -eq "unused"} | ForEach-Object {
                    $x_vmnic = $_
                    $policy | Set-NicTeamingPolicy -MakeNicUnused $(Get-VMHostNetworkAdapter -Name $x_vmnic.name)
                }


                if ($vmk = Get-VMHostNetworkAdapter -PortGroup $vpg -ErrorAction SilentlyContinue)
                {
                    Write-Host "VMKernel Adapter" $vmk "gibt es bereits. Dieser kann nicht editiert werden."
                    Write-Host "Sollten Einstellungen am VMKernel Adapter geändert werden müssen, muss dieser gelöscht werden"
                    $vmk

                    #//XXX das hier funktioniert nicht wirklich

                    ##VMKernel Port gibt es Bereits
                    #$vmk=Set-VMHostNetworkAdapter -VirtualNic $vmk `                    #    -ManagementTrafficEnabled $([System.Convert]::ToBoolean($_.mgmt)) `                    #    -VMotionEnabled $([System.Convert]::ToBoolean($_.vmotion)) `
                    #    -FaultToleranceLoggingEnabled $([System.Convert]::ToBoolean($_.ft)) `
                    #    -VsanTrafficEnabled $([System.Convert]::ToBoolean($_.vsan)) `
                    #    -Confirm:$false
                    #
                    ##//XXX RAC hier scheinen wir einen Bug zu haben. IP, Addresse kann scheinbar nicht editiert werden
                    #$vmk=Set-VMHostNetworkAdapter -VirtualNic $vmk `                    #    -IP $s_ip `                    #    -SubnetMask $s_subnet_mask `
                    #    -Confirm:$false


                }
                else
                {
                    #VMKernel Port neu anlegen
                    $vmk = New-VMHostNetworkAdapter -Server $server -VirtualSwitch $vswitch `                        -PortGroup $vpg.Name `                        -ManagementTrafficEnabled $([System.Convert]::ToBoolean($_.mgmt)) `                        -VMotionEnabled $([System.Convert]::ToBoolean($_.vmotion)) `
                        -FaultToleranceLoggingEnabled $([System.Convert]::ToBoolean($_.ft)) `
                        -VsanTrafficEnabled $([System.Convert]::ToBoolean($_.vsan)) `
                        -IP $s_ip `                        -SubnetMask $s_subnet_mask
                }

            }

 }

#_VIB-Configure-Host-iSCSI konfiguriert das iSCSI Adapter Mapping für einen vSwitch eines Servers
#wird von _VIB-Configure-Host aufgerufen
Function _VIB-Configure-Host-iSCSI {
    param()

    #http://www.vhersey.com/2013/12/enable-software-iscsi-and-add-sendtargets-with-powercli/
    #http://thatcouldbeaproblem.com/?p=202
    #https://www.virten.net/2014/02/howto-use-esxcli-in-powercli/

    #iSCSI einschalten bedeuted wir erstellen einen Software iSCSI Adapter
    Get-VMHostStorage $server.Name | Set-VMHostStorage -SoftwareIScsiEnabled $True
    $s_HBANumber = Get-VMHostHba -VMHost $HostName -Type iSCSI | %{$_.Device}

    $s_HBANumber
    #HBA Konfiguration geht scheinbar nur mit einer EsxCli Instanz
    $esxcli = Get-EsxCli

    $x_vswitch.vmk | Where-Object {$_.iscsi -eq "true"} | ForEach-Object {
        
        
        
        $x_vmk=$_
        $vpg=Get-VirtualPortGroup -Server $server -Name $x_vmk.network
        $vmk=Get-VMHostNetworkAdapter -PortGroup $vpg
        $vmk

        Write-Host "Versuche Adapter" $vmk.Name "an iSCSI zu binden"

        #http://thatcouldbeaproblem.com/?p=202
        #Binds VMKernel ports to the iSCSI Software Adapter HBA
        #So bekomme ich raus welche Parameter der haben will
        $esxcli.iscsi.networkportal.add
        #                        hba          force    vmk
        $esxcli.iscsi.networkportal.add($s_HBANumber,$false, $vmk.Name)
        
    }

}


#GET Funktionen um Informationen über die XML abzurufen

Function VIB-Get-Clusters {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)] [string] $xml
    )
    [xml]$x_vib=Get-Content $xml

    $x_vib.vib.vcenter.datacenter.clusters.cluster.name

}

Export-ModuleMember VIB-*

#Funktionstests, das hier dann rausnehmen

#VIB-Configure-Cluster-Servers "TK_CLU"