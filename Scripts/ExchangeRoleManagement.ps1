Function Set-ManageMyDistributionGroups{

    New-ManagementRole -Name "zimRAC-ManageMyDistributionGroups" -Parent "Distribution Groups"
    $allRoleEntries=Get-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\*"
    $RemoveRoleEntries=Get-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\*" | Where {$_.Name -ne "Get-Recipient" -and $_.Name -ne "Update-DistributionGroupMember" -and $_.Name -ne "Add-DistributionGroupMember" -and $_.Name -ne "Remove-DistributionGroupMember" -and $_.Name -notlike "Get-*Group*"}

    $RemoveRoleEntries | fl *

    $RemoveRoleEntries | %{Remove-ManagementRoleEntry -Identity "$($_.id)\$($_.name)" -Confirm:$false}


    Get-ManagementRoleEntry "Distribution Groups\*" | ?{$_.Name -like "Get-*"} | %{Add-ManagementRoleEntry -Identity "zimRAC-ManageMyDistributionGroups\$($_.name)"}


    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup" -Parameters Identity,ManagedBy,GrantSendOnBehalfTo,IgnoreNamingPolicy #WIESO??? Ingore Naming Policy setzt alles ausser Kraft. Ich darf dann alles ändern.Aber ohne IgnoreNamingPolicy wird GrantSendOnBehalfTo nicht freigeschaltet
    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup" -Parameters Identity,ManagedBy,GrantSendOnBehalfTo

    Remove-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup"
    #Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\GrantSendOnBehalfTo" -Parameters Identity,ManagedBGrantSendOnBehalfTo
    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup" -Parameters AcceptMessagesOnlyFrom,AcceptMessagesOnlyFromDLMembers,AcceptMessagesOnlyFromSendersOrMembers,BypassModerationFromSendersOrMembers,BypassNestedModerationEnabled,Confirm,Debug,DomainController,ErrorAction,ErrorVariable,ExpansionServer,ForceUpgrade,GrantSendOnBehalfTo,HiddenFromAddressListsEnabled,Identity,IgnoreNamingPolicy,MailTip,MailTipTranslations,ManagedBy,MaxReceiveSize,MaxSendSize,ModeratedBy,ModerationEnabled,OutBuffer,OutVariable,RejectMessagesFrom,RejectMessagesFromDLMembers,RejectMessagesFromSendersOrMembers,ReportToManagerEnabled,ReportToOriginatorEnabled,RequireSenderAuthenticationEnabled,RoomList,SendModerationNotifications,SendOofMessageToOriginatorEnabled,Verbose,WarningAction,WarningVariable,WhatIf

    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-Group" -Parameters Identity,ManagedBy

    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Get-DistributionGroup" -Parameters Anr,Credential,Debug,DomainController,ErrorAction,ErrorVariable,Filter,Identity,IgnoreDefaultScope,ManagedBy,OrganizationalUnit,OutBuffer,OutVariable,ReadFromDomainController,RecipientTypeDetails,ResultSize,SortBy,Verbose,WarningAction,WarningVariable

    Remove-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Add-DistributionGroupMember"
    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Add-DistributionGroupMember" -Parameters Identity,Member
    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Remove-DistributionGroupMember"

    Get-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Add-DistributionGroupMember"

    Remove-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup"
    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup" -Parameters GrantSendOnBehalfTo

    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup" -Parameters Confirm,Debug,DomainController,EmailAddresses,EmailAddressPolicyEnabled,ErrorAction,ErrorVariable,ForceUpgrade,GrantSendOnBehalfTo,HiddenFromAddressListsEnabled,Identity,IgnoreNamingPolicy,IgnoreDefaultScope,MailTip,MailTipTranslations,ManagedBy,ModeratedBy,OutBuffer,OutVariable,Verbose,WarningAction,WarningVariable,WhatIf,WindowsEmailAddress

    Add-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Set-DistributionGroup" -Parameters AcceptMessagesOnlyFrom,AcceptMessagesOnlyFromDLMembers,AcceptMessagesOnlyFromSendersOrMembers,Alias,BypassModerationFromSendersOrMembers,BypassNestedModerationEnabled,Confirm,CustomAttribute1,CustomAttribute10,CustomAttribute11,CustomAttribute12,CustomAttribute13,CustomAttribute14,CustomAttribute15,CustomAttribute2,CustomAttribute3,CustomAttribute4,CustomAttribute5,CustomAttribute6,CustomAttribute7,CustomAttribute8,CustomAttribute9,Debug,DisplayName,DomainController,EmailAddresses,EmailAddressPolicyEnabled,ErrorAction,ErrorVariable,ExpansionServer,ExtensionCustomAttribute1,ExtensionCustomAttribute2,ExtensionCustomAttribute3,ExtensionCustomAttribute4,ExtensionCustomAttribute5,ForceUpgrade,GrantSendOnBehalfTo,HiddenFromAddressListsEnabled,Identity,IgnoreDefaultScope,IgnoreNamingPolicy,MailTip,MailTipTranslations,ManagedBy,MaxReceiveSize,MaxSendSize,MemberDepartRestriction,MemberJoinRestriction,ModeratedBy,ModerationEnabled,Name,OutBuffer,OutVariable,PrimarySmtpAddress,RejectMessagesFrom,RejectMessagesFromDLMembers,RejectMessagesFromSendersOrMembers,ReportToManagerEnabled,ReportToOriginatorEnabled,RequireSenderAuthenticationEnabled,RoomList,SamAccountName,SendModerationNotifications,SendOofMessageToOriginatorEnabled,SimpleDisplayName,Verbose,WarningAction,WarningVariable,WhatIf,WindowsEmailAddress

    Remove-ManagementRoleEntry "zimRAC-ManageMyDistributionGroups\Get-DistributionGroup"


    New-RoleGroup -Name "zim-SelfManaged-DistributionGroupManagement" -Description "Members of this management role group can update the members of groups they are the managers of." -Roles "zimRAC-ManageMyDistributionGroups"

    Set-ManagementRoleAssignment "zimRAC-ManageMyDistributionGroups-SelfManaged-DistributionGroupM" -RecipientRelativeWriteScope MyDistributionGroups

    New-ManagementRoleAssignment -Role "Active Directory Permissions" -SecurityGroup "zim-SelfManaged-DistributionGroupManagement" -RecipientRelativeWriteScope MyDistributionGroups


    Get-ManagementRoleAssignment -RoleAssignee "zim-SelfManaged-DistributionGroupManagement" | Select Name,Role,RoleAssigneeName,RecipientWriteScope,CustomRecipientWriteScope

    Get-ManagementRoleAssignment -RoleAssignee "zim-SelfManaged-DistributionGroupManagement" -Role  "Active Directory Permissions" | Set-ManagementRoleAssignment -RecipientRelativeWriteScope MyDistributionGroups

    New-ManagementRoleAssignment -Role "View-Only Recipients" -SecurityGroup "zim-SelfManaged-DistributionGroupManagement"

    #| Remove-ManagementRoleEntry -Confirm:$false


}


