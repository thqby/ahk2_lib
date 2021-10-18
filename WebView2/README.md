## WebView2

The Microsoft Edge WebView2 control enables you to host web content in your application using Microsoft Edge (Chromium) as the rendering engine. For more information, see Overview of [Microsoft Edge WebView2](https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/?view=webview2-1.0.674-prerelease) and Getting Started with WebView2.

The WebView2 Runtime is built into Win10(latest version) and Win11 and can be easily used in AHK.

#### Example1: AddHostObjectToEdge
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

#### Example2: With only one Tab
```autohotkey
#Include <WebView2\WebView2>

main := Gui("+Resize")
main.OnEvent("Close", ExitApp)
main.Show(Format("w{} h{}", A_ScreenWidth * 0.6, A_ScreenHeight * 0.6))

wvc := WebView2.create(main.Hwnd)
wv := wvc.CoreWebView2
wv.NewWindowRequested(NewWindowRequestedHandler)
wv.Navigate('https://autohotkey.com')

NewWindowRequestedHandler(handler, wv2, arg) {
	argp := WebView2.NewWindowRequestedEventArgs(arg)
	deferral := argp.GetDeferral()
	argp.NewWindow := wv2
	deferral.Complete()
}
```