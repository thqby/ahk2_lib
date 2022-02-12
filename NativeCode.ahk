/**
 * Generate a function with native code
 * @param BIF Function addresses, `void funcname(ResultToken &aResultToken, ExprTokenType *aParam[], int aParamCount)`
 * @param MinParams The number of required parameters
 * @param ParamCount The number of maximum parameters, ParamCount = 255 if the function is variadic
 * @param OutputVars The array that contains one-based indexs of outputvars, up to seven
 * @param FID Function ID, `aResultToken.func->mFID`, for code sharing: this function's ID in the group of functions which share the same C++ function
 */
 BuiltInFunc(BIF, MinParams := 0, ParamCount := 0, OutputVars := 0, FID := 0) {
	static p__init := ObjPtr(Any.__Init), size := 8 * A_PtrSize + 16
	; if a func obj has not own propertys, can improve `Call` performance, so use caching to store the BIF structure
	static bifcache := Map(), _ := %A_ThisFunc%.DefineProp('free', { call: (s, obj) => bifcache.Delete(IsObject(obj) ? ObjPtr(obj) : obj) })
	; copy a func obj struct
	sbif := Buffer(OutputVars ? size + 7 : size, 0), DllCall('RtlMoveMemory', 'ptr', sbif, 'ptr', p__init, 'uint', size)
	obif := ObjFromPtr(sbif.Ptr), IsVariadic := ParamCount == 255	; MAXP_VARIADIC
	bifcache[sbif.Ptr] := sbif
	NumPut('uint', 1, sbif, A_PtrSize), ObjPtrAddRef(Func.Prototype)	; init func refcount and addref base obj
	; init func infos
	NumPut('ptr', StrPtr('User-BIF'), 'int', Max(MinParams, ParamCount), 'int', MinParams, 'int', IsVariadic, sbif, 3 * A_PtrSize + 8)
	NumPut('ptr', BIF, 'ptr', FID, sbif, 6 * A_PtrSize + 16)
	if OutputVars {
		NumPut('ptr', s := sbif.Ptr + size, sbif, 5 * A_PtrSize + 16)	; mOutputVars
		loop Min(OutputVars.Length, 7)	; MAX_FUNC_OUTPUT_VAR = 7
			s := NumPut('uchar', OutputVars[A_Index], s)
	}
	return obif
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
ObjDefineBuiltInProp(obj, name, desc) {
	static bimcache := Map(), _ := %A_ThisFunc%.DefineProp('free', { call: (s, obj, name := unset) => (obj := IsObject(obj) ? ObjPtr(obj) : obj, IsSet(name) ? bimcache[obj].DeleteProp(name) : bimcache.Delete(obj)) })
	descobj := {}, baseobj := ObjPtr(obj.Base)
	for MIT in ['call', 'set', 'get']
		if desc.HasOwnProp(MIT) {
			t := desc.%MIT%
			MinParams := ParamCount := OutputVars := MID := 0, BIM := t.BIM
			for k in ['MinParams', 'ParamCount', 'OutputVars', 'MID']
				if t.HasOwnProp(k)
					%k% := t.%k%
			descobj.%MIT% := BuiltInMethod(baseobj, BIM, MIT, MinParams, ParamCount, OutputVars, MID)
		}
	obj.DefineProp(name, descobj), pobj := ObjPtr(obj)
	cache := bimcache.Has(pobj) ? bimcache[pobj] : (bimcache[pobj] := {})
	cache.%name% := descobj
	BuiltInMethod(pobj, BIM, MIT, MinParams, ParamCount, OutputVars, MID) {
		static pCall := ObjPtr({}.OwnProps), size := 9 * A_PtrSize + 16
		nameoffset := 3 * A_PtrSize + 8, IsVariadic := ParamCount == 255
		sbim := Buffer(OutputVars ? size + 7 : size, 0), DllCall('RtlMoveMemory', 'ptr', sbim, 'ptr', pCall, 'uint', size)
		obim := ObjFromPtr(sbim.Ptr), obim.bim := sbim
		switch MIT, false {
			case 'call':
				++MinParams, ParamCount := IsVariadic ? MinParams : Max(MinParams, ParamCount + 1)
				NumPut('ptr', StrPtr('User-BIM.Call'), sbim, nameoffset), MIT := 2
			case 'set':
				MinParams += 2, ParamCount += 2, MIT := 1
				NumPut('ptr', StrPtr('User-BIM.Set'), sbim, nameoffset)
			case 'get':
				++MinParams, ParamCount := Max(MinParams, ParamCount + 1)
				NumPut('ptr', StrPtr('User-BIM.Get'), sbim, nameoffset), MIT := 0
		}
		NumPut('uint', 1, sbim, A_PtrSize), ObjPtrAddRef(Func.Prototype)
		NumPut('int', Max(MinParams, ParamCount), 'int', MinParams, 'int', IsVariadic, sbim, 4 * A_PtrSize + 8)
		NumPut('ptr', BIM, 'ptr', pobj, 'uchar', MID, 'uchar', MIT, sbim, 6 * A_PtrSize + 16)
		if OutputVars {
			NumPut('ptr', s := sbim.Ptr + size, sbim, 5 * A_PtrSize + 16)
			loop Min(OutputVars.Length, 7)
				s := NumPut('uchar', OutputVars[A_Index], s)
		}
		return obim
	}
}