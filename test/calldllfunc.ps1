Param($srcfile,$dstfile,[switch]$forced);

$MethodDefinition = @"
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
public static extern bool CopyFile(string lpExistingFileName, string lpNewFileName, bool bFailIfExists);
"@;

$Kernel32 = Add-Type -MemberDefinition $MethodDefinition -Name "Kernel32" -Namespace "Win32" -PassThru

# You may now call the CopyFile function
$retval = $Kernel32::CopyFile($srcfile,$dstfile,$forced);
Write-Host "[$srcfile]=>[$dstfile][$forced] [$retval]";
