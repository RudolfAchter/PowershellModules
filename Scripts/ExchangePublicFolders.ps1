<# Public Folders #>
$clientPermissions=Get-PublicFolder -GetChildren | Where-Object {$_.ParentPath -eq "\" -and $_.Name -match "[A-Z]{1}[0-9]{3}"} | Get-PublicFolderClientPermission -User Standard

$clientPermissions | ForEach-Object {
    Remove-PublicFolderClientPermission -Identity $_.Identity -User Standard -Confirm:$false
}


Get-MailboxDatabase | ForEach-Object {
    $o_db=$_
    $o_dbFile=Get-Item $o_db.EdbFilePath.DriveName

    $o_db | Add-Member -MemberType NoteProperty -Name Size -Value $o_dbFile.Length
    $o_db | Select Name,Server,Size
}


Get-MailboxDatabase -Status | fl *


$remote_session=New-PSSession -ComputerName MSXPO1 -Credential $adCredentials

Invoke-Command -Session $remote_session -ScriptBlock { Get-PSDrive }



Get-PublicFolder "\Public" -GetChildren


New-PublicFolder -Name S001-PublicFolder -Mailbox S001-PublicFolderMailbox
New-PublicFolder -Name S002-PublicFolder -Mailbox S002-PublicFolderMailbox


$target_mb_dbs=Get-MailboxDatabase | Sort-Object -Property Name |Where-Object {$_.Name -like "DB??"}

<#
$target_mb_dbs[0]
$mbdb_count=$target_mb_dbs.Count
42 % 20
#>

$i=0

Get-ADGroup -SearchBase "OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de" -Filter "*" -Properties Description | Sort-Object -Property Name | Select-Object -First 5  | ForEach-Object {
    $adGroup=$_
    $targetMBDB=$target_mb_dbs[($i % $mbdb_count)]
    $mbName= $adGroup.Name + "-PublicFolderMailbox"

    Write-Host("Create PublicFolder Mailbox for Team " + $adGroup.Name + " on MBDB " + $targetMBDB.Name + " on Server " + $targetMBDB.Server + " Named " + $mbName)

    

    New-Mailbox -PublicFolder -Database $targetMBDB.Name -Name $mbName -OrganizationalUnit "OU=Public-Folders,OU=Microsoft Exchange Security Groups,DC=ads,DC=uni-passau,DC=de"

    New-PublicFolder -Mailbox $mbName -Name $adGroup.Name -Path "\"



    $i++
}


#zkk@uni-passau.de