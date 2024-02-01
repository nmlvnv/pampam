Powershell.exe -WindowStyle hidden -Command 'clear'

$did = $false
$procs = Get-Process httpd -ErrorAction SilentlyContinue
if ($procs){
	Stop-Process $procs
	$did = $true
}

$procs = Get-Process mysqld -ErrorAction SilentlyContinue
if ($procs){
	& $procs.Path.replace('mysqld', 'mysqladmin') shutdown
	Stop-Process $procs
	$did = $true
}

if($did) {
	if($args.Count -eq 0) {
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
		[System.Windows.Forms.MessageBox]::Show($this, "Stopped done")
	}
}