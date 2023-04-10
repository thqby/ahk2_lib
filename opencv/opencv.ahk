#DllLoad opencv_ahk.dll

; opencv namespace, using opencv_world455
class cv {
	static __New() {
		try api := DllCall(A_AhkPath '\ahkGetApi', 'cdecl ptr')
		catch {
			for k in ['AutoHotkey64.dll', 'AutoHotkey.dll']
				if (mod := DllCall('LoadLibrary', 'str', k, 'ptr')) && (ads := DllCall('GetProcAddress', 'ptr', mod, 'astr', 'ahkGetApi', 'ptr')) && (api := DllCall(ads, 'cdecl ptr'))
					break
			if (!api)
				throw 'Unable to initialize the OpenCV module'
		}
		_ := ObjFromPtr(__ := DllCall('opencv_ahk\opencv_init', 'ptr', api, 'cdecl ptr'))
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