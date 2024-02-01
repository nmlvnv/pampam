# static variables
$container_dir = (get-item $PSScriptRoot).parent.parent.Fullname
$base_dir = (get-item $PSScriptRoot).parent.Fullname
$core_dir = (get-item $PSScriptRoot).Fullname

$ssl_dir = $core_dir

$version_dir = "$base_dir\versions"
$temp_dir = "$base_dir\temp"

$log_dir = "$temp_dir\log"
$profile_dir = "$temp_dir\profiler"
$session_dir = "$temp_dir\session"