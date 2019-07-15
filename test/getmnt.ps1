$svrip="192.168.2.181";
$netshare="user-user2";
$user="user2";
$passwd="user2";

$chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ";

net use | Select-String -Pattern "^OK" | Select-String  -Pattern $svrip | Select-String -Pattern $netshare | Tee-Object -Variable ttobj | Out-Null;
if ($ttobj.length -gt 0) {
    $s = $ttobj -replace "\s+", " ";
    $arr = $s.split(" ");
    $cv = $arr[1].ToUpper();
    $i =0;
    while ($i -lt 26) {
        $cg = $chars[$i];
        $cg += ":";
        if ($cg.equals($cv)) {
            exit($i);
        }
        $i ++;
    }
}


exit(255);