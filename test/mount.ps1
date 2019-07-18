$svrip="%s";
$netshare="%s";
$user="%s";
$passwd="%s";
net use | Select-String -Pattern "^OK" | Select-String  -Pattern $svrip | Select-String -Pattern $netshare | Tee-Object -Variable ttobj | Out-Null;
$ttval="";
if ($ttobj) {
    $ttval=$ttobj.ToString();    
    Write-Host "run ok 0" ;
    exit(0);
}

Write-Host "no \\$svrip\$netshare";

net use |  Select-String -Pattern $svrip |Tee-Object -Variable ttobj | Out-Null;
$ttval="";
if ($ttobj) {
    $ttval=$ttobj.ToString();
}

if ($ttval.length -gt 0) {
    # now we delete all the things we need
    $i = 0;
    foreach($c in $ttobj) {
        $s = $c -replace "\s+"," ";
        $arr = $s.split(" ");
        Write-Host "[$i]=["$arr[1]"]";
        net use $arr[1] /delete /Y; 
        $i ++;
    }
}
$chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$i = 3;
while ($i -lt 26) {
    $mntlabel = $chars[$i];
    $c = "$mntlabel";
    $c += ":";
    Write-Host "c [$c]";
    Write-Host "net use $c \\$svrip\$netshare /user:$user $passwd";
    net use $c \\$svrip\$netshare /user:$user $passwd;
    if ($?) {
        exit(0);
    }
    $i++;
}

Write-Host "can not mount \\$svrip\$netshare /user:$user $passwd";
exit(3);


