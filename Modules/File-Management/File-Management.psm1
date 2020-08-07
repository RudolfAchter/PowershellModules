<#
Function Compress-Files-GroupByTime-Old {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)
        ]
        $Files=(Get-Item *)
        
        ,
        $TargetDir=".",
        $Suffix="Archive",
        $TimeGroupString="yyyy-MM",
        [switch]$RemoveArchived
    )

    Begin{
        $a_files=@()
    }

    Process{
        If($Files.GetType().BaseType.Name -eq "Array"){
            $a_files=$Files
        }
        else{
            $Files | ForEach-Object{
                $a_files+=$Files
            }
        }
    }

    End{
        $file_count=$a_files.Count
        $files_processed=0

        $process_percent = $files_processed / $file_count * 100

        Write-Progress -Id 2 -Activity "Group Compress-Files-GroupByTime" -Status "Creating File Groups" -PercentComplete 0

        $a_files | Group-Object {($_.LastWriteTime).ToString($TimeGroupString)} | 
            ForEach-Object{
                $o_filegroup = $_
                $s_destfile=($TargetDir+"\"+$o_filegroup.Name+"_"+$Suffix+".zip")

                $files_processed+=$o_filegroup.Count
                $process_percent = $files_processed / $file_count * 100
                Write-Progress -Id 2 -Activity "Group Compress-Files-GroupByTime" -Status "Processsing Files $files_processed of $file_count" -PercentComplete $process_percent

                Try{
                    Compress-Archive -LiteralPath ($o_filegroup.Group.FullName) -CompressionLevel Optimal -DestinationPath $s_destfile -Update -ErrorAction Stop
                }
                Catch{}
                Finally{
                    If($RemoveArchived){
                        $o_filegroup.Group | Remove-Item
                    }
                }

            }

    }
}
#>

<#
.SYNOPSIS
    Gruppiert Dateien nach Zeitangaben nach einem angegebenen Muster.
    diese Gruppen werden in ZIP-Archive zusammengefasst
.DESCRIPTION
    Gruppiert Dateien nach Zeitangaben nach einem angegebenen Muster.
    diese Gruppen werden in ZIP-Archive zusammengefasst
.PARAMETER Files
    zu Archivierende Dateien
.PARAMETER TargetDir
    Verzeichnis in das Archiviert wird
.PARAMETER Suffix
    Dieser Name wird hinter das Datum im Archiv Dateinamen angehängt
.PARAMETER
    TimeGroupString

#>
Function Compress-Files-GroupByTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)
        ]
        $Files=(Get-Item *)
        ,
        $TargetDir=".",
        $Suffix="Archive",
        $TimeGroupString="yyyy-MM",
        [switch]$RemoveArchived
    )

    Begin{
        $temp_path=($env:Temp + "\Compress-Files-GroupByTime")
        If(-not (Test-Path $temp_path)){
            New-Item  -Path $env:Temp  -Name "Compress-Files-GroupByTime" -ItemType Directory 
        }

        Remove-Item -Path ($temp_path + "\*")
        $i=0
    }

    Process{
        
        #Get-Item "C:\Temp\2018-11-15 ebay\logfiles_xml\*" | ForEach-Object {
        $Files | ForEach-Object {
            $file=$_
            $temp_group_file=($temp_path + "\" + ($file.LastWriteTime).ToString($TimeGroupString) + "_" + $Suffix + ".txt")
            Write-Progress -Activity "Collecting File Groups" -Status ("Collecting File Groups in: " + $temp_group_file + " : $i Files Processed")
            $file.FullName | Out-File -FilePath $temp_group_file  -Append
            $i++
        }
    }

    End {
        Get-Item($temp_path + "\*") | ForEach-Object {
            $temp_group_file=Get-Item $_
            $a_filegroup=Get-Content $temp_group_file
            Try{
                $archive_target_file=((Get-Item $TargetDir).FullName) + "\" + $temp_group_file.BaseName + ".zip"
                Compress-Archive -Path $a_filegroup -DestinationPath ($archive_target_file) -Update -ErrorAction Stop 
                if($RemoveArchived){
                    if(Test-Path $archive_target_file){
                        Write-Progress -Activity "Removing Archived Items" -Status "Removing ..."
                        Remove-Item -Path $a_filegroup
                    }
                }

            }
            Catch{}
        }

        #Temp Files wieder entfernen
        Remove-Item -Path ($temp_path + "\*")
    }

}



<#
Get-Item xml\* | ForEach-Object {
    New-Item -Path xml_archive -Name $_.Name -ItemType Directory
}
#>

<#
.SYNOPSIS
    Komprimiert Dateien in Unterordnern
