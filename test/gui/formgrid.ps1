
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.drawing;


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

function get_current_file()
{
    $curpath = _my_file_name;
    return $curpath;
}


. ("{0}\valop.ps1" -f (get_current_file_dir));
. ("{0}\fileop.ps1" -f (get_current_file_dir));


#Define Form
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = ""
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Location = New-Object System.Drawing.Point(10,10)
$form1.Size = New-Object System.Drawing.Size(1600,900)
$form1.WindowState = "Normal"
$form1.StartPosition = "CenterScreen"

#Definine DataGridView
$DataGridView_ServerName = New-Object System.Windows.Forms.DataGridView
$DataGridView_ServerName.AllowUserToAddRows = $false
$DataGridView_ServerName.AllowUserToDeleteRows = $false
$DataGridView_ServerName.Top = 10
$DataGridView_ServerName.Left = 10
$DataGridView_ServerName.Height = 100
$DataGridView_ServerName.Width = 410
$DataGridView_ServerName.ColumnHeadersVisible = $true
$DataGridView_ServerName.ColumnHeadersHeight = 20 
$DataGridView_ServerName.Enabled = $true


$refreshbtn =  New-Object System.Windows.Forms.Button;
$refreshbtn.Text = "refresh";

$refnum = 0;

function refresh_datagrid($grid) {

    $global:refnum ++;
    write_stdout -msg "refnum [$global:refnum]";
    if ($global:refnum -gt 1) {
        $cnt = $grid.RowCount;
        write_stdout -msg "before row cnt [$cnt]";
        $grid.Rows.Clear();        
        $cnt = $grid.RowCount;
        write_stdout -msg "row cnt [$cnt]";
        $global:refnum = 0;
    } else {
        $grid.Columns[0].ReadOnly = $false;
        $grid.Columns[3].ReadOnly = $true;

        #Add Rows
        $grid.Rows.Add($false,"1", "2", $rightimg);
        $grid.Rows.Add($true,"a", "b", $wrongimg);
        $grid.Rows[1].Cells[0].ReadOnly = $true;
        $cnt= $grid.RowCount;
        write_stdout -msg "rowcnt[$cnt]";
    }
    $grid.Refresh();
    return;
}

$refresh_click = {
    refresh_datagrid -grid $DataGridView_ServerName;
    Write-Host "cleared";
    return;    
}
$refreshbtn.Add_Click($refresh_click);

    
#Add Columns
$Column1 = New-Object System.Windows.Forms.DataGridViewTextboxColumn
$Column2 = New-Object System.Windows.Forms.DataGridViewTextboxColumn
$Column3 = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn;
$Column4 = New-Object System.Windows.Forms.DataGridViewImageColumn;

        
$Column1.Width = 80
$Column2.Width = 80
$Column3.Width = 80;
$Column4.Width = 80;

$DataGridView_ServerName.ColumnHeadersVisible = $true
$DataGridView_ServerName.Columns.Add($Column3)
$DataGridView_ServerName.Columns.Add($Column1);
$DataGridView_ServerName.Columns.Add($Column2);
$DataGridView_ServerName.Columns.Add($Column4);
$DataGridView_ServerName.Columns[0].Name = "select"
$DataGridView_ServerName.Columns[1].Name = "column1"
$DataGridView_ServerName.Columns[2].Name = "column2"
$DataGridView_ServerName.Columns[3].Name = "changed"


$wrongimg = get_file_img -file ("{0}\wrong.png" -f (get_current_file_dir));
$rightimg = get_file_img -file ("{0}\right.png" -f (get_current_file_dir));


$refreshbtn.Location = New-Object System.Drawing.Point(200,300);

refresh_datagrid -grid $DataGridView_ServerName;

$form1.Controls.Add($DataGridView_ServerName);
$form1.Controls.Add($refreshbtn);



$form1.ShowDialog() 