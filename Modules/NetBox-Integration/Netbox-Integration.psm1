#Requires -Modules powerbox, Virtual-Infrastructure-Management
<#
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
#>
$Global:PowershellConfigDir=($env:USERPROFILE + "\Documents\WindowsPowerShell\Config")
$ModuleSettingsContent=@'
$Global:Netbox = @{
    ApiUrl="https://netbox.zim.uni-passau.de/api"
    #Create Your Own Api Token in Netbox
    ApiToken="YourApiTokenHere"
}
'@

$ModuleName="Netbox-Integration"

If(-not (Test-Path ($Global:PowershellConfigDir + "\" + $ModuleName + ".config.ps1"))){
    Set-Content -Path ($Global:PowershellConfigDir + "\" + $ModuleName + ".config.ps1") -Value $ModuleSettingsContent
}
else{
. ($Global:PowershellConfigDir + "\" + $ModuleName + ".config.ps1")
}

Function Connect-Netbox{
    param(
        $ApiUrl=$Global:Netbox.ApiUrl,
        $ApiToken=$Global:Netbox.ApiToken
    )
    $ApiTokenSecure=ConvertTo-SecureString -String $ApiToken -AsPlainText -Force
    Connect-nbAPI -APIurl $ApiUrl -Token $ApiTokenSecure
}


Function Sync-NetboxTenantToViTags {
    [CmdletBinding()]
    param()

    Get-nbTenant | ForEach-Object {
        $tenant=$_

        $tag=Get-Tag -Name $tenant.name -Category "Tenant" -ErrorAction SilentlyContinue
        if($null -eq $tag){
            New-Tag -Category "Tenant" -Name $tenant.name -Description $tenant.description
        }
        else {
            if($null -ne $tenant.description -and $tenant.description -ne ''){
                $tag | Set-Tag -Description $tenant.description
            }
        }
    }

}


Function Sync-VmToNetbox {

    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline=$True)]
        $VM
    )

    Begin{}

    Process{

        $VM | ForEach-Object {

            $o_vm=Get-VM $_ | VIM-Get-VMValue

            Write-Host("VM: " + $o_vm.Name)

            $nbVM=Get-nbVirtualMachine -query @{name=$o_vm.Name}

            if($nbVM.count -eq 0){
                #Virtuelle Maschine neu Anlegen

                $nbVMCluster=Get-nbCluster -Query @{name=($o_vm | Get-Cluster).Name}

                $nbVMObject= New-Object -Type PSObject -Property @{
                    name=$o_vm.Name
                    #Evtl mit PowerStatus synchronisieren?
                    status="active"
                    site=($o_vm | Get-Datacenter).Name
                    cluster=$nbVMCluster.id
                    role=(Get-nbRole -Query @{name="Server"}).id
                    #Tenant über Tags hinzufügen
                    vcpus=$o_vm.NumCpu
                    memory=$o_vm.MemoryMB
                    disk=[int]$o_vm.ProvisionedSpaceGB
                }

                if($o_vm.Notes -ne $null){
                    $nbVMObject | Add-Member -MemberType NoteProperty -Name "comments" -Value $o_vm.Notes
                }

                $nbVM=New-nbVirtualMachine -Object $nbVMObject

            }
            else{
                #VM Werte aktualisieren
                $nbVMCluster=Get-nbCluster -Query @{name=($o_vm | Get-Cluster).Name}

                $nbVMObject = New-Object -Type PSObject -Property @{
                    name=$o_vm.Name
                    cluster=$nbVMCluster.id
                    role=(Get-nbDeviceRole -Query @{name="Server"}).id
                    #Tenant über Tags hinzufügen
                    vcpus=$o_vm.NumCpu
                    memory=$o_vm.MemoryMB
                    disk=[int]$o_vm.ProvisionedSpaceGB
                }

                if($o_vm.Notes -ne $null){
                    $nbVMObject | Add-Member -MemberType NoteProperty -Name "comments" -Value $o_vm.Notes
                }

                $nbVM=Set-nbVirtualMachine -Id $nbVM.Id -Object $nbVMObject
            }

            

            $o_vm.Guest.Nics | ForEach-Object {
                $nic=$_
                #$nic

                if($nic.Device -ne $null){

                    $nbVmInterface=Get-nbVMInterface -Query @{mac_address=$nic.MacAddress
                                                              virtual_machine=$nbVM.Name}
                    $nicVLAN=(Get-VDPortgroup -Id ("DistributedVirtualPortgroup-" + $nic.Device.NetworkName)).VlanConfiguration
                    $nbVLAN=Get-nbVlan -Query @{vid=$nicVLAN.VlanId}

                    if($null -eq $nbVmInterface.name){
                    #Neues Interface anlegen
                        $vmInterfaceObject = New-Object -Type PSObject -Property @{
                            virtual_machine = $nbVM.id
                            name = $nic.Device.Name
                            mac_address = $nic.MacAddress
                            enabled = $nic.Device.ConnectionState.Connected
                            type = "virtual"
                            untagged_vlan = $nbVLAN.id
                        }
                        $nbVmInterface=New-nbVMInterface -Object $vmInterfaceObject
                    }
                    else{
                        #Bestehendes Interface holen
                        $nbVmInterfaceResult=Get-nbVMInterface -Query @{mac_address=$nic.MacAddress
                                                            virtual_machine=$nbVM.Name}

                        if(($nbVmInterfaceResult | Measure-Object).Count -eq 1){
                            #Und Werte aktualisieren
                            $vmInterface = New-Object -Type PSObject -Property @{
                                virtual_machine = $nbVM.id
                                #Nic Name nicht überschreiben falls dieser verändert wurde
                                #ABER name MUSS in der API gesetzt werden. also einfach das gleiche setzen
                                #name = $nic.Device.Name
                                name = $nbVmInterfaceResult.name
                                enabled = $nic.Device.ConnectionState.Connected
                                untagged_vlan = $nbVLAN.id
                            }
                            $nbVMInterface=Set-nbVMInterface -Id $nbVmInterfaceResult.id -object $vmInterface
                        }
                        else{
                            Write-Error("VM: "+$nbVM.Name+ " : MacAdresse : " + $nic.MacAddress + " nicht eindeutig! Prüfen!")
                            Get-nbVMInterface -Query @{mac_address=$nic.MacAddress}
                        }

                        

                    }
                }
                #//XXX so gehts irgendwie weiter
                #$nic.IPAddress
                $i=0
                ForEach ($ip in $nic.IPAddress){
                    $nbIpPrefix=Get-nbPrefix -Search $ip
                    
                    
                    ForEach($prefix in $nbIpPrefix){
                        #$i
                        if($prefix.prefix -match '[^/]/[0-9]{2}'){
                            $ipResults=Get-nbIpAddress -Query @{address=$ip}
                            $dnsName=(Resolve-DnsName $ip -ErrorAction SilentlyContinue).NameHost
                            if($null -eq $ipResults.id){
                                #IP Neu Anlegen
                                $ipAddressObject = New-Object -Type PSObject -Property @{
                                    #address IP/prefix
                                    address = ($ip + "/" +($nbIpPrefix.prefix -split "/")[1])
                                    interface = $nbVmInterface.id
                                }
                                if($dnsName -ne $null){
                                    $ipAddressObject | Add-Member -MemberType NoteProperty -Name "dns_name" -Value $dnsName
                                }

                                $nbIPAddress=New-nbIpAddress -Object $ipAddressObject
                            }
                            else{
                                if(($ipResults | Measure-Object).Count -ne 1){
                                    Write-Error("IP-Adresse nicht eindeutig VM: " + $o_vm.Name + " : " + $ip)
                                    #$ipResults 
                                }
                                else{
                                    ForEach($ipResult in $ipResults){
                                        #IP an Interface anhängen
                                        $ipAddressObject = New-Object -Type PSObject -Property @{
                                            address = ($ip + "/" +($nbIpPrefix.prefix -split "/")[1])
                                            interface = $nbVmInterface.id
                                        }

                                        if($dnsName -ne $null){
                                            $ipAddressObject | Add-Member -MemberType NoteProperty -Name "dns_name" -Value $dnsName
                                        }

                                        $nbIPAddress=Set-nbIpAddress -Id $ipResult.id -object $ipAddressObject
                                    }
                                }
                            }

                            <#
                            if($i -eq 0){
                                #VM Primary IP aktualisieren
                                $nbVMObject= New-Object -Type PSObject -Property @{
                                    name=$o_vm.Name
                                    cluster=$nbVMCluster.id
                                    primary_ip=$nbIPAddress.id
                                    primary_ip4=$nbIPAddress.id
                                }
                                $nbVM=Set-nbVirtualMachine -Id $nbVM.Id -Object $nbVMObject
                            }
                            #>
                            $i++
                        }
                        
                    }
    
                }

            }
        }
    }

    End{

    }
}