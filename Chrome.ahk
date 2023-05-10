/************************************************************************
 * @description: Modify from G33kDude's Chrome.ahk v1
 * @author thqby
 * @date 2023/05/10
 * @version 1.0.4
 ***********************************************************************/

class Chrome {
	static _http := ComObject('WinHttp.WinHttpRequest.5.1'), Prototype.NewTab := this.Prototype.NewPage
	static FindInstance(exename := 'Chrome.exe', debugport := 0) {
		items := Map(), filter_items := Map()
		for item in ComObjGet('winmgmts:').ExecQuery("SELECT CommandLine, ProcessID FROM Win32_Process WHERE Name = '" exename "' AND CommandLine LIKE '% --remote-debugging-port=%'")
			(!items.Has(parentPID := ProcessGetParent(item.ProcessID)) && items[item.ProcessID] := [parentPID, item.CommandLine])
		for pid, item in items
			if !items.Has(item[1]) && (!debugport || InStr(item[2], ' --remote-debugging-port=' debugport))
				filter_items[pid] := item[2]
		for pid, cmd in filter_items
			if RegExMatch(cmd, 'i) --remote-debugging-port=(\d+)', &m)
				return { Base: this.Prototype, DebugPort: m[1], PID: pid }
	}

	/**
	 * @param ProfilePath - Path to the user profile directory to use. Will use the standard if left blank.
	 * @param URLs        - The page or array of pages for Chrome to load when it opens
	 * @param Flags       - Additional flags for Chrome when launching
	 * @param ChromePath  - Path to Chrome or Edge, will detect from start menu when left blank
	 * @param DebugPort   - What port should Chrome's remote debugging server run on
	 */
	__New(URLs := '', Flags := '', ChromePath := '', DebugPort := 9222, ProfilePath := '') {
		; Verify ChromePath
		if !ChromePath
			try FileGetShortcut A_StartMenuCommon '\Programs\Chrome.lnk', &ChromePath
			catch
				ChromePath := RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Chrome.exe',,
					'C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe')
		if !FileExist(ChromePath) && !FileExist(ChromePath := 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe')
			throw Error('Chrome/Edge could not be found')
		; Verify DebugPort
		if !IsInteger(DebugPort) || (DebugPort <= 0)
			throw Error('DebugPort must be a positive integer')
		this.DebugPort := DebugPort, URLString := ''

		SplitPath(ChromePath, &exename)
		URLs := URLs is Array ? URLs : URLs && URLs is String ? [URLs] : []
		if instance := Chrome.FindInstance(exename, DebugPort) {
			this.PID := instance.PID, http := Chrome._http
			for url in URLs
				http.Open('PUT', 'http://127.0.0.1:' this.DebugPort '/json/new?' url), http.Send()
			return
		}

		; Verify ProfilePath
		if (ProfilePath && !FileExist(ProfilePath))
			DirCreate(ProfilePath)

		; Escape the URL(s)
		for url in URLs
			URLString .= ' ' CliEscape(url)

		hasother := ProcessExist(exename)
		Run(CliEscape(ChromePath) ' --remote-debugging-port=' this.DebugPort ' --remote-allow-origins=*'
			(ProfilePath ? ' --user-data-dir=' CliEscape(ProfilePath) : '')
			(Flags ? ' ' Flags : '') URLString, , , &PID)
		if (hasother && Sleep(600) || !instance := Chrome.FindInstance(exename, this.DebugPort))
			throw Error(Format('{1:} is not running in debug mode. Try closing all {1:} processes and try again', exename))
		this.PID := PID

		CliEscape(Param) => '"' RegExReplace(Param, '(\\*)"', '$1$1\"') '"'
	}

	/**
	 * End Chrome by terminating the process.
	 */
	Kill() {
		ProcessClose(this.PID)
	}

	/**
	 * Queries Chrome for a list of pages that expose a debug interface.
	 * In addition to standard tabs, these include pages such as extension
	 * configuration pages.
	 */
	GetPageList() {
		http := Chrome._http
		try {
			http.Open('GET', 'http://127.0.0.1:' this.DebugPort '/json')
			http.Send()
			return JSON.parse(http.responseText)
		} catch
			return []
	}

	FindPages(opts, MatchMode := 'exact') {
		Pages := []
		for PageData in this.GetPageList() {
			fg := true
			for k, v in (opts is Map ? opts : opts.OwnProps())
				if !((MatchMode = 'exact' && PageData[k] = v) || (MatchMode = 'contains' && InStr(PageData[k], v))
					|| (MatchMode = 'startswith' && InStr(PageData[k], v) == 1) || (MatchMode = 'regex' && PageData[k] ~= v)) {
					fg := false
					break
				}
			if (fg)
				Pages.Push(PageData)
		}
		return Pages
	}

	NewPage(url := 'about:blank', fnCallback?) {
		http := Chrome._http
		http.Open('PUT', 'http://127.0.0.1:' this.DebugPort '/json/new?' url), http.Send()
		if ((PageData := JSON.parse(http.responseText)).Has('webSocketDebuggerUrl'))
			return Chrome.Page(StrReplace(PageData['webSocketDebuggerUrl'], 'localhost', '127.0.0.1'), fnCallback?)
	}