Get-ManagementRoleAssignment -RoleAssignee "Help Desk"


New-ManagementRole -Name "zim-ManageMailboxQuota" -Description "Enables Management of Mailbox Quotas" -Parent "Mail Recipients"
#Get-ManagementRole -Identity "zim-ManageMailboxQuota" | Remove-ManagementRole


Get-ManagementRoleEntry "Mail Recipients\*"

Get-ManagementRoleEntry "zim-ManageMailboxQuota\*" | Where-Object {$_.Name -notlike "Get-*"} | %{Remove-ManagementRoleEntry -Identity "$($_.id)\$($_.name)" -Confirm:$false}

#Remove-ManagementRoleEntry "zim-ManageMailboxQuota\Set-Mailbox"
Add-ManagementRoleEntry "zim-ManageMailboxQuota\Set-Mailbox" -Parameters Identity,IssueWarningQuota,ProhibitSendQuota,ProhibitSendReceiveQuota,UseDatabaseQuotaDefaults

New-RoleGroup -Name "zim-MailboxQuotaManagement" -Description "Member of this management role group can set Quota Properties on Mailboxes." -Roles "zim-ManageMailboxQuota"
New-ManagementRoleAssignment -SecurityGroup "zim-MailboxQuotaManagement" -Role "View-Only Recipients"

