#Requires AutoHotkey v2.0-a121
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
DllCall("User32.dll\SetProcessDpiAwarenessContext", "Ptr", 0xFFFFFFFC)	; not sure if this is needed.  Works fine without it.

main := gui("+Resize")
main.OnEvent("Close", ExitApp)

main.Show(Format("w{} h{}", A_ScreenWidth * 0.4, A_ScreenHeight * 0.6))

; need to have the size also otherwise when you un-maximize it the window has zero height and width
wv := WebView(main)
wv.create()


mainSize(controller, win, minMax, *) {
    ; for performance reasons, you should make the webview2 not visible when the parent window is minimized/hidden.
    ComCall(3, controller, "Int*", &isVisible := 0)	; IWebView2WebViewController::get_IsVisible
    if (minMax == -1) {
        if (isvisible) {
            ComCall(4, controller, "Int", false)	; IWebView2WebViewController::put_IsVisible
        }
    } else {
        if (!isVisible) {
            ComCall(4, controller, "Int", true)	; IWebView2WebViewController::put_IsVisible
        } else {
            DllCall("User32.dll\GetClientRect", "Ptr", win.hWnd, "Ptr", RECT := Buffer(16))
            ComCall(6, controller, "Ptr", RECT)	; IWebView2WebViewController::put_Bounds
        }

    }
}

class WebView {
    __new(parent, dllPath := "WebView2Loader.dll") {
        if (Type(parent) != "Gui") {
            throw Error("Parent must be of type: Gui")
        }

        this.parent := parent
        this.dllPath := A_ScriptDir '\' dllPath
        this.controllerCompletedHandler := ICoreWebView2CreateCoreWebView2ControllerCompletedHandler(this)
        this.envCompletedHandler := IWebView2CreateWebView2EnvironmentCompletedHandler(this.parent, this.controllerCompletedHandler)
    }

    OnControllerCompleted(cb) {
        this.controllerCreatedCallbacks.push(cb)
    }

