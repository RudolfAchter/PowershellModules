
Function Convert-PlaylistToCuesheet {
<#
.SYNOPSIS
    Konvertiert eine Playlist in ein Cuesheet (.txt Datei in .cue Datei)
    Es müssen natürlich keine .txt Dateien sein, aber damit man sich was
    darunter vorstellen kann
.DESCRIPTION
    
    Mögliche Nützliche Regex

    Playlist
    --------------------------------------------------------------------
    0:00 Artist - Title
    13:12 Artist - Title
    
    Regex
    --------------------------------------------------------------------
    ^([0-9]{1,2}\:[0-9]{1,2})\s+(.*)? - (.*)?$
    --------------------------------------------------------------------
    -ArtistMatch 2 -TitleMatch 3 -TimeMatch 1
    --------------------------------------------------------------------

    Playlist
    --------------------------------------------------------------------
    ZKAVE - At The Edge 
    Poolz - Resistless Inflections [ 6:44 ]
    Toteem1 - All the Lost Souls [ 10:52 ]
    
    Regex
    --------------------------------------------------------------------
    ^(.*)? - ([^\[\n]+)( \[ ([0-9]+:[0-9]+|[0-9]+:[0-9]+:[0-9]+) \]|)$
    --------------------------------------------------------------------
    -ArtistMatch 1 -TitleMatch 2 -TimeMatch 4



.PARAMETER Playlist
    Pfad zu der zu konvertierenden Playlist
.PARAMETER Cuesheet
    Pfad zum erstellenden Cuesheet (Neue Datei)
.PARAMETER Regex
    Regular Expression die zum konvertieren verwendet wird
.PARAMETER ArtistMatch
    Match n in der Regular Expression der den Artist beschreibt
.PARAMETER TitleMatch
    Match n in der Regular Expression der den Title beschreibt
.PARAMETER TimeMatch
    Match n in der Regular Expression der den Timestamp beschreibt
.EXAMPLE
    Convert-PlaylistToCuesheet -Playlist "N:\MP3\Arctic Empire - Chillstep\Arctic Empire - Interstellar  Epic Chillstep & Melodic Dubstep Mix.txt" `
    -AudioFile "N:\MP3\Arctic Empire - Chillstep\Arctic Empire - Interstellar  Epic Chillstep & Melodic Dubstep Mix.mp3" `
    -Regex '^([0-9]{1,2}\:[0-9]{1,2})\s+(.*)? - (.*)?$' `
    -TimeMatch 1 -ArtistMatch 2 -TitleMatch 3
.EXAMPLE
#>
    param(
        [string]$Playlist,
        [string]$AudioFile='',
        [string]$Cuesheet='',
        [string]$Regex="^(.*)? - ([^\[\n]+)( \[ ([0-9]+:[0-9]+|[0-9]+:[0-9]+:[0-9]+) \]|)$",
        [int]$ArtistMatch=1,
        [int]$TitleMatch=2,
        [int]$TimeMatch=4,
        [ValidateSet('Second','Minute','Hour','Frame')][string]$SmallestTimeUnit='Second',
        $AlbumArtist='',
        $AlbumTitle=''
    )


    #File abholen
    Try {
        $o_playlist=Get-Item -Path $Playlist -ErrorAction Stop
    }
    Catch {
        Write-Error "Playlist File not found"
        return
    }

    if ($Cuesheet -eq '')
    {
        $Cuesheet=[string]$o_playlist.Directory + "\" + [string]$o_playlist.BaseName + ".cue"
    }

    if ($AudioFile -eq '') {
        #Bei dem AudioFile will ich testen ob es da ist
        $AudioFile_Path=[string]$o_playlist.Directory + "\" + [string]$o_playlist.BaseName + ".mp3"
    }
    else {
        $AudioFile_Path=$AudioFile
    }

    #Testen ob AudioFile existiert
    if(Test-Path $AudioFile_Path){
        $AudioFile=(Get-Item($AudioFile_Path)).Name
    }
    else{
        Write-Error "AudioFile: `"$AudioFile_Path`" : existiert nicht"
        $AudioFile=[string]$o_playlist.BaseName + ".mp3"
    }


    $txt=Get-Content $o_playlist


    #Hier wird die Ausgabe zusammengeführt
    $out=''
    $out+=

    if($AlbumTitle -eq ''){
        $AlbumTitle = $o_playlist.BaseName
    }
    if($AlbumArtist -eq ''){
        $AlbumArtist = 'Various Artists'
    }

    #AUSGABE

    $out += 'PERFORMER ' + '"' + $AlbumArtist + '"' + "`r`n"
    $out += 'TITLE ' + '"' + $AlbumTitle + '"' + "`r`n"
    
    #Evtl noch anpassen wegen relativer und Absoluter Pfade
    $out += 'FILE ' + '"' + $AudioFile + '"' + " WAVE" + "`r`n"

    $i=1
    ForEach($line in $txt){
        #Jede Zeile einzeln bearbeiten
        $match=$line | Select-String -Pattern $Regex
        $str_artist=$match.Matches.Groups[$ArtistMatch].Value
        $str_title=$match.Matches.Groups[$TitleMatch].Value
        $str_time=$match.Matches.Groups[$TimeMatch].Value

        Write-Verbose ('$str_time: '+$str_time)

        if($str_time -eq "")
        {
            $o_time=New-TimeSpan -Seconds 0
        }
        #Wenn die Zeit statt nur Minuten, in die Stunden geht
        elseif(
            $SmallestTimeUnit -eq 'Second' -and
            $str_time -match '[0-9]+:[0-9]+:[0-9]+'
        )
        {
            #Dann müssen wir was mit den Stunden und Minuten machen
            $time_match=$str_time | Select-String -Pattern '([0-9]+):([0-9]+):([0-9]+)'
            $o_time=New-TimeSpan -Hours   $time_match.Matches.Groups[1].Value `
                                 -Minutes $time_match.Matches.Groups[2].Value `
                                 -Seconds $time_match.Matches.Groups[3].Value

        }
        elseif(
            $SmallestTimeUnit -eq 'Second' -and
            $str_time -match '[0-9]+:[0-9]+'
        )
        {
            $time_match=$str_time | Select-String -Pattern '([0-9]+):([0-9]+)'
            $o_time=New-TimeSpan -Minutes $time_match.Matches.Groups[1].Value `
                                 -Seconds $time_match.Matches.Groups[2].Value
        }
        else {
            Write-Error "Unerwartetes Zeitformat, stimmt was mit SmallestTimeUnit nicht?"
        }

        #Wir machen was aus $o_time

        #Minuten mit führender NULL (das ist etwas komplizierter
        #             zwei Stellen
        #                     Format Schalter
        #                        #Integer Conversion
        #                               #Abrundung
        #                                             #Minuten im Zeitobjekt
        [string]$str_minutes="{0:D2}" -f [int]$([math]::floor($o_time.TotalMinutes))

        [string]$str_seconds="{0:D2}" -f [int]$([math]::floor($o_time.Seconds))
        [string]$str_frames="00"

        
        [string]$str_timestamp=$str_minutes+":"+$str_seconds+":"+$str_frames

        #Ausgabe
        $out += "`t"+"TRACK "+ ("{0:D2}" -f $i) + " AUDIO" + "`r`n"
        $out += "`t`t"+'TITLE "'+ $str_title + '"' + "`r`n"
        $out += "`t`t"+'PERFORMER "'+ $str_artist + '"' + "`r`n"
        $out += "`t`t"+'INDEX 01 '+ $str_timestamp + '' + "`r`n"
        #Ausgabe ENDE
        
        $i++
    }

    #//XXX hier weiter. Ausgabe mit File usw
    $out | Out-File -FilePath $Cuesheet -Encoding utf8


}


Function Recode-Media {
 <#
.SYNOPSIS

Kodiert ein Video in einem anderen Format mit Hilfe von ffmpeg
.DESCRIPTION

Kodiert ein Video in einem anderen Format mit Hilfe von ffmpeg.
Im Grunde ist es ein Wrapper-Script für ffmpeg.
Es erleichtert die Bedienung von ffmpeg um gebräuchliche Vorgänge
hier zu automatisieren.

.PARAMETER File

Video Dateien
.PARAMETER To
Zieldatei (kann auch mit Pfad angegeben werden)

.PARAMETER Codec

Verwendeter Codec
    - h264        h264 Codec im mp4 Container, Audio AAC (Standard)
    - h264-mp4    h264 Codec im mp4 Container, Audio AAC (Standard)
    - h264-mkv    h264 Codec im mkv Container, Audio AAC

.PARAMETER Quality

Qualität in der Recodiert wird
je schlechter die Qualität desto weniger Speicherplatz wird benötigt
- 1      beste Qualität
- 10     sehr gute Qualität (Standard)
- 20     gute Qualität
- 30     mittlere Qualität
- 40     schlechte Qualität

.PARAMETER yuv420p

Viele MediaPlayer und Videoschnittprogramme können nur mit
Pixelformat yuv420 umgehen. FFMpeg verwendet Stadardmäßig
das modernere Format yuv440.
In meinen Scripten ist zwecks Kompatibilität yuv420
standarmäßig aktiv

siehe: https://de.wikipedia.org/wiki/YUV-Farbmodell

.PARAMETER Normalize

Anaylsiert zunächst die Lautstärke und normalisiert dann
    
.EXAMPLE

Get-Item *.trp | Recode-Media

.EXAMPLE
#Hole mir alle Verzeichnisse in denen eine .mkv Datei steckt aber keine .mp4 Datei
#Hole mir die .mkv Dateien daraus
#Encodiere diese mit Audio Normalisierung
Get-ChildItem -Directory | 
?{(Get-Childitem -Path $_.FullName *.mkv) -and -not (Get-Childitem -Path $_.FullName *.mp4)} | 
%{Get-ChildItem -Path $_.FullName *.mkv} | 
Recode-Media -Normalize
#>
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    $File,
    [ValidateSet("h264-mp4","mp3-vbr","mp3")][string]$Codec="h264-mp4",
    [int]$Quality=20,
    [bool]$yuv420p=$true,
    [switch]$Normalize,
    [switch]$Chapter
    )
    
    Begin{}
    
    Process{
        $File | ForEach-Object {
            Write-Host $_.FullName
            #Qualität
            [string]$s_quality = [string]$Quality
            
            #Argumente als String
            $s_args=""

            #Metadata File
            if($Chapter) {
                $meta_file=Write-FFMPeg-Chapter -File $_ -GetMetaFile
                $s_args+= ' -i "' + $meta_file.FullName + '"'
            }

            #Input File
            $s_args+= ' -i "' + $_.FullName + '"'
            #Angaben für den Video Codec

            if($Chapter) {
                $s_args+= ' -map_metadata 1'
            }

            Switch($Codec){
            
                {@("h264","h264-mp4") -contains $_} {
                    $s_args+= ' -vcodec libx264 -acodec aac -qp ' + $s_quality
                    $s_extension = "mp4"
                }
                "h264-mkv" {
                    $s_args+= ' -vcodec libx264 -acodec aac -qp ' + $s_quality
                    $s_extension = "mkv"
                }
                #mp3, mp3-vbr
                {@("mp3","mp3-vbr") -contains $_}{
                    $s_args+= ' -codec:a libmp3lame -q:a 4'
                    $s_extension = "mp3"
                }

                

            }
            if($yuv420p){
                $s_args+= ' -pix_fmt yuv420p'
            }

            if($Normalize) {
                #Normalisieren
                Write-Host "Lautstärke für Normalisierung wird analysiert..."
                $val=Get-Media-Normalize-Value $_
                $s_args += ' -af "volume=' + [string][Math]::Round($val,2) + 'dB"'
            }

            #Output File
            $outfile_path=$_.Directory.FullName + "\" + $_.BaseName + "." + $s_extension
            $s_args+= ' "' + $outfile_path
            
            $s_args+= '"'
            Write-Host "ffmpeg" $s_args

            $process=Start-Process "ffmpeg.exe" -ArgumentList $s_args -NoNewWindow -PassThru
            $process.PriorityClass="Belownormal"
            $process.WaitForExit()
            Write-Host "Exitcode: " $process.ExitCode

            Get-Item $outfile_path
        }
    
    }
    
    End {}    
}

