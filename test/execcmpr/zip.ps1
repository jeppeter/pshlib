Param(
    $InFile);
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
$zipinst = New-Object -TypeName ZipCode;
$con = (Get-Content -Path $InFile | Out-String);
$zipstr = $zipinst.Zip($con);
Write-Host "zipstr[$zipstr]";
