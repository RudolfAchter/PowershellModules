function ConvertTo-BinaryIP {
  <#
    .Synopsis
      Converts a Decimal IP address into a binary format.
    .Description
      ConvertTo-BinaryIP uses System.Convert to switch between decimal and binary format. The output from this function is dotted binary.
    .Parameter IPAddress
      An IP Address to convert.
  #>

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Net.IPAddress]$IPAddress
  )

  process {  
    return [String]::Join('.', $( $IPAddress.GetAddressBytes() |
      ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') } ))
  }
}

function ConvertTo-DecimalIP {
  <#
    .Synopsis
      Converts a Decimal IP address into a 32-bit unsigned integer.
    .Description
      ConvertTo-DecimalIP takes a decimal IP, uses a shift-like operation on each octet and returns a single UInt32 value.
    .Parameter IPAddress
      An IP Address to convert.
  #>
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Net.IPAddress]$IPAddress
  )

  process {
    $i = 3; $DecimalIP = 0;
    $IPAddress.GetAddressBytes() | ForEach-Object { $DecimalIP += $_ * [Math]::Pow(256, $i); $i-- }

    return [UInt32]$DecimalIP
  }
}

function ConvertTo-DottedDecimalIP {
  <#
    .Synopsis
      Returns a dotted decimal IP address from either an unsigned 32-bit integer or a dotted binary string.
    .Description
      ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.
    .Parameter IPAddress
      A string representation of an IP address from either UInt32 or dotted binary.
  #>

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    $IPAddress
  )
  
  process {


    if($IPAddress.GetType().Name -eq "UInt32"){
        $IPAddress = [UInt32]$IPAddress
        $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
          $Remainder = $IPAddress % [Math]::Pow(256, $i)
          ($IPAddress - $Remainder) / [Math]::Pow(256, $i)
          $IPAddress = $Remainder
         } )
       
        return [String]::Join('.', $DottedIP)
    }

    Switch -RegEx ($IPAddress) {
      "([01]{8}.){3}[01]{8}" {
        return [String]::Join('.', $( $IPAddress.Split('.') | ForEach-Object { [Convert]::ToUInt32($_, 2) } ))
      }
      "d" {

      }
      default {
        Write-Error "Cannot convert this format"
      }
    }
  }
}

function ConvertTo-MaskLength {
  <#
    .Synopsis
      Returns the length of a subnet mask.
    .Description
      ConvertTo-MaskLength accepts any IPv4 address as input, however the output value 
      only makes sense when using a subnet mask.
    .Parameter SubnetMask
      A subnet mask to convert into length
  #>

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
    [Alias("Mask")]
    [Net.IPAddress]$SubnetMask
  )

  process {
    $Bits = "$( $SubnetMask.GetAddressBytes() | ForEach-Object { [Convert]::ToString($_, 2) } )" -replace ' ' -replace '[s0]'

    return $Bits.Length
  }
}

function ConvertTo-Mask {
  <#
    .Synopsis
      Returns a dotted decimal subnet mask from a mask length.
    .Description
      ConvertTo-Mask returns a subnet mask in dotted decimal format from an integer value ranging 
      between 0 and 32. ConvertTo-Mask first creates a binary string from the length, converts 
      that to an unsigned 32-bit integer then calls ConvertTo-DottedDecimalIP to complete the operation.
    .Parameter MaskLength
      The number of bits which must be masked.
  #>
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Alias("Length")]
    [ValidateRange(0, 32)]
    $MaskLength
  )
  
  Process {
    return ConvertTo-DottedDecimalIP ([Convert]::ToUInt32($(("1" * $MaskLength).PadRight(32, "0")), 2))
  }
}

function Get-NetworkAddress {
  <#
    .Synopsis
      Takes an IP address and subnet mask then calculates the network address for the range.
    .Description
      Get-NetworkAddress returns the network address for a subnet by performing a bitwise AND 
      operation against the decimal forms of the IP address and subnet mask. Get-NetworkAddress 
      expects both the IP address and subnet mask in dotted decimal format.
    .Parameter IPAddress
      Any IP address within the network range.
    .Parameter SubnetMask
      The subnet mask for the network.
  #>
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Net.IPAddress]$IPAddress,
    
    [Parameter(Mandatory = $true, Position = 1)]
    [Alias("Mask")]
    [Net.IPAddress]$SubnetMask
  )

  process {
    return ConvertTo-DottedDecimalIP ((ConvertTo-DecimalIP $IPAddress) -band (ConvertTo-DecimalIP $SubnetMask))
  }
}