<#
.SYNOPSIS
    Sucht den Normalisierungswert für Audio in einem MedienFile

.DESCRIPTION
    Analysiert 20 Minuten von einem Medium. Standardmäßig programmiert für Filme
    Es werden die ersten 5 Minuten übersprungen und dann 20 Minuten analysiert

    //XXX TODO braucht optimierung für typische Musik (Albumtitel)
    Wenn also die Musik kürzer als 25 Minuten ist brauche ich eine ganz
    andere vorgehensweise muss sich noch an die länge des Mediums anpassen
#>
Function Get-Media-Normalize-Value {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    $File
    )
    Write-Host "Suche Wert für Normalisierung:" $File.FullName "..."
    #Zur Lautstärkeanalyse werden 1200 Sekunden (20 Minuten) analysiert
    $command="ffmpeg"
    $a_args = @('-ss','00:05:00','-t','1200','-i',$File.FullName, '-af', 'volumedetect','-f','null','NUL')
    
    #$result=& $command $a_args 2>&1 | Where-Object {$_ -match "max_volume"}
    
    Try {
        Write-Host "Versuche Seek..."
        $result=& $command $a_args 2>&1 | Where-Object {$_ -match "max_volume"}
        $match=$result | Select-String -Pattern "max_volume:\s+(-*[0-9\.]+) dB"
        $([float]$match.Matches.Groups[1].Value * -1)
    }
    Catch {
        Write-Host "Lese von vorn..."
        $a_args = @('-t','1200','-i',$File.FullName, '-af', 'volumedetect','-f','null','NUL')
        $result=& $command $a_args 2>&1 | Where-Object {$_ -match "max_volume"}
        $match=$result | Select-String -Pattern "max_volume:\s+(-*[0-9\.]+) dB"
        $([float]$match.Matches.Groups[1].Value * -1)
    }
    

    #$match=$result | Select-String -Pattern "max_volume:\s+(-*[0-9\.]+) dB"

    #Max Volume als Gleitkommazahl in -db
    #[Math]::Round($val,2)
    #[string][Math]::Round($val,2)
    #$([float]$match.Matches.Groups[1].Value * -1)
}


