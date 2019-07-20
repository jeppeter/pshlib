

$ccaa = "new","old";
[System.Collections.ArrayList]$arr =$ccaa;
$arr.Remove("new");
$arr.Remove("old");
$arr.Add("hello");
#$arr.Add("world");
$i = 0;
foreach($c in $arr) {
    Write-Host "[$i]=[$c]";
    $i ++;
}