Get-RoleGroup "zim-MailboxQuotaManagement" | fl *




Get-ManagementRoleAssignment zim-ManageMailboxQuota-zim-MailboxQuotaManagement | fl *


Set-Mailbox -IssueWarningQuota -ProhibitSendQuota -ProhibitSendReceiveQuota


<#

Get-ManagementRole
New-ManagementRole -Name "zim-ManageMySharedMailboxes" -Description "Enables Self Management for Shared Mailboxes" -Parent "Mail Recipients"
Get-ManagementRoleEntry "zim-ManageMySharedMailboxes\*"

Get-ManagementRoleEntry "zim-ManageMySharedMailboxes\*" | Where-Object {$_.Name -notlike "Get-*"}| %{Remove-ManagementRoleEntry -Identity "$($_.id)\$($_.name)" -Confirm:$false}
Remove-ManagementRoleEntry "zim-ManageMySharedMailboxes\Add-MailboxPermission"
Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Add-MailboxPermission" #-Parameters Identity,User,AccessRights
Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Get-MailboxPermission"

Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Add-MailboxFolderPermission"
Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Remove-MailboxFolderPermission"
Remove-ManagementRoleEntry "zim-ManageMySharedMailboxes\Add-MailboxFolderPermission"
Remove-ManagementRoleEntry "zim-ManageMySharedMailboxes\Remove-MailboxFolderPermission"

Remove-ManagementRoleEntry "zim-ManageMySharedMailboxes\Remove-MailboxPermission"
Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Remove-MailboxPermission" #-Parameters Identity,User,AccessRights
Remove-ManagementRoleEntry "zim-ManageMySharedMailboxes\Set-Mailbox"
Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Set-Mailbox" -Parameters Identity,GrantSendOnBehalfTo

Get-ManagementRoleEntry "MyMailboxDelegation\*"

Get-ManagementRoleEntry "Role Management\*"

Add-ManagementRoleEntry "zim-ManageMySharedMailboxes\Add-ADPermission" -Parameters User,AccessRights,ExtendedRights


New-RoleGroup -Name "zim-SelfManaged-SharedMailboxManagement" -Description "Members of this management role group can delegate full access to their shared mailboxes." -Roles "zim-ManageMySharedMailboxes","View-Only Recipients"
Remove-RoleGroup -Identity "zim-SelfManaged-SharedMailboxManagement"
New-ManagementRoleAssignment -Role "Active Directory Permissions" -SecurityGroup "zim-SelfManaged-SharedMailboxManagement"



New-ManagementScope -Name S001_MailboxMgmtScope -RecipientRestrictionFilter {MemberofGroup -eq "CN=S001_Mailboxes.UG,OU=MgmtScope-RecipientGroups,OU=ZIM-exchange-securitygroups,DC=ads,DC=uni-passau,DC=de"}
#>


Get-ManagementScope 

<# START S001#>
New-RoleGroup -Name "zim-S001-SharedMailboxMgmt" -Description "Member of this Management Role Group are Able to Manage FullAccess and Send As Rights at Group Members of S001_Mailboxes" -Roles "zim-ManageMySharedMailboxes"
Get-ManagementRoleAssignment "zim-ManageMySharedMailboxes-zim-S001-SharedMailboxMgmt" | Set-ManagementRoleAssignment -CustomRecipientWriteScope S001_MailboxMgmtScope
New-ManagementRoleAssignment -SecurityGroup "zim-S001-SharedMailboxMgmt" -Role "Active Directory Permissions" -CustomRecipientWriteScope S001_MailboxMgmtScope -
New-ManagementRoleAssignment -SecurityGroup "zim-S001-SharedMailboxMgmt" -Role "View-Only Recipients"

< #ENDE S001#>


<# START Automatisierte Gruppen #>
$adCredentials=Get-Credential -Message "AD Credentials for Exchange Administrator"

