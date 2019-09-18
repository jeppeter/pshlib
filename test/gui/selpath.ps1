


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
Add-Type -AssemblyName System.Drawing;


. ("{0}\valop.ps1" -f (get_current_file_dir));
. ("{0}\fileop.ps1" -f (get_current_file_dir));
. ("{0}\regop.ps1" -f (get_current_file_dir));
. ("{0}\backupop.ps1" -f (get_current_file_dir));



$mainfrm = New-Object System.Windows.Forms.Form;
$mainfrm.Text = "idvtools 1.0";
$mainfrm.Name = "mainframe";
$mainfrm.DataBindings.DefaultDataSourceUpdateMode = 0;



Set-Variable MAIN_FRAME_WIDTH -option Constant -Value 700;
Set-Variable MAIN_FRAME_HEIGHT -option Constant -Value 650;
Set-Variable TABCTRL_WIDTH -option Constant -Value ($MAIN_FRAME_WIDTH - 25);
Set-Variable TABCTRL_HEIGHT -option Constant -Value ($MAIN_FRAME_HEIGHT - 70);

Set-Variable DATAGRID_WIDTH -option Constant -Value ($TABCTRL_WIDTH - 25);
Set-Variable DATAGRID_HEIGHT -option Constant -Value ($TABCTRL_HEIGHT - 200 );

Set-Variable CHECK_BOX_WIDTH  -option Constant -Value 100;
Set-Variable CHECK_BOX_HEIGHT -option Constant -Value 20;
Set-Variable CHECK_BOX_SPACE  -option Constant -Value 40;
Set-Variable CHECK_BOX_LEFT_POINT -option Constant -Value 70;


$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState;

$mainfrm_drawing_size = New-Object System.Drawing.Size;
$mainfrm_drawing_size.Width = $MAIN_FRAME_WIDTH;
$mainfrm_drawing_size.Height = $MAIN_FRAME_HEIGHT;
$mainfrm.ClientSize = $mainfrm_drawing_size;
$mainfrm_fixed_size = New-Object System.Drawing.Size;
$mainfrm_fixed_size.Width = ($MAIN_FRAME_WIDTH + 25);
$mainfrm_fixed_size.Height = $MAIN_FRAME_HEIGHT;
$mainfrm.minimumSize = $mainfrm_fixed_size;
$mainfrm.maximumSize = $mainfrm_fixed_size;


$txtboxpath = New-Object System.Windows.Forms.TextBox;
$txtboxpath_drawing_point = New-Object System.Drawing.Point;
$txtboxpath_drawing_point.X = 85;
$txtboxpath_drawing_point.Y = (20 + $DATAGRID_HEIGHT + 45);
$txtboxpath.Location = $txtboxpath_drawing_point;

$txtboxpath_drawing_size = New-Object System.Drawing.Size;
$txtboxpath_drawing_size.Width = 450;
$txtboxpath_drawing_size.Height = 20;
$txtboxpath.Size = $txtboxpath_drawing_size;
$mainfrm.Controls.Add($txtboxpath);


$btnpath = New-Object System.Windows.Forms.Button;
$btnpath_drawing_point = New-Object System.Drawing.Point;
$btnpath_drawing_point.X = 540;
$btnpath_drawing_point.Y = (20 + $DATAGRID_HEIGHT + 45);
$btnpath.Location = $btnpath_drawing_point;
$mainfrm.Controls.Add($btnpath);

# text 选择路径...
$btnpath.Text = "$([char]0x9009)$([char]0x62e9)$([char]0x8def)$([char]0x5f84)...";


$btnpath.Add_Click({
   #Create OpenFileDialog object
  $object = New-Object -comObject Shell.Application;
  $folder = $object.BrowseForFolder(0, "$([char]0x9009)$([char]0x62e9)$([char]0x8def)$([char]0x5f84)", 0, "MyComputer");
  if ($folder) {
    $path = $folder.self.Path;
    $txtboxpath.Text = $path;
  }

});

$chkbox_regsetted = New-Object System.Windows.Forms.Checkbox ;
$chkbox_regsetted_point = New-Object System.Drawing.Point;
$chkbox_regsetted_point.X = $CHECK_BOX_LEFT_POINT;
$chkbox_regsetted_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30);
$chkbox_regsetted.Location = $chkbox_regsetted_point;

$chkbox_regsetted_size = New-Object System.Drawing.Size;
$chkbox_regsetted_size.Width = $CHECK_BOX_WIDTH;
$chkbox_regsetted_size.Height = $CHECK_BOX_HEIGHT;
$chkbox_regsetted.Size = $chkbox_regsetted_size;

# text 更改目录
$chkbox_regsetted.Text = "$([char]0x66f4)$([char]0x6539)$([char]0x76ee)$([char]0x5f55)";
$chkbox_regsetted.Checked = $true;
$mainfrm.Controls.Add($chkbox_regsetted);


$chkbox_copyfile = New-Object System.Windows.Forms.Checkbox ;
$chkbox_copyfile_point = New-Object System.Drawing.Point;
$chkbox_copyfile_point.X = ($CHECK_BOX_LEFT_POINT + $CHECK_BOX_WIDTH + $CHECK_BOX_SPACE);
$chkbox_copyfile_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30);
$chkbox_copyfile.Location = $chkbox_copyfile_point;

