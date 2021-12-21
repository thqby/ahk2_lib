# DXGI

## example
```autohotkey
dxcp := dxgicapture()

F7:: {
	t := A_TickCount, i := 0
	loop n := 100000
		if !hr := dxcp.captureAndSave(&data) {
			i++
			continue
		} else if hr == 0x887A0027	; DXGI_ERROR_WAIT_TIMEOUT
			continue
		else
			throw OSError(hr)
	t := A_TickCount - t
	MsgBox '每帧' (t / i) 'ms (有效帧)`n每帧' (t / n) 'ms (总)'
}

box := Buffer(16,0)
NumPut("uint", 400, "uint", 400, "uint", 800, "uint", 800, box)
hr := dxcp.captureAndSave(&data, box)
if hr = 0 || (hr = 0x887A0027 && data)
	dxcp.savebmp('1.bmp', data)

cb := CallbackCreate(revice)
if !dxcp.capture(cb)
	throw
revice(pdata, pitch, sw, sh, tick) {
	; save to bmp
	if tick && pdata {
		bm := Buffer(54)
		size := 4 * sw * sh, line := sw * 4
		StrPut("BM", bm, "CP0")
		NumPut("uint", 54 + size, bm, 2)
		NumPut("uint", 0, bm, 6)
		NumPut("uint", 54, bm, 10)

		NumPut("uint", 40, bm, 14)
		NumPut("uint", sw, bm, 18)
		NumPut("int", -sh, bm, 22)
		NumPut("ushort", 1, bm, 26)
		NumPut("ushort", 32, bm, 28)

		NumPut("uint", 0, bm, 30)
		NumPut("uint", size, bm, 34)
		NumPut("int", 0, bm, 38)
		NumPut("int", 0, bm, 42)
		NumPut("uint", 0, bm, 46)
		NumPut("uint", 0, bm, 50)

		file := FileOpen("1.bmp", "w"), file.RawWrite(bm)
		if (line == pitch)
			file.RawWrite(pdata, size)
		else {
			p := pdata
			loop sh
				file.RawWrite(p, line), p += pitch
		}
		file.Close()
	}
}
```