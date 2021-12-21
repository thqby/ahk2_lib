/************************************************************************
 * @description Screen capture by DXGI desktop duplication, support for multithreading.
 * Bitmap functions:
 * - get pixel colors
 * - search pixel(s)
 * - save to bmp and preview
 * @author thqby
 * @date 2021/12/21
 * @version 1.1.13
 ***********************************************************************/

class dxgicapture {
	static module := 0
	__New(path := "") {
		if (!dxgicapture.module) {
			if !(dxgicapture.module := DllCall("GetModuleHandle", "str", "dxgicapture.dll", "ptr") || DllCall("LoadLibrary", "str", path || A_LineFile "\..\" (A_PtrSize * 8) "bit\dxgicapture.dll", "ptr"))
				throw Error("load dll fail")
		}
		if hr := DllCall("dxgicapture\start", "uint")
			throw OSError(hr)
	}
	__Delete() {
		if dxgicapture.module && DllCall("dxgicapture\end", "uint") == 0
			DllCall("FreeLibrary", "ptr", dxgicapture.module), dxgicapture.module := 0
	}
	/**
	 * @param callback A callback function that accepts data that will be released at the end of the callback. `void callback(BYTE* pBits, UINT Pitch, UINT Width, UINT Height, INT64 Tick)`, no data available when Tick is 0
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
		return DllCall("dxgicapture\capture", "ptr", callback, "ptr", box, "uint", index, "uint")
	}
	; @param data struct { BYTE* pBits, UINT Pitch, UINT Width, UINT Height, INT64 Tick }
	captureAndSave(&data, box := 0, index := 0) {
		return DllCall("dxgicapture\captureAndSave", "ptr*", &data := 0, "ptr", box, "uint", index, "uint")
	}
	reset() {
		return DllCall("dxgicapture\reset", "uint")
	}
	/**
	 * @param cached Cached the capture screen, otherwise capture multiple different regions in the same screen will wait for the next frame (ps: If there are no new frames will wait at least 1s).
	 */
	canCachedFrame(cached := true) {
		DllCall("dxgicapture\canCachedFrame", "int", cached)
	}
	/**
	 * @param timeout The time-out interval, in milliseconds. This interval specifies the amount of time that this method waits for a new frame before it returns to the caller. This method returns if the interval elapses, and a new desktop image is not available.
	 */
	setTimeout(timeout := 0) {
		DllCall("dxgicapture\setTimeout", "uint", timeout)
	}
	/**
	 * @param show capture cursor when show = true
	 */
	showCursor(show := false) {
		DllCall("dxgicapture\showCursor", "int", show)
	}
	; save picture data from calling `captureAndSave` to bmp file
	savebmp(path, data) {
		BitmapBuffer.fromCaptureData(data).save(path)
	}
}

class BitmapBuffer {
	__New(bits, pitch, width, height, offsetx := 0, offsety := 0) {
		this.ptr := bits
		this.pitch := pitch
		this.width := width
		this.height := height
		this.size := pitch * height
		this.offsetx := offsetx, this.offsety := offsety
		NumPut("ptr", bits, "uint", pitch, "uint", width, "uint", height, this.info := Buffer(12 + A_PtrSize))
	}
	static fromCaptureData(data, offsetx := 0, offsety := 0) {
		return BitmapBuffer(NumGet(data, "ptr"), NumGet(data += A_PtrSize, "uint"), NumGet(data += 4, "uint"), NumGet(data + 4, "uint"), offsetx, offsety)
	}
	__Item[x, y] {
		get => NumGet(this, y * this.pitch + x * 4, "uint")
		set => NumPut("uint", Value, this, y * this.pitch + x * 4)
	}
	getHexColor(x, y) => Format("0x{:08X}", NumGet(this, y * this.pitch + x * 4, "uint"))
	range(x1, y1, x2, y2, copy := false) {
		w := x2 - x1, h := y2 - y1, pitch := this.pitch, src := this.ptr + y1 * pitch + x1 * 4
		if (copy) {
			line := 4 * w, this.data := Buffer(line * h)
			ptr := dst := this.data.Ptr, size := this.data.Size
			loop h
				DllCall("RtlMoveMemory", "ptr", dst, "ptr", src, "uint", line), dst += line, src += pitch
			return BitmapBuffer(ptr, 4 * w, w, h)
		} else
			return BitmapBuffer(src, pitch, w, h, x1, y1)
	}
	findColor(&x, &y, color, variation := 0, direction := 0) {
		if r := DllCall("dxgicapture\findColor", "uint*", &x := 0, "uint*", &y := 0, "ptr", this.info, "uint", color, "uint", variation, "int", direction)
			x += this.offsetx, y += this.offsety
		return r
	}
	findAllColor(color, maxcount := 10, variation := 0, direction := 0) {
		if size := DllCall("dxgicapture\findAllColor", "ptr", buf := Buffer(8 * maxcount), "uint", maxcount, "ptr", this.info, "uint", color, "uint", variation, "int", direction) {
			t := [], p := buf.Ptr
			loop size
				t.Push({x: NumGet(p, "int") + this.offsetx, y: NumGet(p += 4, "int") + this.offsety}), p += 4
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
		if r := DllCall("dxgicapture\findMultiColors", "int*", &x := 0, "int*", &y := 0, "ptr", this.info, "ptr", colors, "float", similarity, "uint", variation, "int", direction)
			x += this.offsetx, y += this.offsety
		return r
	}
	findAllMultiColors(colors, similarity := 1.0, maxcount := 10, variation := 0, direction := 0) {
		if colors is Array {
			t := colors
			p := NumPut("int", t.Length, colors := Buffer(4 + t.Length * 12))
			for it in t
				for k, v in it
					p := NumPut("int", v, p)
		}
		if size := DllCall("dxgicapture\findAllMultiColors", "ptr", buf := Buffer(8 * maxcount), "uint", maxcount, "ptr", this.info, "ptr", colors, "float", similarity, "uint", variation, "int", direction) {
			t := [], p := buf.Ptr
			loop size
				t.Push({x: NumGet(p, "int") + this.offsetx, y: NumGet(p += 4, "int") + this.offsety}), p += 4
			return t
		}
	}
	save(path) {
		bm := Buffer(54, 0), pitch := this.pitch
		sw := this.width, sh := this.height
		line := sw * 4, size := this.size
		NumPut("ushort", 0x4d42, "uint", 54 + size, "uint", 0, "uint", 54, "uint", 40,
			"int", sw, "int", -sh, "ushort", 1, "ushort", 32, "uint", 0, "uint", size, bm)
		file := FileOpen(path, "w"), file.RawWrite(bm)
		if (line == pitch)
			file.RawWrite(this.ptr, size)
		else {
			p := this.ptr
			loop sh
				file.RawWrite(p, line), p += pitch
		}
		file.Close()
	}
	show(guiname := "") {
		static guis := Map()
		NumPut("uint", 40, "int", this.pitch / 4, "int", this.height, "short", 1, "short", 32, "uint", 0, "uint", this.size, bi := Buffer(40, 0))
		hbm := DllCall("CreateBitmap", "int", this.width, "int", this.height, "uint", 1, "uint", 32, "ptr", this, "ptr")
		if (!guis.Has(guiname)) {
			g := guis[guiname] := Gui("+Resize -DPIScale", guiname), g.MarginX := g.MarginY := 0
			g.AddPicture("w" this.width " h" this.height " vpic", "HBITMAP:" hbm), g.Show()
			g.OnEvent("Close", (o, * ) => (WinClose(o), guis.Delete(guiname)))
			g.OnEvent("Size", (o, * ) => (o.GetClientPos(, , &w, &h), o["pic"].Move(, , w, h), o["pic"].Redraw()))
		} else
			WinActivate(g := guis[guiname]), g["pic"].Value := "HBITMAP:" hbm
		DllCall("DeleteObject", "ptr", hbm)
	}
}