/************************************************************************
 * @description SQLite class
 * @file CSQLite.ahk
 * @author thqby
 * @date 2022/04/23
 * @version 0.0.4
 ***********************************************************************/

class CSQLite {
	static Version := "", _SQLiteDLL := A_ScriptDir . "\SQLite3.dll", _RefCount := 0, hModule := 0
	static _MinVersion := "3.29"

	__New(DllFolder := "") {
		this._Path := ""						; Database path											(String)
		this.ptr := 0					  ; Database handle										 (Pointer)
		if (CSQLite._RefCount = 0) {
			SQLiteDLL := CSQLite._SQLiteDLL
			if FileExist(DllFolder "\SQLite3.dll")
				SQLiteDLL := CSQLite._SQLiteDLL := DllFolder "\SQLite3.dll"
			if (!DllCall("GetModuleHandle", "Str", SQLiteDLL, "UPtr")
				&& !(CSQLite.hModule := DllCall("LoadLibrary", "Str", SQLiteDLL, "UPtr")))
				throw Error("DLL " SQLiteDLL " does not exist!")
			CSQLite.Version := StrGet(DllCall("SQLite3.dll\sqlite3_libversion", "Cdecl UPtr"), "UTF-8")
			SQLVersion := StrSplit(CSQLite.Version, ".")
			MinVersion := StrSplit(CSQLite._MinVersion, ".")
			if (SQLVersion[1] < MinVersion[1]) || ((SQLVersion[1] = MinVersion[1]) && (SQLVersion[2] < MinVersion[2]))
				DllCall("FreeLibrary", "Ptr", CSQLite.hModule), CSQLite.hModule := 0
				throw Error("Version " . CSQLite.Version . " of SQLite3.dll is not supported!`n`n"
					. "You can download the current version from www.sqlite.org!")
		}
		CSQLite._RefCount += 1
	}
	; ===================================================================================================================
	; DESTRUCTOR __Delete
	; ===================================================================================================================
	__Delete() {
		if (this.ptr)
			this.CloseDB()
		CSQLite._RefCount -= 1
		if (CSQLite._RefCount = 0) {
			if (CSQLite.hModule)
				DllCall("FreeLibrary", "Ptr", CSQLite.hModule)
		}
	}
	_StrToUTF8(Str) => (StrPut(Str, buf := Buffer(StrPut(Str, "utf-8")), "utf-8"), buf)
	_ErrMsg() => ((RC := DllCall("SQLite3.dll\sqlite3_errmsg", "ptr", this, "Cdecl Ptr")) ? StrGet(RC, "UTF-8") : "")
	_ErrCode() => DllCall("SQLite3.dll\sqlite3_errcode", "ptr", this, "Cdecl Int")
	_ReturnMsg(RC) {
		static Msg := Map(1, "SQL错误或丢失数据库"
			, 2, "SQLite内部逻辑错误"
			, 3, "拒绝访问"
			, 4, "回调函数请求取消操作"
			, 5, "数据库文件被锁定"
			, 6, "数据库中的一个表被锁定"
			, 7, "某次malloc()函数调用失败"
			, 8, "尝试写入一个只读数据库"
			, 9, "操作被sqlite3_interupt()函数中断"
			, 10, "发生某些磁盘I/O错误"
			, 11, "数据库磁盘映像不正确"
			, 12, "sqlite3_file_control()中出现未知操作数"
			, 13, "因为数据库满导致插入失败"
			, 14, "无法打开数据库文件"
			, 15, "数据库锁定协议错误"
			, 16, "数据库为空"
			, 17, "数据结构发生改变"
			, 18, "字符串或二进制数据超过大小限制"
			, 19, "由于约束违例而取消"
			, 20, "数据类型不匹配"
			, 21, "不正确的库使用"
			, 22, "使用了操作系统不支持的功能"
			, 23, "授权失败"
			, 24, "附加数据库格式错误"
			, 25, "传递给sqlite3_bind()的第二个参数超出范围"
			, 26, "被打开的文件不是一个数据库文件"
			, 100, "sqlite3_step()已经产生一个行结果"
			, 101, "sqlite3_step()完成执行操作")
		return Msg.Get(RC, "")
	}
	; ===================================================================================================================
	; Properties
	; ===================================================================================================================
	ErrorMsg := ""              ; Error message                           (String)
	ErrorCode := 0              ; SQLite error code / ErrorLevel          (Variant)
	OpenDB(DBPath, Access := "W", Create := true) {
		static SQLITE_OPEN_READONLY := 0x01 ; Database opened as read-only
		static SQLITE_OPEN_READWRITE := 0x02 ; Database opened as read-write
		static SQLITE_OPEN_CREATE := 0x04 ; Database will be created if not exists
		static MEMDB := ":memory:"
		this.ErrorMsg := "", this.ErrorCode := 0
		if (DBPath = "")
			DBPath := MEMDB
		if (DBPath = this._Path) && (this.ptr)
			return true
		if (this.ptr)
			return (this.ErrorMsg := "You must first close DB " . this._Path . "!", false)
		Flags := 0, Access := SubStr(Access, 1, 1)
		if (Access != "W") && (Access != "R")
			Access := "R"
		Flags := SQLITE_OPEN_READONLY
		if (Access = "W") {
			Flags := SQLITE_OPEN_READWRITE
			if (Create)
				Flags |= SQLITE_OPEN_CREATE
		}
		this._Path := DBPath
		if (RC := DllCall("SQLite3.dll\sqlite3_open_v2", "Ptr", this._StrToUTF8(DBPath), "Ptr*", &HDB := 0, "Int", Flags, "Ptr", 0, "Cdecl Int"))
			return (this._Path := "", this.ErrorMsg := this._ErrMsg(), this.ErrorCode := RC, false)
		this.ptr := HDB
		static pfns := Map()
		for fn in [regexp, regex_replace]
			this.createScalarFunction(fn.Name, pfns.Get(fn, 0) || pfns[fn] := CallbackCreate(fn, "F C"), fn.MaxParams)
		return true
		regexp(Context, ArgC, vals) {
			regexNeedle := DllCall("SQLite3.dll\sqlite3_value_text16", "Ptr", NumGet(vals + 0, "Ptr"), "Cdecl Str")
			search := DllCall("SQLite3.dll\sqlite3_value_text16", "Ptr", NumGet(vals + A_PtrSize, "Ptr"), "Cdecl Str")
			DllCall("SQLite3.dll\sqlite3_result_int", "Ptr", Context, "Int", RegexMatch(search, regexNeedle), "Cdecl") ; 0 = false, 1 = true
		}
		regex_replace(Context, ArgC, vals) {
			search := DllCall("SQLite3.dll\sqlite3_value_text16", "Ptr", NumGet(vals + 0, "Ptr"), "Cdecl Str")
			regexNeedle := DllCall("SQLite3.dll\sqlite3_value_text16", "Ptr", NumGet(vals + A_PtrSize, "Ptr"), "Cdecl Str")
			Replacement := DllCall("SQLite3.dll\sqlite3_value_text16", "Ptr", NumGet(vals + A_PtrSize * 2, "Ptr"), "Cdecl Str")
			DllCall("SQLite3.dll\sqlite3_result_text16", "Ptr", Context, "Str", RegExReplace(search, regexNeedle, Replacement), "Int", -1, "Ptr", 0, "Cdecl")
		}
	}
	; ===================================================================================================================
	; METHOD CloseDB        Close database
	; Parameters:           None
	; return values:        On success  - true
	;                       On failure  - false, ErrorMsg / ErrorCode contain additional information
	; ===================================================================================================================
	CloseDB() {
		this.ErrorMsg := "", this.ErrorCode := 0, this.SQL := ""
		if !this.ptr
			return true
		if (RC := DllCall("SQLite3.dll\sqlite3_close", "ptr", this, "Cdecl Int"))
			return (this.ErrorMsg := this._ErrMsg(), this.ErrorCode := RC, false)
		this._Path := "", this.ptr := 0
		return true
	}
	; ===================================================================================================================
	LoadOrSaveDb(DBPath, isSave := 0) {
		static SQLITE_OPEN_READONLY := 0x01 ; Database opened as read-only
		static SQLITE_OPEN_READWRITE := 0x02 ; Database opened as read-write
		static SQLITE_OPEN_CREATE := 0x04 ; Database will be created if not exists
		this.ErrorMsg := "", this.ErrorCode := 0, HDB := 0
		if (DBPath = "")
			return false
		if (!this.ptr)
			return (this.ErrorMsg := "You must first Open Memory DB!", false)
		Flags := SQLITE_OPEN_READWRITE, Flags |= SQLITE_OPEN_CREATE

		if (RC := DllCall("SQLite3.dll\sqlite3_open_v2", "Ptr", this._StrToUTF8(isSave ? (tmp := StrReplace(DBPath, ".db", ".tmp")) : DBPath),
			"Ptr*", &HDB, "Int", Flags, "Ptr", 0, "Cdecl Int"))
			return (this.ErrorMsg := this._ErrMsg(), this.ErrorCode := RC, false)
		pFrom := (isSave ? this.ptr : HDB), pTo := (isSave ? HDB : this.ptr)
		pBackup := DllCall("SQLite3.dll\sqlite3_backup_init", "Ptr", pTo, "AStr", "main", "Ptr", pFrom, "AStr", "main", "Cdecl Int")
		if (pBackup) {
			DllCall("SQLite3.dll\sqlite3_backup_step", "Ptr", pBackup, "Int", -1, "Cdecl Int")
			DllCall("SQLite3.dll\sqlite3_backup_finish", "Ptr", pBackup, "Cdecl Int")
		}
		RC := DllCall("SQLite3.dll\sqlite3_errcode", "Ptr", pTo, "Cdecl Int")
		DllCall("SQLite3.dll\sqlite3_close", "Ptr", HDB, "Cdecl Int")
		if (RC) {
			this._Path := "", this.ErrorMsg := this._ErrMsg(), this.ErrorCode := RC
			if (isSave)
				FileDelete tmp
			return false
		}
		if (isSave) {
			if (FileGetSize(tmp, "K") < 16)
				return (FileDelete(tmp), false)
			FileMove tmp, DBPath, 1
			this.Changes := 0
		}
		return true
	}
	; ===================================================================================================================
	; METHOD AttachDB       Add another database file to the current database connection
	;                       http://www.sqlite.org/lang_attach.html
	; Parameters:           DBPath      - Path of the database file
	;                       DBAlias     - Database alias name used internally by SQLite
	; return values:        On success  - true
	;                       On failure  - false, ErrorMsg / ErrorCode contain additional information
	; ===================================================================================================================
	AttachDB(DBPath, DBAlias) => this.Exec("ATTACH DATABASE '" . DBPath . "' As " . DBAlias . ";")

