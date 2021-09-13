#DllImport ReadProcessMemory, Kernel32\ReadProcessMemory, i==tttutut*
#DllImport WriteProcessMemory, Kernel32\WriteProcessMemory, i==tttutut*
#DllImport VirtualProtectEx, Kernel32\VirtualProtectEx, i==ttutuiui*

; OpenProcess(dwDesiredAccess, bInheritHandle, dwProcessId) => DllCall('OpenProcess', 'uint', dwDesiredAccess, 'int', bInheritHandle, 'uint', dwProcessId, 'ptr')
; ReadProcessMemory(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesRead) => DllCall('Kernel32\ReadProcessMemory', 'ptr', hProcess, 'ptr', lpBaseAddress, 'ptr', lpBuffer, 'uptr', nSize, 'uptr*', lpNumberOfBytesRead, 'int')
; WriteProcessMemory(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesWritten) => DllCall('Kernel32\WriteProcessMemory', 'ptr', hProcess, 'ptr', lpBaseAddress, 'ptr', lpBuffer, 'uptr', nSize, 'uptr*', lpNumberOfBytesWritten, 'int')
; VirtualProtectEx(hProcess, lpAddress, dwSize, flNewProtect, lpflOldProtect) => DllCall('Kernel32\VirtualProtectEx', 'ptr', hProcess, 'ptr', lpAddress, 'uptr', dwSize, 'uint', flNewProtect, 'uint*', lpflOldProtect, 'int')

class MemoryViewer {
	ptr := 0
	__New(pid, access := 2097151) {
		if !this.ptr := OpenProcess(0x38, false, pid)
			throw Error('Open Process Fail', -1)
	}
	Read(lpBaseAddress, nSize) {
		buf := Buffer(nSize)
		if ReadProcessMemory(this, lpBaseAddress, buf, nSize, &r := 0) {
			if (r < nSize)
				buf.Size := r
			return BufferViewer(buf)
		}
		throw OSError(A_LastError)
	}
	Write(lpBaseAddress, lpBuffer, nSize) {
		if !WriteProcessMemory(this, lpBaseAddress, lpBuffer, nSize, &nSize)
			throw OSError(A_LastError)
	}
	VirtualProtect(lpAddress, dwSize, flNewProtect) {
		if !VirtualProtectEx(this, lpAddress, dwSize, flNewProtect, &old := 0)
			throw OSError(A_LastError)
		return old
	}
}

class BufferViewer {
	__New(buf) {
		this.buf := buf, this.ptr := buf.ptr, this.size := buf.size
	}
	__Delete() {
		this.buf := 0
	}
	Hex {
		get {
			static b2h := DllCall.Bind(a := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'crypt32'), 'astr', 'CryptBinaryToStringW', 'ptr'), 'ptr', , 'uint', , 'uint', 0x40000004, 'wstr', , 'uint*', , 'int')
			sz := (len := this.size) * 6
			b2h(this, len, (VarSetStrCapacity(&s, sz), s), &sz)
			return s
		}
	}
	AStr => StrGet(this, 'cp0')
	WStr => StrGet(this, 'utf-16')
	Utf8 => StrGet(this, 'utf-8')
	Char => this.viewNumbers(A_ThisFunc)
	Short => this.viewNumbers(A_ThisFunc)
	Int => this.viewNumbers(A_ThisFunc)
	Int64 => this.viewNumbers(A_ThisFunc)
	Float => this.viewNumbers(A_ThisFunc)
	Double => this.viewNumbers(A_ThisFunc)
	viewNumbers(t) {
		static tps := {char: 1, short: 2, int: 4, int64: 8, float: 4, double: 8}
		t := SubStr(t, InStr(t, '.', , , 2) + 1, -4)
		s := '', c := tps.%t%
		loop this.Size // c
			s .= NumGet(this, (A_Index - 1) * c, t) ' '
		return s
	}
}
