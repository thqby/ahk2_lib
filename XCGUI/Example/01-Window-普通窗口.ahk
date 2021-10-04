#Include '..\XCGUI.ahk'
DllCall('LoadLibrary', 'str', '..\' (A_PtrSize * 8) 'bit\xcgui.dll')

XC.InitXCGUI()
hWindow := CXWindow.Create(0, 0, 600, 400, "炫彩界面库")
hBut := CXButton(10, 5, 60, 20, "关闭", hWindow.ptr)
a := hBut.SetType(3)
a := hWindow.RegEventC(2, CallbackCreate(OnDestroy))
hWindow.ShowWindow(5)
XC.RunXCGUI()
XC.ExitXCGUI()

OnDestroy(pbHandled)
{
	MsgBox A_ThisFunc
}
