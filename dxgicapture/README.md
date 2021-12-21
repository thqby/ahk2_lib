# DXGI

## example
```autohotkey
dxcp := dxgicapture()

F7:: {
	t := A_TickCount, i := 0
	loop n := 100000
		; capture full screen
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
; capture range
NumPut("uint", 400, "uint", 400, "uint", 800, "uint", 800, box)
hr := dxcp.captureAndSave(&data, box)
if hr = 0 || (hr = 0x887A0027 && data)
	BitmapBuffer.fromCaptureData(data).savebmp('1.bmp', data)

cb := CallbackCreate(revice)
; revice by callback
if !dxcp.capture(cb)
	throw
revice(pdata, pitch, sw, sh, tick) {
	if tick && pdata {
		bb := BitmapBuffer(pdata, pitch, sw, sh)
		; save to bmp
		bb.save("1.bmp")
		; get pixel color
		color := bb[12,23]
		; preview
		bb.show()
		; search pixel
		if !bb.findColor(&x, &y, 0x123456)
			MsgBox "not found"
		; search multi pixel combination
		if !bb.findMultiColors(&x, &y, [[0x123456, 0, 0], [0x545938, 12, 85], [0x547138, 12, 18], [0x549378, 36, 8]], 0.98)
			MsgBox "not found"
	}
}
```