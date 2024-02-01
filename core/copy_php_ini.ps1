. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\config.ps1"

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
if($args.Count -ne 2) {
	[System.Windows.Forms.MessageBox]::Show($this, "Missed Argument")
	return
}

$inputPath = $Args[0]
$outputPath = $Args[1]

# load content into a string
if (Test-Path -Path $outputPath) {
	$content = [System.IO.File]::ReadAllText($outputPath)
} else {
	$content = [System.IO.File]::ReadAllText($inputPath)
}

# add new
if(-Not $content.Contains(";;Added;;")) {
	$content += "`r`n" + ";;Added;;"
	$content += "`r`n" + "[xdebug]"
	$content += "`r`n" + "xdebug.remote_enable = on"
	$content += "`r`n" + "xdebug.remote_connect_back = on"
	$content += "`r`n" + "xdebug.remote_handler = dbgp"
	$content += "`r`n" + "xdebug.remote_port = 9000"
	$content += "`r`n" + "xdebug.remote_autostart = on"
	$content += "`r`n" + "xdebug.profiler_enable = on "
	$content += "`r`n" + "xdebug.profiler_enable_trigger = off "
	$content += "`r`n" + "xdebug.profiler_output_dir = `"" + $profile_dir.replace('\', '\\') + "`""
	$content += "`r`n" + "xdebug.default_enable = off"
}

# edit some configs
if(-Not $content.Contains(";;Edited;;")) {
	$content += "`r`n" + ";;Edited;;"
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension_dir\s*=\s*"ext")', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*curl)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*fileinfo)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*gd)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*mbstring)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*openssl)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*pdo_mysql)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*php_curl)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*php_fileinfo)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*php_gd)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*php_mbstring)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*php_openssl)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*extension\s*=\s*php_pdo_mysql)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*);(\s*date.timezone\s*=)', '$1$2 Asia/HO_CHI_MINH'
}

# edited again
$content = $content -replace '((?:\r\n|\r|\n)\s*);?(\s*session.save_path\s*=\s*)"[^;]*"', ('$1$2"' + $session_dir.replace('\', '\\') + '"')
$content = $content -replace '((?:\r\n|\r|\n)\s*)(\s*xdebug.profiler_output_dir\s*=\s*)".*"', ('$1$2"' + $profile_dir.replace('\', '\\') + '"')
$content = $content -replace '(\s*auto_prepend_file\s*=).*([\r\n]+)', ('$1"' + $base_dir.replace('\', '\\') + '\\auto_prepend_file.php"$2')

# end with new line
$content = $content.trim() + "`r`n"

# create new output file
Mutex-Write $outputPath $content
