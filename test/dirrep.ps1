Param(
    $Name,
    $NewDir)

function get_value_global($varname)
{
    $v = Get-Variable -Name $varname -ValueOnly -Scope Global; 
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

function copy_dir($sourcedir,$destdir)
{
    $ret=0;
    $Error.clear();
    $v = Copy-Item -Path $sourcedir -Destination $destdir -Recurse -PassThru -ErrorAction SilentlyContinue;
    for($i=0;$i -lt $Error.Count; $i++) {
        $curerr = $Error[$i];
        $vcce = ($curerr.FullyQualifiedErrorId  | Out-String) ;
        $lowervcce = $vcce.ToLower();
        if ( -Not ($lowervcce.StartsWith("copydirectoryinfoitemioerror,") -Or $lowervcce.StartsWith("directoryexist,"))) {
            write_stderr -msg "[$i]"+($curerr | Out-String) ;
            $ret = 2;
        }
    }
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



function backup_directory($keyname,$newdir)
{
    $shellval = get_shell_folder_value -keyname $keyname;
    $vn = _get_shell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $shellval;
    $usershellval = get_user_shell_folder_value -keyname $keyname;
    $vn = _get_usershell_value_keyname -keyname $keyname;
    set_value_global -varname $vn -varvalue $usershellval;

    if (-Not [string]::IsNullOrEmpty($usershellval) -And -Not [string]::IsNullOrEmpty($shellval)) {
        if ($usershellval != $shellval) {
            write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
            return 3;
        }
        $exval = [System.Environment]::ExpandEnvironmentVariables($usershellval);
        $cmdv = "cmd /c `"rmdir /s /q `"{0}`"`"" -f $exval;
        $cmdk = _get_rmtask_keyname -keyname $keyname;
        $rmtaskname = _get_rmtask_keyname -keyname $keyname;
        $v = get_value_global -varname $rmtaskname;
        if ([string]::IsNullOrEmpty($v)) {
            write_stderr -msg "rmtask [$keyname] already set";
            return 4;
        }

        $v = add_once_task -taskname $cmdk -directory $exval;
        if ([string]::IsNullOrEmpty($v)) {
            return 5;
        }
        set_value_global -varname $rmtaskname -varvalue $v;

    } else if (-Not [string]::IsNullOrEmpty($usershellval) -Or -Not [string]::IsNullOrEmpty($shellval)) {
        write_stderr -msg "usershellval[$keyname][$usershellval] != shellval[$keyname][$shellval]";
        return 2;
    }

    # now we should copy the directory
}