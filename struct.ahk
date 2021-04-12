#Requires AutoHotkey v2.0-a129
class struct
{
	static __types := {UInt: 4, UInt64: 8, Int: 4, Int64: 8, Short: 2, UShort: 2, Char: 1, UChar: 1, Double: 8, Float: 4, Ptr: A_PtrSize, UPtr: A_PtrSize}
	__New(structinfo, ads_pa := unset, _offset := 0) {
		global A_DebuggerName
		_types := struct.__types, _maxbytes := 0, _index := 0, _root := true, _level := 0, _sub := []
		this.DefineProp("__struct", {Value: {}}), this.DefineProp("__buffer", {Value: {Ptr: 0, Size: 0}}), this.DefineProp("__member", {Value: []})	; this.__struct:={}, this.__buffer:=""
		this.DefineProp("__base", {Value: (IsSet(&ads_pa) && Type(ads_pa) = "Buffer") ? (_root := false, ads_pa) : BufferAlloc(A_PtrSize, 0)})
		if (Type(structinfo) = "String") {
			structinfo := RegExReplace(structinfo := StrReplace(structinfo, ",", "`n"), "m)^\s*unsigned\s*", "U")
			structinfo := StrSplit(structinfo, "`n", "`r `t")
		}
		while (_index < structinfo.Length) {
			_index++, _LF := structinfo[_index]
			if (_LF ~= "^(typedef\s+)?struct\s*") {
				if (_index > 1) {
					_level++, _submax := 0, _sub.Length := 0
					while (_level) {
						_index++, _LF := structinfo[_index]
						if InStr(_LF, "{")
							_level++
						else if InStr(_LF, "}") && ((--_level) = 0) {
							if !RegExMatch(_LF, "\}\s*(\w+)", &_n)
								throw Error("structure's name not found")
							break
						} else if RegExMatch(_LF, "^(\w+)\s*(\*+)?\s*(\w+)(\[\d+\])?", &_m)
							_type := struct.ahktype(_m[1] _m[2]), _submax := Max(_submax, struct.__types.%_type%), _LF := _type " " _m[3] _m[4]
						_sub.Push(_LF)
					}
					_offset := Mod(_offset, _submax) ? (Integer(_offset / _submax) + 1) * _submax : _offset
					this.__member.Push(_n[1]), this.__struct.%_n[1]% := _tmp := struct(_sub, this.__base, _offset)
					_offset := _tmp.__offset + _tmp.__buffer.Size, _maxbytes := Max(_maxbytes, _tmp.__maxbytes)
				}
				continue
			}
			if RegExMatch(_LF, "^(\w+)\s*(\*+)?\s*(\w+)(\[\d+\])?", &_m) {
				_type := _root ? struct.ahktype(_m[1] _m[2]) : _m[1]
				_b := _types.%_type%, _maxbytes := Max(_maxbytes, _b), _offset := Mod(_offset, _b) ? (Integer(_offset / _b) + 1) * _b : _offset
				if !IsSet(&_firstmember)
					_firstmember := _offset
				this.DefineProp("__maxbytes", {Value: _maxbytes}), this.__member.Push(_m[3])
				if (_n := Integer("0" Trim(_m[4], "[]")))
					this.__struct.%_m[3]% := {type: _type, offset: _offset, size: _n}, _offset += _b * _n
				else
					this.__struct.%_m[3]% := {type: _type, offset: _offset}, _offset += _b
			}
		}
		_offset := Mod(_offset - _firstmember, _maxbytes) ? ((Integer((_offset - _firstmember) / _maxbytes) + 1) * _maxbytes + _firstmember) : _offset
		this.DefineProp("__offset", {Value: _firstmember})
		if IsSet(&ads_pa) {
			if Type(ads_pa) = "Buffer"
				(this.__buffer := {Size: _offset - _firstmember}).DefineProp("Ptr", {get: ((p, o, *) => NumGet(p, "Ptr") + o).Bind(ads_pa.Ptr, _firstmember)})
			else
				this.__buffer := {Ptr: Integer(ads_pa), Size: _offset - _firstmember}, NumPut("Ptr", ads_pa, this.__base)
		} else NumPut("Ptr", (this.__buffer := BufferAlloc(_offset - _firstmember, 0)).Ptr, this.__base)

		;@Ahk2Exe-IgnoreBegin
		; view structure member's value in debugvars
		if IsSet(&A_DebuggerName)
			for _m in this.__struct.OwnProps()
				this.__struct.%_m%.DefineProp("value", {get: ((n, *) => this.%n%).Bind(_m)})
		;@Ahk2Exe-IgnoreEnd
	}
	__Get(n, params) {
		if (Type(this.__struct.%n%) = "Object") {
			_offset := this.__struct.%n%.offset - this.__offset
			if params.Length {
				if (params[1] >= this.__struct.%n%.size)
					throw Error("Invalid index")
				_offset += params[1] * struct.__types.%(this.__struct.%n%.type)%
			}
			return NumGet(this.__buffer.Ptr, _offset, this.__struct.%n%.type)
		} else return this.__struct.%n%
	}
	__Set(n, params, v) {
		if (Type(this.__struct.%n%) = "Object") {
			_offset := this.__struct.%n%.offset - this.__offset
			if params.Length {
				if (params[1] >= this.__struct.%n%.size)
					throw Error("Invalid index")
				_offset += params[1] * struct.__types.%(this.__struct.%n%.type)%
			}
			NumPut(this.__struct.%n%.type, v, this.__buffer.Ptr, _offset)
		} else throw Error("substruct '" n "' can't be overwritten")
	}
	data() => this.__buffer.Ptr
	offset(n) => this.__struct.%n%.offset
	size() => this.__buffer.Size
	__Delete() => (this.__base := this.__buffer := this.__member := this.__struct := '')

