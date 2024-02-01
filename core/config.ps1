. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\config_static.ps1"

# configuration variables
$hash = decrypt-dir (Ini-To-Hash -ini "$base_dir\config.ini")
foreach ($h in $hash.Keys) {
	New-Variable -Name "$h" -Value $($hash.$h)
}

foreach($type in @('httpd','mariadb','php'))
{
	$cv = $hash.($type + '_version')
	$valid_type = $cv -match "^$type-"
	$valid_dir = Test-Path -Path "$version_dir\$cv"
	
	if($valid_type -and $valid_dir) {
		continue
	} else {
		"$type_version '$cv' is invalid"
		[Environment]::Exit(0)
	}
}

if(!($hash.db_data_dir -and (Test-Path $hash.db_data_dir))) {
	"db_data_dir '$($hash.db_data_dir)' is invalid"
	[Environment]::Exit(0)
}

if(!($hash.project_dir -and (Test-Path $hash.project_dir))) {
	"project_dir '$($hash.project_dir)' is invalid"
	[Environment]::Exit(0)
}

if(!($hash.vhosts_dir -and (Test-Path $hash.vhosts_dir))) {
	"vhosts_dir '$($hash.vhosts_dir)' is invalid"
	[Environment]::Exit(0)
}

# $variables built base on configuration variables
$httpd_dir = "$version_dir\$httpd_version"
$mariadb_dir = "$version_dir\$mariadb_version"
$php_dir = "$version_dir\$php_version"