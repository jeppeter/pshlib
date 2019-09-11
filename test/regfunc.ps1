Param(
    $RegPath,
    $KeyName,
    $KeyValue)


function set_reg_value($path,$key,$value)
{
    $retval=0;
    $Error.clear();
    $kv = Set-ItemProperty -Path $path -Name $key  -Value $value -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        [Console]::Error.WriteLine.Invoke(($Error| Format-List | Out-String));
        $retval=2;
    }
    return $retval;
}

function get_reg_value($path,$key)
{
    $retval="";
    $Error.clear();
    $kv = Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue;
    if ($Error.Count -eq 0) {
        $retval = $kv.$key.ToString();
    } else {
        [Console]::Error.WriteLine.Invoke(($Error| Format-List | Out-String));
    }
    return $retval;
}

function remove_reg_value($path,$key)
{
    $Error.clear();
}


$v = set_reg_value -path $RegPath -key $KeyName -value $KeyValue;
Write-Host "set [$RegPath].[$KeyName]=[$KeyValue] [$v]";