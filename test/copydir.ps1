# for source dir

Param(
    $Sourcedir,
    $Destdir)


function usage_format($usagestr) {
    
}

function Usage($ec,$usagestr)
{

}

if ([string]::IsNullOrEmpty($Sourcedir) ||
    [string]::IsNullOrEmpty($Destdir)) {
    Usage
}