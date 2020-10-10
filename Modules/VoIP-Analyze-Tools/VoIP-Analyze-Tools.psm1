function Convert-HexStringToByteArray
{
################################################################
#.Synopsis
# Convert a string of hex data into a System.Byte[] array. An
# array is always returned, even if it contains only one byte.
#.Parameter String
# A string containing hex data in any of a variety of formats,
# including strings like the following, with or without extra
# tabs, spaces, quotes or other non-hex characters:
# 0x41,0x42,0x43,0x44
# \x41\x42\x43\x44
# 41-42-43-44
# 41424344
# The string can be piped into the function too.
################################################################
[CmdletBinding()]
Param ( [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [String] $String )
 
#Clean out whitespaces and any other non-hex crud.
$String = $String.ToLower() -replace '[^a-f0-9\\,x\-\:]',"
 
#Try to put into canonical colon-delimited format.
$String = $String -replace '0x|\x|\-|,',':'
 
#Remove beginning and ending colons, and other detritus.
$String = $String -replace '^:+|:+$|x|\',"
 
#Maybe there's nothing left over to convert...
if ($String.Length -eq 0) { ,@() ; return }
 
#Split string with or without colon delimiters.
if ($String.Length -eq 1)
{ ,@([System.Convert]::ToByte($String,16)) }
elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1))
{ ,@($String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}) }
elseif ($String.IndexOf(":") -ne -1)
{ ,@($String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)}) }
else
{ ,@() }
#The strange ",@(...)" syntax is needed to force the output into an
#array even if there is only one element in the output (or none).
}




