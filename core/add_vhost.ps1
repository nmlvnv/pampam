. "$((get-item $PSScriptRoot).Fullname)\functions.ps1"
. "$((get-item $PSScriptRoot).Fullname)\config.ps1"

Powershell.exe -WindowStyle hidden -Command 'clear'

# input dialog: enter domain

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Add a vhost'
$form.Size = New-Object System.Drawing.Size(300,160)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,90)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'Add'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,90)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,10)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter domain:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($textBox)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(190,40)
$label.Size = New-Object System.Drawing.Size(80,20)
$label.Text = '.dev.win'
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,65)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Only accept alphabet, dot, underscore and hyphen'
$form.Controls.Add($label)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})

$result = $form.ShowDialog()

for (;;)
{
	if ($result -eq [System.Windows.Forms.DialogResult]::OK)
	{
		$domain = $textBox.Text
		if($domain -match '^[a-z0-9\._\-]*$') {
			# check vhost file exist
			if (Test-Path -Path "$vhosts_dir\$domain.conf") {
				[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
				[System.Windows.Forms.MessageBox]::Show($this, "The domain `"$domain.dev.win`" is used. Type other domain.")
				$result = $form.ShowDialog()
			} else {
				$domain_std = "$domain.dev.win"
				break
			}
		} else {
			$result = $form.ShowDialog()
		}
	} else {
		exit
	}
}

# browser dir: enter webroot dir
$webroot_dir = Browser-Folder "Select a webroot folder" $project_dir
if($webroot_dir) {
	# auto detect project_dir if exists then replace by `${project_dir}
	$webroot_dir_std = $webroot_dir.replace($project_dir, '${project_dir}')
} else {
	exit
}

# create index.php
if (-Not (Test-Path -Path "$webroot_dir\index.php")) {
	Mutex-Write "$webroot_dir\index.php" '<?php echo $_SERVER["SERVER_NAME"]; phpinfo();'
}

$map = "127.0.0.1 $domain_std"

# show alert: require admin
Add-Type -AssemblyName 'PresentationFramework'
$title = 'Add map "' + $map + '" to hosts'
$message = $title + ".`r`nThis will require Administrator Privileges.`r`nContinue?"
$result = [System.Windows.MessageBox]::Show($message, $title, 'YesNo');
if ($result -ne 'Yes') {
	exit
}

$map = "`r`n$map"

# append to hosts
$path = "$($Env:windir)\System32\drivers\etc\hosts"
Try
{
	Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList ("-WindowStyle hidden -NoLogo -NoProfile -ExecutionPolicy Bypass -Command `"& { '$map' | Out-File '$path' -Append -NoClobber -Encoding Default }`"")
}
Catch [System.Management.Automation.RuntimeException]
{
	$_.Exception.Message
	exit
}

# create file in vhosts dir
$test_conf = & "$((get-item $PSScriptRoot).Fullname)\test_conf.ps1"
$new_conf = $test_conf
$new_conf = $new_conf.replace('${project_dir}/test', $webroot_dir_std.replace('\', '/'))
$new_conf = $new_conf.replace('test.dev.win', $domain_std)
Mutex-Write "$vhosts_dir\$domain.conf" $new_conf

$arr_status = & "$((get-item $PSScriptRoot).Fullname)\status.ps1" silent
$str_status = $arr_status -join "`r`n"
& "$((get-item $PSScriptRoot).Fullname)\stop.ps1" silent
if(!$str_status.contains(" not ")) {
	& "$((get-item $PSScriptRoot).Fullname)\start.ps1" silent
}