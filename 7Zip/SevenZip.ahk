Class SevenZip {
	static SevenZipError := Map(32773, "ERROR_DISK_SPACE", 32774, "ERROR_READ_ONLY", 32775, "ERROR_USER_SKIP", 32776, "ERROR_UNKNOWN_TYPE", 32777, "ERROR_METHOD", 32778, "ERROR_PASSWORD_FILE", 32779, "ERROR_VERSION", 32780, "ERROR_FILE_CRC", 32781, "ERROR_FILE_OPEN", 32782, "ERROR_MORE_FRESH", 32783, "ERROR_NOT_EXIST", 32784, "ERROR_ALREADY_EXIST", 32785, "ERROR_TOO_MANY_FILES", 32786, "ERROR_MAKEDIRECTORY", 32787, "ERROR_CANNOT_WRITE", 32788, "ERROR_HUFFMAN_CODE", 32789, "ERROR_COMMENT_HEADER", 32790, "ERROR_HEADER_CRC", 32791, "ERROR_HEADER_BROKEN", 32792, "ERROR_ARC_FILE_OPEN", 32793, "ERROR_NOT_ARC_FILE", 32794, "ERROR_CANNOT_READ", 32795, "ERROR_FILE_STYLE", 32796, "ERROR_COMMAND_NAME", 32797, "ERROR_MORE_HEAP_MEMORY", 32798, "ERROR_ENOUGH_MEMORY", 32799, "ERROR_ALREADY_RUNNING", 32800, "ERROR_USER_CANCEL", 32801, "ERROR_HARC_ISNOT_OPENED", 32802, "ERROR_NOT_SEARCH_MODE", 32803, "ERROR_NOT_SUPPORT", 32804, "ERROR_TIME_STAMP", 32805, "ERROR_TMP_OPEN", 32806, "ERROR_LONG_FILE_NAME", 32807, "ERROR_ARC_READ_ONLY", 32808, "ERROR_SAME_NAME_FILE", 32809, "ERROR_NOT_FIND_ARC_FILE", 32810, "ERROR_RESPONSE_READ", 32811, "ERROR_NOT_FILENAME", 32812, "ERROR_TMP_COPY", 32813, "ERROR_EOF", 32814, "ERROR_ADD_TO_LARC", 32815, "ERROR_TMP_BACK_SPACE", 32816, "ERROR_SHARING", 32817, "ERROR_NOT_FIND_FILE", 32818, "ERROR_LOG_FILE", 32819, "ERROR_NO_DEVICE", 32820, "ERROR_GET_ATTRIBUTES", 32821, "ERROR_SET_ATTRIBUTES", 32822, "ERROR_GET_INFORMATION", 32823, "ERROR_GET_POINT", 32824, "ERROR_SET_POINT", 32825, "ERROR_CONVERT_TIME", 32826, "ERROR_GET_TIME", 32827, "ERROR_SET_TIME", 32828, "ERROR_CLOSE_FILE", 32829, "ERROR_HEAP_MEMORY", 32830, "ERROR_HANDLE", 32831, "ERROR_TIME_STAMP_RANGE", 32832, "ERROR_MAKE_ARCHIVE", 32833, "ERROR_NOT_CONFIRM_NAME", 32834, "ERROR_UNEXPECTED_EOF", 32835, "ERROR_INVALID_END_MARK", 32836, "ERROR_INVOLVED_LZH", 32837, "ERROR_NO_END_MARK", 32838, "ERROR_HDR_INVALID_SIZE", 32839, "ERROR_UNKNOWN_LEVEL", 32840, "ERROR_BROKEN_DATA", 32841, "ERROR_INVALID_PATH", 32842, "ERROR_TOO_BIG", 32843, "ERROR_EXECUTABLE_FILE", 32844, "ERROR_INVALID_VALUE", 32845, "ERROR_HDR_EXPLOIT", 32846, "ERROR_HDR_NO_CRC", 32847, "ERROR_HDR_NO_NAME")
		, SevenZipError.Default := "ERROR_UNKNOWN_ERROR"
	__New(hwnd := 0, dllpath := "") {
		this.lib := lib := DllCall("LoadLibrary", "str", dllpath || (A_LineFile "\..\7-zip" (A_PtrSize * 8) ".dll"), "ptr")
		if (!lib)
			throw Error("load dll fail")
		for k, v in { Zip: "ttti", GetVersion: "h=s", GetCursorMode: "i", SetCursorMode: "i", GetBackGroundMode: "", SetBackGroundMode: "i", GetCursorInterval: "h=", SetCursorInterval: "h", GetRunning: "", ConfigDialog: "tti", _CheckArchive: "ti", _GetArchiveType: "t", _GetFileCount: "t", _OpenArchive: "t=tTi", CloseArchive: "t", _FindFirst: "ttt", FindNext: "tt", _GetArcFileName: "tti", GetArcFileSize: "ui=t", GetArcOriginalSize: "ui=t", GetArcCompressedSize: "ui=t", GetArcRatio: "h=t", GetArcDate: "h=t", GetArcTime: "h=t", GetArcOSType: "ui=t", IsSFXFile: "t", _GetFileName: "tti", GetOriginalSize: "ui=t", GetCompressedSize: "ui=t", GetRatio: "h=t", GetDate: "h=t", GetTime: "h=t", GetCRC: "ui=t", GetAttribute: "t", GetOSType: "ui=t", _GetMethod: "tti", GetWriteTime: "ui=t", GetWriteTimeEx: "tt", GetArcCreateTimeEx: "tt", GetArcAccessTimeEx: "tt", GetArcWriteTimeEx: "tt", SetOwnerWindow: "t", ClearOwnerWindow: "", SetOwnerWindowEx: "tt", KillOwnerWindowEx: "t", SetOwnerWindowEx64: "tti", KillOwnerWindowEx64: "t", GetSubVersion: "h=", GetArcFileSizeEx: "tt", GetArcOriginalSizeEx: "tt", GetArcCompressedSizeEx: "tt", GetOriginalSizeEx: "tt", GetCompressedSizeEx: "tt", SetUnicodeMode: "i", _ExtractMem: "tttii6*i6*i6*", _ExtractMemEx: "ttti6i6*i6*i6*", SetPriority: "i", SetCP: "ui", GetCP: "", GetLastError: "t", _SetDefaultPassword: "tt", _GetDefaultPassword: "tti", _PasswordDialog: "tti", _SfxFileStoring: "t", _SfxConfigDialog: "tti" }.OwnProps()
		this.%StrReplace(k, "Archive", "")% := DynaCall(DllCall("GetProcAddress", "ptr", lib, "astr", "SevenZip" (k = "zip" ? "" : LTrim(k, "_")), "ptr"), v)
		(this.SetUnicodeMode)(1), this.hwnd := hwnd
		DynaCall(ptr, params) {
			static p := Map("t", "ptr", "i", "int", "s", "str", "a", "astr", "w", "wstr", "h", "short", "c", "char", "f", "float", "d", "double", "i6", "int64")
			c := "", ret := "", arr := []
			loop parse StrLower(params) {
				switch A_LoopField {
					case "u":
					case "=":
						if (c = "=")
							ret := "cdecl " ret
						else if arr.Length
							ret := arr[1], arr.Length := 0
					case "6":
						arr[arr.Length - 1] .= "64"
					case "*", "p":
						arr[arr.Length - 1] .= "*"
					default:
						arr.Push((c = "u" ? "u" : "") p[A_LoopField]), arr.Length++
				}
				c := A_LoopField
			}
			if (ret)
				arr.Push(ret)
			return DllCall.Bind(ptr, arr*)
		}
	}
	SetDefaultPassword(harc := 0, pw := "") {
		return (this._SetDefaultPassword)(harc, StrBuf(pw, "UTF-8"))
	}
	GetDefaultPassword(harc := 0) {
		if (-1 = sz := (this._GetDefaultPassword)(harc))
			return -1
		pw := Buffer(sz)
		(this._GetDefaultPassword)(harc, pw, sz)
		return StrGet(pw, "UTF-8")
	}
	PasswordDialog() {
		pw := Buffer(10240)
		if !(this._PasswordDialog)(this.hwnd, pw, 10240)
			return StrGet(pw, "UTF-8")
	}
	SfxConfigDialog() {
		sfx := Buffer(10240)
		(this._SfxConfigDialog)(this.hwnd, sfx, 10240)
		return StrGet(sfx, "UTF-8")
	}
	SfxFileStoring(file) {
		return (this._SfxFileStoring)(StrBuf(file, "UTF-8"))
	}
	AutoZip(files, method := "zip", level := 9, threads := 2, options := "") {
		if !InStr(".Zip.GZip.BZip2.7z.XZ.WIM.", "." method ".")
			throw TypeError("The method " method " is not supported by 7zip", -1)
		result := ""
		if !IsObject(files)
			_files := files
		else
			for k, v in files
				_files .= v "`n"
		Loop Parse, _files, "`n", "`r"
		{
			If FileExist(A_LoopField) {
				If (this.Check(A_LoopField)) {
					DirCreate(tempDir := A_Temp "\" A_TickCount "_extract")
					this.Extract(A_LoopField, tempDir, , "-y" (InStr(options, "-hide") ? " -hide" : ""))
					FileDelete(A_LoopField)
					try FileDelete(tempDir ".txt")
					Loop Files, tempDir "\*", "FD"
						FileAppend(A_LoopFileFullPath "`n", tempDir ".txt")
					result := this.Add(SubStr(A_LoopField, -1 * StrLen(method)) = method ? A_LoopField : SubStr(A_LoopField, 1, InStr(A_LoopField, ".", 1, -1)) method, "@" tempdir ".txt", "-t" method " -r -mx" level " -mmt=" threads " " options)
					DirDelete(tempDir, 1)
					FileDelete(tempDir ".txt")
				} else result := this.Add(((isFolder := InStr(FileExist(A_LoopField), "D")) ? RTrim(A_LoopField, "\") "." : SubStr(A_LoopField, 1, InStr(A_LoopField, ".", 1, -1))) method, A_LoopField (isFolder ? "\*" : ""), "-t" method " " (isFolder ? "-r " : "") "-mx" level " -mmt=" threads)
			}
		}
		return result
	}
	ExtractMem(archive, file := "", options := "") {
		if (!harc := this.Open(archive))
			|| (!info := this.FindFirst(harc, file))
			throw TargetError("Could not open archive or archive is empty: " archive, -1)
			(this.CloseArchive)(harc)
		buf := Buffer(szBuf := info.dwOriginalSize)
		if Err := (this._ExtractMem)(this.hwnd, StrBuf("x " options " `"" archive "`"" (file ? "`"" file "`"" : ""), "UTF-8"), buf, szBuf, &time := 0, &attr := 0, &szWrite := 0)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		else return buf
	}
	ExtractMemEx(archive, file := "", options := "") {
		if (!harc := this.Open(archive))
			|| (!info := this.FindFirst(harc, file))
			throw TargetError("Could not open archive or archive is empty: " archive, -1)
			(this.CloseArchive)(harc)
		buf := Buffer(szBuf := info.dwOriginalSize)
		if Err := (this._ExtractMemEx)(this.hwnd, StrBuf("x " options " `"" archive "`"" (file ? "`"" file "`"" : ""), "UTF-8"), buf, szBuf, &time := 0, &attr := 0, &szWrite := 0)
			throw ValueError(SevenZip.Error[Err], -1)
		else return buf

	}
	FindFirst(harc, file := "") {
		if !(this._FindFirst)(harc, StrBuf("`"" StrReplace(file, "`n", "`" `"") "`" -r", "UTF-8"), info := SevenZip.INDIVIDUALINFO())
			return info
	}
	GetMethod(harc) {
		buf := Buffer(10)
		if !Err := (this._GetMethod)(harc, buf, 8)
			return StrGet(buf, "UTF-8")
		else return SevenZip.SevenZipError[Err]
	}
	GetFileName(harc) {
		buf := Buffer(1024)
		if !Err := (this._GetFileName)(harc, buf, 1024)
			return StrGet(buf, "UTF-8")
		else return SevenZip.SevenZipError[Err]
	}
	GetArcFileName(harc, archive) {
		buf := Buffer(102400)
		if !Err := (this._GetArcFileName)(harc, buf, 102400)
			return StrGet(buf, "UTF-8")
		else return SevenZip.SevenZipError[Err]
	}
	Open(archive, mode) {
		return (this._Open)(this.hwnd, StrBuf(archive, "UTF-8"), mode)
	}
	Check(archive, mode := 0) {
		return (this._Check)(StrBuf(archive, "UTF-8"), mode)
	}
	GetFileCount(archive) {
		return (this._GetFileCount)(StrBuf(archive, "UTF-8"))
	}
	GetType(archive) {
		return (this._GetType)(StrBuf(archive, "UTF-8"))
	}
	Cmd(commandline) {
		if Err := (this.Zip)(this.hwnd, StrBuf(commandline, "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	Add(archive, files, options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("a " options " `"" archive "`" `"" StrReplace(files, "`n", "`" `"") "`"", "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	Benchmark(options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("b " options, "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		else return StrGet(buf, "UTF-8")
	}
	Delete(archive, files, options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("d " options " `"" archive "`" `"" StrReplace(files, "`n", "`" `"") "`"", "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	ExtractRoot(archive, dir, files := "", options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("e " options " `"" archive "`"" (dir ? " -o`"" RTrim(dir, "\") "\`"" : "") (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : ""), "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	List(archive, files := "", options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("l " options " `"" archive "`"" (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : ""), "UTF-8"), buf := Buffer(1024 * 1024), 1024 * 1024)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		if RegExMatch(rs := StrGet(buf, "UTF-8"), "i)Type = (.*)`r`n[\s\S]*`r`n[- ]{50,}`r`n([\S\s]*)`r`n[- ]{50,}`r`n([\d-]+ [\d:]+)?\s+(\d+)\s+(\d+)\s+((\d+) files)?,?\s*((\d+) folders)?", &rv)
		{
			out := [], sz := 0, out.type := rv[1], out.size := rv[5], out.file := rv[7], out.folder := rv[9]
			Loop Parse, rv[2], "`n", "`r "
				if RegExMatch(A_LoopField, "([\d-]+ [\d:]+)?\s?(\S+)\s+(\S+)\s+(\S+)\s+(.*)", &rv)
					out.push({ date: rv[1], attr: RTrim(rv[2], "."), sz: rv[3], size: rv[4], path: rv[5] })
			return out
		}
	}
	Test(archive, files := "", options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("t " options " `"" archive "`"" (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : ""), "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	Update(archive, files, options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("u " options " `"" archive "`"" (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : ""), "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	Extract(archive, dir, files := "", options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("x " options " `"" archive "`"" (dir ? " -o`"" RTrim(dir, "\") "\`"" : "") (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : ""), "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	Hash(crc, files := "", options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("h -scrc" (crc = "" ? "crc32" : crc) " " options " " (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : "*"), "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	Rename(archive, files, options := "") {
		if Err := (this.Zip)(this.hwnd, StrBuf("rn " options " `"" archive "`"" (files ? " `"" StrReplace(files, "`n", "`" `"") "`"" : ""), "UTF-8"), buf := Buffer(10240), 10240)
			throw ValueError(SevenZip.SevenZipError[Err], -1)
		return StrGet(buf, "UTF-8")
	}
	__Delete() {
		DllCall("FreeLibrary", "ptr", this.lib)
	}
	class INDIVIDUALINFO extends Buffer {
		__New() => super.__New(558, 0)
		dwOriginalSize => NumGet(this, "uint")
		dwCompressedSize => NumGet(this, 4, "uint")
		dwCRC => NumGet(this, 8, "uint")
		uFlag => NumGet(this, 12, "uint")
		uOSType => NumGet(this, 16, "uint")
		wRatio => NumGet(this, 20, "ushort")
		wDate => NumGet(this, 22, "ushort")
		wTime => NumGet(this, 24, "ushort")
		szFileName => StrGet(this.ptr + 26, 513, "cp0")
		dummy1 => StrGet(this.ptr + 539, 3, "cp0")
		szAttribute => StrGet(this.ptr + 542, 8, "cp0")
		szMode => StrGet(this.ptr + 550, 8, "cp0")
	}
}
StrBuf(string, encoding := "UTF-8") {
	return (buf := Buffer(StrPut(string, encoding)), StrPut(string, buf, encoding), buf)
}