Function Convert-UnixTimestampToDatetime
(
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ] $UnixDate
) {
   [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate))
}
Function Voip-Get-TracePerStatusCode {
<#
.SYNOPSIS
    Extrahiert VoIP Calls anhand eines Filters
.DESCRIPTION
    VoIP Calls auf die der Filter zutrifft, werden komplett extrahiert (von Invite bis BYE ACK)

    //XXX TODO
    - Die Mehrfachen tshark Aufrufe ersetzen durch nur ein Powershell CMD-Let "Voip-Get-Packets"
        Dieses soll Paket Objekte laut angegebenen Filter zurückgeben, diese können dann hier weiter verwendet werden

    - Aktuell sieht man nur das Signaling
        man sollte auch das zugehörige Audio (RTP) mit extrahieren können
    - Statt StatusCode sollte man einen beliebigen Wireshark Filter verwenden können
        Diese Funktion dann Voip-GetTracePerFilter nennen
        dann eine weitere Funktion schreiben die Voip-GetTracePerStatusCode heisst und auf diese Funktion mit entsprechendem Filter verweist
    - 2 Ladebalken wären Nice
        - Einer für den kompletten Prozess (x von y Pcaps verarbeitet)
        - Einer für den Fortschritt im einzelnen PCAP (tshark wir 4 Mal aufgerufen, kann jedes Mal um 25% erhöht werden)

.PARAMETER PcapFile
    Zu lesendes Pcap (können rein gepiped werden)
.PARAMETER SBCip
    IP-Addresse des nach aussen gerichteten SBC Interface
.PARAMETER StatusCode
    Nach diesem StatusCode suchen wir
.EXAMPLE
    Get-Item .\new.pcap | Voip-Get-TracePerStatusCode -SBCip 192.168.1.87 -StatusCode 481
.EXAMPLE
    Get-Item *.pcap | Voip-Get-TracePerStatusCode -SBCip 192.168.1.87 -StatusCode 481
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/VoIP-Analyze-Tools.psm1
    
#>
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $PcapFile,

        [Parameter(Mandatory=$true)] $SBCip,

        #//XXX Statt Status Code einen ganzen Wireshark Filter angeben
        #Muss mir dann was überlegen wie dann die Datei heissen soll
        $StatusCode=408,

        $TargetPath="_extracted"

        

    )

    Begin {}

    Process {
        $PcapFile | ForEach-Object {
            $pcap=$_

            Write-Host "PCAP-File" $pcap
            <#
            Write-Host "Test"

            tshark -2 -r "$pcap" -Y "sip.Status-Code == $StatusCode and ip.host == $SBCip" -T fields -E "separator=|" `
                -e ip.src -e udp.srcport -e tcp.srcport -e ip.dst -e udp.dstport -e tcp.dstport `
                -e sip.Call-ID -e sip.Status-Code
            #>

            tshark -r "$pcap" -Y "sip.Status-Code == $StatusCode and ip.host == $SBCip" -T fields -E "separator=|" `
                -e ip.src -e udp.srcport -e tcp.srcport -e ip.dst -e udp.dstport -e tcp.dstport `
                -e sip.Call-ID -e sip.Status-Code | 
            ForEach-Object {
                $values=$_.split("|")

                $packet=New-Object -TypeName PSObject -Property @{
                    srcip=$values[0]
                    srcudpport=$values[1]
                    srctcpport=$values[2]
                    dstip=$values[3]
                    dstudpport=$values[4]
                    dsttcpport=$values[5]
                    sipCallID=$values[6]
                    sipStatusCode=$values[7]
                } 
                #$packet

                [string]$sipCallId='\"'+$packet.sipCallID+'\"'

                #//XXX diese mehrfachen aufrufe von tshark durch einen generischen in einem Cmdlet ersetzen
                tshark -r "$pcap" -Y "sip.Call-ID == $sipCallId" -T fields -E "separator=|" `
                -e frame.time -e frame.time_epoch `
                -e ip.src -e udp.srcport -e tcp.srcport -e ip.dst -e udp.dstport -e tcp.dstport `
                -e sip.Call-ID -e sip.Status-Code -e sip.Method | 
                ForEach-Object {
                    $values=$_.split("|")
                    $time_match=$values[0] | Select-String -Pattern "^(.*[0-9]+:[0-9]+:[0-9]+.[0-9]+)"
                    $packet=New-Object -TypeName PSObject -Property @{
                        frametime      = Get-Date $time_match.Matches.Groups[1].Value
                        frametimeepoch = $values[1]
                        srcip          = $values[2]
                        srcudpport     = $values[3]
                        srctcpport     = $values[4]
                        dstip          = $values[5]
                        dstudpport     = $values[6]
                        dsttcpport     = $values[7]
                        sipCallID      = $values[8]
                        sipStatusCode  = $values[9]
                        sipMethod      = $values[10]
                    }

                    #$packet

                    if($packet.sipMethod -eq "INVITE") {
                        $callstart=$packet.frametime
                        $searchstart=[int]$packet.frametimeepoch - 1
                        $searchend=[int]$packet.frametimeepoch + 1

                        $sipcallidstring=""
                        
                        $i=0
                        
                        tshark -r "$pcap" -Y "frame.time_epoch > $searchstart and frame.time_epoch < $searchend and sip.Status-Code == 100" -T fields -E "separator=|" `
                        -e frame.time -e frame.time_epoch `
                        -e ip.src -e udp.srcport -e tcp.srcport -e ip.dst -e udp.dstport -e tcp.dstport `
                        -e sip.Call-ID -e sip.Status-Code -e sip.Method | 
                        ForEach-Object {
                            $values=$_.split("|")
                            $time_match=$values[0] | Select-String -Pattern "^(.*[0-9]+:[0-9]+:[0-9]+.[0-9]+)"
                            $packet=New-Object -TypeName PSObject -Property @{
                                frametime      = Get-Date $time_match.Matches.Groups[1].Value
                                frametimeepoch = $values[1]
                                srcip          = $values[2]
                                srcudpport     = $values[3]
                                srctcpport     = $values[4]
                                dstip          = $values[5]
                                dstudpport     = $values[6]
                                dsttcpport     = $values[7]
                                sipCallID      = $values[8]
                                sipStatusCode  = $values[9]
                                sipMethod      = $values[10]
                            }

                            #$packet
                            
                            if($i -gt 0){
                             $sipcallidstring+= " or "
                            }

                            $sipcallidstring+="sip.Call-ID == "+ '\"' +$packet.sipCallId + '\"'

                            $i++

                        }
                        
                    }

                }


                $filterstring="( tcp.connection.syn or " + $sipcallidstring + ")"
                Write-Host "filterstring: " $filterstring
                #Write-Host "last_filterstring: " $last_filterstring
                <#
                    Es kann sein, dass ein Status mehrmals in einem PCAP vorkommt
                    Deswegen muss sich der filterstring immer unterscheiden
                #>
                if($last_filterstring -ne $filterstring){
                    $last_filterstring=$filterstring

                    $target_dir=$TargetPath + '\' + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss" $callstart)+ "_IP_" + $SBCip + "_Status_" + $StatusCode
                    $target_file=$target_dir + '\' + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss" $callstart) + "_IP_" + $SBCip + "_Status_" + $StatusCode + ".pcap"

                    $wavs=Voip-SearchCallWav $callstart
                    
                    Write-Host "target_file: " $target_file

                    #Gefundene Call-IDs ins Zielverzeichnis Filtern
                    #Und WAVs kopieren

                    if(-not (Get-Item $target_file -ErrorAction SilentlyContinue)){
                        $new_targetdir=New-Item -Path $target_dir -ItemType Directory
                        $wavs.file | Copy-Item -Destination $target_dir -ErrorAction SilentlyContinue
                        tshark -r "$pcap" -Y "$filterstring" -w $target_file
                    }
                }
                else
                {
                    Write-Host "Status $StatusCode Mehrfach"
                }


            }

            Write-Host ""
            Write-Host ""
            #Nächste Datei

        }

    }

    End {}

}


Function Voip-Get-SipOnly
{
<#
.SYNOPSIS
    Filtert rein SIP aus dem/den PCAPs
#>
    param(
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $PcapFile
    )

    Begin {}

    Process {
        $PcapFile | ForEach-Object{
            if(-not (Get-Item ($_.Name + ".siponly.pcap") -ErrorAction SilentlyContinue))
            {
                tshark -2 -r $_.Name  -Y "sip or tcp.connection.syn" -w ($_.Name + ".siponly.pcap")
            }
        }
    }

    End {}


}



