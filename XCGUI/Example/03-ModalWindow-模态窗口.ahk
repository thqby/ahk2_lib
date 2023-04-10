; by 布谷布谷
#Include '..\XCGUI.ahk'
DllCall('LoadLibrary', 'str', '..\' (A_PtrSize * 8) 'bit\xcgui.dll')
XC.InitXCGUI()
m_hWindow := CXWindow(100, 100, 400, 300, "炫彩界面库窗口")
CXButton(5, 3, 60, 20, "关闭", m_hWindow).SetType(XC.TYPE_EX.button_close)
m_hButton := CXButton(20, 50, 120, 20, "popup-modalWindow", m_hWindow)
m_hButton.RegEventC(XC.eleEvents.BNCLICK, CallbackCreate(OnBtnClick))
m_hWindow.ShowWindow(SW_SHOW := 5)
XC.RunXCGUI()
XC.ExitXCGUI()

OnBtnClick(pbHandled){
	m_hWindowModal := CXModalWindow( 200, 200, "炫彩界面库窗口", m_hWindow.GetHWND())
	CXButton(5, 3, 60, 20, "关闭", m_hWindowModal).SetType(XC.TYPE_EX.button_close)
	nResult := m_hWindowModal.DoModal()
	MsgBox "Exit modal " nResult
}