
function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
        $msg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
    return;
}

function write_stdout($msg)
{
    [Console]::Out.WriteLine.Invoke($msg);
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
        $msg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
    return;
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

function get_shell_folder_value($keyname)
{
    return get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -key $keyname;
}

function get_user_shell_folder_value($keyname)
{
    return get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -key $keyname;
}

function _get_rmtask_keyname($keyname)
{
    $c = "rmtask_name_{0}" -f $keyname;
    return $c.Replace(" ","_");
}

function get_rmtask_value($keyname)
{
    $rmname = _get_rmtask_keyname -keyname $keyname;
    return get_reg_value -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -key $rmname;
}

function get_env_value($keyname)
{
    return get_reg_value -path "HKCU:\Environment" -key $keyname;
}

function insert_datagrid($grid,$chked,$itemname,$path,$ischanged)
{
    
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




Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.drawing;




$mainfrm = New-Object System.Windows.Forms.Form;
$mainfrm.Text = "idvtools 1.0";
$mainfrm.Name = "mainframe";
$mainfrm.DataBindings.DefaultDataSourceUpdateMode = 0;


$maintabctrl = New-object System.Windows.Forms.TabControl;
$syspage = New-Object System.Windows.Forms.TabPage;
$backuppage = New-Object System.Windows.Forms.TabPage;

$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState;

$mainfrm_drawing_size = New-Object System.Drawing.Size;
$mainfrm_drawing_size.Width = 700;
$mainfrm_drawing_size.Height = 550;
$mainfrm.ClientSize = $mainfrm_drawing_size;
$mainfrm_fixed_size = New-Object System.Drawing.Size;
$mainfrm_fixed_size.Width = 725;
$mainfrm_fixed_size.Height = 550;
$mainfrm.minimumSize = $mainfrm_fixed_size;
$mainfrm.maximumSize = $mainfrm_fixed_size;

$maintabctrl.DataBindings.DefaultDataSourceUpdateMode = 0;
$tabctrl_drawing_point = New-Object System.Drawing.Point;
$tabctrl_drawing_point.X = 20;
$tabctrl_drawing_point.Y = 20;
$maintabctrl.Location = $tabctrl_drawing_point;

$tabctrl_drawing_size = New-Object System.Drawing.Size;
$tabctrl_drawing_size.Height = 400;
$tabctrl_drawing_size.Width = 675;
$maintabctrl.Size = $tabctrl_drawing_size;

$mainfrm.Controls.Add($maintabctrl);


$syspage.DataBindings.DefaultDataSourceUpdateMode = 0;
$syspage.UseVisualStyleBackColor = $True;
$syspage.Name = "syspagectrl";
# this is the chinese 系统
$syspage.Text = "$([char]0x7cfb)$([char]0x7edf)";;
$maintabctrl.Controls.Add($syspage);

$backuppage.DataBindings.DefaultDataSourceUpdateMode = 0;
$backuppage.UseVisualStyleBackColor = $True;
$backuppage.Name = "syspagectrl";
# this is the chinese 用户资料重定向
$backuppage.Text = "$([char]0x7528)$([char]0x6237)$([char]0x8d44)$([char]0x6599)$([char]0x91cd)$([char]0x5b9a)$([char]0x5411)";
$maintabctrl.Controls.Add($backuppage);


$datagrid = New-Object System.Windows.Forms.DataGridView;
$datagrid_point = New-Object System.Drawing.Point;
$datagrid_point.X = 10;
$datagrid_point.Y = 10;
$datagrid.Location = $datagrid_point;
$datagrid_size = New-Object System.Drawing.Size;
$datagrid_size.Width = 650;
$datagrid_size.Height = 350;
$datagrid.Size = $datagrid_size;
$datagrid.MultiSelect = $false;
$datagrid.ColumnHeadersVisible = $true;
$datagrid.RowHeadersVisible = $false;
$backuppage.Controls.Add($datagrid);


$mainfrm.ShowDialog() | Out-Null;
