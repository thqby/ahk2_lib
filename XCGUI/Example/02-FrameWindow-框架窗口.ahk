#Include '..\XCGUI.ahk'

XC.InitXCGUI()
hWindow := CXFrameWindow(0, 0, 600, 400, "炫彩界面库窗口", 0, XC.window_style.Default)
CXButton(8, 3, 50, 24, "关闭", hWindow).SetType(XC.TYPE_EX.button_close)
hPane1 := CXPane("窗格1", 200, 200, hWindow)
hPane2 := CXPane("窗格2", 200, 200, hWindow)
hPane3 := CXPane("窗格3", 200, 200, hWindow)
hWindow.AddPane(0, hPane1, XC.pane_align.left)
hWindow.AddPane(0, hPane3, XC.pane_align.right)
hWindow.MergePane(hPane1, hPane2)
; hWindow.SetView(CXEle(0, 0, 100, 100, hWindow))
hWindow.RegEventC(WM_RBUTTONUP := 0x0205, CallbackCreate(OnWndRButtonUp))
hWindow.RegEventC(XC.WM_MENU_SELECT, CallbackCreate(OnWndMenuSelect))
hWindow.AdjustLayout()
; hWindow.RegEventC(WM_DESTROY := 0x0002, CallbackCreate(OnDestroy))
hWindow.ShowWindow(5)
XC.RunXCGUI()
XC.ExitXCGUI()

OnWndRButtonUp(nFlags, pPt, pbHandled)
{
	hMenu := CXMenu()
	hMenu.AddItem(201, '窗格1')
	hMenu.AddItem(202, '窗格2')
	hMenu.AddItem(203, '窗格3')
	pp := {base: XC.POINT.Prototype, ptr: pPt}
	pt := XC.POINT(pp.x, pp.y)
	hwnd := hWindow.GetHWND()
	r := DllCall("user32\ClientToScreen", "Ptr", hwnd, "ptr", pt.ptr, "Int")
	x := pt.x, y := pt.y
	hMenu.Popup(hWindow.GetHWND(), x, y)
}
OnWndMenuSelect(nID, pbHandled)
{
	switch nID
	{
		case 201:
			if (hPane1.IsShowPane())
				hPane1.HidePane()
			else
				hPane1.ShowPane()
		case 202:
			if (hPane2.IsShowPane())
				hPane2.HidePane()
			else
				hPane2.ShowPane()
		case 203:
			if (hPane3.IsShowPane())
				hPane3.HidePane()
			else
				hPane3.ShowPane()
	}
	hWindow.AdjustLayout()
	hWindow.RedrawWnd(true)
}