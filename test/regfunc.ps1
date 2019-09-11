Param(
    $RegPath,
    $KeyName)


function get_reg_value($path,$key)
{
    $retval="";
    $kv = Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue;
    if ($Error.Count -eq 0) {
        $retval = $kv.$key.ToString();
    } else {
        [Console]::Error.WriteLine.Invoke(($Error| Format-List | Out-String));
    }
    return $retval;
}

$v = get_reg_value -path $RegPath -key $KeyName;
Write-Host "get [$RegPath].[$KeyName]=[$v]";