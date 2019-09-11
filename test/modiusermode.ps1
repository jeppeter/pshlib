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




if (![string]::IsNullOrEmpty($Personal)) {
    Write-Host "Personal [$Personal]";
    $OldPersonal = $Personal;
}

if (![string]::IsNullOrEmpty($OldPersonal)) {
    Write-Host "OldPersonal [$OldPersonal]";
}





