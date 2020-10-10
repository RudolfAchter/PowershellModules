<#
.SYNOPSIS
    Synchronisiert zwei Verzeichnisse mit robocopy /MIR
.DESCRIPTION
    Versucht einen Gesamtstatuns anhand der Anzahl der Files vom letzten Run anzuzeigen
    Wenn es keinen vorherigen Run gibt, gibt es auch keinen Status

#>
Function Sync-Dir(
    [Parameter(Mandatory=$true)]
    $Source,
    [Parameter(Mandatory=$true)]
    $Target
)
{
    If($source_dir=Get-Item $Source -ErrorAction SilentlyContinue){
        If($target_dir=Get-Item $Target -ErrorAction SilentlyContinue){
            
            if(Test-Path ($source_dir.FullName + "\_Sync-Dir_Result.cli.xml")){
                $i_lastrun_synced_files=Import-Clixml -Path ($source_dir.FullName + "\_Sync-Dir_Result.cli.xml")
                $know_count=$true
            }
            else{
                $know_count=$false
            }

            
            
            [int]$i_synced_files=0
            $last_status_time=$(Get-Date) - (New-TimeSpan -Seconds 10)
            robocopy /MIR /W:1 /R:1 $source_dir.FullName $target_dir.FullName | ForEach-Object {
                $line=$_
                $line | Write-Verbose
                $matches=$line | Select-String -Pattern '^\s+([0-9])+\s+(.*)$'

                if($matches.count -gt 0){

                    $o_sync=New-Object -TypeName PSObject -Property ([ordered]@{
                        dir=$matches.Matches.Groups[2].value
                        filecount=$matches.Matches.Groups[1].value
                    })

                    $i_synced_files+=$o_sync.filecount
                    Write-Verbose "i_synced_files: $i_synced_files"
                    Write-Verbose "i_laststatus_synced_files: $i_laststatus_synced_files"

                    

                    #Zwecks Performance nur alle 100 Files ausgeben
                    #if($i_synced_files - $i_laststatus_synced_files -gt 100){
                    #Wenn der letzte Statuns länger als x Sekunden her ist
                    if($last_status_time -lt $(Get-Date) - (New-TimeSpan -Seconds 1)){

                        if($know_count){
                            $percent=100/$i_lastrun_synced_files*$i_synced_files
                            if($percent -gt 100)
                            {
                                $percent=100
                            }
                            Write-Progress -Activity "Synchronizing $source_dir with $target_dir" -Status "Last Filecount $i_lastrun_synced_files  | Checked Files: $i_synced_files" `
                                -PercentComplete $percent -Id 1 
                        }
                        else{
                            Write-Progress -Activity "Synchronizing $source_dir with $target_dir" -Status "Filecount Unknown -> No Progress Bar | Checked Files: $i_synced_files" -Id 1
                        }
                        #$i_laststatus_synced_files=$i_synced_files
                        $last_status_time=Get-Date
                    }

                    
                }
                else{
                    #Fortschritt den Robocopy beim kopieren von Dateien ausgibt
                    $matches=$line|Select-String -Pattern '^\s*([0-9\.]+)%.*$'
                    
                    if($matches.count -gt 0){

                        if($last_status_time -lt $(Get-Date) - (New-TimeSpan -Seconds 1)){

                            [single]$copy_progress=$matches.Matches.Groups[1].value

                            if($copy_progress -gt 99){
                                Write-Progress -Activity "File Progress" -Status "0 %" -PercentComplete 0 -Id 2
                            }
                            else{
                                Write-Progress -Activity "File Progress" -Status "$copy_progress %" -PercentComplete $copy_progress -Id 2
                            }
                            $last_status_time=Get-Date
                        }

                    }
                    else{
                        Write-Host $line
                    }

                }
            }

            $i_synced_files | Export-Clixml -Path ($source_dir.FullName + "\_Sync-Dir_Result.cli.xml")
        }
        Else{
            Write-Error "Target Directory $Target not available. Skipping..."
        }
    }
    Else{
        Write-Error "Source Directory $Source not available. Skipping..."
    }
}

