$global:MailStyle=@"
body {
 padding-top: 80px;
 text-align: left;
 font-family: Arial, Helvetica, sans-serif;
 font-size:12px;
}
h1, h2 {
 display: inline-block;
 background: #fff;
}
h1 {
 
}
h2 {
 
}



table.content,table.content th,table.content td {
 border: 1px solid black;
 border-collapse: collapse;
}
table.content {
 
}
table.content th {
 background: #ddd;
}
table.content th, table.content td {
 padding: 5px;
}
table.content td {
 padding: 5px;
 border-bottom: 1px solid #ddd;
 border-left: 1px solid #ddd;
 border-right: 1px solid #ddd;
}
table.content tr:nth-child(even) {
 background-color: #f2f2f2;
}
table.content td.even {
 background-color: #f2f2f2;
}
table.content tr:not(:first-child):hover {
 background-color:#8f1775;
 color:#ffffff;
}

"@

<#
.SYNOPSIS
    Erstellt HTML mit Stylesheet
.DESCRIPTION
    Nimmt Items aus der Pipe und formatiert diese mit dem übergebenen Stylesheet
    Wennn Objekte übergeben werden, werden diese in einer Tabelle Formatiert

    Wenn ein String übergeben wurde, wird davon ausgegangen, dass dies ein HTML String ist
    und dieses HTML wird mit dem Stylesheet Formatiert
.PARAMETER Item
    Zu übergebene Powershell Objekte
.PARAMETER Style
    String mit Stylesheet Definitionen
    Du kannst auch einen Style mit:
    Get-Content("DeinStylesheet.css")
    laden
#>
Function ConvertTo-StyledHTML {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true, ValueFromPipeline=$true)]
        $Item,
        [string]$Style=$global:MailStyle,
        [switch]$Fragment
    )

    Begin{
        $a_items=@()
    }

    Process{
        $Item | ForEach-Object {
            $a_items+=$_
        }
    }

    End{
        $out="<html>"+"`n"
        $out+="<head>"+"`n"
        $out+="<style>"+$Style+"</style>"+"`n"
        $out+="</head>"+"`n"
        $out+="<body>"
        
        $s_fragment=""
        if(($a_items | Select-Object -First 1).GetType().Name -eq "String"){
            $s_fragment+=$a_items -join ""
        }
        else{
            $s_fragment+=$a_items | ConvertTo-FormattedHTMLTable -Fragment
        }

        $out+=$s_fragment
        
        <#
        $a_tmp_items=@()
        $last_item_type=""

        ForEach($item in $a_items){
            if($item.GetType().Name -eq "String"){
                $out+=$item
            }
            else{
                #$out+=$item | ConvertTo-FormattedHTMLTable -Fragment
                if($last_item_type -eq $item.GetType().Name -or $last_item_type -eq ""){
                    $a_tmp_items+=$item
                }
                else{
                    $out+=$a_tmp_items | ConvertTo-FormattedHTMLTable -Fragment
                }
                $last_item_type=$item.GetType().Name
            }
        }
        #>

        $out+="</body>"+"`n"
        $out+="</html>"+"`n"

        if($Fragment){
            $s_fragment
        }
        else{
            $out
        }
    }
}


<#
.SYNOPSIS
    Erstellt aus den übergebenen Objekten eine Formatierte HTML Tabelle
    Hierbei sind die geraden und Ungeraden Zeilen mit den Klassen
    "even" und "odd" markiert.
.PARAMETER Item
    Übergebenes Powershell Objekt
.PARAMETER class
    Mit dieser Klasse wird das Tabellenobjekt markiert
#>
Function ConvertTo-FormattedHTMLTable {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true, ValueFromPipeline=$true)]
        $Item,
        $class="content",
        [switch]$Fragment

    )

    Begin{
        $a_items=@()
    }

    Process{
        $Item | ForEach-Object {
            $a_items+=$_
        }
    }

    End{
        [System.Xml.XmlDocument]$xml=$a_items | ConvertTo-Html -Fragment

        $attrib=$xml.CreateAttribute("class")
        $attrib.Value=$class

        $added=$xml.table.Attributes.Append($attrib)

        for($i=1; $i -le $xml.table.tr.Count; $i++){
            #Modulo 2
            
            $attrib=$xml.CreateAttribute("class")

            if($i % 2 -eq 0){
                $attrib.Value="even"
            }
            else{
                $attrib.Value="odd"
            }


            $added_node=$xml.table.SelectSingleNode("//tr["+$i+"]").Attributes.Append($attrib)

            for($j=1; $j -le $xml.table.tr[$i].td.Count; $j++){
                Write-Verbose ("i $i j $j")

                #Ich muss das Attribut für jede Zelle NEU erstellen
                #da sich das Attribut immer nur an EINEN Node hängen lässt
                #Wenn ich das Attribut Objekt wiederverwenden würde, würde es
                #Am alten Node verschwinden und zum neuen Node wandern
                $attrib=$xml.CreateAttribute("class")

                if($i % 2 -eq 0){
                    $attrib.Value="even"
                }
                else{
                    $attrib.Value="odd"
                }
                
                Try{
                    $added_node=$xml.table.SelectSingleNode("//tr["+$i+"]//td["+$j+"]").Attributes.Append($attrib)
                }
                Catch{
                }
            }
            
        }

        if(-not $Fragment){
        @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>HTML TABLE</title>
</head><body>
"@
        }

        $xml.OuterXml

        if(-not $Fragment){
        @"
</body></html>
"@
        }

    }

}