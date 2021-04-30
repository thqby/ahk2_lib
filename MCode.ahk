MCode(hex) {
	dwFlags := Map("1", 4, "2", 1), c := (A_PtrSize = 8) ? "x64" : "x86"
	If (!RegExMatch(hex, "i)^([12]),(" c ":|.*?," c ":)([^,]+)", &m))
		If (hex ~= "i)^[\dA-F]+$")
			m1 := 1, m3 := hex
		Else
			throw Exception("MCode格式不正确")
	If (!DllCall("crypt32\CryptStringToBinary", "Str", m3, "UInt", 0, "UInt", dwFlags[m1], "Ptr", 0, "UInt*", &s := 0, "Ptr", 0, "Ptr", 0))
		throw Exception("MCode解码失败")
	code := Buffer(s)
	DllCall("VirtualProtect", "Ptr", code, "UInt", s, "UInt", 0x40, "Ptr", 0)
	If (DllCall("crypt32\CryptStringToBinary", "Str", m3, "UInt", 0, "UInt", dwFlags[m1], "Ptr", code, "UInt*", &s, "Ptr", 0, "Ptr", 0))
		Return MCode.Bind(code)
	throw Exception("MCode解码失败")
	MCode(buf, arg*) => DllCall(buf.Ptr, arg*)
}