Param($Arg1,$Arg2,$Arg3,$Arg4,$Arg5);

$cnt=0;
if (-Not [string]::IsNullOrEmpty($Arg1)) {
    $cnt ++;
}

if (-Not [string]::IsNullOrEmpty($Arg2)) {
    $cnt ++;
}

if (-Not [string]::IsNullOrEmpty($Arg3)) {
    $cnt ++;
}

if (-Not [string]::IsNullOrEmpty($Arg4)) {
    $cnt ++;
}

if (-Not [string]::IsNullOrEmpty($Arg5)) {
    $cnt ++;
}

[Environment]::Exit($cnt);