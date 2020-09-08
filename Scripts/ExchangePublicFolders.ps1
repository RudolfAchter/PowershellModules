


<#
$target_mb_dbs[0]
$mbdb_count=$target_mb_dbs.Count
42 % 20
#>


#########################################
#DAS HIER GEHT LIVE!!
#########################################
$target_mb_dbs=Get-MailboxDatabase | Sort-Object -Property Name |Where-Object {$_.Name -like "DB??"}
$mbdb_count=$target_mb_dbs.Count
$i=0
$adgroup_count=(Get-ADGroup -SearchBase "OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de" -Filter "*" -Properties Description).Count

Get-ADGroup -SearchBase "OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de" -Filter "*" -Properties Description | Sort-Object -Property Name <#| Select-Object -First 2#>  | ForEach-Object {
    $adGroup=$_
    $targetMBDB=$target_mb_dbs[($i % $mbdb_count)]
    $mbName= $adGroup.Name + "-PublicFolderMailbox"

    $progress_percent=$i / $adgroup_count * 100
    Write-Progress -Activity "Checking Public Folder Access Permissions" -Status "Public Folder $i of $adgroup_count" -PercentComplete $progress_percent

    $mailbox=Get-Mailbox -PublicFolder -Identity $mbName -ErrorAction SilentlyContinue

    if($null -eq $mailbox){
        Write-Host("Create PublicFolder Mailbox for Team " + $adGroup.Name + " on MBDB " + $targetMBDB.Name + " on Server " + $targetMBDB.Server + " Named " + $mbName)
        New-Mailbox -PublicFolder -Database $targetMBDB.Name -Name $mbName -OrganizationalUnit "OU=Public-Folders,OU=Microsoft Exchange Security Groups,DC=ads,DC=uni-passau,DC=de"
        $publicFolder=New-PublicFolder -Mailbox $mbName -Name $adGroup.Name -Path "\"
        
        #Standard Client Permissions auf "Keine" setzen. Aber nur beim Neu erstellen
        $clientPermissions=$publicFolder | Get-PublicFolderClientPermission -User Standard

        $clientPermissions | ForEach-Object {
            Remove-PublicFolderClientPermission -Identity $_.Identity -User Standard -Confirm:$false
        }

    }
    else{
        $publicFolder=Get-PublicFolder ("\" + $adGroup.Name)
        Write-Host("Public Folder " + $publicFolder.Name + " already exists")
    }

    #Gruppenmitglieder synchron halten

    $clientPermissions=$publicFolder | Get-PublicFolderClientPermission
    #Alle ADUser prüfen ob diese noch Mitglied in der Gruppe sind
    $permissionAdUsers=$clientPermissions.User | Where-Object {$null -ne $_.ADRecipient} | %{Get-ADUser $_.AdRecipient.DistinguishedName}
    $groupMembers=$adGroup | Get-ADGroupMember | Get-ADUser | ?{$_.Enabled -eq $true}

    #Zu löschende Mitglieder prüfen
    ForEach($member in $permissionADUsers){
        if($member.SID -notin $groupMembers.SID){
            #Entfernen
            Write-Host("Remove " + $member.DistinguishedName + " from " + $publicFolder.Name)
            Remove-PublicFolderClientPermission -Identity $publicFolder.Identity -User $member.distinguishedName -Confirm:$false
        }
        else{
            Write-Host($member.DistinguishedName + " is member in " + $adGroup.Name)
        }
    }


    #Hinzuzufügende Mitglieder prüfen
    ForEach($member in $groupMembers){
        if($member.SID -notin $permissionAdUsers.SID){
            $publicFolder | Add-PublicFolderClientPermission -User $member.distinguishedName -AccessRights PublishingEditor | ForEach-Object {
                Write-Host ("Add User "+ $member.distinguishedName + " : " + $_.AccessRights -join ",")
            }
        }
        else{
            Write-Host ("User "+ $member.distinguishedName + " already has access to " + $publicFolder.Name)
        }
    }

    $i++
}
#########################################
#ENDE DAS HIER GEHT LIVE!!
#########################################

#zkk@uni-passau.de