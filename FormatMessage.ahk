FormatMessage(err, module := 0) {
	flags := 0x100 | (module ? 0x800 : 0x1000)
	DllCall("FormatMessage", "uint", flags, "ptr", module, "uint", err, "uint", 0, "ptr*", &pstr := 0, "uint", 0, "ptr", 0)
	if (pstr) {
		msg := StrGet(pstr)
		DllCall('LocalFree', 'ptr', pstr)
		return msg
	}
}