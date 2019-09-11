Param(
    $SD);


function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    return;
}


function get_link_type($dir)
{
    if (Test-Path -pathtype container $dir) {
        return "container";
    }
    return "not container";
}

$v = get_link_type -dir $SD;
Write-Host "with [$SD] [$v]";