Param(
    $TaskName,
    $RemoveDir)


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

function set_runonce_task($taskname,$taskvalue)
{
    $v = get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $taskname;
    if (-Not [string]::IsNullOrEmpty($v)) {
        [Console]::Error.WriteLine.Invoke("[$TaskName] has already");
        $v = "";
    } else {
        $retval = set_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $taskname -value $taskvalue;
        Write-Host "retval [$retval]";
        if ($retval -eq 0) {
            $v = $taskname;
        } else {
            $v = "";
        }
    }
    return $v;
}

function add_once_task($taskname,$directory)
{
    $taskvalue = "cmd.exe /c `"rmdir /s /q `"{0}`"`"" -f $directory
    return set_runonce_task -taskname $taskname -taskvalue $taskvalue
}



$v = add_once_task -taskname $TaskName -directory $RemoveDir;
Write-Host "set [$TaskName].[$RemoveDir] [$v]";
