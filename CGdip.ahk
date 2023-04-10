/************************************************************************
 * @description Gdip类
 * @file CGdip.ahk
 * @author thqby
 * @date 2023/02/05
 * @version 1.0.8
 ***********************************************************************/

#Requires AutoHotkey v2.0-beta
class CGdip
{
	static pToken := 0, hModule := 0, RefCount := 0

	static Startup() {
		CGdip.RefCount += 1
		if CGdip.RefCount > 1
			return CGdip.pToken
		if (!CGdip.hModule && !DllCall("GetModuleHandle", "Str", "gdiplus", "Ptr"))
			CGdip.hModule := DllCall("LoadLibrary", "Str", "gdiplus")
		si := Buffer(A_PtrSize = 8 ? 24 : 16, 0), NumPut("UInt", 1, si, 0)
		DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken := 0, "Ptr", si, "Ptr", 0), CGdip.pToken := pToken
		return pToken
	}

	static Shutdown() {
		CGdip.RefCount -= 1
		if CGdip.RefCount > 0
			return 0
		if CGdip.pToken
			DllCall("gdiplus\GdiplusShutdown", "Ptr", CGdip.pToken), CGdip.pToken := 0
		if CGdip.hModule
			DllCall("FreeLibrary", "Ptr", CGdip.hModule), CGdip.hModule := 0
		return 0
	}

	static SetImageAttributesColorMatrix(Matrix) {
		ColourMatrix := Buffer(100, 0)
		Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", , 1), "[^\d-\.]+", "|")
		Matrix := StrSplit(Matrix, "|")
		Loop 25
		{
			Matrix_ := (Matrix[A_Index] != "") ? Matrix[A_Index] : Mod(A_Index - 1, 6) ? 0 : 1
			NumPut("float", Matrix_, ColourMatrix, (A_Index - 1) * 4)
		}
		DllCall("gdiplus\GdipCreateImageAttributes", "Ptr*", &ImageAttr := 0)
		DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "Ptr", ImageAttr, "int", 1, "int", 1, "Ptr", ColourMatrix, "Ptr", 0, "int", 0)
		return ImageAttr
	}

	static DisposeImageAttributes(ImageAttr) {
		return DllCall("gdiplus\GdipDisposeImageAttributes", "Ptr", ImageAttr)
	}

	static CreateRegion() {
		DllCall("gdiplus\GdipCreateRegion", "UInt*", &Region := 0)
		return Region
	}

	static DeleteRegion(Region) {
		return DllCall("gdiplus\GdipDeleteRegion", "Ptr", Region)
	}

	static GetImageDimensions(pBitmap, &Width, &Height) {
		Width := 0, Height := 0
		DllCall("gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "Uint*", &Width)
		DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "Uint*", &Height)
	}

	static GetImageWidth(pBitmap) {
		DllCall("gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "Uint*", &Width := 0)
		return Width
	}

	static GetImageHeight(pBitmap) {
		DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "Uint*", &Height := 0)
		return Height
	}

	class Graphics
	{
		Ptr := 0, hdc := 0

		__New(pGraphics) {
			if (!pGraphics)
				throw "invalid pGraphics"
			else
				this.Ptr := pGraphics
		}

		__Delete() {
			if (!CGdip.pToken)
				return
			if this.hdc
				this.ReleaseDC()
			if (this.Ptr)
				DllCall("gdiplus\GdipDeleteGraphics", "Ptr", this)
		}

		static FromHDC(hdc) {
			DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &pGraphics := 0)
			return CGdip.Graphics(pGraphics)
		}

		static FromBitmap(pBitmap) {
			DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", pBitmap, "Ptr*", &pGraphics := 0)
			return CGdip.Graphics(pGraphics)
		}

		DrawRectangle(pPen, x, y, w, h) {
			return DllCall("gdiplus\GdipDrawRectangle", "Ptr", this, "Ptr", pPen, "float", x, "float", y, "float", w, "float", h)
		}

		DrawRoundedRectangle(pPen, x, y, w, h, r) {
			this.SetClipRect(x - r, y - r, 2 * r, 2 * r, 4)
			this.SetClipRect(x + w - r, y - r, 2 * r, 2 * r, 4)
			this.SetClipRect(x - r, y + h - r, 2 * r, 2 * r, 4)
			this.SetClipRect(x + w - r, y + h - r, 2 * r, 2 * r, 4)
			E := this.DrawRectangle(pPen, x, y, w, h)
			this.ResetClip()
			this.SetClipRect(x - (2 * r), y + r, w + (4 * r), h - (2 * r), 4)
			this.SetClipRect(x + r, y - (2 * r), w - (2 * r), h + (4 * r), 4)
			this.DrawEllipse(pPen, x, y, 2 * r, 2 * r)
			this.DrawEllipse(pPen, x + w - (2 * r), y, 2 * r, 2 * r)
			this.DrawEllipse(pPen, x, y + h - (2 * r), 2 * r, 2 * r)
			this.DrawEllipse(pPen, x + w - (2 * r), y + h - (2 * r), 2 * r, 2 * r)
			this.ResetClip()
			return E
		}

		DrawEllipse(pPen, x, y, w, h) {
			return DllCall("gdiplus\GdipDrawEllipse", "Ptr", this, "Ptr", pPen, "float", x, "float", y, "float", w, "float", h)
		}

		DrawBezier(pPen, x1, y1, x2, y2, x3, y3, x4, y4) {
			return DllCall("gdiplus\GdipDrawBezier", "Ptr", this, "Ptr", pPen
				, "float", x1, "float", y1, "float", x2, "float", y2
				, "float", x3, "float", y3, "float", x4, "float", y4)
		}

		DrawArc(pPen, x, y, w, h, StartAngle, SweepAngle) {
			return DllCall("gdiplus\GdipDrawArc", "Ptr", this, "Ptr", pPen
				, "float", x, "float", y, "float", w, "float", h
				, "float", StartAngle, "float", SweepAngle)
		}

		DrawPie(pPen, x, y, w, h, StartAngle, SweepAngle) {
			return DllCall("gdiplus\GdipDrawPie", "Ptr", this, "Ptr", pPen, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
		}

		DrawLine(pPen, x1, y1, x2, y2) {
			return DllCall("gdiplus\GdipDrawLine"
				, "Ptr", this, "Ptr", pPen
				, "float", x1, "float", y1, "float", x2, "float", y2)
		}

		DrawLines(pPen, Points) {
			Points := StrSplit(Points, "|")
			PointF := Buffer(8 * Points.Length)
			Loop Points.Length
				Coord := StrSplit(Points[A_Index], ","), NumPut("float", Coord[1], "float", Coord[2], PointF, 8 * (A_Index - 1))
			return DllCall("gdiplus\GdipDrawLines", "Ptr", this, "Ptr", pPen, "Ptr", PointF, "int", Points.Length)
		}

		DrawImage(pBitmap, dx := "", dy := "", dw := "", dh := "", sx := "", sy := "", sw := "", sh := "", Matrix := 1) {
			ImageAttr := 0
			if !IsNumber(Matrix)
				ImageAttr := CGdip.SetImageAttributesColorMatrix(Matrix)
			else if (Matrix != 1)
				ImageAttr := CGdip.SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

			if (sx = "" && sy = "" && sw = "" && sh = "")
			{
				if (dx = "" && dy = "" && dw = "" && dh = "")
				{
					sx := dx := 0, sy := dy := 0
					sw := dw := CGdip.GetImageWidth(pBitmap)
					sh := dh := CGdip.GetImageHeight(pBitmap)
				} else
				{
					sx := sy := 0
					sw := CGdip.GetImageWidth(pBitmap)
					sh := CGdip.GetImageHeight(pBitmap)
				}
			}

			E := DllCall("gdiplus\GdipDrawImageRectRect", "Ptr", this, "Ptr", pBitmap
				, "float", dx, "float", dy, "float", dw, "float", dh
				, "float", sx, "float", sy, "float", sw, "float", sh
				, "int", 2, "Ptr", ImageAttr, "Ptr", 0, "Ptr", 0)
			if ImageAttr
				CGdip.DisposeImageAttributes(ImageAttr)
			return E
		}

		DrawString(sString, hFont, hFormat, pBrush, RectF) {
			return DllCall("gdiplus\GdipDrawString", "Ptr", this, "Str", sString, "int", -1
				, "Ptr", hFont, "Ptr", RectF, "Ptr", hFormat, "Ptr", pBrush)
		}

		MeasureString(sString, hFont, hFormat, RectF) {
			RC := Buffer(16, 0)
			DllCall("gdiplus\GdipMeasureString", "Ptr", this, "Ptr", StrPtr(sString), "int", -1
				, "Ptr", hFont, "Ptr", RectF, "Ptr", hFormat
				, "Ptr", RC, "Uint*", &Chars := 0, "Uint*", &Lines := 0)
			return RC.Ptr ? { x: NumGet(RC, 0, "float"), y: NumGet(RC, 4, "float"), w: NumGet(RC, 8, "float"), h: NumGet(RC, 12, "float"), chars: Chars, lines: Lines } : 0
		}

		FillRectangle(pBrush, x, y, w, h) {
			return DllCall("gdiplus\GdipFillRectangle"
				, "Ptr", this, "Ptr", pBrush
				, "float", x, "float", y, "float", w, "float", h)
		}

		FillRoundedRectangle(pBrush, x, y, w, h, r) {
			Region := this.GetClipRegion()
			this.SetClipRect(x - r, y - r, 2 * r, 2 * r, 4)
			this.SetClipRect(x + w - r, y - r, 2 * r, 2 * r, 4)
			this.SetClipRect(x - r, y + h - r, 2 * r, 2 * r, 4)
			this.SetClipRect(x + w - r, y + h - r, 2 * r, 2 * r, 4)
			E := this.FillRectangle(pBrush, x, y, w, h)
			this.SetClipRegion(Region, 0)
			this.SetClipRect(x - (2 * r), y + r, w + (4 * r), h - (2 * r), 4)
			this.SetClipRect(x + r, y - (2 * r), w - (2 * r), h + (4 * r), 4)
			this.FillEllipse(pBrush, x, y, 2 * r, 2 * r)
			this.FillEllipse(pBrush, x + w - (2 * r), y, 2 * r, 2 * r)
			this.FillEllipse(pBrush, x, y + h - (2 * r), 2 * r, 2 * r)
			this.FillEllipse(pBrush, x + w - (2 * r), y + h - (2 * r), 2 * r, 2 * r)
			this.SetClipRegion(Region, 0)
			CGdip.DeleteRegion(Region)
			return E
		}

		FillPolygon(pBrush, Points, FillMode := 0) {
			Points := StrSplit(Points, "|")
			PointF := Buffer(8 * Points.Length)
			Loop Points.Length
				Coord := StrSplit(Points[A_Index], ","), NumPut("float", Coord[1], "float", Coord[2], PointF, 8 * (A_Index - 1))
			return DllCall("gdiplus\GdipFillPolygon", "Ptr", this, "Ptr", pBrush, "Ptr", PointF, "int", Points.Length, "int", FillMode)
		}

		FillPie(pBrush, x, y, w, h, StartAngle, SweepAngle) {
			return DllCall("gdiplus\GdipFillPie", "Ptr", this, "Ptr", pBrush
				, "float", x, "float", y, "float", w, "float", h
				, "float", StartAngle, "float", SweepAngle)
		}

		FillEllipse(pBrush, x, y, w, h) {
			return DllCall("gdiplus\GdipFillEllipse", "Ptr", this, "Ptr", pBrush, "float", x, "float", y, "float", w, "float", h)
		}

		FillRegion(pBrush, Region) {
			return DllCall("gdiplus\GdipFillRegion", "Ptr", this, "Ptr", pBrush, "Ptr", Region)
		}

		SetClipRect(x, y, w, h, CombineMode := 0) {
			return DllCall("gdiplus\GdipSetClipRect", "Ptr", this, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
		}

		SetClipPath(pPath, CombineMode := 0) {
			return DllCall("gdiplus\GdipSetClipPath", "Ptr", this, "Ptr", pPath, "int", CombineMode)
		}

		ResetClip() {
			return DllCall("gdiplus\GdipResetClip", "Ptr", this)
		}

		GetClipRegion() {
			Region := CGdip.CreateRegion()
			DllCall("gdiplus\GdipGetClip", "Ptr", this, "UInt", Region)
			return Region
		}

		SetClipRegion(Region, CombineMode := 0) {
			return DllCall("gdiplus\GdipSetClipRegion", "Ptr", this, "Ptr", Region, "int", CombineMode)
		}

		; SystemDefault = 0
		; SingleBitPerPixelGridFit = 1
		; SingleBitPerPixel = 2
		; AntiAliasGridFit = 3
		; AntiAlias = 4
		SetTextRenderingHint(RenderingHint := 0) {
			return DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", this, "int", RenderingHint)
		}

		SetInterpolationMode(InterpolationMode := 0) {
			; Default = 0
			; LowQuality = 1
			; HighQuality = 2
			; Bilinear = 3
			; Bicubic = 4
			; NearestNeighbor = 5
			; HighQualityBilinear = 6
			; HighQualityBicubic = 7
			return DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", this, "int", InterpolationMode)
		}

		SetSmoothingMode(SmoothingMode := 0) {
			; Default = 0
			; HighSpeed = 1
			; HighQuality = 2
			; None = 3
			; AntiAlias = 4
			return DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", this, "int", SmoothingMode)
		}

		SetCompositingMode(CompositingMode := 0) {
			; CompositingModeSourceOver = 0 (blended)
			; CompositingModeSourceCopy = 1 (overwrite)
			return DllCall("gdiplus\GdipSetCompositingMode", "Ptr", this, "int", CompositingMode)
		}

		GetDC() {
			if this.hdc
				return this.hdc
			DllCall("gdiplus\GdipGetDC", "Ptr", this, "Ptr*", &hdc := 0), this.hdc := hdc
			return hdc
		}

		ReleaseDC() {
			DllCall("gdiplus\GdipReleaseDC", "Ptr", this, "Ptr", this.hdc), this.hdc := 0
		}

		RotateWorldTransform(Angle, MatrixOrder := 0) {
			return DllCall("gdiplus\GdipRotateWorldTransform", "Ptr", this, "float", Angle, "int", MatrixOrder)
		}

		ScaleWorldTransform(x, y, MatrixOrder := 0) {
			return DllCall("gdiplus\GdipScaleWorldTransform", "Ptr", this, "float", x, "float", y, "int", MatrixOrder)
		}

		TranslateWorldTransform(x, y, MatrixOrder := 0) {
			return DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", this, "float", x, "float", y, "int", MatrixOrder)
		}

		ResetWorldTransform() {
			return DllCall("gdiplus\GdipResetWorldTransform", "Ptr", this)
		}
	}

	class Bitmap
	{
		Ptr := 0, Dispose := 0

		__New(pBitmap, Dispose := 1) {
			if (!pBitmap)
				throw "invalid pBitmap"
			else
				this.Ptr := pBitmap, this.Dispose := Dispose
		}

		__Delete() {
			if (this.Ptr && this.Dispose && CGdip.pToken)
				DllCall("gdiplus\GdipDisposeImage", "Ptr", this)
		}

		static FromHWND(hwnd) {
			WinGetPos(, , &Width, &Height, hwnd)
			hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			PrintWindow(hwnd, hdc)
			DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", &pBitmap := 0)
			SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
			return CGdip.Bitmap(pBitmap)
		}

		static FromBase64(Base64) {
			If !(DllCall("crypt32\CryptStringToBinary", "Str", Base64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UInt*", &DecLen := 0, "Ptr", 0, "Ptr", 0))
				return -1
			Dec := Buffer(DecLen)
			If !(DllCall("crypt32\CryptStringToBinary", "Str", Base64, "UInt", 0, "UInt", 0x01, "Ptr", Dec, "UInt*", &DecLen, "Ptr", 0, "Ptr", 0))
				return -2
			If !(pStream := DllCall("shlwapi\SHCreateMemStream", "Ptr", Dec, "UInt", DecLen, "UPtr"))
				return -3
			DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "Ptr", pStream, "Ptr*", &pBitmap := 0)
			ObjRelease(pStream)
			return CGdip.Bitmap(pBitmap)
		}

		static FromFile(sFile, IconNumber := 1, IconSize := "") {
			SplitPath(sFile, , , &ext)
			if (ext ~= "i)^(exe|dll|icl)$")
			{
				Sizes := IconSize ? IconSize : 256 "|" 128 "|" 64 "|" 48 "|" 32 "|" 16
				BufSize := 16 + (2 * (A_PtrSize ? A_PtrSize : 4))

				buf := Buffer(BufSize, 0)
				Loop Parse Sizes, "|"
				{
					DllCall("PrivateExtractIcons", "Str", sFile, "int", IconNumber - 1, "int", A_LoopField, "int", A_LoopField, "Ptr*", &hIcon := 0, "Ptr*", 0, "Uint", 1, "Uint", 0)
					if !hIcon
						continue
					if !DllCall("GetIconInfo", "Ptr", hIcon, "Ptr", buf)
					{
						DestroyIcon(hIcon)
						continue
					}
					hbmMask := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4))
					hbmColor := NumGet(buf, 12 + ((A_PtrSize ? A_PtrSize : 4) - 4) + (A_PtrSize ? A_PtrSize : 4))
					if !(hbmColor && DllCall("GetObject", "Ptr", hbmColor, "int", BufSize, "Ptr", buf))
					{
						DestroyIcon(hIcon)
						continue
					}
					break
				}
				if !hIcon
					return -1

				Width := NumGet(buf, 4, "int"), Height := NumGet(buf, 8, "int")
				hbm := CreateDIBSection(Width, -Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
				if !DllCall("DrawIconEx", "Ptr", hdc, "int", 0, "int", 0, "Ptr", hIcon, "Uint", Width, "Uint", Height, "Uint", 0, "Ptr", 0, "Uint", 3)
				{
					DestroyIcon(hIcon)
					return -2
				}

				dib := Buffer(104)
				DllCall("GetObject", "Ptr", hbm, "int", A_PtrSize = 8 ? 104 : 84, "Ptr", dib)	; sizeof(DIBSECTION) = 76+2*(A_PtrSize=8?4:0)+2*A_PtrSize
				Stride := NumGet(dib, 12, "Int"), Bits := NumGet(dib, 20 + (A_PtrSize = 8 ? 4 : 0))	; padding
				DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", Stride, "int", 0x26200A, "Ptr", Bits, "Ptr*", &pBitmapOld := 0)
				DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", 0x26200A, "Ptr", 0, "Ptr*", &pBitmap := 0)
				DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", pBitmap, "Ptr*", &G := 0)
				G := CGdip.Graphics.FromBitmap(pBitmap), G.DrawImage(pBitmapOld, 0, 0, Width, Height, 0, 0, Width, Height)
				SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
				DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmapOld)
				DestroyIcon(hIcon)
			} else
				DllCall("gdiplus\GdipCreateBitmapFromFile", "Ptr", StrPtr(sFile), "Ptr*", &pBitmap := 0)
			return CGdip.Bitmap(pBitmap)
		}

		static FromScreen(Screen := 0, Raster := "") {
			if (Screen = 0) {
				x := SySGet(76)
				y := SySGet(77)
				w := SySGet(78)
				h := SySGet(79)
			} else if (SubStr(Screen, 1, 5) = "hwnd:") {
				Screen := SubStr(Screen, 6)
				if !WinExist("ahk_id " Screen)
					return -2
				WinGetPos(, , &w, &h, "ahk_id" Screen)
				x := y := 0
				hhdc := GetDCEx(Screen, 3)
			} else if (Screen is Integer) {
				MonitorGet(Screen, &x, &y, &w, &h)
				w -= x, h -= y
			} else {
				S := StrSplit(Screen, "|")
				x := S[1], y := S[2], w := S[3], h := S[4]
			}

			if (x = "") || (y = "") || (w = "") || (h = "")
				return -1

			chdc := CreateCompatibleDC(), hbm := CreateDIBSection(w, h, chdc), obm := SelectObject(chdc, hbm), hhdc := hhdc ?? GetDC()
			BitBlt(chdc, 0, 0, w, h, hhdc, x, y, Raster)
			ReleaseDC(hhdc)
			DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", &pBitmap := 0)
			SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(hhdc), DeleteDC(chdc)
			return CGdip.Bitmap(pBitmap)
		}

		static FromHBITMAP(hBitmap, Palette := 0) {
			DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", Palette, "Ptr*", &pBitmap := 0)
			return CGdip.Bitmap(pBitmap)
		}

		static FromHICON(hIcon) {
			DllCall("gdiplus\GdipCreateBitmapFromHICON", "Ptr", hIcon, "Ptr*", &pBitmap := 0)
			return CGdip.Bitmap(pBitmap)
		}

		static Create(Width, Height, Format := 0x26200A) {
			DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, "Ptr", 0, "Ptr*", &pBitmap := 0)
			return CGdip.Bitmap(pBitmap)
		}

		static FromBRA(BRAFromMemIn, File, Alternate := 0) {
			pBitmap := 0, pStream := 0
			If !(BRAFromMemIn)
				Return -1
			Headers := StrSplit(StrGet(BRAFromMemIn, 256, "CP0"), "`n")
			Header := StrSplit(Headers[1], "|")
			HeaderLength := Header.Length
			If (HeaderLength != 4) || (Header[2] != "BRA!")
				Return -2
			_Info := StrSplit(Headers[2], "|")
			_InfoLength := _Info.Length
			If (_InfoLength != 3)
				Return -3
			OffsetTOC := StrPut(Headers[1], "CP0") + StrPut(Headers[2], "CP0")	;  + 2
			OffsetData := _Info[2]
			SearchIndex := Alternate ? 1 : 2
			TOC := StrGet(BRAFromMemIn + OffsetTOC, OffsetData - OffsetTOC - 1, "CP0")
			RX1 := "mi`n)^"
			Offset := Size := 0
			If RegExMatch(TOC, RX1 . (Alternate ? File "\|.+?" : "\d+\|" . File) . "\|(\d+)\|(\d+)$", &FileInfo) {
				Offset := OffsetData + FileInfo[1]
				Size := FileInfo[2]
			}
			If (Size = 0)
				Return -4
			hData := DllCall("GlobalAlloc", "UInt", 2, "UInt", Size, "UPtr")
			pData := DllCall("GlobalLock", "Ptr", hData, "UPtr")
			DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", BRAFromMemIn + Offset, "Ptr", Size)
			DllCall("GlobalUnlock", "Ptr", hData)
			DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", 1, "Ptr*", &pStream)
			DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "Ptr*", &pBitmap)
			ObjRelease(pStream)
			Return CGdip.Bitmap(pBitmap)
		}

		static FromClipboard() {
			if !DllCall("OpenClipboard", "Ptr", 0)
				return -1
			if !DllCall("IsClipboardFormatAvailable", "Uint", 8) {
				DllCall("CloseClipboard")
				return -2
			}
			pBitmap := 0
			if (hBitmap := DllCall("GetClipboardData", "Uint", 2, "Ptr"))
				DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap)
				, DeleteObject(hBitmap)
			DllCall("CloseClipboard")
			return CGdip.Bitmap(pBitmap)
		}

		SetClipboard() {
			off1 := A_PtrSize = 8 ? 52 : 44, off2 := A_PtrSize = 8 ? 32 : 24
			DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", this, "Ptr*", &hBitmap := 0, "int", 0xffffffff)
			DllCall("GetObject", "Ptr", hBitmap, "int", oi := Buffer(A_PtrSize = 8 ? 104 : 84, 0), "Ptr", oi)
			hdib := DllCall("GlobalAlloc", "Uint", 2, "Ptr", 40 + NumGet(oi, off1, "UInt"), "Ptr")
			pdib := DllCall("GlobalLock", "Ptr", hdib, "Ptr")
			DllCall("RtlMoveMemory", "Ptr", pdib, "Ptr", oi.Ptr + off2, "Ptr", 40)
			DllCall("RtlMoveMemory", "Ptr", pdib + 40, "Ptr", NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), "Ptr"), "Ptr", NumGet(oi, off1, "UInt"))
			DllCall("GlobalUnlock", "Ptr", hdib)
			DllCall("DeleteObject", "Ptr", hBitmap)
			DllCall("OpenClipboard", "Ptr", 0)
			DllCall("EmptyClipboard")
			DllCall("SetClipboardData", "Uint", 8, "Ptr", hdib)
			DllCall("CloseClipboard")
		}

		CreateHBITMAP(Background := 0xffffffff) {
			DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", this, "Ptr*", &hbm := 0, "int", Background)
			return hbm
		}

		CreateHICON() {
			DllCall("gdiplus\GdipCreateHICONFromBitmap", "Ptr", this, "Ptr*", &hIcon := 0)
			return hIcon
		}

		CloneArea(x, y, w, h, Format := 0x26200A) {
			DllCall("gdiplus\GdipCloneBitmapArea"
				, "float", x, "float", y, "float", w, "float", h
				, "int", Format, "Ptr", this, "Ptr*", &pBitmapDest := 0)
			return pBitmapDest
		}

		RotateFlip(RotateFlipType := 1) {
			return DllCall("gdiplus\GdipImageRotateFlip", "Ptr", this, "int", RotateFlipType)
		}

		Save(sOutput, Quality := 75) {
			SplitPath(sOutput, , , &Extension, &Name)
			if !(Extension ~= "i)^(BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
				return -1
			Extension := "." Extension

			DllCall("gdiplus\GdipGetImageEncodersSize", "Uint*", &nCount := 0, "Uint*", &nSize := 0)
			ci := Buffer(nSize)
			DllCall("gdiplus\GdipGetImageEncoders", "Uint", nCount, "Uint", nSize, "Ptr", ci)
			if !(nCount && nSize)
				return -2

			Loop nCount
			{
				sString := StrGet(NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize, "Ptr"), "UTF-16")
				if !InStr(sString, "*" Extension)
					continue

				pCodec := ci.Ptr + idx
				break
			}

			if !pCodec
				return -3

			p := 0
			if (Quality != 75)
			{
				Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality
				if (Extension ~= "i)^(\.JPG|\.JPEG|\.JPE|\.JFIF)$")
				{
					DllCall("gdiplus\GdipGetEncoderParameterListSize", "Ptr", this, "Ptr", pCodec, "Uint*", &nSize := 0)
					EncoderParameters := Buffer(nSize, 0)
					DllCall("gdiplus\GdipGetEncoderParameterList", "Ptr", this, "Ptr", pCodec, "Uint", nSize, "Ptr", EncoderParameters)
					Loop NumGet(EncoderParameters, "UInt")	;%
					{
						elem := (24 + A_PtrSize) * (A_Index - 1) + A_PtrSize
						if (NumGet(EncoderParameters, elem + 16, "UInt") = 1) && (NumGet(EncoderParameters, elem + 20, "UInt") = 6)
						{
							ep := EncoderParameters.ptr + elem - A_PtrSize
							NumPut("uptr", 1, ep)
							NumPut("uint", 4, ep, 20 + A_PtrSize)
							NumPut("uint", quality, NumGet(ep + 24 + A_PtrSize, "uptr"))
							break
						}
					}
				}
			}

			if Name
				E := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", this, "Ptr", StrPtr(sOutput), "Ptr", pCodec, "Uint", p)
			else {
				DllCall("ole32\CreateStreamOnHGlobal", "Ptr", 0, "Int", 1, "Ptr*", &pStream := 0)
				DllCall("gdiplus\GdipSaveImageToStream", "Ptr", this, "Ptr", pStream, "Ptr", pCodec, "UInt", p)
				return pStream
			}
			return E ? -5 : 0
		}

		GetPixel(x, y) {
			DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", this, "int", x, "int", y, "Uint*", &ARGB := 0)
			return ARGB
		}

		SetPixel(x, y, ARGB) {
			return DllCall("gdiplus\GdipBitmapSetPixel", "Ptr", this, "int", x, "int", y, "int", ARGB)
		}

		GetWidth() {
			return CGdip.GetImageWidth(this)
		}

		GetHeight() {
			return CGdip.GetImageHeight(this)
		}

		GetDimensions(&Width, &Height) {
			CGdip.GetImageDimensions(this, &Width, &Height)
		}

		GetPixelFormat() {
			DllCall("gdiplus\GdipGetImagePixelFormat", "Ptr", this, "int*", &Format := 0)
			return Format
		}

		LockBits(x, y, w, h, &Stride, &Scan0, &BitmapData, LockMode := 3, PixelFormat := 0x26200a) {
			CreateRect(&_Rect, x, y, w, h), BitmapData := Buffer(16 + 2 * A_PtrSize, 0)
			_E := DllCall("Gdiplus\GdipBitmapLockBits", "Ptr", this, "Ptr", _Rect, "Uint", LockMode, "int", PixelFormat, "Ptr", BitmapData)
			Stride := NumGet(BitmapData, 8, "Int")
			Scan0 := NumGet(BitmapData, 16, "Ptr")
			return _E
		}

		UnlockBits(BitmapData) {
			return DllCall("Gdiplus\GdipBitmapUnlockBits", "Ptr", this, "Ptr", BitmapData)
		}

		SetLockBitPixel(ARGB, Scan0, x, y, Stride) {
			NumPut("UInt", ARGB, Scan0 + 0, (x * 4) + (y * Stride))
		}

		GetLockBitPixel(Scan0, x, y, Stride) {
			return NumGet(Scan0 + 0, (x * 4) + (y * Stride), "UInt")
		}

		Pixelate(pBitmapOut, BlockSize) {
			static PixelateBitmap := ""

			if (PixelateBitmap = "") {
				if A_PtrSize != 8	; x86 machine code
					MCode_PixelateBitmap := "
				(LTrim Join
				558BEC83EC3C8B4514538B5D1C99F7FB56578BC88955EC894DD885C90F8E830200008B451099F7FB8365DC008365E000894DC88955F08945E833FF897DD4
				397DE80F8E160100008BCB0FAFCB894DCC33C08945F88945FC89451C8945143BD87E608B45088D50028BC82BCA8BF02BF2418945F48B45E02955F4894DC4
				8D0CB80FAFCB03CA895DD08BD1895DE40FB64416030145140FB60201451C8B45C40FB604100145FC8B45F40FB604020145F883C204FF4DE475D6034D18FF
				4DD075C98B4DCC8B451499F7F98945148B451C99F7F989451C8B45FC99F7F98945FC8B45F899F7F98945F885DB7E648B450C8D50028BC82BCA83C103894D
				C48BC82BCA41894DF48B4DD48945E48B45E02955E48D0C880FAFCB03CA895DD08BD18BF38A45148B7DC48804178A451C8B7DF488028A45FC8804178A45F8
				8B7DE488043A83C2044E75DA034D18FF4DD075CE8B4DCC8B7DD447897DD43B7DE80F8CF2FEFFFF837DF0000F842C01000033C08945F88945FC89451C8945
				148945E43BD87E65837DF0007E578B4DDC034DE48B75E80FAF4D180FAFF38B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945CC0F
				B6440E030145140FB60101451C0FB6440F010145FC8B45F40FB604010145F883C104FF4DCC75D8FF45E4395DE47C9B8B4DF00FAFCB85C9740B8B451499F7
				F9894514EB048365140033F63BCE740B8B451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB
				038975F88975E43BDE7E5A837DF0007E4C8B4DDC034DE48B75E80FAF4D180FAFF38B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955CC8A55
				1488540E038A551C88118A55FC88540F018A55F888140183C104FF4DCC75DFFF45E4395DE47CA68B45180145E0015DDCFF4DC80F8594FDFFFF8B451099F7
				FB8955F08945E885C00F8E450100008B45EC0FAFC38365DC008945D48B45E88945CC33C08945F88945FC89451C8945148945103945EC7E6085DB7E518B4D
				D88B45080FAFCB034D108D50020FAF4D18034DDC8BF08BF88945F403CA2BF22BFA2955F4895DC80FB6440E030145140FB60101451C0FB6440F010145FC8B
				45F40FB604080145F883C104FF4DC875D8FF45108B45103B45EC7CA08B4DD485C9740B8B451499F7F9894514EB048365140033F63BCE740B8B451C99F7F9
				89451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975103975EC7E5585DB7E468B4DD88B450C
				0FAFCB034D108D50020FAF4D18034DDC8BF08BF803CA2BF22BFA2BC2895DC88A551488540E038A551C88118A55FC88540F018A55F888140183C104FF4DC8
				75DFFF45108B45103B45EC7CAB8BC3C1E0020145DCFF4DCC0F85CEFEFFFF8B4DEC33C08945F88945FC89451C8945148945103BC87E6C3945F07E5C8B4DD8
				8B75E80FAFCB034D100FAFF30FAF4D188B45088D500203CA8D0CB18BF08BF88945F48B45F02BF22BFA2955F48945C80FB6440E030145140FB60101451C0F
				B6440F010145FC8B45F40FB604010145F883C104FF4DC875D833C0FF45108B4DEC394D107C940FAF4DF03BC874068B451499F7F933F68945143BCE740B8B
				451C99F7F989451CEB0389751C3BCE740B8B45FC99F7F98945FCEB038975FC3BCE740B8B45F899F7F98945F8EB038975F88975083975EC7E63EB0233F639
				75F07E4F8B4DD88B75E80FAFCB034D080FAFF30FAF4D188B450C8D500203CA8D0CB18BF08BF82BF22BFA2BC28B55F08955108A551488540E038A551C8811
				8A55FC88540F018A55F888140883C104FF4D1075DFFF45088B45083B45EC7C9F5F5E33C05BC9C21800
				)"
				else	; x64 machine code
					MCode_PixelateBitmap := "
				(LTrim Join
				4489442418488954241048894C24085355565741544155415641574883EC28418BC1448B8C24980000004C8BDA99488BD941F7F9448BD0448BFA8954240C
				448994248800000085C00F8E9D020000418BC04533E4458BF299448924244C8954241041F7F933C9898C24980000008BEA89542404448BE889442408EB05
				4C8B5C24784585ED0F8E1A010000458BF1418BFD48897C2418450FAFF14533D233F633ED4533E44533ED4585C97E5B4C63BC2490000000418D040A410FAF
				C148984C8D441802498BD9498BD04D8BD90FB642010FB64AFF4403E80FB60203E90FB64AFE4883C2044403E003F149FFCB75DE4D03C748FFCB75D0488B7C
				24188B8C24980000004C8B5C2478418BC59941F7FE448BE8418BC49941F7FE448BE08BC59941F7FE8BE88BC69941F7FE8BF04585C97E4048639C24900000
				004103CA4D8BC1410FAFC94863C94A8D541902488BCA498BC144886901448821408869FF408871FE4883C10448FFC875E84803D349FFC875DA8B8C249800
				0000488B5C24704C8B5C24784183C20448FFCF48897C24180F850AFFFFFF8B6C2404448B2424448B6C24084C8B74241085ED0F840A01000033FF33DB4533
				DB4533D24533C04585C97E53488B74247085ED7E42438D0C04418BC50FAF8C2490000000410FAFC18D04814863C8488D5431028BCD0FB642014403D00FB6
				024883C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC17CB28BCD410FAFC985C9740A418BC299F7F98BF0EB0233F685C9740B418BC3
				99F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585C97E4D4C8B74247885ED7E3841
				8D0C14418BC50FAF8C2490000000410FAFC18D04814863C84A8D4431028BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2413BD17CBD
				4C8B7424108B8C2498000000038C2490000000488B5C24704503E149FFCE44892424898C24980000004C897424100F859EFDFFFF448B7C240C448B842480
				000000418BC09941F7F98BE8448BEA89942498000000896C240C85C00F8E3B010000448BAC2488000000418BCF448BF5410FAFC9898C248000000033FF33
				ED33F64533DB4533D24533C04585FF7E524585C97E40418BC5410FAFC14103C00FAF84249000000003C74898488D541802498BD90FB642014403D00FB602
				4883C2044403D80FB642FB03F00FB642FA03E848FFCB75DE488B5C247041FFC0453BC77CAE85C9740B418BC299F7F9448BE0EB034533E485C9740A418BC3
				99F7F98BD8EB0233DB85C9740A8BC699F7F9448BD8EB034533DB85C9740A8BC599F7F9448BD0EB034533D24533C04585FF7E4E488B4C24784585C97E3541
				8BC5410FAFC14103C00FAF84249000000003C74898488D540802498BC144886201881A44885AFF448852FE4883C20448FFC875E941FFC0453BC77CBE8B8C
				2480000000488B5C2470418BC1C1E00203F849FFCE0F85ECFEFFFF448BAC24980000008B6C240C448BA4248800000033FF33DB4533DB4533D24533C04585
				FF7E5A488B7424704585ED7E48418BCC8BC5410FAFC94103C80FAF8C2490000000410FAFC18D04814863C8488D543102418BCD0FB642014403D00FB60248
				83C2044403D80FB642FB03D80FB642FA03F848FFC975DE41FFC0453BC77CAB418BCF410FAFCD85C9740A418BC299F7F98BF0EB0233F685C9740B418BC399
				F7F9448BD8EB034533DB85C9740A8BC399F7F9448BD0EB034533D285C9740A8BC799F7F9448BC0EB034533C033D24585FF7E4E4585ED7E42418BCC8BC541
				0FAFC903CA0FAF8C2490000000410FAFC18D04814863C8488B442478488D440102418BCD40887001448818448850FF448840FE4883C00448FFC975E8FFC2
				413BD77CB233C04883C428415F415E415D415C5F5E5D5BC3
				)"
				PixelateBitmap := Buffer(nCount := StrLen(MCode_PixelateBitmap) // 2)
				if (!DllCall("crypt32\CryptStringToBinary", "Str", MCode_PixelateBitmap, "Uint", 0, "Uint", 4, "Ptr", PixelateBitmap, "Uint*", &nCount, "Ptr", 0, "Ptr", 0)) {
					Loop nCount
						NumPut("UChar", ("0x" SubStr(MCode_PixelateBitmap, (2 * A_Index) - 1, 2)) + 0, PixelateBitmap, A_Index - 1)
				}
				DllCall("VirtualProtect", "Ptr", PixelateBitmap, "UInt", nCount, "Uint", 0x40, "Uint*", 0)
			}

			this.GetDimensions(&Width := 0, &Height := 0), cBO := CGdip.Bitmap(pBitmapOut, 0)

			if (Width != cBO.GetWidth() || Height != cBO.GetHeight())
				return -1
			if (BlockSize > Width || BlockSize > Height)
				return -2

			E1 := this.LockBits(0, 0, Width, Height, Stride1 := 0, Scan01 := 0, BitmapData1 := "")
			E2 := cBO.LockBits(0, 0, Width, Height, Stride2 := 0, Scan02 := 0, BitmapData2 := "")
			if (E1 || E2)
				return -3

			; E:=- unused exit code
			DllCall(PixelateBitmap, "Ptr", Scan01, "Ptr", Scan02, "int", Width, "int", Height, "int", Stride1, "int", BlockSize)

			this.UnlockBits(BitmapData1), cBO.UnlockBits(BitmapData2)
			return 0
		}
	}

	class StringFormat
	{
		Ptr := 0

		__New(Format := "", LineAlign := 0, Align := 0) {
			; StringFormatFlagsDirectionRightToLeft    = 0x00000001
			; StringFormatFlagsDirectionVertical       = 0x00000002
			; StringFormatFlagsNoFitBlackBox           = 0x00000004
			; StringFormatFlagsDisplayFormatControl    = 0x00000020
			; StringFormatFlagsNoFontFallback          = 0x00000400
			; StringFormatFlagsMeasureTrailingSpaces   = 0x00000800
			; StringFormatFlagsNoWrap                  = 0x00001000
			; StringFormatFlagsLineLimit               = 0x00002000
			; StringFormatFlagsNoClip                  = 0x00004000
			if (Format = "")
				DllCall("gdiplus\GdipStringFormatGetGenericDefault", "Ptr*", &hFormat := 0)
			else DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", 0, "Ptr*", &hFormat := 0)
			if (Align) {
				; Near = 0  Center = 1  Far = 2
				DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", hFormat, "int", Align)
			}
			if (LineAlign) {
				; Near = 0  Center = 1  Far = 2
				DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", hFormat, "int", LineAlign)
			}
			this.Ptr := hFormat
			if !hFormat
				throw "Create StringFormat Failed"
		}

		__Delete() {
			if (this.Ptr && CGdip.pToken)
				DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", this)
		}
	}

	class Font
	{
		static FontFamilys := Map(), FontFamilys.CaseSense := "Off"
		Ptr := 0, prop := "", font := ""

		__New(font, size, style := 0) {
			; Regular = 0
			; Bold = 1
			; Italic = 2
			; BoldItalic = 3
			; Underline = 4
			; Strikeout = 8
			FontFamilys := CGdip.Font.FontFamilys
			if !FontFamilys.Has(font) {
				DllCall("gdiplus\GdipCreateFontFamilyFromName", "Ptr", StrPtr(Font), "Uint", 0, "Ptr*", &hFamily := 0)
				if (!hFamily)
					throw "Create Font Family Failed"
				FontFamilys[font] := { Ptr: hFamily, Fonts: Map() }
			} else hFamily := FontFamilys[font].Ptr
			prop := size " " style
			if FontFamilys[font].Fonts.Has(prop)
				this.Ptr := FontFamilys[font].Fonts[prop].Ptr, FontFamilys[font].Fonts[prop].RefCount++
			else {
				DllCall("gdiplus\GdipCreateFont", "Ptr", hFamily, "float", Size, "int", Style, "int", 0, "Ptr*", &hFont := 0)
				if (!hFont) {
					if (!FontFamilys[font].Fonts.Count)
						DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", hFamily), FontFamilys.Delete(font)
					throw "Create Font Failed"
				}
				FontFamilys[font].Fonts[prop] := { Ptr: (this.Ptr := hFont), RefCount: 1 }
			}
			this.prop := prop, this.font := font
		}

		__Delete() {
			FontFamilys := CGdip.Font.FontFamilys
			if (!CGdip.pToken)
				return FontFamilys.Clear()
			if (!this.Ptr || (--FontFamilys[this.font].Fonts[this.prop].RefCount))
				return
			FontFamilys[this.font].Fonts.Delete(this.prop)
			DllCall("gdiplus\GdipDeleteFont", "Ptr", this)
			if (!FontFamilys[this.font].Fonts.Count)
				DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", FontFamilys[this.font])
				, FontFamilys.Delete(this.font)
		}
	}

	class Pen
	{
		static Pens := Map(), Pens.CaseSense := "Off"
		Ptr := 0, prop := ""

		__New(pPen, prop := "") {
			if (!pPen)
				throw "invalid pPen"
			this.Ptr := pPen
			if (this.prop := prop) {
				Pens := CGdip.Pen.Pens
				if (!Pens.Has(prop))
					Pens[prop] := { Ptr: pPen, RefCount: 1 }
				else Pens[prop].RefCount++
			}
		}

		__Delete() {
			Pens := CGdip.Pen.Pens
			if (!CGdip.pToken)
				return Pens.Clear()
			if (!this.Ptr)
				return
			if (this.prop && Pens.Has(this.prop)) {
				if (--Pens[this.prop].RefCount)
					return
				Pens.Delete(this.prop)
			}
			DllCall("gdiplus\GdipDeletePen", "Ptr", this)
		}

		static Create(ARGB, w) {
			prop := Format("{:x}|{:.1f}", ARGB, w), Pens := CGdip.Pen.Pens
			if Pens.Has(prop)
				return CGdip.Pen(Pens[prop].Ptr, prop)
			DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, "Ptr*", &pPen := 0)
			return CGdip.Pen(pPen, prop)
		}

		static FromBrush(pBrush, w) {
			DllCall("gdiplus\GdipCreatePen2", "Ptr", pBrush, "float", w, "int", 2, "Ptr*", &pPen := 0)
			return CGdip.Pen(pPen)
		}
	}

	class Brush
	{
		static SolidBrushs := Map(), SolidBrushs.CaseSense := "Off"
		Ptr := 0, prop := ""

		__New(pBrush, prop := "") {
			if (!pBrush)
				throw "invalid pBrush"
			this.Ptr := pBrush
			if (this.prop := prop) {
				SolidBrushs := CGdip.Brush.SolidBrushs
				if (!SolidBrushs.Has(prop))
					SolidBrushs[prop] := { Ptr: pBrush, RefCount: 1 }
				else SolidBrushs[prop].RefCount++
			}
		}

		__Delete() {
			SolidBrushs := CGdip.Brush.SolidBrushs
			if (!CGdip.pToken)
				return SolidBrushs.Clear()
			if (!this.Ptr)
				return
			if (this.prop && SolidBrushs.Has(this.prop)) {
				if (--SolidBrushs[this.prop].RefCount)
					return
				SolidBrushs.Delete(this.prop)
			}
			DllCall("gdiplus\GdipDeleteBrush", "Ptr", this)
		}

		static SolidFill(ARGB := 0xff000000) {
			if (Type(ARGB) = "String" && ARGB ~= "i)^[a-f\d]+$")
				ARGB := Integer("0x" ARGB)
			prop := Format("{:x}", ARGB), SolidBrushs := CGdip.Brush.SolidBrushs
			if SolidBrushs.Has(prop)
				return CGdip.Brush(SolidBrushs[prop].Ptr, prop)
			DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, "Ptr*", &pBrush := 0)
			return CGdip.Brush(pBrush, prop)
		}

		static HatchBrush(ARGBfront, ARGBback, HatchStyle := 0) {
			DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, "Ptr*", &pBrush := 0)
			return CGdip.Brush(pBrush)
		}

		static TextureBrush(pBitmap, WrapMode := 1, x := 0, y := 0, w := "", h := "") {
			pBrush := 0
			if !(w && h)
				DllCall("gdiplus\GdipCreateTexture", "Ptr", pBitmap, "int", WrapMode, "Ptr*", &pBrush)
			else
				DllCall("gdiplus\GdipCreateTexture2", "Ptr", pBitmap, "int", WrapMode, "float", x, "float", y, "float", w, "float", h, "Ptr*", &pBrush)
			return CGdip.Brush(pBrush)
		}

		static LineBrush(x1, y1, x2, y2, ARGB1, ARGB2, WrapMode := 1) {
			; WrapModeTile = 0
			; WrapModeTileFlipX = 1
			; WrapModeTileFlipY = 2
			; WrapModeTileFlipXY = 3
			; WrapModeClamp = 4
			CreatePointF(&PointF1, x1, y1), CreatePointF(&PointF2, x2, y2)
			DllCall("gdiplus\GdipCreateLineBrush", "Ptr", PointF1, "Ptr", PointF2, "Uint", ARGB1, "Uint", ARGB2, "int", WrapMode, "Ptr*", &LGpBrush := 0)
			return CGdip.Brush(LGpBrush)
		}

		static LineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode := 1, WrapMode := 1) {
			; LinearGradientModeHorizontal = 0
			; LinearGradientModeVertical = 1
			; LinearGradientModeForwardDiagonal = 2
			; LinearGradientModeBackwardDiagonal = 3
			CreateRectF(&RectF, x, y, w, h)
			DllCall("gdiplus\GdipCreateLineBrushFromRect", "Ptr", RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "Ptr*", &LGpBrush := 0)
			return CGdip.Brush(LGpBrush)
		}

		Clone() {
			DllCall("gdiplus\GdipCloneBrush", "Ptr", this, "Ptr*", &pBrushClone := 0)
			return CGdip.Brush(pBrushClone)
		}
	}

	class Matrix
	{
		Ptr := 0

		__New(params*) {
			if (params.Length = 6)
				DllCall("gdiplus\GdipCreateMatrix2", "float", params[1], "float", params[2], "float", params[3]
					, "float", params[4], "float", params[5], "float", params[6], "Ptr*", &Matrix := 0)
			else
				DllCall("gdiplus\GdipCreateMatrix", "Ptr*", &Matrix := 0)
			if Matrix
				this.Ptr := Matrix
			else
				throw "Create Matrix Failed"
		}

		__Delete() {
			if (this.Ptr && CGdip.pToken)
				DllCall("gdiplus\GdipDeleteMatrix", "Ptr", this)
		}
	}
}

