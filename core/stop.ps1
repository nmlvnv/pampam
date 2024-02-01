Powershell.exe -WindowStyle hidden -Command 'clear'

. "$((get-item $PSScriptRoot).Fullname)\config.ps1"

$did = $false
$procs = Get-Process httpd -ErrorAction SilentlyContinue | Where-Object {$_.Path.Contains($httpd_dir)}
if ($procs){
	Stop-Process $procs
	$did = $true
}

$procs = Get-Process mysqld -ErrorAction SilentlyContinue | Where-Object {$_.Path.Contains($mariadb_dir)}
if ($procs){
	& $procs.Path.replace('mysqld', 'mysqladmin') shutdown
	Stop-Process $procs
	$did = $true
}

if($did) {
	if($args.Count -eq 0) {
		& "$((get-item $PSScriptRoot).Fullname)\status.ps1"
	}
}
