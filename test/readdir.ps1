Param(
    $Sourcedir,
    $Destdir);


function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    return;
}

function write_stdout($msg)
{
    [Console]::Out.WriteLine.Invoke($msg);
    return;
}


function _copy_error($v)
{
    $retv = @();
    for ($i = 0 ; $i -lt $v.Count ; $i++) {
        $retv = $retv + $v[$i];
    }
    return $retv;
}


function get_child_items($dir)
{
    $olderror = _copy_error -v $Error;
    $Error.clear();
    $retval = Get-ChildItem -Path $dir -ErrorAction SilentlyContinue -Force;
    if ($Error.Count -gt 0) {
        for($i=0;$i -lt $Error.Count;$i ++) {
            $curerr = $Error[$i];
            $vs = ($curerr | Out-String);
            $vcce = ($curerr.FullyQualifiedErrorId  | Out-String);
            $lowervcce = $vcce.ToLower();
            write_stderr -msg "[$i]------------------access [$dir]";
            if (-Not $lowervcce.StartsWith("dirunauthorizedaccesserror,")) {
                write_stderr -msg "[$i]------------------";
                write_stderr -msg $vs;
                write_stderr -msg "++++++++++++++++++++++";
            }
        }
        write_stderr -msg $vs;
    }

    $Error = _copy_error -v $olderror;
    return $retval;
}

function display_dir($basedir,$curitem,$newargv)
{
    $retval = 0;
    if (-Not $curitem.Name) {
        return 0;
    }
    if ($curitem.Name.Equals(".") -Or $curitem.Name.Equals("..")) {
        return 0;
    }
    $wholepath = Join-Path -Path $basedir -ChildPath $curitem.Name;
    if (Test-Path -Path $wholepath -PathType container) {
        write_stdout -msg "[$wholepath] is dir newargv[$newargv]";
        $newdir = Join-Path -Path $newargv -ChildPath $curitem.Name;
        $retval = handle_directory_callback ${function:\display_dir} -dir $wholepath -argv  $newdir;
        if ($retval -lt 0) {
            return $retval;
        }
    } else {
        write_stdout -msg "[$wholepath] is not dir newargv[$newargv]";
        $retval = 1;
    }
    return $retval;
}


function handle_directory_callback($function,$dir,$argv)
{
    $retval = 0;
    $cnt = 0;

    $olderror = _copy_error -v $Error;

    $items =  get_child_items($dir);

    foreach($i in $items) {
        $ret = Invoke-Command $function -ArgumentList $dir,$i,$argv;
        if ($ret -lt 0) {            
            return $ret;
        }
        $cnt += $ret;
    }

    $Error = _copy_error -v $olderror;
    return $cnt;
}



$retval = handle_directory_callback ${function:\display_dir} -dir $Sourcedir -argv  $Destdir;


