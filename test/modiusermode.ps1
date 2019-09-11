# ParamTest.ps1 - Show some parameter features
# Param statement must be first non-comment, non-blank line in the script
Param(
    $Personal,
    $Desktop,
    $Favorites,
    $MyMusic,
    $MyPic,
    $MyVideo,
    $Downloads,
    $SavedGames,
    $Contacts)


function get_value_global($varname)
{
    $v = Get-Variable -Name $varname -ValueOnly -Scope Global; 
    return $v;
}

function set_value_global($varname,$varvalue)
{
    Set-Variable -Name $varname -Value $varvalue -Scope Global
}

function copy_dir($sourcedir,$destdir)
{
    $ret=0;
    $v = Copy-Item -Path $sourcedir -Destination $destdir -Recurse -PassThru -ErrorAction SilentlyContinue;
    for($i=0;$i -lt $Error.Count; $i++) {
        $curerr = $Error[$i];
        $vcce = ($curerr.FullyQualifiedErrorId  | Out-String) ;
        $lowervcce = $vcce.ToLower();
        if ( -Not ($lowervcce.StartsWith("copydirectoryinfoitemioerror,") -Or $lowervcce.StartsWith("directoryexist,"))) {
            [Console]::Error.WriteLine.Invoke("[$i]"+($curerr | Out-String));
            $ret = 2;
        }
    }
    return $ret;
}


function get_reg_value($path,$key)
{
    $retval="";
    $kv = Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue;
    if ($Error.Count -eq 0) {
        $retval = $kv.$key.ToString();
    } else {
        [Console]::Error.WriteLine.Invoke(($Error| Format-List | Out-String));
    }
    return $retval;
}



if (![string]::IsNullOrEmpty($Personal)) {
    Write-Host "Personal [$Personal]";
    $OldPersonal = $Personal;
}

if (![string]::IsNullOrEmpty($OldPersonal)) {
    Write-Host "OldPersonal [$OldPersonal]";
}





