/**
 * import ahk v1 library to v2. It can call v1 functions and classes, read and modify global variables.
 * 
 * - import v1 lib `v1 := import_v1lib("gdip_all.ahk", "ahkv1.exe")`
 * - create a class instance `v1["AHKv1LibHelper"].__New("classname", params)` or `v1["AHKv1LibHelper"].__New(v1["classname"], params)`
 * - call a functions `v1.funcname(params)`, *no param* `v1.funcname`
 * - set a global variable `v1.varname := "str"` or `v1["varname"] := {}`
 * - retrieve a global variable `MsgBox(v1["varname"])`
 * 
 * @param pathsorcode The paths of the include script files or ahk v1 code. `Array or String`
 * @param ahkv1runtime The path of the AutoHotkey v1 runtime (AutoHotkey.exe or AutoHotkey.dll).
 */
import_v1lib(pathsorcode, ahkv1runtime := "C:\Program Files\AutoHotkey\AutoHotkey.exe") {
	static IDispatch := Buffer(16), _ := NumPut("int64", 0x20400, "int64", 0x46000000000000c0, IDispatch)
	lresult := DllCall("oleacc\LresultFromObject", "ptr", IDispatch, "ptr", 0, "ptr", ObjPtr(client := { proxy: 0 }), "ptr")
	; free com marshal on fail
	autofree := { ptr: lresult, __Delete: (s) => DllCall("oleacc\ObjectFromLresult", "ptr", s, "ptr", IDispatch, "ptr", 0, "ptr*", ComValue(9, 0)) }
	if !FileExist(ahkv1runtime)
		throw Error("Could not find AutoHotkey v1 runtime")
	if pathsorcode is Array {
		t := pathsorcode, pathsorcode := ""
		for p in t
			pathsorcode .= "`n#include " p
	}
	v1script := Format("
	(
		#Persistent
		#NoTrayIcon
		class AHKv1LibHelper {
			__New(name, args*) {
				static _ := (VarSetCapacity(IDispatch, 16), NumPut(0x46000000000000c0, NumPut(0x20400, IDispatch, "int64"), "int64"), DllCall("oleacc\ObjectFromLresult", "ptr", {}, "ptr", &IDispatch, "ptr", 0, "ptr*", idisp := 0), ComObject(9, idisp).proxy := new AHKv1LibHelper(), ObjRelease(idisp))
				return IsObject(name) ? new name(args*) : new %name%(args*)
			}
			__Call(name, args*) {
				return %name%(args*)
			}
			__Get(name) {
				global
				return val := %name%
			}
			__Set(name, val) {
				global
				return %name% := val
			}
			__Delete() {
				SetTimer ExitApp, -1
				return
				ExitApp:
					ExitApp
			}
		}
		{}
	)", lresult, FileExist(pathsorcode) ? "#include " pathsorcode : pathsorcode)
	if ahkv1runtime ~= "i)\.dll$" {
		if !DllCall("GetModuleHandle", "str", ahkv1runtime) && !DllCall("LoadLibrary", "str", ahkv1runtime)
			throw Error("Failed to load AutoHotkey.dll")
		if !hThread := DllCall(ahkv1runtime "\ahktextdll", "str", v1script, "str", "", "str", "", "cdecl ptr")
			throw Error("Failed to load script")
		while !client.proxy
			Sleep(10)
	} else {
		exec := ComObject("WScript.Shell").Exec('"' ahkv1runtime '" /ErrorStdOut *')
		exec.StdIn.Write(v1script), exec.StdIn.Close()
		while exec.Status = 0 && !client.proxy
			Sleep(10)
		if exec.Status != 0 {
			ex := Error("Failed to load script")
			if RegExMatch(err := exec.StdErr.ReadAll(), "s)(.*?) \((\d+)\) : ==> (.*?)(?:\s*Specifically: (.*?))?\R?$", &m)
				ex.Message .= "`n`nReason:`t" m[3] "`nLine text:`t" m[4] "`nFile:`t" m[1] "`nLine:`t" m[2]
			throw ex
		}
	}
	autofree.DeleteProp("__Delete")
	return client.proxy
}
