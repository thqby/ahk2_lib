#Include '..\XCGUI.ahk'
DllCall('LoadLibrary', 'str', '..\' (A_PtrSize * 8) 'bit\xcgui.dll')
XC.InitXCGUI()
m_hWindow := CXWindow(0, 0, 300, 200, "炫彩界面库窗口")
CXButton(10, 5, 60, 20, "关闭", m_hWindow).SetType(XC.TYPE_EX.button_close)
m_hButton := CXButton(100, 50, 60, 25, "Button", m_hWindow)
m_hButton.RegEventC(XC.eleEvents.BNCLICK, CallbackCreate(OnBtnClick))
m_hWindow.ShowWindow(5)
XC.RunXCGUI()
XC.ExitXCGUI()

OnBtnClick(pbHandled)
{
  MsgBox '你点击了按钮', '提示'
  return
}