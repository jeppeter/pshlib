Param(
    $SD);


function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
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
    $Error.clear();
    return Get-ChildItem -Path $dir -ea SilentlyContinue -Force;
}

function display_dir($curitem,$newargv)
{
    #Write-Host "curitem " ($curitem | Format-List |Out-String);
    Write-Host "curitem2 " ($curitem | gm |Out-String);
    #$ts = ($curitem.GetType().ToString());
    #Write-Host ("[{0}] type [{1}]" -f $curitem.Name, $ts);
    Write-Host ("newargv [$newargv] [{0}]" -f $curitem.Name);
    return 0;
}


function handle_directory_callback($function,$dir,$argv)
{
    $retval = 0;

    $olderror = _copy_error -v $Error;

    $items =  get_child_items($dir);

    foreach($i in $items) {
        $ret = Invoke-Command $function -ArgumentList $i,$argv;
        if ($ret -ne 0) {
            $retval = $ret;
            break;
        }
    }

    $Error = _copy_error -v $olderror;
    return $retval;
}



$retval = handle_directory_callback ${function:\display_dir} -dir $SD -argv "CAll" ;


