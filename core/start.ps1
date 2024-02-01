ipconfig /flushdns | Out-Null

. "$((get-item $PSScriptRoot).Fullname)\init.ps1"

# need for PHP's OpenSSL extension and some other extensions

$backup = $env:PATH

$p = [System.Environment]::getEnvironmentVariable('Path', 'Machine') + ";" + [System.Environment]::getEnvironmentVariable('Path', 'User')
if(!$p.contains($php_dir)) {
	$env:PATH = $p + ";" + $php_dir
}

$messages = [System.Collections.ArrayList]@()

$procs = Get-Process httpd -ErrorAction SilentlyContinue | Where-Object {$_.Path.Contains($httpd_dir)}
if (!$procs){
	$others = Get-Process httpd -ErrorAction SilentlyContinue
	if($others) {
		$messages.Add("Another httpd is running")
	} else {
		Start-Process -FilePath "$httpd_dir\bin\httpd.exe" -WindowStyle hidden
	}
} else {
	$messages.Add("Httpd have been running")
}

$env:PATH = $backup

$procs = Get-Process mysqld -ErrorAction SilentlyContinue | Where-Object {$_.Path.Contains($mariadb_dir)}
if (!$procs){
	$others = Get-Process mysqld -ErrorAction SilentlyContinue
	if($others) {
		$messages.Add("Another mariadb is running")
	} else {
		Start-Process -FilePath "$mariadb_dir\bin\mysqld.exe" -ArgumentList "--defaults-file=`"$mariadb_dir\my.ini`"" -WindowStyle hidden
	}
} else {
	$messages.Add("MariaDB have been running")
}

if($messages.count) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show($this, $messages -join "`r`n")
}

if($args.Count -eq 0) {
	& "$((get-item $PSScriptRoot).Fullname)\status.ps1"
}