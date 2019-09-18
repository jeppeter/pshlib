


function _my_file_name()
{
    return $MyInvocation.ScriptName;
}

function get_current_file_dir()
{
# Determine script location for PowerShell
    $curpath = _my_file_name;
    return Split-Path $curpath;
}

Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.drawing;


. ("{0}\valop.ps1" -f (get_current_file_dir));
. ("{0}\fileop.ps1" -f (get_current_file_dir));
. ("{0}\regop.ps1" -f (get_current_file_dir));
. ("{0}\backupop.ps1" -f (get_current_file_dir));



function set_datagrid_rowidx($grid,$keyname)
{
    $vn = _get_rowidx_keyname -keyname $keyname;
    $val = $grid.RowCount - 1;
    set_value_global -varname $vn -varvalue $val;
    write_stdout -msg "insert[$keyname]idx[$val]";
    return $val;

}

function add_grid_row($grid,$chked,$keyname,$shellval,$img,$readonly)
{
    $grid.Rows.Add($chked,$keyname,$shellval,$img);
    $idx = $grid.RowCount - 1;
    $grid.Rows[$idx].Cells[0].ReadOnly = $readonly;
    return set_datagrid_rowidx -grid $grid -keyname $keyname;
}


function insert_datagrid_common($grid,$chked,$keyname,$okimg,$wrongimg, $defval)
{
    $rmval = get_rmtask_value -keyname $keyname;
    $shellval = get_shell_folder_value -keyname $keyname;
    if ( [string]::IsNullOrEmpty($shellval)) {
        $shellval = $defval;
    }
    if (-Not [string]::IsNullOrEmpty($rmval)) {
        return add_grid_row -grid $grid -chked $false -keyname $keyname -shellval $shellval -img $wrongimg -readonly $true;
    } 
    return add_grid_row -grid $grid -chked $chked -keyname $keyname -shellval $shellval -img $okimg -readonly $false;
}

function insert_datagrid_spec($grid,$chked,$keyname,$itemname,$okimg,$wrongimg,$defval)
{
    $rmval = get_rmtask_value -keyname $keyname;
    $shellval = get_shell_folder_value -keyname $itemname;
    if ( [string]::IsNullOrEmpty($shellval)) {
        $shellval = $defval;
    }
    if (-Not [string]::IsNullOrEmpty($rmval)) {
        return add_grid_row -grid $grid -chked $false -keyname $keyname -shellval $shellval -img $wrongimg -readonly $true;
    }
    return add_grid_row -grid $grid -chked $chked -keyname $keyname -shellval $shellval -img $okimg -readonly $false;
}

function insert_datagrid_env($grid,$chked,$keyname,$okimg,$wrongimg,$defval)
{
    $rmval = get_rmtask_value -keyname $keyname;
    $shellval = get_env_value -keyname $keyname;
    if ( [string]::IsNullOrEmpty($shellval)) {
        $shellval = $defval;
    }
    if (-Not [string]::IsNullOrEmpty($rmval)) {
        return add_grid_row -grid $grid -chked $false -keyname $keyname -shellval $shellval -img $wrongimg -readonly $true;
    }
    return add_grid_row -grid $grid -chked $chked -keyname $keyname -shellval $shellval -img $okimg -readonly $false;   
}



$mainfrm = New-Object System.Windows.Forms.Form;
$mainfrm.Text = "idvtools 1.0";
$mainfrm.Name = "mainframe";
$mainfrm.DataBindings.DefaultDataSourceUpdateMode = 0;


$maintabctrl = New-object System.Windows.Forms.TabControl;
$syspage = New-Object System.Windows.Forms.TabPage;
$backuppage = New-Object System.Windows.Forms.TabPage;

$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState;

Set-Variable MAIN_FRAME_WIDTH -option Constant -Value 700;
Set-Variable MAIN_FRAME_HEIGHT -option Constant -Value 650;
Set-Variable TABCTRL_WIDTH -option Constant -Value ($MAIN_FRAME_WIDTH - 25);
Set-Variable TABCTRL_HEIGHT -option Constant -Value ($MAIN_FRAME_HEIGHT - 250);

Set-Variable DATAGRID_WIDTH -option Constant -Value ($TABCTRL_WIDTH - 25);
Set-Variable DATAGRID_HEIGHT -option Constant -Value ($TABCTRL_HEIGHT - 50 );

