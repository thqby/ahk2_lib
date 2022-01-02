# wincapture
This library contains 3 types of windows capture, as well as waiting for screen changes, bitmap grayscale, binarization, colors search and picture search.

## DXGI
Screen capture by [DXGI desktop duplication](https://docs.microsoft.com/en-us/windows/win32/direct3ddxgi/desktop-dup-api
), support for use in multiple threads and only one instance in the process.

## DWM
Window capture by `DwmGetDxSharedSurface`, background windows(excluding minimization) are supported, but some windows are not supported.

## WGC
Window and Monitor capture by `winrt` [Windows.Graphics.Capture](https://docs.microsoft.com/en-us/uwp/api/windows.graphics.capture?view=winrt-20348), background windows(excluding minimization) are supported, and only win10 1903 or above is supported.

## example
```autohotkey
dxcp := wincapture.DXGI()

F7:: {
	t := A_TickCount, i := 0
	loop n := 100000
		; capture full screen
		try {
			bb := dxcp.captureAndSave()
			i++
			continue
		} catch TimeoutError	; DXGI_ERROR_WAIT_TIMEOUT
			continue
	t := A_TickCount - t
	MsgBox (t / i) 'ms (valid frame)`n' (t / n) 'ms (total)'
}

box := Buffer(16,0)
; capture range
x := Random(0, A_ScreenWidth - 200), y := Random(0, A_ScreenHeight - 200)
NumPut("uint", x, "uint", y, "uint", x + 200, "uint", y + 200, box)

if dxcp.waitScreenChange(15000, box)
	MsgBox "screen0[" x "," y "," (x + 200) "," (y + 200) "] has changed"
else MsgBox("wait timeout")

; save to bmp
try dxcp.captureAndSave(box).save('1.bmp')
dxcp.freeBuffer()	; It's not necessary

cb := CallbackCreate(revice)
; revice by callback
dxcp.capture(cb)
dxcp.release()	; It's not necessary

revice(pdata, pitch, sw, sh, tick) {
	if tick && pdata {
		bb := BitmapBuffer(pdata, pitch, sw, sh)
		
		; find picture
		t3 := A_TickCount
		if bb.findPic(&x,&y, t := BitmapBuffer.loadPicture("1.bmp"))
			t3 := A_TickCount - t3, fillcolor(x, y, 0xff0000ff, 40)

		; get pixel color
		color := bb[Random(0, A_ScreenWidth - 1), Random(0, A_ScreenHeight - 1)]
		; search pixel
		t1 := A_TickCount
		if bb.findColor(&x, &y, color)
			t1 := A_TickCount - t1, fillcolor(x, y, 0xff00ff00)

		; search multi pixel combination
		arr := [], x := Random(0, A_ScreenWidth), y := Random(0, A_ScreenHeight)
		loop 9 {
			xx := Random(-x, A_ScreenWidth - x - 1), yy := Random(-y, A_ScreenHeight - y - 1)
			arr.Push([bb[x + xx, y + yy], xx, yy])
		}
		t2 := A_TickCount
		if bb.findMultiColors(&x, &y, arr) {
			t2 := A_TickCount - t2
			for a in arr
				fillcolor(a[2] + x, a[3] + y, 0xffff0000)
		}

		; preview
		bb.show("src")
		t.show("dst")
		MsgBox "findColor: " t1 "ms`nfindMultiColors: " t2 "ms`nfindPic: " t3 "ms"
	}
	fillcolor(x, y, color, r := 20) {
		loop r {
			i := A_Index - 1
			loop r
				bb[x + i, y + A_Index - 1] := color
		}
	}
}
```
