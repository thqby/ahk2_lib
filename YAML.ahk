/************************************************************************
 * @description: YAML/JSON格式字符串序列化和反序列化, 修改自[HotKeyIt/Yaml](https://github.com/HotKeyIt/Yaml)
 * 修复了一些YAML解析的bug, 增加了对true/false/null类型的支持, 保留了数值的类型
 * @author thqby, HotKeyIt
 * @date 2023/02/23
 * @version 1.0.7
 ***********************************************************************/

class YAML {
	static null := ComValue(1, 0), true := ComValue(0xB, 1), false := ComValue(0xB, 0)

	/**
	 * Converts a AutoHotkey Object Notation (YAML/JSON) string into an object.
	 * @param text A valid YAML/JSON string.
	 * @param mergedarray A array to be merged
	 * @param keepbooltype convert true/false/null to YAML.true / YAML.false / YAML.null where it's true, otherwise 1 / 0 / ''
	 */
	static parse(text, mergedarray := 0, keepbooltype := false) {
		static undefined := ComValue(0, 0), _fun_ := A_PtrSize = 8 ? "SIXJdExED7cBZkWFwHUM60BIg8ECZkWFwHQkZkGD+Ap0IWZBg/gNRA+3QQJ142ZBg/gKdB9Ig8ECZkWFwHXjSInIw4XSdAUx0maJEUiNQQLDMcDDhdJ0BTHAZokBSI1BBMOQkJCQ" : "i0QkBIXAdEsPtxBmhdJ1CutBg8ACZoXSdDdmg/oKdCBmg/oND7dQAnXoZoP6CnQmg8ACZoXSdejzw422AAAAAItMJAiFyXQFMdJmiRCDwALD88MxwMOLTCQIhcl0BTHSZokQg8AEw5A=", _sz_, NXTLN, _op_, __ := (DllCall("crypt32\CryptStringToBinary", "str", _fun_, "uint", 0, "uint", 1, "ptr", 0, "uint*", &_sz_ := 0, "ptr", 0, "ptr", 0), NXTLN := DllCall("GlobalAlloc", "uint", 0, "ptr", _sz_, "ptr"), DllCall("VirtualProtect", "ptr", NXTLN, "ptr", _sz_, "uint", 0x40, "uint*", &_op_ := 0), DllCall("crypt32\CryptStringToBinary", "str", _fun_, "uint", 0, "uint", 1, "ptr", NXTLN, "uint*", &_sz_, "ptr", 0, "ptr", 0))
		keepbooltype ? (_true := YAML.true, _false := YAML.false, _null := YAML.null) : (_true := true, _false := false, _null := "")
		if (text = "")
			return []
		else if InStr("[{", SubStr(text := LTrim(text, " `t`n`r"), 1, 1))
			return PJ(&text, mergedarray)
		return CY(&text, mergedarray)

		CY(&txt, Y := 0) {	; convert yaml to object
			NewDoc := 0, _C := "", _CE := "", _S := "", _K := "", V := undefined, N := false, _L := "", K := O := "", VQ := "", h := "", VC := ""
			txt .= Chr(0) Chr(0) Chr(0) Chr(0), P := StrPtr(txt), A := Map(), D := [0], I := [0], D.Length := I.Length := 1000
			D.Default := I.Default := 0
			; LS := RegExMatch(txt, "m)^[^\s].*:(\s+\#.*)?\R(\s+)", &LS) ? LS.Len(2) * (Ord(LS.2) = 9 ? 2 : 1) : 2	; indentation length (A_Tab = 2 Spaces, 2 Tabs = 4 Spaces)
			LS := 2
			;~ while P:=G(LP:=P,LF){
			while P && (LP := P, P := DllCall(NXTLN, "PTR", P, "Int", true, "cdecl PTR"), LF := StrGet(LP), P) {	;P:=(LP:=P,!p||!NumGet(p,"UShort")?0:(str:=StrSplit(StrGet(P),"`n","`r",2)).Length?(p+=StrLen(LF:=str[1])*2,p+=!NumGet(p,"UShort") ? 0 : NumGet(p,"USHORT")=13?4:2):0){
				if (!Y && InStr(LF, "---") = 1) || (InStr(LF, "---") = 1 && (Y.Push(""), NEWDOC := 0, D[1] := 0, _L := _LL := O := _Q := _K := _S := _T := _V := "", 1)) || (InStr(LF, "...") = 1 && NEWDOC := 1) || (LF = "") || RegExMatch(LF, "^\s+$")
					continue
				else if NEWDOC
					throw Error("Document ended but new document not specified.", 0, LF)
				if RegExMatch(LF, "^\s*#") || InStr(LF, "``%") = 1	; Comments, tag, document start/end or empty line, ignore
					continue
				else if _C || (_S && SubStr(LF, 1, LL * LS) = CL(LL + 1)) || (V !== undefined && !(K && _.SEQ) && SubStr(LF, 1, LL * LS) = CL(LL + 1)) {	; Continuing line incl. scalars
					if _Q && !_K {	; Sequence
						if D[L].Length && IsObject(VC := D[L].Pop())
							throw Error("Malformed inline YAML string")	; Error if previous value is an object
						else D[L].Push(VC (VC ? (InStr(_S, '|') == 1 ? '`n' : ' ') : "") _CE := LTrim(LF, "`t "))	; append value to previous item	; append value to previous item
					} else if IsObject(VC := D[L][K])
						throw Error("Malformed inline YAML string")	; Error if previous value is an object
					else D[L][K] := VC (VC ? (InStr(_S, '|') == 1 ? '`n' : ' ') : "") _CE := LTrim(LF, "`t ")	; append value to previous item
					continue
				} else if _C && (SubStr(_CE, -1) != _C)
					throw Error("Unexpected character", 0, (_Q ? D[L][D[L].Length] : D[L][K]))	; else check if quoted value was ended with a quote
				else _C := ""	; reset continuation
				if (CM := InStr(LF, " #")) && !RegExMatch(LF, ".*[`"'].*\s\#.*[`"'].*")	; check for comments and remove
					LF := SubStr(LF, 1, CM - 1)
				; Split line into yaml elements
				if SubStr(LTrim(LF, " `t"), 1, 1) = ":"
					throw Error("Unexpected character.", 0, ':')
				RegExMatch(LF, "S)^(?<LVL>\s+)?(?<SEQ>-\s)?(?<KEY>`".*`"\s*:(\s|$)|'.*'\s*:(\s|$)|[^:`"'\{\[]+\s*:(\s|$))?\s*(?<SCA>[\|\>][+-]?)?\s*(?<TYP>!!\w+)?\s*(?<AGET>\*[^\s\t]+)?\s*(?<ASET>&[^\s\t]+)?\s*(?<VAL>`".+`"|'.+'|.+)?\s*$", &_)
				L := LL := CS(_.LVL, LS), Q := _.SEQ, K := _.KEY, S := _.SCA, T := SubStr(_.TYP, 3), V := UQ(_.VAL, T != "")
				VQ := InStr(".''.`"`".", "." SubStr(LTrim(_.VAL, " `t"), 1, 1) SubStr(RTrim(_.VAL, " `t"), -1) ".")
				if L > 1 {
					if LL = _LL
						L := _L
					else if LL > _LL
						I[LL] := L := _L + 1
					else if LL < _LL
						if !I[LL]
							throw Error("Indentation problem.", 0, LF)
						else L := I[LL] + (LL + 1 == _LL && Q != '' && D[LL] is Map && D[_LL] is Array)
				}
				if Trim(_[], " `t") = "-"	; empty sequence not cached by previous line
					V := undefined, Q := "-"
				else if V = "" && _.VAL = ""
					V := undefined
				else if V !== undefined && !Q	; only a value is catched, convert to key
					if K = ""
						K := V, V := undefined
				if !Q && SubStr(RTrim(K, " `t"), -1) != ":"	; not a sequence and key is missing :
					if L > _L && (D[_L][_K] := K, LL := _LL, L := _L, K := _K, Q := _Q, _S := ">")
						continue
					else throw Error("Invalid key.", 0, LF)
				else if K != ""	; trim key if not empty
					K := UQ(RTrim(K, ": "), true)
				Loop _L = "" ? D.Length - 1 : _L ? _L - L : 0	; remove objects in deeper levels created before
					D[L + A_Index] := 0, I[L + A_Index] := 0
				if !VQ && _.VAL != "" && !InStr("'`"", _C := SubStr(LTrim(_.VAL, " `t"), 1, 1))	; check if value started with a quote and was not closed so next line continues
					_C := ""
				if _L != L && !D[L]	; object in this level not created yet
					if L = 1 {	; first level, use or create main object
						if Y && Type(Y[Y.Length]) != "String" && ((Q && Type(Y[Y.Length]) != "Array") || (!Q && Type(Y[Y.Length]) = "Array"))
							throw Error("Mapping Item and Sequence cannot be defined on the same level.", 0, LF)	; trying to create sequence on the same level as key or vice versa
						else D[L] := Y ? (Type(Y[Y.Length]) = "String" ? (Y[Y.Length] := Q ? [] : Map()) : Y[Y.Length]) : (Y := Q ? [[]] : [Map()])[1]
					} else if !_Q && Type(D[L - 1][_K]) = (Q ? "Array" : "Map")	; use previous object
						D[L] := D[L - 1][_K]
					else D[L] := O := Q ? [] : Map(), _A ? A[_A] := O : "", _Q ? (N && D[L - 1].Pop(), D[L - 1].Push(O)) : D[L - 1][_K] := O, O := ""	; create new object
				_A := ""	; reset alias
				if Q && K	; Sequence containing a key, create object
					D[L].Push(O := Map()), D[++L] := O, Q := O := "", LL += 1
				if (Q && Type(D[L]) != "Array" || !Q && Type(D[L]) = "Array") {
					if (Q && N && !D[L + 1] && D[L].Has(_K))
						D[L][_K] := O := [], I[L] := LL, LL += 1, D[++L] := O, O := ""
					else if (Q && Type(D[L + 1]) = "Array" || !Q && Type(D[L + 1]) = "Map")
						L++
					else
						throw Error("Mapping Item and Sequence cannot be defined on the same level,", 0, LF)	; trying to create sequence on the same level as key or vice versa
				}
				if T = "binary" {	; !!binary
					O := Buffer(StrLen(V) // 2), PBIN := O.Ptr
					Loop Parse V
						if ("" != h .= A_LoopField) && !Mod(A_Index, 2)
							NumPut("UChar", "0x" h, PBIN, A_Index / 2 - 1), h := ""
				} else if T = "set"
					throw Error("Tag 'set' is not supported")	; tag !!set is not supported
				else V := T = "int" || T = "float" ? V + 0 : T = "str" ? V "" : T = "null" ? _null : T = "bool" ? (V = "true" ? _true : V = "false" ? _false : V) : V	; tags !!int !!float !!str !!null !!bool - else seq map omap ignored
				if _.ASET
					A[_A := SubStr(_.ASET, 2)] := V
				if _.AGET
					V := A[SubStr(_.AGET, 2)]
				else if V is ComValue {
				} else if !VQ && SubStr(LTrim(V, " `t"), 1, 1) = "{"	; create json map object
					O := Map(), _A ? A[_A] := O : "", P := (YO(O, LP + InStr(LF, V) * 2, L))
				else if !VQ && SubStr(LTrim(V, " `t"), 1, 1) = "["	; create json sequence object
					O := [], _A ? A[_A] := O : "", P := (YA(O, LP + InStr(LF, V) * 2, L))
				N := false
				if _S ~= '^[>|]\+?$' {
					if D[L] is Map
						D[L][_K] .= '`n'
					else D[L][D[L].Length] .= '`n'
				}
				if Q	; push sequence value into an object
					; (V !== undefined ? D[L].Push(O ? O : S ? "" : V) : 0)
					(V !== undefined ? D[L].Push(O ? O : S ? "" : V) : (N := true, D[L].Push(_null)))
				else D[L][K] := O ? O : D[L].Has(K) ? D[L][K] : S ? "" : V = undefined ? (N := true, _null) : V	; add key: value into object
				if !Q && V !== undefined	; backup yaml elements
					_L := L, _LL := LL, O := _Q := _K := _S := _T := _V := ""	;_L:=
				else _L := L, _LL := LL, _Q := Q, _K := K, _S := S, _T := T, _V := V, O := ""
			}
			if _S ~= '^[>|]\+?$' {
				if D[L] is Map
					D[L][K] .= '`n'
				else D[L][D[L].Length] .= '`n'
			}
			if Y && Type(Y[Y.Length]) = "String"
				Y.Pop()
			return SubStr(txt, 1, 3) != "---" && Y.Length = 1 ? Y[1] : Y
		}
		YO(O, P, L) {	; YamlObject: convert json map
			v := q := k := b := 0, key := val := lf := nl := ""
			while ("" != c := Chr(NumGet(p, "UShort"))) {
				if c = "`n" || (c = "`r" && 10 = NumGet(p + 2, "UShort")) {
					if (q || k || (!v && !k) || SubStr(Ltrim(StrGet(p + (c = "`n" ? 2 : 4)), " `t`r`n"), 1, 1) = "}") && P += c = "`n" ? 2 : 4
						continue
					else throw Error("Malformed inline YAML string", 0, StrGet(p - 6))
				} else if !q && (c = " " || c = A_Tab) && P += 2
					continue
				else if !v && (c = '"' || c = "'") && (q := c, v := 1, P += 2)
					continue
				else if !v && k && (c = "[" || c = "{") && (P := c = "[" ? YA(O[key] := [], P + 2, L) : YO(O[key] := Map(), P + 2, L), key := "", k := 0, 1)
					continue
				else if v && !k && ((!q && c = ":") || (q && !b && q = c)) && (v := 0, key := q ? (InStr(key, "\") ? UC(key) : key) : Trim(key, " `t"), k := 1, q := 0, P += 2)
					continue
				else if v && k && ((!q && c = ",") || (q && !b && q = c)) && (v := 0, O[key] := q ? (InStr(val, "\") ? UC(val) : val) : IsNumber(val) ? val + 0 : val = "true" ? _true : val = "false" ? _false : val = "null" ? _null : val, val := "", key := "", q := 0, k := 0, P += 2)
					continue
				else if !q && c = "}" && (k && v ? (O[key] := val = "true" ? _true : val = "false" ? _false : val = "null" ? _null : val, 1) : 1) {
					;~ if ((tp:=G(P+2,lf))&&(NumGet(P+2,"UShort")=10||NumGet(P+4,"UShort")=10||(nl:=RegExMatch(lf,"^\s+?$"))||RegExMatch(lf,"^\s*[,\}\]]")))
					if ((tp := DllCall(NXTLN, "PTR", P + 2, "Int", false, "cdecl PTR"), lf := StrGet(P + 2), tp) && (NumGet(P + 2, "UShort") = 0 || (nl := RegExMatch(lf, "^\s+?$")) || RegExMatch(lf, "^\s*[,\}\]]")))
						return nl ? DllCall(NXTLN, "PTR", P + 2, "Int", true, "cdecl PTR") : lf ? P + 2 : NumGet(P + 4, "UShort") = 0 ? P + 6 : P + 4	; in case `r`n we have 2 times NULL chr
					else if !tp
						return NumGet(P + 4, "UShort") = 0 ? P + 6 : P + 4	; in case `r`n we have 2 times NULL chr
					else throw Error("Malformed inline YAML string.", 0, StrGet(p))
				} else if !v && (c = "," || c = ":" || c = " " || c = "`t") && P += 2
					continue
				else if !v && (!k ? (key := c) : val := c, b := !b && c = "\", v := 1, P += 2)
					continue
				else if v && (!k ? (key .= c) : val .= c, b := !b && c = "\", P += 2)
					continue
				else throw Error("Undefined")
			}
			return P
		}
		YA(O, P, L) {	; YamlArray: convert json sequence
			s := "", v := q := c := b := tp := 0, lf := nl := ""
			while ("" != c := Chr(NumGet(p, "UShort"))) {
				if c = "`n" || (c = "`r" && 10 = NumGet(p + 2, "UShort")) {
					if (q || !v || SubStr(Ltrim(StrGet(p + (c = "`n" ? 2 : 4)), " `t`r`n"), 1, 1) = "]") && P += c = "`n" ? 2 : 4
						continue
					else throw Error("Malformed inline YAML string.", 0, s "`n" StrGet(p - 6))
				} else if !q && (c = " " || c = A_Tab) && (lf != '' && lf .= c, P += 2)
					continue
				else if !v && (c = '"' || c = "'") && (q := c, v := 1, P += 2)
					continue
				else if !v && (c = "[" || c = "{") && (P := c = "[" ? YA((O.Push(lf := []), lf), P + 2, L) : YO((O.Push(lf := Map()), lf), P + 2, L), lf := "", 1)
					continue
				else if v && ((!q && c = ",") || (q && !b && c = q)) && (v := 0, O.Push(q ? (InStr(lf, "\") ? UC(lf) : lf) : IsNumber(lf) ? lf + 0 : lf = "true" ? _true : lf = "false" ? _false : lf = "null" ? _null : lf), q := 0, lf := "", P += 2)
					continue
				else if !q && c = "]" && (v ? (O.Push(lf = "true" ? _true : lf = "false" ? _false : lf = "null" ? _null : IsNumber(lf) ? lf + 0 : lf), 1) : 1) {
					;~ if ((tp:=G(P+2,lf))&&(NumGet(P+2,"UShort")=10||NumGet(P+4,"UShort")=10||(nl:=RegExMatch(lf,"^\s+?$"))||RegExMatch(lf,"^\s*[,\}\]]")))
					if ((tp := DllCall(NXTLN, "PTR", P + 2, "Int", false, "cdecl PTR"), lf := StrGet(P + 2), tp) && (NumGet(P + 2, "UShort") = 0 || (nl := RegExMatch(lf, "^\s+?$")) || RegExMatch(lf, "^\s*[,\}\]]")))
						return nl ? DllCall(NXTLN, "PTR", P + 2, "Int", true, "cdecl PTR") : lf ? P + 2 : NumGet(P + 4, "UShort") = 0 ? P + 6 : P + 4	; in case `r`n we have 2 times NULL chr
					else if !tp
						return NumGet(P + 4, "UShort") = 0 ? P + 6 : P + 4	; in case `r`n we have 2 times NULL chr	; in case `r`n we have 2 times NULL chr
					else if (lf ~= "^\s*#") && P += 2 * StrLen(lf) + 2
						continue
					else throw Error("Malformed inline YAML string.", 0, StrGet(p))
				} else if !v && (c = "," || c = " " || c = "`t") && P += 2	;InStr(", `t",c)
					continue
				else if !v && (lf .= c, v := 1, b := c = "\", P += 2)
					continue
				else if v && (lf .= c, b := !b && c = "\", P += 2)
					continue
				else throw Error("Undefined")
			}
			return P
		}
		PJ(&S, Y) {	; PureJSON: convert pure JSON Object
			NQ := "", LF := "", LP := 0, P := "", R := ""
			D := [C := (A := InStr(S, "[") = 1) ? [] : Map()], S := LTrim(SubStr(S, 2), " `t`r`n"), L := 1, N := 0, V := K := "", Y ? (Y.Push(C), J := Y) : J := [C], !(Q := InStr(S, '"') != 1) ? S := LTrim(S, '"') : ""
			Loop Parse S, '"' {
				Q := NQ ? 1 : !Q
				NQ := Q && (SubStr(A_LoopField, -3) = "\\\" || (SubStr(A_LoopField, -1) = "\" && SubStr(A_LoopField, -2) != "\\"))
				if !Q {
					if (t := Trim(A_LoopField, " `t`r`n")) = "," || (t = ":" && V := 1)
						continue
					else if t && (InStr("{[]},:", SubStr(t, 1, 1)) || RegExMatch(t, "^-?\d*(\.\d*)?\s*[,\]\}]")) {
						Loop Parse t {
							if N && N--
								continue
							if InStr("`n`r `t", A_LoopField)
								continue
							else if InStr("{[", A_LoopField) {
								if !A && !V
									throw Error("Malformed JSON - missing key.", 0, t)
								C := A_LoopField = "[" ? [] : Map(), A ? D[L].Push(C) : D[L][K] := C, D.Has(++L) ? D[L] := C : D.Push(C), V := "", A := Type(C) = "Array"
								continue
							} else if InStr("]}", A_LoopField) {
								if !A && V
									throw Error("Malformed JSON - missing value.", 0, t)
								else if L = 0
									throw Error("Malformed JSON - to many closing brackets.", 0, t)
								else C := --L = 0 ? "" : D[L], A := Type(C) = "Array"
							} else if !(InStr(" `t`r,", A_LoopField) || (A_LoopField = ":" && V := 1)) {
								if RegExMatch(SubStr(t, A_Index), "m)^(null|false|true|-?\d+\.?\d*)\s*[,}\]\r\n]", &R) && (N := R.Len(0) - 2, R := R.1, 1) {
									if A
										C.Push(R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R)
									else if V
										C[K] := R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R, K := V := ""
									else throw Error("Malformed JSON - missing key.", 0, t)
								} else
									throw Error("Malformed JSON - unrecognized character-", 0, A_LoopField " in " t)
							}
						}
					} else if InStr(t, ':') > 1
						throw Error("Malformed JSON - unrecognized character-", 0, SubStr(t, 1, 1) " in " t)
				} else if NQ && (P .= A_LoopField '"', 1)
					continue
				else if A
					LF := P A_LoopField, C.Push(InStr(LF, "\") ? UC(LF) : LF), P := ""
				else if V
					LF := P A_LoopField, C[K] := InStr(LF, "\") ? UC(LF) : LF, K := V := P := ""
				else
					LF := P A_LoopField, K := InStr(LF, "\") ? UC(LF) : LF, P := ""
			}
			return J[1]
		}
		UQ(S, K := false) {	; UnQuote: remove quotes
			return (t := SubStr(S := Trim(S, " `t"), 1, 1) SubStr(S, -1)) = '""' ? (InStr(S, "\") ? UC(SubStr(S, 2, -1)) : SubStr(S, 2, -1)) : t = "''" ? SubStr(S, 2, -1) : K ? S : IsNumber(S) ? S + 0 : S = "null" ? _null : S = "true" ? _true : S = "false" ? _false : S
		}
		CS(s, x) {	; Convert Spaces to level, 1 = first level = no spaces
			return ((StrLen(s) << (Ord(s) = 9)) // x) + 1
		}
		UC(S, e := 1) {	; UniChar: convert unicode and special characters
			static m := Map(Ord('"'), '"', Ord("a"), "`a", Ord("b"), "`b", Ord("t"), "`t", Ord("n"), "`n", Ord("v"), "`v", Ord("f"), "`f", Ord("r"), "`r", Ord("e"), Chr(0x1B), Ord("N"), Chr(0x85), Ord("P"), Chr(0x2029), 0, "", Ord("L"), Chr(0x2028), Ord("_"), Chr(0xA0))
			v := ""
			Loop Parse S, "\"
				if !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
					v .= (t := InStr("ux", SubStr(A_LoopField, 1, 1)) ? SubStr(A_LoopField, 1, RegExMatch(A_LoopField, "i)^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K") - 1) : "") && RegexMatch(t, "i)^[ux][\da-f]+$") ? Chr(Abs("0x" SubStr(t, 2))) SubStr(A_LoopField, RegExMatch(A_LoopField, "i)^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K")) : m.Has(Ord(A_LoopField)) ? m[Ord(A_LoopField)] SubStr(A_LoopField, 2) : "\" A_LoopField, e := A_LoopField = "" ? e : !e
			return v
		}
		CL(i) {	; Convert level to spaces
			Loop (s := "", i - 1)
				s .= "  "
			return s
		}
	}

	/**
	 * Converts a AutoHotkey Array/Map/Object to a Object Notation (YAML/JSON) string.
	 * @param obj A AutoHotkey value, usually an object or array or map, to be converted.
	 * @param expandlevel The level of (YAML/JSON) string need to expand, by default return YAML string and expand all.
	 * @param space (Only JSON)Adds indentation, white space, and line break characters to the return-value JSON text to make it easier to read.
	 * @param unicode_escaped Convert non-ascii characters to \uxxxx where unicode_escaped = true
	 * @returns JSON string where expandlevel <= 0, otherwise YAML string
	 */
	static stringify(obj, expandlevel := unset, space := "  ", unicode_escaped := false) {
		expandlevel := IsSet(expandlevel) ? expandlevel : 100000
		return Trim(CO(obj, expandlevel))

		CO(O, J := 0, R := 0, Q := 0) {	; helper: convert object to yaml string
			static M1 := "{", M2 := "}", S1 := "[", S2 := "]", N := "`n", C := ",", S := "- ", E := "", K := ":"
			if (OT := Type(O)) = "Array" {
				D := J < 1 && !R ? S1 : ""
				for key, value in O {
					if ((VT := Type(value)) = "Buffer" && J > 0) {
						Loop (VAL := "", PTR := value.Ptr, value.size)
							VAL .= format("{1:.2X}", NumGet(PTR + A_Index - 1, "UCHAR"))
						value := "!!binary " VAL, F := E
					} else
						F := VT = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					if J <= R
						D .= (J + R < 0 ? "`n" CL(R + 2) : "") (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value, J, unicode_escaped, 0)) (OT = "Array" && O.Length = A_Index ? E : C)
					else if ((D := D N CL(R + 1) S) || 1) && F
						D .= Z ? Z : (J <= (R + 1) ? %F%1 : E) (F = "M" ? LTrim(CO(value, J, R + 1, F), " `t`n") : CO(value, J, R + 1, F)) (J <= (R + 1) ? %F%2 : E)
					else D .= ES(value, J, unicode_escaped, 2)
				}
			} else {
				D := J < 1 && !R ? M1 : ""
				for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
					if ((VT := Type(value)) = "Buffer" && J > 0) {
						Loop (VAL := "", PTR := value.Ptr, value.size)
							VAL .= format("{1:.2X}", NumGet(PTR + A_Index - 1, "UCHAR"))
						value := "!!binary " VAL, F := E
					} else
						F := VT = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					if J <= R
						D .= (J + R < 0 ? "`n" CL(R + 2) : "") (Q = "S" && A_Index = 1 ? M1 : E) ES(key, J, unicode_escaped, 1) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value, J, unicode_escaped, 0)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
					else if ((D := D N CL(R + 1) ES(key, J, unicode_escaped, 3) K " ") || 1) && F
						D .= Z ? Z : (J <= (R + 1) ? %F%1 : E) CO(value, J, R + 1, F) (J <= (R + 1) ? %F%2 : E)
					else D .= ES(value, J, unicode_escaped, 2)
					if J = 0 && !R
						D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
				}
			}
			if J < 0 && J + R < 0
				D .= "`n" CL(R + 1)
			if R = 0
				D := LTrim(D, "`n") (J < 1 ? (OT = "Array" ? S2 : M2) : "")
			return D
		}
		ES(S, J := 1, U := false, K := -1) {	; EscIfNeed: check if escaping needed and convert to unicode notation
			static ascii := Map("\", "\", "`a", "a", "`b", "b", "`t", "t", "`n", "n", "`v", "v", "`f", "f", "`r", "r", "`"", "`"")
			switch Type(S) {
				case "Float":
					if (v := '', d := InStr(S, 'e'))
						v := SubStr(S, d), S := SubStr(S, 1, d - 1)
					if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
						S := Round(S, Max(1, d - InStr(S, ".") - 1))
					return S v
				case "Integer":
					return S
				case "String":
					v := ""
					if (U && RegExMatch(S, "m)[\x{7F}-\x{7FFF}]")) {
						Loop Parse S
							v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : Ord(A_LoopField) < 128 ? A_LoopField : "\u" format("{1:.4X}", Ord(A_LoopField))
						return '"' v '"'
					} else if (J < 1) {
						Loop Parse S
							v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : A_LoopField
						return '"' v '"'
					} else if (K < 2) {
						if (RegExMatch(S, "m)[\{\}\[\]`"'\s:,]|^\s|\s$")) {
							Loop Parse S
								v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : A_LoopField
							return '"' v '"'
						}
					} else if (RegExMatch(S, "m)[\{\[`"'\r\n]|:\s|,\s|\s#|^[\s#\-:>]|\s$")) {
						Loop Parse S
							v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : A_LoopField
						return '"' v '"'
					} else if (K = 2 && (IsNumber(S) || RegExMatch(S, "i)^(true|false|null)$")))
						return '"' S '"'
					return S || '""'
				default:
					return S == YAML.true ? "true" : S == YAML.false ? "false" : "null"
			}
		}
		CL(i) {	; Convert level to spaces
			Loop (s := "", i - 1)
				s .= space
			return s
		}
	}
}