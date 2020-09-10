
$global:RepositoryPath = '\\ads\grp\S001\PSRepository'


<#
.EXAMPLE
 Create-PSRepository -RepoName 'MT-RAC'
#>
Function Create-PowershellRepository{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoName
    )

    $repo_path=$global:RepositoryPath + "\" + $RepoName

    if(-not (Test-Path $repo_path))
    {
        $new_dir=mkdir $repo_path
    }

    $repo = @{
        Name = $RepoName
        SourceLocation = $repo_path
        PublishLocation = $repo_path
        InstallationPolicy = 'Trusted'
    }
    $new_repo=Register-PSRepository @repo

    Get-PSRepository $repo.Name

}

<#
.EXAMPLE
 Get-PowershellRepository
#>
Function Get-PowershellRepository{
    [CmdletBinding()]
    param(

    )

    Get-ChildItem $global:RepositoryPath

}

<#
.EXAMPLE
 Get-PowershellRepository
#>
Function Register-PowershellRepository{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoName
    )

    $repo_path=$global:RepositoryPath + "\" + $RepoName

    $repo = @{
        Name = $RepoName
        SourceLocation = $repo_path
        PublishLocation = $repo_path
        InstallationPolicy = 'Trusted'
    }
    $new_repo=Register-PSRepository @repo

    Get-PSRepository $repo.Name
}



