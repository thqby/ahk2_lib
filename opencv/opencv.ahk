/************************************************************************
 * @description [ahk binding for opencv](https://github.com/thqby/opencv_ahk)
 * [opencv_world*.dll](https://github.com/opencv/opencv/releases)
 * @tutorial https://docs.opencv.org/4.x/index.html
 * @author thqby
 * @date 2024/03/14
 * @version 0.0.1
 ***********************************************************************/

; opencv namespace
class cv {
	static __New() {
		try api := DllCall(A_AhkPath '\ahkGetApi', 'cdecl ptr')
		catch {
			for k in ['AutoHotkey64.dll', 'AutoHotkey.dll']
				if (mod := DllCall('LoadLibrary', 'str', k, 'ptr')) && (ads := DllCall('GetProcAddress', 'ptr', mod, 'astr', 'ahkGetApi', 'ptr')) && (api := DllCall(ads, 'cdecl ptr'))
					break
			if (!api)
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
		for k in ['Prototype', '__Init', '__New']
			this.DeleteProp(k)
		this.DefineProp('__Delete', {Call: (self) => NumPut('ptr', NumGet(ObjPtr({}), 'ptr'), ObjPtr(self))})
		this.Base := Object.Prototype, NumPut('ptr', NumGet(__, 'ptr'), ObjPtr(this))
		for k, v in _.DeleteProp('constants').OwnProps()
			cv2.%k% := v
		for k, v in _.OwnProps()
			this.DefineProp(k, {value: v})
	}
}

; opencv constants namespace
class cv2 {
	static __New() => (cv, 0)
}