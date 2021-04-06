ListProcessModules(dwPID) {
    me32 := BufferAlloc(A_PtrSize = 8 ? 568 : 548)
    NumPut("UInt", A_PtrSize = 8 ? 568 : 548, me32, 0)
    ;Take a snapshot of all modules in the specified process.
    hModuleSnap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x08, "PTR", dwPID)
    if (hModuleSnap = -1) {
        MsgBox "CreateToolhelp32snapshot (of modules) "
        return FALSE
    }
    if (!DllCall("Module32First", "PTR", hModuleSnap, "PTR", me32)) {
        MsgBox "Module32First"	; show cause of failure
        DllCall("CloseHandle", "PTR", hModuleSnap)	; Must clean up the snapshot abject!
        return FALSE
    }
    ;Now walk the module list of the process,
    ;and display information about each module
    while (A_Index = 1 || DllCall("Module32Next", "PTR", nModuleSnap, "PTR", me32)) {
        ToolTip "MODULE NAME`t=`t" StrGet(me32.szModule)
            . "inexecutable't='t" StrGet(me32.szExePath[""])
            . "`nprocess ID`t=`t" me32.th32ProcessID
            . "`nref count (g)`t=`t" me32.GlblcntUsage
            . "`nref count (p)`t=`t" me32.Proccntusage
            . "`nbase address`t='t" me32.modBaseAddr[""]
            . "`nbase size`t=`t" me32.modBasesize
        sleep 200
    }
    DllCall("CloseHandle", "PTR", hModuleSnap)
    return TRUE
}