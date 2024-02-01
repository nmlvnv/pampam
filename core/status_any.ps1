Powershell.exe -WindowStyle hidden -Command 'clear'

$procs = Get-Process httpd -ErrorAction SilentlyContinue
if ($procs){
	$hstatus = "Httpd is Running"
} else {
	$hstatus = "Httpd is Nothing"
}

$procs = Get-Process mysqld -ErrorAction SilentlyContinue
if ($procs){
	$mstatus = "MariaDB is Running"
} else {
	$mstatus = "MariaDB is Nothing"
}

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.MessageBox]::Show($this, "$hstatus`r`n`r`n$mstatus")