	; ===================================================================================================================
	; METHOD DetachDB       Detaches an additional database connection previously attached using AttachDB()
	;                       http://www.sqlite.org/lang_detach.html
	; Parameters:           DBAlias     - Database alias name used with AttachDB()
	; return values:        On success  - true
	;                       On failure  - false, ErrorMsg / ErrorCode contain additional information
	; ===================================================================================================================
	DetachDB(DBAlias) => this.Exec("DETACH DATABASE " . DBAlias . ";")
	Exec(SQL, pCallback := 0) {
		this.ErrorMsg := "", this.ErrorCode := 0
		if !(this.ptr)
			return (this.ErrorMsg := "Invalid database handle!", false)
		RC := DllCall("SQLite3.dll\sqlite3_exec", "ptr", this, "Ptr", this._StrToUTF8(SQL), "Ptr", pCallback, "Ptr", ObjPtr(this), "Ptr*", &Err := 0, "Cdecl Int")
		if (RC) {
			this.ErrorMsg := this._ReturnMsg(RC) || StrGet(Err, "UTF-8")
			this.ErrorCode := RC
			DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
			return false
		}
		return true
	}
	GetTable(SQL, &TB, pcall := 0) {
		static callback_gettable_ptr := CallbackCreate(callback_gettable, "F C")
		this.ErrorMsg := "", this.ErrorCode := 0
		if !(this.ptr)
			return (this.ErrorMsg := "Invalid database handle!", false)
		TB := { RowCount: 0, Rows: [] }
		RC := DllCall("SQLite3.dll\sqlite3_exec", "ptr", this, "Ptr", SQL := this._StrToUTF8(SQL)
			, "Ptr", (pcall != -1 && pcall || callback_gettable_ptr), "Ptr", ObjPtr(TB), "Ptr*", &Err := 0, "Cdecl Int")
		if (RC) {
			this.ErrorMsg := this._ReturnMsg(RC) || StrGet(Err, "UTF-8")
			this.ErrorCode := RC, DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
			return false
		} else if (pcall = -1) {
			RC := DllCall("SQlite3.dll\sqlite3_prepare_v2", "ptr", this, "Ptr", SQL, "Int", -1, "Ptr*", &Stmt := 0, "Ptr", 0, "Cdecl Int")
			TB.Cols := [], TB.ColCount := DllCall("SQlite3.dll\sqlite3_column_count", "Ptr", Stmt, "Cdecl Int")
			Loop TB.ColCount
				TB.Cols.Push(StrGet(DllCall("SQlite3.dll\sqlite3_column_name16", "Ptr", Stmt, "Int", A_Index - 1, "Cdecl UPtr"), "UTF-16"))
			DllCall("SQLite3.dll\sqlite3_finalize", "Ptr", Stmt, "Cdecl Int")
		}
		return true
		callback_gettable(TB, coln, vals, cols) {
			arr := Array(), TBobj := ObjFromPtrAddRef(TB)
			Loop coln
				arr.Push(StrGet(NumGet(vals + A_PtrSize * (A_Index - 1), "Ptr"), "UTF-8"))
			TBobj.Rows.Push(arr), TBobj.RowCount++
			return 0
		}
	}
	createScalarFunction(name, pfn, params) {
		this.ErrorMsg := "", this.ErrorCode := 0
		if (err := DllCall("SQLite3.dll\sqlite3_create_function16", "ptr", this, "Str", name, "Int", params, "Int", 0x801, "Ptr", 0, "Ptr", pfn, "Ptr", 0, "Ptr", 0, "Cdecl Int"))
			return (this.ErrorMsg := this._ErrMsg(), this.ErrorCode := err, false)
		return true
	}
	Changes() => DllCall("SQLite3.dll\sqlite3_changes", "ptr", this, "Cdecl Int")
	LastInsertRowID() => DllCall("SQLite3.dll\sqlite3_last_insert_rowid", "ptr", this, "Cdecl Int64")
	TotalChanges() => DllCall("SQLite3.dll\sqlite3_total_changes", "ptr", this, "Cdecl Int")
	SetTimeout(Timeout := 1000) {
		this.ErrorMsg := "", this.ErrorCode := 0, this.SQL := ""
		if !(this.ptr)
			return (this.ErrorMsg := "Invalid database handle!", false)
		RC := DllCall("SQLite3.dll\sqlite3_busy_timeout", "ptr", this, "Int", Timeout, "Cdecl Int")
		if (RC)
			return (this.ErrorMsg := this._ErrMsg(), this.ErrorCode := RC, false)
		return true
	}
}
