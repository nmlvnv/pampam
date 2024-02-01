. "$((get-item $PSScriptRoot).Fullname)\config_static.ps1"

Set-Location -Path $version_dir

$list = Get-ChildItem . -Filter *.zip
foreach ($f in $list){
	$type = $f.name -replace '^([^-]*)-.*','$1'
	$name = $f.name -replace '^(.*)\.zip$','$1'
	Switch ($type)
	{
		"httpd" {
			if(!(Test-Path $name)) {
				$form = Show-Processing "Expanding $($f.name)"
				Expand-Archive "$($f.name)" -DestinationPath "$name-temp"
				mv "$name-temp\Apache24" "$name"
				Remove-Item -LiteralPath "$name-temp" -Force -Recurse
				Remove-Item "$($f.name)"
				Hide-Processing $form
			}
			Break
		}
		"mariadb" {
			if(!(Test-Path $name)) {
				$form = Show-Processing "Expanding $($f.name)"
				Expand-Archive "$($f.name)" -DestinationPath "."
				Remove-Item "$($f.name)"
				Hide-Processing $form
			}
			Break
		}
		"php" {
			if(!(Test-Path $name)) {
				$form = Show-Processing "Expanding $($f.name)"
				Expand-Archive "$($f.name)" -DestinationPath "$name"
				Remove-Item "$($f.name)"
				Hide-Processing $form
			}
			Break
		}
	}
}
