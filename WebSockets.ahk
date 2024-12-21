/************************************************************************
 * @description The Websocket server and client realized by Socket, do not support wss protocol.
 * @author thqby
 * @date 2024/04/22
 * @version 1.0.0
 ***********************************************************************/

#Include <Socket>
class WebSockets {
	class Server extends Socket.Server {
		clients := Map()
		/**
		 * Create a websocket server.
		 * @param {Number} port {@link Socket.Server#__New~port port}
		 * @param {String} host {@link Socket.Server#__New~host host}
		 * @param {typeof WebSockets.Client} clientType The class for socket instantiation.
		 * @example
		 * Persistent()
		 * ws := WebSockets.Server(6789)
		 * ws.onClientConnect := (ws, c) => (c.onMessage := (c, msg)=>c.SendText(msg), c.onData := (c, buf)=>c.SendData(buf))
		 */
		__New(port, host?, clientType := WebSockets.Client, backlog := 4) {
			this._clientType := clientType
			super.__New(port, host?, , , backlog)
		}
		__Delete() {
			for sock in this.clients
				sock._server := 0
			super.__Delete()
		}
		/** @event onAccept */
		onAccept(err) {
			if err || err := -1 == (ptr := this._accept(&addr)) && Socket.GetLastError()
				Throw OSError(err)
			respond := '', this.clients[sock := {
				_server: ObjPtr(this),
				addr: addr, base: this._clientType.Prototype,
				onRead: ServerShakehand, ptr: ptr
			}] := 1, sock.UpdateMonitoring()
			ServerShakehand(self, err) {
				respond .= self.RecvText()
				if SubStr(respond, -4) !== '`r`n`r`n'
					return
				self.DeleteProp('onRead')
				success := 0, res := ['^GET /.+`r`n', 'mi)^Connection:\s*Upgrade`r`n', 'mi)^Upgrade:\s*websocket`r`n']
				for re in res
					if !success := RegExMatch(respond, re)
						break
				if success && i := RegExMatch(respond, 'mi)^Sec-WebSocket-Key:\s*\K') {
					(Socket.Client.Prototype.SendText)(self,
						Format('HTTP/1.1 101 Switching Protocols`r`nUpgrade: websocket`r`nConnection: Upgrade`r`nSec-Websocket-Accept: {}`r`n`r`n',
							WebSockets.sec_accept(SubStr(respond, i, InStr(respond, '`r`n', , i) - i))))
					try this.onClientConnect(self)
					return
				}
				if p := self._server
					self._server := 0, ObjFromPtrAddRef(p).clients.Delete(self)
				Throw Error('Unknown request', respond)
			}
		}
	}
	class Client extends Socket.Client {
		static Prototype._server := 0, Prototype._head := 0x80, Prototype._state := 'head'