function Using-Culture ([System.Globalization.CultureInfo]$culture =(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
                        [ScriptBlock]$script=(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
{    
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    $OldUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
    try {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture        
        Invoke-Command $script    
    }    
    finally {        
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture        
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $OldUICulture    
    }    
}


Function Execute-Command ($commandTitle, $commandPath, $commandArguments)
{
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $commandPath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $commandArguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    [pscustomobject]@{
        commandTitle = $commandTitle
        stdout = $p.StandardOutput.ReadToEnd()
        stderr = $p.StandardError.ReadToEnd()
        ExitCode = $p.ExitCode  
    }
}


<#
.SYNOPSIS

Durchsucht ein Verzeichnis nach .mpg und .mp4 Dateien und gibt es nur aus
wenn eine .mpg Datei vorhanden UND keine .mp4 Datei vorhanden ist
.DESCRIPTION

Durchsucht ein Verzeichnis nach .mpg und .mp4 Dateien und gibt es nur aus
wenn eine .mpg Datei vorhanden UND keine .mp4 Datei vorhanden ist

.PARAMETER File

Verzeichnisse
    
.EXAMPLE

Get-ChildItem -Directory | Get-Folder-without-mp4-and-with-mpg
.EXAMPLE

Get-ChildItem -Directory | Get-Folder-without-mp4-and-with-mpg | %{Get-ChildItem -Path $_.FullName -Filter *.mpg} | Recode-Media
#>
function Get-Folder-without-mp4-and-with-mpg {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    $File=$(Get-ChildItem -Directory)
    )

    Begin {}

    Process {
        $File | ForEach-Object {
            #Wenn ich einem Verzeichnis eine .mpg Datei gefunden wird
            #aber keine mp4 Datei dann gib das Verzeichnis zurück
            if($(Get-ChildItem -Path $_.FullName -Filter "*.mpg") -and
               -not $(Get-ChildItem -Path $_.FullName -Filter "*.mp4")
               ){
                    $_
                }
        }
    
    }

    End {}

}

<#
.EXAMPLE
    #Finde Objekte die KEIN "Kapitel 10" haben und generiere dort Kapitel
    Get-ChildItem *.mp4 -Recurse | Where-Object {-not $($_ | Get-FFMpeg-MediaInfo -ErrorAction SilentlyContinue).metadata.chapter10} | Write-FFMPeg-Chapter
.EXAMPLE
    #Filme die nicht imr 16:9 Format sind
    $not_16_9 = Get-ChildItem -Recurse *.mp4 | %{$_ | Get-FFMpeg-MediaInfo} | ?{$_.mediainfo.Mediainfo.File.track.Display_aspect_ratio[2] -ne "16:9"}
    $not_16_9
#>
function Get-FFMpeg-MediaInfo {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true)
    ]
    [Alias('FileItem')]
    #[ValidateScript({($_.GetType().Name -eq "FileInfo")})]
    $File,
    [switch]$DoFFmpeg=$true,
    [switch]$DoMediaInfo=$true
    )

    Begin {}

    Process{

        $File | ForEach-Object {

            $o_file = Get-Item $_

            if($DoFFmpeg){

                #FFMpeg
                $s_tmp = $(($o_file.Directory.FullName) + "\" + ($o_file.Basename) + ".metadata.txt")
    
                #'-loglevel', '8',
                $command="ffmpeg"
                $a_args = @('-loglevel', '8',                        #Quiet
                            '-y',                                    #Overwrite
                            '-i',$o_file.FullName,                     #Input File
                            '-f', 'ffmetadata',                      #Get Metadata
                            $s_tmp                                   #To File
                            )   

                & $command $a_args

                $txt=Get-Content -Path $s_tmp
                Remove-Item $s_tmp
    
                $h_info = @{"metadata"=@{"txt"=$txt}}

                $h_cinfo = @{}

                $i_chapter=0
                $txt | ForEach-Object {
                    $line=$_
                    $match=$line | Select-String -Pattern '^([^=]+)=([^=]+)$'
        
                    Try
                    {
                        $key=$match.Matches.Groups[1].Value
                        $val=$match.Matches.Groups[2].Value

                        if($key){
                            $h_cinfo+=@{$key=$val}
                        }

                    }
                    Catch
                    {
                        #$line

                        if($line -match "^\[CHAPTER\]$")
                        {
                            #$h_cinfo
                            #Um eine Kopie einer Hashtable zu bekommen muss ich sie "Klonen"
                            if($i_chapter -eq 0){
                                $h_info.metadata += @{"base"=$h_cinfo.Clone()}
                            }                
                            else {
                                $h_info.metadata += @{$("chapter"+$i_chapter)=$h_cinfo.Clone()}
                            }
                            $i_chapter++
                
                            #Write-Host "Chapter" $i_chapter
                            $h_cinfo.Clear()
                        }
        
                    }
        
                }

                #Abschliesende Info Übernahme
                #$h_cinfo
                #Um eine Kopie einer Hashtable zu bekommen muss ich sie "Klonen"
                if($i_chapter -eq 0){
                    $h_info.metadata += @{"base"=$h_cinfo.Clone()}
                }                
                else {
                    $h_info.metadata += @{$("chapter"+$i_chapter)=$h_cinfo.Clone()}
                }
            }
            if($DoMediaInfo){

                #MediaInfo
                #'-loglevel', '8',
                $command="MediaInfo"
                $a_args = @('--Full',                        #Alles Ausgeben
                            '--Output=XML',                  #Im XML Format
                            $o_file.FullName                   #Input File
                            )   

                [xml]$xml_mediainfo=& $command $a_args
                $h_info+=@{"mediainfo"=$xml_mediainfo}
            }

            $h_info
        }
    }

    End {}
}

