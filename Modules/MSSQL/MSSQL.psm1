#Aus: https://technet.microsoft.com/de-de/magazine/hh855069.aspx
#Stellt Cmdlets zur Verfügung mit denen SQL Queries durchgeführt werden können

<#
.SYNOPSIS
    Führt Datenbankabfragen durch
.DESCRIPTION
    Verbindet sich mittels ConnectionString zu einer Datenbank und führt dort eine Query aus.
    Mit Integrated Security=SSPI bist du mit deinem Windows User angemeldet. Ansonsten einen
    Connection String bauen der für die entsprechende Verbindung zuständig ist.
.PARAMETER connectionString
    Connection String zu einer Datenbank
.PARAMETER query
    Auszuführende SQL Query
.PARAMETER isSQLServer
    isSQLServer true oder false. Wenn false dann ist die Verbindung eine OleDB Mode Verbindung
.EXAMPLE
    
    $conn = "Server=deslnsql2008srv;Database=RAC_LogRestore_Test;Integrated Security=SSPI"
    $query = "Select * From ractest"
    $data = Get-DatabaseData -connectionString $conn -query $query -isSQLServer:$true
    $data | Select-Object -First 10 | Format-Table -AutoSize
.LINK
    http://wiki.megatech.local/mediawiki/index.php/PSCmdlet:Get-DatabaseData
.LINK
    https://technet.microsoft.com/de-de/magazine/hh855069.aspx
.LINK
    https://www.connectionstrings.com/sql-server/
.LINK
    https://msdn.microsoft.com/en-us/library/ms254500(v=vs.110).aspx
.NOTES
    Author: Rudolf Achter
    Date:   2015-10-01
#>
 function Get-DatabaseData {
	[CmdletBinding()]
	param (
		[string]$connectionString,
		[string]$query,
		[switch]$isSQLServer
	)
	if ($isSQLServer) {
		Write-Verbose 'in SQL Server mode'
		$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
	} else {
		Write-Verbose 'in OleDB mode'
		$connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
	}
	$connection.ConnectionString = $connectionString
	$command = $connection.CreateCommand()
	$command.CommandText = $query
	if ($isSQLServer) {
		$adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
	} else {
		$adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
	}
	$dataset = New-Object -TypeName System.Data.DataSet
	$out=$adapter.Fill($dataset)
	$dataset.Tables[0]
}

#//XXX muss noch dokumentiert werden

function Invoke-DatabaseQuery {
	[CmdletBinding()]
	param (
		[string]$connectionString,
		[string]$query,
		[switch]$isSQLServer
	)
	if ($isSQLServer) {
		Write-Verbose 'in SQL Server mode'
		$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
	} else {
		Write-Verbose 'in OleDB mode'
		$connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
	}
	$connection.ConnectionString = $connectionString
	$command = $connection.CreateCommand()
	$command.CommandText = $query
	$connection.Open()
	$command.ExecuteNonQuery()
	$connection.close()
}