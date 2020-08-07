$global:current_excel_doc_name=""
$global:current_excel_sheet_name=""
$global:current_excel_mode="CurrentOpenExcel"
$global:current_excel_application=""


Function Get-ExcelTable {
<#
.SYNOPSIS
    Holt aus Excel eine Tabelle aus einem Tabellen Blatt
    Eine Tabelle die auch als Tabelle formatiert wurde.
    Das zu liefernde Excel Tabellenblatt kann mit
    mit dem CMDlet Set-ExcelFocus "fokussiert" werden
.DESCRIPTION
    Aktuell verbindet sich diese Funktion mit einer bereits laufenden
    Excel Instanz.
    Es ist denkbar diese Funktion so zu programmieren, dass man wahlweise
    eine bereits offene Excel Instanz verwenden kann oder eine gespeicherte
    Excel Datei öffnet.
    Die zurückgelieferten Daten werden als Powershell Objekt Array zurückgeliefert
    die Properties der Objekte bestehen aus den Excel Tabellen Spalten
.PARAMETER DocName
    Dateiname der offenen Excel Datei.
    Oder Pfad zur zu öffnenden Excel Datei (im Mode "File")
.PARAMETER SheetName
    Tabellenblatt in dem nach einer Tabelle gesucht werden soll. Hier können 
    Wildcards verwendet werden z.B..
    VIB-*
    gibt dann alle Tabellen Blätter zurück die mit VIB-* beginnen.
    Die Tabellen sollten dann alle das gleiche Format haben (gleiche Spalten)
    weil die Tabellen dann für Powershell zu einer Tabelle zusammengefügt werden
.PARAMETER Mode
    [ValidateSet("CurrentOpenExcel","File")]
    Es gibt diese Modi
        CurrentOpenExcel:   die Daten werden aus einer Tabelle der gerade geöffneten Excel Instanz geladen
        File:               die angegebene Excel Datei wird geöffnet und die Daten daraus entnommen
.INPUTS
    keine Pipe Inputs
.OUTPUTS
    Array aus Powershell Objekten. Properties sind die Spalten der Excel Tabelle
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/ExcelData.psm1/Get-ExcelTable
.EXAMPLE
    #tns_user_data.xlsx muss in Excel geöffnet sein
    Get-ExcelTable -DocName 'tns_user_data.xlsx' -SheetName 'user'
.EXAMPLE
    Get-ExcelTable -Mode File -DocName 'L:\RAC\ToDo\2019-02-14 RZ Hann\tns_user_data.xlsx' -SheetName 'user'
.EXAMPLE
    Get-ExcelTable -Mode File -DocName 'L:\RAC\ToDo\2019-02-14 RZ Hann\tns_user_data.xlsx' -SheetName 'user' | Out-GridView
.EXAMPLE
    Get-ExcelTable -Mode File -DocName 'L:\RAC\ToDo\2019-02-14 RZ Hann\tns_user_data.xlsx' -SheetName 'user' | Format-Table -AutoSize
#>
    [CmdletBinding()]
    param(
        [Alias('Path')]
        [string]$DocName=$global:current_excel_doc_name,
        [string]$SheetName=$global:current_excel_sheet_name,
        [ValidateSet("CurrentOpenExcel","File")]
        [string]$Mode=$global:current_excel_mode,
        [switch]$NoValidate
    )
    
    Begin{

    }

    Process{}

    End{
        If($DocName -eq "" -or $SheetName -eq ""){
            Write-Error("Kein Excel Dokument Fokussiert. Wähle zu erst mit Set-ExcelFocus ein Dokument, dass du in Excel geöffnet hast")
            return
        }

        Switch($Mode){
            "CurrentOpenExcel"{
                #Excel Workbook aus geradem laufendem Excel öffnen
                $global:current_excel_application = [Runtime.Interopservices.Marshal]::GetActiveObject('Excel.Application')
                $o_excel = $global:current_excel_application
                $workbook=$o_excel.workbooks | ?{$_.Name -eq $DocName}

                #//XXX man könnte hier noch versuchen, wenn das offene Excel nicht gefunden wurde, stattdessen einfach das File zu öffnen
                #muss ich mir noch überlegen

                If(-not $workbook){
                    Write-Error("Excel Dokument '"+$DocName +"' nicht gefunden")
                }


                break
            }
            "File"{
                
                #Wir starten ein neues Excel wenn wir noch kein Excel haben
                if($global:current_excel_application -eq "" -or $global:current_excel_application.Application -eq $null){
                    $global:current_excel_application=New-Object -ComObject 'Excel.Application'
                }
                #Wenn wir Excel schon gestartet haben, verwenden wir das bereits gestartete Excel

                #Excel Workbook aus einer gespeicherten Datei öffnen
                #$o_excel=New-Object -ComObject 'Excel.Application'
                $o_excel=$global:current_excel_application

                $o_file=Get-Item $DocName

                $workbook=$o_excel.Workbooks.Open($o_file.FullName)
            }
        }

        $sheets=$workbook.Sheets | ?{$_.Name -like $SheetName}

        $excel_file=Get-Item $workbook.FullName
        $validate_file_path=((Get-Item $excel_file.PSParentPath).FullName + "\" + $excel_file.BaseName + ".validateSet.xml")

        #Wenn ein validateSet vorhanden ist und $NoValidate NICHT gesetzt ist, dann
        #validieren wir laut dem validateSet
        if((Test-Path $validate_file_path) -and (-not $NoValidate)){
            $do_validate=$true
            #Und wir laden auch gleich das validate File
            [xml]$validate_xml=Get-Content $validate_file_path
        }
        else{
            $do_validate=$false
        }



        If(-not $sheets){
            Write-Error("Sheet '"+$SheetName +"' nicht gefunden")
        }
        
        #Diese Objekte will ich ausgeben
        $a_objects_out=@()
        #Das hier hängt von der "Validation" ab
        #Wenn die "Validation" fehlschlägt dann $return_objects auf $false setzen
        $validation_success=$true

        $sheets | ForEach-Object {
            $sheet=$_
            #$sheets | Select Name
            #$sheets.ListObjects | Get-Member
            $colnames=$sheet.ListObjects.Item(1).ListColumns | %{$_.Name}
            
            ForEach($row in $sheet.ListObjects.Item(1).DataBodyRange.Rows){
                $object=New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name Sheet -Value $sheet.Name
                
                if($do_validate){
                    Write-Host("Validating row: "+ ($row.Value2 -join " | "))
                }

                $j=0
                ForEach($col_val in $row.Value2){
                    #//XXX ToDo
                    #Spaltenwert Laut geladenem Validate Set validieren
                    if($do_validate){
                        #//XXX Hier könnte ich noch nach einem $mode Unterscheiden
                        #$mode könnte sein:
                        #  - Regex
                        #  - Script
                        #  - Cmdlet
                        #  - usw...

                        #Erst mal gehe nur nur nach RegEx "pattern"
                        $cur_pattern=$validate_xml.SelectSingleNode("//sheet[@name='"+ $SheetName +"']//columns//column[@name='" + $colnames[$j] + "']").pattern
                        if($cur_pattern -ne $null){
                            if($col_val -match $cur_pattern){
                                Write-Host($colnames[$j]+ ": '" + $col_val + "' Matches") -ForegroundColor Green
                            }
                            else{
                                Write-Host($colnames[$j]+ ": '" + $col_val + "' Does NOT Match") -ForegroundColor Red
                                $validation_success=$false
                            }
                        }
                    }

                    #Spaltenwert wird dem Objekt hinzugefügt
                    $object | Add-Member -MemberType NoteProperty -Name $colnames[$j] -Value $col_val -Force
                    $j++
                }

                $a_objects_out+=$object
            }
        }

        
        #//XXX das brauch ich später
        if($validation_success){
            $a_objects_out
        }
        else{
            $false
            Write-Error("Errors in Document Validation. No Values are returned")
        }
        #>

        #$a_objects_out

        #Wenn wir eine Datei geöffnet hatten müssen wir diese auch wieder schließen
        if($Mode -eq "File"){
            $workbook.Saved=$true
            $workbook.Close()
            #$o_excel.Application.Quit()
        }

    }
}


Function Set-ExcelFocus {
<#
.SYNOPSIS
    Setzt den Focus von Excel auf ein Dokument und bestimmte Tabellenblätter
    (Sheet Angabe mit Wildcard (*) möglich)
.PARAMETER DocName
    Name des Dokuments das Fokussiert werden soll. Das Dokument muss mit dem selben
    User, in dem diese Powershell Instanz läuft, in Excel geöffnet sein
.PARAMETER SheetName
    Name des Sheets innerhalb des Excel Dokuments. Es wird die erste Tabelle
    (also wirklich als Tabelle Formatierte Tabelle) selektiert die in diesem
    Sheet gefunden wird
.PARAMETER Mode
    [ValidateSet("CurrentOpenExcel","File")]
    Es gibt diese Modi
        CurrentOpenExcel:   die Daten werden aus einer Tabelle der gerade geöffneten Excel Instanz geladen
        File:               die angegebene Excel Datei wird geöffnet und die Daten daraus entnommen
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] $DocName,
        [Parameter(Mandatory=$true)] $SheetName,
        [ValidateSet("CurrentOpenExcel","File")]
        [Parameter(Mandatory=$false)] $Mode=$global:current_excel_mode
    )

    $global:current_excel_doc_name=$DocName
    $global:current_excel_sheet_name=$SheetName
    $global:current_excel_mode=$Mode
}


