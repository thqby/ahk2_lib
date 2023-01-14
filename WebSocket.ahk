/************************************************************************
 * @author thqby
 * @date 2023/01/14
 * @version 1.0.0
 ***********************************************************************/

class WebSocket {
	Ptr := 0, async := 0, readyState := 0, url := '', waiting := false
	HINTERNETs := [], cache := Buffer(0), recdata := Buffer(0)

	; onClose(status, reason) => void
	; onData(eBufferType, ptr, size) => void
	; onMessage(msg) => void

	/**
	 * @param Url the url of websocket
	 * @param Events an object of `{data:(this, eBufferType, ptr, size)=>void,message:(this, msg)=>void,close:(this, status, reason)=>void}`
	 */
	__New(Url, Events := 0, Async := true, Headers := '') {
		this.HINTERNETs := [], this.async := !!Async, this.cache.Size := 8192, this.url := Url
		if (!RegExMatch(Url, 'i)^((?<SCHEME>wss?)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:]+)(:(?<PORT>\d+))?(?<PATH>/.*)?$', &m))
			throw Error('Invalid websocket url')
		if !hSession := DllCall('Winhttp\WinHttpOpen', 'ptr', 0, 'uint', 0, 'ptr', 0, 'ptr', 0, 'uint', Async ? 0x10000000 : 0, 'ptr')
			throw OSError()
		this.HINTERNETs.Push(hSession), port := m.PORT ? Integer(m.PORT) : m.SCHEME = 'ws' ? 80 : 443, dwFlags := m.SCHEME = 'wss' ? 0x800000 : 0
		if !hConnect := DllCall('Winhttp\WinHttpConnect', 'ptr', hSession, 'wstr', m.HOST, 'ushort', port, 'uint', 0, 'ptr')
			throw OSError()
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
				if (k ~= 'i)^(data|message|close)$')
					this.on%k% := v
		}
		connect(this)
		this.reconnect := connect