CreateCompatibleBitmap(hdc, w, h) {
	return DllCall("gdi32\CreateCompatibleBitmap", "Ptr", hdc, "int", w, "int", h)
}

CreateDIBSection(w, h, hdc := "", bpp := 32, &ppvBits := 0) {
	hdc2 := hdc ? hdc : GetDC()
	bi := Buffer(40, 0)

	NumPut("Uint", 40, "Uint", Integer(w), "Uint", Integer(h), "ushort", 1, "ushort", bpp, "uInt", 0, bi, 0)
	hbm := DllCall("CreateDIBSection", "Ptr", hdc2, "Ptr", bi, "Uint", 0, "Ptr*", &ppvBits, "Ptr", 0, "Uint", 0, "Ptr")
	if !hdc
		ReleaseDC(hdc2)
	return hbm
}

PrintWindow(hwnd, hdc, Flags := 0) {
	return DllCall("PrintWindow", "Ptr", hwnd, "Ptr", hdc, "Uint", Flags)
}

PaintDesktop(hdc) {
	return DllCall("PaintDesktop", "Ptr", hdc)
}

DestroyIcon(hIcon) {
	return DllCall("DestroyIcon", "Ptr", hIcon)
}

CreateCompatibleDC(hdc := 0) {
	return DllCall("CreateCompatibleDC", "Ptr", hdc, "ptr")
}

