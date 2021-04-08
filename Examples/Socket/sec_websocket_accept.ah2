sec_websocket_accept(key) {
	buf := BufferAlloc(size := StrPut(key .= "258EAFA5-E914-47DA-95CA-C5AB0DC85B11", "utf-8") - 1), StrPut(key, buf, "utf-8")
	DllCall("advapi32\CryptAcquireContextA", "Ptr*", &hProv := 0, "Uint", 0, "Uint", 0, "Uint", 1, "Uint", 0xF0000000)
	DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "Uint", CALG_SHA1 := 0x8004, "Uint", 0, "Uint", 0, "Ptr*", &hHash := 0)
	DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", buf, "Uint", size, "Uint", 0)
	DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "Uint", 2, "Ptr", 0, "UInt*", &size, "Uint", 0), HashVal := BufferAlloc(size)
	DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "Uint", 2, "Ptr", HashVal, "UInt*", &size, "Uint", 0)
	DllCall("advapi32\CryptDestroyHash", "Ptr", hHash), DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "Uint", 0)
	DllCall("crypt32\CryptBinaryToString", "Ptr", HashVal, "UInt", size, "UInt", 0x40000001, "Ptr", 0, "Uint*", &_size := 0)
	VarSetStrCapacity(&secaccept, _size << 1)
	DllCall("crypt32\CryptBinaryToString", "Ptr", HashVal, "UInt", size, "UInt", 0x40000001, "Str", secaccept, "Uint*", &_size)
	return secaccept
}