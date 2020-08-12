
Function Get-XML-from-ExcelData {
<#
.SYNOPSIS
    Holt Daten aus einer Excel Tabelle und generiert Metadaten oder XML Daten anhand eines Templates
.DESCRIPTION
    Im Template wird vorgegeben wie die zu generierenden Daten aussehen sollen.
    Das einzige Feature das implementiert ist ist bis jetzt die Funktion %ForEach Das sieht dann so aus:

    Du hast z.B ein xml

    <xml>
        <items>
            <item>
                <prop1>Data</prop1>
                <prop2>Data</prop2>
                <prop3>Data</prop3>
            </item>
        </items>
    </xml>

    Bereite dies so vor:

    <xml>
        <items>
            <!-- %ForEach item BEGIN -->
            <item>
                <prop1>{{prop1}}</prop1>
                <prop2>{{prop2}}</prop2>
                <prop3>{{prop3}}</prop3>
            </item>
        </items>
        <!-- %ForEach item END -->
    </xml>

    Erstelle dann ein Excel Tabelle mit diesen Spalten
    Benenne das Sheet als "item" (genauso wie nach %ForEach angegeben)

    * prop1
    * prop2
    * prop3

    Deine Tabelle sieht dann z.B. so aus

    prop1	    prop2	    prop3
    ---------   ----------  ----------
    Item eins	daten eins	daten eins
    Item zwei	daten zwei	daten zwei
    Item drei	daten drei	datem drei

    Formatiere diese Tabelle WIRKLICH als Tabelle 
    (Benutze das Feature "Als Tabelle Formatieren in Excel")
    Die Tabelle hat Header? -> JA!

    Wenn du das vorbereitet hast kannst du z.B. so etwas machen

    Get-XML-from-ExcelData -ExcelFocus mydata.xlsx -Template my_xml_template.xml | Out-File -FilePath data_out.xml -Encoding utf8
.PARAMETER ExcelFocus
    Dateiname der offenen Excel Datei (Das was Im Title deines Excel Fenster steht9
.PARAMETER Template
    Pfad zu deinem Template (xml Datei oder dergleichen)
.EXAMPLE
    Get-XML-from-ExcelData -ExcelFocus tns_user_data.xlsx -Template tns_user_template.xml | Out-File -FilePath out_data.xml -Encoding utf8
#>
    param(
        $ExcelFocus=$global:current_excel_doc_name,
        $Template
    )

    #$ExcelFocus="tns_user_data.xlsx"
    #$Template="tns_user_template.xml"

    $template_lines=Get-Content $Template

    [string]$s_template=$template_lines -join "`r`n"

    #//XXX START dieser Abschnitt hier muss ein bisschen anders werdden
    # Nicht nur Regex sondern Zeilenstart und Zeilen Ende merken

    $match_pattern='((.|\n)*)?<!--\s*%(ForEach) ([^\s]+)(.*) (BEGIN) -->((.|\n)*)<!--\s*%(ForEach) ([^\s]+)(.*) (END) -->((.|\n)*)?'

    $match=$s_template | Select-String -Pattern $match_pattern


    #Aber Prinzipiell kann ich diese Variablen hier verwenden

    $str_before=$match.Matches.Groups[1].Value
    $action_name=$match.Matches.Groups[3].Value
    $item_name=$match.Matches.Groups[4].Value
    $action_content=$match.Matches.Groups[7].Value
    $str_after=$match.Matches.Groups[13].Value


    Switch($action_name){
        "ForEach" {
            
            #Daten vor dem Abschnitt ausgeben
            $str_before

            $excel_data=Get-ExcelTable -DocName $ExcelFocus -SheetName $item_name

            #NUR wenn wir gültige Excel Daten bekommen haben
            if($excel_data){
                           
                #Das hier führen wir für jede Zeile im Excel durch
                $excel_data | ForEach-Object {
                    $current_content=$action_content

                    $data=$_
                    ForEach($prop in $data.PSObject.Properties){
                        $current_content=$current_content -replace ("{{"+ $prop.Name + "}}"),([System.Security.SecurityElement]::Escape($prop.Value))
                    }
                    #Verändertes XML / Metadaten ausgeben
                    $current_content
                }

            }

            #Daten nach dem Abschnitt ausgeben
            $str_after

            break
        }
    }


}