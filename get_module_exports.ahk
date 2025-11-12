get_module_exports(mod) {
	if !mod
		mod := DllCall('GetModuleHandleW', 'ptr', 0, 'ptr')
	else if (DllCall('GetModuleFileNameW', 'ptr', mod, 'ptr*', 0, 'uint', 1), A_LastError = 126)
		Throw OSError()
	entry_export := mod + NumGet(mod, data_directory_offset := NumGet(mod, 60, 'uint') + 104 + A_PtrSize * 4, 'uint')
	entry_export_end := entry_export + NumGet(mod, data_directory_offset + 4, 'uint')
	func_tbl_offset := NumGet(entry_export, 0x1c, 'uint'), name_tbl_offset := NumGet(entry_export, 0x20, 'uint')
	ordinal_tbl_offset := NumGet(entry_export, 0x24, 'uint'), exports := Map()
	loop NumGet(entry_export, 0x18, 'uint') {
		ordinal := NumGet(mod, ordinal_tbl_offset, 'ushort'), fn_ptr := mod + NumGet(mod, func_tbl_offset + ordinal * 4, 'uint')
		if entry_export <= fn_ptr && fn_ptr < entry_export_end {
			fn_name := StrSplit(StrGet(fn_ptr, 'cp0'), '.')
			fn_ptr := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', fn_name[1], 'ptr'), 'astr', fn_name[2], 'ptr')
		}
		exports[StrGet(mod + NumGet(mod, name_tbl_offset, 'uint'), 'cp0')] := fn_ptr, name_tbl_offset += 4, ordinal_tbl_offset += 2
	}
	return exports
}