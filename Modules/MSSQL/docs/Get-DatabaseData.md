```

NAME
    Get-DatabaseData
    
ÜBERSICHT
    Fï¿½hrt Datenbankabfragen durch
    
    
SYNTAX
    Get-DatabaseData [[-connectionString] <String>] [[-query] <String>] [-isOleDB] [-isSQLServer] [<CommonParameters>]
    
    
BESCHREIBUNG
    Verbindet sich mittels ConnectionString zu einer Datenbank und fï¿½hrt dort eine Query aus.
    Mit Integrated Security=SSPI bist du mit deinem Windows User angemeldet. Ansonsten einen
    Connection String bauen der fï¿½r die entsprechende Verbindung zustï¿½ndig ist.
    

PARAMETER
    -connectionString <String>
        Connection String zu einer Datenbank
        
        Erforderlich?                false
        Position?                    1
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -query <String>
        Auszufï¿½hrende SQL Query
        
        Erforderlich?                false
        Position?                    2
        Standardwert                 
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -isOleDB [<SwitchParameter>]
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    -isSQLServer [<SwitchParameter>]
        isSQLServer true oder false. Wenn false dann ist die Verbindung eine OleDB Mode Verbindung
        
        Erforderlich?                false
        Position?                    named
        Standardwert                 False
        Pipelineeingaben akzeptieren?false
        Platzhalterzeichen akzeptieren?false
        
    <CommonParameters>
        Dieses Cmdlet unterstützt folgende allgemeine Parameter: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable und OutVariable. Weitere Informationen finden Sie unter 
        "about_CommonParameters" (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
EINGABEN
    
AUSGABEN
    
HINWEISE
    
    
        Author: Rudolf Achter
        Date:   2015-10-01
        
        
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
    
    -------------------------- BEISPIEL 1 --------------------------
    
    PS C:\>$conn = "Server=deslnsql2008srv;Database=RAC_LogRestore_Test;Integrated Security=SSPI"
    
    $query = "Select * From ractest"
    $data = Get-DatabaseData -connectionString $conn -query $query -isSQLServer:$true
    $data | Select-Object -First 10 | Format-Table -AutoSize
    
    
    
    
    
VERWANDTE LINKS
    http://wiki.megatech.local/mediawiki/index.php/PSCmdlet:Get-DatabaseData
    https://technet.microsoft.com/de-de/magazine/hh855069.aspx
    https://www.connectionstrings.com/sql-server/
    https://msdn.microsoft.com/en-us/library/ms254500(v=vs.110).aspx



```

