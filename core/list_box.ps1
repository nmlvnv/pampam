# https://learn.microsoft.com/en-us/powershell/scripting/samples/selecting-items-from-a-list-box?view=powershell-5.1

function list-box {
	param ($title, $desc, $items, $selected = "")
	
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = $title
	$form.Size = New-Object System.Drawing.Size(410,200)
	$form.StartPosition = 'CenterScreen'

	$okButton = New-Object System.Windows.Forms.Button
	$okButton.Location = New-Object System.Drawing.Point(75,125)
	$okButton.Size = New-Object System.Drawing.Size(75,23)
	$okButton.Text = 'Select'
	$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $okButton
	$form.Controls.Add($okButton)

	$cancelButton = New-Object System.Windows.Forms.Button
	$cancelButton.Location = New-Object System.Drawing.Point(250,125)
	$cancelButton.Size = New-Object System.Drawing.Size(75,23)
	$cancelButton.Text = 'Cancel'
	$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $cancelButton
	$form.Controls.Add($cancelButton)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10)
	$label.Size = New-Object System.Drawing.Size(410,30)
	$label.Text = $desc
	$form.Controls.Add($label)

	$listBox = New-Object System.Windows.Forms.ListBox
	$listBox.Location = New-Object System.Drawing.Point(10,45)
	$listBox.Size = New-Object System.Drawing.Size(400,20)
	$listBox.Height = 80

	foreach($item in $items)
	{
		[void] $listBox.Items.Add($item)
	}
	
	if($items -contains $selected) {
		$listBox.SelectedItem = $selected
	}

	$form.Controls.Add($listBox)

	$form.Topmost = $true

	$result = $form.ShowDialog()

	for (;;)
	{
		if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
			if($listBox.SelectedItem) {
				return $listBox.SelectedItem;
			} else {
				$result = $form.ShowDialog()
			}
		} else {
			return ""
		}
	}
}