SelectObject(hdc, hgdiobj) {
	return DllCall("SelectObject", "Ptr", hdc, "Ptr", hgdiobj, "ptr")
}

DeleteObject(hObject) {
	return DllCall("DeleteObject", "Ptr", hObject)
}

GetDC(hwnd := 0) {
	return DllCall("GetDC", "Ptr", hwnd, "ptr")
}

GetDCEx(hwnd, flags := 0, hrgnClip := 0) {
	return DllCall("GetDCEx", "Ptr", hwnd, "Ptr", hrgnClip, "int", flags, "ptr")
}

ReleaseDC(hdc, hwnd := 0) {
	return DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hdc)
}

DeleteDC(hdc) {
	return DllCall("DeleteDC", "Ptr", hdc)
}

CreateRectF(&RectF, x, y, w, h) {
	RectF := Buffer(16)
	NumPut("float", x, "float", y, "float", w, "float", h, RectF, 0)
}

CreateRect(&Rect, x, y, w, h) {
	Rect := Buffer(16)
	NumPut("Uint", x, "Uint", y, "Uint", w, "Uint", h, Rect, 0)
}

CreateSizeF(&SizeF, w, h) {
	SizeF := Buffer(8)
	NumPut("float", w, "float", h, SizeF, 0)
}

CreatePointF(&PointF, x, y) {
	PointF := Buffer(8)
	NumPut("float", x, "float", y, PointF, 0)
}