	ClosePage(opts, MatchMode := 'exact') {
		http := Chrome._http
		switch Type(opts) {
			case 'String':
				return (http.Open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' opts), http.Send())
			case 'Map':
				if opts.Has('id')
					return (http.Open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' opts['id']), http.Send())
			case 'Object':
				if opts.HasProp('id')
					return (http.Open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' opts.id), http.Send())
		}
		for page in this.FindPages(opts, MatchMode)
			http.Open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' page['id']), http.Send()
	}

	ActivatePage(opts, MatchMode := 'exact') {
		http := Chrome._http
		for page in this.FindPages(opts, MatchMode)
			return (http.Open('GET', 'http://127.0.0.1:' this.DebugPort '/json/activate/' page['id']), http.Send())
	}
	/**
	 * Returns a connection to the debug interface of a page that matches the
	 * provided criteria. When multiple pages match the criteria, they appear
	 * ordered by how recently the pages were opened.
	 *
	 * Key        - The key from the page list to search for, such as 'url' or 'title'
	 * Value      - The value to search for in the provided key
	 * MatchMode  - What kind of search to use, such as 'exact', 'contains', 'startswith', or 'regex'
	 * Index      - If multiple pages match the given criteria, which one of them to return
	 * fnCallback - A function to be called whenever message is received from the page, `msg => void`
	 */
	GetPageBy(Key, Value, MatchMode := 'exact', Index := 1, fnCallback?) {
		static match_fn := {
			contains: InStr,
			exact: (a, b) => a = b,
			regex: (a, b) => a ~= b,
			startswith: (a, b) => InStr(a, b) == 1
		}
		Count := 0, Fn := match_fn.%MatchMode%
		for PageData in this.GetPageList()
			if Fn(PageData[Key], Value) && ++Count == Index
				return Chrome.Page(PageData['webSocketDebuggerUrl'], fnCallback?)
	}

	; Shorthand for GetPageBy('url', Value, 'startswith')
	GetPageByURL(Value, MatchMode := 'startswith', Index := 1, fnCallback?) {
		return this.GetPageBy('url', Value, MatchMode, Index, fnCallback?)
	}

	; Shorthand for GetPageBy('title', Value, 'startswith')
	GetPageByTitle(Value, MatchMode := 'startswith', Index := 1, fnCallback?) {
		return this.GetPageBy('title', Value, MatchMode, Index, fnCallback?)
	}

	/**
	 * Shorthand for GetPageBy('type', Type, 'exact')
	 * 
	 * The default type to search for is 'page', which is the visible area of
	 * a normal Chrome tab.
	 */
	GetPage(Index := 1, Type := 'page', fnCallback?) {
		return this.GetPageBy('type', Type, 'exact', Index, fnCallback?)
	}

	; Connects to the debug interface of a page given its WebSocket URL.
	class Page extends WebSocket {
		_index := 0, _responses := Map(), _callback := 0
		/**
		 * @param url the url of webscoket
		 * @param events callback function, `(msg) => void`
		 */
		__New(url, events := 0) {
			super.__New(url)
			this._callback := events
			pthis := ObjPtr(this)
			SetTimer(this.KeepAlive := () => ObjFromPtrAddRef(pthis)('Browser.getVersion', , false), 25000)
		}
		__Delete() {
			if !this.KeepAlive
				return
			SetTimer(this.KeepAlive, 0), this.KeepAlive := 0
			super.__Delete()
		}

		Call(DomainAndMethod, Params?, WaitForResponse := true) {
			if (this.readyState != 1)
				throw Error('Not connected to tab')

			; Use a temporary variable for ID in case more calls are made
			; before we receive a response.
			if !ID := this._index += 1
				ID := this._index += 1
			this.sendText(JSON.stringify(Map('id', ID, 'params', Params ?? {}, 'method', DomainAndMethod), 0))
			if (!WaitForResponse)
				return

			; Wait for the response
			this._responses[ID] := false
			while (this.readyState = 1 && !this._responses[ID])
				Sleep(20)

			; Get the response, check if it's an error
			if !response := this._responses.Delete(ID)
				throw Error('Not connected to tab')
			if !(response is Map)
				return response
			if (response.Has('error'))
				throw Error('Chrome indicated error in response', , JSON.stringify(response['error']))
			try return response['result']
		}
		Evaluate(JS) {
			response := this('Runtime.evaluate', {
				expression: JS,
				objectGroup: 'console',
				includeCommandLineAPI: JSON.true,
				silent: JSON.false,
				returnByValue: JSON.false,
				userGesture: JSON.true,
				awaitPromise: JSON.false
			})
			if (response is Map) {
				if (response.Has('ErrorDetails'))
					throw Error(response['result']['description'], , JSON.stringify(response['ErrorDetails']))
				return response['result']
			}
		}

		Close() {
			RegExMatch(this.url, 'ws://[\d\.]+:(\d+)/devtools/page/(.+)$', &m)
			http := Chrome._http, http.Open('GET', 'http://127.0.0.1:' m[1] '/json/close/' m[2]), http.Send()
			this.__Delete()
		}

		Activate() {
			http := Chrome._http, RegExMatch(this.url, 'ws://[\d\.]+:(\d+)/devtools/page/(.+)$', &m)
			http.Open('GET', 'http://127.0.0.1:' m[1] '/json/activate/' m[2]), http.Send()
		}

		WaitForLoad(DesiredState := 'complete', Interval := 100) {
			while this.Evaluate('document.readyState')['value'] != DesiredState
				Sleep Interval
		}
		onClose(*) {
			try this.reconnect()
			catch WebSocket.Error
				this.__Delete()
		}
		onMessage(msg) {
			data := JSON.parse(msg)
			if this._responses.Has(id := data.Get('id', 0))
				this._responses[id] := data
			try (this._callback)(data)
		}
	}
}

; #Include 'JSON.ahk'
#Include 'WebSocket.ahk'
