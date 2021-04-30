OpenFolderAndSelect(path, selfilearr) {
	if !(FolderPidl := DllCall("shell32\ILCreateFromPath", "Str", path := Trim(path, "\")))
		return
	Loop (plist := Buffer(selfilearr.Length * A_PtrSize, 0), pidls := [], selfilearr.Length)
		if (!DllCall("shell32\SHParseDisplayName", "Str", InStr(selfilearr[A_Index], ":") ? selfilearr[A_Index] : path "\" selfilearr[A_Index], "Ptr", 0, "Ptr*", &ItemPidl := 0, "Uint", 0, "Uint*", 0))
			pidls.Push(ItemPidl), NumPut("ptr", ItemPidl, plist, (pidls.Length - 1) * A_PtrSize)
	DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", FolderPidl, "UInt", pidls.Length, "Ptr", plist, "Int", 0), pidls.Push(FolderPidl)
	Loop pidls.Length
		DllCall("ole32\CoTaskMemFree", "ptr", pidls[A_Index])
}