# WebView2

The Microsoft Edge WebView2 control enables you to host web content in your application using Microsoft Edge (Chromium) as the rendering engine. For more information, see Overview of [Microsoft Edge WebView2](https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/) and Getting Started with WebView2.

The WebView2 Runtime is built into Win10(latest version) and Win11 and can be easily used in AHK.

## api conversion
- The Asynchronous method will have the `Async` suffix, such as `ExecuteScriptAsync`, and return the [Promise](https://github.com/thqby/ahk2_lib/blob/master/Promise.ahk) after the call.
- The `add_event` method accepts an ahk callable object with two minimum parameters, and it has a method named `event`, which returns the object and cancels the registration event after the object is destructed.

## Example1: AddHostObjectToEdge, Open with multiple windows
```autohotkey
#Include <WebView2\WebView2>

main := Gui()
main.OnEvent('Close', (*) => (wvc := wv := 0))
main.Show(Format('w{} h{}', A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))

wvc := WebView2.CreateControllerAsync(main.Hwnd).await2()
wv := wvc.CoreWebView2
wv.Navigate('https://autohotkey.com')
wv.AddHostObjectToScript('ahk', {str:'str from ahk',func:MsgBox})
wv.OpenDevToolsWindow()
```

Run code in Edge DevTools
```javascript
obj = await window.chrome.webview.hostObjects.ahk;
obj.func('call from edge\n' + (await obj.str));
obj = window.chrome.webview.hostObjects.sync.ahk;
obj.func('call from edge\n' + obj.str);
```

## Example2: Open with only one Tab
```autohotkey
#Include <WebView2\WebView2>

main := Gui()
main.OnEvent('Close', (*) => ExitApp())
main.Show(Format('w{} h{}', A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))

wvc := WebView2.CreateControllerAsync(main.Hwnd).await2()
wv := wvc.CoreWebView2
nwr := wv.NewWindowRequested(NewWindowRequestedHandler)
wv.Navigate('https://autohotkey.com')

NewWindowRequestedHandler(wv2, arg) {
	deferral := arg.GetDeferral()
	arg.NewWindow := wv2
	deferral.Complete()
}
```

## Example3: Open with multiple Tabs in a window
```autohotkey
#Include <WebView2\WebView2>

main := Gui('+Resize'), main.MarginX := main.MarginY := 0
main.OnEvent('Close', _exit_)
main.OnEvent('Size', gui_size)
tab := main.AddTab2(Format('w{} h{}', A_ScreenWidth * 0.6, A_ScreenHeight * 0.6), ['tab1'])
tab.UseTab(1), tabs := []
tabs.Push(ctl := main.AddText('x0 y25 w' (A_ScreenWidth * 0.6) ' h' (A_ScreenHeight * 0.6)))
tab.UseTab()
main.Show()
ctl.wvc := wvc := WebView2.CreateControllerAsync(ctl.Hwnd).await2()
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

NewWindowRequestedHandler(wv2, arg) {
	deferral := arg.GetDeferral()
	tab.Add(['tab' (i := tabs.Length + 1)])
	tab.UseTab(i), tab.Choose(i)
	main.GetClientPos(, , &w, &h)
	tabs.Push(ctl := main.AddText('x0 y25 w' w ' h' (h - 25)))
	tab.UseTab()
	wv2.Environment.CreateCoreWebView2ControllerAsync(ctl.Hwnd).then(ControllerCompleted)
	ControllerCompleted(wvc) {
		ctl.wvc := wvc
		arg.NewWindow := wv := wvc.CoreWebView2
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

## Example4: PrintToPDF
```
#Include <WebView2\WebView2>

main := Gui()
main.Show('w800 h600')
wvc := WebView2.CreateControllerAsync(main.Hwnd).await2()
wv := wvc.CoreWebView2
wv.Navigate('https://autohotkey.com')
MsgBox('Wait for loading to complete')
PrintToPdf(wv, A_ScriptDir '\11.pdf')

PrintToPdf(wv, path) {
	set := wv.Environment.CreatePrintSettings()
	set.Orientation := WebView2.PRINT_ORIENTATION.LANDSCAPE
	waitting := true, t := A_TickCount
	try {
		wv.PrintToPdfAsync(A_ScriptDir '\11.pdf', set).await2(5000)
		Run(A_ScriptDir '\11.pdf')
		MsgBox('PrintToPdf complete')
	} catch TimeoutError
		MsgBox('PrintToPdf timeout')
}
```