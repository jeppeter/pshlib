
Param($cmd,$params);

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

Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;




$mainfrm = New-Object System.Windows.Forms.Form;
$mainfrm.Text = "idvtools 1.0";
$mainfrm.Name = "mainframe";
$mainfrm.DataBindings.DefaultDataSourceUpdateMode = 0;

$btnset = New-Object System.Windows.Forms.Button;
$btnset.Text = "start";

$global:backup_proc = $null;
$global:cmd = $cmd;
$global:params = $params;
$global:backup_timer = $null;
$global:timer_cnt = 0;

function handle_backup_timer()
{
    if ( -Not $global:backup_proc)  {
        $global:backup_timer.Stop();
        $global:backup_timer = $null;
        $global:timer_cnt = 0;
        $btnset.Enabled = $true;
        return;
    }
    if ($global:backup_proc.HasExited) {
        $c = $global:backup_proc.ExitCode;
        write_stdout -msg "exit code [$c]";
        $global:backup_proc = $null;
        $global:backup_timer.Stop();
        $global:backup_timer = $null;
        $global:timer_cnt = 0;
        $btnset.Enabled = $true;
        return;
    }

    $global:timer_cnt ++;
    $cnt = $global:timer_cnt;
    write_stdout -msg "call timer[$cnt]";
    return;
}

$btnset.Add_Click({
    if ($global:backup_proc) {
        write_stdout -msg "has backup";
        return;
    }
    $global:backup_proc = Start-Process -FilePath $global:cmd -Passthru -ArgumentList $global:params;
    if (-Not $global:backup_proc) {
        write_stderr -msg "can not create proc";
        return;
    }
    $global:backup_proc.EnableRaisingEvents = $true;
    $global:backup_timer = New-Object System.Windows.Forms.Timer;
    $global:backup_timer.Interval = 500;
    $global:backup_timer.add_tick({
        handle_backup_timer | Out-Null;
        });
    $global:backup_timer.Start();
    $btnset.Enabled = $false;
});

$mainfrm.Controls.Add($btnset);

$mainfrm.ShowDialog() | Out-Null;