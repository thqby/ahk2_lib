/************************************************************************
 * @description [ahk binding for opencv](https://github.com/thqby/opencv_ahk)
 * [opencv_world*.dll](https://github.com/opencv/opencv/releases)
 * @tutorial https://docs.opencv.org/4.x/index.html
 * @author thqby
 * @date 2025/09/21
 * @version 0.0.2
 ***********************************************************************/

; opencv namespace
class cv {
	;@lint-disable class-non-dynamic-member-check
	static __New() {
		this.DeleteProp('__New')
		try api := DllCall(A_AhkPath '\ahkGetApi', 'cdecl ptr')
		catch {
			for k in ['AutoHotkey64.dll', 'AutoHotkey.dll']
				if (mod := DllCall('LoadLibrary', 'str', k, 'ptr')) && (ads := DllCall('GetProcAddress', 'ptr', mod, 'astr', 'ahkGetApi', 'ptr')) && (api := DllCall(ads, 'cdecl ptr'))
					break
			if !IsSet(api) || !api
				throw Error('Unable to initialize the OpenCV module')
		}
		dllpath := ''
		loop files A_LineFile '\..\opencv*_ahk' SubStr(A_AhkVersion, 1, 3) '.dll'
			dllpath := A_LoopFileFullPath
		if !DllCall('LoadLibraryEx', 'str', dllpath, 'ptr', 0, 'uint', 8, 'ptr')
			throw OSError()
		SplitPath(dllpath, &dllname)
		if !__ := DllCall(dllname '\opencv_init', 'ptr', api, 'cdecl ptr')
			return
		_ := ObjFromPtr(__)
		for v in [cv, cv2]
			for k in ['Prototype', '__Init', '__New']
				v.DeleteProp(k)
		static revoked := (OnExit((*) => !{ __Delete: t => NumPut('ptr', NumGet(ObjPtr(t), 'ptr'), ObjPtr(cv)) }))
		this.Base := Object.Prototype, NumPut('ptr', NumGet(__, 'ptr'), ObjPtr(this))
		for k, v in _.DeleteProp('constants').OwnProps()
			cv2.%k% := v
		for k, v in _.OwnProps()
			this.DefineProp(k, { value: v })
	}
	class TextDraw {
		__New(font?, fontSize := 24, weight := 0, italic := false, underline := false) => 0
		hDC => 0
		/** @returns {Array} */
		getTextSize(text) => 0
		putText(img, text, point, color, bottomLeftOrigin := false) => 0
	}
}

; opencv constants namespace
class cv2 {
	;@lint-disable class-non-dynamic-member-check
	static __New() => (cv, 0)
}