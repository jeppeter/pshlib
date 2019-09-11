Param(
    $Name);



function write_stderr($msg)
{
    [Console]::Error.WriteLine.Invoke($msg);
    return;
}

function remove_dir($dir)
{
    $retval=0;
    if (Test-Path -Path $dir) {
        # if the directory exists
        $Error.clear();
        Remove-Item  $dir -ErrorAction SilentlyContinue -Recurse -Force;
        if ($Error.Count -gt 0) {
            write_stderr -msg ($Error | Format-List | Out-String);
            $retval = 2;
        }

    }
    return $retval;
}


remove_dir -dir $Name;