.DESCRIPTION
    Nehmen wir an du hast eine solche Struktur

 |--SourceFolder
 |  |
 |  |--SubFolder1
 |  |--|
 |  |  |--Datei1
 |  |  |--Datei2
 |  |--SubFolder2
 |  |--|
 |     |--Datei3
 |     |--Datei4
 |
 |--TargetFolder

    Du willst alle Dateien aus "SourceFolder" in "TargetFolder" Archivieren. 
    Du benötigst ale SubFolder aus "SourceFolder"
    Das Script legt alle SubFolder aus SourceFolder im TargetFolder an
    Die Dateien aus der Quelle werden gruppiert nach TimeGroupString im Target Folder abgelegt

.PARAMETER SourceFolder
    Hieraus werden die Dateien archiviert
.PARAMETER TargetFolder
    Hierhin werden die Dateien archiviert
.PARAMETER TimeGroupString
    Nach diesem DateTime String Muster werden die Archiv Gruppen generiert
    siehe: https://blogs.technet.microsoft.com/heyscriptingguy/2015/01/22/formatting-date-strings-with-powershell/
.PARAMETER AgeType
    Wie wird gefiltert
        OlderThan       Älter als Jetzt + Timespan
        OlderEqual      Älter oder gleich alt wie Jetzt + Timespan
        NewerThan       Neuer als Jetzt + Timespan
        NewerEqual      Neuer oder gleich wie Jetzt + Timespan
        BeforeDate      Älter als Angegebener DateTime
        BeforEqualDate  Älter oder gleich Alt wie angegebener DateTime
        AfterDate       Neuer als angegebener DateTime
        AfterEqualDate  Neuer oder gleich wie angegebener DateTime
.PARAMETER AgeValue
    Ein TimeSpan oder DateTime der einen gesuchten Zeitpunkt beschreibt
    steht in Kombination mit "AgeType". ACHTUNG.
    Bei Timespans müssen Zeitpunkte in der Verganenheit als Negative
    Timespans angegeben werden z.B.:
    Das ist vor 7 Tagen (in der Vergangenheit)
    -AgeValue (New-Timespan -Days -7)
    
    Das ist in 7 Tagen (in der Zukunft)
    -AgeValue (New-Timespan -Days 7)

.PARAMETER AgeProperty
    Anhand welcher Property soll das Alter der Datei bestimmt werden
    z.B.
    -AgeProperty CreationTime
#>

Function Compress-SubFolders-GroupByTime{
    param(
        $SourceFolder,
        $TargetFolder,
        $TimeGroupString="yyyy-MM",
        [switch]$RemoveArchived,
       
        [ValidateSet("OlderThan","OlderEqual","NewerThan","NewerEqual","BeforeDate","BeforeEqualDate","AfterDate","AfterEqualDate")]
        [string]$AgeType="OlderThan",

        [ValidateScript({
        $AgeValue=$_
        Switch($AgeType){
            {$_ -in @("OlderThan","OlderEqual","NewerThan","NewerEqual")} {
                #Write-Host($AgeValue.GetType().Name)
                $AgeValue.GetType().Name -eq "TimeSpan"
                break
            }
            {$_ -in @("BeforeDate","BeforeEqualDate","AfterDate","AfterEqualDate")} {
                #Write-Host($AgeValue.GetType().Name)
                $AgeValue.GetType().Name -eq "DateTime"
                break
            }

        }
        })]
        $AgeValue=0,

        [ValidateSet("LastWriteTime","CreationTime","LastAccessTime")]
        $AgeProperty="LastWriteTime"

    )
    
    $source_folders=Get-ChildItem -Path $SourceFolder -Directory

    $folders_processed=0
    

    $source_folders | ForEach-Object {

        $source_folder=$_

        $folders_processed++
        $process_percent = $folders_processed / $source_folders.Count * 100

        Write-Progress -Id 1 -Activity "Processing Folders" -Status ("Folder $folders_processed of " + $source_folders.Count) -PercentComplete $process_percent

        
        $cur_target_folder=$TargetFolder + "\" + $source_folder.Name
        If( -not (Test-Path $cur_target_folder)){
            New-Item -Path $TargetFolder -Name $source_folder.Name -ItemType Directory
        }

        if($AgeValue -eq 0){
            $source_files=(Get-Item ($source_folder.FullName+"\*"))
        }
        else{
            $source_files=(Get-Item ($source_folder.FullName+"\*") | Where-FileAge -AgeType $AgeType -AgeValue $AgeValue -AgeProperty $AgeProperty)
        }

        
        if($source_files.Count -gt 0){
            Compress-Files-GroupByTime -Files $source_files -TargetDir $cur_target_folder -Suffix $source_folder.Name -TimeGroupString $TimeGroupString -RemoveArchived:$RemoveArchived
        }
        else{
            Write-Verbose ("In " + $source_folder.FullName + " Sind keine Dateien zum archivieren")
        }

    }

}

<#
.SYNOPSIS
    Filtert Dateien nach ihrem Alter
