#Fuer Ubuntu 18.04

$global:netplan_environment=@{
    initial_netplan_content=@"
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
"@
}

Function Set-Netplan {
<#
.SYNOPSIS
    Creates a Netpan for Ubuntu Server
.DESCRIPTION
    Creates Netplan. Default Netplan Location is:
    /etc/netplan/50-cloud-init.yaml
    Optional you can apply this configuration immediately
.PARAMETER IPv4Address
    IPv4 Address in Dotted IPv4 Notation
.PARAMETER CIDR
    Netmask in CIDR Notation (24 for example)
.PARAMETER Gateway
    Default Gateway in IPv4 Notation
.PARAMETER DNSServers
    Array of DNS Servers
.PARAMETER DNSSearch
    Array of DNS Search Domains
.PARAMETER NetplanFile
    Where to save NetplanFile (Default: '/etc/netplan/50-cloud-init.yaml')
.PARAMETER OnlyShow
    Just Shows generated Config
.PARAMETER Apply
    Applies Network Configuration to this System
#>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        $IPv4Address,
        $CIDR,
        $Gateway,
        $DNSServers=@(),
        $DNSSearch=@(),
        $NetplanFile='/etc/netplan/50-cloud-init.yaml',
        [switch]$OnlyShow,
        [switch]$Apply
    )
    
    #$out=$global:netplan_environment.initial_netplan_content + "`n"
    $out=''
    
    $out+='network:' + "`n"
    $out+="    "+'ethernets:' + "`n"
    $out+="        "+'ens160:' + "`n"
    $out+="            "+'addresses:' + "`n"
    $out+="            "+'- '+$IPv4Address+'/'+$CIDR + "`n"

    $out+="            "+'gateway4: '+ $Gateway + "`n"
    $out+="            "+'nameservers:'+ "`n"
    $out+="                "+'addresses:'+ "`n"
    ForEach($DNSServer in $DNSServers){
        $out+="                "+'- '+ $DNSServer + "`n"
    }
    $out+="                "+'search: '+ "["+ ($DNSSearch -join ",") +"]" + "`n"

    $out+="            "+'optional: true'  + "`n"
    $out+="    "+'version: 2'

    if($OnlyShow){
        Write-Host($out)
    }
    else{

        $out | Set-Content -Path $NetplanFile
    
        if($Apply){
            Start-Netplan
        }
    }
}

Function Start-Netplan{
<#
.SYNOPSIS
    Applies previously Saved Netplan from Default Path
    (Default: '/etc/netplan/50-cloud-init.yaml')
#>
    netplan apply
}


Function Get-ModuleLoadTest{
<#
.SYNOPSIS
    Just for testing purposes
#>
    Write-Host("Module Load Test")
}

