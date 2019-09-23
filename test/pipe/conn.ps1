Param($Pipename);


function _my_file_name()
{
    return $MyInvocation.ScriptName;
}

function get_current_file_dir()
{
# Determine script location for PowerShell
    $curpath = _my_file_name;
    return Split-Path $curpath;
}


. ("{0}\fileop.ps1" -f (get_current_file_dir));


function connect_namedpipe($pipename,$rtime,$wtime)
{
    $pipeconn = New-Object System.IO.Pipes.NamedPipeClientStream("\\.", $pipename, [System.IO.Pipes.PipeDirection]::InOut,
                                                                [System.IO.Pipes.PipeOptions]::WriteThrough, 
                                                                [System.Security.Principal.TokenImpersonationLevel]::Impersonation
                                                                );
    #$pipeconn.ReadTimeout = $rtime;
    #$pipeconn.WriteTimeout = $wtime;
    try{
        $pipeconn.Connect(1000);
        return $pipeconn;
    }
    catch {
        $s = "catch exception [$pipename]";
        $s += ($error[0] | Format-List | Out-String);
        write_stdout -msg $s;
        $pipeconn.Dispose();
        return $null;
    }
}

function exp_2($cnt)
{
    $retcnt = 1;
    for($i=0;$i -lt $cnt ; $i ++) {
        $retcnt *= 2;
    }
    return $retcnt;
}


function pipe_read_message($reader)
{
    try{
        $b = $reader.ReadBytes(4);
        if ($b.Length -lt 4) {
            write_stdout -msg "b Length["$b.Length"]";
            return $null;
        }

        $realcnt = 0;
        for ($i=0;$i -lt $b.Length;$i++) {
            $realcnt += ($b[$i] * (exp_2 -cnt ($i * 8)) );
        }
        if ($realcnt -gt 4) {
            $b = $reader.ReadBytes(($realcnt - 4));
            if ($b.Length -lt ($realcnt - 4)) {
                write_stdout -msg "b Length["$b.Length"]";
                return $null;
            }
            $enc = [System.Text.Encoding]::UTF8;
            return $enc.GetString($b);            
        } 
        return "";
    }
    catch{
        $s = "read message";
        $s += ($error[0] | Out-String);
        write_stderr -msg $s;
        return $null;
    }
}


function pipe_write_message($writer,$msg)
{
    try {
        $enc = [System.Text.Encoding]::UTF8;
        $bs = $enc.GetBytes($msg);
        $realcnt = ($bs.Length + 4);
        $b = New-Object -TypeName System.Byte[] -ArgumentList $realcnt;

        for ($i =0;$i -lt 4 ;$i ++) {
            $b[$i] = ((($realcnt * ( exp_2 -cnt ($i * 8)))) -band 0xff);
        }
        for ($i = 0; $i -lt $bs.Length ; $i ++) {
            $b[($i+4)] = $bs[$i];
        }

        $writer.Write($b);
        return $b.Length;
    }
    catch {
        return -3;
    }
}

$p = connect_namedpipe -pipename $Pipename -rtime 3000 -wtime 3000;
if (-Not $p) {
    write_stderr -msg "can not connect [$Pipename]";
    [Environment]::Exit(2);
}

$reader = New-Object System.IO.BinaryReader($p);
$writer = New-Object System.IO.BinaryWriter($p);

$v = pipe_write_message -writer $writer -msg "hello";
if ($v -lt 0 ) {
    write_stderr -msg "write message error [$v]";
    [Environment]::Exit(5);
}

$v = pipe_read_message -reader $reader;
if (-Not $v) {
    write_stderr -msg "read message error";
    [Environment]::Exit(6);
}
write_stdout -msg "read [$v]";

$p.Dispose();
[Environment]::Exit(0);

