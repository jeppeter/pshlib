Function GenerateForm {
[Void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$ButtonUpdateGrid = New-Object Windows.Forms.Button
$ButtonUpdateGrid.Location = New-Object Drawing.Point 7,15
$ButtonUpdateGrid.size = New-Object Drawing.Point 90,23
$ButtonUpdateGrid.Text = "&Get Packages"
$ButtonUpdateGrid.add_click({Get-info})

$Button1 = New-Object Windows.Forms.Button
$Button1.Location = New-Object Drawing.Point 200,15
$Button1.size = New-Object Drawing.Point 90,23
$Button1.Text = "columns"
$button1.add_Click($button1_OnClick)

$ButtonStartExport = New-Object Windows.Forms.Button
$ButtonStartExport.Location = New-Object Drawing.Point 100,15
$ButtonStartExport.size = New-Object Drawing.Point 90,23
$ButtonStartExport.Text = "rows"
$ButtonStartExport.add_click({Do-Grid})

$dataGridView1 = New-Object System.Windows.Forms.DataGridView
$dataGridView1.Location = New-Object Drawing.Point 7,40
$dataGridView1.size = New-Object Drawing.Point 1000,700
$dataGridView1.MultiSelect = $false
$dataGridView1.ColumnHeadersVisible = $true
$dataGridView1.RowHeadersVisible = $false

$form = New-Object Windows.Forms.Form
$form.text = "Package Exporter v0.1"
$form.Size = New-Object Drawing.Point 1024, 768
$form.topmost = 1
$form.Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")

$form.Controls.Add($dataGridView1)
$form.controls.add($Button1)
$form.controls.add($ButtonStartExport)
$form.controls.add($ButtonUpdateGrid)
#$form.add_Load($OnLoadForm)
$form.ShowDialog()
}


 Function Get-info{
    If($datagridview1.columncount -gt 0){
        $dataGridview1.DataSource = $null
        $DataGridView1.Columns.RemoveAt(0) 
    }
    $Column1 = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
    $Column1.width = 30
    $Column1.name = "Exp"
    $DataGridView1.Columns.Add($Column1) 
    $array = New-Object System.Collections.ArrayList
    $Script:procInfo = get-process | Select-Object name, company, description,     product, id, vm, fileversion
    $array.AddRange($procInfo)
    $dataGridview1.DataSource = $array
    $form.refresh()
}          


Function Do-Grid{

    for($i=0;$i -lt $datagridview1.RowCount;$i++){ 

       if($datagridview1.Rows[$i].Cells['exp'].Value -eq $true)
       {
         write-host "cell #$i is checked"
         #uncheck it
         #$datagridview1.Rows[$i].Cells['exp'].Value=$false
       }
       else    
       {
         #check it
         #$datagridview1.Rows[$i].Cells['exp'].Value=$true
         write-host  "cell #$i is not-checked"
       }
    }
}

GenerateForm