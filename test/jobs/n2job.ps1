cls
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$folderLocation = [System.IO.Path]::Combine($scriptPath, "PowerShellMultiThreading_LockExample")
if (Test-Path $folderLocation)
{
    Remove-Item $folderLocation -Recurse -Force
}
New-Item -Path $folderLocation -ItemType directory -Force > $null

$summaryFile = [System.IO.Path]::Combine($folderLocation, "summaryfile.txt")

# Create session state, load in the locking script and create a shared variable $summaryFile
$sessionstate = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$sessionstate.ImportPSModule("$scriptPath\LockObject.psm1")
$sessionstate.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry('summaryFile', $summaryFile, $null)))

$runspacepool = [runspacefactory]::CreateRunspacePool(1, 100, $sessionstate, $Host)
$runspacepool.Open()

$ScriptBlock_NoLocking = {
   Param (
   [int]$RunNumber = 0
   )
    try
    {    
        Add-Content $summaryFile $RunNumber -ErrorAction  stop
    }
    Catch [System.Exception]
    {
        Write-Host  $_.Exception.ToString()
    }
}

$ScriptBlock_Locking = {
   Param (
   [int]$RunNumber = 0
   )
    try
    {    
        lock ($summaryFile) {
            Add-Content $summaryFile $RunNumber -ErrorAction  stop
        }
    }
    Catch [System.Exception]
    {
        Write-Host  $_.Exception.ToString()
    }
}

Write-Host "Try to update summaryFile with no locking - we are going to see a lot of exceptions"

New-Item -Path $summaryFile -ItemType file -Force > $null
$Jobs = @()
1..100 | % {
   $Job = [powershell]::Create().AddScript($ScriptBlock_NoLocking).AddArgument($_)
   $Job.RunspacePool = $runspacepool
   $Jobs += New-Object PSObject -Property @{
      RunNum = $_
      Job = $Job
      Result = $Job.BeginInvoke()
   }
}
 
Write-Host "Waiting.." -NoNewline
Do {
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
} While ( $Jobs.Result.IsCompleted -contains $false)

$contents = Get-Content $summaryFile
$numEntries = $contents.count
Write-Host ""
Write-Host "Update complete: summaryFile contains $numEntries entries, should contain 100"
Write-Host ""
Write-Host ""

Write-Host "Try to update summaryFile with locking - 
should work correctly and summaryFile should be updated with all 100 entries"

New-Item -Path $summaryFile -ItemType file -Force > $null
$Jobs = @()
1..100 | % {
   $Job = [powershell]::Create().AddScript($ScriptBlock_Locking).AddArgument($_)
   $Job.RunspacePool = $runspacepool
   $Jobs += New-Object PSObject -Property @{
      RunNum = $_
      Job = $Job
      Result = $Job.BeginInvoke()
   }
}
 
Write-Host "Waiting.." -NoNewline
Do {
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
} While ( $Jobs.Result.IsCompleted -contains $false)

$contents = Get-Content $summaryFile
$numEntries = $contents.count
Write-Host ""
Write-Host "Update complete: summaryFile contains $numEntries entries"