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

$ccaa = "new","old";
[System.Collections.ArrayList]$shares =$ccaa;
[System.Collections.ArrayList]$disk =$ccaa;
$shares.Remove("new");
$shares.Remove("old");
$disk.Remove("new");
$disk.Remove("old");


if ($ttval.length -gt 0) {
    # now we delete all the things we need
    $i = 0;
    foreach($c in $ttobj) {
        $s = $c -replace "\s+"," ";
        $arr = $s.split(" ");
        if (-Not ($arr[2] -match "-")) {
            Write-Host "add ["$arr[2]"] ["$arr[1]"]";
            $shares.Add($arr[2]);
            $disk.Add($arr[1]);
        }
        Write-Host "[$i]=["$arr[1]"]";
        net use $arr[1] /delete /Y;
        $i ++;
    }
}


$i=0;
foreach($c in $shares) {
    $n = $shares[$i];
    $d = $disk[$i];
    net use $d $n  /user:$user $passwd;
    if (-Not $?) {
        Write-Host "can not mount [$n] on [$d] error";
    }
    $i ++;
}


$chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
$i = 3;
while ($i -lt 26) {
    $mntlabel = $chars[$i];
    $c = "$mntlabel";
    $c += ":";
    Write-Host "c [$c]";
    Write-Host "net use $c \\$svrip\$netshare /user:$user $passwd";
    net use $c \\$svrip\$netshare /user:$user $passwd /persistent:no;
    if ($?) {
        exit(0);
    }
    $i++;
}

Write-Host "can not mount \\$svrip\$netshare /user:$user $passwd";
exit(3);


