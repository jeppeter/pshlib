# for source dir

Param(
    $Sourcedir,
    $Destdir,
    $FileAppend)


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
    #$f = get_value_global -varname "globa_append_file";
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
    #if (-Not [string]::IsNullOrEmpty($f)) {
        #$msg | Out-File -FilePath $f -Append -ErrorAction SilentlyContinue ;
        $msg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
    return;
}

function write_stdout($msg)
{
    [Console]::Out.WriteLine.Invoke($msg);
    #$f = get_value_global -varname "globa_append_file";
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
    #if (-Not [string]::IsNullOrEmpty($f)) {
        #$msg | Out-File -FilePath $f -Append -ErrorAction SilentlyContinue ;
        $msg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
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
    $c = "shell_value_{0}" -f $keyname;
    return $c.Replace(" ","_");
}

function _get_usershell_value_keyname($keyname)
{
    $c = "usershell_value_{0}" -f $keyname;
    return $c.Replace(" ","_");
}

function _get_rmtask_keyname($keyname)
{
    $c = "rmtask_name_{0}" -f $keyname;
    return $c.Replace(" ","_");
}

function _get_newdir_keyname($keyname)
{
    $c = "newdir_{0}" -f $keyname;
    return $c.Replace(" ","_");
}

function _get_shellval_setted_keyname($keyname)
{
    $c = "shellval_setted_{0}" -f $keyname;
    return $c.Replace(" ","_");
}

function _get_usershellval_setted_keyname($keyname)
{
    $c = "usershellval_setted_{0}" -f $keyname;
    return $c.Replace(" ","_");
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


function backup_temp($newdir)
{
    $diffed = 0;
    $vn = _get_shellval_setted_keyname -keyname "temp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "environment [temp] has already setted";
        return -3;
    }

    $tempval = get_env_value -keyname "temp";
    $vn = _get_shell_value_keyname -keyname "temp";
    $c = set_value_global -varname $vn -varvalue $tempval;
    $vn = _get_shellval_setted_keyname -keyname "temp";
    $c = set_value_global -varname $vn -varvalue "1";

    $tmpval = get_env_value -keyname "tmp";
    $vn = _get_shellval_setted_keyname -keyname "tmp";
    $c = set_value_global -varname $vn -varvalue $tmpval;
    $vn = _get_shellval_setted_keyname -keyname "tmp";
    $c = set_value_global -varname $vn -varvalue "1";

    $extmpval= "";
    $extempval = "";

    if (-Not [string]::IsNullOrEmpty($tmpval) -And -Not [string]::IsNullOrEmpty($tempval)) {
        $extmpval = [System.Environment]::ExpandEnvironmentVariables($tmpval);
        $extempval = [System.Environment]::ExpandEnvironmentVariables($tempval);
        if (-Not $extmpval.Equals($extempval)) {
            write_stderr -msg "[TMP].[$extmpval] != [TEMP].[$extempval]";
            return -5;
        }
    } elseif (-Not [string]::IsNullOrEmpty($tmpval)) {
        $extmpval = [System.Environment]::ExpandEnvironmentVariables($tmpval);
    } elseif (-Not [string]::IsNullOrEmpty($tempval)) {
        $extmpval = [System.Environment]::ExpandEnvironmentVariables($tempval);
    }

    if (-Not [string]::IsNullOrEmpty($extmpval)) {
        if (-Not $newdir.Equals($extmpval)) {
            # now we should give the compare
            $retval = add_task_keyname -keyname "temp" -dir $extmpval;
            if ($retval -lt 0) {
                return $retval;
            }

            $retval = copy_dir_top -srcdir $extmpval -dstdir $newdir;
            if ($retval -lt 0) {
                return -3;
            }
            $diffed = 1;
        }
    } else {
        $retval = remove_dir -dir $newdir;
        if ($retval -ne 0) {
            return -5;
        }
        $retval = make_dir_safe -dir $newdir;
        if ($retval -ne 0) {
            return -6;
        }
        $diffed = 1;
    }

    if ($diffed) {
        $vn = _get_newdir_keyname -keyname "temp";
        set_value_global -varname $vn -varvalue $newdir;

        $retval = set_env_value -keyname "temp" -value $newdir;
        if ($retval -ne 0) {
            return -6;
        }

        $retval = set_env_value -keyname "tmp" -value $newdir;
        if ($retval -ne 0) {
            return -7;
        }
    }


    return $diffed;
}


function restore_temp()
{

    $c = remove_task_keyname -keyname "temp";

    $vn = _get_shellval_setted_keyname -keyname "temp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname "temp";
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_env_value -keyname "temp";
        } else {
            set_env_value -keyname "temp" -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname "temp";
        set_value_global -varname $vn -varvalue "";
    }


    $vn = _get_shellval_setted_keyname -keyname "tmp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        # have setted
        $vn = _get_shell_value_keyname -keyname "tmp";
        $v = get_value_global -varname $vn;
        if ([string]::IsNullOrEmpty($v)) {
            del_env_value -keyname "tmp";
        } else {
            set_env_value -keyname "tmp" -value $v;
        }
        $vn = _get_shellval_setted_keyname -keyname "tmp";
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_newdir_keyname -keyname "temp";
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $c = remove_dir -dir $v;
        $c = set_value_global -varname $vn -varvalue "";
    }
    return;
}