$mainfrm_drawing_size = New-Object System.Drawing.Size;
$mainfrm_drawing_size.Width = $MAIN_FRAME_WIDTH;
$mainfrm_drawing_size.Height = $MAIN_FRAME_HEIGHT;
$mainfrm.ClientSize = $mainfrm_drawing_size;
$mainfrm_fixed_size = New-Object System.Drawing.Size;
$mainfrm_fixed_size.Width = ($MAIN_FRAME_WIDTH + 25);
$mainfrm_fixed_size.Height = $MAIN_FRAME_HEIGHT;
$mainfrm.minimumSize = $mainfrm_fixed_size;
$mainfrm.maximumSize = $mainfrm_fixed_size;

$maintabctrl.DataBindings.DefaultDataSourceUpdateMode = 0;
$tabctrl_drawing_point = New-Object System.Drawing.Point;
$tabctrl_drawing_point.X = 20;
$tabctrl_drawing_point.Y = 20;
$maintabctrl.Location = $tabctrl_drawing_point;

$tabctrl_drawing_size = New-Object System.Drawing.Size;
$tabctrl_drawing_size.Height = $TABCTRL_HEIGHT;
$tabctrl_drawing_size.Width = $TABCTRL_WIDTH;
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
$datagrid_size.Width = $DATAGRID_WIDTH;
$datagrid_size.Height = $DATAGRID_HEIGHT;
$datagrid.Size = $datagrid_size;
$datagrid.MultiSelect = $false;
$datagrid.ColumnHeadersVisible = $true;
$datagrid.RowHeadersVisible = $false;
$datagrid.AllowUserToAddRows = $false;
$datagrid.AllowUserToDeleteRows = $false;
$backuppage.Controls.Add($datagrid);

$wrongimghdl = get_file_img -file ("{0}\wrong.png" -f (get_current_file_dir));
$rightimghdl = get_file_img -file ("{0}\right.png" -f (get_current_file_dir));


function insert_grid_columns($grid)
{
    # to first insert column
    #$v = $grid.Columns.Clear();

    $colchk = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn;
    $colname = New-Object System.Windows.Forms.DataGridViewTextboxColumn;
    $colpath = New-Object System.Windows.Forms.DataGridViewTextboxColumn;
    $colimg = New-Object System.Windows.Forms.DataGridViewImageColumn;

    $colchk.Width = 40;
    $colname.Width = 80;
    $colpath.Width = 430;
    $colimg.Width = 80;

    #$grid.ColumnHeadersVisible = $true;

    # name 设置
    $colchk.Name = "$([char]0x8bbe)$([char]0x7f6e)";
    $colchk.ReadOnly = $false;
    # name 名称
    $colname.Name = "$([char]0x540d)$([char]0x79f0)";
    $colname.ReadOnly = $true;
    # name 路径
    $colpath.Name = "$([char]0x8def)$([char]0x5f84)";
    $colpath.ReadOnly = $true;
    # name 允许编辑
    $colimg.Name="$([char]0x5141)$([char]0x8bb8)$([char]0x7f16)$([char]0x8f91)";
    $colimg.ReadOnly = $true;

    $grid.Columns.Add($colchk);
    $grid.Columns.Add($colname);
    $grid.Columns.Add($colpath);
    $grid.Columns.Add($colimg);

    return;
}

function refresh_grid($grid,$okimg,$wrongimg) 
{
    $grid.Rows.Clear();    

    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Personal" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_PERSONAL_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Desktop" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_DESKTOP_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Favorites" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_FAVORITES_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "My Music" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_MYMUSIC_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "My Pictures" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_MYPIC_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "My Video" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_MYVIDEO_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Cookies" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_COOKIES_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Cache" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_CACHE_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "History" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_HISTORY_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Recent" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_RECENT_DIR;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "AppData" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_APPDATA_DIR;

    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "download" -itemname $DOWNLOAD_ITEM_NAME -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_DOWNLOADS_DIR;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "savedgames" -itemname $SAVED_GAME_ITEM_NAME -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_SAVEDGAMES_DIR;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "contacts" -itemname $CONTACTS_ITEM_NAME -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_CONTACTS_DIR;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "search" -itemname $SEARCH_ITEM_NAME -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_SEARCHES_DIR;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "link" -itemname $LINK_ITEM_NAME -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_LINKS_DIR;

    $v = insert_datagrid_env -grid $grid -chked $true -keyname "temp" -okimg $okimg -wrongimg $wrongimg -defval $DEFAULT_TEMP_DIR;

    $grid.Refresh();
    return ;
}

$v = insert_grid_columns -grid $datagrid;
$v = refresh_grid -grid $datagrid -okimg $rightimghdl -wrongimg $wrongimghdl;

$datagrid.Refresh();
$mainfrm.ShowDialog() | Out-Null;
