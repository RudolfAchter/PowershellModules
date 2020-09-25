<#
Created:	 2015-02-22
Edit by RAC: 2018-09-17
Version:	 1.0
Author:      Peter Löfgren
Extended By: Rudolf Achter <rudolf.achter@megatech-communication.de>
Homepage:    http://syscenramblings.wordpress.com

Disclaimer:
This script is provided "AS IS" with no warranties, confers no rights and 
is not supported by the authors or DeploymentArtist.

Author - Peter Löfgren
    Twitter: @LofgrenPeter
    Blog   : http://syscenramblings.wordpress.com
#>

$global:SignatureTemplatesPath="\\file.megatech.local\ALLE\ALLGEMEIN\Vorlagen\E-Mail-Signatur"


$global:ad_a_load_properties=@(
    'name',
    'sn',
    'givenName',
    'displayName',
    'middleName',
    'telephoneNumber',
    'title',
    'facsimileTelephoneNumber',
    'mobile',
    'company',
    'streetAddress',
    'postalCode',
    'l',
    'co',
    'mail',
    'postOfficeBox',
    'distinguishedName',
    'roomNumber'
    'photo'
)

for($i=1;$i -le 15; $i++){
    $global:ad_a_load_properties+='extensionAttribute'+[string]$i
}


Function Get-ADUser-from-DirectorySearcher {
<#
.SYNOPSIS
    Liefert einen ADUser mit Hilfe der .Net Klasse System.DirectoryServices.DirectorySearcher
    Somit wird Get-ADUser aus den RSAT Tools nicht benötigt
.PARAMETER UserName
    samAccountName des Users
#>
    param(
        $UserName
    )

    $Searcher = New-Object System.DirectoryServices.DirectorySearcher


    $a_load_properties=$global:ad_a_load_properties
        

    ForEach($prop in $a_load_properties){
        $result=$Searcher.PropertiesToLoad.Add($prop)
    }


    #$SearchUserEmail=$UserName+"@"+$Domain


    $Filter = "(&(objectCategory=User)(samAccountName=$UserName))"
    $Searcher.Filter = $Filter

    $ADUserPath = $Searcher.FindOne()
    $ADUser = $ADUserPath.GetDirectoryEntry()

    $ADPhone = $ADUser.telephoneNumber -replace '(\+49)([0-9]{4})([0-9]{4})([0-9]{3})','$1 $2 $3 - $4'

    $ADUser | Add-Member -MemberType NoteProperty -Name "telephoneNumberPrettyPrint" -Value $ADPhone -Force

    $ADUser

}

Function Get-ADUser-SignatureProperties {
<#
.SYNOPSIS
    Liefert die Properties eines Users die für eine E-Mail Signatur verwendet werden können
.DESCRIPTION
    Standardmäßig werden die Werte für die E-Mail-Signatur des aktuell angemeldeten Users angezeigt
    Als Parameter kann ein anderer User übergeben werden
.PARAMETER UserName
    User dessen Werte angezeigt werden sollen (samAccountName)
.PARAMETER Domain
    Domain in der wir arbeiten (bei uns Standardmäßig megatech-communication.de)
#>
    param(
        $UserName=$env:username
    )
    
    $a_show_props=@(
        'name',
        'sn',
        'givenName',
        'displayName',
        'middleName',
        'telephoneNumber',
        'telephoneNumberPrettyPrint',
        'title',
        'facsimileTelephoneNumber',
        'mobile',
        'company',
        'streetAddress',
        'postalCode',
        'l',
        'co',
        'mail',
        'postOfficeBox',
        'distinguishedName',
        'roomNumber'
        
    )

    for($i=1;$i -le 15; $i++){
        $a_show_props+='extensionAttribute'+[string]$i
    }


    $user=Get-ADUser-from-DirectorySearcher -UserName $UserName

    $user | Select $a_show_props
        
}