Function Get-ExcelFocus{
<#
.SYNOPSIS
    Zeig das Fokussierte Dokument und Sheet an, das mit Set-ExcelFocus focussiert wurde
#>
    New-Object -TypeName PSObject -Property ([ordered]@{
            DocName = $global:current_excel_doc_name
            SheetName  = $global:current_excel_sheet_name
        })
}


Function Set-ExcelTableValidation {
<#
.SYNOPSIS
    Setzt eine Validation Regel für eine Spalte in einem Excel Sheet
.DESCRIPTION
    Für die angesprochene Excel Datei wird eine Datei Namens
    <Dateiname>.validateSet.xml angelegt. In dieser XML-Datei werden
    die Regeln für die Validierung der Excel Datei angelegt.

    Excel Data kann mit einer Tabelle pro Sheet umgehen, mehr geht
    aktuell leider nicht. Das sollte in der Regel aber meist ausreichen

    Set-ExcelTableValidation kann für jede Spalte im Excel einmal ausgeführt werden
    somit kann für jede Spalte eine Regel gespeichert werden.
    Aktuell werden nur Regular Expressions unterstützt
    Als "pattern" gibtst du somit eine Regular Expression an die auf die Spalte angewandt wird
    Solange die Regular Expression auf die gesamte Spalte "matched" sind die Daten valide

    Sollte die Regular Expression einmal nicht zutreffen, werden die Daten als INvalide deklariert
    und Get-ExcelTable gibt keine Daten mehr zurück
.PARAMETER DocName
    Dateiname der offenen Excel Datei.
    Oder Pfad zur zu öffnenden Excel Datei (im Mode "File")
.PARAMETER SheetName
    Tabellenblatt in dem nach einer Tabelle gesucht werden soll.
.PARAMETER Mode
    [ValidateSet("CurrentOpenExcel","File")]
    Es gibt diese Modi
        CurrentOpenExcel:   die Daten werden aus einer Tabelle der gerade geöffneten Excel Instanz geladen
        File:               die angegebene Excel Datei wird geöffnet und die Daten daraus entnommen
.PARAMETER Column
    Spalte für die eine Regel festgelegt werden soll
.PARAMETER Pattern
    Pattern. In diesem Fall die Regular Expression die für die Spalte festgelegt werden soll
.PARAMETER Type
    Für spätere Weiterentwicklung. Aktuell IMMER "RegEx"
.PARAMETER NoAutoCompletion
    Die Regular Expression wird immer um den Anfang und das Ende ergänzt (da dies gern vergessen wird)
    Es wird immer so Ergänzt:
    
        ^RegEx$

    Dies führt dazu, dass der GESAMTE Wert in der Spalte der Regular Expression entsprechen muss anstatt nur
    ein Teilstring. Würde man z.B. nur nach einer Ziffer suchen 

        [0-9]+

    würde die Regel zutreffen, wenn nur IRGENDEINE Ziffer im String vorkommen würde z.B.:

        blaBlubb7Blubb
    
    das ist nicht Hilfreich wenn ich sicherstellen will, dass NUR Ziffern im String vorkommen.
    Sollte die Auto Vervollständigung mit ^ und $ nicht gewünscht sein kannst du das eben
    mit diesem NoAutoCompletion Schalter ausschalten
#>
    [CmdletBinding()]
    param(
        [Alias('Path')]
        [string]$DocName=$global:current_excel_doc_name,
        [string]$SheetName=$global:current_excel_sheet_name,
        [ValidateSet("CurrentOpenExcel","File")]
        [string]$Mode=$global:current_excel_mode,
        [Parameter(Mandatory=$true)]
        [string]$Column,
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        [ValidateSet("RegEx")]
        [string]$Type="RegEx",
        [switch]$NoAutoCompletion
    )
    
    Begin{}
    
    Process{}
    
    End{
        
        #Ein RegEx ergänze ich in der Regel von ANFANG bis ENDE
        if((-not $NoAutoCompletion) -and $Type -eq "Regex"){
            $Pattern='^'+$Pattern+'$'
        }

        $first_object=Get-ExcelTable -DocName $DocName -SheetName $SheetName -Mode $Mode -NoValidate | Select-Object -First 1

        $excel_file=Get-Item ($global:current_excel_application.Workbooks | ?{$_.Name -eq $DocName}).FullName
        $validate_file_path=((Get-Item $excel_file.PSParentPath).FullName + "\" + $excel_file.BaseName + ".validateSet.xml")


        If(-not (Test-Path $validate_file_path)){
        #Wenn das Validate File noch nicht existiert, erstellen wir es neu


            [xml]$xml=@"
<?xml version="1.0" encoding="UTF-8"?>
<ValidateSet>
</ValidateSet>
"@
            #Sheet erstellen
            $node=$xml.CreateNode("element","sheet","")
            $attr=$xml.CreateAttribute("name")
            $attr.Value=$SheetName
            $node.Attributes.Append($attr)

            $xml.DocumentElement.AppendChild($node) | Out-Null
        
            #Columns erstellen
            $node=$xml.CreateNode("element","columns","")
            $xml.SelectSingleNode("//sheet[@name='" + $SheetName + "']").AppendChild($node) | Out-Null

            #In Columns

            ForEach($prop in $first_object.PSObject.Properties){

                $node=$xml.CreateNode("element","column","")

                $attr=$xml.CreateAttribute("name")
                $attr.Value=$prop.Name
                $node.Attributes.Append($attr) | Out-Null

                $xml.SelectSingleNode("//sheet[@name='" + $SheetName + "']//columns").AppendChild($node) | Out-Null
            }

            $xml.Save($validate_file_path)

        }
        else{

            #Wenn das Validate File bereits existiert dann überprüfen wir, ob alle Spalten existieren
            #Fehlende Spalten müssen wir ergänzen
            #Evtl auch gelöschte Spalten wieder entfernen (braucht noch etwas Logik)

            [xml]$xml=Get-Content $validate_file_path


            #Sicherstellen, dass das Sheet existiert
            #Wenn der Sheet Node Nicht existiert
            if($xml.ValidateSet.SelectSingleNode("//sheet[@name='" + $SheetName + "']") -eq $null){

                #Sheet erstellen
                $node=$xml.CreateNode("element","sheet","")
                $attr=$xml.CreateAttribute("name")
                $attr.Value=$SheetName
                $node.Attributes.Append($attr)
                #Sheet anhängen
                $xml.DocumentElement.AppendChild($node) | Out-Null

                #Columns erstellen
                $node=$xml.CreateNode("element","columns","")
                $xml.SelectSingleNode("//sheet[@name='" + $SheetName + "']").AppendChild($node) | Out-Null


            }
            
            #Die Spalte "Sheet" wird generiert, weil das ein zusätzliches Property der Excel Objekte ist
            ForEach($prop in $first_object.PSObject.Properties){
                #Sicherstellen, dass alle Spalten existieren
                #Wenn die Spalte nicht existiert
                if($xml.ValidateSet.SelectSingleNode("//sheet[@name='" + $SheetName + "']//columns//column[@name='" + $prop.Name + "']") -eq $null){
                    #Dann die Spalte anlegen
                    $node=$xml.CreateNode("element","column","")
                    $attr=$xml.CreateAttribute("name")
                    $attr.Value=$prop.Name
                    $node.Attributes.Append($attr) | Out-Null
                    
                    #$xml.ValidateSet.columns.AppendChild($node)
                    $xml.ValidateSet.SelectSingleNode("//sheet[@name='" + $SheetName + "']//columns").AppendChild($node) | Out-Null
                }

            }


            $xml.Save($validate_file_path)

        }
        


        [xml]$validate_xml=Get-Content $validate_file_path

        $attr=$validate_xml.CreateAttribute("pattern")
        $attr.Value=$Pattern
        
        Write-Host("Setting Validation for Column: '"+ $Column +"' Pattern: '"+ $Pattern +"'")
        $validate_xml.SelectSingleNode("//sheet[@name='" + $SheetName + "']//columns//column[@name='$Column']").Attributes.SetNamedItem($attr) | Out-Null

        $validate_xml.Save($validate_file_path)

    }    
}

Function Get-ExcelTableValidation {
<#
.SYNOPSIS
    Zeigt die für die aktuelle Excel Tabelle gespeicherten Validation Sets
.PARAMETER DocName
    Dateiname der offenen Excel Datei.
    Oder Pfad zur zu öffnenden Excel Datei (im Mode "File")
.PARAMETER SheetName
    Tabellenblatt in dem nach einer Tabelle gesucht werden soll.
#>
    [CmdletBinding()]
    param(
        [Alias('Path')]
        [string]$DocName=$global:current_excel_doc_name,
        [string]$SheetName=$global:current_excel_sheet_name
        )

    $excel_file=Get-Item ($global:current_excel_application.Workbooks | ?{$_.Name -eq $DocName}).FullName
    $validate_file_path=((Get-Item $excel_file.PSParentPath).FullName + "\" + $excel_file.BaseName + ".validateSet.xml")

    [xml]$validate_xml=Get-Content $validate_file_path

    #Select gehört evtl erweitert. Erst mal reichts
    $validate_xml.SelectSingleNode("//sheet[@name='" + $SheetName + "']").columns.column | Select name,pattern
}