.DESCRIPTION
    Eine Vereinfachte Möglichkeit Dateien nach ihrem Alter zu Filtern.
    Prinzipiell macht es dasselbe wie Where-Object.Nur hier sind diverse
    Parameter mit sinnvollen Vorbelegungen versehen und die Filter Anweisung
    kann etwas kürzer geschrieben werden
.PARAMETER Files
    Dateien aus der Pipe
.PARAMETER AgeType
    Wie wird gefiltert
        OlderThan       Älter als Jetzt + Timespan
        OlderEqual      Älter oder gleich alt wie Jetzt + Timespan
        NewerThan       Neuer als Jetzt + Timespan
        NewerEqual      Neuer oder gleich wie Jetzt + Timespan
        BeforeDate      Älter als Angegebener DateTime
        BeforEqualDate  Älter oder gleich Alt wie angegebener DateTime
        AfterDate       Neuer als angegebener DateTime
        AfterEqualDate  Neuer oder gleich wie angegebener DateTime
.PARAMETER AgeValue
    Ein TimeSpan oder DateTime der einen gesuchten Zeitpunkt beschreibt
    steht in Kombination mit "AgeType". ACHTUNG.
    Bei Timespans müssen Zeitpunkte in der Verganenheit als Negative
    Timespans angegeben werden z.B.:
    Das ist vor 7 Tagen (in der Vergangenheit)
    -AgeValue (New-Timespan -Days -7)
    
    Das ist in 7 Tagen (in der Zukunft)
    -AgeValue (New-Timespan -Days 7)

.PARAMETER AgeProperty
    Anhand welcher Property soll das Alter der Datei bestimmt werden
    z.B.
    -AgeProperty CreationTime

.EXAMPLE
    Get-Item * | Where-FileAge -AgeType NewerEqual -AgeValue (New-TimeSpan -Days -7)
.EXAMPLE
    #Mit Where-FileAge habe ich anscheinend ein Performance Problem.
    #Files die über die Pipe übergeben werden, werden anscheinend im Arbeitsspeicher gepuffert
    #Das führt bei einer riesigen Anzahl an Dateien zu Problemen
    #z.B. Problematischer Befehl
    Get-Item \\deslnsrvmention\MENTION\mention_produktiv\logfiles-xml\* | Where-FileAge -AgeType OlderEqual -AgeValue (New-Timespan -Days -180)
    #Das hier könnte Performater sein
    Get-Item \\deslnsrvmention\MENTION\mention_produktiv\logfiles-xml\* | Where-Object {$_.LastWriteTime -le ((Get-Date)+(New-Timespan -Days -180))}

.LINK
    https://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/File-Management.psm1/Where-FileAge
#>
Function Where-FileAge{

    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)
        ]
        $Files=(Get-Item *),

        [ValidateSet("OlderThan","OlderEqual","NewerThan","NewerEqual","BeforeDate","BeforeEqualDate","AfterDate","AfterEqualDate")]
        [string]$AgeType="OlderThan",

        [ValidateScript({
        $AgeValue=$_
        Switch($AgeType){
            {$_ -in @("OlderThan","OlderEqual","NewerThan","NewerEqual")} {
                #Write-Host($AgeValue.GetType().Name)
                $AgeValue.GetType().Name -eq "TimeSpan"
                break
            }
            {$_ -in @("BeforeDate","BeforeEqualDate","AfterDate","AfterEqualDate")} {
                #Write-Host($AgeValue.GetType().Name)
                $AgeValue.GetType().Name -eq "DateTime"
                break
            }

        }
        })]
        $AgeValue=(New-Timespan),

        [ValidateSet("LastWriteTime","CreationTime","LastAccessTime")]
        [string]$AgeProperty="LastWriteTime"
    )


    Begin{}

    Process{
        $Files | ForEach-Object {
            $file=$_
                
            Switch($AgeType){
                "OlderThan"{
                    if($file.$AgeProperty -lt ((Get-Date)+$AgeValue)) {
                        $file
                    }
                    break
                }
                "OlderEqual"{
                    if($file.$AgeProperty -le ((Get-Date)+$AgeValue)) {
                        $file
                    }
                    break
                }
                "NewerThan"{
                    if($file.$AgeProperty -gt ((Get-Date)+$AgeValue)) {
                        $file
                    }
                    break
                }
                "NewerEqual"{
                    if($file.$AgeProperty -ge ((Get-Date)+$AgeValue)) {
                        $file
                    }
                    break
                }
                "BeforeDate"{
                    if($file.$AgeProperty -lt $AgeValue) {
                        $file
                    }
                    break
                }
                "BeforeEqualDate"{
                    if($file.$AgeProperty -le $AgeValue) {
                        $file
                    }
                    break
                }
                "AfterDate"{
                    if($file.$AgeProperty -gt $AgeValue) {
                        $file
                    }
                    break
                }
                "AfterEqualDate"{
                    if($file.$AgeProperty -ge $AgeValue) {
                        $file
                    }
                    break
                }


            }
                
            

        }
    
    }

    End{}

}