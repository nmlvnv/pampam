. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\config.ps1"

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
if($args.Count -ne 1) {
	[System.Windows.Forms.MessageBox]::Show($this, "Missed Argument")
	return
}

$configPath = $Args[0]

# load content into a string
$content = [System.IO.File]::ReadAllText($configPath)

# add new
if(-Not $content.Contains("##Added##")) {
$content +=
@"
`r`n
##Added##

SSLSessionCache "shmcb:$($log_dir.replace('\', '/'))/ssl_scache"
SSLSessionCacheTimeout  300

ServerName localhost
Listen 443
AddType application/x-httpd-php .php

Define ssl_dir "$($ssl_dir.replace('\', '/'))"
Define php_dir "$($php_dir.replace('\', '/'))"
Define project_dir "$($project_dir.replace('\', '/'))"

Include "$($php_dir.replace('\', '/'))/httpd-php.conf"
Include "$($vhosts_dir.replace('\', '/'))/*.conf"
"@
}

# edit some configs
if(-Not $content.Contains("##Edited##")) {
	$content += "`r`n" + "##Edited##"

	$content = $content -replace '((?:\r\n|\r|\n)\s*)(ServerRoot)', '$1#$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)(DocumentRoot)', '$1#$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+access_compat_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+expires_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+lbmethod_byrequests_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+proxy_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+proxy_balancer_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+proxy_http_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+proxy_http2_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+proxy_wstunnel_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+rewrite_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+slotmem_shm_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+socache_shmcb_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)#(LoadModule\s+ssl_module)', '$1$2'
	$content = $content -replace '((?:\r\n|\r|\n)\s*)(DirectoryIndex\s+index.html)', '$1$2 index.php'
}

# editted again
$content = $content -replace '(SSLSessionCache\s+"shmcb:).*(\\ssl_scache")', ('$1' + $log_dir.replace('\', '/') + '$2')
$content = $content -replace '(ErrorLog\s+).*([\r\n]+)', ('$1"' + $log_dir.replace('\', '/') + '/error.log"$2')
$content = $content -replace '(CustomLog\s+).*(\s+common)', ('$1"' + $log_dir.replace('\', '/') + '/access.log"$2')
$content = $content -replace '(Define\s+ssl_dir\s+)".*"', ('$1"' + $ssl_dir.replace('\', '/') + '"')
$content = $content -replace '(Define\s+php_dir\s+)".*"', ('$1"' + $php_dir.replace('\', '/') + '"')
$content = $content -replace '(Define\s+project_dir\s+)".*"', ('$1"' + $project_dir.replace('\', '/') + '"')
$content = $content -replace '(Include\s+").*(\/httpd\-php\.conf")', ('$1' + $php_dir.replace('\', '/') + '$2')
$content = $content -replace '(Include\s+").*(?:vh|host).*(\/\*\.conf")', ('$1' + $vhosts_dir.replace('\', '/') + '$2')

# end with new line
$content = $content.trim() + "`r`n"

# update the file
Mutex-Write $configPath $content
