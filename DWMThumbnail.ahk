class DWMThumbnail {
	static thumbnails := Map(), thumbnails.Default := 0
	static Call(hwnd) {
		if !(hwnd is Integer)
			hwnd := WinExist(hwnd)
		if thumbnail := DWMThumbnail.thumbnails[hwnd]
			return thumbnail
		thumbnail := {base: DWMThumbnail.Prototype}
		thumbnail.__New(hwnd)
		return DWMThumbnail.thumbnails[hwnd] := thumbnail
	}
	__New(hwnd) {
		this.gui := g := Gui("+AlwaysOnTop +E0x08000000 ToolWindow Resize -DPIScale")
		if hr := DllCall("dwmapi\DwmRegisterThumbnail", "ptr", g.Hwnd, "UInt", hwnd, "ptr*", &thumbnail := 0) {
			g.Destroy()
			throw OSError(hr)
		}
		this.ptr := thumbnail
		this.querySourceSize(&w, &h)
		g.OnEvent("Size", onSize.Bind(thumbnail))
		g.OnEvent("Close", (*) => DWMThumbnail.thumbnails.Has(hwnd) ? DWMThumbnail.thumbnails.Delete(hwnd) : 0)
		g.Show(Format("w{} h{} NA", w / 2, h / 2))
		this.show()

		onSize(id, GuiObj, MinMax, Width, Height) {
			NumPut("uint", 1, buf := Buffer(45, 0))
			if !DllCall("dwmapi\DwmQueryThumbnailSourceSize", "ptr",this, "ptr",size := Buffer(8)) {
				w := NumGet(size, "int"), h := NumGet(size, 4, "int")
				if w * Height > Width * h {
					h0 := h * Width / w, h1 := (Height - h0) / 2
					NumPut("int", h1, "int", Width, "int", h0 + h1, buf, 8)
				} else {
					w0 := w * Height / h, w1 := (Width - w0) / 2
					NumPut("int", w1, "int", 0, "int", w0 + w1, "int", Height, buf, 4)
				}
			} else
				NumPut("int", Width, "int", Height, buf, 12)
			DllCall("dwmapi\DwmUpdateThumbnailProperties", "ptr", id, "ptr", buf)
		}
	}
	querySourceSize(&width, &height) {
		if hr := DllCall("dwmapi\DwmQueryThumbnailSourceSize", "ptr",this, "ptr",size := Buffer(8))
			throw OSError(hr)
		width := NumGet(size, "int")
		height := NumGet(size, 4, "int")
	}
	updateProperties(properties) {
		buf := Buffer(45, 0), flags := 0
		for k, v in properties {
			switch k, false {
				case "rcDestination", "dest", "d":
					flags |= 1, NumPut("int", v[1], "int", v[2], "int", v[3], "int", v[4], buf, 4)
				case "rcSource", "src", "s":
					if v
						flags |= 2, NumPut("int", v[1], "int", v[2], "int", v[3], "int", v[4], buf, 20)
				case "opacity", "o":
					flags |= 4, NumPut("uchar", v, buf, 36)
				case "fVisible", "vis", "v":
					flags |= 8, NumPut("int", v, buf, 37)
				case "fSourceClientAreaOnly", "client", "c":
					flags |= 16, NumPut("int", v, buf, 41)
			}
		}
		NumPut("uint", flags, buf)
		if hr := DllCall("dwmapi\DwmUpdateThumbnailProperties", "ptr", this, "ptr", buf)
			throw OSError(hr)
	}
	show(dst := 0, src := 0) {
		if !dst {
			this.gui.GetClientPos(,, &w, &h)
			dst := [0, 0, w, h]
		}
		this.gui.Show("NA")
		WinActivate(this.gui.Hwnd)
		this.updateProperties({ v: 1, d: dst, s: src })
	}
	hide() => (this.updateProperties({ v: 0 }), this.gui.Hide())
	onlyClientArea(client := true) => this.updateProperties({c: client})
	setOpacity(opacity) => this.updateProperties({o: opacity})
	__Delete() {
		DllCall("dwmapi\DwmUnregisterThumbnail", "ptr", this)
		this.gui := 0
	}
}
