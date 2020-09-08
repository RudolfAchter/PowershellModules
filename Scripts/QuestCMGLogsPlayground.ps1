New-SmbMapping -LocalPath T: -RemotePath "\\quest-cmg\c$" -UserName msxadmin@ads.uni-passau.de -Password "M8msNl0s!adS"

Get-QuestCMGProcessedMessages | Export-Csv -Path "H:\Todo\2020-08-14_QuestCMGLogs\2020-09-07_QuestCMGProcessedMessages.csv" -NoTypeInformation