SetSysColorToControl(hwnd, SysColor := 15) {
	WinGetPos(, , &w, &h, Integer(hwnd))
	bc := DllCall("GetSysColor", "Int", SysColor, "UInt")
	BrushClear := CGdip.Brush.SolidFill(0xff000000 | (bc >> 16 | bc & 0xff00 | (bc & 0xff) << 16))
	Bitmap := CGdip.Bitmap.Create(w, h), G := CGdip.Graphics.FromBitmap(Bitmap)
	G.FillRectangle(BrushClear, 0, 0, w, h)
	hBitmap := Bitmap.CreateHBITMAP()
	SetImage(hwnd, hBitmap)
	DeleteObject(hBitmap)
	return 0
}

SetImage(hwnd, hBitmap) {
	E := SendMessage(0x172, 0x0, hBitmap, , Integer(hwnd))
	DeleteObject(E)
	return E
}

SetStretchBltMode(hdc, iStretchMode := 4) {
	; STRETCH_ANDSCANS 		= 0x01
	; STRETCH_ORSCANS 		= 0x02
	; STRETCH_DELETESCANS 	= 0x03
	; STRETCH_HALFTONE 		= 0x04
	return DllCall("gdi32\SetStretchBltMode", "Ptr", hdc, "int", iStretchMode)
}

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster := "") {
	return DllCall("gdi32\StretchBlt", "Ptr", ddc, "int", dx, "int", dy, "int", dw, "int", dh
		, "Ptr", sdc, "int", sx, "int", sy, "int", sw, "int", sh, "Uint", Raster ? Raster : 0x00CC0020)
}

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster := "") {
	; BLACKNESS				= 0x00000042
	; NOTSRCERASE			= 0x001100A6
	; NOTSRCCOPY			= 0x00330008
	; SRCERASE				= 0x00440328
	; DSTINVERT				= 0x00550009
	; PATINVERT				= 0x005A0049
	; SRCINVERT				= 0x00660046
	; SRCAND				= 0x008800C6
	; MERGEPAINT			= 0x00BB0226
	; MERGECOPY				= 0x00C000CA
	; SRCCOPY				= 0x00CC0020
	; SRCPAINT				= 0x00EE0086
	; PATCOPY				= 0x00F00021
	; PATPAINT				= 0x00FB0A09
	; WHITENESS				= 0x00FF0062
	; CAPTUREBLT			= 0x40000000
	; NOMIRRORBITMAP		= 0x80000000
	return DllCall("gdi32\BitBlt", "Ptr", dDC, "int", dx, "int", dy, "int", dw, "int", dh
		, "Ptr", sDC, "int", sx, "int", sy, "Uint", Raster ? Raster : 0x00CC0020)
}

