
$file_redirect_code = @"
using System;
using System.IO;
public class SetConsole
{
    public static void SetOutput(string outfile){
        StreamWriter writer = new StreamWriter(outfile);
        writer.AutoFlush = true;
        Console.SetOut(writer);
        return;
    }
    public static void SetError(string errfile) {
        StreamWriter writer = new StreamWriter(errfile);
        writer.AutoFlush = true;
        Console.SetError(writer);
        return;
    }
}
"@
 
Add-Type -TypeDefinition $file_redirect_code -Language CSharp 

function redirect_out($outf)
{
    if ($outf.Length -gt 0) {
        $c = ("[SetConsole]::SetOutput(`"{0}`")"  -f $outf);
        iex $c;
    }
}

function redirect_err($errf)
{
    if ($errf.Length -gt 0) {
        $c = ("[SetConsole]::SetError(`"{0}`")"  -f $errf);
        iex $c;
    }
}


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
    $v = [Console]::Error.WriteLine.Invoke($newmsg);
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
        $v = $newmsg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
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
    $v = [Console]::Out.WriteLine.Invoke($newmsg);
    if (-Not [string]::IsNullOrEmpty($FileAppend)) {
        $v = $newmsg | Out-File -FilePath $FileAppend -Append -ErrorAction SilentlyContinue ;
    }
    return;
}

function file_exists($fname)
{
    if (Test-Path $fname) {
        return $True;
    }
    return $False;
}


function basename($fname)
{
    $sarr = $fname.Split("\");
    if ($sarr.Length -gt 1) {
        return $sarr[($sarr.Length -1)];
    }
    if ($sarr.Length -gt 0) {
        return $sarr[0];
    }
    return "";    
}

function normalize_path($path)
{
    $relpath = Resolve-Path $path -ErrorAction SilentlyContinue `
                                       -ErrorVariable _frperror
    if (-not($relpath)) {
        $relpath = $_frperror[0].TargetObject
    }
    return $relpath;
}

function get_caller_file()
{
    return $MyInvocation.ScriptName;
}

function dirname($path)
{
    return Split-Path -parent $path;
}