function Write-FFMPeg-Chapter {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    [ValidateScript({($_.GetType().Name -eq "FileInfo")})]
    $File,

    [Switch] $GetMetaFile
    )
    Begin {
        $chap_count=20
    
    }

    Process {
        
        
        $out=";FFMETADATA1" + "`n"

        $File | ForEach-Object {
            
            $curr_file=$_
            write-Host $curr_file.FullName
            Write-Host "Hole Media Info..."
            $info=Get-FFMpeg-MediaInfo $_

            $timestring=$($info.mediainfo.Mediainfo.File.track[0].Duration[5] | 
                Select-String -Pattern '([0-9]+:[0-9]+:[0-9]+)').Matches.Groups[1].Value
            $timeStringWithPeriod = $timeString.Replace(",",".")
            $timespan = [TimeSpan]::Parse($timestringWithPeriod)

            #Ich bekomme die Duration in Milisekunden
            [bigint]$duration=$timespan.TotalMilliseconds
            
            #Timebase sind Millisekunden
            [bigint]$chap_time=[int]$duration / [bigint]$chap_count

            #Bisherige Metainformationen übernehmen
            $info.metadata.base.Keys | ForEach-Object{
                $out+=$_ + "=" + $info.metadata.base.Item($_) + "`n"
            }


            $curr_time=0
            for($i=1; $i -le $chap_count; $i++) { 
                $out+="[CHAPTER]" + "`n"
                $out+="TIMEBASE=1/1000" + "`n"
                $out+="START="+ $curr_time + "`n"

                [bigint]$curr_time+=$chap_time

                $out+="END="+ $curr_time + "`n"
                $out+="title=Chapter "+ ("{0:0#}" -f $i) + "`n"
            }

            $target_path=($_.Directory.FullName + "/" + $_.BaseName + ".metadata.write.txt")

            #$out | Out-File -Encoding utf8 -FilePath $target_path

            $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
            [System.IO.File]::WriteAllLines($target_path, $out, $Utf8NoBomEncoding)

            #Wenn ich nur das MetaFile haben will
            if($GetMetaFile){
                Get-Item $target_path
            }
            Else
            {
                $metadata_file=Get-Item $target_path
                $target_path=($_.Directory.FullName + "/" + $_.BaseName + ".chapters.tmp" + $_.Extension)
                $final_path=$_.FullName
                #FFMpeg
                #'-loglevel', '8',
                $command="ffmpeg"
                $a_args = @('-loglevel', '8',                        #Quiet
                            '-y',                                    #Overwrite
                            '-i',$metadata_file.FullName,            #Metadata File
                            '-i',$curr_file.FullName,                #Input File
                            '-map_metadata', '1',                    #Schreib Metadata
                            '-codec','copy',                         #Alles andere kopieren
                            $target_path                             #To File Path
                            )   
                Write-Host "Schreibe Temporäre Datei mit Chapters"
                & $command $a_args

                Write-Host "Ersetze Original Datei"
                Remove-Item $curr_file
                Move-Item -Path $target_path -Destination $final_path
            }
        }
    }

    End {

    }



}

