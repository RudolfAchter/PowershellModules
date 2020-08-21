$apiToken=ConvertTo-SecureString -String '611e80a35adb220239f158de2b469465492b8b9c' -AsPlainText -Force


Connect-nbAPI -Token $apiToken -APIurl https://netbox.zim.uni-passau.de/api
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
Get-nbTenant | Out-GridView

Get-nbTenantGroup

Connect-LDAP