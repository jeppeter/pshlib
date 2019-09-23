

function write_stderr($msg)
{
    $line = $MyInvocation.ScriptLineNumber;
    $file = $MyInvocation.ScriptName;
    $newmsg = "[";
    $newmsg += "$file";
    $newmsg += ":";
    $newmsg += "$line";
    $newmsg += "]";
    $newmsg += ":";
    $newmsg += "$msg";
    [Console]::Error.WriteLine.Invoke($newmsg);
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
        $newmsg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
    return;
}

function write_stdout($msg)
{
    $line = $MyInvocation.ScriptLineNumber;
    $file = $MyInvocation.ScriptName;
    $newmsg = "[";
    $newmsg += "$file";
    $newmsg += ":";
    $newmsg += "$line";
    $newmsg += "]";
    $newmsg += ":";
    $newmsg += "$msg";
    [Console]::Out.WriteLine.Invoke($newmsg);
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
        $newmsg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
    return;
}


function get_file_img($file)
{
    $fitem = (Get-Item $file);
    return [System.Drawing.Image]::Fromfile($fitem);
}


function remove_dir($dir)
{
    $retval=0;
    $olderror = _copy_error -v $Error;
    if ((Test-Path -Path $dir)) {
        # if the directory exists
        $Error.clear();
        Remove-Item  $dir -ErrorAction SilentlyContinue -Recurse -Force;
        if ($Error.Count -gt 0) {
            write_stderr -msg ($Error | Format-List | Out-String);
            $retval = 2;
        }

    }
    $Error = _copy_error -v $olderror;
    return $retval;
}

function make_dir_safe($dir)
{
    $ret = 0;
    $olderror = _copy_error -v $Error;
    if ((Test-Path -Path $dir -PathType  container)) {
        return 0;
    }
    $Error.clear();
    $n = New-Item  -ItemType "directory" -Path $dir -ErrorAction SilentlyContinue;
    if ($Error.Count -gt 0) {
        write_stderr -msg "make [$dir] error`n" + ($Error | Format-List | Out-String);
        $Error = _copy_error -v $olderror;
        return 2;
    }

    $Error = _copy_error -v $olderror;
    return $ret;
}


function get_child_items($dir)
{
    $olderror = _copy_error -v $Error;
    $Error.clear();
    $retval = Get-ChildItem -Path $dir -ErrorAction SilentlyContinue -Force;
    if ($Error.Count -gt 0) {
        for($i=0;$i -lt $Error.Count;$i ++) {
            $vs = ($curerr | Out-String);
            $curerr = $Error[$i];
            $vcce = ($curerr.FullyQualifiedErrorId  | Out-String);
            $lowervcce = $vcce.ToLower();
            write_stderr -msg "[$i]------------------access [$dir]";
            if (-Not $lowervcce.StartsWith("dirunauthorizedaccesserror,")) {
                write_stderr -msg "[$i]------------------";
                write_stderr -msg $vs;
                write_stderr -msg "++++++++++++++++++++++";
            }
        }
    }

    $Error = _copy_error -v $olderror;
    return $retval;
}

function copy_dir_recur($basedir,$curitem,$newargv)
{
    $cnt = 0;
    if (-Not $curitem) {
        return $cnt;
    }
    #$c = ($curitem | Format-List | Out-String);
    #write_stdout -msg $c;
    if (-Not (Test-Path -Path $newargv -PathType container)) {
        $retval = make_dir_safe -dir $newargv;
        if ($retval -ne 0) {
            write_stderr -msg " ";
            return -1;
        }
        $cnt ++;
    }

    if (-Not $curitem.Name) {
        return $cnt;
    }
    if ($curitem.Name.Equals(".") -Or $curitem.Name.Equals("..")) {
        return $cnt;
    }

    $name = $curitem.Name;
    write_stdout -msg "[$basedir] new [$name]";
    $wholepath = Join-Path -Path $basedir -ChildPath $name;
    if (Test-Path -Path $wholepath -PathType container) {
        write_stdout -msg "[$wholepath] is dir newargv[$newargv]";
        $newdir = Join-Path -Path $newargv -ChildPath $name;
        $retval = handle_directory_callback ${function:\copy_dir_recur} -dir $wholepath -argv  $newdir;
        if ($retval -lt 0) {
            write_stderr -msg " ";
            return $retval;
        }
        $cnt += $retval;
    } else {
        write_stdout -msg "[$wholepath] is not dir newargv[$newargv]";
        $srcfile = Join-Path -Path $basedir -ChildPath $name;
        $dstfile = Join-Path -Path $newargv -ChildPath $name;
        $olderror = _copy_error -v $Error;
        write_stdout -msg "[$srcfile]=>[$dstfile]";
        $Error.clear();
        $v = Copy-Item -Path $srcfile -Destination $dstfile -Recurse -ErrorAction SilentlyContinue;
        if ($Error.Count -gt 0) {
            for ($i=0 ; $i -lt $Error.Count ;$i++) {
                write_stderr -msg "[$i]-----------($srcfile) => ($dstfile)";
                write_stderr -msg ($Error[$i] | Out-String);
            }
        } else {
            $cnt ++;
        }

        $Error = _copy_error -v $olderror;
    }
    return $cnt;
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
            write_stderr -msg " ";
            return $ret;
        }
        $cnt += $ret;
    }

    $Error = _copy_error -v $olderror;
    return $cnt;
}

function copy_dir_top($srcdir,$dstdir)
{
    if (-Not (Test-Path -Path $srcdir -PathType Container)) {
        write_stderr -msg " ";
        return -1;
    }
    if (-Not (Test-Path -Path $dstdir -PathType Container)) {
        $retval = make_dir_safe -dir $dstdir;
        if ($retval -ne 0) {
            write_stderr -msg " ";
            return -2;
        }
    }
    return handle_directory_callback ${function:\copy_dir_recur} -dir $srcdir -argv  $dstdir;
}
