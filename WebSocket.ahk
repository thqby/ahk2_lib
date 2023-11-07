/************************************************************************
 * @author thqby
 * @date 2023/11/07
 * @version 1.0.5
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
	 * @param {Object} Events an object of `{open:(this)=>void,data:(this, data, size)=>bool,message:(this, msg)=>bool,close:(this, status, reason)=>void}`
	 * @param {Integer} Async Use asynchronous mode
	 * @param {Object|Map|String} Headers Request header
	 * @param {Integer} TimeOut Set resolve, connect, send and receive timeout
	 */
	__New(Url, Events := 0, Async := true, Headers := '', TimeOut := 0, InitialSize := 8192) {
		if (!RegExMatch(Url, 'i)^((?<SCHEME>wss?)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:\s]+)(:(?<PORT>\d+))?(?<PATH>/\S*)?$', &m))
			Throw WebSocket.Error('Invalid websocket url')
		if !hSession := DllCall('Winhttp\WinHttpOpen', 'ptr', 0, 'uint', 0, 'ptr', 0, 'ptr', 0, 'uint', Async ? 0x10000000 : 0, 'ptr')
			Throw WebSocket.Error()
		this.async := Async := !!Async, this.url := Url
		this.HINTERNETs.Push(hSession)
		port := m.PORT ? Integer(m.PORT) : m.SCHEME = 'ws' ? 80 : 443
		dwFlags := m.SCHEME = 'wss' ? 0x800000 : 0
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
		if (Async) {
			this.DefineProp('shutdown', { call: async_shutdown })
				.DefineProp('receive', { call: receive })
				.DefineProp('_send', { call: async_send })
		} else this.__cache_size := InitialSize
		connect(this), this.DefineProp('reconnect', { call: connect })

		connect(self) {
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
			DllCall('Winhttp\WinHttpCloseHandle', 'ptr', self.HINTERNETs.Pop())
			self.HINTERNETs.Push(self.Ptr), self.readyState := 1
			(Async && async_receive(self))
		}

		async_receive(self) {
			static on_read_complete := get_sync_callback(), hHeap := DllCall('GetProcessHeap', 'ptr')
			static msg_gui := Gui(), wm_ahkmsg := DllCall('RegisterWindowMessage', 'str', 'AHK_WEBSOCKET_STATUSCHANGE', 'uint')
			static pHeapReAlloc := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'kernel32', 'ptr'), 'astr', 'HeapReAlloc', 'ptr')
			static pSendMessageW := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'user32', 'ptr'), 'astr', 'SendMessageW', 'ptr')
			static pWinHttpWebSocketReceive := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'winhttp', 'ptr'), 'astr', 'WinHttpWebSocketReceive', 'ptr')
			static _ := (OnMessage(wm_ahkmsg, WEBSOCKET_READ_WRITE_COMPLETE, 0xff), DllCall('SetParent', 'ptr', msg_gui.Hwnd, 'ptr', -3))
			; #DllLoad E:\projects\test\test\x64\Debug\test.dll
			; on_read_complete := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'test', 'ptr'), 'astr', 'WINHTTP_STATUS_READ_COMPLETE', 'ptr')
			NumPut('ptr', ObjPtr(self), 'ptr', msg_gui.Hwnd, 'uint', wm_ahkmsg, 'uint', InitialSize, 'ptr', hHeap,
				'ptr', cache := DllCall('HeapAlloc', 'ptr', hHeap, 'uint', 0, 'uptr', InitialSize, 'ptr'), 'uptr', 0, 'uptr', InitialSize,
				'ptr', pHeapReAlloc, 'ptr', pSendMessageW, 'ptr', pWinHttpWebSocketReceive,
				context := Buffer(11 * A_PtrSize))
			context.DefineProp('__Delete', { call: self => DllCall('HeapFree', 'ptr', hHeap, 'uint', 0, 'ptr', NumGet(self, 3 * A_PtrSize + 8, 'ptr')) })
			DllCall('Winhttp\WinHttpSetOption', 'ptr', self, 'uint', 45, 'ptr*', (self.__context := context).Ptr, 'uint', A_PtrSize)
			DllCall('Winhttp\WinHttpSetStatusCallback', 'ptr', self, 'ptr', on_read_complete, 'uint', 0x80000, 'uptr', 0, 'ptr')
			if err := DllCall('Winhttp\WinHttpWebSocketReceive', 'ptr', self, 'ptr', cache, 'uint', InitialSize, 'uint*', 0, 'uint*', 0)
				self.onError(err)

			static WEBSOCKET_READ_WRITE_COMPLETE(wp, lp, msg, hwnd) {
				ws := ObjFromPtrAddRef(NumGet(wp, 'ptr'))
				if ws.readyState != 1
					return
				switch lp {
					case 5:		; WRITE_COMPLETE
						try ws.__send_queue.Pop()
					case 4:		; WINHTTP_WEB_SOCKET_CLOSE_BUFFER_TYPE
						if err := NumGet(wp, A_PtrSize, 'uint')
							return ws.onError(err)
						rea := ws.QueryCloseStatus(), ws.shutdown()
						return ws.onClose(rea.status, rea.reason)
					default:	; WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, WINHTTP_WEB_SOCKET_UTF8_MESSAGE_BUFFER_TYPE
						data := NumGet(wp, A_PtrSize, 'ptr')
						size := NumGet(wp, 2 * A_PtrSize, 'uptr')
						if lp == 2
							return ws.onMessage(StrGet(data, size, 'utf-8'))
						else return ws.onData(data, size)
				}
			}
		}

		static async_send(self, type, buf, size) {
			if (self.readyState != 1)
				Throw WebSocket.Error('websocket is disconnected')
			(q := self.__send_queue).InsertAt(1, buf)
			while (err := DllCall('Winhttp\WinHttpWebSocketSend', 'ptr', self, 'uint', type, 'ptr', buf, 'uint', size, 'uint')) = 4317 && A_Index < 60
				Sleep(15)
			if err
				q.RemoveAt(1), self.onError(err)
		}

		static async_shutdown(self) {
			if self.Ptr
				DllCall('Winhttp\WinHttpSetOption', 'ptr', self, 'uint', 45, 'ptr*', 0, 'uint', A_PtrSize)
			(WebSocket.Prototype.shutdown)(self), self.__context := unset, self.__send_queue := []
		}

		static get_sync_callback() {
			mcodes := ['g+wMVot0JBiF9g+E0QAAAItEJBw9AAAQAHUVi0YkagVW/3YI/3YE/9Beg8QMwhQAPQAACAAPhaYAAACLBolEJASLRCQgU1VXi1AEx0QkFAAAAADHRCQYAAAAAIP6BHRsi04Yi+qLAI0MAYlOGIPlAXV2i0YUiUQkFI1EJBBSUP92CItGJP92BIlMJCjHRhgAAAAA/9CNfhyFwHQHi14MOx91UYsHK0YYagBqAFCLRhQDRhhQ/3QkMItGKP/QhcB0HT3dEAAAdBaJRCQUagSNRCQUUP92CItGJP92BP/QX11bXoPEDMIUAIteHI1+HDvLcrED24tGIFP/dhRqAP92EP/QhcB0B4lGFIkf65aF7XSSx0QkFA4AB4DrsQ==',
				'SIXSD4QvAQAASIlcJCBBVkiD7FBIi9pMi/FBgfgAABAAdR9Ii0sITIvCi1IQQbkFAAAA/1NASItcJHhIg8RQQV7DQYH4AAAIAA+F3gAAAEiLAkljUQRIiWwkYEiJRCQwM8BIiXQkaEiJfCRwSMdEJDgAAAAASIlEJECD+gQPhIYAAABFiwGL6kiLQyhNjQQATIlDKIPlAQ+FnAAAAEiLQyBMi8qLUxBIi0sITIlEJEBMjUQkMEiJRCQ4SMdDKAAAAAD/U0BIjXswSIXAdAiLcxRIOzd1c0SLB0UzyUiLUyBJi85EK0MoSANTKEjHRCQgAAAAAP9TSIXAdCM93RAAAHQci8BIiUQkOItTEEyNRCQwSItLCEG5BAAAAP9TQEiLdCRoSItsJGBIi3wkcEiLXCR4SIPEUEFew0iLczBIjXswTDvGcpBIA/ZMi0MgTIvOSItLGDPS/1M4SIXAdAxIiUMgSIk36Wz///+F7Q+EZP///0jHRCQ4DgAHgOuM']
			DllCall('crypt32\CryptStringToBinary', 'str', hex := mcodes[A_PtrSize >> 2], 'uint', 0, 'uint', 1, 'ptr', 0, 'uint*', &s := 0, 'ptr', 0, 'ptr', 0) &&
				DllCall('crypt32\CryptStringToBinary', 'str', hex, 'uint', 0, 'uint', 1, 'ptr', code := Buffer(s), 'uint*', &s, 'ptr', 0, 'ptr', 0) &&
				DllCall('VirtualProtect', 'ptr', code, 'uint', s, 'uint', 0x40, 'uint*', 0)
			return code
			/*c++ source, /FAc /O2 /GS-
			struct Context {
				void *obj;
				HWND hwnd;
				UINT msg;
				UINT initial_size;
				HANDLE heap;
				BYTE *data;
				size_t size;
				size_t capacity;
				decltype(&HeapReAlloc) ReAlloc;
				decltype(&SendMessageW) Send;
				decltype(&WinHttpWebSocketReceive) Receive;
			};
			void __stdcall WINHTTP_STATUS_READ_WRITE_COMPLETE(
				void *hInternet,
				Context *dwContext,
				DWORD dwInternetStatus,
				WINHTTP_WEB_SOCKET_STATUS *lpvStatusInformation,
				DWORD dwStatusInformationLength) {
				if (!dwContext)
					return;
				auto &context = *dwContext;
				if (dwInternetStatus == WINHTTP_CALLBACK_FLAG_WRITE_COMPLETE)
					return (void)context.Send(context.hwnd, context.msg, (WPARAM)dwContext, 5);
				else if (dwInternetStatus != WINHTTP_CALLBACK_FLAG_READ_COMPLETE)
					return;
				UINT_PTR param[3] = { (UINT_PTR)context.obj, 0 };
				DWORD err;
				switch (auto bt = lpvStatusInformation->eBufferType)
				{
				case WINHTTP_WEB_SOCKET_CLOSE_BUFFER_TYPE:
					goto close;
				default:
					size_t new_size;
					auto is_fragment = bt & 1;
					context.size += lpvStatusInformation->dwBytesTransferred;
					if (!is_fragment) {
						param[1] = (UINT_PTR)context.data;
						param[2] = context.size;
						context.size = 0;
						if (!context.Send(context.hwnd, context.msg, (WPARAM)param, bt) ||
							(new_size = (size_t)context.initial_size) == context.capacity)
							break;
					}
					else if (context.size >= context.capacity)
						new_size = context.capacity << 1;
					else break;
					if (auto p = context.ReAlloc(context.heap, 0, context.data, new_size))
						context.data = (BYTE *)p, context.capacity = new_size;
					else if (is_fragment) {
						param[1] = E_OUTOFMEMORY;
						goto close;
					}
					break;
				}
				err = context.Receive(hInternet, context.data + context.size, DWORD(context.capacity - context.size), 0, 0);
				if (err && err != ERROR_INVALID_OPERATION) {
					param[1] = err;
				close: context.Send(context.hwnd, context.msg, (WPARAM)param, WINHTTP_WEB_SOCKET_CLOSE_BUFFER_TYPE);
				}
			}*/
		}

		static receive(*) {
			Throw WebSocket.Error('Used only in synchronous mode')
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

	/** @param type BINARY_MESSAGE = 0, BINARY_FRAGMENT = 1, UTF8_MESSAGE = 2, UTF8_FRAGMENT = 3 */
	_send(type, buf, size) {
		if (this.readyState != 1)
			Throw WebSocket.Error('websocket is disconnected')
		if err := DllCall('Winhttp\WinHttpWebSocketSend', 'ptr', this, 'uint', type, 'ptr', buf, 'uint', size, 'uint')
			return this.onError(err)
	}

	; sends a utf-8 string to the server
	sendText(str) {
		if (size := StrPut(str, 'utf-8') - 1) {
			StrPut(str, buf := Buffer(size), 'utf-8')
			this._send(2, buf, size)
		} else
			this._send(2, 0, 0)
	}

	send(buf) => this._send(0, buf, buf.Size)

	receive() {
		if (this.readyState != 1)
			Throw WebSocket.Error('websocket is disconnected')
		ptr := (cache := Buffer(size := this.__cache_size)).Ptr, offset := 0
		while (!err := DllCall('Winhttp\WinHttpWebSocketReceive', 'ptr', this, 'ptr', ptr + offset, 'uint', size - offset, 'uint*', &dwBytesRead := 0, 'uint*', &eBufferType := 0)) {
			switch eBufferType {
				case 1, 3:
					offset += dwBytesRead
					if offset == size
						cache.Size := size *= 2, ptr := cache.Ptr
				case 0, 2:
					offset += dwBytesRead
					if eBufferType == 2
						return StrGet(ptr, offset, 'utf-8')
					cache.Size := offset
					return cache
				case 4:
					rea := this.QueryCloseStatus(), this.shutdown()
					try this.onClose(rea.status, rea.reason)
					return
			}
		}
		(err != 4317 && this.onError(err))
	}

	; sends a close frame to the server to close the send channel, but leaves the receive channel open.
	shutdown() {
		if (this.readyState = 1) {
			this.readyState := 2
			DllCall('Winhttp\WinHttpWebSocketShutdown', 'ptr', this, 'ushort', 1006, 'ptr', 0, 'uint', 0)
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