function Get-BroadcastAddress {
  <#
    .Synopsis
      Takes an IP address and subnet mask then calculates the broadcast address for the range.
    .Description
      Get-BroadcastAddress returns the broadcast address for a subnet by performing a bitwise AND 
      operation against the decimal forms of the IP address and inverted subnet mask. 
      Get-BroadcastAddress expects both the IP address and subnet mask in dotted decimal format.
    .Parameter IPAddress
      Any IP address within the network range.
    .Parameter SubnetMask
      The subnet mask for the network.
  #>
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Net.IPAddress]$IPAddress, 
    
    [Parameter(Mandatory = $true, Position = 1)]
    [Alias("Mask")]
    [Net.IPAddress]$SubnetMask
  )

  process {
    return ConvertTo-DottedDecimalIP $((ConvertTo-DecimalIP $IPAddress) -bor `
      ((-bnot (ConvertTo-DecimalIP $SubnetMask)) -band [UInt32]::MaxValue))
  }
}

function Get-NetworkSummary ( [String]$IP, [String]$Mask ) {
<#
    .Synopsis
        Provides all Necessary Network Information in an Object
        Network is provided either by IP-Address/cidr or IP-Address and Mask
    .Parameter IP
        IP-Address oder IP/cidr
        for Example
        -IP 192.168.10.20 -Mask 255.255.255.128
        -IP "192.168.10.20/25"
    .EXAMPLE
        Get-NetworkSummary 192.168.70.20/28
#>
  if ($IP.Contains("/")) {
    $Temp = $IP.Split("/")
    $IP = $Temp[0]
    $Mask = $Temp[1]
  }

  if (!$Mask.Contains(".")) {
    $Mask = ConvertTo-Mask $Mask
  }

  $DecimalIP = ConvertTo-DecimalIP $IP
  $DecimalMask = ConvertTo-DecimalIP $Mask
  
  $Network = $DecimalIP -band $DecimalMask
  $Broadcast = $DecimalIP -bor `
    ((-bnot $DecimalMask) -band [UInt32]::MaxValue)
  #Write-Host("Network: "+ $Network)
  $NetworkAddress = ConvertTo-DottedDecimalIP $Network
  $RangeStart = ConvertTo-DottedDecimalIP ($Network + 1)
  $RangeEnd = ConvertTo-DottedDecimalIP ($Broadcast - 1)
  $BroadcastAddress = ConvertTo-DottedDecimalIP $Broadcast
  $MaskLength = ConvertTo-MaskLength $Mask
  
  $BinaryIP = ConvertTo-BinaryIP $IP; $Private = $False
  switch -regex ($BinaryIP) {
    "^1111"  { $Class = "E"; $SubnetBitMap = "1111"; break }
    "^1110"  { $Class = "D"; $SubnetBitMap = "1110"; break }
    "^110"   { 
      $Class = "C"
      if ($BinaryIP -match "^11000000.10101000") { $Private = $true }
      break
    }
    "^10"    { 
      $Class = "B"
      if ($BinaryIP -match "^10101100.0001") { $Private = $true }
      break
    }
    "^0"     { 
      $Class = "A" 
      if ($BinaryIP -match "^0000101") { $Private = $true }
    }
  }   
   
  $NetInfo = New-Object Object
  Add-Member NoteProperty "Network"     -Input $NetInfo -Value $NetworkAddress
  Add-Member NoteProperty "Broadcast"   -Input $NetInfo -Value $BroadcastAddress
  Add-Member NoteProperty "Range"       -Input $NetInfo -Value "$RangeStart - $RangeEnd"
  Add-Member NoteProperty "RangeStart"  -Input $NetInfo -Value $RangeStart
  Add-Member NoteProperty "RangeEnd"    -Input $NetInfo -Value $RangeEnd
  Add-Member NoteProperty "Mask"        -Input $NetInfo -Value $Mask
  Add-Member NoteProperty "CIDR"        -Input $NetInfo -Value $MaskLength
  Add-Member NoteProperty "Hosts"       -Input $NetInfo -Value $($Broadcast - $Network - 1)
  Add-Member NoteProperty "Class"       -Input $NetInfo -Value $Class
  Add-Member NoteProperty "IsPrivate"   -Input $NetInfo -Value $Private
  
  
  return $NetInfo
}

function Get-NetworkRange( [String]$IP, [String]$Mask ) {
  if ($IP.Contains("/")) {
    $Temp = $IP.Split("/")
    $IP = $Temp[0]
    $Mask = $Temp[1]
  }

  if (!$Mask.Contains(".")) {
    $Mask = ConvertTo-Mask $Mask
  }

  $DecimalIP = ConvertTo-DecimalIP $IP
  $DecimalMask = ConvertTo-DecimalIP $Mask
  
  $Network = $DecimalIP -band $DecimalMask
  $Broadcast = $DecimalIP -bor ((-bnot $DecimalMask) -band [UInt32]::MaxValue)

  for ($i = $($Network + 1); $i -lt $Broadcast; $i++) {
    ConvertTo-DottedDecimalIP $i
  }
}

function Get-IP-NetworkMembership ([string] $IP, [string]$network) {
<#
.SYNOPSIS
    Checks Membership of IP-Address in a particular Network
    Returns true When IP is Member
    Returns false wehon IP is not Member
.EXAMPLE
    Get-IP-NetworkMembership -IP 192.168.10.5 -network 192.168.10.0/24
    #True
.EXAMPLE
    Get-IP-NetworkMembership -IP 172.16.10.200 -network 172.16.10.0/25
    #False
#>
    if( 
        ([Net.IPAddress]$IP).Address -ge ([Net.IPAddress]((Get-NetworkSummary $network).RangeStart)).Address `
        -and `
        ([Net.IPAddress]$IP).Address -le ([Net.IPAddress]((Get-NetworkSummary $network).RangeEnd)).Address
       )
    {
        return $true
    }
    else
    {
        return $false
    }
    

}
