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
    $ret=0;
    $v = Copy-Item -Path $sourcedir -Destination $destdir -Recurse -PassThru -ErrorAction SilentlyContinue;
    for($i=0;$i -lt $Error.Count; $i++) {
        $curerr = $Error[$i];
        $vcce = ($curerr.FullyQualifiedErrorId  | Out-String) ;
        $lowervcce = $vcce.ToLower();
        if ( -Not ($lowervcce.StartsWith("copydirectoryinfoitemioerror,") -Or $lowervcce.StartsWith("directoryexist,"))) {
            [Console]::Error.WriteLine.Invoke("[$i]"+($curerr | Out-String));
            $ret = 2;
        }
    }

    return $ret;
}

if ([string]::IsNullOrEmpty($Sourcedir) -Or [string]::IsNullOrEmpty($Destdir)) {
    Usage -ec 3 -usagestr "need source and dest";
}

copy_dir -sourcedir $Sourcedir -destdir $Destdir;