Function Invoke-Ovaboot{
<#
.SYNOPSIS
    Does all Operations needed for a FirstBoot on a cloned System
    It is used for configuring this system after OVA Deployment
    This works like "sysprep"
.DESCRIPTION
    Bisher macht dieses Script folgendes
    - Konfiguriert das Netzwerk
    - Setzt den Hostnamen
    - Konfiguriert DNS Auflösung
    - Generiert neue SSH IDs
    - Generiert neue SSL Zertifikate (aktuell nur Webmin)
.PARAMETER Hostname
    Hostname of this System
.PARAMETER IPv4addr01
    IPv4 Address in Dotted IPv4 Notation
.PARAMETER IPv4cidr01
    Netmask in CIDR Notation (24 for example)
.PARAMETER IPv4gw01
    Default Gateway in IPv4 Notation
.PARAMETER IPv4dnsservers
    Array of DNS Servers
.PARAMETER IPv4dnssearch
    Array of DNS Search Domains
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Hostname,
        [Parameter(Mandatory=$true)]
        $IPv4addr01,
        [Parameter(Mandatory=$true)]
        $IPv4cidr01,
        [Parameter(Mandatory=$true)]
        $IPv4gw01,
        [Parameter(Mandatory=$true)]
        $IPv4dnssearch,
        [Parameter(Mandatory=$true)]
        $IPv4dnsservers
    )

    Write-Progress -Activity "Executing Ovaboot" -Status "Starting..." -PercentComplete 1
    

    Write-Progress -Activity "Executing Ovaboot" -Status "Setting Network Interface..." -PercentComplete 5
    #IP Netzwerkeinstellungen
    Set-Netplan -IPv4Address $IPv4addr01 -CIDR $IPv4cidr01 -Gateway $IPv4gw01 -DNSServers $IPv4dnsservers -DNSSearch $IPv4dnssearch -OnlyShow
    Set-Netplan -IPv4Address $IPv4addr01 -CIDR $IPv4cidr01 -Gateway $IPv4gw01 -DNSServers $IPv4dnsservers -DNSSearch $IPv4dnssearch -Apply

    #Hostname
    Write-Progress -Activity "Executing Ovaboot" -Status "Setting Hostname..." -PercentComplete 10
    Write-Host('Setting Hostname...')
	hostnamectl set-hostname $Hostname

	#systemd-resolved (Ubuntu DNS Cache) neu konfigurieren
    $systemd_resolved_conf="/etc/systemd/resolved.conf"
    
    Write-Progress -Activity "Executing Ovaboot" -Status "Configuring resolved..." -PercentComplete 15
	Write-Host('Configuring systemd-resolved (DNS Cache Service)....')
	Write-Host("Setting in ${systemd_resolved_conf}:")
	
	$out=Get-Content "/etc/systemd/resolved.conf.orig"
	$space_separated_dns_servers=$IPv4dnsservers -join " "
	
	$out+=@"
DNS=${space_separated_dns_servers}
#FallbackDNS=
Domains=*
LLMNR=no
MulticastDNS=no
DNSSEC=no
Cache=yes
#DNSStubListener=yes
"@
	Write-Host("###############################################################")
	Write-Host($out -join "`n")
	Write-Host("###############################################################")

	$out | Set-Content -Path $systemd_resolved_conf
	Write-Host("Restarting systemd-resolved service...")
	systemctl restart systemd-resolved

    Write-Progress -Activity "Executing Ovaboot" -Status "Reconfiguring sshd..." -PercentComplete 20

	#SSH Regenerate
	Write-Host('Generating New SSH Host Keys')
	rm /etc/ssh/ssh_host_*
	dpkg-reconfigure openssh-server
	systemctl restart ssh
    
    Write-Progress -Activity "Executing Ovaboot" -Status "Reconfiguring Webmin..." -PercentComplete 25

	#Webmin Reconfigure
	Write-Host('Reconfiguring Webmin')
    dpkg-reconfigure webmin
    Write-Progress -Activity "Executing Ovaboot" -Status "Reconfiguring Webmin..." -PercentComplete 50
	Write-Host('Generating New Webmin SSL Certificates')
	/usr/local/bin/ssl_regenerate_webmin.sh

	
    #Default 46xxsettings.txt
    $file_46xxsettings='/var/www/html/46xxsettings.txt'

    if(Test-Path -Path $file_46xxsettings){
        Write-Progress -Activity "Executing Ovaboot" -Status "Generating 46xxsettings..." -PercentComplete 90
        Write-Host('Found 46xxsettings File. This is a Utility Server')
        Write-Host('Generating Default 46xxsettings.txt')
        $myipv4addr=$IPv4addr01
        
        $config_46xxsettings_content=@"
## Generated by ovaboot.ps1
## MEGATECH rudolf.achter@megatech-communication.de
## MEGATECH Branko.Tocevic@megatech-communication.de
SET SCREENSAVERON 1
SET SCREENSAVER OpenSourceUtility.jpg
SET BRURI http://$myipv4addr/PhoneBackup
"@
        $config_46xxsettings_content | Set-Content -Path $file_46xxsettings -Encoding Ascii
    }

    Write-Progress -Activity "Executing Ovaboot" -Status "Getting Ready..." -PercentComplete 99

    if(Test-Path '/etc/firstboot'){
        Remove-Item -Path '/etc/firstboot'
    }

}
