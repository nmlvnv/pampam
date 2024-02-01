Powershell.exe -WindowStyle hidden -Command 'clear'

$map = '127.0.0.1 test.dev.win'
$map_regex = '\r\n\s*127.0.0.1\s+test.dev.win\s*\r\n'
$path = "$($Env:windir)\System32\drivers\etc\hosts"

if($args.Count -eq 0) {
	$content = Get-Content $path | Out-String
	if("`r`n$content`r`n" -match $map_regex) {
		return
	}
	
	Add-Type -AssemblyName 'PresentationFramework'
	$title = 'Add map "' + $map + '" to hosts'
	$message = $title + ".`r`nThis will require Administrator Privileges.`r`nContinue?"
	$result = [System.Windows.MessageBox]::Show($message, $title, 'YesNo');
	if ($result -ne 'Yes') {
		return
	}

	Try
	{
		Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList ('-WindowStyle hidden -NoLogo -NoProfile -ExecutionPolicy Bypass -file "' + $myinvocation.MyCommand.Definition + '" done')
	}
	Catch [System.Management.Automation.RuntimeException]
	{
		$_.Exception.Message
	}
	return
}

"`r`n" + $map | Out-File $path -Append -NoClobber -Encoding Default
