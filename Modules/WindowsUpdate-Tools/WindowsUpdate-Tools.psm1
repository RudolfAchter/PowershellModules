

<#
$Nodes=(Get-ExchangeServer).Name
Invoke-WUJob -ComputerName $Nodes -Script {ipmo PSWindowsUpdate} -RunNow
#>

Function Install-PSWindowsUpdate {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$Nodes,
        $Credential=(Get-Credential)
    )

    Begin{
        $a_nodes=@()
    }

    Process{
        $Nodes | ForEach-Object {
            $a_nodes+=$_
        }
    }

    End{
        Invoke-WUJob -ComputerName $a_nodes -Script {ipmo PSWindowsUpdate} -RunNow -Credential $Credential
    }

}