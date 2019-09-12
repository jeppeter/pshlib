Param(
    $Name,
    $NewDir)

function get_value_global($varname)
{
    $v = Get-Variable -Name $varname -ValueOnly -Scope Global -ErrorAction SilentlyContinue; 
    return $v;
}

function set_value_global($varname,$varvalue)
{
    Set-Variable -Name $varname -Value $varvalue -Scope Global
}


function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    return;
}

function write_stdout($msg)
{
    [Console]::Out.WriteLine.Invoke($msg);
    return;
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
    $n = New-Item  -ItemType "directory" -Path $dir -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        write_stderr -msg "make [$dir] error`n" + ($Error | Format-List | Out-String);
        $Error = _copy_error -v $olderror;
        return 2;
    }

    $Error = _copy_error -v $olderror;
    return $ret;
}



function get_child_items($dir)
{
    $olderror = _copy_error -v $Error;
    $Error.clear();
    $retval = Get-ChildItem -Path $dir -ErrorAction SilentlyContinue -Force;
    if ($Error.Count -gt 0) {
        for($i=0;$i -lt $Error.Count;$i ++) {
            $vs = ($curerr | Out-String);
            $curerr = $Error[$i];
            $vcce = ($curerr.FullyQualifiedErrorId  | Out-String);
            $lowervcce = $vcce.ToLower();
            write_stderr -msg "[$i]------------------access [$dir]";
            if (-Not $lowervcce.StartsWith("dirunauthorizedaccesserror,")) {
                write_stderr -msg "[$i]------------------";
                write_stderr -msg $vs;
                write_stderr -msg "++++++++++++++++++++++";
            }
        }
    }

    $Error = _copy_error -v $olderror;
    return $retval;
}

function copy_dir_recur($basedir,$curitem,$newargv)
{
    $cnt = 0;
    if (-Not $curitem) {
        return $cnt;
    }
    #$c = ($curitem | Format-List | Out-String);
    #write_stdout -msg $c;
    if (-Not (Test-Path -Path $newargv)) {
        write_stdout -msg "create [$newargv]";
        $retval = make_dir_safe -dir $newargv;
        if ($retval -ne 0) {
            return -1;
        }
        $cnt ++;
    }
    if (-Not $curitem.Name) {
        return $cnt;
    }
    if ($curitem.Name.Equals(".") -Or $curitem.Name.Equals("..")) {
        return $cnt;
    }
    $name = $curitem.Name;
    write_stdout -msg "[$basedir] new [$name]";
    $wholepath = Join-Path -Path $basedir -ChildPath $name;
    if (Test-Path -Path $wholepath -PathType container) {
        write_stdout -msg "[$wholepath] is dir newargv[$newargv]";
        $newdir = Join-Path -Path $newargv -ChildPath $name;
        $retval = handle_directory_callback ${function:\copy_dir_recur} -dir $wholepath -argv  $newdir;
        if ($retval -lt 0) {
            return $retval;
        }
    } else {
        write_stdout -msg "[$wholepath] is not dir newargv[$newargv]";
        $srcfile = Join-Path -Path $basedir -ChildPath $name;
        $dstfile = Join-Path -Path $newargv -ChildPath $name;
        $olderror = _copy_error -v $Error;
        write_stdout -msg "[$srcfile]=>[$dstfile]";
        $Error.clear();
        $v = Copy-Item -Path $srcfile -Destination $dstfile -Recurse -ErrorAction SilentlyContinue;
        if ($Error.Count -gt 0) {
            for ($i=0 ; $i -lt $Error.Count ;$i++) {
                write_stderr -msg "[$i]-----------($srcfile) => ($dstfile)";
                write_stderr -msg ($Error[$i] | Out-String);
            }
        } else {
            $cnt ++;
        }

        $Error = _copy_error -v $olderror;
    }
    return $cnt;
}


function handle_directory_callback($function,$dir,$argv)
{
    $retval = 0;
    $cnt = 0;

    $olderror = _copy_error -v $Error;

    $items =  get_child_items($dir);

    foreach($i in $items) {
        $ret = Invoke-Command $function -ArgumentList $dir,$i,$argv;
        if ($ret -lt 0) {            
            return $ret;
        }
        $cnt += $ret;
    }

    $Error = _copy_error -v $olderror;
    return $cnt;
}

function copy_dir_top($srcdir,$dstdir)
{
    if (-Not (Test-Path -Path $srcdir -PathType Container)) {
        return -1;
    }
    if (-Not (Test-Path -Path $dstdir -PathType Container)) {
        $retval = make_dir_safe -dir $dstdir;
        if ($retval -ne 0) {
            return -2;
        }
    }
    return handle_directory_callback ${function:\copy_dir_recur} -dir $srcdir -argv  $dstdir;
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
    write_stdout -msg "keyname [$keyname] newdir [$newdir]";
    $diffed = 0;
    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "[$keyname] has already done";
        return -2;
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
        return -2;
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
            return -3;
        }
        if (-Not $exshellval.Equals($newdir)) {
            $cmdk = _get_rmtask_keyname -keyname $keyname;
            $v = get_value_global -varname $cmdk;
            if (-Not [string]::IsNullOrEmpty($v)) {
                write_stderr -msg "rmtask [$keyname] already set";
                return -4;
            }

            $v = add_once_task -taskname $cmdk -directory $exshellval;
            if ([string]::IsNullOrEmpty($v)) {
                return -5;
            }
            set_value_global -varname $cmdk -varvalue $v;            
        }

    } elseif (-Not [string]::IsNullOrEmpty($usershellval) -Or -Not [string]::IsNullOrEmpty($shellval)) {
        write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
        return -2;
    }


    # now we should copy the directory
    if ([string]::IsNullOrEmpty($exshellval)) {
        $retval = make_dir_safe -dir $newdir;        
        if ($retval -ne 0) {
            return -3;
        }
        $diffed = 1;
    } else {
        if(-Not $exshellval.Equals($newdir)) {
            $retval = copy_dir_top -srcdir $exshellval -dstdir $newdir;
            if ($retval -ne 0) {
                return 3;
            }
            $diffed = 1;
        }        
    }

    if ($diffed) {
        $vn = _get_newdir_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue $newdir;

        $retval = set_shell_folder_value -keyname $keyname -value $newdir;
        if ($retval -ne 0) {
            return -6;
        }

        $retval = set_user_shell_folder_value -keyname $keyname -value $newdir;
        if ($retval -ne 0) {
            return -7;
        }        
    }


    return $diffed;
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

$retval = backup_directory -keyname $Name -newdir $NewDir;
if ($retval -lt 0) {
    restore_directory -keyname $Name;
}

Write-Host "total ret[$retval]";

[Environment]::Exit($retval);