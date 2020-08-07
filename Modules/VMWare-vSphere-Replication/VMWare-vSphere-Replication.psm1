

<#
.SYNOPSIS
    Loggt sich in Notwendige ESX-Server ein, bevor Aktionen mit VMs durchgeführt werden
#>
Function Get-ESXSSHLogins {
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
        $a_vms = @()
    }

    Process{
        $VM | ForEach-Object {
            $a_vms+=$_
        }
    }

    End {
    
        $a_groups=$a_vms | Group-Object -Property VMHost

        $a_groups | ForEach-Object {
            $group=$_

            if(-not (Get-SSHSession -ComputerName $group.Name)){
                $cred = Get-Credential -Message ("Root Login für ESX-Server: "+ $group.Name)
                New-SSHSession -ComputerName $group.Name -Credential $cred
            }
            else{
                Get-SSHSession -ComputerName $group.Name
            }
        }
    }

}
Set-Alias -Name VIM-Get-ESXSSHLogins -Value Get-ESXSSHLogins

<#
.SYNOPSIS
    Holt VM Objekte als würde man 
    vim-cmd vmsvc/getallvms
    Ausführen
.DESCRIPTION
    Hiermit bekommst du ein LowLevel VM Objekt. Mit diesem Objekt kannst du auch eine VM killen die nicht mehr reagiert

    Entsprechende CmdLets hierfür müssen noch programmiert werden
#>
Function Get-VimCmdVM {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM=(Get-VM)
    )

    Begin{
        $a_vms = @()
    }

    Process{
        $VM | ForEach-Object {
            $a_vms+=$_
        }
    }

    End {
    
        $a_groups=$a_vms | Group-Object -Property VMHost
        
        $ssh_logins=Get-ESXSSHLogins -VM $a_vms

        $result_vms=@()
        $a_groups | ForEach-Object {
            $group=$_
            $o_ssh=(Get-SSHSession -ComputerName $group.Name)
            $out=Invoke-SSHCommand -SSHSession $o_ssh  -Command "vim-cmd vmsvc/getallvms"

            $matchString='^([0-9]+)\s+(.*?)\s+\[([^\]]+)\]\s+(.*\.vmx)\s+([^\s]+)\s+([^\s]+)\s+(.*)$'

            $matches=$out.Output | Select-String -Pattern $matchString

            
            ForEach($match in $matches){
                $result_vms+=New-Object -TypeName PSObject -Property ([ordered]@{
                    host      = $o_ssh.Host
                    index     = $match.Matches.Groups[1].Value
                    vm        = $match.Matches.Groups[2].Value
                    datastore = $match.Matches.Groups[3].Value
                    file      = $match.Matches.Groups[4].Value
                    guestos   = $match.Matches.Groups[5].Value
                    version   = $match.Matches.Groups[6].Value
                    annotation= $match.Matches.Groups[7].Value
                })

            }


        }

        $a_vms_names=$a_vms.Name

        $result_vms | Where-Object {$a_vms_names -contains $_.vm}

    }

}
Set-Alias -Name VIM-Get-VimCmdVM -Value Get-VimCmdVM



Function Get-ReplicationState {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('VirtualMachine')]
    $VM=(Get-VM)
    )

    Begin {
        $a_vms=@()
    }

    Process {
        $VM | ForEach-Object {
            $a_vms+=$_
        }
    }

    End {
        #Nur VMs holen die wirklich für Replication konfiguriert sind
        $o_vm = $a_vms | ?{$_ | Get-AdvancedSetting -Name "hbr_filter.*"} | Get-VimCmdVM


        $o_vm | ForEach-Object {
            $vm=$_
            $o_ssh=Get-SSHSession -ComputerName $vm.host
            $out=Invoke-SSHCommand -SSHSession $o_ssh  -Command ("vim-cmd hbrsvc/vmreplica.getState " + $vm.index)

            #//XXX Hier weiter

            Write-Host ("Host: "+$vm.host)
            Write-Host ("VM: "+$vm.vm)
            ForEach($line in $out.Output){
                Write-Host $line
            }
        }
    }
}

Set-Alias -Name VIM-Get-ReplicationState -Value Get-ReplicationState