Function Voip-Get-SipPDML
{
<#
.SYNOPSIS
    Liefert das SIP PDML aus einem PCAP
.DESCRIPTION
    Filtert mit tshark das PCAP auf SIP Informationen (nur SIP)
    und gibt diese als PDML zurück
    PDML wird in einem xml File gespeichert um es bei erneutem
    Aufruf schneller laden zu können

#>
    param
    (
        $pcap
    )

    Begin{}

    Process{}

    End{
        $pdml_file_path=($pcap.Directory.FullName + "\" + $pcap.BaseName + ".siponly.pdml.xml")
        Write-Verbose([string](Get-Date -Format "yyyy-MM-dd hh:mm:ss") + ": " + "Lade SIP Informationen")
        If(Test-Path -Path $pdml_file_path){
            Write-Verbose "Lade PDML von: $pdml_file_path"
            [xml]$pdml=Get-Content $pdml_file_path
        }
        else
        {
            Write-Verbose ("Erzeuge PDML aus: "+$pcap.FullName)
            #tshark -2 -r $pcap.FullName  -Y "sip" -T pdml | Out-File ($pcap.BaseName + ".sip.pdml.xml")
            [xml]$pdml=tshark -2 -r $pcap.FullName  -Y "sip" -T pdml
            #Wir sichern das PDML in einem XML File um es dann schneller laden zu können
            $pdml.Save($pdml_file_path)
        }
        Write-Verbose([string](Get-Date -Format "yyyy-MM-dd hh:mm:ss") + ": " + "SIP Informationen Laden fertig")

        $pdml
    }

}


Function Voip-Get-SipCall
{
<#
.SYNOPSIS
    Liefert SIP Calls in einem PCAP
.DESCRIPTION
    Teilt die Eingangs PCAPS in seine einzelnen Calls auf
    Liefert als Ergebnis die ausgegebenen PCAP Files zurück
    
    Die PCAP Files werden NICHT in chronologischer Reihenfolge ausgegeben
    Das kommt davon weil hier zunächst die Call-IDs mit "sort | uniq" sortiert werden
    das ist dann also die Ausgabe Reihenfolge
    
    Die DATEINAMEN sind dann aber chronologisch

.EXAMPLE
    Get-Item 2017-04-18_13-56-52_longtrace.pcap | Voip-Get-SipCall | Out-GridView
#>

param
(
    #PcapFile: Files (Get-Item) die aufgeteilt werden sollen
    [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)
    ]
    $PcapFile,

    $pdml="",

    $CallID=""
)

    Begin {
        
    }

    Process {
        $PcapFile=Get-Item $PcapFile

        $PcapFile | ForEach-Object{
            $pcap=$_

            #Nur wenn wir kein pdml übergeben bekommen haben, holen wir es uns neu
            if($pdml -eq ""){
                $pdml=Voip-Get-SipPDML $pcap
            }

            if($CallID -ne ""){
                $call_id=$CallID
            }
            else
            {
                #$pdml
                $x_invite = $pdml.pdml.packet | ?{$_.proto.name -eq "sip"} | ?{$_.proto.field.field.name -eq "sip.Method" -and $_.proto.field.field.show -eq "INVITE"}

                #Nur Calls IDs die wir noch nicht hatten in das call_id Array speichern. Wir werten Jeden Call nur einmal ein
                #(So umgehe ich das reINVITE Problem
                $call_id=@()
                $x_invite.proto | ? name -eq sip | %{$_.field} | ? name -eq sip.msg_hdr | %{$_.field} | ? name -eq "sip.Call-ID" | ForEach-Object {
                     $cid=$_.show
                 
                     if ( $cid -notin $call_id)
                     {
                        $call_id+=$cid
                     }
                     else
                     {
                        Write-Verbose ("reINVITE in CallID ignoriert: "+ $cid)
                     }

                }
                #$call_id
            }

            $call_id | ForEach-Object {
                $sip_cid=$_

                $frame_objects=$pdml.pdml.packet | ?{$_.proto.name -eq "sip"} | ?{ ($_.proto.field | ? name -eq "sip.msg_hdr" | %{$_.field} | ? name -eq "sip.Call-ID").show -eq $sip_cid }

                $first_frame_object=$frame_objects | Select-Object -First 1
                $last_frame_object=$frame_objects | Select-Object -Last 1

                $first_frame_timestamp=($first_frame_object.proto | ? name -eq "geninfo" | % field | ? name -eq "timestamp").value
                $last_frame_timestamp=($last_frame_object.proto | ? name -eq "geninfo" | % field | ? name -eq "timestamp").value

                $first_frame_datetime=Get-Date (Convert-UnixTimestampToDatetime $first_frame_timestamp) -Format "yyyy-MM-dd hh:mm:ss.fff"

                $first_frame_number=($first_frame_object.proto | ? name -eq "geninfo" | % field | ? name -eq "num").show
                $last_frame_number=($last_frame_object.proto | ? name -eq "geninfo" | % field | ? name -eq "num").show

                $src_ip=($first_frame_object.proto | ? name -eq  "ip" | % field | ? name -eq "ip.src").show
                $dst_ip=($first_frame_object.proto | ? name -eq  "ip" | % field | ? name -eq "ip.dst").show

                #So bekomme ich SIP Infos
                $sip_from=($first_frame_object.proto | ? name -eq "sip" | % field | ? name -eq "sip.msg_hdr" | % field | ? name -eq "sip.From").show
                $sip_to=($first_frame_object.proto | ? name -eq "sip" | % field | ? name -eq "sip.msg_hdr" | % field | ? name -eq "sip.To").show
                

                Write-Verbose ("First-Frame: "+($first_frame_object.proto | ? name -eq "geninfo" | % field | ? name -eq "num").show)
                Write-Verbose ("Last-Frame: "+  ($last_frame_object.proto | ? name -eq "geninfo" | % field | ? name -eq "num").show)

                Write-Verbose ("First-Frame-Timestamp: "+ $first_frame_timestamp)
                Write-Verbose ("First-Frame-Timestamp: "+ $last_frame_timestamp)
                Write-Verbose ("First-Frame-DateTime:" + (Get-Date $first_frame_datetime -Format "yyyy-MM-dd_hh-mm-ss"))

                New-Object -TypeName PSObject -Property ([ordered]@{
                    src_ip = $src_ip;
                    dst_ip = $dst_ip;
                    sip_from = $sip_from;
                    sip_to = $sip_to;
                    first_frame_number = $first_frame_number;
                    first_frame_datetime = $first_frame_datetime;
                    last_frame_number = $last_frame_number;
                    sip_callid = $sip_cid;
                    
                })

            }
        }
    }
    
    End{}

}



