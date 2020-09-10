```

NAME
    Get-XML-from-ExcelData
    
ÜBERSICHT
    Holt Daten aus einer Excel Tabelle und generiert Metadaten oder XML Daten anhand eines Templates
    
    
SYNTAX
    Get-XML-from-ExcelData [[-ExcelFocus] <Object>] [[-Template] <Object>] [<CommonParameters>]
    
    
BESCHREIBUNG
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
    
    Get-XML-from-ExcelData -ExcelFocus mydata.xlsx -Template my_xml_template.xml | Out-File -FilePath data_out.xml 
    -Encoding utf8
    

PARAMETER
    -ExcelFocus <Object>
        Dateiname der offenen Excel Datei (Das was Im Title deines Excel Fenster steht9
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 $global:current_excel_doc_name
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -Template <Object>
        Pfad zu deinem Template (xml Datei oder dergleichen)
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>Get-XML-from-ExcelData -ExcelFocus tns_user_data.xlsx -Template tns_user_template.xml | Out-File -FilePath 
    out_data.xml -Encoding utf8
    
    
    
    
    
    
    
VERWANDTE LINKS



```