<#
.EXAMPLE
Get-ChildItem -File *.cue,*.mp3,*.mpd,*.mrk | Group-Files-By -Pattern '^(.*)\.' -Show

.EXAMPLE

Get-ChildItem -File *.cue,*.mp3,*.mpd,*.mrk | Group-Files-By -Pattern '^(.*)([\.-_]?)'
#>
Function Group-Files-By {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    [ValidateScript({($_.GetType().Name -eq "FileInfo")})]
    $File,

    [String] $Pattern,

    [Switch] $Show
    )
    Begin {
        $a_dirs=@()
    
    }

    Process {
        $File | ForEach-Object {
            $match = $_.Name | Select-String -Pattern $Pattern
            
            $group_dir = $match.Matches.Groups[1].Value
            if($Show)
            {
                $object = New-Object PSObject   
                Add-Member -InputObject $object -MemberType NoteProperty -Name "File" -Value $_.Name
                Add-Member -InputObject $object -MemberType NoteProperty -Name "MoveTo" -Value $group_dir
                $a_dirs+=$object
            }
            else
            {
                $group_dir_path=($_.Directory.FullName + "\" + $group_dir)
                if(-not $(Test-Path -Path $group_dir_path)){
                    Write-Host "Erstelle Verzeichnis: " $group_dir_path
                    $o_group_dir=New-Item -Path $group_dir -ItemType "Directory"
                }
                Move-Item -Path $_.FullName -Destination $group_dir_path

            }
        }
    }

    End {

        $a_dirs | Sort-Object -Property "MoveTo" | Out-GridView
    }

}


<#
.SYNOPSIS

Führt mehrere Dateien Binär zu einer Datei zusammen
.DESCRIPTION

Führt mehrere Dateien Binär zu einer Datei zusammen

.PARAMETER File

Eine oder mehre Dateien die mit Get-Item oder Get-ChildItem abgerufen wurden
.EXAMPLE

Get-Item * | Join-Binary
#>
function Join-Binary {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    $File,
    
    [Parameter(Position=1, Mandatory=$false)] [Alias('JoinFileName')][string]$To="Join.bin"
    )

    Begin {
        $a_files=@()
    }

    Process {
        #$File | Get-Content -Encoding Byte -ReadCount 104857600 | Set-Content -Path $To -Encoding Byte
        #$ins = @("a.ts", "b.ts")
        $File | ForEach-Object {
            $a_files+=$_
        }
    }

    End {
        

        If ( -not $(Get-Item -Path $To -ErrorAction SilentlyContinue)) {
            $o_outfile = New-Item -Path $To
        }
        Else {
            $o_outfile = Get-Item -Path $To
        }
        $outfile = $o_outfile.FullName
        Write-Host "Output Path:" $outfile

        #Write-Host "In-Files:"
        #$a_files

        
        $out = New-Object -TypeName "System.IO.FileStream" -ArgumentList @(
            $outfile, 
            [System.IO.FileMode]::Create,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None,
            256KB,
            [System.IO.FileOptions]::None)
        try {
            $a_files | ForEach-Object {
                $fs = New-Object -TypeName "System.IO.FileStream" -ArgumentList @(
                    $_.FullName, 
                    [System.IO.FileMode]::Open,
                    [System.IO.FileAccess]::Read,
                    [System.IO.FileShare]::Read,
                    256KB,
                    [System.IO.FileOptions]::SequentialScan)
                try {
                    $fs.CopyTo($out)
                } finally {
                    $fs.Dispose()
                }
            }
        } finally {
            $out.Dispose()
        }
        
    }
}


