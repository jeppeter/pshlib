# for source dir

Param(
    $Sourcedir,
    $Destdir)


function usage_format($usagestr) {
    $retstr = "";
    if (![string]::IsNullOrEmpty($usagestr)) {
        $retstr += $usagestr;
        $retstr += "`n";
    }

    $retstr += "copydir sourcedir destdir`n";
    Write-Host "retstr`n[$retstr]";

    return $retstr;
}

function Usage($ec,$usagestr)
{
    $v = usage_format -usagestr $usagestr;
    $func = [Console]::Error.WriteLine;
    if ($ec -eq 0) {
        $func = [Console].WriteLine;
    } 
    $func.Invoke($v);    
    [Environment]::Exit($ec);
}

function copy_dir($sourcedir,$destdir)
{
    $v = Copy-Item -Path $sourcedir -Destination $destdir -Recurse -PassThru -ErrorAction SilentlyContinue;
    $vs = ($Error[0] | Get-Member | Out-String);
    $ve = ($Error[0].FullyQualifiedErrorId | Out-String);
    $s = ($Error | Format-Table | Out-String);
    Write-Host "vs [$vs]";
    Write-Host "s [$s]";
    Write-Host "ve [$ve]";

}

if ([string]::IsNullOrEmpty($Sourcedir) -Or [string]::IsNullOrEmpty($Destdir)) {
    Usage -ec 3 -usagestr "need source and dest";
}

copy_dir -sourcedir $Sourcedir -destdir $Destdir;