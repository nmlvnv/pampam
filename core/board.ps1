Powershell.exe -WindowStyle hidden -Command 'clear'

. "$((get-item $PSScriptRoot).Fullname)\init.ps1"

$procs = Get-WmiObject Win32_Process -Filter "name = 'powershell.exe'"  -ErrorAction SilentlyContinue

$count = 0;
foreach($proc in $procs) {
	if($proc.CommandLine.Contains($myinvocation.MyCommand.Definition)) {
		$count++
	}
}

if($count -gt 1) {
	[Environment]::Exit(0)
}

$starting = $false
Function do_start
{
	if($starting) {
		return
	}
	$starting = $true
	$statusLabel.Text = 'Starting...'
	& "$((get-item $PSScriptRoot).Fullname)\start.ps1" silent
	$starting = $false
	get_config_info
}

Function do_stop
{
	$statusLabel.Text = 'Stopping...'
	& "$((get-item $PSScriptRoot).Fullname)\stop.ps1" silent
}

Function check_status
{
	$arr =  & "$((get-item $PSScriptRoot).Fullname)\status.ps1" silent
	$statusLabel.Text = $arr -join "`r`n`r`n"
}

Function add_vhost
{
	& "$((get-item $PSScriptRoot).Fullname)\add_vhost.ps1"
}

Function change_version
{
	param ($type)
	
	& "$((get-item $PSScriptRoot).Fullname)\change_version.ps1" $type
	get_config_info
}

Function change_dir
{
	param ($type)
	
	& "$((get-item $PSScriptRoot).Fullname)\change_dir.ps1" $type
	get_config_info
}

Function get_config_info() {
	$hash = decrypt-dir (Ini-To-Hash -ini "$base_dir\config.ini")

	$info = ""
	foreach ($h in $hash.Keys) {
		$info += $h.replace('_', ' ') + " : " + $hash.$h + "`r`n`r`n"
	}
	
	$info += "base dir : $base_dir"
	
	$infoLabel.Text = $info.trim()
}

Add-Type -AssemblyName System.Windows.Forms 
Add-Type -AssemblyName System.Drawing.Font
Add-Type -AssemblyName System.Drawing

# sizes
$margin = 15
$y = 0
$padding = 15

# Build Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "PamPam"
$Form.Size = New-Object System.Drawing.Size(560, 440)
$Form.StartPosition = "CenterScreen"
$Form.MaximizeBox = $False
$Form.MinimizeBox = $False
$Form.FormBorderStyle = "FixedDialog"
$Form.Topmost = $False

$y_c = $y + 13
$height_c = 20
$padding_c = 9
$i_c = 0

# Add Button
$c1Button = New-Object System.Windows.Forms.Button
$c1Button.Location = New-Object System.Drawing.Point($margin, $y_c)
$c1Button.Size = New-Object System.Drawing.Size(60, $height_c)
$c1Button.Text = "Change"
$c1Button.Add_Click({change_version "httpd"})
$Form.Controls.Add($c1Button)

$i_c++

# Add Button
$c2Button = New-Object System.Windows.Forms.Button
$c2Button.Location = New-Object System.Drawing.Point($margin, ($y_c + $height_c * $i_c + $padding_c * $i_c))
$c2Button.Size = New-Object System.Drawing.Size(60, $height_c)
$c2Button.Text = "Change"
$c2Button.Add_Click({change_version "mariadb"})
$Form.Controls.Add($c2Button)

$i_c++

# Add Button
$c3Button = New-Object System.Windows.Forms.Button
$c3Button.Location = New-Object System.Drawing.Point($margin, ($y_c + $height_c * $i_c + $padding_c * $i_c))
$c3Button.Size = New-Object System.Drawing.Size(60, $height_c)
$c3Button.Text = "Change"
$c3Button.Add_Click({change_version "php"})
$Form.Controls.Add($c3Button)

$i_c++

