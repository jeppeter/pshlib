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
    $Contacts,
    $Searches,
    $Links,
    $Cookies,
    $Cache,
    $History,
    $Recent,
    $TempFile,
    $AppData,
    $FileAppend,
    [switch]$RemoveOld,
    [switch]$CopyFiles)





function _my_file_name()
{
    return $MyInvocation.ScriptName;
}

function get_current_file_dir()
{
# Determine script location for PowerShell
    $curpath = _my_file_name;
    return Split-Path $curpath;
}


. ("{0}\valop.ps1" -f (get_current_file_dir));
. ("{0}\fileop.ps1" -f (get_current_file_dir));
. ("{0}\regop.ps1" -f (get_current_file_dir));
. ("{0}\backupop.ps1" -f (get_current_file_dir));


$errorcode=0;
$diffed=0;

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Personal)) {
    $retval = backup_directory -keyname "Personal" -newdir $Personal -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Personal[$Personal]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Desktop)) {
    $retval = backup_directory -keyname "Desktop" -newdir $Desktop -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Desktop[$Desktop]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Favorites)) {
    $retval = backup_directory -keyname "Favorites" -newdir $Favorites -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Favorites[$Favorites]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($MyMusic)) {
    $retval = backup_directory -keyname "My Music" -newdir $MyMusic -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On MyMusic[$MyMusic]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}


if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($MyPic)) {
    $retval = backup_directory -keyname "My Pictures" -newdir $MyPic -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On MyPic[$MyPic]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($MyVideo)) {
    $retval = backup_directory -keyname "My Video" -newdir $MyVideo -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On MyVideo[$MyVideo]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Cookies)) {
    $retval = backup_directory -keyname "Cookies" -newdir $Cookies -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Cookies[$Cookies]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}


if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Cache)) {
    $retval = backup_directory -keyname "Cache" -newdir $Cache -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Cache[$Cache]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($History)) {
    $retval = backup_directory -keyname "History" -newdir $History -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On History[$History]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Recent)) {
    $retval = backup_directory -keyname "Recent" -newdir $Recent -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Recent[$Recent]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($AppData)) {
    $retval = backup_directory -keyname "AppData" -newdir $AppData -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On AppData[$AppData]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}




if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Downloads)) {
    $retval = backup_spec -keyname "download" -itemname $DOWNLOAD_ITEM_NAME -newdir $Downloads -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Downloads[$Downloads]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($SavedGames)) {
    $retval = backup_spec -keyname "savedgames" -itemname $SAVED_GAME_ITEM_NAME -newdir $SavedGames -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On SavedGames[$SavedGames]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Contacts)) {
    $retval = backup_spec -keyname "contacts" -itemname $CONTACTS_ITEM_NAME -newdir $Contacts -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Contacts[$Contacts]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Searches)) {
    $retval = backup_spec -keyname "search" -itemname $SEARCH_ITEM_NAME -newdir $Searches -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Searches[$Searches]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($Links)) {
    $retval = backup_spec -keyname "link" -itemname $LINK_ITEM_NAME -newdir $Links -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On Links[$Links]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -eq 0 -And -Not [string]::IsNullOrEmpty($TempFile)) {
    $retval = backup_temp -newdir $TempFile -copied $CopyFiles -removed $RemoveOld;
    if ($retval -lt 0) {
        write_stderr -msg "error On TempFile[$TempFile]";
        $errorcode = 3;
    } elseif ($retval -gt 0) {
        $diffed = 1;
    }
}

if ($errorcode -ne 0) {
    $c = restore_directory -keyname "Personal";  
    $c = restore_directory -keyname "Desktop";  
    $c = restore_directory -keyname "Favorites";  
    $c = restore_directory -keyname "My Music";  
    $c = restore_directory -keyname "My Pictures";  
    $c = restore_directory -keyname "My Video";
    $c = restore_directory -keyname "Cookies";  
    $c = restore_directory -keyname "Cache";  
    $c = restore_directory -keyname "History";  
    $c = restore_directory -keyname "Recent";  
    $c = restore_directory -keyname "AppData";  
    $c = restore_spec -keyname "download" -itemname $DOWNLOAD_ITEM_NAME ;  
    $c = restore_spec -keyname "savedgames" -itemname $SAVED_GAME_ITEM_NAME;  
    $c = restore_spec -keyname "contacts" -itemname $CONTACTS_ITEM_NAME;  
    $c = restore_spec -keyname "search" -itemname $SEARCH_ITEM_NAME ;  
    $c = restore_spec -keyname "link" -itemname $LINK_ITEM_NAME ;  
    $c = restore_temp ;
}

if ($errorcode -ne 0) {    
    [Environment]::Exit($errorcode);
}

write_stdout -msg "diffed [$diffed]";
[Environment]::Exit($diffed);
