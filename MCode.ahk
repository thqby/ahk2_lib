MCode(hex, argtypes := 0, &code := 0) {
	static reg := "^([12]?).*" (c := A_PtrSize = 8 ? "x64" : "x86") ":([A-Za-z\d+/=]+)"
	if (RegExMatch(hex, reg, &m))
		hex := m[2], flag := m[1] = "1" ? 4 : m[1] = "2" ? 1 : hex ~= "[+/=]" ? 1 : 4
	else
		flag := hex ~= "[+/=]" ? 1 : 4
	if (!DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", 0, "uint*", &s := 0, "ptr", 0, "ptr", 0))
		return
	code := Buffer(s)
	if (DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", code, "uint*", &s, "ptr", 0, "ptr", 0) && DllCall("VirtualProtect", "ptr", code, "uint", s, "uint", 0x40, "uint*", 0)) {
		args := []
		if (Type(argtypes) = "Array" && argtypes.Length) {
			args.Length := argtypes.Length * 2 - 1
			for i, t in argtypes
				args[i * 2 - 1] := t
		}
		return DllCall.Bind(code, args*)
	}
}