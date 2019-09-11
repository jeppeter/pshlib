Param(
    $RegPath,
    $KeyName,
    $KeyValue)


function set_reg_value($path,$key,$value)
{
    $retval=0;
    $kv = Set-ItemProperty -Path $path -Name $key  -Value $value -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        [Console]::Error.WriteLine.Invoke(($Error| Format-List | Out-String));
        $retval=2;
    }
    return $retval;
}

$v = set_reg_value -path $RegPath -key $KeyName -value $KeyValue;
Write-Host "set [$RegPath].[$KeyName]=[$KeyValue] [$v]";