Function Voip-Get-SipCallPcapFile
{
<#
.SYNOPSIS
    Teilt ein PCAP in seine einzelnen Calls auf
.DESCRIPTION
    Teilt die eingangs PCAPS in seine einzelnen Calls auf
    Liefert als Ergebnis die ausgegebenen PCAP Files zurück
    
#>
    param
    (
        #PcapFile: Files (Get-Item) die aufgeteilt werden sollen
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $PcapFile,
        <#
            Mode: Modus in dem die PCAP Files aufgeteilt werden
                Single   : Pro Call ein PCAP File
                Pair     : SBC intern,extern Paare (also der interne und externe Calls zusammen)
                Exact    : Es wird genau nur immer ein Call mit dazugehörigen Audioströmen (via SSRC) in ein File gepackt
                ExactPair: Wie Exact. Nur mit SBC intern, extern Paaren 
        #>
    
        [ValidateSet("Single","Pair","Exact","ExactPair")] $Mode="Single"
    )

    Begin {
        $PcapFile=Get-Item $PcapFile
    }

    Process {
        $PcapFile | ForEach-Object{
            $pcap=$_
            $target_dir=New-Item -Path ($pcap.Directory.FullName + "\" + $pcap.BaseName) -ItemType Directory -ErrorAction SilentlyContinue
            $target_dir=Get-Item ($pcap.Directory.FullName + "\" + $pcap.BaseName)

            $sip_cid=$call.sip_callid
            $first_frame_number=$call.first_frame_number
            $last_frame_number=$call.last_frame_number


            Switch($Mode){

                "Single"
                {
                    Voip-Get-SipCall -PcapFile $pcap | ForEach-Object {
                        $call=$_
                        $thark_filter='"sip.Call-ID=='+$call.sip_callid+' or (!sip and frame.number > '+$call.first_frame_number+' and frame.number < '+$call.last_frame_number+')"'

                        $target_file=($target_dir.FullName + "\"+ $pcap.BaseName + "_call_" + (Get-Date $call.first_frame_datetime -Format "yyyy-MM-dd_hh-mm-ss") + "_"+$call.src_ip+".pcap" )
                
                        Write-Verbose ("thark_filter: "+ $thark_filter)
                        Write-Verbose ("target_file: " + $target_file)

                        tshark -2 -r $pcap.FullName -Y "sip.Call-ID==""""$sip_cid"""" or (!sip and frame.number > $first_frame_number and frame.number < $last_frame_number)" -w $target_file
                
                        #Das File das Wireshark schreibt geben wir zurueck
                        Get-Item $target_file
                        }
                    break;
                }
                "Pair"
                {
                    $calls=Voip-Get-SipCall -PcapFile $pcap
                    
                    $j=1
                    $k=1
                    for($i=0;$i -lt $calls.Length; $i++){
                        #$k
                        $calls[$i] | Add-Member -MemberType NoteProperty -Name Group -Value $k
                        $calls[$i]
                        if($j -eq 2){
                            $k++
                            $j=0
                        }
                        $j++
                    }


                    #$call_groups=$calls | Group-Object -Property {Get-Date $_.first_frame_datetime -Format "yyyy-MM-DD hh:mm:ss"}
                    $call_groups=$calls | Group-Object -Property Group

                    #$call_groups

                    $call_groups | ForEach-Object {
                        $call_group=$_ 

                        $calls=$call_group.Group

                        #$calls
                        #Write-Host "Call 1" 
                        #$calls[0]
                        #Write-Host "Call 2" 
                        #$calls[1]

                        $target_file=($target_dir.FullName + "\"+ $pcap.BaseName + "_call_" + (Get-Date $calls[0].first_frame_datetime -Format "yyyy-MM-dd_hh-mm-ss") + "_"+$calls[0].src_ip+"_"+$calls[1].src_ip+".pair.pcap" )
                        $cid1 =$calls[0].sip_callid
                        $cid2 =$calls[1].sip_callid
                        $ffn  =$calls[1].first_frame_number
                        $lfn  =$calls[1].last_frame_number

                        tshark -2 -r $pcap.FullName -Y "sip.Call-ID==""""$cid1"""" or sip.Call-ID==""""$cid2"""" or(!sip and frame.number > $ffn and frame.number < $lfn)" -w $target_file
                        Get-Item $target_file
                    }
                    break;
                }
                "Exact"
                {
                    Voip-Get-SipCall -PcapFile $pcap | ForEach-Object {
                        $call=$_

                        $target_file=($target_dir.FullName + "\"+ $pcap.BaseName + "_call_" + (Get-Date $call.first_frame_datetime -Format "yyyy-MM-dd_hh-mm-ss") + "_"+$call.src_ip+".pcap" )

                        $sip_cid=$call.sip_callid
                        $rtp=Voip-Get-SipAudioStream -PcapFile $pcap -CallID $call.sip_callid

                        $ssrcfilter=""
                        $i=0
                        ForEach ($ssrc in $rtp.ssrc){
                            if($i -gt 0){
                                $ssrcfilter+=" or "
                            }
                            $ssrcfilter+= "rtp.ssrc == $ssrc"
                            $i++
                        }
                        Write-Verbose("Wireshark Filter: "+"sip.Call-ID==""""$sip_cid"""" or (($ssrcfilter) and frame.number > $first_frame_number and frame.number < $last_frame_number)")

                        tshark -2 -r $pcap.FullName -Y "sip.Call-ID==""""$sip_cid"""" or (($ssrcfilter) and frame.number > $first_frame_number and frame.number < $last_frame_number)" -w $target_file
                        Get-Item $target_file
                    }
                }
                "ExactPair"
                {
                    $calls=Voip-Get-SipCall -PcapFile $pcap

                    $j=1
                    $k=1
                    for($i=0;$i -lt $calls.Length; $i++){
                        #$k
                        $calls[$i] | Add-Member -MemberType NoteProperty -Name Group -Value $k
                        $calls[$i]
                        if($j -eq 2){
                            $k++
                            $j=0
                        }
                        $j++
                    }


                    #$call_groups=$calls | Group-Object -Property {Get-Date $_.first_frame_datetime -Format "yyyy-MM-DD hh:mm:ss"}
                    $call_groups=$calls | Group-Object -Property Group

                    #$call_groups

                    $call_groups | ForEach-Object {
                        $call_group=$_ 

                        $calls=$call_group.Group

                        $rtp=@()

                        ForEach($call in $calls){
                            $rtp+=Voip-Get-SipAudioStream -PcapFile $pcap -CallID $call.sip_callid
                        }

                        $ssrcfilter=""
                        $i=0
                        ForEach ($ssrc in $rtp.ssrc){
                            if($i -gt 0){
                                $ssrcfilter+=" or "
                            }
                            $ssrcfilter+= "rtp.ssrc == $ssrc"
                            $i++
                        }


                        #$calls
                        #Write-Host "Call 1" 
                        #$calls[0]
                        #Write-Host "Call 2" 
                        #$calls[1]

                        $target_file=($target_dir.FullName + "\"+ $pcap.BaseName + "_call_" + (Get-Date $calls[0].first_frame_datetime -Format "yyyy-MM-dd_hh-mm-ss") + "_"+$calls[0].src_ip+"_"+$calls[1].src_ip+".pair.pcap" )
                        $cid1 =$calls[0].sip_callid
                        $cid2 =$calls[1].sip_callid
                        $ffn  =$calls[1].first_frame_number
                        $lfn  =$calls[1].last_frame_number

                        Write-Verbose("Wireshark Filter: "+"sip.Call-ID==""""$cid1"""" or sip.Call-ID==""""$cid2"""" or(($ssrcfilter) and frame.number > $ffn and frame.number < $lfn)")

                        tshark -2 -r $pcap.FullName -Y "sip.Call-ID==""""$cid1"""" or sip.Call-ID==""""$cid2"""" or(($ssrcfilter) and frame.number > $ffn and frame.number < $lfn)" -w $target_file
                    }
                }
            }
        }
    }

    End {}

}



Function Voip-Get-SDPMediaConnections
{
<#
.SYNOPSIS
    Liefert SDP-MediaConnection Objekte
.DESCRIPTION
    Liefert SDP-MediaConnection Objekte
    mit folgenden Eigenschaften:
        - ip
        - mediatype
        - port

    Marschiert durch alle SDP Header und wertet nacheinanderfolgendes aus
    - sdp.connection_info
        - sdp.connection_info.address -> Hier findet sich die IP-Addresse
    - sdp.media
        - sdp.media.media -> Media Typ (z.B. Audio)
        - sdp.media.port -> Port auf dem das Medium zur Verfügung gestellt wird
    
    Unvollständige Verbindungsinformationen werden nicht zurückgeliefert
#>
param
(
    #PDML Objekt des aktuellen Frame Frame (Packet)
    $packet,
    #PCAP File das gerade bearbeitet wird
    $pcap
)
    
    <#
    //XXX Die Namen hier noch optimieren
    ip         -> media_to_ip
    mediatype  -> media_type
    port       -> media_to_port

    #>

    $current_framenumber=$packet.proto | ? name -eq geninfo | % field | ? name -eq "num" | % show

    $current_timestamp= ($packet.proto | ? name -eq geninfo | % field | ? name -eq "timestamp" | % value)| Convert-UnixTimestampToDatetime | Get-Date -Format "yyyy-MM-dd hh:mm:ss.fff"

    Write-Verbose ("Current Frame Number: " + $current_framenumber)

    $x_sip=$packet.proto | ? name -eq "sip"
    #$x_sip
                        
    $x_sip_header=$x_sip.field | ? name -eq  "sip.msg_hdr"
    $x_sip_body=$x_sip.field | ? name -eq  "sip.msg_body"

    #$x_sip_body.proto
                        
    $x_sip_sdp=$x_sip_body.proto | ? name -eq "sdp"

    $media_to_ip=""
    $media_type=""
    $media_to_port=""
    $media_attribute=@()


    [int]$i=0

    ForEach($sdp_field in $x_sip_sdp.field)
    {
        Write-Verbose ("Current Field: " + $sdp_field.name)
        

        Switch($sdp_field.name)
        {
            "sdp.version"
            {
                break;
            }
            "sdp.owner"
            {
                break;
            }
            "sdp.session_name"
            {
                break;
            }
            "sdp.connection_info"
            {
                #IP bestimmen
                $media_to_ip    = $sdp_field | % field | ? name -eq "sdp.connection_info.address" | % show
                
                #Bei jeder connection_info Zählen wir eins weiter
                $i++

                break;
            }
            "sdp.time"
            {
                break;
            }
            "sdp.media_attr"
            {
                #//XXX das muss noch anders implementiert werden
                #$media_attribute += $sdp_field.show
                break;
            }
            "sdp.media"
            {
                #Port bestimmen
                #Media Type kommt hier auch
                $media_type    = $sdp_field | % field | ? name -eq "sdp.media.media" | % show
                $media_to_port = $sdp_field | % field | ? name -eq "sdp.media.port"  | % show

                #Nach jedem "Media" geben wir ein Objekt zurück
                #if($i -gt 0){

                Write-Verbose("---------------------------------------------------")
                Write-Verbose ("media_to_ip: " + $media_to_ip)
                Write-Verbose ("media_type: " + $media_type)
                Write-Verbose ("media_to_port: " + $media_to_port)
                Write-Verbose ("media_attribute: " + $media_attribute)
                    
                $ssrc=""
                $payload_type=""
                #Nach RTP Stream suchen
                #Nur den ersten Frame finden
                if($media_to_ip -ne "" -and $media_to_port -gt 0)
                {

                    Write-Verbose("tshark Filter: rtp and ip.dst == $media_to_ip and udp.port == $media_to_port and frame > $current_framenumber")
                    [string]$result=tshark -2 -r $pcap.FullName  -Y "rtp and ip.dst == $media_to_ip and udp.port == $media_to_port and frame > $current_framenumber " -T fields -e "rtp.ssrc" -e "rtp.p_type" -E "separator=," | Select-Object -First 1
    
                    if($result){
                        Write-Verbose ("tshark result: " + $result)
                        $vals=$result.Split(",")
                        $ssrc=$vals[0]
                        #Payload ist meistens 8 (PCMA A-Law)
                        $payload_type=$vals[1]
                    }
                }

                Write-Verbose ("ssrc: " + $ssrc)
                Write-Verbose ("payload_type: " + $payload_type)
                Write-Verbose("---------------------------------------------------")


                New-Object -TypeName PSObject -Property ([ordered]@{
                    sip_call_id = ($x_sip_header | % field | ? name -eq "sip.Call-ID" | % show) ;
                    frame = $current_framenumber;
                    media_start_time = $current_timestamp;
                    media_to_ip = $media_to_ip;
                    media_type = $media_type;
                    media_to_port = $media_to_port;
                    media_attribute = $media_attribute;
                    ssrc = $ssrc;
                    payload_type = $payload_type;
                })

                #Daten zurücksetzen
                #$media_to_ip=""
                $media_type=""
                $media_to_port=""
                #$media_attribute=@()
                $ssrc=""
                $payload_type=""

                #}


                break;
            }


        }

    }

    #Zum Schluss müssen wir das letzte Objekt zurückgeben
    <#
    Write-Verbose("---------------------------------------------------")
    Write-Verbose ("media_to_ip: " + $media_to_ip)
    Write-Verbose ("media_type: " + $media_type)
    Write-Verbose ("media_to_port: " + $media_to_port)
    Write-Verbose ("media_attribute: " + $media_attribute)
    

    #Nach RTP Stream suchen
    #Nur den ersten Frame finden

    if($media_to_ip -ne "" -and $media_to_port -gt 0)
    {

        Write-Verbose("tshark Filter: rtp and ip.dst == $media_to_ip and udp.port == $media_to_port and frame > $current_framenumber")
        [string]$result=tshark -2 -r $pcap.FullName  -Y "rtp and ip.dst == $media_to_ip and udp.port == $media_to_port and frame > $current_framenumber " -T fields -e "rtp.ssrc" -e "rtp.p_type" -E "separator=," | Select-Object -First 1
    
        if($result){
            Write-Verbose ("tshark result: " + $result)
            $vals=$result.Split(",")
            $ssrc=$vals[0]
            #Payload ist meistens 8 (PCMA A-Law)
            $payload_type=$vals[1]
        }
    }

    Write-Verbose ("ssrc: " + $ssrc)
    Write-Verbose ("payload_type: " + $payload_type)
    Write-Verbose("---------------------------------------------------")

    New-Object -TypeName PSObject -Property ([ordered]@{
        sip_call_id = ($x_sip_header | % field | ? name -eq "sip.Call-ID" | % show) ;
        frame = $current_framenumber;
        media_start_time = $current_timestamp;
        media_to_ip = $media_to_ip;
        media_type = $media_type;
        media_to_port = $media_to_port;
        media_attribute = $media_attribute;
        ssrc = $ssrc;
        payload_type = $payload_type;
    })
    #>
    #Daten zurücksetzen
    $media_to_ip=""
    $media_type=""
    $media_to_port=""
    $media_attribute=@()
    $ssrc=""
    $payload_type=""



}



Function Voip-Get-SipAudioStream
{
<#
.SYNOPSIS
    Holt sich Audio Stream Files aus PCAP
.DESCRIPTION

    NOTIZ:
    Das hier macht dass ich die RAW Payload in "test.raw" drin habe

    $pcap=Get-Item 2017-04-18_11-30-38_longtrace_call_2017-04-18_11-34-25_172.25.8.3.pcap
    [xml]$pdml=tshark -2 -r $pcap.FullName -Y "rtp and udp.dstport == 27908 and ip.dst == 172.25.8.3" -T pdml
    ($pdml.pdml.packet.proto | ? name -eq "rtp" | % field | ? name -eq "rtp.payload").value | % {$_ | Convert-HexStringToByteArray} | Set-Content -Path test.raw -Encoding Byte

#>
    param
    (
        #PcapFile: Files (Get-Item) aus denen Audio Streams zurückgeliefert werden
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $PcapFile,

        $CallID=""
    )

    Begin {}

    Process {
        $PcapFile=Get-Item $PcapFile

        $PcapFile | ForEach-Object{
            $pcap=$_


            #[xml]$pdml=tshark -2 -r $pcap.FullName  -Y "sip" -T pdml
            #[xml]$pdml=tshark -2 -r $pcap.FullName -T pdml

            $pdml=Voip-Get-SipPDML -pcap $pcap
            if($CallID -ne ""){
                $sip_calls=Voip-Get-SipCall -PcapFile $pcap -pdml $pdml -CallID $CallID
            }
            else {
                $sip_calls=Voip-Get-SipCall -PcapFile $pcap -pdml $pdml
            }

            
            #Pro SIPCall suchen wir die Media Verbindungen raus
            $sip_calls | ForEach-Object {
                $sip_call=$_ 
                #$sip_call
                Write-Verbose ("Media für Sip-Call-ID: "+$sip_call.sip_callid)

                $pdml.pdml.packet | 
                    Where-Object {
                        $_.proto.field.proto.name -eq "sdp" `
                        -and `
                        ($_ | %{$_.proto.field.field} | ? name -eq "sip.Call-ID" | %{$_.show}) -eq $sip_call.sip_callid
                        

                    } | 
                    ForEach-Object{
                        #Hier gehen wir durch alle SDP Packets EINER CallID
                        $packet=$_

                        <#
                        sdp_media_connections
                        Das ist mindestens ein Audiostrom den ein Host erwartet
                        kann aber auch ein Audio ein Video usw sein
                        Der andere Host kommt dann mit dem nächsten Schleifendurchlauf
                        #>
                        $sdp_media_connections=Voip-Get-SDPMediaConnections -packet $packet -pcap $pcap
                        $sdp_media_connections

                        
                   }
                
            }

        }
    
    }

    End {}

}


Function Voip-Get-SipAudioStreamFile
{
<#
.SYNOPSIS
    Holt sich Audio Stream Files aus PCAP
.DESCRIPTION

    NOTIZ:
    Das hier macht dass ich die RAW Payload in "test.raw" drin habe

    $pcap=Get-Item 2017-04-18_11-30-38_longtrace_call_2017-04-18_11-34-25_172.25.8.3.pcap
    [xml]$pdml=tshark -2 -r $pcap.FullName -Y "rtp and udp.dstport == 27908 and ip.dst == 172.25.8.3" -T pdml
    ($pdml.pdml.packet.proto | ? name -eq "rtp" | % field | ? name -eq "rtp.payload").value | % {$_ | Convert-HexStringToByteArray} | Set-Content -Path test.raw -Encoding Byte

#>

    param
    (
        #PcapFile: Files (Get-Item) aus denen Audio Stream Files extrahiert werden
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $PcapFile
    )


    Begin {}
    
    Process {
        $PcapFile=Get-Item $PcapFile
        
        $PcapFile | ForEach-Object{
            $pcap=$_
            
            $target_dir=New-Item -Path ($pcap.Directory.FullName + "\" + $pcap.BaseName) -ItemType Directory -ErrorAction SilentlyContinue
            $target_dir=Get-Item ($pcap.Directory.FullName + "\" + $pcap.BaseName)
                

            #//XXX hier weiter
            #Hierher bekomme ich die Audiostream Metadaten
            Voip-Get-SipAudioStream -PcapFile $pcap | ? ssrc -ne "" | ForEach-Object {
                $stream=$_

                $stream

                $ssrc=$stream.ssrc
                $dstip=$stream.media_to_ip
                $dstport=$stream.media_to_port

                Write-Host ("Wireshark Filter: " + "rtp.ssrc == $ssrc")
                
                $raw_target_path=($target_dir.FullName + "/" + (Get-Date $stream.media_start_time -Format "yyyy-MM-dd_mm-hh-ss") + "_ToIP" + $stream.media_to_ip + "_Port"+ $stream.media_to_port + "_" + $stream.media_type + "_Payload" + $stream.payload_type + ".raw")

                tshark -2 -r $pcap.FullName -Y "rtp.ssrc == $ssrc and ip.dst == $dstip and udp.dstport == $dstport" -T fields -e "rtp.payload" |
                    Where-Object {
                        $_ -ne ""
                     } | % { $_ |Convert-HexStringToByteArray} | 
                        Set-Content -Path $raw_target_path -Encoding Byte
                
                <#
                [xml]$pdml=tshark -2 -r $pcap.FullName -Y "rtp.ssrc == $ssrc" -T pdml
                ($pdml.pdml.packet.proto | ? name -eq "rtp" | % field | ? name -eq "rtp.payload").value | % {$_ | Convert-HexStringToByteArray} | 
                Set-Content -Path ($target_dir.FullName + "/" + (Get-Date $stream.media_start_time -Format "yyyy-MM-dd_mm-hh-ss") + "_" + $stream.media_to_ip + "_" + $stream.media_type + "_" + $stream.payload_type + ".raw") -Encoding Byte
                #>

                $file=Get-Item $raw_target_path

                #Wenn wir den Codec kennen, dann bauen wir gleich noch den Header dran
                Switch($stream.payload_type){
                    #8: PCMA 8000 Hz Ulaw Mono
                    8 {
                        ffmpeg -y -f alaw -ar 8000 -ac 1 -i $file.FullName -codec copy ($target_dir.FullName + "/" +$file.BaseName+".wav")
                        break;
                    }
                }

            }


        }
    }

    End {}

}



Function Voip-Get-RTPStreamFile {
<#
.SYNOPSIS
    Holt sich alle Media Streams aus PCAP
#>  

    param
    (
        #PcapFile: Files (Get-Item) aus denen Audio Stream Files extrahiert werden
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)
        ]
        $PcapFile,

        [Switch]$Ports
    )

    Begin {}
    
    Process {
        $PcapFile=Get-Item $PcapFile

        $PcapFile | ForEach-Object{
            $pcap=$_
            $target_dir=New-Item -Path ($pcap.Directory.FullName + "\" + $pcap.BaseName) -ItemType Directory -ErrorAction SilentlyContinue
            $target_dir=Get-Item ($pcap.Directory.FullName + "\" + $pcap.BaseName)

            $a_ssrc=@()
            $a_files=@()

            tshark -2 -r $pcap.FullName -Y "rtp" -T fields -e "frame.time_epoch" -e "ip.src" -e "udp.srcport" -e "ip.dst" -e "udp.dstport" -e "rtp.p_type" -e "rtp.ssrc" -e "rtp.payload" -E "separator=," |
                ForEach-Object {
                    $tline=$_
                    $vals=$tline.Split(",")

                    #Write-Host ("line: "+$tline)

                    $time    =$vals[0]
                    $timestr = Get-Date (Convert-UnixTimestampToDatetime $time) -Format "yyyy-MM-dd_HH-mm-ss-fff"
                    $srcip   =$vals[1]
                    $srcport =$vals[2]
                    $dstip   =$vals[3]
                    $dstport =$vals[4]
                    $ptype   =$vals[5]
                    $ssrc    =$vals[6]
                    $payload =$vals[7]

                    if($a_ssrc.ssrc -notcontains $ssrc)
                    {
                        $h_ssrc=@{
                            "ssrc"=$ssrc;
                            "timestr"=$timestr;
                        }
                        $a_ssrc+=$h_ssrc
                    }
                    else
                    {
                        $h_ssrc=$a_ssrc | ? ssrc -eq $ssrc
                        $timestr=$h_ssrc.timestr
                    }

                    if($Ports)
                    {
                        $target_file=$target_dir.FullName + "\$timestr--Src-$srcip-$srcport-Dst-$dstip-$dstport-Payload-$ptype-SSRC-$ssrc.raw"
                    }
                    else
                    {
                        $target_file=$target_dir.FullName + "\$timestr--Src-$srcip-Dst-$dstip-Payload-$ptype-SSRC-$ssrc.raw"
                    }
                    
                    
                    #Write-Host("File: " +$target_file)
                    
                    
                    if($a_files.file -notcontains $target_file)
                    {
                        $h_file=@{
                            "file"=$target_file;
                            "ptype"=$ptype;
                        }
                        $a_files+=$h_file

                        if(Test-Path -Path $target_file){
                            Clear-Content -Path $target_file
                        }

                    }

                    if($payload -ne ""){
                        $payload | ? $_ -ne "" | % { $_ |Convert-HexStringToByteArray} | Add-Content -Path $target_file -Encoding Byte
                    }
                }

            ForEach($file in $a_files)
            {
                $o_file=Get-Item $file.file
                $o_file | Add-Member -MemberType NoteProperty -Name "PayloadTypeID" -Value $file.ptype
                $o_file

                #Umwandeln wenn es ein bekannter Payload ist
                if($file.ptype -eq "8"){
                    ffmpeg -y -f alaw -ar 8000 -ac 1 -i $o_file.FullName -codec copy ($target_dir.FullName + "/" +$o_file.BaseName+".wav") 2>&1 | Write-Verbose
                }
            }

        }
    }

    End{}
}