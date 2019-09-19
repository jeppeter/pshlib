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

$setitem="";

Set-Variable DOWNLOAD_ITEM_NAME -option Constant -Value "{374DE290-123F-4565-9164-39C4925E467B}";
Set-Variable SAVED_GAME_ITEM_NAME -option Constant -Value "{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}";
Set-Variable CONTACTS_ITEM_NAME -option Constant -Value "{56784854-C6CB-462B-8169-88E350ACB882}";
Set-Variable SEARCH_ITEM_NAME -option Constant -Value "{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}";
Set-Variable LINK_ITEM_NAME -option Constant -Value "{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}";


if ($Name.Equals("download")) {
    $setitem=$DOWNLOAD_ITEM_NAME;
} elseif ($Name.Equals("savedgame")) {
    $setitem=$SAVED_GAME_ITEM_NAME;
} elseif ($Name.Equals("contacts")) {
    $setitem=$CONTACTS_ITEM_NAME;
} elseif ($Name.Equals("search")) {
    $setitem=$SEARCH_ITEM_NAME;
} elseif ($Name.Equals("link")) {
    $setitem=$LINK_ITEM_NAME;
}


if ([string]::IsNullOrEmpty($setitem)) {
    write_stderr -msg "not support name [$Name]";
    [Environment]::Exit(5);
}

$retval = backup_spec -keyname $Name -itemname $setitem -newdir $NewDir;
if ($retval -lt 0) {
    restore_spec -keyname $Name -itemname $setitem;
}

Write-Host "[$Name]total ret[$retval]";

[Environment]::Exit($retval);