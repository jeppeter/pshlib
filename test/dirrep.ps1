Param(
    $Name,
    $NewDir)

function get_value_global($varname)
{
    $v = Get-Variable -Name $varname -ValueOnly -Scope Global -ErrorAction SilentlyContinue; 
    return $v;
}

function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    return;
}

function set_value_global($varname,$varvalue)
{
    Set-Variable -Name $varname -Value $varvalue -Scope Global
}

function _copy_error($v)
{
    $retv = @();
    for ($i = 0 ; $i -lt $v.Count ; $i++) {
        $retv = $retv + $v[$i];
    }
    return $retv;
}


function remove_dir($dir)
{
    $retval=0;
    $olderror = _copy_error -v $Error;
    if (Test-Path -Path $dir) {
        # if the directory exists
        $Error.clear();
        Remove-Item  $dir -ErrorAction SilentlyContinue -Recurse -Force;
        if ($Error.Count -gt 0) {
            write_stderr -msg ($Error | Format-List | Out-String);
            $retval = 2;
        }

    }
    $Error = _copy_error -v $olderror;
    return $retval;
}


function copy_dir($sourcedir,$destdir)
{
    $ret=0;
    $olderror = _copy_error -v $Error;
    $retval = remove_dir -dir $destdir;
    Write-Host "retval [$retval]";
    if ($retval -ne 0) {
        $Error = _copy_error -v $olderror;
        return $retval;
    }
    $Error.clear();
    Write-Host "Error count [" + $Error.Count + "]";
    $v = Copy-Item -Path $sourcedir -Destination $destdir -Recurse -ErrorAction SilentlyContinue;
    Write-Host "[$sourcedir] => [$destdir] [" + $Error.Count  +"]";
    Write-Host ($Error | Format-Table | Out-String);
    for($i=0;$i -lt $Error.Count; $i++) {
        $curerr = $Error[$i];
        $curfmt = ($curerr | Format-Table | Out-String);
        $vcce = ($curerr.FullyQualifiedErrorId  | Out-String) ;
        $lowervcce = $vcce.ToLower();
        write_stderr -msg "[$i] error `$lowervcce [$lowervcce]" + ($curerr | Out-String);
        if ( -Not ($lowervcce.StartsWith("copydirectoryinfoitemioerror,") -Or $lowervcce.StartsWith("directoryexist,") -Or $lowervcce.length -eq 0)) {
            write_stderr -msg "[$i]"+ $curfmt ;
            $ret = 2;
        }
    }
    $Error = _copy_error -v $olderror;
    return $ret;
}

function make_dir_safe($dir)
{
    $ret = 0;
    $olderror = _copy_error -v $Error;
    if (Test-Path -Path $dir) {
        $retval = remove_dir -dir $dir;
        if ($retval -ne 0) {
            return $retval;
        }
    }
    $Error.clear();
    New-Item  -ItemType "directory" -Path $dir -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        write_stderr -msg "make [$dir] error`n" + ($Error | Format-List | Out-String);
        $Error = _copy_error -v $olderror;
        return 2;
    }

    $Error = _copy_error -v $olderror;
    return $ret;
}


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



function set_runonce_task($taskname,$taskvalue)
{
    $v = get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $taskname;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$TaskName] has already";
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

function _get_shell_value_keyname($keyname)
{
    return "shell_value_{0}" -f $keyname;
}

function _get_usershell_value_keyname($keyname)
{
    return "usershell_value_{0}" -f $keyname;
}

function _get_rmtask_keyname($keyname)
{
    return "rmtask_name_{0}" -f $keyname;
}

function _get_newdir_keyname($keyname)
{
    return "newdir_{0}" -f $keyname;
}

function _get_shellval_setted_keyname($keyname)
{
    return "shellval_setted_{0}" -f $keyname;
}

function _get_usershellval_setted_keyname($keyname)
{
    return "usershellval_setted_{0}" -f $keyname;
}

function backup_directory($keyname,$newdir)
{

    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$keyname] has already done";
        return 2;
    }

    $shellval = get_shell_folder_value -keyname $keyname;
    $vn = _get_shell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $shellval;
    $vn = _get_shellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue "1";

    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$keyname] has already done";
        return 2;
    }

    $usershellval = get_user_shell_folder_value -keyname $keyname;
    $vn = _get_usershell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $usershellval;
    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn =varvalue "1";


    $exshellval = "";

    if (-Not [string]::IsNullOrEmpty($usershellval) -And -Not [string]::IsNullOrEmpty($shellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($shellval);
        $exusershellval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
        if (-Not $exusershellval.Equals($exshellval)) {
            write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
            return 3;
        }
        $cmdk = _get_rmtask_keyname -keyname $keyname;
        $v = get_value_global -varname $cmdk;
        if (-Not [string]::IsNullOrEmpty($v)) {
            write_stderr -msg "rmtask [$keyname] already set";
            return 4;
        }

        $v = add_once_task -taskname $cmdk -directory $exshellval;
        if ([string]::IsNullOrEmpty($v)) {
            return 5;
        }
        set_value_global -varname $cmdk -varvalue $v;

    } elseif (-Not [string]::IsNullOrEmpty($usershellval) -Or -Not [string]::IsNullOrEmpty($shellval)) {
        write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
        return 2;
    }

    Write-Host "call 1";

    # now we should copy the directory
    if ([string]::IsNullOrEmpty($exshellval)) {
        Write-Host "call 11";        
        $retval = make_dir_safe -dir $newdir;
        Write-Host "call 12";
    } else {
        Write-Host "call 13";
        $retval = copy_dir -sourcedir $exshellval -destdir $newdir;
        Write-Host "call 14";
    }

    Write-Host "call 1 retval[$retval]";
    if ($retval -ne 0) {
        return $retval;
    }

    Write-Host "call 2";

    $vn = _get_newdir_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $newdir;

    $retval = set_shell_folder_value -keyname $keyname -value $newdir;
    if ($retval -ne 0) {
        return $retval;
    }

    Write-Host "call 3";

    $retval = set_user_shell_folder_value -keyname $keyname -value $newdir;
    if ($retval -ne 0) {
        return $retval;
    }


    Write-Host "call 4";
    return 0;
}

function restore_directory($keyname)
{
    # first to get the taskname 
    $vn = _get_rmtask_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have set
        remove_once_task -taskname $v;
        # we do not remove it double
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname $keyname;
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_shell_folder_value -keyname $keyname;
        } else {
            set_shell_folder_value -keyname $keyname -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $vn = _get_usershell_value_keyname -keyname $keyname;
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_user_shell_folder_value -keyname $keyname;
        } else {
            set_user_shell_folder_value -keyname $keyname -value $v;
        }
        $vn = _get_usershellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }


    # now to make new directory
    $vn = _get_newdir_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        remove_dir($v);
        set_value_global -varname $vn -varvalue "";
    }
    return;
}

$retval = backup_directory -keyname $Name -NewDir $newdir;
if ($retval -ne 0) {
    restore_directory -keyname $Name;
}

Write-Host "total ret[$retval]";

[Environment]::Exit($retval);