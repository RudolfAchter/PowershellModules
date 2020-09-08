$byteReplacePattern='(.*\()|,| [a-z]*\)'

Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize 20 |
    Get-MailboxStatistics | ForEach-Object {
        $mailbox=$_
        $mailbox | Add-Member -MemberType ScriptProperty -Name TotalItemSizeInBytes  -Value {[bigint]($this.TotalItemSize -replace $byteReplacePattern, '')}
        $mailbox | Select-Object DisplayName, TotalItemSizeInBytes
    }



Get-MailboxDatabase -status | ForEach-Object {
    $mbdb=$_
    $mbdb | Add-Member -MemberType ScriptProperty -Name DatabaseSizeBytes  -Value {[bigint]($this.DatabaseSize -replace $byteReplacePattern, '')}
    $mbdb
} | Select-Object Name,DatabaseSize,DatabaseSizeBytes,AvailableNewMailboxSpace


  Select-Object DisplayName, TotalItemSizeInBytes,@{Name=”TotalItemSize (GB)”; `

  Expression={[math]::Round($_.TotalItemSizeInBytes/1GB,2)}}