		connect(self) {
			static StatusCallback, msg_gui, wm_ahkmsg := DllCall('RegisterWindowMessage', 'str', 'AHK_WEBSOCKET_STATUSCHANGE', 'uint')
			static pSendMessageW := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'user32', 'ptr'), 'astr', 'SendMessageW', 'ptr')
			while (self.HINTERNETs.Length > 2)
				DllCall('Winhttp\WinHttpCloseHandle', 'ptr', self.HINTERNETs.Pop())
			if !hRequest := DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', 'GET', 'wstr', m.PATH, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'uint', dwFlags, 'ptr')
				throw OSError()
			self.HINTERNETs.Push(hRequest)
			if (Headers)
				DllCall('Winhttp\WinHttpAddRequestHeaders', 'ptr', hRequest, 'wstr', Headers, 'uint', -1, 'uint', 0x20000000, 'int')
			if (!DllCall('Winhttp\WinHttpSetOption', 'ptr', hRequest, 'uint', 114, 'ptr', 0, 'uint', 0, 'int')
				|| !DllCall('Winhttp\WinHttpSendRequest', 'ptr', hRequest, 'ptr', 0, 'uint', 0, 'ptr', 0, 'uint', 0, 'uint', 0, 'uptr', 0, 'int')
				|| !DllCall('Winhttp\WinHttpReceiveResponse', 'ptr', hRequest, 'ptr', 0)
				|| !DllCall('Winhttp\WinHttpQueryHeaders', 'ptr', hRequest, 'uint', 19, 'ptr', 0, 'wstr', status := '00000', 'uint*', 10, 'ptr', 0, 'int')
				|| status != '101')
				throw OSError()
			if !self.Ptr := DllCall('Winhttp\WinHttpWebSocketCompleteUpgrade', 'ptr', hRequest, 'ptr', 0)
				throw OSError()
			DllCall('Winhttp\WinHttpCloseHandle', 'ptr', self.HINTERNETs.Pop()), self.HINTERNETs.Push(self.Ptr), self.readyState := 1
			if (Async) {
				if !IsSet(StatusCallback) {
					StatusCallback := get_sync_StatusCallback()
					msg_gui := Gui(), OnMessage(wm_ahkmsg, WEBSOCKET_STATUSCHANGE)
				}
				NumPut('ptr', ObjPtr(self), 'ptr', msg_gui.Hwnd, 'ptr', pSendMessageW, 'uint', wm_ahkmsg, self.__context := Buffer(4 * A_PtrSize))
				DllCall('Winhttp\WinHttpSetOption', 'ptr', self, 'uint', 45, 'ptr*', self.__context.Ptr, 'uint', A_PtrSize)
				DllCall('Winhttp\WinHttpSetStatusCallback', 'ptr', self, 'ptr', StatusCallback, 'uint', 0xffffffff, 'uptr', 0, 'ptr')
				self.waiting := true
				DllCall('Winhttp\WinHttpWebSocketReceive', 'ptr', self, 'ptr', self.cache, 'uint', self.cache.Size, 'uint*', 0, 'uint*', 0)
			}

			get_sync_StatusCallback() {
				mcodes := ['i1QkDIPsDIH6AAAIAHQIgfoAAAAEdTWLTCQUiwGJBCSLRCQQiUQkBItEJByJRCQIM8CB+gAACAAPlMBQjUQkBFD/cQyLQQj/cQT/0IPEDMIUAA==',
					'SIPsSEyL0kGB+AAACAB0CUGB+AAAAAR1MEiLAotSGEyJTCQwRTPJQYH4AAAIAEiJTCQoSYtKCEyNRCQgQQ+UwUiJRCQgQf9SEEiDxEjD']
				DllCall("crypt32\CryptStringToBinary", "str", hex := mcodes[A_PtrSize >> 2], "uint", 0, "uint", 1, "ptr", 0, "uint*", &s := 0, "ptr", 0, "ptr", 0) &&
					DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", 1, "ptr", code := Buffer(s), "uint*", &s, "ptr", 0, "ptr", 0) &&
					DllCall("VirtualProtect", "ptr", code, "uint", s, "uint", 0x40, "uint*", 0)
				return code
				/*
				struct __CONTEXT {
					void *obj;
					HWND hwnd;
					decltype(&SendMessageW) pSendMessage;
					UINT msg;
				};
				void __stdcall WinhttpStatusCallback(
					void *hInternet,
					DWORD_PTR dwContext,
					DWORD dwInternetStatus,
					void *lpvStatusInformation,
					DWORD dwStatusInformationLength) {
					if (dwInternetStatus == 0x80000 || dwInternetStatus == 0x4000000) {
						__CONTEXT *context = (__CONTEXT *)dwContext;
						void *param[3] = { context->obj,hInternet,lpvStatusInformation };
						context->pSendMessage(context->hwnd, context->msg, (WPARAM)param, dwInternetStatus == 0x80000);
					}
				}*/
			}

			static WEBSOCKET_STATUSCHANGE(wp, lp, msg, hwnd) {
				ws := ObjFromPtrAddRef(NumGet(wp, 'ptr'))
				if lp {
					if (ws.readyState != 1)
						return
					hInternet := NumGet(wp, A_PtrSize, 'ptr')
					lpvStatusInformation := NumGet(wp, A_PtrSize * 2, 'ptr')
					dwBytesTransferred := NumGet(lpvStatusInformation, 'uint')
					eBufferType := NumGet(lpvStatusInformation, 4, 'uint')
					ws.waiting := false, rec := ws.recdata, offset := rec.Size
					switch eBufferType {
						case 0, 1:	; BINARY, BINARY_FRAGMENT
							try ws.onData(eBufferType, ws.cache.Ptr, dwBytesTransferred)
							wait()
						case 2:		; UTF8
							if (offset) {
								rec.Size += dwBytesTransferred, DllCall('RtlMoveMemory', 'ptr', rec.Ptr + offset, 'ptr', ws.cache, 'uint', dwBytesTransferred)
								msg := StrGet(rec, 'utf-8'), ws.recdata := Buffer(offset := 0), wait()
							} else msg := StrGet(ws.cache, dwBytesTransferred, 'utf-8'), wait()
							try ws.onMessage(msg)
						case 3:		; UTF8_FRAGMENT
							rec.Size += dwBytesTransferred, DllCall('RtlMoveMemory', 'ptr', rec.Ptr + offset, 'ptr', ws.cache, 'uint', dwBytesTransferred), offset += dwBytesTransferred
							wait()
						default:	; CLOSE
							ws.shutdown(), ws.readyState := 3
							rea := ws.QueryCloseStatus()
							try ws.onClose(rea.status, rea.reason)
					}
				} else ws.readyState := 3
				wait() {
					SetTimer(receive, -1, 2147483647)
					receive() {
						ws.waiting := true
						ret := DllCall('Winhttp\WinHttpWebSocketReceive', 'ptr', hInternet, 'ptr', ws.cache, 'uint', ws.cache.Size, 'uint*', 0, 'uint*', 0)
						if (ret = 12030)
							ws.readyState := 3, ws.onClose && SetTimer(() => ws.onClose(1006, ''), -1, 2147483647)
					}
				}
			}
		}
	}

	__Delete() {
		this.shutdown()
		while (this.HINTERNETs.Length)
			DllCall('Winhttp\WinHttpCloseHandle', 'ptr', this.HINTERNETs.Pop())
	}

	queryCloseStatus() {
		if (!DllCall('Winhttp\WinHttpWebSocketQueryCloseStatus', 'ptr', this, 'ushort*', &usStatus := 0, 'ptr', vReason := Buffer(123), 'uint', 123, 'uint*', &len := 0))
			return { status: usStatus, reason: StrGet(vReason, len, 'utf-8') }
		else if (this.readyState > 1)
			return { status: 1006, reason: '' }
	}

	send(eBufferType, pvBuffer, dwBufferLength) {
		if (this.readyState != 1)
			throw Error('websocket is disconnected')
		ret := DllCall('Winhttp\WinHttpWebSocketSend', 'ptr', this, 'uint', eBufferType, 'ptr', pvBuffer, 'uint', dwBufferLength, 'uint')
		if (ret) {
			if (ret != 12030)
				throw OSError()
			this.readyState := 3
			try this.onClose(1006, '')
		}
	}

	sendText(str) {
		if (size := StrPut(str, 'utf-8') - 1) {
			StrPut(str, buf := Buffer(size), 'utf-8')
			this.send(2, buf, size)
		} else
			this.send(2, 0, 0)
	}

	receive() {
		if (this.async)
			throw Error('Used only in synchronous mode')
		cache := this.cache, size := this.cache.Size, rec := Buffer(0), offset := 0
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
					this.shutdown()
					rea := this.QueryCloseStatus()
					try this.onClose(rea.status, rea.reason)
					return
			}
		}
		if (ret) {
			if (ret != 12030)
				throw Error(ret)
			this.readyState := 3
			try this.onClose(1006, '')
		}
	}

	shutdown() {
		if (this.readyState = 1) {
			this.readyState := 2
			if DllCall('Winhttp\WinHttpWebSocketShutdown', 'ptr', this, 'ushort', 1000, 'ptr', 0, 'uint', 0, 'uint')
				this.readyState := 3
		}
	}

	close() => this.shutdown()
}
