/************************************************************************
 * @description create native functions or methods from mcode,
 * load ahk modules(write by c/c++) as native classes or fuctions.
 * @author thqby
 * @date 2024/05/04
 * @version 1.1.9
 ***********************************************************************/

class Native extends Func {
	static Prototype.caches := Map()
	static sizes := {
		func: 8 * A_PtrSize + 16,
		method: 9 * A_PtrSize + 16,
		mdfunc: 10 * A_PtrSize + 16,
	}
	static offsets := {
		name: 3 * A_PtrSize + 8,
		buffer_data: 3 * A_PtrSize + 8,
		maxparams: 4 * A_PtrSize + 8,
		outputvars: 5 * A_PtrSize + 16,
		pfn: 6 * A_PtrSize + 16,
	}
	static __New() {
		this.DeleteProp('__New')
		if VerCompare(A_AhkVersion, '2.1-alpha.3') >= 0 {
			for prop in ['sizes', 'offsets']
				for name in (obj := this.%prop%).OwnProps()
					obj.%name% += 2 * A_PtrSize
		}
	}

	; Auto free the NativeFunc object memory, because destructor is overridden, ahk will not free the memory.
	; Freeing memory before func obj is released can cause invalid reads and writes to memory.
	; Delayed free memory, the memory of the last function is freed when the function object is released.
	__Delete() {
		static buffer_data_offset := Native.offsets.buffer_data, pfn_offset := Native.offsets.pfn
		NumPut('ptr', pthis := ObjPtr(this), ObjPtr(this.caches[''] := Buffer()), buffer_data_offset)
		try this.caches.Delete(NumGet(pthis + pfn_offset, 'ptr'))
	}

	; Provides a way for modules to call ahk objects
	static __Get(name, params) => params.Length ? %name%[params*] : %name%
	static __Call(name, params) {
		if name = 'throw' {
			if len := params.Length {
				msg := params[1], extra := len > 1 ? params[2] : '', errobj := len > 2 ? %params[3]% : msg is Integer ? OSError : Error
				throw errobj(msg, -1, extra)
			}
			throw Error('An exception occurred', -1)
		}
		return %name%(params*)
	}