<#
.SYNOPSIS

Führt gesplittete Aufnahmen in angegebenen Verzeichnissen zusammen
.DESCRIPTION

Führt gesplittete Aufnahmen in angegebenen Verzeichnissen zusammen

.PARAMETER Dir

Verzeichnisse
.EXAMPLE

Get-Item * | Join-Binary
#>
function Join-TrpRecord-Binary {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('Directory')]
    $Dir
    )

    Begin {}

    Process {
        $Dir | ForEach-Object {
            If ( $_.PSIsContainer -and $_.GetType().Name -eq "DirectoryInfo")
            {
                $dir_content=@()
                $_ | ForEach-Object {
                        $dir_content+=Get-ChildItem -Path $_.FullName -Filter "*.trp"
                        For($i=0;$i -le 10; $i++) { #*.000 bis *.010
                            $dir_content+=Get-ChildItem -Path $_.FullName -Filter $("*."+$i.ToString("000"))
                        }
                     }
                $target_path=$_.FullName + "/" + $_.Name +".join.bin" 
                $dir_content | Join-Binary -To $target_path 
            }
        }
    }

    End {}
}



<#
.SYNOPSIS

Erstellt für jede übergebene Datei einen Ordner und verschiebt diese dort hinein
.DESCRIPTION

Erstellt für jede übergebene Datei einen Ordner und verschiebt diese dort hinein.
Brauche ich um z.B. Filme in Ordner zu organisieren

.PARAMETER File

Eine oder mehre Dateien die mit Get-Item oder Get-ChildItem abgerufen wurden
.EXAMPLE

Get-Item * | To-Folder
#>
function To-Folder {
    param(  
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    [Alias('FileItem')]
    $File
    )
    <#
        Für korrekten Pipeline Support brauch ich die Blöcke Begin,Process,End
        Siehe: https://learn-powershell.net/2013/05/07/tips-on-implementing-pipeline-support/
    #>
    Begin {}

    Process {

        $File | ForEach-Object {
            If ( -not $_.PSIsContainer -and $_.GetType().Name -eq "FileInfo")
            {
                $dir=New-Item -ItemType Directory -Name $_.BaseName
                $_ | Move-Item -Destination $dir
                $dir
            }
            Else
            {
                Write-Host "Nur Dateien werden in Ordner verpackt. Keine Verzeichnisse:" $_.Name
            }
        }
    }

    End {}
}

<#
.SYNOPSIS
    Ermittelt Passende Input Parameter für ffmpeg Image Demuxer
.DESCRIPTION
    Wenn ich mit FFMpeg Zeitraffer aus Bild Sequenzen machen will erwartet ffmpeg
    eine durchnummerierte Abfolge an Bildern.
    Ich muss ein Pattern angeben:
    z.B. DSC-%05d.jpg
    Das sind dann Bilder DSC-01234.jpg und ab dort durchnummeriert.
    Wenn die Abfolge nicht mit 0 oder 1 beginnt muss bei FFMpeg die Startnummer
    mit -start_number angegeben werden. Hier ermittle ich Pattern und Statnummer
    automatisch.

    Es müssen einfach nur Bilder, mit irgendeiner Nummerierung und der Endung .jpg sein
