; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=21223
SyncCallbackCreate(Fn, Options := '', ParamCount := Fn.MinParams) {
	static sMsg := DllCall('RegisterWindowMessage', 'str', 'AHK_SYNC_CALLBACK', 'uint')
	static sSendMessageW := (OnMessage(sMsg, SyncCallback_Proc, 255), DllCall('GetProcAddress',
		'ptr', DllCall('GetModuleHandle', 'str', 'user32.dll', 'ptr'), 'astr', 'SendMessageW', 'ptr'))
	if !pcb := DllCall('GlobalAlloc', 'uint', 0, 'ptr', 80, 'ptr')
		throw MemoryError()
	DllCall('VirtualProtect', 'ptr', pcb, 'ptr', 96, 'uint', 0x40, 'uint*', 0)
	if A_PtrSize == 8 {
		lParamPtr := NumPut('int64', 0x54894808244c8948, 'int64', 0x4c182444894c1024,
			'int64', 0x28ec834820244c89, 'int64', 0xb9493024448d4c, pcb) - 1
		p := NumPut('char', 0xba, 'int', sMsg, 'char', 0xb9, 'int', A_ScriptHwnd,
			'short', 0xb848, 'ptr', sSendMessageW, 'int64', 0x00c328c48348d0ff, lParamPtr, 8)
	} else {
		p := NumPut('char', 0x68, 'int', 0, 'int', 0x0824448d, 'short', 0x6850, 'int', sMsg,
			'char', 0x68, 'int', A_ScriptHwnd, 'char', 0xb8, 'ptr', sSendMessageW, 'short', 0xd0ff,
			'char', 0xc2, 'short', InStr(Options, 'C') ? 0 : ParamCount * 4, pcb), lParamPtr := pcb + 1
	}
	NumPut('ptr', p, lParamPtr), NumPut('ptr', ObjPtrAddRef(Fn), 'int', InStr(Options, '&') ? -1 : ParamCount, p)
	return pcb
	static SyncCallback_Proc(wParam, lParam, msg, hwnd) {
		if hwnd !== A_ScriptHwnd
			return
		fn := ObjFromPtrAddRef(NumGet(lParam, 'ptr'))
		if 0 > paramCount := NumGet(lParam, A_PtrSize, 'int')
			return fn(wParam)
		params := []
		loop paramCount
			params.Push(NumGet(wParam, 'ptr')), wParam += A_PtrSize
		return fn(params*)
	}
}

SyncCallbackFree(Address) {
	ObjRelease(NumGet(Address, A_PtrSize == 8 ? 67 : 30, 'ptr'))
	DllCall('GlobalFree', 'ptr', Address)
}