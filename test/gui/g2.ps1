cls #https://adminscache.wordpress.com/2014/08/03/powershell-winforms-menu/
# Install .Net Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Enable Visual Styles
[Windows.Forms.Application]::EnableVisualStyles()

<# Form #>	write-host "=== Form ==="
	$Form = New-Object Windows.Forms.Form
	$Form.StartPosition = "CenterScreen"
	$Form.Size = "1024,768"
	$Form.BackColor = "White"
	$Form.Name = "Form"
	$Form.Text = "PowerTools (ALPHA 3.0)"
	
	# Form .Net Objects
	$menuMain			= New-Object System.Windows.Forms.MenuStrip
	
	$menuFile			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuView			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuTools			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuOpen			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuSave			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuSaveAs			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuFullScr		= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuOptions		= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuOptions1		= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuOptions2		= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuExit			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuHelp			= New-Object System.Windows.Forms.ToolStripMenuItem
	$menuAbout			= New-Object System.Windows.Forms.ToolStripMenuItem
	
	$mainToolStrip		= New-Object System.Windows.Forms.ToolStrip
	$toolStripOpen		= New-Object System.Windows.Forms.ToolStripButton
	
	$toolStripSave		= New-Object System.Windows.Forms.ToolStripButton
	$toolStripSaveAs	= New-Object System.Windows.Forms.ToolStripButton
	$toolStripFullScr	= New-Object System.Windows.Forms.ToolStripButton
	$toolStripAbout		= New-Object System.Windows.Forms.ToolStripButton
	$toolStripExit		= New-Object System.Windows.Forms.ToolStripButton
	
	$statusStrip		= New-Object System.Windows.Forms.StatusStrip
	$statusLabel		= New-Object System.Windows.Forms.ToolStripStatusLabel

# Main Form
#$mainForm.Icon            = $iconPS
	$Form.MainMenuStrip   = $menuMain

	$Form.Controls.Add($menuMain)
	$Form.Controls.Add($mainToolStrip)
	$Form.Controls.Add($menuMain)
	$menuFile.Text = "&File"
[void]$menuMain.Items.Add($menuFile)

#$Form | Get-Member #-MemberType Event,Property,Method
$Form.ShowDialog()
