param(

    $PathToKeePassFolder = "C:\Program Files (x86)\KeePass Password Safe 2"
)
#Load all .NET binaries in the folder
(Get-ChildItem -recurse $PathToKeePassFolder|Where-Object {($_.Extension -EQ ".dll") -or ($_.Extension -eq ".exe")} | ForEach-Object { $AssemblyName=$_.FullName; Try {[Reflection.Assembly]::LoadFile($AssemblyName) } Catch{ }} ) | out-null


function KP-Open-Database(
    $DB,
    $Password="",
    $Keyfile=""
) 
{
    $global:PwDatabase = new-object KeePassLib.PwDatabase

    #Wenn Passwort gesetzt Datebank mit Passwort oeffnen
    if($Password -ne ""){
        $global:m_pKey = new-object KeePassLib.Keys.CompositeKey
        $global:m_pKey.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($Password)));

    }

    if($Keyfile -ne ""){
        $global:m_pKey = new-object KeePassLib.Keys.CompositeKey
        $global:m_pKey.AddUserKey((New-Object KeePassLib.Keys.KcpPassword($Password)));

    }

    $global:m_ioInfo = New-Object KeePassLib.Serialization.IOConnectionInfo
    $global:m_ioInfo.Path = $DB

    $global:IStatusLogger = New-Object KeePassLib.Interfaces.NullStatusLogger

    $global:PwDatabase.Open($global:m_ioInfo,$global:m_pKey,$global:IStatusLogger)

    
}


function KP-Find-Entry(
    $find="*"
)
<#
.SYNOPSIS
    Gibt das KeePass Password Item zurück das mittels $find gefunden wurde
.DESCRIPTION
    Der gelieferte Passwort Eintrag ist erst mal nicht lesbar
    um den Passwort Eintrag als Menschenlesbar anzuzeigen dann mit Pipe
    in KP-Get-PSObject-PWEntry Umleiten
.EXAMPLE
    KP-Find-Entry -find tkvcenter | KP-Get-PSObject-PWEntry | ft
.PARAMETER find
    String nach dem gesucht wird (ähnlich wenn man mit STRG + F in KeePass sucht)
#>
{
    $pwItems = $PwDatabase.RootGroup.GetObjects($true, $true)
    foreach($pwItem in $pwItems)
    {
        if (
                $pwItem.Strings.ReadSafe("Title") -like $find -or
                $pwItem.Strings.ReadSafe("UserName") -like $find -or
                $pwItem.Strings.ReadSafe("Host") -like $find -or
                $pwItem.Strings.ReadSafe("IP") -like $find -or
                $pwItem.Strings.ReadSafe("URL") -like $find
        
            )
        {
            $pwItem
        }
    }

}


function KP-Get-EntryByProperty(
    $property="",
    $value=""
)
<#
.SYNOPSIS
    Gibt das KeePass Password Item zurück bei dem "property" exakt dem gesuchten "value" entspricht
.DESCRIPTION
    Der gelieferte Passwort Eintrag ist erst mal nicht lesbar
    um den Passwort Eintrag als Menschenlesbar anzuzeigen dann mit Pipe
    in KP-Get-PSObject-PWEntry Umleiten
.EXAMPLE
    KP-Get-EntryByProperty -property Host -value tkvcenter | KP-Get-PSObject-PWEntry | ft
.PARAMETER property
    Zu vergleichende Eigenschaft
.PARAMETER value
    Wert mit dem verglichen wird
#>
{
    $pwItems = $PwDatabase.RootGroup.GetObjects($true, $true)
    foreach($pwItem in $pwItems)
    {
        if (
                $pwItem.Strings.ReadSafe($property) -eq $value
            )
        {
            $pwItem
        }
    }

}



function KP-Get-PSObject-PWEntry (
                                    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
                                    $pwItem
                                    ) 
{

    Begin {}

    Process {

        ForEach ($p in $pwItem){
        
            #$pwItem.Strings.ReadSafe("Password")
            #$pwItem.Strings
            $o_pw = New-Object -TypeName PSObject
            ForEach($h in $p.Strings.GetEnumerator()){
                #Write-Host "$($h.Key): $($h.Value)"
                Add-Member -InputObject $o_pw -MemberType NoteProperty -Name $($h.Key) -Value $p.Strings.ReadSafe($($h.Key))
            }
            $o_pw
        }
    }

    End {}
}

function KP-Add-Group {
    param(
        $Name,
        $Parent=""
    )

    if($Parent -eq ""){
        $o_parent=$PwDatabase.RootGroup
    }

    $o_group=New-Object KeePassLib.PwGroup

    $Name="TestGroup"
    $o_group.Name = $Name

    $o_parent.AddGroup($o_group,$false)


    if($global:pwDatabase.IsOpen){
        $global:pwDatabase.MergeIn($global:pwDatabase,[KeePassLib.PwMergeMethod]::Synchronize,$global:IStatusLogger)
        $global:pwDatabase.Save($global:IStatusLogger)
    }
}
