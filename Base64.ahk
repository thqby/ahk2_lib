
Class Base64 {
	; ===================================================================================================================
	; Base64.Encode()
	; https://docs.microsoft.com/zh-cn/windows/win32/api/wincrypt/nf-wincrypt-cryptbinarytostringa
	; Parameters:
	;    Buf  - Buffer Object has Ptr, Size Property
	;    Codec  - CRYPT_STRING_BASE64 0x00000001
	;			  CRYPT_STRING_NOCRLF 0x40000000
	; return values:
	;    On success: Base64 String
	;    On failure: false
	; Remarks:
	;    VarIn may contain any binary contents including NUll bytes.
	; ===================================================================================================================
	static Encode(Buf, Codec:=0x40000001)=>((DllCall("crypt32\CryptBinaryToString", "Ptr", Buf, "UInt", Buf.Size, "UInt", Codec, "Ptr", 0, "Uint*", nSize:=0) && (VarSetStrCapacity(VarOut, nSize<<1), DllCall("crypt32\CryptBinaryToString", "Ptr", Buf, "UInt", Buf.Size, "UInt", Codec, "Str", VarOut, "Uint*", nSize))) ? (VarSetStrCapacity(VarOut, -1), VarOut) : false)
	
	; ===================================================================================================================
	; Base64.Decode()
	; https://docs.microsoft.com/zh-cn/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinarya
	; Parameters:
	;    VarIn  - Variable containing a null-terminated Base64 encoded string
	;    Codec  - CRYPT_STRING_BASE64 0x00000001
	; return values:
	;    On success: Buffer Object
	;    On failure: false
	; Remarks:
	;    VarOut may contain any binary contents including NUll bytes.
	; ===================================================================================================================
	static Decode(VarIn, Codec:=0x00000001)=>((DllCall("Crypt32.dll\CryptStringToBinary", "Str", VarIn, "UInt", 0, "UInt", Codec, "Ptr", 0, "Uint*", SizeOut:=0, "Ptr", 0, "Ptr", 0) && DllCall("Crypt32.dll\CryptStringToBinary", "Str", VarIn, "UInt", 0, "UInt", Codec, "Ptr", VarOut:=BufferAlloc(SizeOut), "Uint*", SizeOut, "Ptr", 0, "Ptr", 0)) ? VarOut : false)
}
