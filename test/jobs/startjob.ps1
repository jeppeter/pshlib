

$script_block = {
    $cnt = 0;
    while ($cnt -lt 10) {
        Write-Host "cnt [$cnt]";
        $cnt ++;
        Start-Sleep -m 300;
    }
}

$j = Start-Job $script_block;

$sj = ($j | gm | Out-String);
Write-Host "$sj";
while (1) {
    if (-Not (Get-Job -State "Running")) {
        break;
    }
    Write-Host "job state";
    Start-Sleep -s 1.0;
}

Get-Job | Receive-Job;
Remove-Job $j;
Write-Host "job all over";