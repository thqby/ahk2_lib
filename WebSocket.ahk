/************************************************************************
 * @author thqby
 * @date 2023/11/06
 * @version 1.0.4
 ***********************************************************************/

#DllLoad winhttp.dll
class WebSocket {
	Ptr := 0, async := 0, readyState := 0, url := ''

	; The array of HINTERNET handles, [hSession, hConnect, hRequest, hWebSocket]
	HINTERNETs := []

	; when request is opened
	onOpen() => 0
	; when server sent a close frame
	onClose(status, reason) => 0
	; when server sent binary message
	onData(data, size) => 0
	; when server sent UTF-8 message
	onMessage(msg) => 0
	reconnect() => 0

	/**
	 * @param {String} Url the url of websocket
	 * @param {Object} Events an object of `{open:(this)=>void,data:(this, data, size)=>void,message:(this, msg)=>void,close:(this, status, reason)=>void}`
	 * @param {Integer} Async Use asynchronous mode
	 * @param {Object|Map|String} Headers Request header
	 * @param {Integer} TimeOut Set resolve, connect, send and receive timeout
	 */
	__New(Url, Events := 0, Async := true, Headers := '', TimeOut := 0, cache_size := 32768) {
		this.HINTERNETs := [], this.async := !!Async, this.url := Url
		if (!RegExMatch(Url, 'i)^((?<SCHEME>wss?)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:\s]+)(:(?<PORT>\d+))?(?<PATH>/\S*)?$', &m))
			Throw WebSocket.Error('Invalid websocket url')
		if !hSession := DllCall('Winhttp\WinHttpOpen', 'ptr', 0, 'uint', 0, 'ptr', 0, 'ptr', 0, 'uint', Async ? 0x10000000 : 0, 'ptr')
			Throw WebSocket.Error()
		this.HINTERNETs.Push(hSession), port := m.PORT ? Integer(m.PORT) : m.SCHEME = 'ws' ? 80 : 443, dwFlags := m.SCHEME = 'wss' ? 0x800000 : 0
		if TimeOut
			DllCall('Winhttp\WinHttpSetTimeouts', 'ptr', hSession, 'int', TimeOut, 'int', TimeOut, 'int', TimeOut, 'int', TimeOut, 'int')
		if !hConnect := DllCall('Winhttp\WinHttpConnect', 'ptr', hSession, 'wstr', m.HOST, 'ushort', port, 'uint', 0, 'ptr')
			Throw WebSocket.Error()
		this.HINTERNETs.Push(hConnect)
		switch Type(Headers) {
			case 'Object', 'Map':
				s := ''
				for k, v in Headers is Map ? Headers : Headers.OwnProps()
					s .= '`r`n' k ': ' v
				Headers := LTrim(s, '`r`n')
			case 'String':
			default:
				Headers := ''
		}
		if (Events) {
			for k, v in Events.OwnProps()
				if (k ~= 'i)^(open|data|message|close)$')
					this.DefineProp('on' k, { call: v })
		}
		connect(this), this.DefineProp('reconnect', { call: connect })

		connect(self) {
			static StatusCallback, hHeap, msg_gui, wm_ahkmsg := DllCall('RegisterWindowMessage', 'str', 'AHK_WEBSOCKET_STATUSCHANGE', 'uint')
			static pHeapReAlloc := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'kernel32', 'ptr'), 'astr', 'HeapReAlloc', 'ptr')
			static pSendMessageW := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'user32', 'ptr'), 'astr', 'SendMessageW', 'ptr')
			static pWinHttpWebSocketReceive := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'winhttp', 'ptr'), 'astr', 'WinHttpWebSocketReceive', 'ptr')
			if !self.HINTERNETs.Length
				Throw WebSocket.Error('The connection is closed')
			self.shutdown()
			while (self.HINTERNETs.Length > 2)
				DllCall('Winhttp\WinHttpCloseHandle', 'ptr', self.HINTERNETs.Pop())
			if !hRequest := DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', 'GET', 'wstr', m.PATH, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'uint', dwFlags, 'ptr')
				Throw WebSocket.Error()
			self.HINTERNETs.Push(hRequest), self.onOpen()
			if (Headers)
				DllCall('Winhttp\WinHttpAddRequestHeaders', 'ptr', hRequest, 'wstr', Headers, 'uint', -1, 'uint', 0x20000000, 'int')
			if (!DllCall('Winhttp\WinHttpSetOption', 'ptr', hRequest, 'uint', 114, 'ptr', 0, 'uint', 0, 'int')
				|| !DllCall('Winhttp\WinHttpSendRequest', 'ptr', hRequest, 'ptr', 0, 'uint', 0, 'ptr', 0, 'uint', 0, 'uint', 0, 'uptr', 0, 'int')
				|| !DllCall('Winhttp\WinHttpReceiveResponse', 'ptr', hRequest, 'ptr', 0)
				|| !DllCall('Winhttp\WinHttpQueryHeaders', 'ptr', hRequest, 'uint', 19, 'ptr', 0, 'wstr', status := '00000', 'uint*', 10, 'ptr', 0, 'int')
				|| status != '101')
				Throw IsSet(status) ? WebSocket.Error('Invalid status: ' status) : WebSocket.Error()
			if !self.Ptr := DllCall('Winhttp\WinHttpWebSocketCompleteUpgrade', 'ptr', hRequest, 'ptr', 0)
				Throw WebSocket.Error()
			DllCall('Winhttp\WinHttpCloseHandle', 'ptr', self.HINTERNETs.Pop()), self.HINTERNETs.Push(self.Ptr), self.readyState := 1
			if (Async) {
				if !IsSet(StatusCallback) {
					hHeap := DllCall('GetProcessHeap', 'ptr')
					StatusCallback := get_sync_StatusCallback()
					DllCall('SetParent', 'ptr', (msg_gui := Gui()).Hwnd, 'ptr', -3)
					OnMessage(wm_ahkmsg, WEBSOCKET_STATUSCHANGE)
				}
				NumPut('ptr', ObjPtr(self), 'ptr', msg_gui.Hwnd, 'uint', wm_ahkmsg, 'uint', cache_size, 'ptr', hHeap,
					'ptr', pHeapReAlloc, 'ptr', pSendMessageW, 'ptr', pWinHttpWebSocketReceive,
					'ptr', cache := DllCall('HeapAlloc', 'ptr', hHeap, 'uint', 0, 'uptr', cache_size, 'ptr'), 'uptr', 0, 'uptr', cache_size,
					context := Buffer(11 * A_PtrSize))
				context.DefineProp('__Delete', { call: self => DllCall('HeapFree', 'ptr', hHeap, 'uint', 0, 'ptr', NumGet(self, 6 * A_PtrSize + 8, 'ptr')) })
				DllCall('Winhttp\WinHttpSetOption', 'ptr', self, 'uint', 45, 'ptr*', (self.__context := context).Ptr, 'uint', A_PtrSize)
				DllCall('Winhttp\WinHttpSetStatusCallback', 'ptr', self, 'ptr', StatusCallback, 'uint', 0x80000, 'uptr', 0, 'ptr')
				ret := DllCall('Winhttp\WinHttpWebSocketReceive', 'ptr', self, 'ptr', cache, 'uint', cache_size, 'uint*', 0, 'uint*', 0)
				(ret && self.onError(ret))
			} else self.cache_size := cache_size

			static get_sync_StatusCallback() {
				mcodes := ['g+wQi0wkIA9XwFNVVot0JCSLUQRXZg/WRCQUiwaJRCQQi8LHRCQcAAAAAIPoAXRGg+gCdEGD6AF0MotGIIsJA04ki14MiUQkFI1EJBBSUP92CItGGP92BIlMJCjHRiQAAAAA/9CNTigz7esnx0QkFAAAAADrY4tGJL0BAAAAAwGNTiiLEYv5iUYkO8JyIoteDAPai/k7GXQXi0YUU/92IGoA/3YQ/9CFwHRKiUYgiR+LBytGJGoAagBQi0YgA0YkUP90JDSLRhz/0IXAdB093RAAAHQWiUQkFGoEjUQkFFD/dgiLRhj/dgT/0F9eXVuDxBDCFACF7XS3x0QkFA4AB4Dr1g==',
					'TIvcSYlbCEmJcxBJiXsYTYlzIEFXSIPsUEiLAkiL2k1jQQQPV8BJiUPYQYvQM8BMi/kPEUQkOEmJQ/CD6gF0RoPqAnRBg/oBD4SwAAAAQYsRTYvISANTQE2NQ9hIi0M4SItLCItzFEmJU+iLUxBJiUPgSMdDQAAAAAD/UyhIjUtIRTP26yZBiwFIjUtISANDQEG+AQAAAEiLEUiL+UiJQ0BIO8JyKotzFEgD8kiL+Ug7MXQcTItDOEyLzkiLSxgz0v9TIEiFwHRqSIlDOEiJN0SLB0UzyUiLUzhJi89EK0NASANTQEjHRCQgAAAAAP9TMIXAdCM93RAAAHQci8BIiUQkOItTEEyNRCQwSItLCEG5BAAAAP9TKEiLXCRgSIt0JGhIi3wkcEyLdCR4SIPEUEFfw02F9nSYSMdEJDgOAAeA68A=']
				DllCall('crypt32\CryptStringToBinary', 'str', hex := mcodes[A_PtrSize >> 2], 'uint', 0, 'uint', 1, 'ptr', 0, 'uint*', &s := 0, 'ptr', 0, 'ptr', 0) &&
					DllCall('crypt32\CryptStringToBinary', 'str', hex, 'uint', 0, 'uint', 1, 'ptr', code := Buffer(s), 'uint*', &s, 'ptr', 0, 'ptr', 0) &&
					DllCall('VirtualProtect', 'ptr', code, 'uint', s, 'uint', 0x40, 'uint*', 0)
				return code
				/*c++ source, /FAc /O2 /GS-
				struct Context {
					void *obj;
					HWND hwnd;
					UINT msg;
					UINT growth_size;
					HANDLE heap;
					decltype(&HeapReAlloc) HeapReAlloc;
					decltype(&SendMessageW) SendMessageW;
					decltype(&WinHttpWebSocketReceive) WinHttpWebSocketReceive;
					char *cache;
					size_t offset;
					size_t size;
				};
				void __stdcall WINHTTP_STATUS_READ_COMPLETE(
					void *hInternet,
					Context *dwContext,
					DWORD dwInternetStatus,
					WINHTTP_WEB_SOCKET_STATUS *lpvStatusInformation,
					DWORD dwStatusInformationLength) {
					auto &context = *dwContext;
					UINT_PTR param[4] = { (UINT_PTR)context.obj };
					size_t reset_size = 0, is_fragment = 0;
					auto tp = lpvStatusInformation->eBufferType;
					DWORD r;
					switch (tp)
					{
					case WINHTTP_WEB_SOCKET_CLOSE_BUFFER_TYPE:
						param[1] = 0;
						goto ret;
					case WINHTTP_WEB_SOCKET_BINARY_FRAGMENT_BUFFER_TYPE:
					case WINHTTP_WEB_SOCKET_UTF8_FRAGMENT_BUFFER_TYPE:
						is_fragment = 1;
					default:
						context.offset += lpvStatusInformation->dwBytesTransferred;
						if (!is_fragment) {
							param[1] = (UINT_PTR)context.cache;
							param[2] = context.offset;
							context.offset = 0;
							reset_size = (size_t)context.growth_size;
							context.SendMessageW(context.hwnd, context.msg, (WPARAM)param, (LPARAM)tp);
						}
						else if (context.offset < context.size)
							break;
						else reset_size = context.size + (size_t)context.growth_size;
						if (reset_size != context.size) {
							if (auto p = context.HeapReAlloc(context.heap, 0, context.cache, reset_size))
								context.cache = (char *)p, context.size = reset_size;
							else if (is_fragment) {
								param[1] = E_OUTOFMEMORY;
								goto ret;
							}
						}
						break;
					}
					if (r = context.WinHttpWebSocketReceive(hInternet, context.cache + context.offset, DWORD(context.size - context.offset), 0, 0))
						if (r != ERROR_INVALID_OPERATION) {
							param[1] = r;
						ret:
							context.SendMessageW(context.hwnd, context.msg, (WPARAM)param, WINHTTP_WEB_SOCKET_CLOSE_BUFFER_TYPE);
						}
				}*/
			}

			static WEBSOCKET_STATUSCHANGE(wp, lp, msg, hwnd) {
				ws := ObjFromPtrAddRef(NumGet(wp, 'ptr'))
				if ws.readyState != 1
					return
				switch lp {
					case 4:		; WINHTTP_WEB_SOCKET_CLOSE_BUFFER_TYPE
						if err := NumGet(wp, A_PtrSize, 'uint')
							return ws.onError(err)
						rea := ws.QueryCloseStatus(), ws.shutdown()
						return ws.onClose(rea.status, rea.reason)
					default:	; WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, WINHTTP_WEB_SOCKET_UTF8_MESSAGE_BUFFER_TYPE
						data := NumGet(wp, A_PtrSize, 'ptr')
						size := NumGet(wp, 2 * A_PtrSize, 'uptr')
						if lp == 2
							ws.onMessage(StrGet(data, size, 'utf-8'))
						else ws.onData(data, size)
				}
			}
		}
	}

	__Delete() {
		this.shutdown()
		while (this.HINTERNETs.Length)
			DllCall('Winhttp\WinHttpCloseHandle', 'ptr', this.HINTERNETs.Pop())
	}

	onError(err, what := 0) {
		if err != 12030
			Throw WebSocket.Error(err, what - 5)
		if this.readyState == 3
			return
		this.readyState := 3
		try this.onClose(1006, '')
	}

	class Error extends Error {
		__New(err := A_LastError, what := -4) {
			static module := DllCall('GetModuleHandle', 'str', 'winhttp', 'ptr')
			if err is Integer
				if (DllCall("FormatMessage", "uint", 0x900, "ptr", module, "uint", err, "uint", 0, "ptr*", &pstr := 0, "uint", 0, "ptr", 0), pstr)
					err := (msg := StrGet(pstr), DllCall('LocalFree', 'ptr', pstr), msg)
				else err := OSError(err).Message
			super.__New(err, what)
		}
	}

	queryCloseStatus() {
		if (!DllCall('Winhttp\WinHttpWebSocketQueryCloseStatus', 'ptr', this, 'ushort*', &usStatus := 0, 'ptr', vReason := Buffer(123), 'uint', 123, 'uint*', &len := 0))
			return { status: usStatus, reason: StrGet(vReason, len, 'utf-8') }
		else if (this.readyState > 1)
			return { status: 1006, reason: '' }
	}

	/** @param eBufferType BINARY_MESSAGE = 0, BINARY_FRAGMENT = 1, UTF8_MESSAGE = 2, UTF8_FRAGMENT = 3 */
	send(eBufferType, pvBuffer, dwBufferLength) {
		if (this.readyState != 1)
			Throw WebSocket.Error('websocket is disconnected')
		ret := DllCall('Winhttp\WinHttpWebSocketSend', 'ptr', this, 'uint', eBufferType, 'ptr', pvBuffer, 'uint', dwBufferLength, 'uint')
		(ret && this.onError(ret))
	}

	; sends a utf-8 string to the server
	sendText(str) {
		if (size := StrPut(str, 'utf-8') - 1) {
			StrPut(str, buf := Buffer(size), 'utf-8')
			this.send(2, buf, size)
		} else
			this.send(2, 0, 0)
	}

	receive() {
		if (this.async)
			Throw WebSocket.Error('Used only in synchronous mode')
		if (this.readyState != 1)
			Throw WebSocket.Error('websocket is disconnected')
		cache := Buffer(size := this.cache_size), rec := Buffer(0), offset := 0
		while (!ret := DllCall('Winhttp\WinHttpWebSocketReceive', 'ptr', this, 'ptr', cache, 'uint', size, 'uint*', &dwBytesRead := 0, 'uint*', &eBufferType := 0)) {
			switch eBufferType {
				case 0:
					if (offset)
						rec.Size += dwBytesRead, DllCall('RtlMoveMemory', 'ptr', rec.Ptr + offset, 'ptr', cache, 'uint', dwBytesRead)
					else
						rec := cache, rec.Size := dwBytesRead
					return rec
				case 1, 3:
					rec.Size += dwBytesRead, DllCall('RtlMoveMemory', 'ptr', rec.Ptr + offset, 'ptr', cache, 'uint', dwBytesRead), offset += dwBytesRead
				case 2:
					if (offset) {
						rec.Size += dwBytesRead, DllCall('RtlMoveMemory', 'ptr', rec.Ptr + offset, 'ptr', cache, 'uint', dwBytesRead)
						return StrGet(rec, 'utf-8')
					}
					return StrGet(cache, dwBytesRead, 'utf-8')
				default:
					rea := this.QueryCloseStatus(), this.shutdown()
					try this.onClose(rea.status, rea.reason)
					return
			}
		}
		(ret != 4317 && this.onError(ret))
	}

	; sends a close frame to the server to close the send channel, but leaves the receive channel open.
	shutdown() {
		if (this.readyState = 1) {
			this.readyState := 2
			DllCall('Winhttp\WinHttpWebSocketShutdown', 'ptr', this, 'ushort', 1000, 'ptr', 0, 'uint', 0)
			this.readyState := 3
		}
	}
}

; ws := WebSocket(wss_or_ws_url, {
; 	message: (self, data) => FileAppend(Data '`n', '*', 'utf-8'),
; 	close: (self, status, reason) => FileAppend(status ' ' reason '`n', '*', 'utf-8')
; })
; ws.sendText('hello'), Sleep(100)
; ws.send(0, Buffer(10), 10), Sleep(100)
