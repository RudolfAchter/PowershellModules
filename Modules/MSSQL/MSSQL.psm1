#Aus: https://technet.microsoft.com/de-de/magazine/hh855069.aspx
#Stellt Cmdlets zur Verf�gung mit denen SQL Queries durchgef�hrt werden k�nnen

<#
.SYNOPSIS
    F�hrt Datenbankabfragen durch
.DESCRIPTION
    Verbindet sich mittels ConnectionString zu einer Datenbank und f�hrt dort eine Query aus.
    Mit Integrated Security=SSPI bist du mit deinem Windows User angemeldet. Ansonsten einen
    Connection String bauen der f�r die entsprechende Verbindung zust�ndig ist.
.PARAMETER connectionString
    Connection String zu einer Datenbank
.PARAMETER query
    Auszuf�hrende SQL Query
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
<#
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
#>
function Get-DatabaseData {
<#
.SYNOPSIS
    Führt Datenbankabfragen durch
.DESCRIPTION
    Verbindet sich mittels ConnectionString zu einer Datenbank und führt dort eine Query aus.
    Mit Integrated Security=SSPI bist du mit deinem Windows User angemeldet. Ansonsten einen
    Connection String bauen der für die entsprechende Verbindung zustündig ist.
.PARAMETER connectionString
	Connection String zu einer Datenbank
	(Ich hätte gern noch ein CMDlet Get-ConnectionString um das erstellen von Connection Strings
	zu vereinfachen)
.PARAMETER query
    Auszuführende SQL Query
.PARAMETER isSQLServer
    isSQLServer true oder false. Wenn false dann ist die Verbindung eine OleDB Mode Verbindung

.PARAMETER isOleDB
Verbindet sich mit einer OleDB Verbindung. 
Der Connection String muss dann für eine Ole DB Verbindung verwendet werden

.PARAMETER isSQLServer
Für Kompatibilität für die alte Get-DatabaseData Funktion
isSQLServer true oder false. Wenn false dann ist die Verbindung eine OleDB Mode Verbindung
(Überschreibt isOleDB)

.EXAMPLE
$conn = "Server=deslnsql2008srv;Database=RAC_LogRestore_Test;Integrated Security=SSPI"
$query = "Select * From ractest"
$data = Get-DatabaseData -connectionString $conn -query $query -isSQLServer:$true
$data | Select-Object -First 10 | Format-Table -AutoSize

.NOTES
General notes
#>

	[CmdletBinding()]
	param(
		[string]$connectionString,
		[string]$query,
		[switch]$isOleDB,
		[switch]$isSQLServer
	)

	#Für Kompatibilität für die alte Get-DatabaseData Funktion
	if($isSQLServer -eq $true){$isOleDB=$false}

	if ($isOleDB) {
		Write-Verbose 'in OleDB mode'
		$conn = New-Object -TypeName System.Data.OleDb.OleDbConnection($connectionString)
	} else {
		Write-Verbose 'in SQL Server mode'
		$conn = New-Object -TypeName System.Data.SqlClient.SqlConnection($connectionString)
	}

	$conn.Open()

	$sqlcmd = New-Object "System.Data.SqlClient.SqlCommand"($query,$conn)
	$reader=$sqlcmd.ExecuteReader()

	$i=0
	
	#Für Jede Zeile
	#Alle Spalten mit Spaltennamen als Powershell Obekt ausgeben
	while($reader.read()){
		$h_vals=[ordered]@{}
		for($j=0; $j -lt $reader.FieldCount ;$j++){
			$h_vals.Add($reader.GetName($j),$reader.GetValue($j))
		}
		New-Object -TypeName "PSObject" -Property $h_vals
	}

	$reader.Close()

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

function Get-ConnectionString {
	param(
		[ValidateSet("SQL","Windows")]
		$Type,
		$Hostname,
		$Database,
		$User,
		$Password
	)

	Switch($Type) {
		"SQL"{
			("Server=$Hostname;Database=$Database;User Id=$User;Password=$Password")
			break
		}
		"Windows"{
			("Server=$Hostname;Database=$Database;Integrated Security=SSPI")
			break
		}
	}

}