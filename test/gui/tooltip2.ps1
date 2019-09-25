#------------------------------------------------------------------------
# Source File Information (DO NOT MODIFY)
# Source ID: d5e480b8-3268-4006-b44f-adff63b956f6
# Source File: C:\Users\\Documents\SAPIEN\Files\tooltip.psf
#------------------------------------------------------------------------


#----------------------------------------------
#region Application Functions
#----------------------------------------------

#endregion Application Functions

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Show-tooltip_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object 'System.Windows.Forms.Form'
	$button1 = New-Object 'System.Windows.Forms.Button'
	$tooltip1 = New-Object 'System.Windows.Forms.ToolTip'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$form1_Load={
		
		$tooltip1.OwnerDraw = $true
		
	}
	
	
	$tooltip1_Draw=[System.Windows.Forms.DrawToolTipEventHandler]{
	#Event Argument: $_ = [System.Windows.Forms.DrawToolTipEventArgs]
		
		$_.DrawBackground()
		$fontstyle = New-Object System.Drawing.Font("Segoe UI", 9.75, [System.Drawing.FontStyle]::Italic)
		$format = [System.Drawing.StringFormat]::GenericTypographic
		$_.Graphics.DrawString($_.ToolTipText, $fontstyle, [System.Drawing.SystemBrushes]::ControlText, $_.Bounds.X, $_.Bounds.Y, $format)
		
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$form1.remove_Load($form1_Load)
			$tooltip1.remove_Draw($tooltip1_Draw)
			$form1.remove_Load($Form_StateCorrection_Load)
			$form1.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null  }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$form1.SuspendLayout()
	#
	# form1
	#
	$form1.Controls.Add($button1)
	$form1.AutoScaleDimensions = '6, 13'
	$form1.AutoScaleMode = 'Font'
	$form1.ClientSize = '284, 262'
	$form1.Name = 'form1'
	$form1.Text = 'Form'
	$form1.add_Load($form1_Load)
	#
	# button1
	#
	$button1.Location = '47, 61'
	$button1.Name = 'button1'
	$button1.Size = '75, 23'
	$button1.TabIndex = 0
	$button1.Text = 'button1'
	$tooltip1.SetToolTip($button1, 'tooltip demo')
	$button1.UseVisualStyleBackColor = $True
	#
	# tooltip1
	#
	$tooltip1.add_Draw($tooltip1_Draw)
	$form1.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form1.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form1.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $form1.ShowDialog()

} #End Function

#Call the form
Show-tooltip_psf | Out-Null