    create() {
        ; DllCall('combase\CoInitializeEx', 'ptr', 0, 'uint', 2)

        ; if (R := DllCall(this.dllPath . "\CreateCoreWebView2EnvironmentWithOptions", 'wstr', 'C:\Program Files (x86)\Microsoft\EdgeWebView\Application\91.0.864.48', 'ptr', 0, 'ptr', 0, "Ptr", this.envCompletedHandler, "UInt")) {
        if (R := DllCall(this.dllPath . "\CreateCoreWebView2EnvironmentWithOptions", 'wstr', 'C:\Program Files (x86)\Microsoft\EdgeWebView\Application\91.0.864.48', 'str', 'D:\Desktop\web', 'ptr', 0, "Ptr", this.envCompletedHandler, "UInt")) {
        ; if (R := DllCall(this.dllPath . "\CreateCoreWebView2Environment", "Ptr", this.envCompletedHandler, "UInt")) {
            DllCall("FormatMessage", "uint", 0x100 | 0x1000, "ptr", 0, "uint", R, "uint", 0, "ptr*", &pstr := 0, "uint", 0, "ptr", 0)
            MsgBox("ERROR " . StrGet(pstr))
            DllCall('LocalFree', 'ptr', pstr)
        }
    }
}

class IWebView2CreateWebView2EnvironmentCompletedHandler extends IUnknown {
    __New(parent, controllerCompleted) {
        super.__new()

        this.parent := parent
        this.controllerCompleted := controllerCompleted
    }

    Invoke(thisPtr, hresult, ICoreWebView2Env) {
        ; ICoreWebView2Environment::CreateCoreWebView2Controller Method.
        ; https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/0-9-538/icorewebview2environment#createcorewebview2controller
        ComCall(3, ICoreWebView2Env, "Ptr", this.parent.hwnd, "Ptr", this.controllerCompleted)

        return 0	; S_OK.
    }
}

class ICoreWebView2CreateCoreWebView2ControllerCompletedHandler extends IUnknown {
    __new(wv) {
        super.__new()

        this.wv := wv
    }

    Invoke(thisPtr, HRESULT, IWebView2WebViewController) {
        ObjAddRef(IWebView2WebViewController)	; This was key to retain a reference to the Controller

        this.wv.parent.OnEvent("Size", mainSize.bind(IWebView2WebViewController))

        ; Resize WebView to fit the bounds of the parent window.
        ; IWebView2WebViewController::put_Bounds Method.
        ; https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/0-9-538/icorewebview2controller#put_bounds
        DllCall("User32.dll\GetClientRect", "Ptr", this.wv.parent.hWnd, "Ptr", RECT := Buffer(16))
        ComCall(6, IWebView2WebViewController, "Ptr", RECT)

        ; IWebView2WebViewController::get_CoreWebView2
        ; https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/0-9-538/icorewebview2controller#get_corewebview2
        ComCall(25, IWebView2WebViewController, "Ptr*", &coreWebView := 0)
        this.wv.coreWebView := coreWebView

        ; ICoreWebView2::add_navigationstarting
        ; https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/0-9-538/icorewebview2#add_navigationstarting
        ; not really sure what the last parameter (EventRegistrationToken) is for but passing an empty buffer makes it work
        ComCall(7, this.wv.coreWebView, "Ptr", ICoreWebView2NavigationStartingEventHandler(), "Ptr", token := Buffer(8))

        ; ICoreWebView2::Navigate
        ; https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/0-9-538/icorewebview2#navigate
        ; ComCall(5, this.wv.coreWebView, "Str", "https://getbootstrap.com/")
        ComCall(5, this.wv.coreWebView, "Str", "file:///" A_ScriptDir "/index.html")

        return 0	; S_OK.
    }
}

class ICoreWebView2NavigationStartingEventHandler extends IUnknown {
    Invoke(thisPtr, IWebView2WebView, IWebView2NavigationStartingEventArgs) {
        ComCall(4, IWebView2NavigationStartingEventArgs, "Int*", &isUserInitiated := 0)
        ComCall(5, IWebView2NavigationStartingEventArgs, "Int*", &isRedirected := 0)

        if (isUserInitiated && !isRedirected) {
            ComCall(3, IWebView2NavigationStartingEventArgs, "Str*", &uri := "")

            if (MsgBox("You are about to navigate to: " . uri . "`n`nDo you want to continue?", "Navigation warning", "YN Icon!") = "No") {

                ; IWebView2NavigationStartingEventArgs::put_Cancel
                ComCall(8, IWebView2NavigationStartingEventArgs, "Int", true)

                ; ICoreWebView2::NavigateToString
                ComCall(6, IWebView2WebView, "Str", "<h1>Navigation Canceled</h1><p>You chose to cancel navigation to the following URL: " . uri . "</p>")
            }
        }

        return 0	; S_OK
    }
}

class IUnknown {
    methods := ["QueryInterface", "AddRef", "Release", "Invoke"]
    vtbl := Buffer(4 * A_PtrSize)

    __New() {
        for (name in this.methods) {
            method := this.GetMethod(name)
            NumPut("UPtr", CallbackCreate(method.bind(this), "", method.MinParams - 1), this.vtbl, (A_Index - 1) * A_PtrSize)
        }

        this.ptr := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 0, "Ptr", A_PtrSize + 4, "UPtr")
        NumPut("UPtr", this.vtbl.ptr, this.ptr)
        NumPut("UInt", 1, this.ptr, A_PtrSize)
    }

    __Delete() {
        DllCall("Kernel32.dll\GlobalFree", "Ptr", this)
    }

    QueryInterface(pthis, riid, ppvObject) {
        ; No idea why this isn't called at all...
    }

    AddRef(interface) {
        ObjAddRef(interface)
    }

    Release(interface) {
        ObjRelease(interface)
    }
}