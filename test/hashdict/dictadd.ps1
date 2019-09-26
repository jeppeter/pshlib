

function remove_first_commands($arrlist) {
    $retlist = @();
    $insert = $false;


    foreach($c in $arrlist) {
        if ($insert) {
            $retlist += $c;
        } else {
            if ($c -eq "") {
                $insert = $true;
            }
        }
    }
    return $retlist;
}

function get_first_commands($arrlist) {
    $retlist = $null;
    $insert = $false;

    foreach($c in $arrlist) {
        if ($c -eq "") {
            break;
        }
        if ( -Not $insert) {
            $retlist = @();
        }
        $insert = $true;
        $retlist += $c;
    }

    return $retlist;
}

function insert_commands($arrlist,$c)
{
    $insert = $false;
    foreach($b in $c) {
        $insert = $true;
        $arrlist += $b;
    }

    if ($insert) {
        $arrlist += "";
    }
    return $arrlist;
}


$arrlist = New-Object System.Collections.ArrayList;

$arrlist = insert_commands -arrlist $arrlist -c "Subcmd","gethostipmac";
$arrlist = insert_commands -arrlist $arrlist -c "Subcmd","getipmac";
$arrlist = insert_commands -arrlist $arrlist -c "Subcmd","gethostpass","Passowrd","hello";

$arrlist | Format-Table;

$f = get_first_commands -arrlist $arrlist;
Write-Host "first";
$f | Format-Table;

$arrlist = remove_first_commands -arrlist $arrlist;

Write-Host "new";
$arrlist | Format-Table;

$f = get_first_commands -arrlist $arrlist;
Write-Host "first";
$f | Format-Table;

$arrlist = remove_first_commands -arrlist $arrlist;
$arrlist = remove_first_commands -arrlist $arrlist;

Write-Host "new2";
$arrlist | Format-Table;

$f = get_first_commands -arrlist $arrlist;
if (-Not $f) {
    Write-Host "no first";
} else {
    Write-Host "first";
    $f | Format-Table;
}
