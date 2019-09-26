Param($timeout);

$timer = new-object timers.timer

$action = {write-host "Timer Elapse Event: $(get-date -Format 'HH:mm:ss')"} 
$timer.Interval = $timeout #3 seconds 

Register-ObjectEvent -InputObject $timer -EventName elapsed -SourceIdentifier  thetimer -Action $action

$timer.start()

$cnt = 0;
while(1) {
    Start-Sleep -m 300;
    Write-Host "$cnt";
    $cnt++;
}

#to stop run
$timer.stop()
#cleanup
Unregister-Event thetimer