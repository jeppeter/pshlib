$svrip="%s";
$netshare="%s";
$user="%s";
$passwd="%s";

$chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ";

net use | Select-String -Pattern "^OK" | Select-String  -Pattern $svrip | Select-String -Pattern $netshare | Tee-Object -Variable ttobj | Out-Null;

$ttval="";
if ($ttobj) {
    $ttval=$ttobj.ToString();
    Write-Host "ttval[$ttval]";
}
if ($ttval.length -gt 0) {
    $s = $ttobj -replace "\s+", " ";
    $arr = $s.split(" ");
    $cv = $arr[1].ToUpper();
    $i =0;
    while ($i -lt 26) {
        $cg = $chars[$i];
        $cg += ":";
        if ($cg.equals($cv)) {
            Write-Host "get [$cg]";
            exit($i + 1);
        }
        $i ++;
    }
}

Write-Host "ttobj["$ttobj"]";

exit(255);