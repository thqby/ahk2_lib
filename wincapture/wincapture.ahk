/************************************************************************
 * @description Windows capture library, including `DXGI`, `DWM`, `WGC`. And some bitmap functions.
 * @author thqby
 * @date 2021/12/29
 * @version 1.1.176
 ***********************************************************************/

class wincapture {
	static ptr := 0, refcount := 0
	static init(path := "") {
		if (!this.ptr) {
			if !(module := DllCall("LoadLibrary", "str", path || A_LineFile "\..\" (A_PtrSize * 8) "bit\wincapture.dll", "ptr"))
				throw Error("load dll fail")
			this.ptr := module
		}
		++this.refcount
	}
	static free() {
		if (this.refcount) {
			if (--this.refcount)
				return
			DllCall("FreeLibrary", "ptr", this)
			this.ptr := 0
		}
	}

	; Screen capture by `DXGI desktop duplication`, support for multithreading and only one instance in the process.
	; https://docs.microsoft.com/en-us/windows/win32/direct3ddxgi/desktop-dup-api
	class DXGI {
		__New(path := "") {
			wincapture.init(path)
			if hr := DllCall("wincapture\dxgi_start", "uint")
				throw OSError(hr)
		}
		__Delete() {
			DllCall("wincapture\dxgi_end", "uint")
			wincapture.free()
		}
		/**
		 * @param callback A callback function for accepting data, the received data is valid before the next capture or release. `void callback(BYTE* pBits, UINT Pitch, UINT Width, UINT Height, INT64 Tick)`, no data available when Tick is 0
		 * @param box Coordinates of the top left and bottom right corner of the capture area.
		 * struct { int x1, int y1, int x2, int y2 }
		 * 
		 * The coordinates in the top left corner of the capture screen are {0,0} when index >= 0
		 * 
		 * The coordinates are the virtual screen coordinates when index < 0, don't supported across multiple screens
		 * @param index The index of the output.
		 * @returns HRESULT	S_OK, DXGI_ERROR_WAIT_TIMEOUT, ...
		 */
		capture(callback, box := 0, index := 0) {
			switch hr := DllCall("wincapture\dxgi_capture", "ptr", callback, "ptr", box, "uint", index, "uint") {
				case 0:
				case 0x887A0027:
					throw TimeoutError(OSError(0x887A0027).Message, -1)
				default:
					throw OSError(hr, -1)
			}
		}
		; @param data struct { BYTE* pBits, UINT Pitch, UINT Width, UINT Height, INT64 Tick }
		captureAndSave(box := 0, index := 0) {
			switch hr := DllCall("wincapture\dxgi_captureAndSave", "ptr*", &pdata := 0, "ptr", box, "uint", index, "uint") {
				case 0:
					return BitmapBuffer.fromCaptureData(pdata)
				case 0x887A0027:
					throw TimeoutError(OSError(0x887A0027).Message, -1)
				default:
					throw OSError(hr, -1)
			}
		}
		; reset() => DllCall("wincapture\dxgi_reset", "uint")
		/**
		 * @param cached Cached the capture screen, otherwise capture multiple different regions in the same screen will wait for the next frame (ps: If there are no new frames will wait at least 1s).
		 */
		canCachedFrame(cached := false) => DllCall("wincapture\dxgi_canCachedFrame", "int", cached)
		/**
		 * @param timeout The time-out interval, in milliseconds. This interval specifies the amount of time that this method waits for a new frame before it returns to the caller. This method returns if the interval elapses, and a new desktop image is not available.
		 */
		setTimeout(timeout := 0) => DllCall("wincapture\dxgi_setTimeout", "uint", timeout)
		/**
		 * @param visible capture cursor when visible = true
		 */
		showCursor(visible := false) => DllCall("wincapture\dxgi_showCursor", "int", visible)
		/**
		 * release the captured texture.
		 * @param index The index of the output. release last captured texture when index = -1
		 */
		release(index := -1) => DllCall("wincapture\dxgi_releaseTexture", "int", index)
	}

	; Window capture by `DwmGetDxSharedSurface`, background windows are supported, but the minimized windows and some windows are not supported.
	; https://docs.microsoft.com/en-us/windows/win32/dwm/dwm-overview
	class DWM {
		ptr := 0
		__New(path := "") {
			wincapture.init(path)
			if hr := DllCall("wincapture\dwm_init", "ptr*", this)
				throw OSError(hr)
		}
		__Delete() {
			DllCall("wincapture\dwm_free", "ptr", this)
			wincapture.free()
		}
		capture(hwnd, box := 0) {
			if hr := DllCall("wincapture\dwm_capture", "ptr", this, "ptr", hwnd, "ptr", box, "ptr", data := Buffer(32))
				throw OSError(hr)
			return BitmapBuffer.fromCaptureData(data.Ptr)
		}
		release() => DllCall("wincapture\dwm_releaseTexture", "ptr", this)
	}

	; Window and Monitor capture by `Windows.Graphics.Capture`, background windows are supported, and only win10 1903 or above is supported.
	; https://docs.microsoft.com/en-us/uwp/api/windows.graphics.capture?view=winrt-20348
	class WGC {
		ptr := 0
		__New(hwnd_or_monitor_or_index := 1, persistent := true, path := "") {
			wincapture.init(path)
			if (hwnd_or_monitor_or_index <= MonitorGetCount())
				ptr := DllCall("wincapture\wgc_init_monitorindex", "int", hwnd_or_monitor_or_index, "int", persistent, "ptr")
			else if DllCall("IsWindow", "ptr", hwnd_or_monitor_or_index)
				ptr := DllCall("wincapture\wgc_init_window", "ptr", hwnd_or_monitor_or_index, "int", persistent, "ptr")
			else
				ptr := DllCall("wincapture\wgc_init_monitor", "ptr", hwnd_or_monitor_or_index, "int", persistent, "ptr")
			if !ptr
				throw Error("create capture source fail")
			this.ptr := ptr
		}
		__Delete() {
			DllCall("wincapture\wgc_free", "ptr", this)
			wincapture.free()
		}
		showCursor(visible := false) => DllCall("wincapture\wgc_showCursor", "ptr", this, "int", visible)
		; show or hide the colored border around the capture source to indicate that a capture is in progress.
		; Each time switch devices, the colored border will be shown.
		isBorderRequired(required := false) => DllCall("wincapture\wgc_isBorderRequired", "ptr", this, "int", required)
		; Acquire all the frames of the capture source in the free thread to speed up each capture
		persistent(persistent := true) => DllCall("wincapture\wgc_persistent", "ptr", this, "int", persistent)
		release() => DllCall("wincapture\wgc_releaseTexture", "ptr", this)
		capture(box := 0) {
			switch r := DllCall("wincapture\wgc_capture", "ptr", this, "ptr", box, "ptr", data := Buffer(32)) {
				case 0:
					return BitmapBuffer.fromCaptureData(data.Ptr)
				case -1:
					throw ValueError("Invalid capture range")
				case -2:
					throw TimeoutError("No frames available")
				case -3:
					throw Error("Invalid source")
				default:
					throw OSError(r)
			}
		}
	}
}

class BitmapBuffer {
	__New(bits, pitch, width, height, bytespixel := 4, offsetx := 0, offsety := 0) {
		NumPut("ptr", bits, "uint", pitch, "uint", width, "uint", height, "uint", bytespixel, "uint", offsetx, "uint", offsety, this.info := Buffer(40, 0))
		this.ptr := bits
		this.pitch := pitch
		this.width := width
		this.height := height
		this.size := pitch * height
		this.bytespixel := bytespixel
		this.offsetx := offsetx, this.offsety := offsety
		switch bytespixel {
			case 4: tp := "uint"
			case 2: ; tp := "ushort"
				throw TypeError("unsupported bitmap type")
			case 1: tp := "uchar"
			case 3: this.DefineProp("__Item", { get: (s, x, y) => NumGet(s, y * s.pitch + x * 3, "uint") & 0xffffff, set: (s, v, x, y) => NumPut("uint", v, s, y * s.pitch + x * 3) })
			default:
				throw ValueError("invalid bytespixel")
		}
		if (bytespixel != 3)
			this.DefineProp("__Item", { get: (s, x, y) => NumGet(s, y * s.pitch + x * bytespixel, tp), set: (s, v, x, y) => NumPut(tp, v, s, y * s.pitch + x * bytespixel) })
	}
	static fromCaptureData(data, offsetx := 0, offsety := 0) {
		bb := BitmapBuffer(NumGet(data, "ptr"), NumGet(data += A_PtrSize, "uint"), NumGet(data += 4, "int"), NumGet(data += 4, "int"), 4, offsetx, offsety)
		bb.tick := NumGet(data + 4, "int64")
		return bb
	}
	static create(width, height, bytespixel := 4) {
		line := (width * bytespixel + 3) >> 2 << 2
		data := Buffer(line * height, 0)
		bb := BitmapBuffer(data.Ptr, line, width, height, bytespixel)
		bb.data := data
		return bb
	}
	updateDesc() {
		b := this.info, o := A_PtrSize
		this.pitch := NumGet(b, o, "int")
		this.width := NumGet(b, o += 4, "int")
		this.height := NumGet(b, o += 4, "int")
		this.bytespixel := NumGet(b, o += 4, "int")
		this.offsetx := NumGet(b, o += 4, "int")
		this.offsety := NumGet(b, o += 4, "int")
		this.size := this.pitch * this.height
	}
	getHexColor(x, y) => Format("0x{:08X}", this[x, y])
	cvtBytes(bytes := 4, bmp := unset) {
		if !IsSet(bmp)
			bmp := BitmapBuffer.create(this.width, this.height, Max(1, bytes))
		if !DllCall("wincapture\cvtBytes", "ptr", this.info, "ptr", bmp.info, "short", bytes)
			throw TypeError("invalid BitmapData")
		bmp.updateDesc()
		return bmp
	}
	cvtGray(mode := 0, threshold := unset, bmp := unset) {
		if !IsSet(bmp)
			bmp := BitmapBuffer.create(this.width, this.height, 1)
		if IsSet(threshold)
			tp := "char*"
		else tp := "ptr", threshold := 0
		if IsObject(mode) {
			buf := Buffer(24, 0)
			for k, v in mode
				switch k, false {
					case 1, "r": NumPut("double", v, buf)
					case 2, "g": NumPut("double", v, buf)
					case 3, "b": NumPut("double", v, buf)
					default:
						throw ValueError("invalid key")
				}
			if !DllCall("wincapture\cvtGray", "ptr", this.info, "ptr", bmp.info, tp, threshold, "ptr", buf)
				throw TypeError("invalid BitmapData")
		}
		if mode != 0 && mode != 1
			throw ValueError("mode only is 0 or 1")
		if !DllCall("wincapture\cvtGray", "ptr", this.info, "ptr", bmp.info, tp, threshold, "ptr", mode)
			throw TypeError("invalid BitmapData")
		if bmp != this
			bmp.updateDesc()
		return bmp
	}
	copyRangeData(dst, linestep, x := 0, y := 0, w := 0, h := 0) {
		if (w * h)
			NumPut("uint", x, "uint", y, "uint", w, "uint", h, roi := Buffer(16))
		else roi := 0
		DllCall("wincapture\copyBitmapData", "ptr", this.info, "ptr", dst, "int", linestep, "ptr", roi)
	}
	range(x1 := 0, y1 := 0, x2 := unset, y2 := unset, copy := false) {
		if !IsSet(x2)
			x2 := this.width
		if !IsSet(y2)
			y2 := this.height
		w := x2 - x1, h := y2 - y1, pitch := this.pitch, src := this.ptr + y1 * pitch + x1 * this.bytespixel
		if (copy) {
			line := (this.bytespixel * w + 3) >> 2 << 2
			data := Buffer(size := line * h, 0), ptr := data.Ptr
			bb := BitmapBuffer(ptr, line, w, h, this.bytespixel, this.offsetx + x1, this.offsety + y1), bb.data := data
			NumPut("uint", x1, "uint", y1, "uint", x2, "uint", y2, roi := Buffer(16))
			DllCall("wincapture\copyBitmapData", "ptr", this.info, "ptr", bb, "int", line, "ptr", roi)
			return bb
		} else
			return BitmapBuffer(src, pitch, w, h, this.bytespixel, this.offsetx + x1, this.offsety + y1)
	}
	findColor(&x, &y, color, variation := 0, direction := 0) {
		return DllCall("wincapture\findColor", "uint*", &x := 0, "uint*", &y := 0, "ptr", this.info, "uint", color, "uint", variation, "int", direction)
	}
	findAllColor(color, maxcount := 10, variation := 0, direction := 0) {
		if size := DllCall("wincapture\findAllColor", "ptr", buf := Buffer(8 * maxcount), "uint", maxcount, "ptr", this.info, "uint", color, "uint", variation, "int", direction) {
			t := [], p := buf.Ptr
			loop size
				t.Push({ x: NumGet(p, "int"), y: NumGet(p += 4, "int") }), p += 4
			return t
		}
	}
	findMultiColors(&x, &y, colors, similarity := 1.0, variation := 0, direction := 0) {
		if colors is Array {
			t := colors
			p := NumPut("int", t.Length, colors := Buffer(4 + t.Length * 12))
			for it in t
				for k, v in it
					p := NumPut("int", v, p)
		}
		return DllCall("wincapture\findMultiColors", "int*", &x := 0, "int*", &y := 0, "ptr", this.info, "ptr", colors, "float", similarity, "uint", variation, "int", direction)
	}
	findAllMultiColors(colors, similarity := 1.0, maxcount := 10, variation := 0, direction := 0) {
		if colors is Array {
			t := colors
			p := NumPut("int", t.Length, colors := Buffer(4 + t.Length * 12))
			for it in t
				for k, v in it
					p := NumPut("int", v, p)
		}
		if size := DllCall("wincapture\findAllMultiColors", "ptr", buf := Buffer(8 * maxcount), "uint", maxcount, "ptr", this.info, "ptr", colors, "float", similarity, "uint", variation, "int", direction) {
			t := [], p := buf.Ptr
			loop size
				t.Push({ x: NumGet(p, "int"), y: NumGet(p += 4, "int") }), p += 4
			return t
		}
	}
	clone() => this.range(0, 0, this.width, this.height, true)
	save(path) {
		if this.bytespixel < 3
			return this.cvtBytes(3).save(path)
		bm := Buffer(54, 0), pitch := this.pitch
		sw := this.width, sh := this.height
		line := (sw * this.bytespixel + 3) >> 2 << 2, size := this.size
		NumPut("ushort", 0x4d42, "uint", 54 + size, "uint", 0, "uint", 54, "uint", 40,
			"int", sw, "int", -sh, "ushort", 1, "ushort", this.bytespixel * 8, "uint", 0, "uint", size, bm)
		file := FileOpen(path, "w"), file.RawWrite(bm)
		if (line == pitch)
			file.RawWrite(this)
		else {
			p := this.ptr
			loop sh
				file.RawWrite(p, line), p += pitch
		}
		file.Close()
	}
	show(guiname := "") {
		static guis := Map()
		if this.bytespixel < 3
			return this.cvtBytes(3).show(guiname)
		if (!guis.Has(guiname)) {
			g := guis[guiname] := Gui("AlwaysOnTop +Resize +E0x08000000 -DPIScale", guiname), g.obm := 0
			g.hdc := { ptr: DllCall("GetDC", "ptr", g.hwnd, "ptr"), __Delete: (s) => DllCall("ReleaseDC", "ptr", g.Hwnd, "ptr", s) }
			g.mdc := { ptr: DllCall("CreateCompatibleDC", "ptr", g.hdc, "ptr"), __Delete: (s) => DllCall("DeleteDC", "ptr", s) }
			DllCall("SetStretchBltMode", "Ptr", g.hdc, "int", 4)
			if this.width > 0.8 * A_ScreenWidth
				g.Show("NA w" (w := 0.8 * A_ScreenWidth) " h" (w / this.width * this.height))
			else if this.height > 0.8 * A_ScreenHeight
				g.Show("NA h" (h := 0.8 * A_ScreenHeight) " w" (h / this.height * this.width))
			else g.Show("NA w" this.width " h" this.height)

			g.OnEvent("Close", (g, * ) => (DllCall("DeleteObject", "ptr", DllCall("SelectObject", "ptr", g.mdc, "ptr", g.obm, "ptr")), g.mdc := g.hdc := 0, WinClose(g), guis.Delete(guiname)))
			g.OnEvent("Size", (g, * ) => (g.GetClientPos(, , &w, &h), g.obm ? DllCall("StretchBlt", "ptr", g.hdc, "int", 0, "int", 0, "int", w, "int", h, "ptr", g.mdc, "int", 0, "int", 0, "int", g.width, "int", g.height, "uint", 0x00CC0020) : 0))
		} else (g := guis[guiname]).Show("NA")

		bm := bm2 := Buffer(40, 0), sw := this.width, sh := this.height, ptr := this.ptr, size := this.size, linebytes := (sw * this.bytespixel + 3) >> 2 << 2
		NumPut("uint", 40, "int", sw, "int", -sh, "ushort", 1, "ushort", this.bytespixel * 8, "uint", 0, "uint", linebytes * sh, bm)
		if linebytes != this.pitch
			NumPut("int", Integer(this.pitch / this.bytespixel), bm2 := ClipboardAll(bm2), 4), NumPut("uint", size, bm2, 20)
		hbm := DllCall("CreateDIBitmap", "ptr", g.hdc, "ptr", bm, "uint", 4, "ptr", ptr, "ptr", bm2, "int", 0, "ptr")
		if (g.obm)
			DllCall("DeleteObject", "ptr", DllCall("SelectObject", "ptr", g.mdc, "ptr", hbm, "ptr"))
		else g.obm := DllCall("SelectObject", "ptr", g.mdc, "ptr", hbm, "ptr")
		g.width := this.width, g.height := this.height
		g.GetClientPos(, , &w, &h)
		DllCall("StretchBlt", "ptr", g.hdc, "int", 0, "int", 0, "int", w, "int", h, "ptr", g.mdc, "int", 0, "int", 0, "int", g.width, "int", g.height, "uint", 0x00CC0020)
	}
}