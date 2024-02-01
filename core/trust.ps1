if($args.Count -eq 0) {	
	$verify = certutil -verifystore root '*.dev.win'
	if(($verify -join ' ').Contains('Serial Number:')) {
		return
	}
	
	Add-Type -AssemblyName 'PresentationFramework'
	$title = "Enable Valid SSL Certificate"
	$message = "Enable Valid SSL Certificate.`r`nThis will require Administrator Privileges.`r`nContinue?"
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

$ssl_dir = (get-item $PSScriptRoot).Fullname

certutil -addstore root "$ssl_dir\star_ca.pem" | Out-Null
