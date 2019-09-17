

function set_reg_value($path,$key,$value)
{
    $retval=0;
    $Error.clear();
    $kv = Set-ItemProperty -Path $path -Name $key  -Value $value -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        write_stderr -msg ($Error| Format-List | Out-String);
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
        write_stderr -msg ($Error| Format-List | Out-String);
    }
    return $retval;
}

function del_reg_value($path,$key)
{
    $retval=0;
    $Error.clear();
    Remove-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        for($i=0; $i -lt $Error.Count; $i++) {
            $curerr = $Error[$i];
            $vcce = ($curerr.FullyQualifiedErrorId | Out-String);
            $lowervcce = $vcce.ToLower();
            if (-Not $lowervcce.StartsWith("system.management.automation.psargumentexception,")) {
                write_stderr -msg "[$i]"+($Error | Format-List | Out-String);
                $retval = 2;
            }
        }
    }
    return $retval;
}

function get_rmtask_value($keyname)
{
    $rmname = _get_rmtask_keyname -keyname $keyname;
    return get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $rmname;
}


function set_runonce_task($taskname,$taskvalue)
{
    $v = get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $taskname;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$TaskName] has already";
        $v = "";
    } else {
        $olderror = _copy_error -v $Error;
        $Error.clear();
        $c = Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce";
        if ($Error.Count -gt 0) {
            $Error.clear();
            $c = New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce";
            if  ($Error.Count -gt 0) {
                $Error = _copy_error -v $olderror;
                return "";
            }
        }

        $retval = set_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $taskname -value $taskvalue;
        if ($retval -eq 0) {
            $v = $taskname;
        } else {
            $v = "";
        }
        $Error = _copy_error -v $olderror;
    }
    return $v;
}

function add_once_task($taskname,$directory)
{
    $taskvalue = "cmd.exe /q /c `"rmdir /s /q `"{0}`"`"" -f $directory;
    return set_runonce_task -taskname $taskname -taskvalue $taskvalue;
}


function remove_once_task($taskname)
{
    return del_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $taskname;
}


function get_shell_folder_value($keyname)
{
    return get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -key $keyname;
}

function del_shell_folder_value($keyname)
{
    return del_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -key $keyname;
}

function set_shell_folder_value($keyname,$value)
{
    return set_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -key $keyname -value $value;
}



function get_user_shell_folder_value($keyname)
{
    return get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -key $keyname;
}

function del_user_shell_folder_value($keyname)
{
    return del_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -key $keyname;
}

function set_user_shell_folder_value($keyname,$value)
{
    return set_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -key $keyname -value $value;
}

function get_env_value($keyname)
{
    return get_reg_value -path "HKCU:\Environment" -key $keyname;
}

function del_env_value($keyname)
{
    return del_reg_value -path "HKCU:\Environment" -key $keyname;
}

function set_env_value($keyname,$value)
{
    return set_reg_value -path "HKCU:\Environment" -key $keyname -value $value;
}

function add_task_keyname($keyname,$dir)
{
    $cmdk = _get_rmtask_keyname -keyname $keyname;
    $v = get_value_global -varname $cmdk;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "has already set rmtask[temp] [$cmdk] [$v]";
        return -6;
    }

    $v = add_once_task -taskname $cmdk -directory $dir;
    if ([string]::IsNullOrEmpty($v)) {
        return -4;
    }
    set_value_global -varname $cmdk -varvalue $v;
    return 0;
}

function remove_task_keyname($keyname)
{
    $vn = _get_rmtask_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have set
        $c = remove_once_task -taskname $v;
        # we do not remove it double
        $c = set_value_global -varname $vn -varvalue "";
    }
    return;
}

