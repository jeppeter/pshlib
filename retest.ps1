#! powershell

function match
{
    Param([string]$restr,[string]$instr);
    Write-Host "match call restr[$restr] instr[$instr]";
    return;
}

function findall
{
    Param([string]$restr,[string]$instr);
    Write-Host "findall call restr[$restr] instr[$instr]";
    return;
}

function usage
{
    Param([int]$exitcode,[string]$fmt);
    if ($ec -ne 0) {
        Write-Host $fmt;
    }
    Write-Host "retest.ps1 [cmd] ...";
    Write-Host "[COMMAND]:";
    Write-Host "    match   restr instr ...      to make match";
    Write-Host "    findall restr instr ...      to make findall";
    exit($exitcode);
}

if ($args.count -lt 2) {
    usage -exitcode 3 -fmt "less than 2 arguments";
}


$cmd=$args[0];
if ($cmd.equals("match")) {
    if ($args.count -lt 3) {
        usage -exitcode 3 -fmt "match need at least 3 params";
    }
    $restr = $args[1];
    for($i=2;$i -lt $args.count;$i++) {
        match -restr $restr -instr $args[$i];
    }
} elseif ($cmd.equals("findall")) {
    if ($args.count -lt 3) {
        usage -exitcode 3 -fmt "findall need at least 3 params";
    }
    $restr = $args[1];
    for($i=2;$i -lt $args.count;$i++) {
        findall -restr $restr -instr $args[$i];
    }
} else {
    usage -exitcode 4 -fmt "unknown command ["+ $cmd +"]";
}