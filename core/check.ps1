. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\list_box.ps1"

$base_dir = (get-item $PSScriptRoot).parent.Fullname
$version_dir = "$base_dir\versions"

$default = [ordered]@{
	httpd_version = ""
	mariadb_version = ""
	php_version = ""
	db_data_dir = ""
	project_dir = ""
	vhosts_dir = ""
}

if (-Not (Test-Path -Path "$base_dir\config.ini")) {
	$hash = $default
	$org_json = ConvertTo-Json $hash -Compress
	# write
	Hash-To-Ini -hash (encrypt-dir $hash) -ini "$base_dir\config.ini"
} else {
	# read
	$hash = decrypt-dir (Ini-To-Hash -ini "$base_dir\config.ini")
	$org_json = ConvertTo-Json $hash -Compress
	
	# merge with default array
	$hash = Merge-Hashtables $hash $default $hash
	$mer_json = ConvertTo-Json $hash -Compress

	# write
	if($org_json -ne $mer_json) {
		Hash-To-Ini -hash (encrypt-dir $hash) -ini "$base_dir\config.ini"
		$org_json = $mer_json
	}
}

# create version dir if not exist
if (-Not (Test-Path -Path $version_dir)) {
	mkdir $version_dir | Out-Null
}

# move zip into versions
Move-Item -Path "$base_dir\*.zip" -Destination $version_dir -Force

# check zip and dir
$ds = Get-ChildItem -Path $version_dir -Name -Directory
$zs = Get-ChildItem -Path $version_dir -Name -File -Include *.zip
$fs = $zs | ForEach-Object {[System.IO.Path]::GetFileNameWithoutExtension($_)}

# alert
$has_httpd = $false
$has_mariadb = $false
$has_php = $false
foreach ($item in $($ds; $fs))
{
  if($item -match '^httpd-') {
	  $has_httpd = $true
  }
  if($item -match '^mariadb-') {
	  $has_mariadb = $true
  }
  if($item -match '^php-') {
	  $has_php = $true
  }
}

if(!$has_httpd -or !$has_mariadb -or !$has_php) {
	$message = "Download zip versions of the packages."
	
	if(!$has_httpd) {
		$message += "`r`n`r`nhttpd: https://www.httpdlounge.com/download"
	}
	if(!$has_mariadb) {
		$message += "`r`n`r`nmariadb: https://mariadb.org/download"
	}
	if(!$has_php) {
		$message += "`r`n`r`nphp: https://windows.php.net/downloads/releases"
	}
	
	$message += "`r`n`r`nThen put them into one in the folders:`r`n`r`n$base_dir`r`n`r`n$version_dir"
	
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show($this, $message)
	
	[Environment]::Exit(0)
}

# expand
& "$((get-item $PSScriptRoot).Fullname)\expand.ps1"

# check value of *_version
$httpd_version_list = [System.Collections.ArrayList]@()
$mariadb_version_list = [System.Collections.ArrayList]@()
$php_version_list = [System.Collections.ArrayList]@()
foreach ($item in $($ds; $fs))
{
  if($item -match '^httpd-') {
	  [void] $httpd_version_list.Add($item)
  }
  if($item -match '^mariadb-') {
	  [void] $mariadb_version_list.Add($item)
  }
  if($item -match '^php-') {
	  [void] $php_version_list.Add($item)
  }
}

foreach($type in @('httpd','mariadb','php'))
{
	$cv = $hash.($type + '_version')
	if($cv) {
		$valid_type = $cv -match "^$type-"
		$valid_dir = Test-Path -Path "$version_dir\$cv"
		if($valid_type -and $valid_dir) {
			continue
		} else {
			$title = "Select another $type version"
			$desc = "Version `"$cv`" has not corresponding folder.`r`nSo select another $type version:"
		}
	} else {
		$title = "Select a $type version"
		$desc = "Select a $type version:"
	}

	$list = Get-Variable ($type + '_version_list') -ValueOnly
	$v = list-box $title $desc $list
	
	if(!$v) {
		[Environment]::Exit(0)
	}
	
	$hash.($type + '_version') = $v
}

$upd_json = ConvertTo-Json $hash -Compress

# write
if($org_json -ne $upd_json) {
	Hash-To-Ini -hash (encrypt-dir $hash) -ini "$base_dir\config.ini"
}

# check data dir
if(!($hash.db_data_dir -and (Test-Path $hash.db_data_dir))) {
	$v = Browser-Folder "Select a database data folder" $base_dir
	if(!$v) {
		[Environment]::Exit(0)
	}
	$hash.db_data_dir = $v
}

# check project dir
if(!($hash.project_dir -and (Test-Path $hash.project_dir))) {
	$v = Browser-Folder "Select a project folder" $base_dir
	if(!$v) {
		[Environment]::Exit(0)
	}
	$hash.project_dir = $v
}

# check vhosts dir
if(!($hash.vhosts_dir -and (Test-Path $hash.vhosts_dir))) {
	$v = Browser-Folder "Select a vhosts folder" $base_dir
	if(!$v) {
		[Environment]::Exit(0)
	}
	$hash.vhosts_dir = $v
}

$pro_json = ConvertTo-Json $hash -Compress

# write
if($upd_json -ne $pro_json) {
	Hash-To-Ini -hash (encrypt-dir $hash) -ini "$base_dir\config.ini"
}
