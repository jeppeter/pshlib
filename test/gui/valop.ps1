

function get_value_global($varname)
{
    $v = Get-Variable -Name $varname -ValueOnly -Scope Global -ErrorAction SilentlyContinue; 
    return $v;
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


