;@Ahk2Exe-AddResource LoadScript.ahk, LOADSCRIPT
class LoadScript {
	/**
	 * 加载脚本文件或脚本代码作为子进程并返回一个对象，该对象可用于调用函数或获取/设置全局变量.
	 * 
	 * @param pathorcode 脚本路径或脚本代码.
	 * @param exe AutoHotkey可执行文件的路径 (默认为A_AhkPath).
	 * @param noTrayIcon 隐藏子进程托盘图标.
	 */
	static Call(pathorcode, exe := A_AhkPath, noTrayIcon := true) {
		ObjRegisterActive(client := { _parent: LoadScript.Proxy() }, guid := CreateGUID())
		exec := ComObject('WScript.Shell').Exec(Format('"{}" /script /CP{} /ErrorStdOut *', exe, DllCall('GetACP', 'uint')))
		exec.StdIn.Write(Format('
		(
			LoadScript.Serve('{}')
			#Include {}
			#Warn All, Off
			{}
			{}
		)', guid, A_IsCompiled ? '*LOADSCRIPT' : A_LineFile, noTrayIcon ? '#NoTrayIcon' : '',
			FileExist(pathorcode) ? '#include ' pathorcode '`nA_ScriptName := "' pathorcode '"' : pathorcode))
		exec.StdIn.Close()
		status := exec.Status, t := A_TickCount
		while (!status && !client.HasOwnProp('_proxy') && A_TickCount - t < 500)
			Sleep(10)
		if client.HasOwnProp('_proxy')
			return (ObjRegisterActive(client, ''), client._proxy)
		if status || !ProcessExist(exec.ProcessID) {
			err := exec.StdErr.ReadAll(), ex := Error('Failed to load file', -1)
			if RegExMatch(err, 's)(.*?) \((\d+)\) : ==> (.*?)(?:\s*Specifically: (.*?))?\R?$', &m)
				ex.Message .= '`n`nReason:`t' m[3] '`nLine text:`t' m[4] '`nFile:`t' m[1] '`nLine:`t' m[2]
			else ex.Message .= '`n`n' err
		} else ex := TimeoutError('Timeout', -1)
		Throw ex

		ObjRegisterActive(obj, CLSID := '', Flags := 0) {
			static cookieJar := Map()
			if (!CLSID) {
				if (cookieJar.Has(obj))
					DllCall('oleaut32\RevokeActiveObject', 'uint', cookieJar.Delete(obj), 'Ptr', 0)
				return
			}
			if cookieJar.Has(obj)
				Throw Error('object is already registered', -1)
			if (hr := DllCall('ole32\CLSIDFromString', 'wstr', CLSID, 'Ptr', _clsid := Buffer(16))) < 0
				Throw Error('Invalid CLSID', -1, CLSID)
			hr := DllCall('oleaut32\RegisterActiveObject', 'Ptr', ObjPtr(obj), 'Ptr', _clsid, 'uint', Flags, 'uint*', &cookie := 0, 'uint')
			if hr < 0
				Throw Error(Format('Error 0x{:x}', hr), -1)
			cookieJar[obj] := cookie
		}
		CreateGUID() {
			if !(DllCall('ole32.dll\CoCreateGuid', 'ptr', pguid := Buffer(16))) {
				VarSetStrCapacity(&sguid, 80)
				if (DllCall('ole32.dll\StringFromGUID2', 'ptr', pguid, 'str', sguid, 'int', 80))
					return sguid
			}
		}
	}
	static Serve(guid) {
		try {
			client := ComObjActive(guid)
			global parent_process := client._parent
			client._proxy := LoadScript.Proxy().DefineProp('__Delete', { call: _ => ExitApp() })
			Persistent()
		} catch Error as ex {
			stderr := FileOpen('**', 'w')
			stderr.Write(Format('{} ({}) : ==> {}`n     Specifically: {}', ex.File, ex.Line, ex.Message, ex.Extra))
			stderr.Close()
			ExitApp
		}
	}
	class Proxy {
		__Call(name, args) => %name%(args*)
		__Get(Key, Params) => Params.Length ? %Key%[Params*] : %Key%
		__Set(Key, Params, Value) {
			global
			if Params.Length
				%Key%[Params*] := Value
			else %Key% := Value
		}
	}
}
