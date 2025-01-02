WriteConsoleInput(pid := 0, cmd := '') {
	static ir2 := Buffer(40), attach_pid := -1, attach_hwnd := -1, conin, hConIn
	static pir2 := NumPut('int64', 0x100000001, 'int64', 1, 'int', 0, 'int64', 1, 'int64', 1, 'int', 0, ir2) - 40
	if pid !== attach_pid || DllCall('GetConsoleWindow', 'ptr') !== attach_hwnd {
		DllCall('FreeConsole')
		if !pid
			return conin := !attach_pid := attach_hwnd := -1
		if !DllCall('AttachConsole', 'uint', pid)
			throw OSError()
		conin := FileOpen('CONIN$', 'w'), hConIn := conin.Handle
		attach_pid := pid, attach_hwnd := DllCall('GetConsoleWindow', 'ptr') || -1
	}
	loop parse cmd {
		NumPut('ushort', char := Ord(A_LoopField), NumPut('ushort', char, pir2, 14) + 20)
		if !DllCall('WriteConsoleInputW', 'ptr', hConIn, 'ptr', pir2, 'uint', 2, 'uint*', 0)
			throw OSError()
	}
}
