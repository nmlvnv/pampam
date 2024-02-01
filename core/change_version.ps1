Powershell.exe -WindowStyle hidden -Command 'clear'

. "$((get-item $PSScriptRoot).Fullname)\config_static.ps1"
. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\list_box.ps1"

# argument
if($args.Count -eq 1) {
	if(@('httpd','mariadb','php') -contains "$($args[0])") {
		$type = $args[0]
	} else {
		$type = ""
	}
} else {
	$type = ""
}

# alert when $type is invalid
if(!$type) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show($this, "Invalid Type")
	exit
}

# check only dir
$ds = Get-ChildItem -Path $version_dir -Name -Directory

# build list of supported versions
$list = [System.Collections.ArrayList]@()
foreach ($item in $ds)
{
  if($item -match "^$type-") {
	  [void] $list.Add($item)
  }
}

$hash = decrypt-dir (Ini-To-Hash -ini "$base_dir\config.ini")

$title = "Select a $type version"
$desc = "Select a $type version:"

$v = list-box $title $desc $list $hash.($type + '_version')

if(!$v) {
	exit
}

if($v -ne $hash.($type + '_version')) {
	$arr_status = & "$((get-item $PSScriptRoot).Fullname)\status.ps1" silent
	$str_status = $arr_status -join "`r`n"
	
	# stop service of old version
	& "$((get-item $PSScriptRoot).Fullname)\stop.ps1" silent
	
	$hash.($type + '_version') = $v
	Hash-To-Ini -hash (encrypt-dir $hash) -ini "$base_dir\config.ini"
	
	& "$((get-item $PSScriptRoot).Fullname)\init.ps1"
	
	# or call stop_any.ps1 because path is changed
	# so old service can't be stopped
	
	if(!$str_status.contains(" not ")) {
		& "$((get-item $PSScriptRoot).Fullname)\start.ps1" silent
	}
}