function backup_spec($keyname,$itemname,$newdir)
{
    write_stdout -msg "keyname[$keyname] itemname[$itemname] newdir[$newdir]";
    $diffed = 0;


    $vn = _get_shellval_setted_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        write_stderr -msg "already set [$keyname]";
        return -3;
    }

    $shellval = get_shell_folder_value -keyname $itemname;
    write_stdout -msg "shell[$keyname].[$itemname]=[$shellval]";
    $vn = _get_shell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $shellval;
    $vn = _get_shellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue "1";

    $usershellval = get_user_shell_folder_value -keyname $itemname;
    write_stdout -msg "usershell[$keyname].[$itemname]=[$shellval]";
    $vn = _get_usershell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $usershellval;
    $vn = _get_usershellval_setted_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue "1";




    $exshellval = "";
    $exusershellval = "";

    if ( -Not [string]::IsNullOrEmpty($shellval)  -And -Not [string]::IsNullOrEmpty($usershellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($shellval);
        $exusershellval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
        if (-Not $exshellval.Equals($exusershellval)) {
            write_stderr -msg "keyname[$keyname].item[$itemname] usershell[$usershellval] != shellval[$shellval]";
            return -3;
        }
    } elseif (-Not [string]::IsNullOrEmpty($shellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($shellval);
    } elseif (-Not [string]::IsNullOrEmpty($usershellval)) {
        $exshellval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
    }

    if (-Not [string]::IsNullOrEmpty($exshellval)) {
        if (-Not $exshellval.Equals($newdir)) {

            # first to add remove disk
            $cmdk = _get_rmtask_keyname -keyname $keyname;
            $v = get_value_global -varname $cmdk;
            if (-Not [string]::IsNullOrEmpty($v)) {
                write_stderr -msg "has already set rmtask[$keyname] [$cmdk] [$v]";
                return -6;
            }


            $v = add_once_task -taskname $cmdk -directory $exshellval;
            if ([string]::IsNullOrEmpty($v)) {
                return -4;
            }
            set_value_global -varname $cmdk -varvalue $v;

            # now to copy 
            $retval = copy_dir_top -srcdir $exshellval -dstdir $newdir;
            if ($retval -lt 0) {
                return -7;
            }
            $diffed=1;
        }
    } else {
        $retval = make_dir_safe -dir $newdir;
        if ($retval -ne 0) {
            return -3;
        }
        $diffed=1;
    }

    if ($diffed) {
        $vn = _get_newdir_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue $newdir;

        $retval = set_shell_folder_value -keyname $itemname -value $newdir;
        if ($retval -ne 0) {
            return -6;
        }

        $retval = set_user_shell_folder_value -keyname $itemname -value $newdir;
        if ($retval -ne 0) {
            return -7;
        }
    }
    return $diffed;
}


function restore_spec($keyname,$itemname)
{
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
            del_shell_folder_value -keyname $itemname;
        } else {
            set_shell_folder_value -keyname $itemname -value $v;
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
            del_user_shell_folder_value -keyname $itemname;
        } else {
            set_user_shell_folder_value -keyname $itemname -value $v;
        }
        $vn = _get_usershellval_setted_keyname -keyname $keyname;
        set_value_global -varname $vn -varvalue "";
    }

    $vn = _get_newdir_keyname -keyname $keyname;
    $v = get_value_global -varname $vn;
    if (-Not [string]::IsNullOrEmpty($v)) {
        $c = remove_dir -dir $v;
        $c = set_value_global -varname $vn -varvalue "";
    }
    return;
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

        write_stdout -msg "exshellval [$exshellval] newdir [$newdir]";
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
            if ($retval -lt 0) {
                return -3;
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
        $v = remove_dir -dir $v;
        $v = set_value_global -varname $vn -varvalue "";
    }
    return;
}

function usage_format($usagestr) {
    $retstr = "";
    if (![string]::IsNullOrEmpty($usagestr)) {
        $retstr += $usagestr;
        $retstr += "`n";
    }

    $retstr += "copydir sourcedir destdir`n";
    write_stdout -msg "retstr`n[$retstr]";

    return $retstr;
}

function Usage($ec,$usagestr)
{
    $v = usage_format -usagestr $usagestr;
    $func = [Console]::Error.WriteLine;
    if ($ec -eq 0) {
        $func = [Console].WriteLine;
    } 
    $func.Invoke($v);    
    [Environment]::Exit($ec);
}


if ([string]::IsNullOrEmpty($Sourcedir) -Or [string]::IsNullOrEmpty($Destdir)) {
    Usage -ec 3 -usagestr "need source and dest";
}

$retval  = copy_dir_top -srcdir $Sourcedir -dstdir  $Destdir;


write_stdout -msg "retval [$retval]";