	; create c/c++ function from mcode, and return the function address
	static MCode(hex) {
		static reg := "^([12]?).*" (A_PtrSize = 8 ? "x64" : "x86") ":([A-Za-z\d+/=]+)"
		if (RegExMatch(hex, reg, &m))
			hex := m[2], flag := m[1] = "1" ? 4 : m[1] = "2" ? 1 : hex ~= "[+/=]" ? 1 : 4
		else flag := hex ~= "[+/=]" ? 1 : 4
		if (!DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", 0, "uint*", &s := 0, "ptr", 0, "ptr", 0))
			throw OSError(A_LastError)
		if (DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", p := (code := Buffer(s)).Ptr, "uint*", &s, "ptr", 0, "ptr", 0) && DllCall("VirtualProtect", "ptr", code, "uint", s, "uint", 0x40, "uint*", 0))
			return (this.Prototype.caches[p] := code, p)
		throw OSError(A_LastError)
	}

	/**
	 * Generate a func object with native code
	 * @param BIF Function addresses, `void funcname(ResultToken &aResultToken, ExprTokenType *aParam[], int aParamCount)`
	 * @param MinParams The number of required parameters
	 * @param ParamCount The number of maximum parameters, ParamCount = 255 if the function is variadic
	 * @param OutputVars The array that contains one-based indexs of outputvars, up to seven
	 * @param FID Function ID, `aResultToken.func->mFID`, for code sharing: this function's ID in the group of functions which share the same C++ function
	 */
	static Func(BIF, MinParams := 0, ParamCount := 0, OutputVars := 0, FID := 0) {
		static p__init := ObjPtr(Any.__Init)
		offsets := this.offsets, size := this.sizes.func
		if BIF is String
			BIF := this.MCode(BIF)
		; copy a func object memory
		sbif := Buffer(OutputVars ? size + 7 : size, 0), DllCall('RtlMoveMemory', 'ptr', sbif, 'ptr', p__init, 'uint', size)
		obif := ObjFromPtr(sbif.Ptr)
		if IsVariadic := ParamCount == 255
			ParamCount := MinParams
		else ParamCount := Max(MinParams, ParamCount)
		; init func refcount and base obj
		NumPut('uint', 1, 'uint', 0, 'ptr', ObjPtrAddRef(Native.Prototype), sbif, A_PtrSize)
		; init func infos
		NumPut('ptr', StrPtr('User-BIF'), 'int', ParamCount, 'int', MinParams, 'int', IsVariadic, sbif, offsets.name)
		NumPut('ptr', BIF, 'ptr', FID, sbif, offsets.pfn)
		if OutputVars {
			NumPut('ptr', s := sbif.Ptr + size, sbif, offsets.outputvars)	; mOutputVars
			loop Min(OutputVars.Length, 7)	; MAX_FUNC_OUTPUT_VAR = 7
				s := NumPut('uchar', OutputVars[A_Index], s)
		}
		NumPut('ptr', 0, 'ptr', 0, ObjPtr(sbif), offsets.buffer_data) ; Avoid the memory of func object be freed when buffer is released
		return obif
	}

	/**
	 * Generate a method with native code, is same with `Native.Func`
	 * @param base The base of instance
	 */
	static Method(base, BIM, MIT, MinParams := 0, ParamCount := 0, MID := 0) {
		static pOwnProps := ObjPtr({}.OwnProps)
		offsets := this.offsets, size := this.sizes.method, nameoffset := offsets.name
		if BIM is String
			BIM := this.MCode(BIM)
		sbim := Buffer(size, 0), DllCall('RtlMoveMemory', 'ptr', sbim, 'ptr', pOwnProps, 'uint', size)
		obim := ObjFromPtr(sbim.Ptr), IsVariadic := ParamCount == 255
		switch MIT, false {
			case 'call', 2: ++MinParams, ParamCount := IsVariadic ? MinParams : Max(MinParams, ParamCount + 1), NumPut('ptr', StrPtr('User-BIM'), sbim, nameoffset), MIT := 2
			case 'set', 1: MinParams += 2, ParamCount += 2, MIT := 1, NumPut('ptr', StrPtr('User-BIM.Set'), sbim, nameoffset)
			case 'get', 0: ++MinParams, ParamCount := Max(MinParams, ParamCount + 1), NumPut('ptr', StrPtr('User-BIM.Get'), sbim, nameoffset), MIT := 0
		}
		NumPut('uint', 1, 'uint', 0, 'ptr', ObjPtrAddRef(Native.Prototype), sbim, A_PtrSize)
		NumPut('int', Max(MinParams, ParamCount), 'int', MinParams, 'int', IsVariadic, sbim, offsets.maxparams)
		NumPut('ptr', BIM, 'ptr', base, 'uchar', MID, 'uchar', MIT, sbim, offsets.pfn)
		NumPut('ptr', 0, 'ptr', 0, ObjPtr(sbim), offsets.buffer_data)
		return obim
	}

	/**
	 * Defines a new own property with native code, is similar with `obj.DefineProp`
	 * @param obj Any object
	 * @param name The name of the property
	 * @param desc An object with one of following own properties, or both `Get` and `Set`
	 * 
	 * `Call, Get, Set`: an object with `BIM` property and optional properties `MinParams`, `ParamCount`, `OutputVars`, `MID`, is same with the parameters of `BuiltInFunc`
	 * 
	 * `BIM`: `void (IObject::* ObjectMethod)(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount)`
	 */
	static DefineProp(obj, name, desc) {
		descobj := {}, baseobj := ObjPtr(obj.Base)
		for MIT in ['call', 'set', 'get']
			if desc.HasOwnProp(MIT) {
				t := desc.%MIT%, MinParams := ParamCount := MID := 0, BIM := t.BIM
				for k in ['MinParams', 'ParamCount', 'MID']
					if t.HasOwnProp(k)
						%k% := t.%k%
				descobj.%MIT% := this.Method(baseobj, BIM, MIT, MinParams, ParamCount, MID)
			}
		obj.DefineProp(name, descobj)
	}

	/**
	 * Create a class with constructor function address
	 * @param ctor constructor function address, `void funcname(ResultToken &aResultToken, ExprTokenType *aParam[], int aParamCount)`
	 * 
	 * constructor function used to create an object
	 */
	static Class(name, ctor := 0, FID := 0) {
		cls := Class(), NumPut('uint', 1, ObjPtr(cls.Prototype := { Base: Object.Prototype, __Class: name }), A_PtrSize + 4)
		if ctor
			cls.DefineProp('Call', {call: this.Func(ctor, 1, 255, 0, FID)})
		return cls
	}

	/**
	 * Load a dll file with the specified format to create native functions and classes
	 * @param path ahk module path
	 * @param load_symbols Load symbols that specific names, will overwrite existing global classes
	 * @param loader Create native functions and classes based on the information provided by the module, or do it in the module
	 * @param provider Used to provide the ahk objects required by the module
	 */
	static LoadModule(path, load_symbols := 0, loader := 0, provider := 0) {
		if !(module := DllCall('LoadLibrary', 'str', path, 'ptr'))
			throw OSError(A_LastError)
		module_load_addr := DllCall('GetProcAddress', 'ptr', module, 'astr', 'ahk2_module_load', 'ptr') || DllCall('GetProcAddress', 'ptr', module, 'ptr', 1, 'ptr')
		if !module_load_addr
			throw Error('Export function not found')
		if load_symbols {
			t := Map(), t.CaseSense := false
			for k in load_symbols
				t[k] := true
			load_symbols := t
		}
		if !p := DllCall(module_load_addr, 'ptr', ObjPtr(loader || default_loader), 'ptr', ObjPtr(provider || Native), 'cdecl ptr')
			throw Error('Load module fail', -1, OSError(A_LastError).Message)
		return ObjFromPtr(p)

		default_loader(count, addr) {
			static size := 2 * A_PtrSize + 16
			symbols := Map(), symbols.CaseSense := false, symbols.DefineProp('__Call', { call: (s, n, p) => s[n](p*) })
			loop count {
				name := StrGet(pname := NumGet(addr, 'ptr'))
				if load_symbols && !load_symbols.Has(name) {
					addr += size
					continue
				}
				funcaddr := NumGet(addr += A_PtrSize, 'ptr')
				minparams := NumGet(addr += A_PtrSize, 'uchar')
				maxparams := NumGet(addr += 1, 'uchar')
				id := NumGet(addr += 1, 'ushort')
				if member_count := NumGet(addr += 2, 'uint') {
					try {
						if !load_symbols || !IsObject(symbol := %name%)
							throw
						symbols[name] := symbol
						if !symbol.HasOwnProp('Prototype')
							symbol.Prototype := this.Class(name, 0).Prototype
						if funcaddr
							symbol.DefineProp('Call', {call: me := this.Func(funcaddr, 1, maxparams + 1, 0, id)}), NumPut('ptr', pname, ObjPtr(me), 3 * A_PtrSize + 8)
					} catch
						symbols[name] := symbol := this.Class(name, funcaddr, id)
					pmem := NumGet(addr += 4, 'ptr')
				}
				staticmembers := {}, members := {}
				loop member_count {
					name := StrGet(pname := NumGet(pmem, 'ptr'))
					method := NumGet(pmem += A_PtrSize, 'ptr')
					id := NumGet(pmem += A_PtrSize, 'uchar')
					mit := NumGet(pmem += 1, 'uchar')
					minparams := NumGet(pmem += 1, 'uchar')
					maxparams := NumGet(pmem += 1, 'uchar')
					namearr := StrSplit(name, '.')
					if mit < 2 && namearr.Length > 2
						namearr.Pop()
					name := namearr.Pop()
					sub := mit = 2 ? 'call' : mit = 1 ? 'set' : 'get'
					if namearr.Length < 2
						mems := staticmembers, pbase := ObjPtr(symbol.Base)
					else
						mems := members, pbase := ObjPtr(symbol.Prototype.Base)
					if !mems.HasOwnProp(name)
						mems.DefineProp(name, { value: t := {} })
					else t := mems.%name%
					t.DefineProp(sub, { value: me := this.Method(pbase, method, mit, minparams, maxparams, id) })
					NumPut('ptr', pname, ObjPtr(me), 3 * A_PtrSize + 8)
					pmem += A_PtrSize - 3
				} else {
					symbols[name] := symbol := this.Func(funcaddr, minparams, maxparams, 0, id)
					NumPut('ptr', pname, ObjPtr(symbol), 3 * A_PtrSize + 8)
					if NumGet(addr += 4, 'uchar')	; set mOutputVars
						NumPut('ptr', addr, ObjPtr(symbol), 5 * A_PtrSize + 16)
				}
				if member_count {
					if symbol == Map	; Break circular references if Map has define native funcs
						OnExit(onexitapp.Bind(Map(Map, [staticmembers*], Map.Prototype, [members*])))
					for name, desc in staticmembers.OwnProps()
						symbol.DefineProp(name, desc)
					symbol := symbol.Prototype
					for name, desc in members.OwnProps()
						symbol.DefineProp(name, desc)
				}
				addr += 8
			}
			return symbols

			onexitapp(todels, *) {
				for o, arr in todels
					for n in arr
						try o.DeleteProp(n)
			}
		}
	}

	/**
	 * @param fn c/c++ funtion pointer
	 * @param sig Signature of function `rettype(argtypes)`, [rettype, argtypes*]
	 */
	static MdFunc(fn, sig, prototype := 0) {
		static p_mdfunc := ObjPtr(MsgBox), size := this.sizes.mdfunc
		static mdtypes := {
			void: 0,
			int8: 1,
			uint8: 2,
			int16: 3,
			uint16: 4,
			int32: 5,
			uint32: 6,
			int64: 7,
			uint64: 8,
			float64: 9,
			float32: 10,
			string: 11,
			object: 12,
			variant: 13,
			bool32: 14,
			resulttype: 15,
			fresult: 16,
			params: 17,
			optional: 0x80,
			retval: 0x81,
			out: 0x82,
			; thiscall,
			uintptr: A_PtrSize = 8 ? 8 : 6,
			intptr: A_PtrSize = 8 ? 7 : 5,
		}
		offsets := this.offsets, mdfn_offset := offsets.pfn
		if fn is String
			fn := this.MCode(fn)
		; copy a func object memory
		smdf := Buffer(size, 0), DllCall('RtlMoveMemory', 'ptr', smdf, 'ptr', p_mdfunc, 'uint', size)
		p := NumPut('ptr', fn, smdf, mdfn_offset), ac := pc := MinParams := 0
		if prototype
			NumPut('char', 1, NumPut('ptr', IsObject(prototype) ? ObjPtr(prototype) : prototype, p) + A_PtrSize + 3), ac := pc := MinParams := 1
		IsVariadic := false, MaxResultTokens := 0
		if sig is Array {
			if sig.Length
				ret := sig.RemoveAt(1), smdf.Size += sig.Length, ret is String && ret := mdtypes.%ret%
			else ret := 0
			opt := false, retval := false, out := 0
			loop sig.Length {
				c := sig[A_Index]
				if c is String
					sig[A_Index] := c := mdtypes.%c%
				NumPut('uchar', c, smdf, size + A_Index - 1)
				if c >= 128 {
					if c = 128
						opt := true
					else if c = 0x82
						out := c
					else if c = 0x81
						retval := true
					continue
				}
				if A_PtrSize = 4 && c >= 7 && c <= 9 && !out && !opt
					ac++
				ac++
				if c = 17
					IsVariadic := true
				else if !retval {
					++pc
					if !opt && pc - 1 = MinParams
						MinParams := pc
					if c = 13 && out
						++MaxResultTokens
				}
				opt := false, retval := false, out := 0
			}
			NumPut('ptr', smdf.Ptr + size, 'uchar', ret, 'uchar', MaxResultTokens, 'uchar', ac, smdf, 2 * A_PtrSize + mdfn_offset)
		} else throw TypeError()
		ParamCount := pc
		obif := ObjFromPtr(smdf.Ptr)
		; init func refcount and base obj
		NumPut('uint', 1, 'uint', 0, 'ptr', ObjPtrAddRef(Native.Prototype), smdf, A_PtrSize)
		; init func infos
		NumPut('ptr', StrPtr('User-MdFunc'), 'int', ParamCount, 'int', MinParams, 'int', IsVariadic, smdf, offsets.name)
		NumPut('ptr', 0, 'ptr', 0, ObjPtr(smdf), offsets.buffer_data)	; Avoid the memory of func object be freed when buffer is released
		return obif
	}
}