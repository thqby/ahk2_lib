; BSTR wrapper, convert BSTR to AHK string and free it
BSTR(ptr) {
	static _ := DllCall("LoadLibrary", "str", "oleaut32.dll")
	if ptr {
		s := StrGet(ptr), DllCall("oleaut32\SysFreeString", "ptr", ptr)
		return s
	}
}