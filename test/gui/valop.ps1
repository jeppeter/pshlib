

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

function _get_rowidx_keyname($keyname)
{
    $c = "rowidx_{0}" -f $keyname;
    return $c.Replace(" ", "_");
}


Set-Variable DOWNLOAD_ITEM_NAME -option Constant -Value "{374DE290-123F-4565-9164-39C4925E467B}";
Set-Variable SAVED_GAME_ITEM_NAME -option Constant -Value "{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}";
Set-Variable CONTACTS_ITEM_NAME -option Constant -Value "{56784854-C6CB-462B-8169-88E350ACB882}";
Set-Variable SEARCH_ITEM_NAME -option Constant -Value "{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}";
Set-Variable LINK_ITEM_NAME -option Constant -Value "{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}";

$userprofile = (Get-Item env:"USERPROFILE").Value;
Set-Variable DEFAULT_PERSONAL_DIR -option Constant -Value ("{0}\Documents" -f $userprofile);
Set-Variable DEFAULT_DESKTOP_DIR -option Constant -Value ("{0}\Desktop" -f $userprofile);
Set-Variable DEFAULT_FAVORITES_DIR -option Constant -Value ("{0}\Favorites" -f $userprofile);
Set-Variable DEFAULT_MYMUSIC_DIR -option Constant -Value ("{0}\Music" -f $userprofile);
Set-Variable DEFAULT_MYPIC_DIR -option Constant -Value ("{0}\Pictures" -f $userprofile);
Set-Variable DEFAULT_MYVIDEO_DIR -option Constant -Value ("{0}\Video" -f $userprofile);
Set-Variable DEFAULT_DOWNLOADS_DIR -option Constant -Value ("{0}\Downloads" -f $userprofile);
Set-Variable DEFAULT_SAVEDGAMES_DIR -option Constant -Value ("{0}\Saved Games" -f $userprofile);
Set-Variable DEFAULT_CONTACTS_DIR -option Constant -Value ("{0}\Contacts" -f $userprofile);
Set-Variable DEFAULT_SEARCHES_DIR -option Constant -Value ("{0}\Searches" -f $userprofile);
Set-Variable DEFAULT_LINKS_DIR -option Constant -Value ("{0}\Links" -f $userprofile);
Set-Variable DEFAULT_COOKIES_DIR -option Constant -Value ("{0}\AppData\Roaming\Microsoft\Windows\Cookies" -f $userprofile);
Set-Variable DEFAULT_CACHE_DIR -option Constant -Value ("{0}\AppData\Local\Microsoft\Windows\Temporary Internet Files" -f $userprofile);
Set-Variable DEFAULT_HISTORY_DIR -option Constant -Value ("{0}\AppData\Local\Microsoft\Windows\History" -f $userprofile);
Set-Variable DEFAULT_RECENT_DIR -option Constant -Value ("{0}\AppData\Roaming\Microsoft\Windows\Recent" -f $userprofile);
Set-Variable DEFAULT_TEMP_DIR -option Constant -Value ("{0}\AppData\Local\Temp" -f $userprofile);
Set-Variable DEFAULT_APPDATA_DIR -option Constant -Value ("{0}\AppData\Roaming" -f $userprofile);


$lower_alpha_lists="abcdefghijklmnopqrstuvwxyz";
$higher_alpha_lists="ABCDEFGHIJKLMNOPQRSTUVWXYZ";

function get_next_char($c) {
    if ($c -ge 'a' -And $c -le 'z') {
        $idx = 0;
        for($idx =0 ; $idx -lt $lower_alpha_lists.Length ;$idx ++) {
            if ($lower_alpha_lists[$idx] -eq $c) {
                break;
            }
        }
        if ($idx -lt ($lower_alpha_lists.Length - 1)) {
            return $lower_alpha_lists[($idx+1)];
        } else {
            return $lower_alpha_lists[0];
        }
        
    } elseif (($c -ge 'A' -And $c -le 'Z')) {
        $idx = 0;
        for($idx =0 ; $idx -lt $lower_alpha_lists.Length ;$idx ++) {
            if ($lower_alpha_lists[$idx] -eq $c) {
                break;
            }
        }
        if ($idx -lt ($higher_alpha_lists.Length - 1)) {
            return $higher_alpha_lists[($idx+1)];
        } else {
            return $higher_alpha_lists[0];
        }

    } 
    return $c;    
}