Get-ADGroup -SearchBase 'OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de' -Filter * -Properties Description | ForEach-Object {
    $TeamAdGroup=$_

    Write-Host ("Working On: " + $TeamAdGroup.Name + " : " + $TeamAdGroup.Description)

    $TeamName=$TeamAdGroup.Name
    $mailboxesGroupName=($TeamName + "_Mailboxes.UG")

    Try{
        $mailboxesGroup=Get-ADGroup $mailboxesGroupName
        $mailboxesgroup | Set-ADGroup -Description ("These are Mailboxes of Team "+ $TeamAdGroup.Name + " : " + $TeamAdGroup.Description) -Credential $adCredentials
    }
    Catch{
        New-ADGroup -Name $mailboxesGroupName -Path 'OU=MgmtScope-RecipientGroups,OU=Microsoft Exchange Security Groups,DC=ads,DC=uni-passau,DC=de' -GroupScope Universal -Credential $adCredentials -Description ("These are Mailboxes of Team "+ $TeamAdGroup.Name + " : " + $TeamAdGroup.Description)
        $mailboxesGroup=Get-ADGroup $mailboxesGroupName
    }

    $defaultTeamMailbox=Get-ADUser -Filter ('Name -eq "' + $TeamName + '_Team"')
    if($defaultTeamMailbox -ne $null){
        $mailboxesGroup | Add-ADGroupMember -Members $defaultTeamMailbox -Credential $adCredentials
    }


    $recipientRestrictionFilter=("MemberofGroup -eq '" + $mailboxesGroup.DistinguishedName + "'")
    
    $OldErrorActionPreference=$ErrorActionPreference
    $ErrorActionPreference="Stop"

    Try{
        $managementScope=Get-ManagementScope ($TeamName + "_MailboxMgmtScope")

        if($managementScope -eq $null){
            $managementScope=New-ManagementScope -Name ($TeamName + "_MailboxMgmtScope") -RecipientRestrictionFilter $recipientRestrictionFilter
        }

        if($managementScope.RecipientFilter -ne $recipientRestrictionFilter){
            $managementScope | Set-ManagementScope -RecipientRestrictionFilter $recipientRestrictionFilter
        }
    }
    Catch{
        $managementScope=New-ManagementScope -Name ($TeamName + "_MailboxMgmtScope") -RecipientRestrictionFilter $recipientRestrictionFilter
    }

    

    $roleGroupName=($TeamName + "-SharedMailboxMgmt")
    Try{
        $roleGroup=Get-RoleGroup -Identity $roleGroupName
    }
    Catch{
        $roleGroup = New-RoleGroup -Name $roleGroupName -Description  ("Member of this Management Role Group are Able to Manage FullAccess and Send As Rights at Group Members of " + $TeamName + "_Mailboxes")

        #$roleAdObject=$null
        #$roleAdObject=(Get-ADObject -Identity $roleGroup.DistinguishedName)
        <#
        While ($roleAdObject -eq $null){
            
            $roleAdObject=(Get-ADObject -Identity $roleGroup.DistinguishedName)
        }
        #>

        #Move-ADObject -Identity $roleGroup.DistinguishedName  -TargetPath 'OU=RestrictedSecurityScopeGroups,OU=Microsoft Exchange Security Groups,DC=ads,DC=uni-passau,DC=de' -Credential $adCredentials
    }


    $ErrorActionPreference=$OldErrorActionPreference

    ForEach ($roleName in @("zim-ManageMySharedMailboxes","Active Directory Permissions")){
        $roleAssignment=Get-ManagementRoleAssignment -RoleAssignee $roleGroup.Name -Role $roleName
        if($roleAssignment -ne $null){
            $roleAssignment | Set-ManagementRoleAssignment -CustomRecipientWriteScope $managementScope.Name
        }
        else{
            New-ManagementRoleAssignment -SecurityGroup $roleGroup.Name -Role $roleName -CustomRecipientWriteScope $managementScope.Name
        }
    }

    $roleAssignment=Get-ManagementRoleAssignment -RoleAssignee $roleGroup.Name -Role "View-Only Recipients"
    if($roleAssignment -eq $null){
        New-ManagementRoleAssignment -SecurityGroup $roleGroup.Name -Role "View-Only Recipients"
    }

}