Function Publish-PowershellModule {
<#
.SYNOPSIS
    Publiziert ein Powershell Modul nach Megatech Standard
.PARAMETER Module
    Name des Moduls (wie in Get-Module angezeigt)
.PARAMETER RepositoryName
    Name des Repositories an das Publiziert wird
.PARAMETER Description
    Beschreibung des Moduls. Beim ersten Publizieren muss die Description gesetzt werden
    bei einem Update kann man diesen Parameter weg lassen
.PARAMETER MajorRelease
    Ist dieser Switch gesetzt wird das Major Release um eins hoch gesetzt
    Minor Release fängt dann wieder bei 0 zu zählen an
.PARAMETER FunctionsExportToDefault
    Sorgt dafür dass einfach ALLE Funktionen exportiert werden
.PARAMETER NoDocument
    Normalerweise werden alle CMDlets des Moduls im Wiki dokumentiert.
    Mit diesem Switch wird das umgangen. Das ist eine Zeitersparniss, wenn keine neuen
    CMDlets hinzu gekommen sind sondern nur ein paar kleinere Bugfixes publiziert werden
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$false)]
        [string]$Module,

        [Parameter(Mandatory=$true)]
        $RepositoryName,

        $Description=$null,
        [switch]
        $MajorRelease,

        [switch]$FunctionsExportToDefault,
        [ValidateSet("markup","mediawiki")]
        $DocumentFormat="markup",
        [switch]$NoDocument
    )

    $repo_path=$global:RepositoryPath + "\" + $RepositoryName

    if(-not (Test-Path $repo_path)){
        Write-Error("Repository $RepositoryName nicht in " + $global:RepositoryPath + " gefunden" )
        return
    }


    Import-Module $Module -Force
    $o_module=Get-Module $Module

    $module_dir=(Get-Item $o_module.Path).PSParentPath
    $module_name=(Get-Item $module_dir).Name

    $current_aduser=Get-ADUser -LDAPFilter ('(samAccountName='+ $env:USERNAME +')') -Properties mail

    $author_string=$current_aduser.Name + ' <' + $current_aduser.mail + '>'

    if(-not $NoDocument){
        Document-PowershellModule -Module $module_name -Format $DocumentFormat
    }

    #Existiert schon ein Manifest
    if(Test-Path ($module_dir + "\" + $module_name + ".psd1")){
        
        #$o_module.Version.Minor

        if($MajorRelease){
            #Beim Major Release müssen wir die Minor auf 0 zurück setzen
            #z.B. 1.4, 2.0, 2.5, 3.0
            $new_version=New-Object System.Version -ArgumentList ([string]($o_module.Version.Major + 1) + "." +"0")
        }
        else{
            $new_version=New-Object System.Version -ArgumentList ([string]($o_module.Version.Major) + "." +[string]($o_module.Version.Minor+1))
        }


        $manifest_path=($module_dir + "\" + $module_name + ".psd1")

        $manifest_update=@{
            Path = $manifest_path
            RootModule = ($module_name + ".psm1")
            Author = $author_string
            ModuleVersion = $new_version
        }

        if($Description -ne $null){
            $manifest_update.Add("Description",$Description)
        }


        if($FunctionsExportToDefault){
            $manifest_update.Add("FunctionsToExport",'*')
        }
        
        #Manifest Updaten
        $manifest_content=Update-ModuleManifest @manifest_update -PassThru
        $manifest_content | Set-Content $manifest_path -Encoding UTF8
            
    }
    else{
        #Neues Manifest
        New-ModuleManifest -Path ($module_dir + "\" + $module_name + ".psd1") `
            -RootModule ($module_name + ".psm1") `
            -Author $author_string `
            -Description $Description `
            -FunctionsToExport '*'
            
    }

    Publish-Module -Path $module_dir -Repository $RepositoryName
    
    Import-Module $Module -Force
    Get-Module $Module
}


Function ConvertTo-MediawikiPsHelp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)]
        $Help
    )

    Begin{
            $crlf="`r`n"
            $pg="`r`n`r`n"
            $br="<br/>`r`n"
    }

    Process{
        $Help | ForEach-Object {
            $o_help=$_
            
            
            [string]$out=''+$crlf

            $out+='= Powershell Inline kommentierte Doku =' + $pg

            $out+='== Name ==' + $crlf
            $out+=$o_help.Name + $br
            $out+='Modul: [[Scripts/Powershell/'+ $o_help.ModuleName +'.psm1|' + $o_help.ModuleName + ']]' + $pg


            $out+='== Übersicht ==' + $crlf
            $out+=$o_help.Synopsis + $pg

            $out+='== Beschreibung ==' + $crlf
            $out+=($o_help.description | Out-String ) + $pg -replace $crlf,('<br/>'+$crlf)

            <#
            $out+='== Syntax ==' + $crlf
            $out+=($o_help.syntax | Out-String)
            #>

            #Parameter

            $i=0

            if($o_help.parameters.parameter.Count -gt 0){

                $out+='== Parameter ==' + $crlf
                $out+='{| class="wikitable"' + $crlf

                $o_help.parameters.parameter | ForEach-Object {
                    $param=$_
                
                    if($i -gt 0){$out+='|-'+$crlf}
                
                

                    $out+='|valign="top"|'+$param.Name + $crlf
                    $out+='|'+($param.description | Out-String)+$crlf

                        $out+='{|'+$crlf
                        $out+='|Erforderlich:||'+$param.required+$crlf
                        $out+='|-'+$crlf
                        $out+='|Position:||'+$param.position+$crlf
                        $out+='|-'+$crlf
                        $out+='|Standardwert:||'+$param.defaultValue+$crlf
                        $out+='|-'+$crlf
                        $out+='|Pipeline Eingaben akzeptieren:||'+$param.pipelineInput+$crlf
                        $out+='|-'+$crlf
                        $out+='|Platzhalterzeichen akzeptieren:||'+$param.globbing+$crlf
                        $out+='|}'+$crlf
                
                    $i++
                }

                $out+='|}'+$pg

            }

            


            $out+='== Eingaben ==' + $crlf
            
            $out+=$o_help.inputTypes.inputType.type.name + $pg

            $out+='== Ausgaben ==' + $crlf
            $out+=$o_help.returnValues.returnValue.type.name + $pg

            
            #Beispiele

            $i=0
            if($o_help.examples.example.Count -gt 0){
                $out+='== Beispiele ==' + $crlf
                $o_help.examples.example | ForEach-Object {
                    $o_example=$_
                
                    $out+="'''Beispiel "+($i+1) + "'''" +$pg

                    $out+='<syntaxhighlight lang="powershell">'+$crlf
                    $out+=$o_example.code + $crlf + ($o_example.remarks | Out-String) + $crlf
                    $out+='</syntaxhighlight>' + $pg
                    $i++

                }
            }

            if($o_help.relatedLinks.navigationLink.uri.Count -gt 0){

                $out+='== Verwandte Links ==' + $crlf

                $o_help.relatedLinks.navigationLink.uri | ForEach-Object {
                    $o_uri=$_
                    $out+='*' + $o_uri + $crlf
                }
            }

            $out
        }
    }

    End{

    }
    
}


Function Document-PowershellModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)]
        $Module,
        [ValidateSet("mediawiki","markup")]
        $Format="markup",
        $SubpagePrefix="Scripts/Powershell/"
    )

    Begin{
        $a_module_names=@()
    }

    Process{
        $Module | ForEach-Object {
            if($_.GetType().Name -eq "String"){
                $a_module_names+=$_
            }
            elseif($_.GetType().Name -eq "PSModuleInfo"){
                $a_module_names+=$_.Name
            }
            else{
                Write-Error ($_ + " kann nicht als Powershell Modul (PSModuleInfo) interpretiert werden!")
            }
        }
    }

    End{
        $a_module_names | ForEach-Object {
            $s_module=$_


            Get-Command -Module $s_module | ForEach-Object {
                $o_command=$_

                $module_file_name=(Get-Item (Get-Module -Name $s_module).Path).Name

                Switch($Format){
                    "mediawiki"{
                        $page_title=$SubpagePrefix + $module_file_name + "/" + $o_command.Name
                        #//XXX Todo ConvertTo-MediawikiPsHelp Funktioniert noch nicht so gut
                        #$help_text=Get-Help -Name $o_command.Name | ConvertTo-MediawikiPsHelp #| Out-String
                        $help_text="<pre>`r`n"
                        $help_text+=Get-Help -Name $o_command.Name -Full | Out-String
                        $help_text+="`r`n</pre>"
                        $summary=("Powershell Automated Manual. Module: $module_file_name Command: "+$o_command.Name)

                        Set-WikiPageFragment -title $page_title -tag div -tag_id powershell_automated_man -content $help_text
                        break;
                    }
                    "markup"{
                        $s_module_dir=(Get-Item (Get-Module -Name $s_module).Path).PSParentPath

                        if(-not (Test-Path ($s_module_dir+"\docs"))){
                            mkdir ($s_module_dir+"\docs")
                        }

                        $file_path=($s_module_dir+"\docs\"+$o_command.Name+".md")

                        $help_text='```' + "`r`n"
                        $help_text+=Get-Help -Name $o_command.Name -Full | Out-String
                        $help_text+='```' + "`r`n"

                        Set-Content -Path $file_path -Value $help_text -Encoding UTF8
                        
                        break;
                    }
                }

                #Write-Host ("Editing Page: $page_title - Summary: $summary")
                #Edit-Page -title $page_title -text $out -summary $summary
                

            }
        }
    }
}