


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
    return $val;

}


function insert_datagrid_common($grid,$chked,$keyname,$okimg,$wrongimg)
{
    $rmval = get_rmtask_value -keyname $keyname;
    $shellval = get_shell_folder_value -keyname $keyname;
    if (-Not [string]::IsNullOrEmpty($rmval)) {
        # now this is not allow to make value
        $grid.Rows.Add($false,$keyname,$shellval,$wrongimg);
        $idx = $grid.RowCount - 1;
        $grid.Rows[$idx].Cells[0].ReadOnly = $true;
    } else {
        $grid.Rows.Add($chked,$keyname,$shellval,$okimg);
        $idx = $grid.RowCount - 1;
        $grid.Rows[$idx].Cells[0].ReadOnly = $false;
    }
    $val = set_datagrid_rowidx -grid $grid -keyname $keyname;
    return $val;
}

function insert_datagrid_spec($grid,$chked,$keyname,$itemname,$okimg,$wrongimg)
{
    $rmval = get_rmtask_value -keyname $keyname;
    $shellval = get_shell_folder_value -keyname $itemname;
    if (-Not [string]::IsNullOrEmpty($rmval)) {
        # now this is not allow to make value
        $grid.Rows.Add($false,$keyname,$shellval,$wrongimg);
        $idx = $grid.RowCount - 1;
        $grid.Rows[$idx].Cells[0].ReadOnly = $true;
    } else {
        $grid.Rows.Add($chked,$keyname,$shellval,$okimg);
        $idx = $grid.RowCount - 1;
        $grid.Rows[$idx].Cells[0].ReadOnly = $false;
    }

    $val = set_datagrid_rowidx -grid $grid -keyname $keyname;
    return $val;
}

function insert_datagrid_env($grid,$chked,$keyname,$okimg,$wrongimg)
{
    $rmval = get_rmtask_value -keyname $keyname;
    $shellval = get_env_value -keyname $keyname;
    if (-Not [string]::IsNullOrEmpty($rmval)) {
        # now this is not allow to make value
        $grid.Rows.Add($false,$keyname,$shellval,$wrongimg);
        $idx = $grid.RowCount - 1;
        $grid.Rows[$idx].Cells[0].ReadOnly = $true;
    } else {
        $grid.Rows.Add($chked,$keyname,$shellval,$okimg);
        $idx = $grid.RowCount - 1;
        $grid.Rows[$idx].Cells[0].ReadOnly = $false;
    }

    $val = set_datagrid_rowidx -grid $grid -keyname $keyname;
    return $val;
}



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

$wrongimghdl = get_file_img -file ("{0}\wrong.png" -f (get_current_file_dir));
$rightimghdl = get_file_img -file ("{0}\right.png" -f (get_current_file_dir));


function refresh_grid($grid,$okimg,$wrongimg) 
{
    $grid.Rows.Clear();
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Personal" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Desktop" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Favorites" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "My Music" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "My Pictures" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "My Video" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Cookies" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Cache" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "History" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "Recent" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_common -grid $grid -chked $true -keyname "AppData" -okimg $okimg -wrongimg $wrongimg;

    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "download" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "savedgames" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "contacts" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "search" -okimg $okimg -wrongimg $wrongimg;
    $v = insert_datagrid_spec -grid $grid -chked $true -keyname "link" -okimg $okimg -wrongimg $wrongimg;

    $v = insert_datagrid_env -grid $grid -chked $true -keyname "temp" -okimg $okimg -wrongimg $wrongimg;
    $grid.Refresh();
    return ;
}


$v = refresh_grid -grid $datagrid -okimg $rightimghdl -wrongimg $wrongimghdl;
$mainfrm.ShowDialog() | Out-Null;