# Add Button
$c4Button = New-Object System.Windows.Forms.Button
$c4Button.Location = New-Object System.Drawing.Point($margin, ($y_c + $height_c * $i_c + $padding_c * $i_c))
$c4Button.Size = New-Object System.Drawing.Size(60, $height_c)
$c4Button.Text = "Change"
$c4Button.Add_Click({change_dir "db_data"})
$Form.Controls.Add($c4Button)

$i_c++

# Add Button
$c5Button = New-Object System.Windows.Forms.Button
$c5Button.Location = New-Object System.Drawing.Point($margin, ($y_c + $height_c * $i_c + $padding_c * $i_c))
$c5Button.Size = New-Object System.Drawing.Size(60, $height_c)
$c5Button.Text = "Change"
$c5Button.Add_Click({change_dir "project"})
$Form.Controls.Add($c5Button)

$i_c++

# Add Button
$c6Button = New-Object System.Windows.Forms.Button
$c6Button.Location = New-Object System.Drawing.Point($margin, ($y_c + $height_c * $i_c + $padding_c * $i_c))
$c6Button.Size = New-Object System.Drawing.Size(60, $height_c)
$c6Button.Text = "Change"
$c6Button.Add_Click({change_dir "vhosts"})
$Form.Controls.Add($c6Button)

# Add Label
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Location = New-Object System.Drawing.Point(($margin + 73), $margin)
$infoLabel.Size = New-Object System.Drawing.Size(520, ($height = 210))
$infoLabel.Text = ""
$infoLabel.Font = New-Object System.Drawing.Font("Lucida Console",11,[System.Drawing.FontStyle]::Regular)
$form.Controls.Add($infoLabel)

$y += $margin + $height

$hlLabel = New-Object System.Windows.Forms.Label
$hlLabel.Location = New-Object System.Drawing.Point($margin, $y)
$hlLabel.Size = New-Object System.Drawing.Size(500, 2)
$hlLabel.Text = ''
$hlLabel.BorderStyle = 'Fixed3D'
$hlLabel.AutoSize = $false
$form.Controls.Add($hlLabel)

$y += 15

# Add Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(($margin + 170), $y)
$statusLabel.Size = New-Object System.Drawing.Size(260, ($height = 60))
$statusLabel.Text = 'Checking...'
$statusLabel.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Regular)
$form.Controls.Add($statusLabel)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000
$timer.add_tick({check_status})
$timer.start()

$y += $height
$y += 8

# Add Button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Location = New-Object System.Drawing.Point(($margin + 130), $y)
$startButton.Size = New-Object System.Drawing.Size(120, ($height = 23))
$startButton.Text = "Start"
$startButton.Add_Click({do_start})
$Form.Controls.Add($startButton)

# Add Button
$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Location = New-Object System.Drawing.Point(($margin + $padding + 120 + 130), $y)
$stopButton.Size = New-Object System.Drawing.Size(120, ($height = 23))
$stopButton.Text = "Stop"
$stopButton.Add_Click({do_stop})
$Form.Controls.Add($stopButton)

$y += $height
$y += $padding

$hl2Label = New-Object System.Windows.Forms.Label
$hl2Label.Location = New-Object System.Drawing.Point($margin, $y)
$hl2Label.Size = New-Object System.Drawing.Size(500, 2)
$hl2Label.Text = ''
$hl2Label.BorderStyle = 'Fixed3D'
$hl2Label.AutoSize = $false
$form.Controls.Add($hl2Label)

$y += 15

# Add Button
$vhostButton = New-Object System.Windows.Forms.Button
$vhostButton.Location = New-Object System.Drawing.Point(($margin + 200), $y)
$vhostButton.Size = New-Object System.Drawing.Size(120, ($height = 23))
$vhostButton.Text = "Add a virtual host"
$vhostButton.Add_Click({add_vhost})

$y += $height
$y += $margin

$Form.Controls.Add($vhostButton)

# update status at very begin
check_status

# get versions
get_config_info

# Show the Form
$form.ShowDialog()| Out-Null