Get-ADGroup -SearchBase 'OU=group,OU=idm,DC=ads,DC=uni-passau,DC=de' -Filter * -Properties Description | ForEach-Object {
    $TeamAdGroup=$_

    $TeamName=$TeamAdGroup.Name
    $mailboxesGroupName=($TeamName + "_Mailboxes.UG")

    Get-ADGroup $mailboxesGroupName

    #-Description ("These are Mailboxes of Team "+ $TeamAdGroup.Name + " : " + $TeamAdGroup.Description)

}



<# ENDE Automatisierte Gruppen #>




New-RoleGroup -Name "S001-SharedMailboxMgmt" -Description "Member of this Management Role Group are Able to Manage FullAccess and Send As Rights at Group Members of S001_Mailboxes" -Roles "zim-ManageMySharedMailboxes"
#Get-ManagementRoleAssignment "zim-ManageMySharedMailboxes-zim-S001-SharedMailboxMgmt" | Set-ManagementRoleAssignment -CustomRecipientWriteScope S001_MailboxMgmtScope
New-ManagementRoleAssignment -SecurityGroup "S001-SharedMailboxMgmt" -Role "zim-ManageMySharedMailboxes" -CustomRecipientWriteScope S001_MailboxMgmtScope
New-ManagementRoleAssignment -SecurityGroup "S001-SharedMailboxMgmt" -Role "Active Directory Permissions" -CustomRecipientWriteScope S001_MailboxMgmtScope
New-ManagementRoleAssignment -SecurityGroup "S001-SharedMailboxMgmt" -Role "View-Only Recipients"
<# ENDE Automatisierte Gruppen #>


Get-ManagementRoleAssignment | ft -AutoSize
Get-ManagementRoleAssignment -Identity "zim-ManageMySharedMailboxes-zim-SelfManaged-SharedMailboxManagem" | Set-ManagementRoleAssignment -RecipientRelativeWriteScope

Set-ManagementRoleAssignment "" -RecipientRelativeWriteScope 


Get-ManagementRoleEntry "Active Directory Permissions\*"
Get-ManagementRoleEntry "Mail Recipients\*"

Get-ManagementRoleAssignment | ft -AutoSize

Get-ManagementRoleAssignment -Identity zim-ManageMySharedMailboxes-zim-SelfManaged-SharedMailboxManagem | Set-ManagementRoleAssignment -RecipientRelativeWriteScope Organization

$mb | Add-MailboxPermission -User schaetzl -AccessRights FullAccess

$mb_aduser=Get-ADUser $mb.SamAccountName

Add-ADPermission -Identity $mb_aduser.DistinguishedName -User schaetzl -AccessRights ExtendedRight -ExtendedRights "Send As"











New-ManagementRole -Name SecurityScopeGroupsManager -Description "This Role Enables Management of Role Group Management / Admin Group Management" -Parent "Role Management"
#%{Remove-ManagementRoleEntry -Identity "$($_.id)\$($_.name)" -Confirm:$false}

Get-ManagementRoleEntry "SecurityScopeGroupsManager\*" | Where-Object {$_.Name -notlike "Get-*" -and $_.Name -notin ("Add-RoleGroupMember","Remove-RoleGroupMember","Update-RoleGroupMember")} |
    %{Remove-ManagementRoleEntry -Identity "$($_.id)\$($_.name)" -Confirm:$false}

$recipientRestrictionFilter='CommonName -like "*"'
$managementScope=New-ManagementScope -Name "RestrictedSecurityScopeGroups" -RecipientRoot "ads.uni-passau.de/Microsoft Exchange Security Groups/RestrictedSecurityScopeGroups" -RecipientRestrictionFilter $recipientRestrictionFilter

New-RoleGroup -Name zim-SecurityScopeGroupsManager -Roles SecurityScopeGroupsManager -Description "Members of this group are able to manage Group Members in ads.uni-passau.de/Microsoft Exchange Security Groups/RestrictedSecurityScopeGroups"

Get-ManagementRoleAssignment -RoleAssignee zim-SecurityScopeGroupsManager | ft -AutoSize
Set-ManagementRoleAssignment -Identity "SecurityScopeGroupsManager-zim-SecurityScopeGroupsManager" -CustomRecipientWriteScope RestrictedSecurityScopeGroups


