/************************************************************************
 * @description: Chrome.ahk v1.0 for ahk_v2
 * @author thqby
 * @date 2021/04/22
 * @version 0.0.26
 ***********************************************************************/

#Requires AutoHotkey v2.0-a131

class Chrome {
	/*
	 * Escape a string in a manner suitable for command line parameters
	 */
	static CliEscape(Param) {
		return '"' RegExReplace(Param, '(\\*)"', '$1$1\"') '"'
	}

	static FindInstances(exename := 'Chrome.exe') {
		for Item in ComObjGet('winmgmts:').ExecQuery("SELECT CommandLine FROM Win32_Process WHERE Name = '" exename "'")
			if RegExMatch(Item.CommandLine, '--remote-debugging-port=(\d+)', &Match)
				return {DebugPort: Match[1], CommandLine: Item.CommandLine}
	}

	/*
	 * @param ProfilePath - Path to the user profile directory to use. Will use the standard if left blank.
	 * @param URLs        - The page or array of pages for Chrome to load when it opens
	 * @param Flags       - Additional flags for Chrome when launching
	 * @param ChromePath  - Path to Chrome.exe, will detect from start menu when left blank
	 * @param DebugPort   - What port should Chrome's remote debugging server run on
	 */
	__New(URLs := 'about:blank', Flags := '', ChromePath := '', DebugPort := 9222, ProfilePath := '') {
		; Verify ProfilePath
		if (ProfilePath != '' && !FileExist(ProfilePath))
			DirCreate(ProfilePath)

		; Verify ChromePath
		if (ChromePath == '')
			try FileGetShortcut A_StartMenuCommon '\Programs\Chrome.lnk', ChromePath
		if (ChromePath == '')
			try ChromePath := RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Chrome.exe')
		if !FileExist(ChromePath) && !FileExist(ChromePath := 'C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe')
			throw Error('Chrome could not be found')
		this.ChromePath := ChromePath

		; Verify DebugPort
		if !IsInteger(DebugPort) || (DebugPort <= 0)
			throw Error('DebugPort must be a positive integer')
		this.DebugPort := DebugPort

		; Escape the URL(s)
		for url in (URLString := '', (t := Type(URLs)) = 'Array' ? URLs : t = 'String' ? [URLs] : ['about:blank'])
			URLString .= ' ' Chrome.CliEscape(URL)

		Run(Chrome.CliEscape(ChromePath) ' --remote-debugging-port=' this.DebugPort
			(ProfilePath ? ' --user-data-dir=' Chrome.CliEscape(ProfilePath) : '')
			(Flags ? ' ' Flags : '') URLString, , , &PID)
		this.PID := PID, this.http := ComObject('WinHttp.WinHttpRequest.5.1')
	}

	/*
	 * End Chrome by terminating the process.
	 */
	Kill() {
		ProcessClose(this.PID)
	}

	/*
	 * Queries Chrome for a list of pages that expose a debug interface.
	 * In addition to standard tabs, these include pages such as extension
	 * configuration pages.
	 */
	GetPageList() {
		http := this.http
		try {
			http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json')
			http.send()
			return JSON.parse(http.responseText)
		} catch
			return []
	}

