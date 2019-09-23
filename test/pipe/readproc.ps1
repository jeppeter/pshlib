Param($cc);

Function Execute-Command ($commandTitle, $commandPath, $commandArguments)
{
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $commandPath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $commandArguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    return $p;
}
#    $p.WaitForExit()
#    return [pscustomobject]@{
#        commandTitle = $commandTitle
#        stdout = $p.StandardOutput.ReadToEnd()
#        stderr = $p.StandardError.ReadToEnd()
#        ExitCode = $p.ExitCode
#    }


$p = Execute-Command -commandTitle "title" -commandPath "powershell.exe" -commandArguments "-Command `"Write-Host -NoNewLine `\`"$cc\`";`"";
Write-Host "get stdout "$p.stdout;
$cnt =0;

While(1) {
    Write-Host "cnt [$cnt]";
    if ($p.HasExited) {
        break;
    }
    Start-Sleep -Milliseconds  100;
    $cnt ++;
}

$out = $p.StandardOutput.ReadToEnd();
Write-Host "read [$out]";
