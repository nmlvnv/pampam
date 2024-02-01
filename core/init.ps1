& "$((get-item $PSScriptRoot).Fullname)\check.ps1"
. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\config.ps1"

if (-Not (Test-Path -Path $temp_dir)) {
	mkdir $temp_dir | Out-Null
}

if (-Not (Test-Path -Path $log_dir)) {
	mkdir $log_dir | Out-Null
}
if (-Not (Test-Path -Path $profile_dir)) {
	mkdir $profile_dir | Out-Null
}
if (-Not (Test-Path -Path $session_dir)) {
	mkdir $session_dir | Out-Null
}

if (-Not (Test-Path -Path $version_dir)) {
	mkdir $version_dir | Out-Null
}

if (-Not (Test-Path -Path "$project_dir\test")) {
	mkdir "$project_dir\test" | Out-Null
}

# only create once not update
if (-Not (Test-Path -Path "$project_dir\test\index.php")) {
	Mutex-Write "$project_dir\test\index.php" '<?php echo $_SERVER["SERVER_NAME"]; phpinfo();'
}

# only create once not update
if (-Not (Test-Path -Path "$vhosts_dir\test.conf")) {
	$test_conf = & "$((get-item $PSScriptRoot).Fullname)\test_conf.ps1"
	Mutex-Write "$vhosts_dir\test.conf" $test_conf
}

# only create once not update
if (-Not (Test-Path -Path "$base_dir\auto_prepend_file.php")) {
	Mutex-Write "$base_dir\auto_prepend_file.php" "<?php`r`n"
}

# valid ssl certifiate
& "$((get-item $PSScriptRoot).Fullname)\trust.ps1" | Out-Null

# httpd conf
& "$core_dir\edit_httpd_conf.ps1" "$httpd_dir\conf\httpd.conf"

# mariadb conf
$path = "$mariadb_dir\my.ini"
if (Test-Path -Path $path) {
	$content = [System.IO.File]::ReadAllText($path)
	
	# edit some configs
	if(-Not $content.Contains(";;Edited;;")) {
		$content += "`r`n" + ";;Edited;;"
		# here
	}
	
	# edited again
	$content = $content -replace '(datadir\s*=\s*)".*"', ('$1"' + $db_data_dir.replace('\', '\\') + '"')
} else {
	$content = "";
	$content += "`r`n" + '[mysqld]'
	$content += "`r`n" + 'character-set-server=utf8mb4'
	$content += "`r`n" + 'skip_name_resolve=on'
	$content += "`r`n" + 'skip_grant_tables=on'
	$content += "`r`n" + 'innodb_file_per_table=on'
	$content += "`r`n" + 'datadir="' + $db_data_dir.replace('\', '\\') + '"'
}
# update or create
Mutex-Write $path $content

# php conf
$content = "";
if (Test-Path -Path "$php_dir\php5apache2_4.dll") {
	$content += "`r`n" + 'LoadModule php5_module "${php_dir}\php5apache2_4.dll"'
}
if (Test-Path -Path "$php_dir\php7apache2_4.dll") {
	$content += "`r`n" + 'LoadModule php7_module "${php_dir}\php7apache2_4.dll"'
}
if (Test-Path -Path "$php_dir\php8apache2_4.dll") {
	$content += "`r`n" + 'LoadModule php_module "${php_dir}\php8apache2_4.dll"'
}
$content += "`r`n" + 'PHPIniDir "${php_dir}"'
$content = $content.trim() + "`r`n"

# always overwrite to updated latest
Mutex-Write "$php_dir\httpd-php.conf" $content

& "$core_dir\copy_php_ini.ps1" "$php_dir\php.ini-development" "$php_dir\php.ini"

# add test to hosts
& "$((get-item $PSScriptRoot).Fullname)\test_to_hosts.ps1" | Out-Null

# update environment variable Path
$path = [System.Environment]::getEnvironmentVariable('Path', 'User')
if(!($path.contains($php_dir) -and $path.contains("$mariadb_dir\bin"))) {
	# check only dir
	$ds = Get-ChildItem -Path $version_dir -Name -Directory
	# clear others
	foreach ($item in $ds)
	{ 
	  if($item -match '^mariadb-') {
		$path = $path.replace("$version_dir\$item\bin", '')
	  }
	  if($item -match '^php-') {
		$path = $path.replace("$version_dir\$item", '')
	  }
	}
	# clear itself
	$path = $path.replace($php_dir, '').replace("$mariadb_dir\bin", '')
	# add both again
	$path = $path.trim(';', '\', '/') + ";$php_dir;$mariadb_dir\bin;"
	# update to environment
	[System.Environment]::SetEnvironmentVariable('Path', $path, 'User')
	$env:PATH = [System.Environment]::getEnvironmentVariable('Path', 'Machine') + ";" + [System.Environment]::getEnvironmentVariable('Path', 'User')
}