$chkbox_copyfile_size = New-Object System.Drawing.Size;
$chkbox_copyfile_size.Width = $CHECK_BOX_WIDTH;
$chkbox_copyfile_size.Height = $CHECK_BOX_HEIGHT;
$chkbox_copyfile.Size = $chkbox_copyfile_size;

# text 数据转移
$chkbox_copyfile.Text = "$([char]0x6570)$([char]0x636e)$([char]0x8f6c)$([char]0x79fb)";
$chkbox_copyfile.Checked = $true;
$mainfrm.Controls.Add($chkbox_copyfile);


$chkbox_removed = New-Object System.Windows.Forms.Checkbox ;
$chkbox_removed_point = New-Object System.Drawing.Point;
$chkbox_removed_point.X = ($CHECK_BOX_LEFT_POINT + $CHECK_BOX_WIDTH * 2 + $CHECK_BOX_SPACE * 2);;
$chkbox_removed_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30);
$chkbox_removed.Location = $chkbox_removed_point;

$chkbox_removed_size = New-Object System.Drawing.Size;
$chkbox_removed_size.Width = $CHECK_BOX_WIDTH;
$chkbox_removed_size.Height = $CHECK_BOX_HEIGHT;
$chkbox_removed.Size = $chkbox_removed_size;

# text 清除数据
$chkbox_removed.Text = "$([char]0x6e05)$([char]0x9664)$([char]0x6570)$([char]0x636e)";
$chkbox_removed.Checked = $true;
$mainfrm.Controls.Add($chkbox_removed);


$chkbox_selall = New-Object System.Windows.Forms.Checkbox ;
$chkbox_selall_point = New-Object System.Drawing.Point;
$chkbox_selall_point.X = ($CHECK_BOX_LEFT_POINT + $CHECK_BOX_WIDTH * 3 + $CHECK_BOX_SPACE * 3);;
$chkbox_selall_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30);
$chkbox_selall.Location = $chkbox_selall_point;

$chkbox_selall_size = New-Object System.Drawing.Size;
$chkbox_selall_size.Width = $CHECK_BOX_WIDTH;
$chkbox_selall_size.Height = $CHECK_BOX_HEIGHT;
$chkbox_selall.Size = $chkbox_selall_size;

# text 选择所有
$chkbox_selall.Text = "$([char]0x9009)$([char]0x62e9)$([char]0x6240)$([char]0x6709)";
$chkbox_selall.Checked = $false;

$chkbox_selall.Add_CheckStateChanged({
  $val = $chkbox_selall.Checked;
  write_stdout -msg "call clicked [$val]";
  });
$mainfrm.Controls.Add($chkbox_selall);

$btnset_default = New-Object System.Windows.Forms.Button;
$btnset_default_point = New-Object System.Drawing.Point;
$btnset_default_point.X = 20;
$btnset_default_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30 + $CHECK_BOX_HEIGHT + 10);

$btnset_default.Location = $btnset_default_point;
$btnset_default_size = New-Object System.Drawing.Size;
$btnset_default_size.Width = 100;
$btnset_default_size.Height = 25;

$btnset_default.Size = $btnset_default_size;
# text 推荐选择
$btnset_default.Text = "$([char]0x63a8)$([char]0x8350)$([char]0x9009)$([char]0x62e9)";

$mainfrm.Controls.Add($btnset_default);

$btnset_selected = New-Object System.Windows.Forms.Button;
$btnset_selected_point = New-Object System.Drawing.Point;
$btnset_selected_point.X = (20 + 125);
$btnset_selected_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30 + $CHECK_BOX_HEIGHT + 10);

$btnset_selected.Location = $btnset_selected_point;
$btnset_selected_size = New-Object System.Drawing.Size;
$btnset_selected_size.Width = 100;
$btnset_selected_size.Height = 25;

$btnset_selected.Size = $btnset_selected_size;
# text 开始转移
$btnset_selected.Text = "$([char]0x5f00)$([char]0x59cb)$([char]0x8f6c)$([char]0x79fb)";

$mainfrm.Controls.Add($btnset_selected);


$btnset_restore = New-Object System.Windows.Forms.Button;
$btnset_restore_point = New-Object System.Drawing.Point;
$btnset_restore_point.X = (20 + 125 * 2);
$btnset_restore_point.Y = (20 + $DATAGRID_HEIGHT + 45 + 30 + $CHECK_BOX_HEIGHT + 10);

$btnset_restore.Location = $btnset_restore_point;
$btnset_restore_size = New-Object System.Drawing.Size;
$btnset_restore_size.Width = 100;
$btnset_restore_size.Height = 25;

$btnset_restore.Size = $btnset_restore_size;
# text 恢复默认
$btnset_restore.Text = "$([char]0x6062)$([char]0x590d)$([char]0x9ed8)$([char]0x8ba4)";

$mainfrm.Controls.Add($btnset_restore);


$mainfrm.ShowDialog() | Out-Null;
