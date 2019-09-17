
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.drawing;

function get_file_img($file)
{
    $fitem = (Get-Item $file);
    return [System.Drawing.Image]::Fromfile($fitem);
}

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


$wrongimg = get_file_img -file "$pwd\wrong.png";
$rightimg = get_file_img -file "$pwd\right.png";

        

$form1.Controls.Add($DataGridView_ServerName);

$DataGridView_ServerName.Columns[0].ReadOnly = $false;
$DataGridView_ServerName.Columns[3].ReadOnly = $true;

#Add Rows
$DataGridView_ServerName.Rows.Add($false,"1", "2", $rightimg);
$DataGridView_ServerName.Rows.Add($true,"a", "b", $wrongimg);
$DataGridView_ServerName.Rows[1].Cells[0].ReadOnly = $true;




$form1.ShowDialog() 