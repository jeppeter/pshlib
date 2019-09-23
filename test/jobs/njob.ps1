cls
# create an array and add it to session state
$arrayList = New-Object System.Collections.ArrayList
$arrayList.AddRange(('a','b','c','d','e'))
 
$sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
$sessionstate.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry('arrayList', $arrayList, $null)))
 
$runspacepool = [runspacefactory]::CreateRunspacePool(1, 2, $sessionstate, $Host)
$runspacepool.Open()
 
$ps1 = [powershell]::Create()
$ps1.RunspacePool = $runspacepool
 
$ps1.AddScript({
    for ($i = 1; $i -le 15; $i++)
    {
        $letter = Get-Random -InputObject (97..122) | % {[char]$_} # a random lowercase letter
        $null = $arrayList.Add($letter)
        start-sleep -s 1
    }
}) 
#> $null

# on the first thread start a process that adds values to $arrayList every second
$handle1 = $ps1.BeginInvoke()

# now on the second thread, output the value of $arrayList every 1.5 seconds
$ps2 = [powershell]::Create()
$ps2.RunspacePool = $runspacepool
 
$ps2.AddScript({
     Write-Host "ArrayList contents is "
     foreach ($i in $arrayList)
     {
        Write-Host $i  -NoNewline
        Write-Host " " -NoNewline
     }
     Write-Host ""
}) 
#> $null

1..10 | % {
    $handle2 = $ps2.BeginInvoke()
    if ($handle2.AsyncWaitHandle.WaitOne())
    {
        $ps2.EndInvoke($handle2)
    }
    start-sleep -s 1.5
}