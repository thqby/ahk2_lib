/************************************************************************
 * @description Create a COM object from an unregistered DLL
 * @file ComObjDll.ahk
 * @author thqby
 * @date 2023/02/06
 * @version 0.0.7
 ***********************************************************************/


ComObjDll(dllpath := '', CLSID := '') {
	static clsids := Map(), dlls := Map(), _ := (OnExit(_exit_), clsids.CaseSense := false)
	if (CLSID = '' && SubStr(dllpath, 1, 1) = '{')
		CLSID := dllpath, dllpath := ''
	if (dllpath) {
		freedll := false
		if IsNumber(dllpath) {
			if (!dlls.Has(moduleHandle := Integer(dllpath)))
				DllCall('GetModuleFileNameW', 'Ptr', moduleHandle, 'Ptr', buf := Buffer(260), 'UInt', 260)
				, dllpath := StrGet(buf, 'UTF-16')
		} else if !(moduleHandle := DllCall('GetModuleHandle', 'Str', dllpath, 'Ptr')
			|| moduleHandle := (freedll := true, DllCall('LoadLibrary', 'Str', dllpath, 'Ptr')))
			throw Error('加载DLL失败')
		if (!dlls.Has(moduleHandle)) {
			if !(pfnDllGetClassObject := DllCall('GetProcAddress', 'Ptr', moduleHandle, 'AStr', 'DllGetClassObject', 'Ptr'))
				throw Error('当前模块无DllGetClassObject函数入口')
			dlls[moduleHandle] := {pfn: pfnDllGetClassObject, TypeLib: '', CLSID: '', free: freedll}
			if (!DllCall('oleaut32\LoadTypeLib', 'Str', dllpath, 'Ptr*', &ptlib := 0)) {
				libID := ver := tt := ''
				Loop ComCall(3, ptlib) { ; GetTypeInfoCount
					ComCall(4, ptlib, 'UInt', A_Index - 1, 'Ptr*', &ptinfo := 0) ; GetTypeInfo
					ComCall(3, ptinfo, 'Ptr*', &ptatt := 0) ; GetTypeAttr
					if (5 = typekind := NumGet(ptatt, 36 + A_PtrSize, 'UInt')) ; ptatt->typekind TKIND_COCLASS
						CLSID := CLSID || StringFromGUID2(ptatt)
					else if (typekind = 4) { ; TKIND_DISPATCH
						DispatchIID := StringFromGUID2(ptatt), oldvers := Map()
						try Loop Reg, 'HKEY_CLASSES_ROOT\TypeLib\' RegRead('HKEY_CLASSES_ROOT\Interface\' DispatchIID '\TypeLib'), 'K'
							oldvers[A_LoopRegName] := true
						DllCall('oleaut32\RegisterTypeLibForUser', 'Ptr', ptlib, 'Str', dllpath, 'Ptr', 0)
						libID := RegRead('HKEY_CLASSES_ROOT\Interface\' DispatchIID '\TypeLib')
						Loop Reg, 'HKEY_CLASSES_ROOT\TypeLib\' libID, 'K' {
							wMajorVer := A_LoopRegName
							Loop Reg, A_LoopRegKey '\' A_LoopRegName, 'K'
								if IsInteger(A_LoopRegName) {
									if (oldvers.Has(wMajorVer))
										tt := [Integer(wMajorVer), Integer(A_LoopRegName)]
									else {
										ver := [Integer(wMajorVer), Integer(A_LoopRegName)]
										break 2
									}
								}
						}
					}
					ComCall(19, ptinfo, 'Ptr', ptatt), ObjRelease(ptinfo) ; ptinfo->ReleaseTypeAttr, ptinfo->Release
				}
				if libID
					dlls[moduleHandle].TypeLib := {id: libID, ver: ver || tt}
				dlls[moduleHandle].CLSID := CLSID, ObjRelease(ptlib) ; ptlib->Release
			}
		}
	} else if !clsids.Has(CLSID)
		return ComObject(CLSID)
	if (clsids.Has(CLSID := CLSID || dlls[moduleHandle].CLSID)) {
		pFactory := clsids[CLSID] ; IClassFactory
	} else {
		DllCall('ole32\CLSIDFromString', 'Str', CLSID, 'Ptr', _CLSID := Buffer(16))
		DllCall('ole32\CLSIDFromString', 'Str', '{00000001-0000-0000-C000-000000000046}', 'Ptr', IID_IClassFactory := Buffer(16))
		if (DllCall(dlls[moduleHandle].pfn, 'Ptr', _CLSID, 'Ptr', IID_IClassFactory, 'Ptr*', &pFactory := 0, 'UInt'))
			throw Error('无效的类字符串')
	}
	DllCall('ole32\CLSIDFromString', 'Str', '{00000000-0000-0000-C000-000000000046}', 'Ptr', IID_IUnknown := Buffer(16))
	if (!ComCall(3, pFactory, 'Ptr', 0, 'Ptr', IID_IUnknown, 'Ptr*', &pdisp := 0)) ; pFactory->CreateInstance
		return (clsids[CLSID] := pFactory, ComValue(9, pdisp)) ; IDispatch comobj
	throw Error('创建 COM 对象失败')
	_exit_(*) { ; unregister type library where script exit
		for _, dll in dlls
			if ((tinfo := dll.TypeLib) && !DllCall('ole32\CLSIDFromString', 'Str', tinfo.id, 'Ptr', _libID := Buffer(16)) && tinfo.ver)
				ret:=DllCall('oleaut32\UnRegisterTypeLibForUser', 'Ptr', _libID, 'UInt', tinfo.ver[1], 'UInt', tinfo.ver[2], 'UInt', 0, 'UInt', 1)
		for _, p in clsids
			ObjRelease(p)
	}
	StringFromGUID2(guid) {
		DllCall('ole32\StringFromGUID2', 'Ptr', guid, 'Str', str := '                                        ', 'int', 40)
		return str
	}
}