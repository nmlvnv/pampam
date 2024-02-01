Powershell.exe -WindowStyle hidden -Command 'clear'

. "$((get-item $PSScriptRoot).Fullname)\config.ps1"

$procs = Get-Process httpd -ErrorAction SilentlyContinue | Where-Object {$_.Path.Contains($httpd_dir)}
if ($procs){
	$hstatus = "Httpd is running"
} else {
	$hstatus = "Httpd is not running"
}

$procs = Get-Process mysqld -ErrorAction SilentlyContinue | Where-Object {$_.Path.Contains($mariadb_dir)}
if ($procs){
	$mstatus = "MariaDB is running"
} else {
	$mstatus = "MariaDB is not running"
}

if($args.Count -eq 0) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show($this, "$hstatus`r`n`r`n$mstatus")
} else {
	return @($hstatus, $mstatus)
}