UpdateLayeredWindow(hwnd, hdc, x := "", y := "", w := "", h := "", Alpha := 255) {
	if (x != "" && y != "")
		pt := Buffer(8), NumPut("UInt", Integer(x), "UInt", Integer(y), pt, 0)

	if (w = "" || h = "")
		WinGetPos(, , &w, &h, Integer(hwnd))

	return DllCall("UpdateLayeredWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", ((x = "") && (y = "")) ? 0 : pt
			, "int64*", Integer(w) | Integer(h) << 32, "Ptr", hdc, "int64*", 0, "Uint", 0, "UInt*", Alpha << 16 | 1 << 24, "Uint", 2)
}

MDMF_FromPoint(X := "", Y := "") {
	If (X = "" || Y = "") {
		PT := Buffer(8, 0)
		DllCall("User32.dll\GetCursorPos", "Ptr", PT)
		X := X = "" ? NumGet(PT, 0, "Int") : X
		Y := Y = "" ? NumGet(PT, 4, "Int") : Y
	}
	Return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0, "Ptr")
}

MDMF_GetInfo(HMON) {
	MIEX := Buffer(40 + 64)
	NumPut("UInt", MIEX.Size, MIEX, 0)
	If DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX) {
		MonName := StrGet(MIEX.Ptr + 40, 32)	; CCHDEVICENAME = 32
		MonNum := RegExReplace(MonName, ".*(\d+)$", "$1")
		Return { Name: (Name := StrGet(MIEX.Ptr + 40, 32)), Num: RegExReplace(Name, ".*(\d+)$", "$1"), Left: NumGet(MIEX, 4, "Int"),	; display rectangle
			Top: NumGet(MIEX, 8, "Int"),	; "
			Right: NumGet(MIEX, 12, "Int"),	; "
			Bottom: NumGet(MIEX, 16, "Int"),	; "
			WALeft: NumGet(MIEX, 20, "Int"),	; work area
			WATop: NumGet(MIEX, 24, "Int"),	; "
			WARight: NumGet(MIEX, 28, "Int"),	; "
			WABottom: NumGet(MIEX, 32, "Int"),	; "
			Primary: NumGet(MIEX, 36, "UInt") }	; contains a non-zero value for the primary monitor.
	}
	Return False
}

