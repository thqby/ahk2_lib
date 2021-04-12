ComObjDll(dllpath := '', CLSID := '') {
	static clsids := Map(), dlls := Map(), __delete := {}, _ := (__delete.DefineMethod('__Delete', Func('_exit_')), clsids.CaseSense := false)
	if (CLSID = '' && SubStr(dllpath, 1, 1) = '{')
		CLSID := dllpath, dllpath := ''
	if (dllpath) {
		freedll := false
		if IsNumber(dllpath) {
			if (!dlls.Has(moduleHandle := Integer(dllpath)))
				DllCall('GetModuleFileNameW', 'Ptr', moduleHandle, 'Ptr', buf := BufferAlloc(260), 'UInt', 260)
				, dllpath := StrGet(buf, 'UTF-16')
		} else if !(moduleHandle := DllCall('GetModuleHandle', 'Str', dllpath, 'Ptr')
			|| moduleHandle := (freedll := true, DllCall('LoadLibrary', 'Str', dllpath, 'Ptr')))
			throw Exception('加载DLL失败')
		if (!dlls.Has(moduleHandle)) {
			if !(pfnDllGetClassObject := DllCall('GetProcAddress', 'Ptr', moduleHandle, 'AStr', 'DllGetClassObject', 'Ptr'))
				throw Exception('当前模块无DllGetClassObject函数入口')
			dlls[moduleHandle] := {pfn: pfnDllGetClassObject, TypeLib: '', CLSID: '', free: freedll}
			if (!DllCall('oleaut32\LoadTypeLib', 'Str', dllpath, 'Ptr*', &ptlib := 0)) {
				libID := ver := tt := ''
				Loop ComCall(3, ptlib) { ; GetTypeInfoCount
					ComCall(4, ptlib, 'UInt', A_Index - 1, 'Ptr*', &ptinfo := 0) ; GetTypeInfo
					ComCall(3, ptinfo, 'Ptr*', &ptatt := 0) ; GetTypeAttr
					if (5 = typekind := NumGet(ptatt, 36 + A_PtrSize, 'UInt')) ; ptatt->typekind TKIND_COCLASS
						CLSID := CLSID || (DllCall('ole32\StringFromCLSID', 'Ptr', ptatt, 'Str*', &GUID := ''), GUID)
					else if (typekind = 4) { ; TKIND_DISPATCH
						DllCall('ole32\StringFromCLSID', 'Ptr', ptatt, 'Str*', &DispatchIID := ''), oldvers := Map()
						try Loop Reg, 'HKEY_CLASSES_ROOT\TypeLib\' RegRead('HKEY_CLASSES_ROOT\Interface\' DispatchIID '\TypeLib'), 'K'
							oldvers[A_LoopRegName] := true
						DllCall('oleaut32\RegisterTypeLibForUser', 'Ptr', ptlib, 'Str', dllpath, 'Ptr', 0)
						libID := RegRead('HKEY_CLASSES_ROOT\Interface\' DispatchIID '\TypeLib')
						loopreg:
						Loop Reg, 'HKEY_CLASSES_ROOT\TypeLib\' libID, 'K' {
							wMajorVer := A_LoopRegName
							Loop Reg, A_LoopRegKey '\' A_LoopRegName, 'K'
								if IsInteger(A_LoopRegName) {
									if (oldvers.Has(wMajorVer))
										tt := [Integer(wMajorVer), Integer(A_LoopRegName)]
									else {
										ver := [Integer(wMajorVer), Integer(A_LoopRegName)]
										break loopreg
									}
								}
						}
					}
					ComCall(19, ptinfo, 'Ptr', ptatt), ObjRelease(ptinfo) ; ptinfo->ReleaseTypeAttr, ptinfo->Release
				}
				dlls[moduleHandle].TypeLib := {id: libID, ver: ver || tt}, dlls[moduleHandle].CLSID := CLSID, ObjRelease(ptlib) ; ptlib->Release
			}
		}
	} else if !clsids.Has(CLSID)
		return ComObjCreate(CLSID)
	if (clsids.Has(CLSID := CLSID || dlls[moduleHandle].CLSID)) {
		pFactory := clsids[CLSID] ; IClassFactory
	} else {
		DllCall('ole32\CLSIDFromString', 'Str', CLSID, 'Ptr', _CLSID := BufferAlloc(16))
		DllCall('ole32\CLSIDFromString', 'Str', '{00000001-0000-0000-C000-000000000046}', 'Ptr', IID_IClassFactory := BufferAlloc(16))
		if (DllCall(dlls[moduleHandle].pfn, 'Ptr', _CLSID, 'Ptr', IID_IClassFactory, 'Ptr*', &pFactory := 0, 'UInt'))
			throw Exception('无效的类字符串')
		ObjRelease(pFactory)
	}
	DllCall('ole32\CLSIDFromString', 'Str', '{00000000-0000-0000-C000-000000000046}', 'Ptr', IID_IUnknown := BufferAlloc(16))
	if (!ComCall(3, pFactory, 'Ptr', 0, 'Ptr', IID_IUnknown, 'Ptr*', &pdisp := 0)) ; pFactory->CreateInstance
		return (clsids[CLSID] := pFactory, ComObject(9, pdisp)) ; IDispatch comobj
	throw Exception('创建 COM 对象失败')
	_exit_(*) { ; unregister type library, free library where script exit
		for _, dll in dlls {
			if ((tinfo := dll.TypeLib) && !DllCall('ole32\CLSIDFromString', 'Str', tinfo.id, 'Ptr', _libID := BufferAlloc(16)) && tinfo.ver)
				ret:=DllCall('oleaut32\UnRegisterTypeLibForUser', 'Ptr', _libID, 'UInt', tinfo.ver[1], 'UInt', tinfo.ver[2], 'UInt', 0, 'UInt', 1)
			if dll.free
				DllCall('FreeLibrary', 'Ptr', _)
		}
	}
}