param([string]$server = "localhost", [string]$database = "tempdb", [string]$username, [string]$password)

$cmd = "c:\Program Files\Microsoft SQL Server\100\Tools\Binn\SQLCMD.EXE"

function LoadScripts($files, [string]$server, [string]$database, [string]$username, [string]$password)
{
    ForEach ($file in $files)
    {
        Write-Output "Loading $($file.Name)..."; 
        if ($username -eq "")
        {
            & $cmd -S $server -E -d $database -i $file.Name
        } else 
        {
            & $cmd -S $server -d $database -U $username -P $password -i $file.Name            
        }
    }
}

$sys2_files = Get-ChildItem | ? { $_.Extension -eq ".sql" } | ? { $_.Name.StartsWith("sys2.") } 

LoadScripts $sys2_files $server $database $username $password