		/**
		 * Create a websocket client.
		 * @param url The ws url.
		 * @param {String | Map | Object} headers Additional request headers to use when creating connections.
		 * @example
		 * ws := WebSockets.Client('ws://127.0.0.1:6789')
		 * ws.onMessage := (ws, msg) => MsgBox(msg)
		 * ws.sendText('hello'), Sleep(100)
		 */
		__New(url, headers := '') {
			if !RegExMatch(url, '^ws://([^/:]+)(:\d+)?(/.+)?$', &m)
				Throw Error('Unsupported url')
			host := m[1], port := LTrim(m[2], ':') || '80', path := m[3] || '/', extend := ''
			super.__New(host, port)
			if headers is String
				extend := headers
			else for k, v in headers is Map ? headers : headers.OwnProps()
				extend .= k ': ' v '`r`n'
			request := Format(
				'GET {} HTTP/1.1`r`nConnection: Upgrade`r`nUpgrade: websocket`r`nSec-WebSocket-Version: 13`r`nSec-WebSocket-Key: {}`r`nHost: {}`r`n{}`r`n',
				path, seckey := sec_key(), host ':' port, extend)
			sec_accept := WebSockets.sec_accept(seckey)
			_reconnect := this.ReConnect, ClientShakehand(this)
			this.DefineProp('ReConnect', { call: reconnect })
			reconnect(this) {
				this.DeleteProp('ReConnect')
				_reconnect(this), ClientShakehand(this)
				this.DefineProp('ReConnect', { call: reconnect })
			}
			ClientShakehand(this) {
				this.UpdateMonitoring(0), response := '', endt := A_TickCount + 30000
				(Socket.Client.Prototype.SendText)(this, request)
				while SubStr(response .= read_line(), -4) !== '`r`n`r`n'
					if A_TickCount >= endt
						Throw TimeoutError()
				if RegExMatch(response, '^HTTP/1.1 101\b') &&
					RegExMatch(response, 'mi)^Sec-Websocket-Accept:\s*(.+)`r`n', &m) &&
					m[1] == sec_accept
					return this.UpdateMonitoring()
				Throw Error('fail')
				read_line() {
					if '' == s := this.RecvText(, 1000, 2)
						return
					if i := InStr(s, '`n')
						s := SubStr(s, 1, i)
					l := StrPut(s, 'utf-8') - 1
					this._recv(buf := Buffer(l), l)
					return StrGet(buf, 'utf-8')
				}
			}
			sec_key() {
				NumPut('int64', Random(0, 0xffffffffffffffff), 'int64', Random(0, 0xffffffffffffffff), buf := Buffer(16))
				VarSetStrCapacity(&seckey, 50)
				DllCall('crypt32\CryptBinaryToString', 'Ptr', buf, 'UInt', 16, 'UInt', 0x40000001, 'Str', seckey, 'Uint*', 25)
				return seckey
			}
		}
		/** @event onClose */
		onClose(err) {
			super.__Delete(), this.errCode := err
			this.DefineProp('_async_select', { call: (*) => 0 })
			if p := this._server
				this._server := 0, ObjFromPtrAddRef(p).clients.Delete(this)
		}
		/** @event onRead */
		onRead(err) {
			if err || !sz := this.MsgSize()
				return this.onClose(err)
			goto(this._state)
head:
			if sz < 2
				return
			if DllCall('ws2_32\recv', 'ptr', this, 'ushort*', &v := 0, 'int', 2, 'int', 0) !== 2
				return this.onClose(Socket.GetLastError())
			sz -= 2, opcode := v & 0xf, len := v >> 8 & 0x7f, need_mask := ObjHasOwnProp(this, '_server')
			if 0x8 <= opcode && opcode <= 0xa && (!(v & 0x80) || len > 125) ||
				v < 0x8000 == need_mask || !(this._head & 0x80) !== !opcode
				return this.onClose(10060)
			if opcode
				this._head := v & 0x808f, this._frame := frame := Buffer()
			else this._head |= v & 0x808f
			if len < 126 {
				if this._bytes := this._len := len
					(frame ??= this._frame).Size += len, this._eptr := frame.ptr + frame.size
				if need_mask
					goto mask
				goto payload
			}
			bytes := len == 126 ? 2 : 8
len:
			if sz < bytes ??= this._bytes
				return (this._state := 'len', this._bytes := bytes)
			if DllCall('ws2_32\recv', 'ptr', this, 'int64*', &v := 0, 'int', bytes, 'int', 0) !== bytes
				return this.onClose(Socket.GetLastError())
			sz -= bytes
			if bytes == 8
				len := (v << 56) | (v << 40 & 0xff000000000000) | (v << 24 & 0xff0000000000) | (v << 8 & 0xff00000000) |
					(v >>> 8 & 0xff000000) | (v >>> 24 & 0xff0000) | (v >>> 40 & 0xff00) | (v >>> 56)
			else len := (v << 8 & 0xff00) | (v >> 8)
			(frame ??= this._frame).Size += this._bytes := this._len := len, this._eptr := frame.ptr + frame.size
			if !(need_mask ?? ObjHasOwnProp(this, '_server'))
				goto payload
mask:
			if sz < 4
				return (this._state := 'mask', 0)
			if DllCall('ws2_32\recv', 'ptr', this, 'uint*', &v := 0, 'int', 4, 'int', 0) !== 4
				return this.onClose(Socket.GetLastError())
			sz -= 4, this._mask := v
payload:
			if bytes := this._bytes {
				r := DllCall('ws2_32\recv', 'ptr', this, 'ptr', this._eptr - bytes, 'int', bytes, 'int', 0)
				if r < 0
					return this.onClose(Socket.GetLastError())
				if bytes -= r
					return (this._state := 'payload', this._bytes := bytes)
				sz -= r
			}
			this._state := 'head'
			if (0x8000 & head := this._head) && len ??= this._len
				this._mask_copy(p := this._eptr - len, p, len, v ?? this._mask)
			if head & 0x80
				switch head & 0xf {
					case 0x1:	; text
						try this.onMessage(StrGet(frame ?? this._frame, 'utf-8'))
					case 0x2:	; bin
						try this.onData(frame ?? this._frame)
					case 0x8:	; close
						return this.onClose(0)
					case 0x9:	; ping
						if head & 0x8000
							DllCall('ws2_32\send', 'ptr', this, 'ushort*', 0x89, 'int', 2, 'int', 0)
						else DllCall('ws2_32\send', 'ptr', this, 'ushort*', 0x8089, 'int', 6, 'int', 0)
				}
			goto head
		}
		_mask_copy(target, source, len, mask) {
			static _ := decode_base64(), mask_copy := _.Ptr
			return DllCall(mask_copy, 'ptr', target, 'ptr', source, 'int', len, 'uint*', mask, 'cdecl')
			static decode_base64() {
				/*c++ source, https://godbolt.org/, msvc vxx.latest, /FAc /O2 /GS-
				void mask_copy(char *target, char *source, int len, char *mask) {
					for (int i = 0; i < len; i++)
						target[i] = source[i] ^ mask[i % 4];
				}*/
				mcodes := ['Vot0JBAzwIX2fi1Ti1wkDFWLbCQcV4t8JBgr+w8fQACLyI0UGIPhA0CKDCkyDBeICjvGfOtfXVteww==',
					'RYXAfipFM9JFi8BIK9FmkEmLwkiNSQGD4ANJ/8JCD7YECDJEEf+IQf9Jg+gBdeHD']
				DllCall('crypt32\CryptStringToBinary', 'str', hex := mcodes[A_PtrSize >> 2], 'uint', 0, 'uint', 1, 'ptr', 0, 'uint*', &s := 0, 'ptr', 0, 'ptr', 0) &&
					DllCall('crypt32\CryptStringToBinary', 'str', hex, 'uint', 0, 'uint', 1, 'ptr', code := Buffer(s), 'uint*', &s, 'ptr', 0, 'ptr', 0) &&
					DllCall('VirtualProtect', 'ptr', code, 'uint', s, 'uint', 0x40, 'uint*', 0)
				return code
			}
		}
		_create_data_frame(data, size?) {
			if IsSet(size)
				op := 2
			else
				StrPut(data, t := Buffer(size := StrPut(data, 'utf-8') - 1), 'utf-8'), data := t, op := 1
			mask := !ObjHasOwnProp(this, '_server') && Random(1, 0xffffffff)
			p := NumPut('uchar', 0x80 | op, frame := Buffer((size < 126 ? size + 2 : size < 0x10000 ? size + 4 : size + 10) + (mask ? 4 : 0)))
			if size < 126
				p := NumPut('uchar', (mask && 0x80) | size, p)
			else if size < 0x10000
				p := NumPut('uchar', (mask && 0x80) | 126, 'uchar', size >> 8, 'uchar', size, p)
			else p := NumPut('uchar', (mask && 0x80) | 127,
				'uchar', size >>> 56, 'uchar', size >>> 48, 'uchar', size >>> 40, 'uchar', size >>> 32,
				'uchar', size >>> 24, 'uchar', size >>> 16, 'uchar', size >>> 8, 'uchar', size, p)
			if mask
				this._mask_copy(p := NumPut('uint', mask, p), data, size, mask)
			else DllCall('RtlMoveMemory', 'ptr', p, 'ptr', data, 'uptr', size)
			return frame
		}
		SendData(data, size?) => super.Send(this._create_data_frame(data, size ?? data.size))
		SendText(str) => super.Send(this._create_data_frame(str))
		; Sends a close frame
		close() {
			if ObjHasOwnProp(this, '_server')
				DllCall('ws2_32\send', 'ptr', this, 'ushort*', 0x88, 'int', 2, 'int', 0)
			else DllCall('ws2_32\send', 'ptr', this, 'ushort*', 0x8088, 'int', 6, 'int', 0)
		}
	}
	static sec_accept(key) {
		buf := Buffer(size := StrPut(key .= '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', 'utf-8') - 1), StrPut(key, buf, 'utf-8')
		DllCall('advapi32\CryptAcquireContextA', 'Ptr*', &hProv := 0, 'Uint', 0, 'Uint', 0, 'Uint', 1, 'Uint', 0xF0000000)
		DllCall('advapi32\CryptCreateHash', 'Ptr', hProv, 'Uint', CALG_SHA1 := 0x8004, 'Uint', 0, 'Uint', 0, 'Ptr*', &hHash := 0)
		DllCall('advapi32\CryptHashData', 'Ptr', hHash, 'Ptr', buf, 'Uint', size, 'Uint', 0)
		DllCall('advapi32\CryptGetHashParam', 'Ptr', hHash, 'Uint', 2, 'Ptr', 0, 'UInt*', &size, 'Uint', 0), HashVal := Buffer(size)
		DllCall('advapi32\CryptGetHashParam', 'Ptr', hHash, 'Uint', 2, 'Ptr', HashVal, 'UInt*', &size, 'Uint', 0)
		DllCall('advapi32\CryptDestroyHash', 'Ptr', hHash), DllCall('advapi32\CryptReleaseContext', 'Ptr', hProv, 'Uint', 0)
		DllCall('crypt32\CryptBinaryToString', 'Ptr', HashVal, 'UInt', size, 'UInt', 0x40000001, 'Ptr', 0, 'Uint*', &_size := 0)
		VarSetStrCapacity(&secaccept, _size << 1)
		DllCall('crypt32\CryptBinaryToString', 'Ptr', HashVal, 'UInt', size, 'UInt', 0x40000001, 'Str', secaccept, 'Uint*', &_size)
		return secaccept
	}
}