#>
Function _Timelapse-Get-InputArgs {
    [CmdletBinding()]
    param(
        $SourceDir=".",
        $FilePattern='',
        $Framerate=30,
        $StartNumber=0,
        $Frames=0,
        $Duration=0,
        $FadePercent=0,
        $FadeFramerate=60
    )
    $s_args=""
    #FilePattern ermitteln wenn keines übergeben wurde
    If($FilePattern -eq ''){
        $firstfile=Get-Item ($SourceDir+"\*.jpg") | Select-Object -First 1
        $match=$firstfile.Name | Select-String '([^0-9]*)([0-9]+)([^0-9]*)'
        $FilePattern=$match.Matches.Groups[1].Value + '%0' + $match.Matches.Groups[2].Length + 'd' + $match.Matches.Groups[3].Value
        #Nur wenn die StartNumber nicht übergeben wurde dann eine ermitteln
        if($StartNumber -eq 0){
            $StartNumber=[int]$match.Matches.Groups[2].Value
        }
    }

    <#
    -pix_fmt yuv420p    wichtig für MediaPlayer Kompatibilität
    -framerate 5        wieviele Bilder pro Sekunde verarbeitet werden
    -r                  Framerate des ausgegebenen Videos
    -i                  Input File mit FilePattern
                        FilePattern z.B.
                        img-%03d.jpeg
    -start_number       Starte bei diesem Bild
    -frames             Gib so viele Frames aus
    -vcodec             verwendeter ffmpeg Codec
    -qp                 Quality (10 Perfekt, 20 Gut, 30 OK, 40 Naja)
    -s                  Size z.B. "1024x768"
    #>

    If($FadePercent -gt 0){
        
        $FadeRate = $Framerate * (100-$FadePercent)/100
        #$FadeFRate = $Framerate - $FadeRate

        #Wenn ich einen "Fade" machen will. Muss ich die Bilder entsprechend
        #langsamer auslesen
        #$s_args+='-framerate ' + $FadeRate
        $s_args+='-framerate ' + $Framerate

    }
    else{
        $s_args+='-framerate ' + $Framerate
    }
    #-start_number Start Number
    $s_args+=" -start_number $StartNumber"


    #-t Duration (Input Duration! Wichtig!)
    #Mit Duration Kontrolliere ich wieviel ausgegeben wird    
    $duration_arg=''
    If($Frames -gt 0){
        $DurationCalc=1/$Framerate * $Frames
        $duration_arg=' -t ' + [string]($DurationCalc)
    }

    #Duration überschreibt Frames
    If($Duration -gt 0){
        $DurationCalc = $Duration
        $duration_arg=' -t ' + $DurationCalc
    }

    If($duration_arg -ne ''){
        $s_args+=$duration_arg
    }

    #-i Input
    $s_args+=' -i "' + ($SourceDir + "\" + $FilePattern) + '"'


    $vf_args=""
    $vf_args+="scale=w=1920:h=-2"

    If($FadePercent -gt 0){
        <#
            Slideshow with crossfading between the pictures
            You can make a slideshow with crossfading between the pictures, 
            by using a combination of the zoompan and framerate filters.
            "A" is the duration in seconds how long each picture is shown 
            (without the crossfade duration), 
            and "B" is the crossfade duration in seconds


            -vf zoompan=d=(A+B)/B:fps=1/B,framerate=25:interp_start=0:interp_end=255:scene=100 
        #>
        $A=[string](1/$Framerate*(100-$FadePercent)/100)
        $B=[string](1/$Framerate*$FadePercent/100)

        $vf_args+= ",zoompan=d=($A+$B)/$B"+":fps=1/$B,framerate=$FadeFramerate"+":interp_start=0:interp_end=255:scene=100"
    }

    if($vf_args -ne ""){
        $s_args+=" -vf "+ '"' + $vf_args + '"'
    }

    New-Object -TypeName PsObject -Property ([ordered]@{
        Framerate = $Framerate
        FadePercent = $FadePercent
        FadeRate = $FadeRate
        StartNumber  = $StartNumber
        FilePattern = $FilePattern
        Duration = $DurationCalc
        Frames = $Frames
        args=$s_args
    })

    #Ausgabe
    #$s_args
}


Function Create-Timelapse {
    [CmdletBinding()]
    param(
        $SourceDir=".",
        [Parameter(Mandatory=$true)]$TargetFile,
        $FilePattern='', #'DSC%05d.JPG'
        $Framerate=30,
        $StartNumber=0,
        $vCodec="libx264",
        $Quality=20,
        $Frames=0,
        $Duration=0,
        $FadePercent=0
    )
    <#
    -pix_fmt yuv420p    wichtig für MediaPlayer Kompatibilität
    -framerate 5        wieviele Bilder pro Sekunde verarbeitet werden
    -r                  Framerate des ausgegebenen Videos
    -i                  Input File mit FilePattern
    -start_number       Starte bei diesem Bild
    -frames             Gib so viele Frames aus
    -vcodec             verwendeter ffmpeg Codec
    -qp                 Quality (für libx264) (10 Perfekt, 20 Gut, 30 OK, 40 Naja)
    -s                  Size z.B. "1024x768"
    #>

    
    $args=''

    $o_iargs+=(_Timelapse-Get-InputArgs -SourceDir $SourceDir -FilePattern $FilePattern `
                -Framerate $Framerate -StartNumber $StartNumber -Frames $Frames -Duration $Duration -FadePercent $FadePercent)

    $args+=$o_iargs.args    

    $args+=" -vcodec $vCodec"
    $args+=" -pix_fmt yuv420p"
    $args+=" -qp $Quality"

    $args+=' "' + $TargetFile + '"'

    <#
    ffmpeg -framerate $Framerate -i ($SourceDir + "\" + $FilePattern) `
        -start_number $StartNumber `
        -vcodec $vCodec `
        -pix_fmt yuv420p `
        -qp $Quality `
        $TargetFile
    #>
    
    Write-Host ("args: " + $args)

    $process=Start-Process "ffmpeg.exe" -ArgumentList $args -NoNewWindow -PassThru
    $process.PriorityClass="Belownormal"
    $process.WaitForExit()
    Write-Host "Exitcode: " $process.ExitCode


}

Function Show-Timelapse{
    [CmdletBinding()]
    param(
        $SourceDir=".",
        $FilePattern='',
        $Framerate=30,
        $StartNumber=0,
        $Frames=0,
        $Duration=0,
        $Width=800,
        $Height=600,
        $FadePercent=0
    )

    $args=''

    $o_iargs=(_Timelapse-Get-InputArgs -SourceDir $SourceDir -FilePattern $FilePattern `
                -Framerate $Framerate -StartNumber $StartNumber -Frames $Frames -Duration $Duration -FadePercent $FadePercent)

    $args+=$o_iargs.args

    $args+=" -x $Width -y $Height"
    Write-Host ("args: " + $args)

    $process=Start-Process "ffplay.exe" -ArgumentList $args -NoNewWindow -PassThru
    $process.PriorityClass="Belownormal"
    $process.WaitForExit()

    Write-Host "Exitcode: " $process.ExitCode



}

Function Get-TimelapseSequence {
    [CmdletBinding()]
    param(
        $SourceDir=".",
        $MaxTimeDiffSeconds=61,
        $MinFrames=30
    )

    $files=Get-Item ($SourceDir + "\*.jpg") #| Sort-Object -Property LastWriteTime

    $i=1
    $seq_nr=1
    ForEach($file in $files){
        $match=$file.Name | Select-String '([^0-9]*)([0-9]+)([^0-9]*)'
        $CurNumber=[int]$match.Matches.Groups[2].Value

        if($match){
            if($i -eq 1){
            
                $FilePattern=$match.Matches.Groups[1].Value + '%0' + $match.Matches.Groups[2].Length + 'd' + $match.Matches.Groups[3].Value
                $StartNumber=[int]$match.Matches.Groups[2].Value
            
            }
            else{

                Write-Verbose ("CurNumber: " + $CurNumber)
                Write-Verbose ("LastNumber: " + $LastNumber)

                
                $TimeDiff=New-TimeSpan -Start $LastFileTime -End $file.LastWriteTime
                if($TimeDiff -gt (New-TimeSpan -Seconds $MaxTimeDiffSeconds) -or
                ($CurNumber - $LastNumber) -ne 1
                ){
                    if($i -ge $MinFrames){
                        New-Object -TypeName PsObject -Property ([ordered]@{
                            Nr = $seq_nr
                            SourceDir = (Get-Item $SourceDir)
                            StartNumber  = $StartNumber
                            FilePattern = $FilePattern
                            Frames = $i
                        })
                        $seq_nr++
                    }
                    $i=0                
                }
            }
        }
        else{
            Write-Verbose ($file.Name + " Matcht nicht mit Pattern '([^0-9]*)([0-9]+)([^0-9]*)'")
        }

        $LastFileTime=$file.LastWriteTime
        $LastNumber=$CurNumber
        $i++
    }
    
    #Letzte Sequenz muss auch noch raus
    if($i -ge $MinFrames){
        New-Object -TypeName PsObject -Property ([ordered]@{
            Nr = $seq_nr
            SourceDir = (Get-Item $SourceDir)
            StartNumber  = $StartNumber
            FilePattern = $FilePattern
            Frames = $i
        })
    }


}

<#
.SYNOPSIS
    Spielt alle Zeitraffer Sequenzen in einem Verzeichnis ab

.EXAMPLE
    #Und das hier spielt alle Zeitraffer in allen Verzeichnissen ab die sich
    #im derzeitigen Verzeichnis befinden
    Get-Item * | %{Show-TimelapseSequences -SourceDir $_.FullName}
.EXAMPLE
    #Spiele einen Zeitraffer ab in dem die Fotos mit einem sehr langem Abstand zueinander aufgenommen wurden (5 Minuten)
    Show-TimelapseSequences -MaxTimeDiffSeconds 310
#>
Function Show-TimelapseSequence{
    [CmdletBinding()]
    param(
        $SourceDir=".",
        $Nr="all",
        $MaxTimeDiffSeconds=61,
        $Framerate=30,
        $Width=800,
        $Height=600,
        $MinFrames=60,
        $FadePercent=0
    )

    $a_seq=Get-TimelapseSequence -SourceDir $SourceDir -MaxTimeDiffSeconds $MaxTimeDiffSeconds -MinFrames $MinFrames
    
    If($Nr -ne "all"){
        $a_seq=$a_seq | Where-Object -Property Nr -eq $Nr
    }
    
    $a_seq| ForEach-Object {
        $seq=$_
        Show-Timelapse -SourceDir $SourceDir -FilePattern $seq.FilePattern -Framerate $Framerate `
            -StartNumber $seq.StartNumber -Frames $seq.Frames -Width $Width -Height $Height -FadePercent $FadePercent
    }

}


Function Create-TimelapseSequence{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]$TargetDir,
        $SourceDir=".",
        $Nr="all",
        $MaxTimeDiffSeconds=61,
        $Framerate=30,
        $MinFrames=60,
        $FadePercent=0
    )

    $a_seq=Get-TimelapseSequence -SourceDir $SourceDir -MaxTimeDiffSeconds $MaxTimeDiffSeconds -MinFrames $MinFrames
    
    If($Nr -ne "all"){
        $a_seq=$a_seq | Where-Object -Property Nr -eq $Nr
    }

    $a_seq | ForEach-Object {
        $seq=$_

        $TargetFile=($TargetDir + "\" + $seq.SourceDir.Name + "_" + $seq.StartNumber + ".mp4")
        $i=0
        While(Test-Path -Path $TargetFile){
            $TargetFile=($TargetDir + "\" + $seq.SourceDir.Name + "_" + $seq.StartNumber + "_$i.mp4")
            $i++
        }

        Create-Timelapse -SourceDir $SourceDir -FilePattern $seq.FilePattern -Framerate $Framerate `
            -StartNumber $seq.StartNumber -Frames $seq.Frames -vCodec "libx264"`
            -FadePercent $FadePercent -TargetFile $TargetFile
    }

}