	toString() {
		_str := "// total size:" this.__buffer.Size "  (" (A_PtrSize * 8) " bit)`nstruct {`n", Dump(this)
		return _str "};"

		Dump(structobj, _indent := 1) {
			for _m in structobj.__member {
				if ("Object" = _t := Type(_n := structobj.__struct.%_m%))
					_str .= Indent(_indent) _n.type "`t" _m (_n.HasOwnProp("size") ? "[" _n.size "]" : "") ";`t// " _n.offset "`n"
				else if (_t = "struct") {
					_str .= Indent(_indent) "// struct '" _m "' size:" _n.__buffer.Size "`n" Indent(_indent) "struct {`n"
					Dump(_n, _indent + 1)
					_str .= Indent(_indent) "} " _m ";`n"
				}
			}
		}
		Indent(n := 0) {
			Loop (_ind := "", n)
				_ind .= "  "
			return _ind
		}
	}

	static ahktype(t) {
		if (!struct.__types.HasOwnProp(_type := LTrim(t, "_"))) {
			switch (_type := StrUpper(_type))
			{
				case "BYTE", "BOOLEAN":
					_type := "UChar"
				case "ATOM", "LANGID", "WORD", "INTERNET_PORT":
					_type := "UShort"
				case "TBYTE", "TCHAR", "WCHAR":
					_type := "Short"
				case "BOOL", "HFILE", "HRESULT", "INT32", "LONG", "LONG32", "INTERNET_SCHEME":
					_type := "Int"
				case "UINT32", "ULONG", "ULONG32", "COLORREF", "DWORD", "DWORD32", "LCID", "LCTYPE", "LGRPID":
					_type := "UInt"
				case "LONG64", "LONGLONG", "USN":
					_type := "Int64"
				case "DWORD64", "DWORDLONG", "ULONG64", "ULONGLONG":
					_type := "UInt64"
				default:
					if InStr(_type, "*")
						return "Ptr"
					_U := (_type ~= "^U[^uU]\w+$" ? ((_type := LTrim(_type, "U")), true) : false)
					if (_type == "HALF_PTR")
						_type := (_U ? "U" : "") (A_PtrSize = 8 ? "Int" : "Short")
					else if (_type ~= "^(\w+_PTR|[WL]PARAM|LRESULT|(H|L?P)\w+|SC_(HANDLE|LOCK)|S?SIZE_T|VOID)$")
						_type := (_U ? "U" : "") "Ptr"
					if (!struct.__types.HasOwnProp(_type))
						throw Error("unsupport type: " _type)
			}
		}
		return _type
	}
}

;@Ahk2Exe-IgnoreBegin
if (A_LineFile = A_ScriptFullPath) {
	ss := struct('
	(
typedef struct {
  DWORD           dwStructSize;
  LPWSTR          lpszScheme;
  DWORD           dwSchemeLength;
  INTERNET_SCHEME nScheme;
  LPWSTR          lpszHostName;
  DWORD           dwHostNameLength;
  INTERNET_PORT   nPort;
  LPWSTR          lpszUserName;
  DWORD           dwUserNameLength;
  LPWSTR          lpszPassword;
  DWORD           dwPasswordLength;
  LPWSTR          lpszUrlPath;
  DWORD           dwUrlPathLength;
  LPWSTR          lpszExtraInfo;
  DWORD           dwExtraInfoLength;
} URL_COMPONENTS, *LPURL_COMPONENTS;
	)')
	MsgBox(String(ss))
}
;@Ahk2Exe-IgnoreEnd
