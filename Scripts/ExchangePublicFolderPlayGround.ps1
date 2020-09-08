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


<#
Get-ADGroup -SearchBase "OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de" -Filter "*" -Properties Description | Select-Object -First 2 | ForEach-Object {
    $adGroup=$_
    New-DistributionGroup -OrganizationalUnit "OU=TeamDistributionGroups,OU=Microsoft Exchange Security Groups,DC=ads,DC=uni-passau,DC=de" -ModeratedBy $adGroup.Name -Members $adGroup.Name -Name $adGroup.name
}
#>