Function Show-SignatureTemplate{
    param(
        $UserName=$env:username
    )

    $props=Get-ADUser-SignatureProperties -UserName $UserName

    $props.PSObject.Properties | ForEach-Object {
        "{0,-50}{1,-50}" -f ("{{"+$_.Name+"}}"), ($_.Value -join ";")
    }
}



Function Get-OutlookSignature{
<#
.SYNOPSIS
    Generiert E-Mail Signaturen anhand von HTML Templates die unter $SignatureTemplatesPath
    abgelegt sind
.PARAMETER User
    Für welchen User (samAccountName oder Email (der Teil vorm @)
.PARAMETER TargetPath
    Hier hin werden alle Files geschrieben (Fotos und HTML Dateien)
.PARAMETER SignatureTemplatesPath
    Von hier werden die Templates genommen. Als Namenskonvention haben die Templates:
    *.template.htm
#>
    [CmdletBinding()]
    param(
        [Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$true)]
        $User=$env:username,

        $TargetPath=$env:APPDATA+"\microsoft\signatures",
        $SignatureTemplatesPath=$global:SignatureTemplatesPath
    )


    Begin{
    
    }


    Process{

        $User | ForEach-Object{
            $UserName=$_

            #$UserPhoto = "Rudolf Achter.png"
            #$SignatureName = "MEGATECH Signature"
            #$SignatureNameWoPic = $SignatureName + " ohne Foto"
            #$DefaultSignature=$SignatureNameWoPic
            $ADUser=Get-ADUser-from-DirectorySearcher -UserName $UserName
            
            $ADGivenName = $ADUser.givenName
            $ADSurname = $ADUser.sn
            $ADTitle = $ADUser.Title
            #Telefonnummer für Menschen lesbar formatiert zurückgeben
            $AdPhone = $ADUser.telephoneNumber -replace '(\+49)([0-9]{4})([0-9]{4})([0-9]{3})','$1 $2 $3 - $4'

            #Create the actual file
            if (!(Test-Path -Path $TargetPath)){ mkdir $TargetPath}

            #Mein User Bild ablegen

            #Copy-Item -Path "$PSScriptRoot\$UserPhoto" -Destination $env:APPDATA\microsoft\signatures -Force
            $UserPhotoPath=($TargetPath+"\"+$ADUser.sAMAccountName + ".jpg")

            #Zur Sicherheit, falls jemand möchte, dass sein Foto gelöscht wird
            if(Test-Path $UserPhotoPath){
                Remove-Item $UserPhotoPath -Force
            }

            #Wir holen es IMMER neu vom Active Directory

            #ACHTUNG
            #Exchange Verwendet Standardmäßig "thumbnailPhoto"
            #Für unsere Signaturen verwenden wir hier "photo"
            $ADUser.photo | Set-Content -Path $UserPhotoPath -Encoding Byte

            #//XXX Error Handling wenn der User kein Bild hat
            $UserHasNoPhoto=$false
            Try{
                $UserPhoto=Get-Item $UserPhotoPath -ErrorAction Stop
            }
            Catch{
                #Wenn ein User kein Foto hat, dann darf diese Signatur nicht generiert werden
                
                Copy-Item ($SignatureTemplatesPath+"\Default\NoPic_M.jpg") ($UserPhotoPath) -Force
                $UserPhoto=Get-Item $UserPhotoPath
                $UserHasNoPhoto=$true
            }
            $UserPhotoFileName=ConvertTo-FileUri $UserPhoto.FullName



            ForEach($template in (Get-Item ($SignatureTemplatesPath +"\*.template.htm"))){
        
                $TemplateContent=Get-Content ($template.FullName)

                if($TemplateContent -match "{{UserPhotoFileName}}" -and $UserHasNoPhoto){
                    Write-Verbose ("$SearchUserEmail hat Kein Foto. Generierung der Foto Templates deaktiviert")
                }
                else{
                    [string]$templateName=$template.Name
        
                    $Match=$templateName | Select-String -Pattern '(.*)\.template\.htm'
                    $SignatureName="MEGATECH Signature " + $Match.Matches.Groups[1].Value
        

                    $Html=($TemplateContent) `
                        -replace "{{UserPhotoFileName}}",$UserPhotoFileName `
                        -replace "{{ADGivenName}}",$ADGivenName `
                        -replace "{{ADSurname}}",$ADSurname `
                        -replace "{{ADTitle}}",$ADTitle `
                        -replace "{{ADPhone}}",$AdPhone `
                        -replace "{{ADTitleEN}}",$ADUser.extensionAttribute1
                    <#
                        Alle ADAttribute können im Template verwendet werden
                        In der Form:
                        {{attributeName}}
                    #>
                    ForEach ($prop in $ADUser.PSObject.Properties){
                        if($prop.Value -ne $null){
                            #if($prop.Value.GetType().Name -eq "PropertyValueCollection" -or $prop.Value.GetType().Name -eq "String"){
                                #Für alle Properties durchführen
                                $TemplateVar=("{{"+$prop.Name+"}}")
                                Write-Verbose  ("Replace '$TemplateVar' with '"+$prop.Value+"'")
                                $Html=$Html -replace $TemplateVar, $prop.Value
                            #}
                        }
                    }

                    $TargetFile=$TargetPath+"\"+" $SignatureName $UserName.htm"        
                    $Html | Out-File $TargetFile -Force

                    New-Object -TypeName PSObject -Property ([ordered]@{
                                            Name = $SignatureName
                                            Html = $Html
                                            File = $TargetFile
                                        })
                }
            }
        }
    }

    End{}

}

<#
.SYNOPSIS
    Generiert eine Übersichtsseite mit allen generierten Signaturen
#>
Function Get-SignatureIndex {
    [CmdletBinding()]
    param(
        $BaseDN="OU=MEGATECH-Mitarbeiter,DC=MEGATECH,DC=local",
        [Parameter(Mandatory=$true)] $TargetPath,
        $SignatureTemplatesPath=$global:SignatureTemplatesPath
    )

    $users=Get-ADUser -SearchBase $BaseDN -Filter * -Properties * | Sort-Object -Property sn

    $user_count=($users | Measure-Object).Count

    $out=""
    $out+=@"
<html>
    <head>
        <style>
            body {
                font-family:Verdana,sans-serif
            }

            .signature_card {
                width:550px;
                height:350px;
                border:2px solid grey;
                margin:10px;
                padding:10px;
                float:left;
            }
        </style>
    </head>
    <body>
"@

    $i=0
    $users | ForEach-Object {
        
        $proc_percent=$i / $user_count * 100
        Write-Progress -Activity "Creating Signature Previews" -Status ("User $i of $user_count : "+ $user.displayName) -PercentComplete $proc_percent
        
        $user=$_

        $out+='<h1 style="clear:both">'+$user.displayName+'</h1>'

        $user.samAccountName | Get-OutlookSignature -TargetPath $TargetPath  | ForEach-Object {
            $o_signature=$_

        
            $out+='<div class="signature_card">'
            $out+='<span>'+ $o_signature.Name +'</span>'
            $out+='<hr/><br/>'
            $out+=$o_signature.Html
            $out+="</div>"
        }

        $i++
    }

    $out+=@"
    </body>
</html>
"@
    $TargetFile=($TargetPath + "\index.html")
    $out | Out-File -FilePath $TargetFile
    Get-Item $TargetFile
}

<#
.SYNOPSIS
    Generiert eine Übersichtsseite mit allen generierten Signaturen und zeigt diese an
#>
Function Show-SignatureIndex {
    [CmdletBinding()]
    param()
    Start-Process -FilePath (ConvertTo-FileUri(Get-SignatureIndex -TargetPath ($env:Temp+"\OutlookSignatureIndex")).FullName)
}

<#
//XXX Todo
es braucht hier was für TXT RTF Signaturen

* https://gallery.technet.microsoft.com/scriptcenter/Create-an-RTF-document-333dfe26
#>


Function Create-MyOutlookSignature {
<#
.SYNOPSIS
    Erstellt Outlook Signaturen anhand eigener ActiveDirectory Informationen.
.DESCRIPTION
    Es wird eine Signatur mit Foto und eine Signatur ohne Foto erstellt
    Als Default Signatur wird zunächst diese ohne Foto verwendet.
    Die Signaturen werden nicht erzwungen, der User kann also auch andere
    Signaturen verwenden.
    Das Foto wird aus dem Active Diretory Feld "thumbnailPhoto" verwendet
    Sollte für die E-Mail Signatur ein anderes Foto (evtl anders Formatiert) gewünscht werden,
    könnten wir uch das Attribut "photo" verwenden
.PARAMETER SetAsDefault
    Wenn gesetzt wird die Signatur ohne Foto als Default Signatur für neue Emails eingestellt
.PARAMETER SetAsDefaultAnswer
    Wenn auf true gesetzt, wird die Signatur ohne Foto als Default Signatur für Antworten eingestellt.
.PARAMETER SignatureTemplatesPath
    In diesem Verzeichnis liegen die Vorlagen für die Signaturen
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Outlook-Automation.psm1/Create-MyOutlookSignature
#>
    [CmdletBinding()]
    param(
        [switch]$SetAsDefault,
        [switch]$SetAsDefaultAnswer,
        $SignatureTemplatesPath=$global:SignatureTemplatesPath
    )

    $OutlookSignaturesPath=$env:APPDATA+"\microsoft\signatures"

    #Find the User and all values
    $UserName = $env:username

    Get-Item ($OutlookSignaturesPath+"\*.htm") | Where-Object {$_.Name -match "MEGATECH Signature *"} | Remove-Item -Force

    Get-OutlookSignature -User $UserName -TargetPath $OutlookSignaturesPath

    #Enforce embedded pictures in outlook
    if (!(Test-Path -Path HKCU:\Software\Microsoft\Office\15.0\Outlook\Options\Mail)) { New-Item -Path HKCU:\Software\Microsoft\Office\15.0\Outlook\Options\Mail -ItemType Directory -Force }
    New-ItemProperty HKCU:\Software\Microsoft\Office\15.0\Outlook\Options\Mail -Name 'Send Pictures With Document' -Value 1 -PropertyType 4 -Force
    if (!(Test-Path -Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\Mail)) { New-Item -Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\Mail -ItemType Directory -Force }
    New-ItemProperty HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\Mail -Name 'Send Pictures With Document' -Value 1 -PropertyType 4 -Force


    #Default Signatur und Default Reply setzen wenn gewünscht

    for($i=14;$i -le 16;$i++){
        
        $MailSettingsPath='HKCU:\Software\Microsoft\Office\'+ $i +'.0\Common\MailSettings'
        $OutlookSetupPath='HKCU:\Software\Microsoft\Office\'+ $i +'.0\Outlook\Setup\'

        if($SetAsDefault -or $SetAsDefaultAnswer){
            If(Test-Path ($OutlookSetupPath+"First-Run")){
                Remove-ItemProperty $OutlookSetupPath -Name 'First-Run'
            }
        }

        

        If(Test-Path $MailSettingsPath){

            if($SetAsDefault){
                #Set the signature as default for new mails
                New-ItemProperty $MailSettingsPath -Name 'NewSignature' -Value $DefaultSignature -PropertyType 'String' -Force
                #New-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\15.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force
                #New-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\16.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force
                #Remove-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\16.0\Common\MailSettings' -Name 'NewSignature'
            }
            if($SetAsDefaultAnswer){
                #Set the signature as default for reply mails
                New-ItemProperty $MailSettingsPath -Name 'ReplySignature' -Value $DefaultSignature -PropertyType 'String' -Force
                #New-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\15.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
                #Remove-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\15.0\Common\MailSettings' -Name 'ReplySignature'
                #New-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\16.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
                #Remove-ItemProperty HKCU:'\Software\Policies\Microsoft\Office\16.0\Common\MailSettings' -Name 'ReplySignature'

            }
        }
    
    }

}



function ConvertTo-FileUri {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    $SanitizedPath = $Path -replace "\\", "/" -replace " ", "%20"
    "file:///{0}" -f $SanitizedPath
}


#https://stackoverflow.com/questions/24044681/powershell-open-email-draft-with-signature


Function New-OutlookMail{
<#
.SYNOPSIS
    Verschickt eine E-Mail mit Outlook
.DESCRIPTION
    Zum verschicken der Mail wird deine lokal Instalierte Outlook Instanz verwendet.
    Wenn du eine Default Signatur für eine E-Mail eingestellt hast, wird diese Signatur verwendet
.PARAMETER Subject
    Der Betreff der Mail
.PARAMETER HTMLBody
    Inhalt der Mail als HTML Formatiert. ACHTUNG. Damit das korrekt funktioniert muss HTMLBody ein
    vollständig Formatiertes HTML Dokument sein
    Also
    <html>
        <head></head>
        <body>
            Inhalt
        </body>
    </html>
.PARAMETER FromAccount
    Von welchem Account soll die Mail verschickt werden. Funktioniert aber anscheinend nicht mit IMAP / POP3 Accounts
    mal testen ob es von einem Exchange Account funktioniert
.PARAMETER Send
    Switch zu versenden der Mail. Wenn "Send" nicht angegeben ist öffnet sich lediglich Outlook mit der
    E-Mail. Die E-Mail kann dann nochmal betrachtet und dann manuell versendet werden.  
.EXAMPLE
    #Über Wartungsarbeiten an einem ESX-Host informieren (z.B.)
    Get-VM | ? PowerState -eq "PoweredOn" | VIM-Get-VMValue | Select Name,Ansprechpartner,Applikation,Notes| ConvertTo-StyledHTML | New-OutlookMail -Subject "Test VMs werden pausiert"
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Outlook-Automation.psm1/New-OutlookMail
#>
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true, ValueFromPipeline=$true)]
        [string]$HTMLBody,
        [string]$Subject,
        $Recipients,
        [string]$FromAccount,
        [switch]$Send,
        [switch]$WithSignature
    )


    Begin{
        $a_html=@()
    }

    Process{
        $HTMLBody | ForEach-Object {
            $a_html+=$_
        }
    }

    End{

        #Start-Process Outlook 
        $o = New-Object -com Outlook.Application 
        $mail = $o.CreateItem(0) 

        $oOutlook = New-Object -ComObject Outlook.Application 
        $oMapiNs = $oOutlook.GetNameSpace("MAPI")
        $oMailMsg = $oOutlook.CreateItem(0)

        #Richtigen Absender Account einstellen
        if($null -ne $FromAccount){
            Write-Host("Setting FromAccount")
            $oAccount=$oOutlook.Session.Accounts.Item($FromAccount)
            #//XXX hier weiter
            $oMailMsg.SendUsingAccount = $oOutlook.Session.Accounts.Item($FromAccount)#$oAccount
        }


        ForEach($recipient in $Recipients){
            [Void]$oMailMsg.Recipients.Add($recipient) 
        }


        $oMailMsg.GetInspector.Activate()

        $start=$oMailMsg.HTMLBody.IndexOf("<body")
        $end=$oMailMsg.HTMLBody.IndexOf("</body")

        $Bodytext=$oMailMsg.HTMLBody.Substring($start,($end-$start+7))
        $start=$Bodytext.IndexOf(">")
        $end=$Bodytext.LastIndexOf("</")
    
        $sSignature = $Bodytext.Substring($start+1,($end-$start-1))

        #Write-Host $sSignature
    

        
        if($WithSignature){
            #$oMailMsg.HTMLBody+=$sSignature
            $oMailMsg.HTMLBody=($a_html -join "") -replace '</body>',($sSignature+'</body>')
        }
        else{
            $oMailMsg.HTMLBody=$a_html -join ""
        }

        $oMailMsg.Subject=$Subject
    
        If($Send){
            $oMailMsg.Send()
        }


        #$o.Quit()
    }
    

}