Class Base64 {
	/**
	 * Base64编码
	 * @param Buf Buffer Object has Ptr, Size Property. May contain any binary contents including NUll bytes.
	 * @param Codec CRYPT_STRING_BASE64 0x00000001
	 * CRYPT_STRING_NOCRLF 0x40000000
	 * @returns Base64 String if success, otherwise blank.
	 */
	static Encode(Buf, Codec := 0x40000001) {
		if Buf is String
			p := StrPtr(Buf), s := StrLen(Buf) * 2
		else p := Buf, s := Buf.Size
		if (DllCall("crypt32\CryptBinaryToString", "Ptr", p, "UInt", s, "UInt", Codec, "Ptr", 0, "Uint*", &nSize := 0) &&
			(VarSetStrCapacity(&VarOut, nSize << 1), DllCall("crypt32\CryptBinaryToString", "Ptr", p, "UInt", s, "UInt", Codec, "Str", VarOut, "Uint*", &nSize)))
			return (VarSetStrCapacity(&VarOut, -1), VarOut)
	}

	/**
	 * Base64解码
	 * https://docs.microsoft.com/zh-cn/windows/win32/api/wincrypt/nf-wincrypt-cryptstringtobinarya
	 * @param VarIn Variable containing a null-terminated Base64 encoded string
	 * @param Codec CRYPT_STRING_BASE64 0x00000001
	 * @returns buffer if success, otherwise blank.
	 * VarOut may contain any binary contents including NUll bytes.
	 */
	static Decode(VarIn, Codec := 0x00000001) {
		if (DllCall("crypt32\CryptStringToBinary", "Str", VarIn, "UInt", 0, "UInt", Codec, "Ptr", 0, "Uint*", &SizeOut := 0, "Ptr", 0, "Ptr", 0) &&
			DllCall("Crypt32.dll\CryptStringToBinary", "Str", VarIn, "UInt", 0, "UInt", Codec, "Ptr", VarOut := Buffer(SizeOut), "Uint*", &SizeOut, "Ptr", 0, "Ptr", 0))
			return VarOut
	}
}