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
Function Get-OutlookSignature{
    [CmdletBinding()]
    param(
        [Parameter(
        Position=0, 
        Mandatory=$true, 
        ValueFromPipeline=$true)]
        $User,

        $TargetPath=$env:APPDATA+"\microsoft\signatures",
        $SignatureTemplatesPath=$global:SignatureTemplatesPath
    )


    Begin{
    
    }


    Process{

        $User | ForEach-Object{
            $UserName=$_

            #$UserPhoto = "Rudolf Achter.png"
            $SignatureName = "MEGATECH Signature"
            $SignatureNameWoPic = $SignatureName + " ohne Foto"
            $DefaultSignature=$SignatureNameWoPic

            $SearchUserEmail=$UserName+"@megatech-communication.de"


            $Filter = "(&(objectCategory=User)(|(samAccountName=$UserName)(mail=$SearchUserEmail)))"
            $Searcher = New-Object System.DirectoryServices.DirectorySearcher
            $Searcher.Filter = $Filter
            $ADUserPath = $Searcher.FindOne()
            $ADUser = $ADUserPath.GetDirectoryEntry()
            $ADDisplayName = $ADUser.DisplayName
            $ADGivenName = $ADUser.givenName
            $ADSurname = $ADUser.sn
            $ADTitle = $ADUser.Title
            $ADMobile = $ADUser.Mobile
            $ADFax = $ADUser.facsimileTelephoneNumber
            #Telefonnummer für Menschen lesbar formatiert zurückgeben
            $AdPhone = $ADUser.telephoneNumber -replace '(\+49)([0-9]{4})([0-9]{4})([0-9]{3})','$1 $2 $3 - $4'
            $AdCompany = $ADUser.company
            $AdStreet = $ADUser.streetAddress
            $AdZip = $ADUser.postalCode
            $AdLocation = $ADUser.l
            $AdCountry = $ADUser.co
            $ADemail = $ADUser.mail
            $ADBox = $ADUser.postOfficeBox


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
                        {{ADattr:attributeName}}
                    #>
                    ForEach ($prop in $ADUser.PSObject.Properties){
                        if($prop.Value -ne $null){
                            if($prop.Value.GetType().Name -eq "PropertyValueCollection"){
                                #Für alle Properties durchführen
                                $TemplateVar=("{{ADattr:"+$prop.Name+"}}")
                                Write-Verbose  ("Replace '$TemplateVar' with '"+$prop.Value+"'")
                                $Html=$Html -replace $TemplateVar, $prop.Value
                            }
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
Function Create-MyOutlookSignature {
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
.PARAMETER Send
    Switch zu versenden der Mail. Wenn "Send" nicht angegeben ist öffnet sich lediglich Outlook mit der
    E-Mail. Die E-Mail kann dann nochmal betrachtet und dann manuell versendet werden.  
.LINK
    http://wiki.megatech.local/mediawiki/index.php/Scripts/Powershell/Outlook-Automation.psm1/New-OutlookMail
#>
Function New-OutlookMail{
    [CmdletBinding()]
    param(
        [Parameter( Mandatory=$true, ValueFromPipeline=$true)]
        [string]$HTMLBody,
        [string]$Subject,
        $Recipients,
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
    
        ForEach($recipient in $Recipients){
            [Void]$oMailMsg.Recipients.Add($recipient) 
        }

        If($Send){
            $oMailMsg.Send()
        }


        #$o.Quit()
    }
    

}