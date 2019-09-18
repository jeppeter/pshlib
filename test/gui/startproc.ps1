
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


$p = Start-Process -FilePath $cmd -Passthru -ArgumentList $params;
$p.EnableRaisingEvents = $true;
$msg = ($p | gm | Out-String) ;
write_stdout -msg $msg;

Register-ObjectEvent -InputObject $p -EventName Exited  -SourceIdentifier $p.Exited  -Action {
    write_stdout -msg "process exited";
} | Out-Null;

$cnt=0;
while ($true) {
    $val = $p.Exited;
    $code = $p.ExitCode;
    $e = $p.HasExited;
    write_stdout -msg "exited[$val]code[$code]e[$e]";
    if ($p.HasExited) {
        break;
    }
    Start-Sleep -s 1.0 | Out-Null;
    write_stdout -msg "wait [$cnt]";
    $cnt ++;
}
#$p.WaitForExit();

$code = $p.ExitCode;
write_stdout -msg "exit [$code]";
