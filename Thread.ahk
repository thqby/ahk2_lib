class Thread
{
	Ptr := 0, pfunc := 0
	__New(funcobj, paramsobj, initflag := 0) {
		this.pfunc := pfunc := CallbackCreate(funcobj)
		if (!this.Ptr := DllCall("msvcrt\_beginthreadex", "Ptr", 0, "UInt", 0, "Ptr", pfunc, "Ptr", ObjPtrAddRef(paramsobj), "UInt", initflag, "UInt*", threadid := 0))
			throw Error("create thread fail")
		this.threadid := threadid
	}

	__Delete() => (CallbackFree(this.pfunc), (this.ExitCode = 259) ? this.Terminate() : "", (this.Ptr ? DllCall("Kernel32\CloseHandle", "Ptr", this) : 0))
	Terminate(dwExitCode := 1) => (DllCall("Kernel32\TerminateThread", "Ptr", this, "UInt", dwExitCode))
	ExitCode => (DllCall("Kernel32\GetExitCodeThread", "Ptr", this, "UInt*", Code := 0) ? Code : 0)
}