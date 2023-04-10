ListProcessModules(dwPID) {
	me32 := Buffer(A_PtrSize = 8 ? 568 : 548), modules := []
	NumPut("UInt", A_PtrSize = 8 ? 568 : 548, me32, 0)
	hModuleSnap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x08, "UInt", dwPID)
	if (hModuleSnap = -1)
		return FALSE
	if (!DllCall("Module32First", "PTR", hModuleSnap, "PTR", me32)) {
		DllCall("CloseHandle", "PTR", hModuleSnap)
		return FALSE
	}
	while (A_Index = 1 || DllCall("Module32Next", "PTR", hModuleSnap, "PTR", me32)) {
		modules.Push({
			szModule: StrGet(me32.Ptr + A_PtrSize * 4 + 16, "cp0"),
			szExePath: StrGet(me32.Ptr + A_PtrSize * 4 + 272, "cp0"),
			modBaseAddr: NumGet(me32, A_PtrSize + 16, "ptr"),
			modBaseSize: NumGet(me32, A_PtrSize * 2 + 16, "uint")
		})
	}
	DllCall("CloseHandle", "PTR", hModuleSnap)
	return modules
}
/*
 * total size: 548(32 bit) 568(64 bit)
 * struct tagMODULEENTRY32 {
 * UInt	dwSize;			// 0 0
 * UInt	th32ModuleID;	// 4 4
 * UInt	th32ProcessID;	// 8 8
 * UInt	GlblcntUsage;	// 12 12
 * UInt	ProccntUsage;	// 16 16
 * Ptr	modBaseAddr;	// 20 24
 * UInt	modBaseSize;	// 24 32
 * Ptr	hModule;		// 28 40
 * char	szModule[256];	// 32 48
 * char	szExePath[260];	// 288 304
 * } MODULEENTRY32;
 */