	FindPages(opts, MatchMode := 'exact') {
		Pages := []
		for PageData in this.GetPageList() {
			fg := true
			for k, v in (Type(opts) = 'Map' ? opts : opts.OwnProps())
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

	NewTab(url := 'about:blank') {
		http := this.http, PageData := Map()
		http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json/new?' url), http.send()
		try PageData := JSON.parse(http.responseText)
		if (PageData.Has('webSocketDebuggerUrl'))
			return Chrome.Page.Call(StrReplace(PageData['webSocketDebuggerUrl'], 'localhost', '127.0.0.1'))
	}

	ClosePage(opts, MatchMode := 'exact') {
		http := this.http
		switch Type(opts)
		{
			case 'String':
				return (http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' opts), http.send())
			case 'Map':
				if opts.Has('id')
					return (http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' opts['id']), http.send())
			case 'Object':
				if opts.Has('id')
					return (http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' opts.id), http.send())
		}
		for page in this.FindPages(opts, MatchMode)
			http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json/close/' page['id']), http.send()
	}

	ActivatePage(opts, MatchMode := 'exact') {
		http := this.http
		for page in this.FindPages(opts, MatchMode)
			return (http.open('GET', 'http://127.0.0.1:' this.DebugPort '/json/activate/' page['id']), http.send())
	}
	/*
	 * Returns a connection to the debug interface of a page that matches the
	 * provided criteria. When multiple pages match the criteria, they appear
	 * ordered by how recently the pages were opened.
	 * 
	 * Key        - The key from the page list to search for, such as 'url' or 'title'
	 * Value      - The value to search for in the provided key
	 * MatchMode  - What kind of search to use, such as 'exact', 'contains', 'startswith', or 'regex'
	 * Index      - If multiple pages match the given criteria, which one of them to return
	 * fnCallback - A function to be called whenever message is received from the page
	 */
	GetPageBy(Key, Value, MatchMode := 'exact', Index := 1, fnCallback := '') {
		Count := 0
		for PageData in this.GetPageList()
		{
			if (((MatchMode = 'exact' && PageData[Key] = Value)	; Case insensitive
					|| (MatchMode = 'contains' && InStr(PageData[Key], Value))
					|| (MatchMode = 'startswith' && InStr(PageData[Key], Value) == 1)
					|| (MatchMode = 'regex' && PageData[Key] ~= Value))
				&& ++Count == Index)
				return Chrome.Page.Call(PageData['webSocketDebuggerUrl'], fnCallback)
		}
	}

	/*
	 * Shorthand for GetPageBy('url', Value, 'startswith')
	 */
	GetPageByURL(Value, MatchMode := 'startswith', Index := 1, fnCallback := '') {
		return this.GetPageBy('url', Value, MatchMode, Index, fnCallback)
	}

	/*
	 * Shorthand for GetPageBy('title', Value, 'startswith')
	 */
	GetPageByTitle(Value, MatchMode := 'startswith', Index := 1, fnCallback := '') {
		return this.GetPageBy('title', Value, MatchMode, Index, fnCallback)
	}

	/*
	 * Shorthand for GetPageBy('type', Type, 'exact')
	 * 
	 * The default type to search for is 'page', which is the visible area of
	 * a normal Chrome tab.
	 */
	GetPage(Index := 1, Type := 'page', fnCallback := '') {
		return this.GetPageBy('type', Type, 'exact', Index, fnCallback)
	}

	/*
	 * Connects to the debug interface of a page given its WebSocket URL.
	 */
	class Page extends WebSocket {
		ID := 0, responses := Map(), callback := 0
		__New(url, events := 0) {
			super.__New(url)
			pthis := ObjPtr(this)
			this.KeepAlive := keepalive, this.callback := events
			SetTimer(keepalive, 25000)
			keepalive() {
				self := ObjFromPtrAddRef(pthis)
				self.Call('Browser.getVersion', , false)
			}
		}
		__Delete() {
			super.close()
		}

		Call(DomainAndMethod, Params := '', WaitForResponse := true) {
			if (this.readyState != 1)
				throw Error('Not connected to tab')

			; Use a temporary variable for ID in case more calls are made
			; before we receive a response.
			this.sendText(JSON.stringify(Map('id', ID := this.ID += 1, 'params', Params ? Params : {}, 'method', DomainAndMethod), 0))
			if (!WaitForResponse)
				return
			
			; Wait for the response
			this.responses[ID] := false
			while (this.readyState = 1 && !this.responses[ID])
				Sleep(20)

			; Get the response, check if it's an error
			response := this.responses.Delete(ID)
			if (Type(response) != 'Map')
				return
			if (response.Has('error'))
				throw Error('Chrome indicated error in response', , JSON.stringify(response['error']))
			if response.Has('result')
				return response['result']
		}
		Evaluate(JS) {
			response := this.Call('Runtime.evaluate', {
				expression: JS,
				objectGroup: 'console',
				includeCommandLineAPI: JSON.true,
				silent: JSON.false,
				returnByValue: JSON.false,
				userGesture: JSON.true,
				awaitPromise: JSON.false
			})
			if (Type(response) = 'Map') {
				if (response.Has('ErrorDetails'))
					throw Error(response['result']['description'], , JSON.stringify(response['ErrorDetails']))
				return response['result']
			}
		}

		Close() {
			RegExMatch(this.url, 'ws://[\d\.]+:(\d+)/devtools/page/(.+)$', &m), super.close()
			http := this.http, http.open('GET', 'http://127.0.0.1:' m[1] '/json/close/' m[2]), http.send()
		}

		Activate() {
			http := this.http, RegExMatch(this.url, 'ws://[\d\.]+:(\d+)/devtools/page/(.+)$', &m)
			http.open('GET', 'http://127.0.0.1:' m[1] '/json/activate/' m[2]), http.send()
		}

		WaitForLoad(DesiredState := 'complete', Interval := 100) {
			while this.Evaluate('document.readyState')['value'] != DesiredState
				Sleep Interval
		}
		onClose() {
			this.reconnect()
		}
		onMessage(msg) {
			data := JSON.parse(msg)
			if data.Has('id') && this.responses.Has(data['id'])
				this.responses[data['id']] := data
			try (this.callback)(msg)
		}
	}
}

#Include 'JSON.ahk'
#Include 'WebSocket.ahk'