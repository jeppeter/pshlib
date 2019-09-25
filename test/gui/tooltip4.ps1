[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
# Remove and Unregister events if created earlier. Tip, remove the events you haven’t created earlier
 
#Remove-Event BalloonClicked_event -ea SilentlyContinue
 
#Unregister-Event -SourceIdentifier BalloonClicked_event -ea silentlycontinue
 
#Remove-Event BalloonClosed_event -ea SilentlyContinue
 
#Unregister-Event -SourceIdentifier BalloonClosed_event -ea silentlycontinue
 
Remove-Event Clicked_event -ea SilentlyContinue
 
Unregister-Event -SourceIdentifier Clicked_event -ea silentlycontinue
      
 
# Create the object and customize the message
 
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
 
$objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
 
$objNotifyIcon.BalloonTipIcon = "Info"
 
$objNotifyIcon.BalloonTipTitle = "Technology Notification"
 
$objNotifyIcon.BalloonTipText = "Google Plugin was installed! " + [DateTime]::Now.ToShortTimeString()
 
$objNotifyIcon.Text = "Technology Notification"
 
$objNotifyIcon.Visible = $True
 
#Register-ObjectEvent -InputObject $objNotifyIcon -EventName Click -SourceIdentifier Clicked_event -Action { 
#$objNotifyIcon.Visible = $False 
#[System.Windows.Forms.MessageBox]::Show("Clicked","Information");$objNotifyIcon.Visible = $False 
#} | Out-Null   
 
# Show Notification
 
$objNotifyIcon.ShowBalloonTip(5000)