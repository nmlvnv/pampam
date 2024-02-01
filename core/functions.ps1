. "$((get-item $PSScriptRoot).Fullname)\config_static.ps1"

Function Mutex-Write
{
	param ($file, $content)

	$mtx = New-Object System.Threading.Mutex($false, "MutexWrite")
	if ($mtx.WaitOne(10000)) {
		[System.IO.File]::WriteAllText($file, $content)
		[void]$mtx.ReleaseMutex()
	}
	else {
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
		[System.Windows.Forms.MessageBox]::Show($this, "Timed out acquiring mutex.")
		$mtx.Dispose()
		[Environment]::Exit(0)
    }
	$mtx.Dispose()
}

# portable: run without selecting dirs again if dirs in base dir, container dir
function encrypt-dir {
	param($hash)

	$output = [ordered]@{}
	foreach ($h in $hash.Keys) {
		$output.$h = ($hash.$h).replace($base_dir, '$base_dir').replace($container_dir, '$container_dir')
	}

	return $output
}

function decrypt-dir {
	param($hash)

	$output = [ordered]@{}
	foreach ($h in $hash.Keys) {
		$output.$h = ($hash.$h).replace('$base_dir', $base_dir).replace('$container_dir', $container_dir)
	}

	return $output
}

function Ini-To-Hash {
    param ($ini)
    
	if (Test-Path -Path $ini) {
		$hash = Get-Content $ini | ConvertFrom-StringData
	} else {
		$hash = [ordered]@{}
	}
	
	$output = [ordered]@{}
	ForEach ($h in $hash.Keys) {$output.$h = $hash.$h.trim('"', ' ')}
	
	return $output
}

function Hash-To-Ini {
    param ($hash, $ini)
	
	# not decrypted because it's in writing function
	$old_hash = Ini-To-Hash -ini $ini

	if (Test-Path -Path $ini) {
		$content = [System.IO.File]::ReadAllText($ini)
	} else {
		$content = ""
	}

	$content = "`r`n$content`r`n"
	
	foreach ($h in $hash.Keys) {
		if($old_hash.Keys -contains $h){
			$content = $content -replace ('([\r\n]+\s*' + $h + '\s*=\s*).*(\s*[\r\n]+)'), ('$1"' + $hash.$h.replace('\', '\\') + '"$2')
		} else {
			$content += $h + ' = "' + $hash.$h.replace('\', '\\') + '"' + "`r`n"
		}
	}
	
	Mutex-Write $ini $content.trim()
}

Function Merge-Hashtables {
    $merged = [ordered]@{}
    ForEach ($hash in ($Input + $Args)) {
        ForEach ($h in $hash.Keys) {$merged.$h = $hash.$h}
    }
	
    return $merged
}

Function Browser-Folder
{
	param ($desc, $start = "")
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $browser = New-Object System.Windows.Forms.FolderBrowserDialog
    $browser.Description = $desc
    $browser.rootfolder = "MyComputer"
    $browser.SelectedPath = $start
	
	$result = $browser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))

	for (;;)
	{
		if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
			if($browser.SelectedPath) {
				return $browser.SelectedPath;
			} else {
				$result = $browser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
			}
		} else {
			return ""
		}
	}
}

Function Show-Processing {
	param($title)
	
	$title += " ..."

	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = $title
	$form.Size = New-Object System.Drawing.Size(260,100)
	$form.StartPosition = 'CenterScreen'
	$form.MaximizeBox = $false
	$form.MinimizeBox = $false
	$form.ControlBox = $false
	$form.FormBorderStyle = "FixedDialog"
	$form.Topmost = $true

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,20)
	$label.Size = New-Object System.Drawing.Size(240,20)
	$label.Text = $title
	
	$form.Controls.Add($label)

	$form.Show($this)
	
	Start-Sleep -Milliseconds 100

	return $form
}

Function Hide-Processing {
	param($form)
	
	$form.Close()
}

