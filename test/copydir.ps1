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

if ([string]::IsNullOrEmpty($Sourcedir) -Or [string]::IsNullOrEmpty($Destdir)) {
    Usage -ec 3 -usagestr "need source and dest";
}