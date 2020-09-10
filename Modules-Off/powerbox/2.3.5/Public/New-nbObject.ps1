<#
.SYNOPSIS
    Creates a Object in Netbox
.DESCRIPTION
    This should handle mapping a simple hashtable of values and looking up any references.
.EXAMPLE
    $device = @{
        name = 'example'
        serial = 'aka123457'
        device_type = '20'
        device_role = '85'
        site = '5'
        status = 'active'
    }
    New-nbObject -lookup $lookup -object $device
#>
function New-nbObject {
    [CmdletBinding(DefaultParameterSetName = 'Normal')]
    Param (
        # object/resource type
        [Parameter(Mandatory = $true, ParameterSetName = 'Normal')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Connect')]
        [String]
        [Alias("type")]
        $Resource,

        # List of custom properties
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Connect')]
        [string[]]
        $CustomProperties,

        #List of properties to lookup. Has errors. Maybe remove this feature
        [Parameter(ParameterSetName = 'Normal')]
        [Parameter(ParameterSetName = 'Connect')]
        [hashtable]
        $Lookup,

        # you can specify properties as arguments to this command
        [Parameter(Mandatory=$true)]
        $Object,

        # Passthrough to invoke-nbapi
        # [Parameter(ValueFromRemainingArguments = $true, ParameterSetName = 'Normal')]
        # [Parameter(ValueFromRemainingArguments = $true, ParameterSetName = 'Connect')]
        # [HashTable]
        # $AdditionalParams,

        #AccessId for this API
        [Parameter(Mandatory = $true, ParameterSetName = 'Connect')]
        [SecureString]
        $Token,

        #AccessKey for this API
        [Parameter(Mandatory = $true, ParameterSetName = 'Connect')]
        [uri]
        $APIUrl
    )

    $mapObject = @{custom_fields = @{}}

    ForEach ($key in $Object.Keys){
        $name=$key -replace '-' -replace ':'
        $value=$Object.$key
        $mapObject[$name] = $value

    }

    $mapObject = New-Object -TypeName psobject -Property $mapObject

    #$mapObject
    #($mapObject | ConvertTo-Json -Compress)

    Invoke-nbApi -Resource $Resource -HttpVerb POST -Body ($mapObject | ConvertTo-Json -Compress)
}
