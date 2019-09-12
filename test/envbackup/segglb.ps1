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

function DebugValue($varname)
{
    $v = get_value_global -varname $varname;
    Write-Host "[$varname]=[$v]";
}


$global:Var1="Var1Value";
$global:Var2="Var2Value";


DebugValue -varname "Var1";
DebugValue -varname "Var2";

set_value_global -varname "Var1" -varvalue "Var1Changed";
set_value_global -varname "Var2" -varvalue "Var2Changed";

DebugValue -varname "Var1";
DebugValue -varname "Var2";
