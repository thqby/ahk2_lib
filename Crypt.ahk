MD5(Data, Size:=0){
	MD5_CTX:=Buffer(104), DllCall("advapi32\MD5Init", "Ptr", MD5_CTX)
	DllCall("advapi32\MD5Update", "Ptr", MD5_CTX, "Ptr", Data, "UInt", (!Size&&Type(Data)="Buffer") ? Data.Size : Size)
	DllCall("advapi32\MD5Final", "Ptr", MD5_CTX), MD5:=""
	Loop 16
		MD5 .= Format("{:02X}", NumGet(MD5_CTX, 87+A_Index, "UChar"))
	return MD5
}

MD5_File(sFile, cSz:=4){
	cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), buf:=Buffer(cSz)
	if 1>(hFil := DllCall("CreateFile", "Str", sFile, "UInt", 0x80000000, "Int", 1, "Int", 0, "Int", 3, "Int", 0, "Int", 0))
		return hFil
	DllCall("GetFileSizeEx", "UInt", hFil, "Ptr", buf), fSz := NumGet(buf, 0, "Int64")
	MD5_CTX:=Buffer(104), DllCall("advapi32\MD5Init", "Ptr", MD5_CTX)
	Loop ( fSz//cSz+!!Mod(fSz,cSz) )
	DllCall("ReadFile", "Ptr", hFil, "Ptr", buf, "UInt", cSz, "UInt*", &bytesRead:=0, "UInt", 0)
	, DllCall("advapi32\MD5Update", "Ptr", MD5_CTX, "Ptr", buf, "UInt", bytesRead)
	DllCall("advapi32\MD5Final", "Ptr", MD5_CTX), DllCall("CloseHandle", "Ptr", hFil), MD5:=""
	Loop 16
		MD5 .= Format("{:02X}", NumGet(MD5_CTX, 87+A_Index, "UChar"))
	return MD5
}

Crypt_Hash(Data, nSize:=0, SID := "CRC32", nInitial := 0){
	CALG_SHA := CALG_SHA1 := 1 + CALG_MD5 := 0x8003, CALG_CRC32 := 0
	if !IsSet(CALG_%SID%)
		throw Error("Unsupported type")
	if (!nSize&&Type(Data)="Buffer")
		nSize := Data.Size
	if (!CALG_%SID%){
		sHash := Format("{:X}", DllCall("ntdll\RtlComputeCrc32", "Uint", 0, "Ptr", Data, "Uint", nSize, "Uint"))
		return sHash
	}

	DllCall("advapi32\CryptAcquireContextA", "Ptr*", &hProv:=0, "Uint", 0, "Uint", 0, "Uint", 1, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "Uint", CALG_%SID%, "Uint", 0, "Uint", 0, "Ptr*", &hHash:=0)
	DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", Data, "Uint", nSize, "Uint", 0), sHash:=""
	DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "Uint", 2, "Ptr", 0, "UInt*", &nSize, "Uint", 0), HashVal := Buffer(nSize)
	DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "Uint", 2, "Ptr", HashVal, "UInt*", &nSize, "Uint", 0)
	DllCall("advapi32\CryptDestroyHash", "Ptr", hHash), DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "Uint", 0)
	Loop nSize
		sHash .= Format("{:02X}", NumGet(HashVal, A_Index-1, "UChar"))
	Return	sHash
}

Crypt_AES(pData, nSize, sPassword, SID := 256, bEncrypt := True){
	CALG_AES_256 := 1 + CALG_AES_192 := 1 + CALG_AES_128 := 0x660E, CALG_SHA := CALG_SHA1 := 1 + CALG_MD5 := 0x8003
	DllCall("advapi32\CryptAcquireContextA", "Ptr*", &hProv:=0, "Uint", 0, "Uint", 0, "Uint", 24, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "Uint", CALG_SHA1, "Uint", 0, "Uint", 0, "Ptr*", &hHash:=0)
	DllCall("advapi32\CryptHashData", "Ptr", hHash, "Str", sPassword, "Uint", StrLen(sPassword)*2, "Uint", 0)
	DllCall("advapi32\CryptDeriveKey", "Ptr", hProv, "Uint", CALG_AES_%SID%, "Ptr", hHash, "Uint", SID<<16, "Ptr*", &hKey:=0)
	DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
	If bEncrypt
		DllCall("advapi32\CryptEncrypt", "Ptr", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Ptr", pData, "Uint*", &nSize, "Uint", nSize+16)
	Else DllCall("advapi32\CryptDecrypt", "Ptr", hKey, "Uint", 0, "Uint", True, "Uint", 0, "Ptr", pData, "Uint*", &nSize)
	DllCall("advapi32\CryptDestroyKey", "Ptr", hKey)
	DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "Uint", 0)
	Return	nSize
}
