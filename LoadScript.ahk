class LoadScript {
	/**
	 * 加载脚本文件或脚本代码作为子进程并返回一个对象，该对象可用于调用函数或获取/设置全局变量.
	 * 
	 * @param pathorcode 脚本路径或脚本代码.
	 * @param exe AutoHotkey可执行文件的路径 (默认为A_AhkPath).
	 * @param noTrayIcon 隐藏子进程托盘图标.
	 */
	static Call(pathorcode, exe := "", noTrayIcon := true) {
		ObjRegisterActive(client := {}, guid := CreateGUID())
		try {
			client._parent := LoadScript.Proxy()
			exe := '"' (exe = "" ? A_AhkPath : exe) '"'
			exec := ComObject("WScript.Shell").Exec(exe " /ErrorStdOut *")
			exec.StdIn.Write(Format("
			(
				LoadScript.Serve("{}")
				#include {}
				{}
				{}
			)", guid, A_LineFile, noTrayIcon ? "#NoTrayIcon" : "", FileExist(pathorcode) ? "#include " pathorcode "`nA_ScriptName := '" pathorcode "'" : pathorcode))
			exec.StdIn.Close()
			if exec.Status != 0 {
				err := exec.StdErr.ReadAll()
				ex := Error("Failed to load file", -1)
				if RegExMatch(err, "s)(.*?) \((\d+)\) : ==> (.*?)(?:\s*Specifically: (.*?))?\R?$", &m)
					ex.Message .= "`n`nReason:`t" m[3] "`nLine text:`t" m[4] "`nFile:`t" m[1] "`nLine:`t" m[2]
				throw ex
			} else
				while (!client.HasOwnProp("_proxy"))
					Sleep 10
		}
		ObjRegisterActive(client, "")
		return client._proxy

		ObjRegisterActive(obj, CLSID := "", Flags := 0) {
			static cookieJar := Map()
			if (!CLSID) {
				if (cookieJar.Has(obj))
					DllCall("oleaut32\RevokeActiveObject", "uint", cookieJar.Delete(obj), "Ptr", 0)
				return
			}
			if cookieJar.Has(obj)
				throw Error("object is already registered", -1)
			if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "Ptr", _clsid := Buffer(16))) < 0
				throw Error("Invalid CLSID", -1, CLSID)
			hr := DllCall("oleaut32\RegisterActiveObject", "Ptr", ObjPtr(obj), "Ptr", _clsid, "uint", Flags, "uint*", &cookie := 0, "uint")
			if hr < 0
				throw Error(Format("Error 0x{:x}", hr), -1)
			cookieJar[obj] := cookie
		}
		CreateGUID() {
			if !(DllCall("ole32.dll\CoCreateGuid", "ptr", pguid := Buffer(16))) {
				VarSetStrCapacity(&sguid, 80)
				if (DllCall("ole32.dll\StringFromGUID2", "ptr", pguid, "str", sguid, "int", 80))
					return sguid
			}
		}
	}
	static Serve(guid) {
		try {
			client := ComObjActive(guid)
			global parent_process := client._parent
			client._proxy := LoadScript.Proxy()
			client := ""
			Persistent()
		} catch Error as ex {
			stderr := FileOpen("**", "w")
			stderr.Write(format("{} ({}) : ==> {}`n     Specifically: {}", ex.File, ex.Line, ex.Message, ex.Extra))
			stderr.Close()
			ExitApp
		}
	}
	class Proxy {
		__Call(name, args) {
			try return %name%(args*)
		}
		__Item[name := ""] {
			get {
				if (name)
					try return %name%
			}
			set {
				global
				try %name% := value
			}
		}
		__Delete() {
			if (IsSet(parent_process))
				ExitApp()
		}
	}
}