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




if (![string]::IsNullOrEmpty($Personal)) {
    Write-Host "Personal [$Personal]";
    $OldPersonal = $Personal;
}

if (![string]::IsNullOrEmpty($OldPersonal)) {
    Write-Host "OldPersonal [$OldPersonal]";
}





