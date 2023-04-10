## WebView2

The Microsoft Edge WebView2 control enables you to host web content in your application using Microsoft Edge (Chromium) as the rendering engine. For more information, see Overview of [Microsoft Edge WebView2](https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/?view=webview2-1.0.674-prerelease) and Getting Started with WebView2.

The WebView2 Runtime is built into Win10(latest version) and Win11 and can be easily used in AHK.

#### Example1: AddHostObjectToEdge, Open with multiple windows
```autohotkey
#Include <WebView2\WebView2>

main := Gui('+Resize')
main.OnEvent('Close', (*) => (wvc := wv := 0))
main.Show(Format('w{} h{}', A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))

wvc := WebView2.create(main.Hwnd)
wv := wvc.CoreWebView2
wv.Navigate('https://autohotkey.com')
wv.AddHostObjectToScript('ahk', {str:'str from ahk',func:MsgBox})
wv.OpenDevToolsWindow()
```

Run code in Edge DevTools
```javascript
obj = await window.chrome.webview.hostObjects.ahk;
obj.func('call from edge\n' + (await obj.str));
```

#### Example2: Open with only one Tab
```autohotkey
#Include <WebView2\WebView2>

main := Gui("+Resize")
main.OnEvent("Close", ExitApp)
main.Show(Format("w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))

wvc := WebView2.create(main.Hwnd)
wv := wvc.CoreWebView2
nwr := wv.NewWindowRequested(NewWindowRequestedHandler)
wv.Navigate('https://autohotkey.com')

NewWindowRequestedHandler(handler, wv2, arg) {
	argp := WebView2.NewWindowRequestedEventArgs(arg)
	deferral := argp.GetDeferral()
	argp.NewWindow := wv2
	deferral.Complete()
}
```

#### Example3: Open with multiple Tabs in a window
```autohotkey
#Include <WebView2\WebView2>

main := Gui("+Resize"), main.MarginX := main.MarginY := 0
main.OnEvent("Close", _exit_)
main.OnEvent('Size', gui_size)
tab := main.AddTab2(Format("w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6), ['tab1'])
tab.UseTab(1), tabs := []
tabs.Push(ctl := main.AddText('x0 y25 w' (A_ScreenWidth * 0.6) ' h' (A_ScreenHeight * 0.6)))
tab.UseTab()
main.Show()
ctl.wvc := wvc := WebView2.create(ctl.Hwnd)
wv := wvc.CoreWebView2
ctl.nwr := wv.NewWindowRequested(NewWindowRequestedHandler)
wv.Navigate('https://autohotkey.com')

gui_size(GuiObj, MinMax, Width, Height) {
	if (MinMax != -1) {
		tab.Move(, , Width, Height)
		for t in tabs {
			t.move(, , Width, Height - 23)
			try t.wvc.Fill()
		}
	}
}

NewWindowRequestedHandler(handler, wv2, arg) {
	argp := WebView2.NewWindowRequestedEventArgs(arg)
	deferral := argp.GetDeferral()
	tab.Add(['tab' (i := tabs.Length + 1)])
	tab.UseTab(i), tab.Choose(i)
	main.GetClientPos(,,&w,&h)
	tabs.Push(ctl := main.AddText('x0 y25 w' w ' h' (h - 25)))
	tab.UseTab()
	ctl.wvc := WebView2.create(ctl.Hwnd, ControllerCompleted_Invoke, WebView2.Core(wv2).Environment)
	return 0
	ControllerCompleted_Invoke(wvc) {
		argp.NewWindow := wv := wvc.CoreWebView2
		ctl.nwr := wv.NewWindowRequested(NewWindowRequestedHandler)
		deferral.Complete()
	}
}

_exit_(*) {
	for t in tabs
		t.wvc := t.nwr := 0
	ExitApp()
}
```

#### Example4: PrintToPDF
```
#Include <WebView2\WebView2>

g := Gui()
g.Show('w800 h600')
wvc := WebView2.create(g.Hwnd)
wv := wvc.CoreWebView2
wv.Navigate('https://autohotkey.com')
MsgBox('Wait for loading to complete')
set := wv.Environment.CreatePrintSettings()
set.Orientation := WebView2.PRINT_ORIENTATION.LANDSCAPE
wv.PrintToPdf(A_ScriptDir '\11.pdf', set, WebView2.Handler(handler))

handler(handlerptr, result, success) {
	if (!success)
		MsgBox 'PrintToPdf fail`nerr: ' result
}
```