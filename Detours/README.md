## Detours

[Detours](https://github.com/microsoft/Detours) is a software package for monitoring and instrumenting API calls on Windows. Detours has been used by many ISVs and is also used by product teams at Microsoft. Detours is now available under a standard open source license (MIT). This simplifies licensing for programmers using Detours and allows the community to support Detours using open source tools and processes.

#### example
```autohotkey
#Include 'Detours.ahk'

DllCall('LoadLibrary', 'str', (A_PtrSize * 8) 'bit\Detours.dll')
g_Thread := DllCall('GetCurrentThread')
old_msg := DetourFindFunction('user32.dll', 'MessageBoxW')
new_msg := CallbackCreate(_msg)
r := DetourTransactionBegin()
r := DetourUpdateThread(g_Thread)
r := DetourAttach(old_msg, new_msg)
r := DetourTransactionCommit()
MsgBox('csrer')
_msg(hwnd, text, caption, opt) {
	DllCall(old_msg.value, 'ptr', 0, 'str', 'dvdftre', 'str', 'zvcrte', 'uint', 0)
}
```