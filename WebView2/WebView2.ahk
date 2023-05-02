/************************************************************************
 * @description Use Microsoft Edge WebView2 control in ahk
 * @file WebView2.ahk
 * @author thqby
 * @date 2023/05/02
 * @version 1.0.28
 * @webview2version 1.0.1722.45
 ***********************************************************************/

#Include '..\ComVar.ahk'
class WebView2 extends WebView2.Base {
	/**
	 * create Edge WebView2 control.
	 * @param hwnd the hwnd of Gui or Control.
	 * @param callback Wait for the webview2 control to be created when the callback is unset; otherwise, don't wait and call the callback function after completion.
	 * @param createdEnvironment Create WebView2 controls from the created environment.
	 * @param datadir User data folder.
	 * @param edgeruntime The path of Edge Runtime or Edge(dev..) Bin.
	 * @param options The environment options of Edge. `{TargetCompatibleBrowserVersion?: string, AdditionalBrowserArguments?: string, AllowSingleSignOnUsingOSPrimaryAccount?: bool, Language?: string, ExclusiveUserDataFolderAccess?: bool}`
	 * @param dllPath The path of `WebView2Loader.dll`.
	 */
	static create(hwnd, callback := unset, createdEnvironment := 0, datadir := '', edgeruntime := '', options := 0, dllPath := 'WebView2Loader.dll') {
		Controller := WebView2.Controller()
		ControllerCompletedHandler := WebView2.Handler(ControllerCompleted_Invoke)
		if (createdEnvironment)
			ComCall(3, createdEnvironment, 'ptr', hwnd, 'ptr', ControllerCompletedHandler)	; ICoreWebView2Environment::CreateCoreWebView2Controller Method.
		else {
			if (!FileExist(dllPath) && FileExist(t := A_LineFile '\..\' (A_PtrSize * 8) 'bit\WebView2Loader.dll'))
				dllPath := t
			if (!edgeruntime) {
				ver := '0.0.0.0'
				loop files 'C:\Program Files (x86)\Microsoft\EdgeWebView\Application\*', 'D'
					if RegExMatch(A_LoopFilePath, '\\([\d.]+)$', &m) && VerCompare(m[1], ver) > 0
						edgeruntime := A_LoopFileFullPath, ver := m[1]
			}
			EnvironmentCompletedHandler := WebView2.Handler(EnvironmentCompleted_Invoke)
			if options {
				if !options.HasOwnProp('TargetCompatibleBrowserVersion')
					options.TargetCompatibleBrowserVersion := ver
				options := WebView2.EnvironmentOptions(options)
			}
			if (R := DllCall(dllPath '\CreateCoreWebView2EnvironmentWithOptions', 'str', edgeruntime,
				'str', datadir || RegExReplace(A_AppData, 'Roaming$', 'Local\Microsoft\Edge\User Data'), 'ptr', options,
				'ptr', EnvironmentCompletedHandler, 'uint')) {
				ControllerCompletedHandler := EnvironmentCompletedHandler := 0
				throw OSError(R)
			}
		}
		if (!IsSet(callback))
			while (!Controller.ptr)
				Sleep(-1)
		return Controller

		EnvironmentCompleted_Invoke(com_this, hresult, createdEnvironment) {
			if !createdEnvironment
				throw OSError(hresult)
			ComCall(3, createdEnvironment, 'ptr', hwnd, 'ptr', ControllerCompletedHandler)
			EnvironmentCompletedHandler := 0
			return 0
		}
		ControllerCompleted_Invoke(com_this, hresult, createdController) {
			if !createdController
				throw OSError(hresult)
			DllCall('user32\GetClientRect', 'ptr', hwnd, 'ptr', RECT := Buffer(16)), ObjAddRef(createdController)
			Controller.ptr := createdController, Controller.Bounds := RECT
			if (IsSet(callback))
				try callback(Controller)
			ControllerCompletedHandler := 0
			return 0
		}
	}

	static AHKObjHelper() {
		return { get: get, set: set, call: call }

		get(this, prop, params := unset) {
			if !IsSet(params) {
				if (this is Array && prop is Integer) || (this is Map)
					return this[prop]
				params := []
			}
			return this.%prop%[params*]
		}
		set(this, prop, value, params := unset) {
			if !IsSet(params) {
				if (this is Array && prop is Integer) || (this is Map)
					return this[prop] := value
				params := []
			}
			return this.%prop%[params*] := value
		}
		call(this, method, params*) => this.%method%(params*)
	}

	; Interfaces Base class
	class Base {
		ptr := 0
		__New(ptr := 0, addref := true) {
			if ptr {
				this.ptr := ptr
				if (addref)
					ObjAddRef(ptr)
			}
		}
		__Delete() {
			if (this.ptr)
				this.Release()
		}
		__Call(Name, Params) {
			if (HasMethod(this, 'add_' Name)) {
				if (!IsInteger(handler := Params[1]) && !(handler is WebView2.Handler))
					handler := WebView2.Handler(Params*)
				token := this.add_%Name%(handler)
				return { ptr: this.ptr, handler: handler, __Delete: this.remove_%Name%.Bind(, token) }
			} else
				throw Error('This value of type "' this.__Class '" has no method named "add_' Name '".', -1)
		}
		AddRef() => ObjAddRef(this.ptr)
		Release() => ObjRelease(this.ptr)
	}

	;#region WebView2 Interfaces
	class AcceleratorKeyPressedEventArgs extends WebView2.Base {
		static IID := '{9f760f8a-fb79-42be-9990-7b56900fa9c7}'
		KeyEventKind => (ComCall(3, this, 'int*', &keyEventKind := 0), keyEventKind)	; COREWEBVIEW2_KEY_EVENT_KIND
		VirtualKey => (ComCall(4, this, 'uint*', &virtualKey := 0), virtualKey)
		KeyEventLParam => (ComCall(5, this, 'int*', &lParam := 0), lParam)
		PhysicalKeyStatus => (ComCall(6, this, 'ptr', physicalKeyStatus := WebView2.PHYSICAL_KEY_STATUS()), physicalKeyStatus)	; COREWEBVIEW2_PHYSICAL_KEY_STATUS
		Handled {
			get => (ComCall(7, this, 'int*', &handled := 0), handled)
			set => ComCall(8, this, 'int', Value)
		}
	}
	class BasicAuthenticationRequestedEventArgs extends WebView2.Base {
		static IID := '{ef05516f-d897-4f9e-b672-d8e2307a3fb0}'
		Uri => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		Challenge => (ComCall(4, this, 'ptr*', &challenge := 0), CoTaskMem_String(challenge))
		Response => (ComCall(5, this, 'ptr*', response := WebView2.BasicAuthenticationResponse()), response)
		Cancel {
			get => (ComCall(6, this, 'int*', &cancel := 0), cancel)
			set => ComCall(7, this, 'int', Value)
		}
		GetDeferral() => (ComCall(8, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}
	class BasicAuthenticationResponse extends WebView2.Base {
		UserName {
			get => (ComCall(3, this, 'ptr*', &userName := 0), CoTaskMem_String(userName))
			set => ComCall(4, this, 'wstr', Value)
		}
		Password {
			get => (ComCall(5, this, 'ptr*', &password := 0), CoTaskMem_String(password))
			set => ComCall(6, this, 'wstr', Value)
		}
	}
	class BrowserProcessExitedEventArgs extends WebView2.Base {
		static IID := '{1f00663f-af8c-4782-9cdd-dd01c52e34cb}'
		BrowserProcessExitKind => (ComCall(3, this, 'int*', &browserProcessExitKind := 0), browserProcessExitKind)	; COREWEBVIEW2_BROWSER_PROCESS_EXIT_KIND
		BrowserProcessId => (ComCall(4, this, 'uint*', &value := 0), value)
	}
	class Certificate extends WebView2.Base {
		static IID := '{C5FB2FCE-1CAC-4AEE-9C79-5ED0362EAAE0}'
		Subject => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		Issuer => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		ValidFrom => (ComCall(5, this, 'double*', &value := 0), value)
		ValidTo => (ComCall(6, this, 'double*', &value := 0), value)
		DerEncodedSerialNumber => (ComCall(7, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		DisplayName => (ComCall(8, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		ToPemEncoding() => (ComCall(9, this, 'ptr*', &pemEncodedData := 0), CoTaskMem_String(pemEncodedData))
		PemEncodedIssuerCertificateChain => (ComCall(10, this, 'ptr*', value := WebView2.StringCollection()), value)
	}
	class CompositionController extends WebView2.Base {
		static IID := '{3df9b733-b9ae-4a15-86b4-eb9ee9826469}'
		RootVisualTarget {
			get => (ComCall(3, this, 'ptr*', &target := 0), ComValue(0xd, target))
			set => ComCall(4, this, 'ptr', Value)
		}
		SendMouseInput(eventKind, virtualKeys, mouseData, point) => ComCall(5, this, 'int', eventKind, 'int', virtualKeys, 'uint', mouseData, 'int64', point)
		SendPointerInput(eventKind, pointerInfo) => ComCall(6, this, 'int', eventKind, 'ptr', pointerInfo)	; ICoreWebView2PointerInfo
		Cursor => (ComCall(7, this, 'ptr*', &cursor := 0), cursor)
		SystemCursorId => (ComCall(8, this, 'uint*', &systemCursorId := 0), systemCursorId)
		add_CursorChanged(eventHandler) => (ComCall(9, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2CursorChangedEventHandler
		remove_CursorChanged(token) => ComCall(10, this, 'int64', token)

		static IID_2 := '{0b6a3d24-49cb-4806-ba20-b5e0734a7b26}'
		AutomationProvider => (ComCall(11, this, 'ptr*', &provider := 0), ComValue(0xd, provider))

		static IID_3 := '{9570570e-4d76-4361-9ee1-f04d0dbdfb1e}'
		DragEnter(dataObject, keyState, point) => (ComCall(12, this, 'ptr', dataObject, 'uint', keyState, 'int64', point, 'uint*', &effect := 0), effect)
		DragLeave() => ComCall(13, this)
		DragOver(keyState, point) => (ComCall(14, this, 'uint', keyState, 'int64', point, 'uint*', &effect := 0), effect)
		Drop(dataObject, keyState, point) => (ComCall(15, this, 'ptr', dataObject, 'uint', keyState, 'int64', point, 'uint*', &effect := 0), effect)
	}
	class Controller extends WebView2.Base {
		static IID := '{4d00c0d1-9434-4eb6-8078-8697a560334f}'
		__Delete() {
			if (this.ptr)
				this.Close(), super.__Delete()
		}
		Fill() {
			if !this.ptr
				return
			DllCall('user32\GetClientRect', 'ptr', this.ParentWindow, 'ptr', RECT := Buffer(16))
			this.Bounds := RECT
		}
		IsVisible {
			get => (ComCall(3, this, 'int*', &isVisible := 0), isVisible)
			set => ComCall(4, this, 'int', Value)
		}
		Bounds {
			get => (ComCall(5, this, 'ptr', bounds := Buffer(16)), bounds)
			set => A_PtrSize = 8 ? ComCall(6, this, 'ptr', Value) : ComCall(6, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64'))
		}
		ZoomFactor {
			get => (ComCall(7, this, 'double*', &zoomFactor := 0), zoomFactor)
			set => ComCall(8, this, 'double', Value)
		}
		add_ZoomFactorChanged(eventHandler) => (ComCall(9, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ZoomFactorChangedEventHandler
		remove_ZoomFactorChanged(token) => ComCall(10, this, 'int64', token)
		SetBoundsAndZoomFactor(bounds, zoomFactor) => (A_PtrSize = 8 ? ComCall(11, this, 'ptr', bounds, 'double', zoomFactor) : ComCall(11, this, 'int64', NumGet(bounds, 'int64'), 'int64', NumGet(bounds, 8, 'int64'), 'double', zoomFactor))
		MoveFocus(reason) => ComCall(12, this, 'int', reason)
		add_MoveFocusRequested(eventHandler) => (ComCall(13, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2MoveFocusRequestedEventHandler
		remove_MoveFocusRequested(token) => ComCall(14, this, 'int64', token)
		add_GotFocus(eventHandler) => (ComCall(15, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FocusChangedEventHandler
		remove_GotFocus(token) => ComCall(16, this, 'int64', token)
		add_LostFocus(eventHandler) => (ComCall(17, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FocusChangedEventHandler
		remove_LostFocus(token) => ComCall(18, this, 'int64', token)
		add_AcceleratorKeyPressed(eventHandler) => (ComCall(19, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2AcceleratorKeyPressedEventHandler
		remove_AcceleratorKeyPressed(token) => ComCall(20, this, 'int64', token)
		ParentWindow {
			get => (ComCall(21, this, 'ptr*', &parentWindow := 0), parentWindow)
			set => ComCall(22, this, 'ptr', Value)
		}
		NotifyParentWindowPositionChanged() => ComCall(23, this)
		Close() => ComCall(24, this)
		CoreWebView2 => (ComCall(25, this, 'ptr*', coreWebView2 := WebView2.Core()), coreWebView2)

		static IID_2 := '{c979903e-d4ca-4228-92eb-47ee3fa96eab}'
		; BGR color only, Alpha is not supported
		DefaultBackgroundColor {
			get => (ComCall(26, this, 'uint*', &backgroundColor := 0), backgroundColor >> 8)
			set => ComCall(27, this, 'uint', Value << 8 | 0xff)
		}

		static IID_3 := '{f9614724-5d2b-41dc-aef7-73d62b51543b}'
		RasterizationScale {
			get => (ComCall(28, this, 'double*', &scale := 0), scale)
			set => ComCall(29, this, 'double', Value)
		}
		ShouldDetectMonitorScaleChanges {
			get => (ComCall(30, this, 'int*', &value := 0), value)
			set => ComCall(31, this, 'int', Value)
		}
		add_RasterizationScaleChanged(eventHandler) => (ComCall(32, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2RasterizationScaleChangedEventHandler
		remove_RasterizationScaleChanged(token) => ComCall(33, this, 'int64', token)
		BoundsMode {
			get => (ComCall(34, this, 'int*', &boundsMode := 0), boundsMode)	; COREWEBVIEW2_BOUNDS_MODE
			set => ComCall(35, this, 'int', Value)
		}

		static IID_4 := '{97d418d5-a426-4e49-a151-e1a10f327d9e}'
		AllowExternalDrop {
			get => (ComCall(36, this, 'int*', &value := 0), value)
			set => ComCall(37, this, 'int', Value)
		}
	}
	class ControllerOptions extends WebView2.Base {
		static IID := '{12aae616-8ccb-44ec-bcb3-eb1831881635}'
		ProfileName {
			get => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(4, this, 'wstr', Value)
		}
		IsInPrivateModeEnabled {
			get => (ComCall(5, this, 'int*', &value := 0), value)
			set => ComCall(6, this, 'int', Value)
		}

		static IID_2 := '{06c991d8-9e7e-11ed-a8fc-0242ac120002}'
		ScriptLocale {
			get => (ComCall(7, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(8, this, 'wstr', Value)
		}
	}
	class ContentLoadingEventArgs extends WebView2.Base {
		static IID := '{0c8a1275-9b6b-4901-87ad-70df25bafa6e}'
		IsErrorPage => (ComCall(3, this, 'int*', &isErrorPage := 0), isErrorPage)
		NavigationId => (ComCall(4, this, 'int64*', &navigationId := 0), navigationId)
	}
	class ContextMenuItem extends WebView2.Base {
		static IID := '{7aed49e3-a93f-497a-811c-749c6b6b6c65}'
		Name => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		Label => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		CommandId => (ComCall(5, this, 'int*', &value := 0), value)
		ShortcutKeyDescription => (ComCall(6, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		Icon => (ComCall(7, this, 'ptr*', &value := 0), ComValue(0xd, value))
		Kind => (ComCall(8, this, 'int*', &value := 0), value)
		IsEnabled {
			set => ComCall(9, this, 'int', Value)
			get => (ComCall(10, this, 'int*', &value := 0), value)
		}
		IsChecked {
			set => ComCall(11, this, 'int', Value)
			get => (ComCall(12, this, 'int*', &value := 0), value)
		}
		Children => (ComCall(13, this, 'ptr*', value := WebView2.ContextMenuItemCollection()), value)
		add_CustomItemSelected(eventHandler) => (ComCall(14, this, 'ptr', eventHandler, 'int64*', &token := 0), token)
		remove_CustomItemSelected(token) => ComCall(15, this, 'int64', token)
	}
	class ContextMenuItemCollection extends WebView2.Base {
		static IID := '{f562a2f5-c415-45cf-b909-d4b7c1e276d3}'
		__Item[index] => this.GetValueAtIndex(index)
		Count => (ComCall(3, this, 'uint*', &value := 0), value)
		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', value := WebView2.ContextMenuItem()), value)
		RemoveValueAtIndex(index) => ComCall(5, this, 'uint', index)
		InsertValueAtIndex(index, value) => ComCall(6, this, 'uint', index, 'ptr', value)
	}
	class ContextMenuRequestedEventArgs extends WebView2.Base {
		static IID := '{a1d309ee-c03f-11eb-8529-0242ac130003}'
		MenuItems => (ComCall(3, this, 'ptr*', value := WebView2.ContextMenuItemCollection()), value)
		ContextMenuTarget => (ComCall(4, this, 'ptr*', value := WebView2.ContextMenuTarget()), value)
		Location => (ComCall(5, this, 'int64*', &value := 0), value)
		SelectedCommandId {
			set => ComCall(6, this, 'int', Value)
			get => (ComCall(7, this, 'int*', &value := 0), value)
		}
		Handled {
			set => ComCall(8, this, 'int', Value)
			get => (ComCall(9, this, 'int*', &value := 0), value)
		}
		GetDeferral() => (ComCall(10, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}
	class ContextMenuTarget extends WebView2.Base {
		static IID := '{b8611d99-eed6-4f3f-902c-a198502ad472}'
		Kind => (ComCall(3, this, 'int*', &value := 0), value)	; COREWEBVIEW2_CONTEXT_MENU_TARGET_KIND
		IsEditable => (ComCall(4, this, 'int*', &value := 0), value)
		IsRequestedForMainFrame => (ComCall(5, this, 'int*', &value := 0), value)
		PageUri => (ComCall(6, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		FrameUri => (ComCall(7, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		HasLinkUri => (ComCall(8, this, 'int*', &value := 0), value)
		LinkUri => (ComCall(9, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		HasLinkText => (ComCall(10, this, 'int*', &value := 0), value)
		LinkText => (ComCall(11, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		HasSourceUri => (ComCall(12, this, 'int*', &value := 0), value)
		SourceUri => (ComCall(13, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		HasSelection => (ComCall(14, this, 'int*', &value := 0), value)
		Selection => (ComCall(15, this, 'ptr*', &value := 0), CoTaskMem_String(value))
	}
	class Cookie extends WebView2.Base {
		static IID := '{AD26D6BE-1486-43E6-BF87-A2034006CA21}'
		Name => (ComCall(3, this, 'ptr*', &name := 0), CoTaskMem_String(name))
		Value {
			get => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(5, this, 'wstr', Value)
		}
		Domain => (ComCall(6, this, 'ptr*', &domain := 0), CoTaskMem_String(domain))
		Path => (ComCall(7, this, 'ptr*', &path := 0), CoTaskMem_String(path))
		Expires {
			get => (ComCall(8, this, 'double*', &expires := 0), expires)
			set => ComCall(9, this, 'double', Value)
		}
		IsHttpOnly {
			get => (ComCall(10, this, 'int*', &isHttpOnly := 0), isHttpOnly)
			set => ComCall(11, this, 'int', Value)
		}
		SameSite {
			get => (ComCall(12, this, 'int*', &sameSite := 0), sameSite)	; COREWEBVIEW2_COOKIE_SAME_SITE_KIND
			set => ComCall(13, this, 'int', Value)
		}
		IsSecure {
			get => (ComCall(14, this, 'int*', &isSecure := 0), isSecure)
			set => ComCall(15, this, 'int', Value)
		}
		IsSession => (ComCall(16, this, 'int*', &isSession := 0), isSession)
	}
	class CookieList extends WebView2.Base {
		static IID := '{F7F6F714-5D2A-43C6-9503-346ECE02D186}'
		__Item[index] => this.GetValueAtIndex(index)
		Count => (ComCall(3, this, 'uint*', &count := 0), count)
		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', cookie := WebView2.Cookie()), cookie)
	}
	class CookieManager extends WebView2.Base {
		static IID := '{177CD9E7-B6F5-451A-94A0-5D7A3A4C4141}'
		CreateCookie(name, value, domain, path) => (ComCall(3, this, 'wstr', name, 'wstr', value, 'wstr', domain, 'wstr', path, 'ptr*', cookie := WebView2.Cookie()), cookie)
		CopyCookie(cookieParam) => (ComCall(4, this, 'ptr', cookieParam, 'ptr*', cookie := WebView2.Cookie()), cookie)	; ICoreWebView2Cookie
		GetCookies(uri, handler) => ComCall(5, this, 'wstr', uri, 'ptr', handler)	; ICoreWebView2GetCookiesCompletedHandler
		AddOrUpdateCookie(cookie) => ComCall(6, this, 'ptr', cookie)	; ICoreWebView2Cookie
		DeleteCookie(cookie) => ComCall(7, this, 'ptr', cookie)	; ICoreWebView2Cookie
		DeleteCookies(name, uri) => ComCall(8, this, 'wstr', name, 'wstr', uri)
		DeleteCookiesWithDomainAndPath(name, domain, path) => ComCall(9, this, 'wstr', name, 'wstr', domain, 'wstr', path)
		DeleteAllCookies() => ComCall(10, this)
	}
	class Core extends WebView2.Base {
		static IID := '{76eceacb-0462-4d94-ac83-423a6793775e}'
		AddAHKObjHelper() => this.AddHostObjectToScript('AHKObjHelper', WebView2.AHKObjHelper())
		Settings => (ComCall(3, this, 'ptr*', settings := WebView2.Settings()), settings)
		Source => (ComCall(4, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
		Navigate(uri) => ComCall(5, this, 'wstr', uri)
		NavigateToString(htmlContent) => ComCall(6, this, 'wstr', htmlContent)
		add_NavigationStarting(eventHandler) => (ComCall(7, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2NavigationStartingEventHandler
		remove_NavigationStarting(token) => ComCall(8, this, 'int64', token)
		add_ContentLoading(eventHandler) => (ComCall(9, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ContentLoadingEventHandler
		remove_ContentLoading(token) => ComCall(10, this, 'int64', token)
		add_SourceChanged(eventHandler) => (ComCall(11, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2SourceChangedEventHandler
		remove_SourceChanged(token) => ComCall(12, this, 'int64', token)
		add_HistoryChanged(eventHandler) => (ComCall(13, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2HistoryChangedEventHandler
		remove_HistoryChanged(token) => ComCall(14, this, 'int64', token)
		add_NavigationCompleted(eventHandler) => (ComCall(15, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2NavigationCompletedEventHandler
		remove_NavigationCompleted(token) => ComCall(16, this, 'int64', token)
		add_FrameNavigationStarting(eventHandler) => (ComCall(17, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2NavigationStartingEventHandler
		remove_FrameNavigationStarting(token) => ComCall(18, this, 'int64', token)
		add_FrameNavigationCompleted(eventHandler) => (ComCall(19, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2NavigationCompletedEventHandler
		remove_FrameNavigationCompleted(token) => ComCall(20, this, 'int64', token)
		add_ScriptDialogOpening(eventHandler) => (ComCall(21, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ScriptDialogOpeningEventHandler
		remove_ScriptDialogOpening(token) => ComCall(22, this, 'int64', token)
		add_PermissionRequested(eventHandler) => (ComCall(23, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2PermissionRequestedEventHandler
		remove_PermissionRequested(token) => ComCall(24, this, 'int64', token)
		add_ProcessFailed(eventHandler) => (ComCall(25, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ProcessFailedEventHandler
		remove_ProcessFailed(token) => ComCall(26, this, 'int64', token)
		AddScriptToExecuteOnDocumentCreated(javaScript, handler) => ComCall(27, this, 'wstr', javaScript, 'ptr', handler)	; ICoreWebView2AddScriptToExecuteOnDocumentCreatedCompletedHandler
		RemoveScriptToExecuteOnDocumentCreated(id) => ComCall(28, this, 'wstr', id)
		ExecuteScript(javaScript, handler) => ComCall(29, this, 'wstr', javaScript, 'ptr', handler)	; ICoreWebView2ExecuteScriptCompletedHandler
		CapturePreview(imageFormat, imageStream, handler) => ComCall(30, this, 'int', imageFormat, 'ptr', imageStream, 'ptr', handler)	; ICoreWebView2CapturePreviewCompletedHandler
		Reload() => ComCall(31, this)
		PostWebMessageAsJson(webMessageAsJson) => ComCall(32, this, 'wstr', webMessageAsJson)
		PostWebMessageAsString(webMessageAsString) => ComCall(33, this, 'wstr', webMessageAsString)
		add_WebMessageReceived(handler) => (ComCall(34, this, 'ptr', handler, 'int64*', &token := 0), token)	; ICoreWebView2WebMessageReceivedEventHandler
		remove_WebMessageReceived(token) => ComCall(35, this, 'int64', token)
		CallDevToolsProtocolMethod(methodName, parametersAsJson, handler) => ComCall(36, this, 'wstr', methodName, 'wstr', parametersAsJson, 'ptr', handler)	; ICoreWebView2CallDevToolsProtocolMethodCompletedHandler
		BrowserProcessId => (ComCall(37, this, 'uint*', &value := 0), value)
		CanGoBack => (ComCall(38, this, 'int*', &canGoBack := 0), canGoBack)
		CanGoForward => (ComCall(39, this, 'int*', &canGoForward := 0), canGoForward)
		GoBack() => ComCall(40, this)
		GoForward() => ComCall(41, this)
		GetDevToolsProtocolEventReceiver(eventName) => (ComCall(42, this, 'wstr', eventName, 'ptr*', receiver := WebView2.DevToolsProtocolEventReceiver()), receiver)
		Stop() => ComCall(43, this)
		add_NewWindowRequested(eventHandler) => (ComCall(44, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2NewWindowRequestedEventHandler
		remove_NewWindowRequested(token) => ComCall(45, this, 'int64', token)
		add_DocumentTitleChanged(eventHandler) => (ComCall(46, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2DocumentTitleChangedEventHandler
		remove_DocumentTitleChanged(token) => ComCall(47, this, 'int64', token)
		DocumentTitle => (ComCall(48, this, 'ptr*', &title := 0), CoTaskMem_String(title))
		AddHostObjectToScript(name, object) => ComCall(49, this, 'wstr', name, 'ptr', ComVar(object))
		RemoveHostObjectFromScript(name) => ComCall(50, this, 'wstr', name)
		OpenDevToolsWindow() => ComCall(51, this)
		add_ContainsFullScreenElementChanged(eventHandler) => (ComCall(52, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ContainsFullScreenElementChangedEventHandler
		remove_ContainsFullScreenElementChanged(token) => ComCall(53, this, 'int64', token)
		ContainsFullScreenElement => (ComCall(54, this, 'int*', &containsFullScreenElement := 0), containsFullScreenElement)
		add_WebResourceRequested(eventHandler) => (ComCall(55, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2WebResourceRequestedEventHandler
		remove_WebResourceRequested(token) => ComCall(56, this, 'int64', token)
		AddWebResourceRequestedFilter(uri, resourceContext) => ComCall(57, this, 'wstr', uri, 'int', resourceContext)
		RemoveWebResourceRequestedFilter(uri, resourceContext) => ComCall(58, this, 'wstr', uri, 'int', resourceContext)
		add_WindowCloseRequested(eventHandler) => (ComCall(59, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2WindowCloseRequestedEventHandler
		remove_WindowCloseRequested(token) => ComCall(60, this, 'int64', token)

		static IID_2 := '{9E8F0CF8-E670-4B5E-B2BC-73E061E3184C}'
		add_WebResourceResponseReceived(eventHandler) => (ComCall(61, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2WebResourceResponseReceivedEventHandler
		remove_WebResourceResponseReceived(token) => ComCall(62, this, 'int64', token)
		NavigateWithWebResourceRequest(request) => ComCall(63, this, 'ptr', request)	; ICoreWebView2WebResourceRequest
		add_DOMContentLoaded(eventHandler) => (ComCall(64, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2DOMContentLoadedEventHandler
		remove_DOMContentLoaded(token) => ComCall(65, this, 'int64', token)
		CookieManager => (ComCall(66, this, 'ptr*', cookieManager := WebView2.CookieManager()), cookieManager)
		Environment => (ComCall(67, this, 'ptr*', environment := WebView2.Environment()), environment)

		static IID_3 := '{A0D6DF20-3B92-416D-AA0C-437A9C727857}'
		TrySuspend(handler) => ComCall(68, this, 'ptr', handler)	; ICoreWebView2TrySuspendCompletedHandler
		Resume() => ComCall(69, this)
		IsSuspended => (ComCall(70, this, 'int*', &isSuspended := 0), isSuspended)
		SetVirtualHostNameToFolderMapping(hostName, folderPath, accessKind) => ComCall(71, this, 'wstr', hostName, 'wstr', folderPath, 'int', accessKind)
		ClearVirtualHostNameToFolderMapping(hostName) => ComCall(72, this, 'wstr', hostName)

		static IID_4 := '{20d02d59-6df2-42dc-bd06-f98a694b1302}'
		add_FrameCreated(eventHandler) => (ComCall(73, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameCreatedEventHandler
		remove_FrameCreated(token) => ComCall(74, this, 'int64', token)
		add_DownloadStarting(eventHandler) => (ComCall(75, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2DownloadStartingEventHandler
		remove_DownloadStarting(token) => ComCall(76, this, 'int64', token)

		static IID_5 := '{bedb11b8-d63c-11eb-b8bc-0242ac130003}'
		add_ClientCertificateRequested(eventHandler) => (ComCall(77, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ClientCertificateRequestedEventHandler
		remove_ClientCertificateRequested(token) => ComCall(78, this, 'int64', token)

		static IID_6 := '{499aadac-d92c-4589-8a75-111bfc167795}'
		OpenTaskManagerWindow() => ComCall(79, this)

		static IID_7 := '{79c24d83-09a3-45ae-9418-487f32a58740}'
		PrintToPdf(resultFilePath, printSettings, handler) => ComCall(80, this, 'wstr', resultFilePath, 'ptr', printSettings, 'ptr', handler)

		static IID_8 := '{E9632730-6E1E-43AB-B7B8-7B2C9E62E094}'
		add_IsMutedChanged(eventHandler) => (ComCall(81, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2IsMutedChangedEventHandler
		remove_IsMutedChanged(token) => ComCall(82, this, 'int64', token)
		IsMuted {
			get => (ComCall(83, this, 'int*', &value := 0), value)
			set => ComCall(84, this, 'int', Value)
		}
		add_IsDocumentPlayingAudioChanged(eventHandler) => (ComCall(85, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2IsDocumentPlayingAudioChangedEventHandler
		remove_IsDocumentPlayingAudioChanged(token) => ComCall(86, this, 'int64', token)
		IsDocumentPlayingAudio => (ComCall(87, this, 'int*', &value := 0), value)

		static IID_9 := '{4d7b2eab-9fdc-468d-b998-a9260b5ed651}'
		add_IsDefaultDownloadDialogOpenChanged(handler) => (ComCall(88, this, 'ptr', handler, 'int64*', &token := 0), token)	; ICoreWebView2IsDefaultDownloadDialogOpenChangedEventHandler
		remove_IsDefaultDownloadDialogOpenChanged(token) => ComCall(89, this, 'int64', &token := 0)
		IsDefaultDownloadDialogOpen => (ComCall(90, this, 'int*', &value := 0), value)
		OpenDefaultDownloadDialog() => ComCall(91, this)
		CloseDefaultDownloadDialog() => ComCall(92, this)
		DefaultDownloadDialogCornerAlignment {
			get => (ComCall(93, this, 'int*', &value := 0), value)
			set => ComCall(94, this, 'int', Value)
		}
		DefaultDownloadDialogMargin {
			get => (ComCall(95, this, 'int64*', &value := 0), value)	; POINT
			set => ComCall(96, this, 'int64', Value)
		}

		static IID_10 := '{b1690564-6f5a-4983-8e48-31d1143fecdb}'
		add_BasicAuthenticationRequested(eventHandler) => (ComCall(97, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2BasicAuthenticationRequestedEventHandler
		remove_BasicAuthenticationRequested(token) => ComCall(98, this, 'int64', &token := 0)

		static IID_11 := '{0be78e56-c193-4051-b943-23b460c08bdb}'
		CallDevToolsProtocolMethodForSession(sessionId, methodName, parametersAsJson, handler) => ComCall(99, this, 'wstr', sessionId, 'wstr', methodName, 'wstr', parametersAsJson, 'ptr', handler)
		add_ContextMenuRequested(eventHandler) => (ComCall(100, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ContextMenuRequestedEventHandler
		remove_ContextMenuRequested(token) => ComCall(101, this, 'int64', &token := 0)

		static IID_12 := '{35D69927-BCFA-4566-9349-6B3E0D154CAC}'
		add_StatusBarTextChanged(eventHandler) => (ComCall(102, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2StatusBarTextChangedEventHandler
		remove_StatusBarTextChanged(token) => ComCall(103, this, 'int64', &token := 0)
		StatusBarText => (ComCall(104, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		static IID_13 := '{F75F09A8-667E-4983-88D6-C8773F315E84}'
		Profile => (ComCall(105, this, 'ptr*', value := WebView2.Profile()), value)

		static IID_14 := '{6DAA4F10-4A90-4753-8898-77C5DF534165}'
		add_ServerCertificateErrorDetected(eventHandler) => (ComCall(106, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ServerCertificateErrorDetectedEventHandler
		remove_ServerCertificateErrorDetected(token) => ComCall(107, this, 'int64', &token := 0)
		ClearServerCertificateErrorActions(handler) => ComCall(108, this, 'ptr', handler)	; ICoreWebView2ClearServerCertificateErrorActionsCompletedHandler

		static IID_15 := '{517B2D1D-7DAE-4A66-A4F4-10352FFB9518}'
		add_FaviconChanged(eventHandler) => (ComCall(109, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FaviconChangedEventHandler
		remove_FaviconChanged(token) => ComCall(110, this, 'int64', &token := 0)
		FaviconUri => (ComCall(111, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		GetFavicon(format, completedHandler) => ComCall(112, this, 'int', format, 'ptr', completedHandler)	; COREWEBVIEW2_FAVICON_IMAGE_FORMAT, ICoreWebView2GetFaviconCompletedHandler

		static IID_16 := '{0EB34DC9-9F91-41E1-8639-95CD5943906B}'
		Print(printSettings, handler) => ComCall(113, this, 'ptr', printSettings, 'ptr', handler)
		ShowPrintUI(printDialogKind) => ComCall(114, this, 'int', printDialogKind)
		PrintToPdfStream(printSettings, handler) => ComCall(115, this, 'ptr', printSettings, 'ptr', handler)

		static IID_17 := '{702E75D4-FD44-434D-9D70-1A68A6B1192A}'
		PostSharedBufferToScript(sharedBuffer, access, additionalDataAsJson) => ComCall(116, this, 'ptr', sharedBuffer, 'int', access, 'wstr', additionalDataAsJson)
	}
	class ClientCertificate extends WebView2.Base {
		static IID := '{e7188076-bcc3-11eb-8529-0242ac130003}'
		Subject => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		Issuer => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		ValidFrom => (ComCall(5, this, 'double*', &value := 0), value)
		ValidTo => (ComCall(6, this, 'double*', &value := 0), value)
		DerEncodedSerialNumber => (ComCall(7, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		DisplayName => (ComCall(8, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		ToPemEncoding() => (ComCall(9, this, 'ptr*', &pemEncodedData := 0), CoTaskMem_String(pemEncodedData))
		PemEncodedIssuerCertificateChain => (ComCall(10, this, 'ptr*', value := WebView2.StringCollection()), value)
		Kind => (ComCall(11, this, 'int*', &value := 0), value)	; COREWEBVIEW2_CLIENT_CERTIFICATE_KIND
	}
	class CustomSchemeRegistration extends Buffer {
		static IID := '{d60ac92c-37a6-4b26-a39e-95cfe59047bb}'
		/**
		 * Represents the registration of a custom scheme with the CoreWebView2Environment.
		 * https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2customschemeregistration
		 * @param {String} SchemeName The name of the custom scheme to register.
		 * @param {Array} AllowedOrigins The array of origins that are allowed to use the scheme.
		 * @param TreatAsSecure Whether the sites with this scheme will be treated as a Secure Context like an HTTPS site.
		 * @param HasAuthorityComponent Set this property to true if the URIs with this custom scheme will have an authority component (a host for custom schemes).
		 */
		__New(SchemeName, AllowedOrigins, TreatAsSecure := false, HasAuthorityComponent := false) {
			super.__New(11 * A_PtrSize)
			p_this := ObjPtr(this), p_unk := this.Ptr + A_PtrSize
			p := NumPut('ptr', p_unk, this), fnptrs := []
			this.DefineProp('__Delete', { call: __Delete })
			for cb in [
				QueryInterface, AddRef, Release,
				get_SchemeName, get_TreatAsSecure, put_xxx,
				GetAllowedOrigins, SetAllowedOrigins,
				get_HasAuthorityComponent, put_xxx
			]
				p := NumPut('ptr', _ := CallbackCreate(cb), p), fnptrs.Push(_)
			QueryInterface(this, riid, ppvObject) {
				DllCall("ole32.dll\StringFromGUID2", "ptr", riid, "ptr", buf := Buffer(78), "int", 39)
				iid := StrGet(buf)
				if iid = '{d60ac92c-37a6-4b26-a39e-95cfe59047bb}' {
					ObjAddRef(p_this), NumPut('ptr', p_unk, ppvObject)
					return 0
				}
				NumPut('ptr', 0, ppvObject)
				return 0x80004002
			}
			AddRef(this) => ObjAddRef(p_this)
			Release(this) => ObjRelease(p_this)
			put_xxx(this, value) => 0
			get_SchemeName(this, pvalue) {
				pm := DllCall('ole32\CoTaskMemAlloc', 'uptr', s := StrLen(SchemeName) * 2 + 2, 'ptr')
				DllCall('RtlMoveMemory', 'ptr', pm, 'ptr', StrPtr(SchemeName), 'uptr', s)
				return (NumPut('ptr', pm, pvalue), 0)
			}
			get_TreatAsSecure(this, pvalue) => (NumPut('int', TreatAsSecure, pvalue), 0)
			get_HasAuthorityComponent(this, pvalue) => (NumPut('int', HasAuthorityComponent, pvalue), 0)
			GetAllowedOrigins(this, pallowedOriginsCount, pallowedOrigins) {
				local l, p, pm, ps
				NumPut('uint', l := AllowedOrigins.Length, pallowedOriginsCount)
				if l {
					pm := p := DllCall('ole32\CoTaskMemAlloc', 'uptr', l * A_PtrSize, 'ptr')
					for origin in AllowedOrigins {
						ps := DllCall('ole32\CoTaskMemAlloc', 'uptr', s := StrLen(origin) * 2 + 2, 'ptr')
						DllCall('RtlMoveMemory', 'ptr', ps, 'ptr', StrPtr(origin), 'uptr', s)
						p := NumPut('ptr', ps, p)
					}
				} else pm := 0
				NumPut('ptr', pm, pallowedOrigins)
				return 0
			}
			SetAllowedOrigins(this, allowedOriginsCount, pallowedOrigins) {
				AllowedOrigins := []
				loop allowedOriginsCount
					AllowedOrigins.Push(StrGet(NumGet(pallowedOrigins, (A_Index - 1) * A_PtrSize, 'ptr')))
				return 0
			}
			__Delete(*) {
				for ptr in fnptrs
					CallbackFree(ptr)
			}
		}
	}
	class ClientCertificateCollection extends WebView2.Base {
		static IID := '{ef5674d2-bcc3-11eb-8529-0242ac130003}'
		__Item[index] => this.GetValueAtIndex(index)
		Count => (ComCall(3, this, 'uint*', &value := 0), value)
		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', certificate := WebView2.ClientCertificate()), certificate)
	}
	class ClientCertificateRequestedEventArgs extends WebView2.Base {
		static IID := '{bc59db28-bcc3-11eb-8529-0242ac130003}'
		Host => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		Port => (ComCall(4, this, 'int*', &value := 0), value)
		IsProxy => (ComCall(5, this, 'int*', &value := 0), value)
		AllowedCertificateAuthorities => (ComCall(6, this, 'ptr*', value := WebView2.StringCollection()), value)
		MutuallyTrustedCertificates => (ComCall(7, this, 'ptr*', value := WebView2.ClientCertificateCollection()), value)
		SelectedCertificate {
			get => (ComCall(8, this, 'ptr*', value := WebView2.ClientCertificate()), value)
			set => ComCall(9, this, 'ptr', Value)
		}
		Cancel {
			get => (ComCall(10, this, 'int*', &value := 0), value)
			set => ComCall(11, this, 'int', Value)
		}
		Handled {
			get => (ComCall(12, this, 'int*', &value := 0), value)
			set => ComCall(13, this, 'int', Value)
		}
		GetDeferral() => (ComCall(14, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}
	class DOMContentLoadedEventArgs extends WebView2.Base {
		static IID := '{16B1E21A-C503-44F2-84C9-70ABA5031283}'
		NavigationId => (ComCall(3, this, 'int64*', &navigationId := 0), navigationId)
	}
	class Deferral extends WebView2.Base {
		static IID := '{c10e7f7b-b585-46f0-a623-8befbf3e4ee0}'
		Complete() => ComCall(3, this)
	}
	class DevToolsProtocolEventReceivedEventArgs extends WebView2.Base {
		static IID := '{653c2959-bb3a-4377-8632-b58ada4e66c4}'
		ParameterObjectAsJson => (ComCall(3, this, 'ptr*', &parameterObjectAsJson := 0), CoTaskMem_String(parameterObjectAsJson))

		static IID_2 := '{2DC4959D-1494-4393-95BA-BEA4CB9EBD1B}'
		SessionId => (ComCall(4, this, 'ptr*', &sessionId := 0), CoTaskMem_String(sessionId))
	}
	class DevToolsProtocolEventReceiver extends WebView2.Base {
		static IID := '{b32ca51a-8371-45e9-9317-af021d080367}'
		add_DevToolsProtocolEventReceived(handler) => (ComCall(3, this, 'ptr', handler, 'int64*', &token := 0), token)	; ICoreWebView2DevToolsProtocolEventReceivedEventHandler
		remove_DevToolsProtocolEventReceived(token) => ComCall(4, this, 'int64', token)
	}
	class DownloadOperation extends WebView2.Base {
		static IID := '{3d6b6cf2-afe1-44c7-a995-c65117714336}'
		add_BytesReceivedChanged(eventHandler) => (ComCall(3, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2BytesReceivedChangedEventHandler
		remove_BytesReceivedChanged(token) => ComCall(4, this, 'int64', token)
		add_EstimatedEndTimeChanged(eventHandler) => (ComCall(5, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2EstimatedEndTimeChangedEventHandler
		remove_EstimatedEndTimeChanged(token) => ComCall(6, this, 'int64', token)
		add_StateChanged(eventHandler) => (ComCall(7, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2StateChangedEventHandler
		remove_StateChanged(token) => ComCall(8, this, 'int64', token)
		Uri => (ComCall(9, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
		ContentDisposition => (ComCall(10, this, 'ptr*', &contentDisposition := 0), CoTaskMem_String(contentDisposition))
		MimeType => (ComCall(11, this, 'ptr*', &mimeType := 0), CoTaskMem_String(mimeType))
		TotalBytesToReceive => (ComCall(12, this, 'int64*', &totalBytesToReceive := 0), totalBytesToReceive)
		BytesReceived => (ComCall(13, this, 'int64*', &bytesReceived := 0), bytesReceived)
		EstimatedEndTime => (ComCall(14, this, 'ptr*', &estimatedEndTime := 0), CoTaskMem_String(estimatedEndTime))
		ResultFilePath => (ComCall(15, this, 'ptr*', &resultFilePath := 0), CoTaskMem_String(resultFilePath))
		State => (ComCall(16, this, 'int*', &downloadState := 0), downloadState)	; COREWEBVIEW2_DOWNLOAD_STATE
		InterruptReason => (ComCall(17, this, 'int*', &interruptReason := 0), interruptReason)	; COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON
		Cancel() => ComCall(18, this)
		Pause() => ComCall(19, this)
		Resume() => ComCall(20, this)
		CanResume => (ComCall(21, this, 'int*', &canResume := 0), canResume)
	}
	class DownloadStartingEventArgs extends WebView2.Base {
		static IID := '{e99bbe21-43e9-4544-a732-282764eafa60}'
		DownloadOperation => (ComCall(3, this, 'ptr*', downloadOperation := WebView2.DownloadOperation()), downloadOperation)
		Cancel {
			get => (ComCall(4, this, 'int*', &cancel := 0), cancel)
			set => ComCall(5, this, 'int', Value)
		}
		ResultFilePath {
			get => (ComCall(6, this, 'ptr*', &resultFilePath := 0), CoTaskMem_String(resultFilePath))
			set => ComCall(7, this, 'wstr', Value)
		}
		Handled {
			get => (ComCall(8, this, 'int*', &handled := 0), handled)
			set => ComCall(9, this, 'int', Value)
		}
		GetDeferral() => (ComCall(10, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}
	class Environment extends WebView2.Base {
		static IID := '{b96d755e-0319-4e92-a296-23436f46a1fc}'
		CreateCoreWebView2Controller(parentWindow, handler) => ComCall(3, this, 'ptr', parentWindow, 'ptr', handler)	; ICoreWebView2CreateCoreWebView2ControllerCompletedHandler
		CreateWebResourceResponse(content, statusCode, reasonPhrase, headers) => (ComCall(4, this, 'ptr', content, 'int', statusCode, 'wstr', reasonPhrase, 'wstr', headers, 'ptr*', response := WebView2.WebResourceResponse()), response)
		BrowserVersionString => (ComCall(5, this, 'ptr*', &versionInfo := 0), CoTaskMem_String(versionInfo))
		add_NewBrowserVersionAvailable(eventHandler) => (ComCall(6, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2NewBrowserVersionAvailableEventHandler
		remove_NewBrowserVersionAvailable(token) => ComCall(7, this, 'int64', token)

		static IID_2 := '{41F3632B-5EF4-404F-AD82-2D606C5A9A21}'
		CreateWebResourceRequest(uri, method, postData, headers) => (ComCall(8, this, 'wstr', uri, 'wstr', method, 'ptr', postData, 'wstr', headers, 'ptr*', request := WebView2.WebResourceRequest()), request)

		static IID_3 := '{80a22ae3-be7c-4ce2-afe1-5a50056cdeeb}'
		CreateCoreWebView2CompositionController(parentWindow, handler) => ComCall(9, this, 'ptr', parentWindow, 'ptr', handler)	; ICoreWebView2CreateCoreWebView2CompositionControllerCompletedHandler
		CreateCoreWebView2PointerInfo() => (ComCall(10, this, 'ptr*', pointerInfo := WebView2.PointerInfo()), pointerInfo)

		static IID_4 := '{20944379-6dcf-41d6-a0a0-abc0fc50de0d}'
		GetAutomationProviderForWindow(hwnd) => (ComCall(11, this, 'ptr', hwnd, 'ptr*', &provider := 0), ComValue(0xd, provider))

		static IID_5 := '{319e423d-e0d7-4b8d-9254-ae9475de9b17}'
		add_BrowserProcessExited(eventHandler) => (ComCall(12, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2BrowserProcessExitedEventHandler
		remove_BrowserProcessExited(token) => ComCall(13, this, 'int64', token)

		static IID_6 := '{e59ee362-acbd-4857-9a8e-d3644d9459a9}'
		CreatePrintSettings() => (ComCall(14, this, 'ptr*', printSettings := WebView2.PrintSettings()), printSettings)

		static IID_7 := '{43C22296-3BBD-43A4-9C00-5C0DF6DD29A2}'
		UserDataFolder => (ComCall(15, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		static IID_8 := '{D6EB91DD-C3D2-45E5-BD29-6DC2BC4DE9CF}'
		add_ProcessInfosChanged(eventHandler) => (ComCall(16, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2ProcessInfosChangedEventHandler
		remove_ProcessInfosChanged(token) => ComCall(17, this, 'int64', token)
		GetProcessInfos() => (ComCall(18, this, 'ptr*', value := WebView2.ProcessInfoCollection()), value)

		static IID_9 := '{f06f41bf-4b5a-49d8-b9f6-fa16cd29f274}'
		CreateContextMenuItem(label, iconStream, kind) => (ComCall(19, this, 'wstr', label, 'ptr', iconStream, 'int', kind, 'ptr', item := WebView2.ContextMenuItem()), item)	; IStream*, COREWEBVIEW2_CONTEXT_MENU_ITEM_KIND

		static IID_10 := '{ee0eb9df-6f12-46ce-b53f-3f47b9c928e0}'
		CreateCoreWebView2ControllerOptions() => (ComCall(20, this, 'ptr', options := WebView2.ControllerOptions()), options)
		CreateCoreWebView2ControllerWithOptions(parentWindow, options, handler) => ComCall(21, this, 'ptr', parentWindow, 'ptr', options, 'ptr', handler)	; ICoreWebView2ControllerOptions, ICoreWebView2CreateCoreWebView2ControllerCompletedHandler
		CreateCoreWebView2CompositionControllerWithOptions(parentWindow, options, handler) => ComCall(22, this, 'ptr', parentWindow, 'ptr', options, 'ptr', handler)	; ICoreWebView2ControllerOptions, ICoreWebView2CreateCoreWebView2CompositionControllerCompletedHandler

		static IID_11 := '{F0913DC6-A0EC-42EF-9805-91DFF3A2966A}'
		FailureReportFolderPath => (ComCall(23, this, 'ptr*', &value := 0), CoTaskMem_String(value))

		static IID_12 := '{F503DB9B-739F-48DD-B151-FDFCF253F54E}'
		CreateSharedBuffer(size) => (ComCall(24, this, 'uint64', size, 'ptr', shared_buffer := WebView2.SharedBuffer()), shared_buffer)
	}
	class EnvironmentOptions extends Buffer {
		/**
		 * @param {Object} opts Options used to create WebView2 Environment.
		 * @param {String} opts.AdditionalBrowserArguments Changes the behavior of the WebView.
		 * @param {Bool} opts.AllowSingleSignOnUsingOSPrimaryAccount The AllowSingleSignOnUsingOSPrimaryAccount property is used to enable single sign on with Azure Active Directory (AAD) and personal Microsoft Account (MSA) resources inside WebView.
		 * @param {String} opts.Language The default display language for WebView.
		 * @param {String} opts.TargetCompatibleBrowserVersion Specifies the version of the WebView2 Runtime binaries required to be compatible with your app.
		 * @param {Bool} opts.ExclusiveUserDataFolderAccess Whether other processes can create WebView2 from WebView2Environment created with the same user data folder and therefore sharing the same WebView browser process instance.
		 * @param {Bool} opts.IsCustomCrashReportingEnabled When IsCustomCrashReportingEnabled is set to TRUE, Windows won't send crash data to Microsoft endpoint.
		 * @param {Array} opts.CustomSchemeRegistrations Array of custom scheme registrations.
		 * @param {Bool} opts.EnableTrackingPrevention The EnableTrackingPrevention property is used to enable/disable tracking prevention feature in WebView2.
		 */
		__New(opts) {
			cbs := [
				; options
				QueryInterface, AddRef, Release,
				get_xxx_str.Bind('AdditionalBrowserArguments'), put_xxx,
				get_xxx_str.Bind('Language'), put_xxx,
				get_xxx_str.Bind('TargetCompatibleBrowserVersion'), put_xxx,
				get_xxx_bool.Bind('AllowSingleSignOnUsingOSPrimaryAccount'), put_xxx,
				; options2
				QueryInterface, AddRef, Release,
				get_xxx_bool.Bind('ExclusiveUserDataFolderAccess'), put_xxx,
				;options3
				QueryInterface, AddRef, Release,
				get_xxx_bool.Bind('IsCustomCrashReportingEnabled'), put_xxx,
				; options4
				QueryInterface, AddRef, Release,
				GetCustomSchemeRegistrations, SetCustomSchemeRegistrations,
				; options5
				QueryInterface, AddRef, Release,
				get_xxx_bool.Bind('EnableTrackingPrevention'), put_xxx,
			]
			n := 5
			super.__New((n + cbs.Length) * A_PtrSize)
			p_this := ObjPtr(this), p_unk := this.Ptr, p := p_unk + n * A_PtrSize
			mp := Map(), fnptrs := [], this.DefineProp('__Delete', { call: __Delete })
			for cb in cbs {
				if cb == QueryInterface
					NumPut('ptr', p, this, (A_Index - 1) * A_PtrSize)
				p := NumPut('ptr', mp.Get(cb, 0) || mp[cb] := CallbackCreate(cb, , cb.MinParams || 2), p)
			}
			for _, p in mp
				fnptrs.Push(p)
			QueryInterface(this, riid, ppvObject) {
				static iids := [
					'{2FDE08A8-1E9A-4766-8C05-95A9CEB9D1C5}',
					'{1821A568-A141-4D77-B3D8-2878E383D8DD}',
					'{4A5C436E-A9E3-4A2E-89C3-910D3513F5CC}',
					'{ac52d13f-0d38-475a-9dca-876580d6793e}',
					'{0AE35D64-C47F-4464-814E-259C345D1501}'
				]
				DllCall("ole32.dll\StringFromGUID2", "ptr", riid, "ptr", buf := Buffer(78), "int", 39)
				iid := StrGet(buf)
				for s in iids {
					if s = iid {
						ObjAddRef(p_this)
						NumPut('ptr', p_unk + (A_Index - 1) * A_PtrSize, ppvObject)
						return 0
					}
				}
				NumPut('ptr', 0, ppvObject)
				return 0x80004002
			}
			AddRef(this) => ObjAddRef(p_this)
			Release(this) => ObjRelease(p_this)
			put_xxx(this, value) => 0
			get_xxx_str(prop, this, pvalue) {
				if opts.HasOwnProp(prop) {
					pm := DllCall('ole32\CoTaskMemAlloc', 'uptr', s := StrLen(v := this.%prop%) * 2 + 2, 'ptr')
					DllCall('RtlMoveMemory', 'ptr', p, 'ptr', StrPtr(v), 'uptr', s)
				} else pm := 0
				return (NumPut('ptr', pm, pvalue), 0)
			}
			get_xxx_bool(prop, this, pvalue) {
				if opts.HasOwnProp(prop)
					v := !opts.%prop%
				else v := 0
				return (NumPut('int', v, pvalue), 0)
			}
			GetCustomSchemeRegistrations(this, pcount, pschemeRegistrations) {
				if opts.HasOwnProp('CustomSchemeRegistrations') && (csrs := opts.CustomSchemeRegistrations).Length {
					NumPut('uint', csrs.Length, pcount)
					NumPut('ptr', pm := DllCall('ole32\CoTaskMemAlloc', 'uptr', csrs.Length * A_PtrSize, 'ptr'), pschemeRegistrations)
					for csr in csrs
						ObjPtrAddRef(csr), pm := NumPut('ptr', csr.Ptr, pm)
				} else NumPut('uint', 0, pcount), NumPut('ptr', 0, pschemeRegistrations)
				return 0
			}
			SetCustomSchemeRegistrations(this, count, schemeRegistrations) => 0
			__Delete(*) {
				for ptr in fnptrs
					CallbackFree(ptr)
			}
		}
	}
	class Frame extends WebView2.Base {
		static IID := '{f1131a5e-9ba9-11eb-a8b3-0242ac130003}'
		AddAHKObjHelper() => this.AddHostObjectToScriptWithOrigins('AHKObjHelper', WebView2.AHKObjHelper())
		Name => (ComCall(3, this, 'ptr*', &name := 0), CoTaskMem_String(name))
		add_NameChanged(eventHandler) => (ComCall(4, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameNameChangedEventHandler
		remove_NameChanged(token) => ComCall(5, this, 'int64', token)
		AddHostObjectToScriptWithOrigins(name, object, originsArr*) {
			if originsCount := originsArr.Length {
				p := (origins := Buffer(originsCount * A_PtrSize)).Ptr
				loop originsCount
					p := NumPut('ptr', StrPtr(originsArr[A_Index]), p)
			}
			ComCall(6, this, 'wstr', name, 'ptr', ComVar(object), 'uint', originsCount, 'ptr', origins)	; LPCWSTR*
		}
		RemoveHostObjectFromScript(name) => ComCall(7, this, 'wstr', name)
		add_Destroyed(eventHandler) => (ComCall(8, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameDestroyedEventHandler
		remove_Destroyed(token) => ComCall(9, this, 'int64', token)
		IsDestroyed() => (ComCall(10, this, 'int*', &destroyed := 0), destroyed)

		static IID_2 := '{7a6a5834-d185-4dbf-b63f-4a9bc43107d4}'
		add_NavigationStarting(eventHandler) => (ComCall(11, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameNavigationStartingEventHandler
		remove_NavigationStarting(token) => ComCall(12, this, 'int64', token)
		add_ContentLoading(eventHandler) => (ComCall(13, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameContentLoadingEventHandler
		remove_ContentLoading(token) => ComCall(14, this, 'int64', token)
		add_NavigationCompleted(eventHandler) => (ComCall(15, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameNavigationCompletedEventHandler
		remove_NavigationCompleted(token) => ComCall(16, this, 'int64', token)
		add_DOMContentLoaded(eventHandler) => (ComCall(17, this, 'ptr', eventHandler, 'int64*', &token := 0), token)	; ICoreWebView2FrameDOMContentLoadedEventHandler
		remove_DOMContentLoaded(token) => ComCall(18, this, 'int64', token)
		ExecuteScript(javaScript, handler) => ComCall(19, this, 'wstr', javaScript, 'ptr', handler)	; ICoreWebView2ExecuteScriptCompletedHandler
		PostWebMessageAsJson(webMessageAsJson) => ComCall(20, this, 'wstr', webMessageAsJson)
		PostWebMessageAsString(webMessageAsString) => ComCall(21, this, 'wstr', webMessageAsString)
		add_WebMessageReceived(handler) => (ComCall(22, this, 'ptr', handler, 'int64*', &token := 0), token)	; ICoreWebView2FrameWebMessageReceivedEventHandler
		remove_WebMessageReceived(token) => ComCall(23, this, 'int64', token)

		static IID_3 := '{b50d82cc-cc28-481d-9614-cb048895e6a0}'
		add_PermissionRequested(handler) => (ComCall(24, this, 'ptr', handler, 'int64*', &token := 0), token)	; ICoreWebView2FramePermissionRequestedEventHandler
		remove_PermissionRequested(token) => ComCall(25, this, 'int64', token)

		static IID_4 := '{188782DC-92AA-4732-AB3C-FCC59F6F68B9}'
		PostSharedBufferToScript(sharedBuffer, access, additionalDataAsJson) => ComCall(26, this, 'ptr', sharedBuffer, 'int', access, 'wstr', additionalDataAsJson)
	}
	class FrameCreatedEventArgs extends WebView2.Base {
		static IID := '{4d6e7b5e-9baa-11eb-a8b3-0242ac130003}'
		Frame => (ComCall(3, this, 'ptr*', frame := WebView2.Frame()), frame)
	}
	class FrameInfo extends WebView2.Base {
		static IID := '{da86b8a1-bdf3-4f11-9955-528cefa59727}'
		Name => (ComCall(3, this, 'ptr*', &name := 0), CoTaskMem_String(name))
		Source => (ComCall(4, this, 'ptr*', &source := 0), CoTaskMem_String(source))
	}
	class FrameInfoCollection extends WebView2.Base {
		static IID := '{8f834154-d38e-4d90-affb-6800a7272839}'
		GetIterator() => (ComCall(3, this, 'ptr*', iterator := WebView2.FrameInfoCollectionIterator()), iterator)
	}
	class FrameInfoCollectionIterator extends WebView2.Base {
		static IID := '{1bf89e2d-1b2b-4629-b28f-05099b41bb03}'
		HasCurrent => (ComCall(3, this, 'int*', &hasCurrent := 0), hasCurrent)
		GetCurrent() => (ComCall(4, this, 'ptr*', frameInfo := WebView2.FrameInfo()), frameInfo)
		MoveNext() => (ComCall(5, this, 'int*', &hasNext := 0), hasNext)
	}
	class Handler extends Buffer {
		/**
		 * Construct ICoreWebView2 Event or Completed Handler.
		 * @param invoke_cb Invoke function of handler.
		 * The first parameter of the callback function is the event interface pointer.
		 * @see https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2acceleratorkeypressedeventhandler
		 */
		__New(invoke_cb, paramcount?) {
			super.__New(6 * A_PtrSize)
			NumPut('ptr', this.Ptr + 2 * A_PtrSize, 'ptr', p := ObjPtr(this), this)
			for cb in [QueryInterface, AddRef, Release]
				NumPut('ptr', CallbackCreate(cb), this, (A_Index + 1) * A_PtrSize)
			NumPut('ptr', CallbackCreate(invoke_cb, , paramcount?), this, 5 * A_PtrSize)

			QueryInterface(interface, riid, ppvObject) {

			}
			AddRef(this) => ObjAddRef(NumGet(this, A_PtrSize, 'ptr'))
			Release(this) => ObjRelease(NumGet(this, A_PtrSize, 'ptr'))
		}
		__Delete() {
			loop 4
				CallbackFree(NumGet(this, (A_Index + 1) * A_PtrSize, 'ptr'))
		}
	}
	class HttpHeadersCollectionIterator extends WebView2.Base {
		static IID := '{0702fc30-f43b-47bb-ab52-a42cb552ad9f}'
		GetCurrentHeader(&name, &value) {
			ComCall(3, this, 'ptr*', &name := 0, 'ptr*', &value := 0)
			name := CoTaskMem_String(name), value := CoTaskMem_String(value)
		}
		HasCurrentHeader => (ComCall(4, this, 'int*', &hasCurrent := 0), hasCurrent)
		MoveNext() => (ComCall(5, this, 'int*', &hasNext := 0), hasNext)
	}
	class HttpRequestHeaders extends WebView2.Base {
		static IID := '{e86cac0e-5523-465c-b536-8fb9fc8c8c60}'
		GetHeader(name) => (ComCall(3, this, 'wstr', name, 'ptr*', &value := 0), CoTaskMem_String(value))
		GetHeaders(name) => (ComCall(4, this, 'wstr', name, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)
		RetVal(name) => (ComCall(5, this, 'wstr', name, 'int*', &RetVal := 0), RetVal)
		SetHeader(name, value) => ComCall(6, this, 'wstr', name, 'wstr', value)
		RemoveHeader(name) => ComCall(7, this, 'wstr', name)
		GetIterator() => (ComCall(8, this, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)
	}
	class HttpResponseHeaders extends WebView2.Base {
		static IID := '{03c5ff5a-9b45-4a88-881c-89a9f328619c}'
		AppendHeader(name, value) => ComCall(3, this, 'wstr', name, 'wstr', value)
		RetVal(name) => (ComCall(4, this, 'wstr', name, 'int*', &RetVal := 0), RetVal)
		GetHeader(name) => (ComCall(5, this, 'wstr', name, 'ptr*', &value := 0), CoTaskMem_String(value))
		GetHeaders(name) => (ComCall(6, this, 'wstr', name, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)
		GetIterator() => (ComCall(7, this, 'ptr*', iterator := WebView2.HttpHeadersCollectionIterator()), iterator)
	}
	class MoveFocusRequestedEventArgs extends WebView2.Base {
		static IID := '{2d6aa13b-3839-4a15-92fc-d88b3c0d9c9d}'
		Reason => (ComCall(3, this, 'int*', &reason := 0), reason)	; COREWEBVIEW2_MOVE_FOCUS_REASON
		Handled {
			get => (ComCall(4, this, 'int*', &value := 0), value)
			set => ComCall(5, this, 'int', Value)
		}
	}
	class NavigationCompletedEventArgs extends WebView2.Base {
		static IID := '{30d68b7d-20d9-4752-a9ca-ec8448fbb5c1}'
		IsSuccess => (ComCall(3, this, 'int*', &isSuccess := 0), isSuccess)
		WebErrorStatus => (ComCall(4, this, 'int*', &webErrorStatus := 0), webErrorStatus)	; COREWEBVIEW2_WEB_ERROR_STATUS
		NavigationId => (ComCall(5, this, 'int64*', &navigationId := 0), navigationId)

		static IID_2 := '{FDF8B738-EE1E-4DB2-A329-8D7D7B74D792}'
		HttpStatusCode => (ComCall(6, this, 'int*', &http_status_code := 0), http_status_code)
	}
	class NavigationStartingEventArgs extends WebView2.Base {
		static IID := '{5b495469-e119-438a-9b18-7604f25f2e49}'
		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
		IsUserInitiated => (ComCall(4, this, 'int*', &isUserInitiated := 0), isUserInitiated)
		IsRedirected => (ComCall(5, this, 'int*', &isRedirected := 0), isRedirected)
		RequestHeaders => (ComCall(6, this, 'ptr*', requestHeaders := WebView2.HttpRequestHeaders()), requestHeaders)
		Cancel {
			get => (ComCall(7, this, 'int*', &cancel := 0), cancel)
			set => ComCall(8, this, 'int', Value)
		}
		NavigationId => (ComCall(9, this, 'int64*', &navigationId := 0), navigationId)

		static IID_2 := '{9086BE93-91AA-472D-A7E0-579F2BA006AD}'
		AdditionalAllowedFrameAncestors {
			get => (ComCall(10, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(11, this, 'wstr', Value)
		}
	}
	class NewWindowRequestedEventArgs extends WebView2.Base {
		static IID := '{34acb11c-fc37-4418-9132-f9c21d1eafb9}'
		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
		NewWindow {
			set => ComCall(4, this, 'ptr', Value)
			get => (ComCall(5, this, 'ptr*', newWindow := WebView2.Core()), newWindow)
		}
		Handled {
			set => ComCall(6, this, 'int', Value)
			get => (ComCall(7, this, 'int*', &handled := 0), handled)
		}
		IsUserInitiated => (ComCall(8, this, 'int*', &isUserInitiated := 0), isUserInitiated)
		GetDeferral() => (ComCall(9, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
		WindowFeatures => (ComCall(10, this, 'ptr*', value := WebView2.WindowFeatures()), value)

		static IID_2 := '{bbc7baed-74c6-4c92-b63a-7f5aeae03de3}'
		Name => (ComCall(11, this, 'ptr*', &value := 0), CoTaskMem_String(value))
	}
	class PermissionRequestedEventArgs extends WebView2.Base {
		static IID := '{973ae2ef-ff18-4894-8fb2-3c758f046810}'
		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
		PermissionKind => (ComCall(4, this, 'int*', &permissionKind := 0), permissionKind)	; COREWEBVIEW2_PERMISSION_KIND
		IsUserInitiated => (ComCall(5, this, 'int*', &isUserInitiated := 0), isUserInitiated)
		State {
			get => (ComCall(6, this, 'int*', &state := 0), state)	; COREWEBVIEW2_PERMISSION_STATE
			set => ComCall(7, this, 'int', Value)
		}
		GetDeferral() => (ComCall(8, this, 'ptr*', deferral := WebView2.Deferral()), deferral)

		static IID_2 := '{74d7127f-9de6-4200-8734-42d6fb4ff741}'
		Handled {
			get => (ComCall(9, this, 'int*', &handled := 0), handled)
			set => ComCall(10, this, 'int', Value)
		}

		static IID_3 := '{e61670bc-3dce-4177-86d2-c629ae3cb6ac}'
		SavesInProfile {
			get => (ComCall(11, this, 'int*', &value := 0), value)
			set => ComCall(12, this, 'int', Value)
		}
	}
	class PermissionSetting extends WebView2.Base {
		static IID := '{792b6eca-5576-421c-9119-74ebb3a4ffb3}'
		PermissionKind => (ComCall(3, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PERMISSION_KIND
		PermissionOrigin => (ComCall(4, this, 'int*', &value := 0), CoTaskMem_String(value))
		PermissionState => (ComCall(5, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PERMISSION_STATE
	}
	class PermissionSettingCollectionView extends WebView2.Base {
		static IID := '{f5596f62-3de5-47b1-91e8-a4104b596b96}'
		__Item[index] => this.GetValueAtIndex(index)
		GetValueAtIndex(index) => (ComCall(3, this, 'ptr*', permissionSetting := WebView2.PermissionSetting()), permissionSetting)
		Count => (ComCall(4, this, 'uint*', &value := 0), value)
	}
	class PointerInfo extends WebView2.Base {
		static IID := '{e6995887-d10d-4f5d-9359-4ce46e4f96b9}'
		PointerKind {
			get => (ComCall(3, this, 'uint*', &pointerKind := 0), pointerKind)
			set => ComCall(4, this, 'uint', Value)
		}
		PointerId {
			get => (ComCall(5, this, 'uint*', &pointerId := 0), pointerId)
			set => ComCall(6, this, 'uint', Value)
		}
		FrameId {
			get => (ComCall(7, this, 'uint*', &frameId := 0), frameId)
			set => ComCall(8, this, 'uint', Value)
		}
		PointerFlags {
			get => (ComCall(9, this, 'uint*', &pointerFlags := 0), pointerFlags)
			set => ComCall(10, this, 'uint', Value)
		}
		PointerDeviceRect {
			get => (ComCall(11, this, 'ptr', pointerDeviceRect := Buffer(16)), pointerDeviceRect)
			set => (A_PtrSize = 8 ? ComCall(12, this, 'ptr', Value) : ComCall(12, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}
		DisplayRect {
			get => (ComCall(13, this, 'ptr', displayRect := Buffer(16)), displayRect)
			set => (A_PtrSize = 8 ? ComCall(14, this, 'ptr', Value) : ComCall(14, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}
		PixelLocation {
			get => (ComCall(15, this, 'int64*', &pixelLocation := 0), pixelLocation)
			set => ComCall(16, this, 'int64', Value)
		}
		HimetricLocation {
			get => (ComCall(17, this, 'int64*', &himetricLocation := 0), himetricLocation)
			set => ComCall(18, this, 'int64', Value)
		}
		PixelLocationRaw {
			get => (ComCall(19, this, 'int64*', &pixelLocationRaw := 0), pixelLocationRaw)
			set => ComCall(20, this, 'int64', Value)
		}
		HimetricLocationRaw {
			get => (ComCall(21, this, 'int64*', &himetricLocationRaw := 0), himetricLocationRaw)
			set => ComCall(22, this, 'int64', Value)
		}
		Time {
			get => (ComCall(23, this, 'uint*', &time := 0), time)
			set => ComCall(24, this, 'uint', Value)
		}
		HistoryCount {
			get => (ComCall(25, this, 'uint*', &historyCount := 0), historyCount)
			set => ComCall(26, this, 'uint', Value)
		}
		InputData {
			get => (ComCall(27, this, 'int*', &inputData := 0), inputData)
			set => ComCall(28, this, 'int', Value)
		}
		KeyStates {
			get => (ComCall(29, this, 'uint*', &keyStates := 0), keyStates)
			set => ComCall(30, this, 'uint', Value)
		}
		PerformanceCount {
			get => (ComCall(31, this, 'uint64*', &performanceCount := 0), performanceCount)
			set => ComCall(32, this, 'uint64', Value)
		}
		ButtonChangeKind {
			get => (ComCall(33, this, 'int*', &buttonChangeKind := 0), buttonChangeKind)
			set => ComCall(34, this, 'int', Value)
		}
		PenFlags {
			get => (ComCall(35, this, 'uint*', &penFLags := 0), penFLags)
			set => ComCall(36, this, 'uint', Value)
		}
		PenMask {
			get => (ComCall(37, this, 'uint*', &penMask := 0), penMask)
			set => ComCall(38, this, 'uint', Value)
		}
		PenPressure {
			get => (ComCall(39, this, 'uint*', &penPressure := 0), penPressure)
			set => ComCall(40, this, 'uint', Value)
		}
		PenRotation {
			get => (ComCall(41, this, 'uint*', &penRotation := 0), penRotation)
			set => ComCall(42, this, 'uint', Value)
		}
		PenTiltX {
			get => (ComCall(43, this, 'int*', &penTiltX := 0), penTiltX)
			set => ComCall(44, this, 'int', Value)
		}
		PenTiltY {
			get => (ComCall(45, this, 'int*', &penTiltY := 0), penTiltY)
			set => ComCall(46, this, 'int', Value)
		}
		TouchFlags {
			get => (ComCall(47, this, 'uint*', &touchFlags := 0), touchFlags)
			set => ComCall(48, this, 'uint', Value)
		}
		TouchMask {
			get => (ComCall(49, this, 'uint*', &touchMask := 0), touchMask)
			set => ComCall(50, this, 'uint', Value)
		}
		TouchContact {
			get => (ComCall(51, this, 'ptr', touchContact := Buffer(16)), touchContact)
			set => (A_PtrSize = 8 ? ComCall(52, this, 'ptr', Value) : ComCall(52, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}
		TouchContactRaw {
			get => (ComCall(53, this, 'ptr', touchContactRaw := Buffer(16)), touchContactRaw)
			set => (A_PtrSize = 8 ? ComCall(54, this, 'ptr', Value) : ComCall(54, this, 'int64', NumGet(Value, 'int64'), 'int64', NumGet(Value, 8, 'int64')))
		}
		TouchOrientation {
			get => (ComCall(55, this, 'uint*', &touchOrientation := 0), touchOrientation)
			set => ComCall(56, this, 'uint', Value)
		}
		TouchPressure {
			get => (ComCall(57, this, 'uint*', &touchPressure := 0), touchPressure)
			set => ComCall(58, this, 'uint', Value)
		}
	}
	class PrintSettings extends WebView2.Base {
		static IID := '{377f3721-c74e-48ca-8db1-df68e51d60e2}'
		Orientation {
			get => (ComCall(3, this, 'int*', &orientation := 0), orientation)
			set => ComCall(4, this, 'int', Value)
		}
		ScaleFactor {
			get => (ComCall(5, this, 'double*', &scaleFactor := 0), scaleFactor)
			set => ComCall(6, this, 'double', Value)
		}
		PageWidth {
			get => (ComCall(7, this, 'double*', &pageWidth := 0), pageWidth)
			set => ComCall(8, this, 'double', Value)
		}
		PageHeight {
			get => (ComCall(9, this, 'double*', &pageHeight := 0), pageHeight)
			set => ComCall(10, this, 'double', Value)
		}
		MarginTop {
			get => (ComCall(11, this, 'double*', &marginTop := 0), marginTop)
			set => ComCall(12, this, 'double', Value)
		}
		MarginBottom {
			get => (ComCall(13, this, 'double*', &marginBottom := 0), marginBottom)
			set => ComCall(14, this, 'double', Value)
		}
		MarginLeft {
			get => (ComCall(15, this, 'double*', &marginLeft := 0), marginLeft)
			set => ComCall(16, this, 'double', Value)
		}
		MarginRight {
			get => (ComCall(17, this, 'double*', &marginRight := 0), marginRight)
			set => ComCall(18, this, 'double', Value)
		}
		ShouldPrintBackgrounds {
			get => (ComCall(19, this, 'int*', &shouldPrintBackgrounds := 0), shouldPrintBackgrounds)
			set => ComCall(20, this, 'int', Value)
		}
		ShouldPrintSelectionOnly {
			get => (ComCall(21, this, 'int*', &shouldPrintSelectionOnly := 0), shouldPrintSelectionOnly)
			set => ComCall(22, this, 'int', Value)
		}
		ShouldPrintHeaderAndFooter {
			get => (ComCall(23, this, 'int*', &shouldPrintHeaderAndFooter := 0), shouldPrintHeaderAndFooter)
			set => ComCall(24, this, 'int', Value)
		}
		HeaderTitle {
			get => (ComCall(25, this, 'ptr*', &headerTitle := 0), CoTaskMem_String(headerTitle))
			set => ComCall(26, this, 'wstr', Value)
		}
		FooterUri {
			get => (ComCall(27, this, 'ptr*', &footerUri := 0), CoTaskMem_String(footerUri))
			set => ComCall(28, this, 'wstr', Value)
		}

		static IID_2 := '{CA7F0E1F-3484-41D1-8C1A-65CD44A63F8D}'
		PageRanges {
			get => (ComCall(29, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(30, this, 'wstr', Value)
		}
		PagesPerSide {
			get => (ComCall(31, this, 'int*', &value := 0), value)
			set => ComCall(32, this, 'int', Value)
		}
		Copies {
			get => (ComCall(33, this, 'int*', &value := 0), value)
			set => ComCall(34, this, 'int', Value)
		}
		Collation {
			get => (ComCall(35, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PRINT_COLLATION
			set => ComCall(36, this, 'int', Value)
		}
		ColorMode {
			get => (ComCall(37, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PRINT_COLOR_MODE
			set => ComCall(38, this, 'int', Value)
		}
		Duplex {
			get => (ComCall(39, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PRINT_DUPLEX
			set => ComCall(40, this, 'int', Value)
		}
		MediaSize {
			get => (ComCall(41, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PRINT_MEDIA_SIZE
			set => ComCall(42, this, 'int', Value)
		}
		PrinterName {
			get => (ComCall(43, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(44, this, 'wstr', Value)
		}
	}
	class ProcessInfo extends WebView2.Base {
		static IID := '{84FA7612-3F3D-4FBF-889D-FAD000492D72}'
		ProcessId => (ComCall(3, this, 'int*', &value := 0), value)
		Kind => (ComCall(4, this, 'int*', &kind := 0), kind)	; COREWEBVIEW2_PROCESS_KIND
	}
	class ProcessInfoCollection extends WebView2.Base {
		static IID := '{402B99CD-A0CC-4FA5-B7A5-51D86A1D2339}'
		__Item[index] => this.GetValueAtIndex(index)
		Count => (ComCall(3, this, 'uint*', &count := 0), count)
		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', processInfo := WebView2.ProcessInfo()), processInfo)
	}
	class Profile extends WebView2.Base {
		static IID := '{79110ad3-cd5d-4373-8bc3-c60658f17a5f}'
		ProfileName => (ComCall(3, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		IsInPrivateModeEnabled => (ComCall(4, this, 'int*', &value := 0), value)
		ProfilePath => (ComCall(5, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		DefaultDownloadFolderPath {
			get => (ComCall(6, this, 'ptr*', &value := 0), CoTaskMem_String(value))
			set => ComCall(7, this, 'wstr', Value)
		}
		PreferredColorScheme {
			get => (ComCall(8, this, 'int*', &value := 0), value)	; COREWEBVIEW2_PREFERRED_COLOR_SCHEME
			set => ComCall(9, this, 'int', Value)
		}

		static IID_2 := '{fa740d4b-5eae-4344-a8ad-74be31925397}'
		ClearBrowsingData(dataKinds, handler) => ComCall(10, this, 'int', dataKinds, 'ptr', handler)	; COREWEBVIEW2_BROWSING_DATA_KINDS, ICoreWebView2ClearBrowsingDataCompletedHandler
		ClearBrowsingDataInTimeRange(dataKinds, startTime, endTime, handler) => ComCall(11, this, 'int', dataKinds, 'double', startTime, 'double', endTime, 'ptr', handler)	; COREWEBVIEW2_BROWSING_DATA_KINDS, ICoreWebView2ClearBrowsingDataCompletedHandler
		ClearBrowsingDataAll(handler) => ComCall(12, this, 'ptr', handler)	; ICoreWebView2ClearBrowsingDataCompletedHandler

		static IID_3 := '{B188E659-5685-4E05-BDBA-FC640E0F1992}'
		PreferredTrackingPreventionLevel {
			get => (ComCall(13, this, 'int*', &value := 0), value)	; COREWEBVIEW2_TRACKING_PREVENTION_LEVEL
			set => ComCall(14, this, 'int', Value)
		}

		static IID_4 := '{8F4ae680-192e-4eC8-833a-21cfadaef628}'
		SetPermissionState(permissionKind, origin, state, completedHandler) => ComCall(15, this, 'int', permissionKind, 'wstr', origin, 'int', state, 'ptr', completedHandler)	; COREWEBVIEW2_PERMISSION_KIND,, COREWEBVIEW2_PERMISSION_STATE, ICoreWebView2SetPermissionStateCompletedHandler
		GetNonDefaultPermissionSettings(completedHandler) => ComCall(16, this, 'ptr', completedHandler)	; ICoreWebView2GetNonDefaultPermissionSettingsCompletedHandler
	}
	class ProcessFailedEventArgs extends WebView2.Base {
		static IID := '{8155a9a4-1474-4a86-8cae-151b0fa6b8ca}'
		ProcessFailedKind => (ComCall(3, this, 'int*', &processFailedKind := 0), processFailedKind)	; COREWEBVIEW2_PROCESS_FAILED_KIND

		static IID_2 := '{4dab9422-46fa-4c3e-a5d2-41d2071d3680}'
		Reason => (ComCall(4, this, 'int*', &reason := 0), reason)	; COREWEBVIEW2_PROCESS_FAILED_REASON
		ExitCode => (ComCall(5, this, 'int*', &exitCode := 0), exitCode)
		ProcessDescription => (ComCall(6, this, 'ptr*', &processDescription := 0), CoTaskMem_String(processDescription))
		FrameInfosForFailedProcess => (ComCall(7, this, 'ptr*', frames := WebView2.FrameInfoCollection()), frames)
	}
	class ScriptDialogOpeningEventArgs extends WebView2.Base {
		static IID := '{7390bb70-abe0-4843-9529-f143b31b03d6}'
		Uri => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
		Kind => (ComCall(4, this, 'int*', &kind := 0), kind)	; COREWEBVIEW2_SCRIPT_DIALOG_KIND
		Message => (ComCall(5, this, 'ptr*', &message := 0), CoTaskMem_String(message))
		Accept() => ComCall(6, this)
		DefaultText => (ComCall(7, this, 'ptr*', &defaultText := 0), CoTaskMem_String(defaultText))
		ResultText {
			get => (ComCall(8, this, 'ptr*', &resultText := 0), CoTaskMem_String(resultText))
			set => ComCall(9, this, 'wstr', Value)
		}
		GetDeferral() => (ComCall(10, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}
	class ServerCertificateErrorDetectedEventArgs extends WebView2.Base {
		static IID := '{012193ED-7C13-48FF-969D-A84C1F432A14}'
		ErrorStatus => (ComCall(3, this, 'int*', &value := 0), value)
		RequestUri => (ComCall(4, this, 'ptr*', &value := 0), CoTaskMem_String(value))
		ServerCertificate => (ComCall(5, this, 'ptr*', value := WebView2.Certificate()), value)
		Action {
			get => (ComCall(6, this, 'int*', &value := 0), value)	; COREWEBVIEW2_SERVER_CERTIFICATE_ERROR_ACTION
			set => ComCall(7, this, 'int', Value)
		}
		GetDeferral() => (ComCall(8, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
	}
	class Settings extends WebView2.Base {
		static IID := '{e562e4f0-d7fa-43ac-8d71-c05150499f00}'
		IsScriptEnabled {
			get => (ComCall(3, this, 'int*', &isScriptEnabled := 0), isScriptEnabled)
			set => ComCall(4, this, 'int', Value)
		}
		IsWebMessageEnabled {
			get => (ComCall(5, this, 'int*', &isWebMessageEnabled := 0), isWebMessageEnabled)
			set => ComCall(6, this, 'int', Value)
		}
		AreDefaultScriptDialogsEnabled {
			get => (ComCall(7, this, 'int*', &areDefaultScriptDialogsEnabled := 0), areDefaultScriptDialogsEnabled)
			set => ComCall(8, this, 'int', Value)
		}
		IsStatusBarEnabled {
			get => (ComCall(9, this, 'int*', &isStatusBarEnabled := 0), isStatusBarEnabled)
			set => ComCall(10, this, 'int', Value)
		}
		AreDevToolsEnabled {
			get => (ComCall(11, this, 'int*', &areDevToolsEnabled := 0), areDevToolsEnabled)
			set => ComCall(12, this, 'int', Value)
		}
		AreDefaultContextMenusEnabled {
			get => (ComCall(13, this, 'int*', &enabled := 0), enabled)
			set => ComCall(14, this, 'int', Value)
		}
		AreHostObjectsAllowed {
			get => (ComCall(15, this, 'int*', &allowed := 0), allowed)
			set => ComCall(16, this, 'int', Value)
		}
		IsZoomControlEnabled {
			get => (ComCall(17, this, 'int*', &enabled := 0), enabled)
			set => ComCall(18, this, 'int', Value)
		}
		IsBuiltInErrorPageEnabled {
			get => (ComCall(19, this, 'int*', &enabled := 0), enabled)
			set => ComCall(20, this, 'int', Value)
		}

		static IID_2 := '{ee9a0f68-f46c-4e32-ac23-ef8cac224d2a}'
		UserAgent {
			get => (ComCall(21, this, 'ptr*', &userAgent := 0), CoTaskMem_String(userAgent))
			set => ComCall(22, this, 'wstr', Value)
		}

		static IID_3 := '{fdb5ab74-af33-4854-84f0-0a631deb5eba}'
		AreBrowserAcceleratorKeysEnabled {
			get => (ComCall(23, this, 'int*', &areBrowserAcceleratorKeysEnabled := 0), areBrowserAcceleratorKeysEnabled)
			set => ComCall(24, this, 'int', Value)
		}

		static IID_4 := '{cb56846c-4168-4d53-b04f-03b6d6796ff2}'
		IsPasswordAutosaveEnabled {
			get => (ComCall(25, this, 'int*', &value := 0), value)
			set => ComCall(26, this, 'int', Value)
		}
		IsGeneralAutofillEnabled {
			get => (ComCall(27, this, 'int*', &value := 0), value)
			set => ComCall(28, this, 'int', Value)
		}

		static IID_5 := '{183e7052-1d03-43a0-ab99-98e043b66b39}'
		IsPinchZoomEnabled {
			get => (ComCall(29, this, 'int*', &enabled := 0), enabled)
			set => ComCall(30, this, 'int', Value)
		}

		static IID_6 := '{11cb3acd-9bc8-43b8-83bf-f40753714f87}'
		IsSwipeNavigationEnabled {
			get => (ComCall(31, this, 'int*', &enabled := 0), enabled)
			set => ComCall(32, this, 'int', Value)
		}

		static IID_7 := '{488dc902-35ef-42d2-bc7d-94b65c4bc49c}'
		HiddenPdfToolbarItems {
			get => (ComCall(33, this, 'int*', &hidden_pdf_toolbar_items := 0), hidden_pdf_toolbar_items)	; COREWEBVIEW2_PDF_TOOLBAR_ITEMS
			set => ComCall(34, this, 'int', Value)
		}

		static IID_8 := '{9e6b0e8f-86ad-4e81-8147-a9b5edb68650}'
		IsReputationCheckingRequired {
			get => (ComCall(35, this, 'int*', &value := 0), value)
			set => ComCall(36, this, 'int', Value)
		}
	}
	class SharedBuffer extends WebView2.Base {
		static IID := '{B747A495-0C6F-449E-97B8-2F81E9D6AB43}'
		Size => (ComCall(3, this, 'uint64', &value := 0), value)
		Buffer => (ComCall(4, this, 'ptr*', &value := 0), value)
		OpenStream() => (ComCall(5, this, 'ptr*', value := ComValue(0xd, 0)), value)
		FileMappingHandle => (ComCall(6, this, 'ptr*', &value := 0), value)
		Close() => ComCall(7, this)
	}
	class SourceChangedEventArgs extends WebView2.Base {
		static IID := '{31e0e545-1dba-4266-8914-f63848a1f7d7}'
		IsNewDocument => (ComCall(3, this, 'int*', &isNewDocument := 0), isNewDocument)
	}
	class StringCollection extends WebView2.Base {
		static IID := '{f41f3f8a-bcc3-11eb-8529-0242ac130003}'
		__Item[index] => this.GetValueAtIndex(index)
		Count => (ComCall(3, this, 'uint*', &value := 0), value)
		GetValueAtIndex(index) => (ComCall(4, this, 'uint', index, 'ptr*', &value := 0), CoTaskMem_String(value))
	}
	class WebMessageReceivedEventArgs extends WebView2.Base {
		static IID := '{0f99a40c-e962-4207-9e92-e3d542eff849}'
		Source => (ComCall(3, this, 'ptr*', &source := 0), CoTaskMem_String(source))
		WebMessageAsJson => (ComCall(4, this, 'ptr*', &webMessageAsJson := 0), CoTaskMem_String(webMessageAsJson))
		TryGetWebMessageAsString() => (ComCall(5, this, 'ptr*', &webMessageAsString := 0), CoTaskMem_String(webMessageAsString))
	}
	class WebResourceRequest extends WebView2.Base {
		static IID := '{97055cd4-512c-4264-8b5f-e3f446cea6a5}'
		Uri {
			get => (ComCall(3, this, 'ptr*', &uri := 0), CoTaskMem_String(uri))
			set => ComCall(4, this, 'wstr', Value)
		}
		Method {
			get => (ComCall(5, this, 'ptr*', &method := 0), CoTaskMem_String(method))
			set => ComCall(6, this, 'wstr', Value)
		}
		Content {
			get => (ComCall(7, this, 'ptr*', &content := 0), content)	; IStream*
			set => ComCall(8, this, 'ptr', Value)
		}
		Headers => (ComCall(9, this, 'ptr*', headers := WebView2.HttpRequestHeaders()), headers)
	}
	class WebResourceRequestedEventArgs extends WebView2.Base {
		static IID := '{453e667f-12c7-49d4-be6d-ddbe7956f57a}'
		Request => (ComCall(3, this, 'ptr*', request := WebView2.WebResourceRequest()), request)
		Response {
			get => (ComCall(4, this, 'ptr*', response := WebView2.WebResourceResponse()), response)
			set => ComCall(5, this, 'ptr', Value)
		}
		GetDeferral() => (ComCall(6, this, 'ptr*', deferral := WebView2.Deferral()), deferral)
		ResourceContext => (ComCall(7, this, 'int*', &context := 0), context)	; COREWEBVIEW2_WEB_RESOURCE_CONTEXT
	}
	class WebResourceResponse extends WebView2.Base {
		static IID := '{aafcc94f-fa27-48fd-97df-830ef75aaec9}'
		Content {
			get => (ComCall(3, this, 'ptr*', &content := 0), content)	; IStream*
			set => ComCall(4, this, 'ptr', Value)
		}
		Headers => (ComCall(5, this, 'ptr*', headers := WebView2.HttpResponseHeaders()), headers)
		StatusCode {
			get => (ComCall(6, this, 'int*', &statusCode := 0), statusCode)
			set => ComCall(7, this, 'int', Value)
		}
		ReasonPhrase {
			get => (ComCall(8, this, 'ptr*', &reasonPhrase := 0), CoTaskMem_String(reasonPhrase))
			set => ComCall(9, this, 'wstr', Value)
		}
	}
	class WebResourceResponseReceivedEventArgs extends WebView2.Base {
		static IID := '{D1DB483D-6796-4B8B-80FC-13712BB716F4}'
		Request => (ComCall(3, this, 'ptr*', request := WebView2.WebResourceRequest()), request)
		Response => (ComCall(4, this, 'ptr*', response := WebView2.WebResourceResponseView()), response)
	}
	class WebResourceResponseView extends WebView2.Base {
		static IID := '{79701053-7759-4162-8F7D-F1B3F084928D}'
		Headers => (ComCall(3, this, 'ptr*', headers := WebView2.HttpResponseHeaders()), headers)
		StatusCode => (ComCall(4, this, 'int*', &statusCode := 0), statusCode)
		ReasonPhrase => (ComCall(5, this, 'ptr*', &reasonPhrase := 0), CoTaskMem_String(reasonPhrase))
		GetContent(handler) => ComCall(6, this, 'ptr', handler)	; ICoreWebView2WebResourceResponseViewGetContentCompletedHandler
	}
	class WindowFeatures extends WebView2.Base {
		static IID := '{5eaf559f-b46e-4397-8860-e422f287ff1e}'
		HasPosition => (ComCall(3, this, 'int*', &value := 0), value)
		HasSize => (ComCall(4, this, 'int*', &value := 0), value)
		Left => (ComCall(5, this, 'uint*', &value := 0), value)
		Top => (ComCall(6, this, 'uint*', &value := 0), value)
		Height => (ComCall(7, this, 'uint*', &value := 0), value)
		Width => (ComCall(8, this, 'uint*', &value := 0), value)
		ShouldDisplayMenuBar => (ComCall(9, this, 'int*', &value := 0), value)
		ShouldDisplayStatus => (ComCall(10, this, 'int*', &value := 0), value)
		ShouldDisplayToolbar => (ComCall(11, this, 'int*', &value := 0), value)
		ShouldDisplayScrollBars => (ComCall(12, this, 'int*', &value := 0), value)
	}
	;#endregion

	;#region structs
	class PHYSICAL_KEY_STATUS extends Buffer {
		__New() => super.__New(24, 0)
		RepeatCount {
			get => NumGet(this, 'uint')
			set => NumPut('uint', Value, this)
		}
		ScanCode {
			get => NumGet(this, 4, 'uint')
			set => NumPut('uint', Value, this, 4)
		}
		IsExtendedKey {
			get => NumGet(this, 8, 'int')
			set => NumPut('int', Value, this, 8)
		}
		IsMenuKeyDown {
			get => NumGet(this, 12, 'int')
			set => NumPut('int', Value, this, 12)
		}
		WasKeyDown {
			get => NumGet(this, 16, 'int')
			set => NumPut('int', Value, this, 16)
		}
		IsKeyReleased {
			get => NumGet(this, 20, 'int')
			set => NumPut('int', Value, this, 20)
		}
	}
	;#endregion

	;#region constants
	static CAPTURE_PREVIEW_IMAGE_FORMAT := { PNG: 0, JPEG: 1 }
	static CONTEXT_MENU_TARGET_KIND := {
		PAGE: 0,
		IMAGE: 1,
		SELECTED_TEXT: 2,
		AUDIO: 3,
		VIDEO: 4
	}
	static CONTEXT_MENU_ITEM_KIND := {
		COMMAND: 0,
		CHECK_BOX: 1,
		RADIO: 2,
		SEPARATOR: 3,
		SUBMENU: 4
	}
	static PREFERRED_COLOR_SCHEME := { AUTO: 0, LIGHT: 1, DARK: 2 }
	static BROWSING_DATA_KINDS := {
		FILE_SYSTEMS: (1 << 0),
		INDEXED_DB: (1 << 1),
		LOCAL_STORAGE: (1 << 2),
		WEB_SQL: (1 << 3),
		CACHE_STORAGE: (1 << 4),
		ALL_DOM_STORAGE: (1 << 5),
		COOKIES: (1 << 6),
		ALL_SITE: (1 << 7),
		DISK_CACHE: (1 << 8),
		DOWNLOAD_HISTORY: (1 << 9),
		GENERAL_AUTOFILL: (1 << 10),
		PASSWORD_AUTOSAVE: (1 << 11),
		BROWSING_HISTORY: (1 << 12),
		SETTINGS: (1 << 13),
		ALL_PROFILE: (1 << 14)
	}
	static SERVER_CERTIFICATE_ERROR_ACTION := { ALWAYS_ALLOW: 0, CANCEL: 1, DEFAULT: 2 }
	static FAVICON_IMAGE_FORMAT := { PNG: 0, JPEG: 1 }
	static PRINT_DIALOG_KIND := { BROWSER: 0, SYSTEM: 1 }
	static PRINT_DUPLEX := {
		DEFAULT: 0,
		ONE_SIDED: 1,
		TWO_SIDED_LONG_EDGE: 2,
		TWO_SIDED_SHORT_EDGE: 3
	}
	static PRINT_COLOR_MODE := { DEFAULT: 0, COLOR: 1, GRAYSCALE: 2 }
	static PRINT_COLLATION := { DEFAULT: 0, COLLATED: 1, UNCOLLATED: 2 }
	static PRINT_MEDIA_SIZE := { DEFAULT: 0, CUSTOM: 1 }
	static PRINT_STATUS := { SUCCEEDED: 0, PRINTER_UNAVAILABLE: 1, OTHER_ERROR: 2 }
	static TRACKING_PREVENTION_LEVEL := {
		NONE: 0,
		BASIC: 1,
		BALANCED: 2,
		STRICT: 3
	}
	static SHARED_BUFFER_ACCESS := { READ_ONLY: 0, READ_WRITE: 1 }
	static COOKIE_SAME_SITE_KIND := { NONE: 0, LAX: 1, STRICT: 2 }
	static HOST_RESOURCE_ACCESS_KIND := { DENY: 0, ALLOW: 1, DENY_CORS: 2 }
	static SCRIPT_DIALOG_KIND := { ALERT: 0, CONFIRM: 1, PROMPT: 2, BEFOREUNLOAD: 3 }
	static PDF_TOOLBAR_ITEMS := {
		ITEMS_NONE: 0,
		ITEMS_SAVE: 0x1,
		ITEMS_PRINT: 0x2,
		ITEMS_SAVE_AS: 0x4,
		ITEMS_ZOOM_IN: 0x8,
		ITEMS_ZOOM_OUT: 0x10,
		ITEMS_ROTATE: 0x20,
		ITEMS_FIT_PAGE: 0x40,
		ITEMS_PAGE_LAYOUT: 0x80,
		ITEMS_BOOKMARKS: 0x100,
		ITEMS_PAGE_SELECTOR: 0x200,
		ITEMS_SEARCH: 0x400,
		ITEMS_FULL_SCREEN: 0x800,
		ITEMS_MORE_SETTINGS: 0x1000
	}
	static PROCESS_FAILED_KIND := {
		BROWSER_PROCESS_EXITED: 0,
		RENDER_PROCESS_EXITED: 1,
		RENDER_PROCESS_UNRESPONSIVE: 2,
		FRAME_RENDER_PROCESS_EXITED: 3,
		UTILITY_PROCESS_EXITED: 4,
		SANDBOX_HELPER_PROCESS_EXITED: 5,
		GPU_PROCESS_EXITED: 6,
		PPAPI_PLUGIN_PROCESS_EXITED: 7,
		PPAPI_BROKER_PROCESS_EXITED: 8,
		UNKNOWN_PROCESS_EXITED: 9
	}
	static PROCESS_FAILED_REASON := {
		UNEXPECTED: 0,
		UNRESPONSIVE: 1,
		TERMINATED: 2,
		CRASHED: 3,
		LAUNCH_FAILED: 4,
		OUT_OF_MEMORY: 5,
		PROFILE_DELETED: 6
	}
	static PERMISSION_KIND := {
		UNKNOWN_PERMISSION: 0,
		MICROPHONE: 1,
		CAMERA: 2,
		GEOLOCATION: 3,
		NOTIFICATIONS: 4,
		OTHER_SENSORS: 5,
		CLIPBOARD_READ: 6,
		MULTIPLE_AUTOMATIC_DOWNLOADS: 7,
		FILE_READ_WRITE: 8,
		AUTOPLAY: 9,
		LOCAL_FONTS: 10,
		MIDI_SYSTEM_EXCLUSIVE_MESSAGES: 11,
		WINDOW_MANAGEMENT: 12
	}
	static PERMISSION_STATE := {
		DEFAULT: 0,
		ALLOW: 1,
		DENY: 2
	}
	static PROCESS_KIND := {
		BROWSER: 0,
		RENDERER: 1,
		UTILITY: 2,
		SANDBOX_HELPER: 3,
		GPU: 4,
		PPAPI_PLUGIN: 5,
		PPAPI_BROKER: 6
	}
	static WEB_ERROR_STATUS := {
		UNKNOWN: 0,
		CERTIFICATE_COMMON_NAME_IS_INCORRECT: 1,
		CERTIFICATE_EXPIRED: 2,
		CLIENT_CERTIFICATE_CONTAINS_ERRORS: 3,
		CERTIFICATE_REVOKED: 4,
		CERTIFICATE_IS_INVALID: 5,
		SERVER_UNREACHABLE: 6,
		TIMEOUT: 7,
		ERROR_HTTP_INVALID_SERVER_RESPONSE: 8,
		CONNECTION_ABORTED: 9,
		CONNECTION_RESET: 10,
		DISCONNECTED: 11,
		CANNOT_CONNECT: 12,
		HOST_NAME_NOT_RESOLVED: 13,
		OPERATION_CANCELED: 14,
		REDIRECT_FAILED: 15,
		UNEXPECTED_ERROR: 16,
		VALID_AUTHENTICATION_CREDENTIALS_REQUIRED: 17,
		VALID_PROXY_AUTHENTICATION_REQUIRED: 18
	}
	static WEB_RESOURCE_CONTEXT := {
		ALL: 0,
		DOCUMENT: 1,
		STYLESHEET: 2,
		IMAGE: 3,
		MEDIA: 4,
		FONT: 5,
		SCRIPT: 6,
		XML_HTTP_REQUEST: 7,
		FETCH: 8,
		TEXT_TRACK: 9,
		EVENT_SOURCE: 10,
		WEBSOCKET: 11,
		MANIFEST: 12,
		SIGNED_EXCHANGE: 13,
		PING: 14,
		CSP_VIOLATION_REPORT: 15,
		OTHER: 16
	}
	static MOVE_FOCUS_REASON := { PROGRAMMATIC: 0, NEXT: 1, PREVIOUS: 2 }
	static KEY_EVENT_KIND := { KEY_DOWN: 0, KEY_UP: 1, SYSTEM_KEY_DOWN: 2, SYSTEM_KEY_UP: 3 }
	static BROWSER_PROCESS_EXIT_KIND := { NORMAL: 0, FAILED: 1 }
	static MOUSE_EVENT_KIND := {
		HORIZONTAL_WHEEL: 0x20e,
		LEFT_BUTTON_DOUBLE_CLICK: 0x203,
		LEFT_BUTTON_DOWN: 0x201,
		LEFT_BUTTON_UP: 0x202,
		LEAVE: 0x2a3,
		MIDDLE_BUTTON_DOUBLE_CLICK: 0x209,
		MIDDLE_BUTTON_DOWN: 0x207,
		MIDDLE_BUTTON_UP: 0x208,
		MOVE: 0x200,
		RIGHT_BUTTON_DOUBLE_CLICK: 0x206,
		RIGHT_BUTTON_DOWN: 0x204,
		RIGHT_BUTTON_UP: 0x205,
		WHEEL: 0x20a,
		X_BUTTON_DOUBLE_CLICK: 0x20d,
		X_BUTTON_DOWN: 0x20b,
		X_BUTTON_UP: 0x20c
	}
	static MOUSE_EVENT_VIRTUAL_KEYS := {
		NONE: 0,
		LEFT_BUTTON: 0x1,
		RIGHT_BUTTON: 0x2,
		SHIFT: 0x4,
		CONTROL: 0x8,
		MIDDLE_BUTTON: 0x10,
		X_BUTTON1: 0x20,
		X_BUTTON2: 0x40
	}
	static POINTER_EVENT_KIND := {
		ACTIVATE: 0x24b,
		DOWN: 0x246,
		ENTER: 0x249,
		LEAVE: 0x24a,
		UP: 0x247,
		UPDATE: 0x245
	}
	static BOUNDS_MODE := { USE_RAW_PIXELS: 0, USE_RASTERIZATION_SCALE: 1 }
	static CLIENT_CERTIFICATE_KIND := { SMART_CARD: 0, PIN: 1, OTHER: 2 }
	static DOWNLOAD_STATE := { IN_PROGRESS: 0, INTERRUPTED: 1, COMPLETED: 2 }
	static DOWNLOAD_INTERRUPT_REASON := {
		NONE: 0,
		FILE_FAILED: 1,
		FILE_ACCESS_DENIED: 2,
		FILE_NO_SPACE: 3,
		FILE_NAME_TOO_LONG: 4,
		FILE_TOO_LARGE: 5,
		FILE_MALICIOUS: 6,
		FILE_TRANSIENT_ERROR: 7,
		FILE_BLOCKED_BY_POLICY: 8,
		FILE_SECURITY_CHECK_FAILED: 9,
		FILE_TOO_SHORT: 10,
		FILE_HASH_MISMATCH: 11,
		NETWORK_FAILED: 12,
		NETWORK_TIMEOUT: 13,
		NETWORK_DISCONNECTED: 14,
		NETWORK_SERVER_DOWN: 15,
		NETWORK_INVALID_REQUEST: 16,
		SERVER_FAILED: 17,
		SERVER_NO_RANGE: 18,
		SERVER_BAD_CONTENT: 19,
		SERVER_UNAUTHORIZED: 20,
		SERVER_CERTIFICATE_PROBLEM: 21,
		SERVER_FORBIDDEN: 22,
		SERVER_UNEXPECTED_RESPONSE: 23,
		SERVER_CONTENT_LENGTH_MISMATCH: 24,
		SERVER_CROSS_ORIGIN_REDIRECT: 25,
		USER_CANCELED: 26,
		USER_SHUTDOWN: 27,
		USER_PAUSED: 28,
		DOWNLOAD_PROCESS_CRASHED: 29
	}
	static PRINT_ORIENTATION := { PORTRAIT: 0, LANDSCAPE: 1 }
	static DEFAULT_DOWNLOAD_DIALOG_CORNER_ALIGNMENT := { TOP_LEFT: 0, TOP_RIGHT: 1, BOTTOM_LEFT: 2, BOTTOM_RIGHT: 3 }
	;#endregion
}
CoTaskMem_String(ptr) {
	s := StrGet(ptr), DllCall('ole32\CoTaskMemFree', 'ptr', ptr)
	return s
}
