Param($Titlestr,$Textstr);

function New-BalloonTip  {
  
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    # Specifies the type of icon shown in the balloon tip
    [parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateSet("None", "Info", "Warning", "Error")]
    [ValidateNotNullOrEmpty()]
    [string] $Icon = "Info",

    # Defines the actual text shown in the balloon tip
    [parameter(Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, HelpMessage = "No text specified!")]
    [ValidateNotNullOrEmpty()]
    [string] $Text,

    # Defines the title of the balloon tip
    [parameter(Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, HelpMessage = "No title specified!")]
    [ValidateNotNullOrEmpty()]
    [string] $Title,

    # Specifies how long to display the balloon tip
    [parameter(Position = 3, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]  
    [ValidatePattern("[0-9]")]  
    [int] $Timeout = 10000
  )
  PROCESS{
    [system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    #  Add-Type -AssemblyName System.Windows.Forms
    #if (! $script:balloon) {
      #$script:balloon = New-Object System.Windows.Forms.NotifyIcon
      $balloon = New-Object System.Windows.Forms.NotifyIcon
    #}
    $path = Get-Process -Id $pid | Select-Object -ExpandProperty Path
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloon.BalloonTipIcon = $Icon
    $balloon.BalloonTipText = $Text
    $balloon.BalloonTipTitle = $Title
    $balloon.Visible = $true
    $balloon.ShowBalloonTip($Timeout)
    #$balloon.Dispose()
  } # end PROCESS
} # end function New-BalloonTip

$v = New-BalloonTip -Text $Textstr -Title $Titlestr;