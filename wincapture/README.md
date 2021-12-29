# wincapture

## DXGI

### example
```autohotkey
dxcp := wincapture.DXGI()

F7:: {
	t := A_TickCount, i := 0
	loop n := 100000
		; capture full screen
		try bb := dxcp.captureAndSave() {
			i++
			continue
		} catch TimeoutError	; DXGI_ERROR_WAIT_TIMEOUT
			continue
	t := A_TickCount - t
	MsgBox '每帧' (t / i) 'ms (有效帧)`n每帧' (t / n) 'ms (总)'
}

box := Buffer(16,0)
; capture range
NumPut("uint", 400, "uint", 400, "uint", 800, "uint", 800, box)
try dxcp.captureAndSave(box).savebmp('1.bmp')

cb := CallbackCreate(revice)
; revice by callback
dxcp.capture(cb)
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

## DWM

## WGC