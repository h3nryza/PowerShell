
<# 
.Synopsis
	Easy Encrypt and Decrypt information into\from AES
.DESCRIPTION
   This script Encrypts or Decrypts AES information in an easy way
   automatically created 
.Parameter
.Inputs
	-in : Input
	-out : Output [path only, with leading backslash]
.Outputs
	AES encryption, plaintext
.Example
    Encrypt-String "encryptme"
    Decrypt-String "decryptme"
    Encrypt-File -in "C:\test.txt" -out "c:\temp"
    Encrypt-File -in "c:\temp\test" -out "c:\temp"
.Notes
	Created by 	: Henry Stock
	Version 	: V1.0.0.0
	Dated		: April 2018
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>


function Create-AesManagedObject($key,$iv) {

    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    return $aesManaged
}



function Encrypt-String($in) {

    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
    $key =[System.Convert]::ToBase64String($aesManaged.Key)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($in)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    return $key.substring(0,44) +[System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($in) {
    $key = $in.substring(0,44)
    $encryptLength = $in.length - 44
    $encryptedStringNew = $in.substring(44,$encryptLength )
    $bytes = [System.Convert]::FromBase64String($encryptedStringNew)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    return [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
    
}

function Encrypt-File($in,$out){
    $ext = (get-item $in).Extension
    $base = (get-item $in).BaseName
    write-host $ext
    $bytes = [System.IO.File]::ReadAllBytes($in)

    $infodata = [System.Text.Encoding]::ASCII.GetString($bytes)
    $resultdata = Encrypt-String -in $infodata
    $resultext = Encrypt-String -in $ext
    $resultbase = Encrypt-String -in $base

    "$resultdata ***** $resultext ##### $resultbase" | out-file "$out\$base"

}


function Decrypt-File($in,$out){
    $info = get-content $in
    $extpos = $info.IndexOf(" ***** ")
    $infolen = $info.Length -1

    $infodata = $info.Substring(0,$extpos)
    $infodatalen = $infodata.length -1

    $newInfo = $info.Substring($extpos,($infolen-$infodatalen))
    $basepos = $newInfo.IndexOf(" ##### ")
    $infoext = $newInfo.Substring(7,$basepos-7)
    
    $newInfolen = $newInfo.Length
    $infopos = $newInfo.Substring($basepos+7,($newInfolen-$basepos)-7)


    $resultdata = Decrypt-String -in $infodata
    $resultext = Decrypt-String -in $infoext
    $resultpos = Decrypt-String -in $infopos

    $resultdatacomp = $resultdata.replace("`0","").replace("??","")
    "$resultdatacomp" | set-content "$out\$resultpos$resultext" 
}

  