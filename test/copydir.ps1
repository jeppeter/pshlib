# for source dir

Param(
    $Sourcedir,
    $Destdir)


function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    return;
}

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

function remove_dir($dir)
{
    $retval=0;
    if (Test-Path -Path $dir) {
        # if the directory exists
        $Error.clear();
        Remove-Item $destdir -ErrorAction SilentlyContinue -Recurse;
        if ($Error.Count -gt 0) {
            write_stderr -msg ($Error | Format-List | Out-String);
            $retval = 2;
        }

    }
    return $retval;
}

function copy_dir($sourcedir,$destdir)
{
    $ret=0;
    $retval = remove_dir -dir $destdir;
    if ($retval -ne 0) {
        return $retval;
    }
    $Error.clear();
    $v = Copy-Item -Path $sourcedir -Destination $destdir -Recurse -PassThru -ErrorAction SilentlyContinue;
    for($i=0;$i -lt $Error.Count; $i++) {
        $curerr = $Error[$i];
        $vcce = ($curerr.FullyQualifiedErrorId  | Out-String) ;
        $lowervcce = $vcce.ToLower();
        if ( -Not ($lowervcce.StartsWith("copydirectoryinfoitemioerror,") -Or $lowervcce.StartsWith("directoryexist,"))) {
            write_stderr -msg "[$i]"+($curerr | Out-String) ;
            $ret = 2;
        }
    }
    return $ret;
}

if ([string]::IsNullOrEmpty($Sourcedir) -Or [string]::IsNullOrEmpty($Destdir)) {
    Usage -ec 3 -usagestr "need source and dest";
}

copy_dir -sourcedir $Sourcedir -destdir $Destdir;