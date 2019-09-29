
Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.drawing;

Add-Type "using System;using System.Runtime.InteropServices;public class pInvoke{    [DllImport(`"user32.dll`", SetLastError = true)]   public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);}";


function move_window($ctrl,$x,$y,$w,$h)
{
    $v = [Window]::MoveWindow($ctrl.Handle, $x, $y, $w, $h,$True);
    return $ctrl;
}

function set_control_size_point($ctrl,$x,$y,$w,$h,$text)
{
    $ctrl.Location = New-Object System.Drawing.Point($x,$y);
    $ctrl.Size = New-Object System.Drawing.Size($w,$h);
    $ctrl.Text = $text;
    return $ctrl;
}


$Width=300;
$Height=200;

$screens = [System.Windows.Forms.Screen]::AllScreens;
$tw = $screens[0].WorkingArea.Width;
$th = $screens[0].WorkingArea.Height;

$mainfrm = New-Object System.Windows.Forms.Form;
$mainfrm.Text = "$([char]0x63d0)$([char]0x793a)";
$mainfrm.Name = "mainframe";
$mainfrm.DataBindings.DefaultDataSourceUpdateMode = 0;
$mainfrm.Size = New-Object System.Drawing.Size($Width,$Height);
$mainfrm.minimumSize = New-Object System.Drawing.Size($Width,$Height);
$mainfrm.maximumSize = New-Object System.Drawing.Size($Width,$Height);


$label = New-Object System.Windows.Forms.Label;
$labeltext = "%s";
$label = set_control_size_point -ctrl $label -x 0 -y 0 -w ($Width - 20) -h ($Height - 20) -Text $labeltext;
$label.TextAlign = "MiddleCenter";

$mainfrm.Controls.Add($label);

[pInvoke]::MoveWindow($mainfrm.Handle, ($tw - $Width), ($th - $Height), $Width , $Height, $true);
$mainfrm.MinimizeBox = $false;
$mainfrm.MaximizeBox = $false;

$mainfrm.ShowDialog() | Out-Null;