GetRotatedTranslation(Width, Height, Angle, &xTranslation, &yTranslation) {
	pi := 3.14159, TAngle := Angle * (pi / 180)

	Bound := (Angle >= 0) ? Mod(Angle, 360) : 360 - Mod(-Angle, -360)
	if ((Bound >= 0) && (Bound <= 90))
		xTranslation := Height * Sin(TAngle), yTranslation := 0
	else if ((Bound > 90) && (Bound <= 180))
		xTranslation := (Height * Sin(TAngle)) - (Width * Cos(TAngle)), yTranslation := -Height * Cos(TAngle)
	else if ((Bound > 180) && (Bound <= 270))
		xTranslation := -(Width * Cos(TAngle)), yTranslation := -(Height * Cos(TAngle)) - (Width * Sin(TAngle))
	else if ((Bound > 270) && (Bound <= 360))
		xTranslation := 0, yTranslation := -Width * Sin(TAngle)
}

GetRotatedDimensions(Width, Height, Angle, &RWidth, &RHeight) {
	pi := 3.1415926, TAngle := Angle * (pi / 180)
	if !(Width && Height)
		return -1
	RWidth := Ceil(Abs(Width * Cos(TAngle)) + Abs(Height * Sin(TAngle)))
	RHeight := Ceil(Abs(Width * Sin(TAngle)) + Abs(Height * Cos(Tangle)))
}