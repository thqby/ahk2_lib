#Include <Socket>

class WebSocket {
	static Client(ws, callbacks := 0, proto := '', headers := '') => WebSocket._Client.Call(ws, callbacks, proto, headers)
	class _Client {
		socket := Socket(), readyState := 0
		__New(ws, callbacks := 0, proto := '', headers := '') {
			if !RegExMatch(ws, '^ws://([^/:]+)(:\d+)?(/.+)?$', &m)
				throw Exception('不支持的ws url')
			this.host := host := m[1], this.port := port := LTrim(m[2], ':') || '80', path := m[3] || '/', extend := ''
			this.socket.Connect([host, port])
			this.socket.OnDisconnect := ObjBindMethod(this, 'onEvent', 'Close')
			if Type(headers) = 'String'
				extend := headers
			else
				for k, v in Type(headers) = 'Object' ? headers.OwnProps() : headers
					extend .= k ': ' v '`r`n'
			this.msg := Format(
				'GET {} HTTP/1.1`r`n'
				'Host: {}`r`n'
				'Connection: Upgrade`r`n'
				'Upgrade: websocket`r`n'
				'{}'
				'Sec-WebSocket-Version: 13`r`n'
				'Sec-WebSocket-Key: {}`r`n'
				'`r`n',
				path, host ':' port, extend, seckey := WebSocket.sec_key()
			)
			this.callbacks := Map(), this.callbacks.CaseSense := false, this.sec_accept := WebSocket.sec_accept(seckey)
			for k, v in (!callbacks ? Map() : Type(callbacks) = 'Object' ? callbacks.OwnProps() : callbacks)
				this.callbacks[k] := v
			this.connect()
			ObjRelease(ObjPtr(this))
			ObjRelease(ObjPtr(this))
		}
		__Delete() {
			if (this.socket)
				ObjAddRef(ObjPtrAddRef(this)), this.socket.Disconnect(), this.socket := ''
		}
		SendText(str) {
			if (this.socket.Socket = -1)
				throw Exception('websocket已断开')
			buf := WebSocket.DataFrame.encode({FIN: 1, Opcode: 1, Mask: 1, PayloadData: str})
			try
				this.socket.Send(buf.Ptr, buf.Size)
			catch (e)
				this.socket.OnMessage(this.socket.Socket, Socket.FD_CLOSE, Socket.WM_SOCKET, A_ScriptHwnd)
		}
		ping() {
			buf := WebSocket.DataFrame.encode({FIN: 1, Opcode: 0x9, Mask: 1, PayloadData: 'ping'})
			this.socket.Send(buf.Ptr, buf.Size)
		}
		close() {
			buf := WebSocket.DataFrame.encode({FIN: 1, Opcode: 0x8, Mask: 1, PayloadData: 'close'})
			this.socket.Send(buf.Ptr, buf.Size)
		}
		connect() {
			if (this.socket.Socket = -1)
				this.socket.Connect([this.host, this.port])
			this.socket.DeleteProp('onRecv')
			this.socket.SendText(this.msg)
			this.socket.Recv(&buf := 0, 0, 0, 10000)
			if (!buf)
				throw Exception('连接超时')
			str := StrGet(buf, 'utf-8')
			if InStr(str, 'HTTP/1.1 101 Switching Protocols') != 1
				throw Exception('连接失败')
			if (!RegExMatch(str, 'i)Sec-Websocket-Accept:\s?(.+)', &m) || m[1] != this.sec_accept)
				throw Exception('websocket验证失败')
			this.socket.onRecv := ObjBindMethod(this, 'onEvent', 'Message')
			this.onEvent('Open', '')
			lf := InStr(str, '`r`n`r`n'), lf := StrPut(SubStr(str, 1, lf + 3), 'utf-8') - 1
			if (buf.Size > lf && this.callbacks.Has('Message')) {
				frames := WebSocket.decodeDataFrames({Ptr: buf.Ptr + lf, Size: buf.Size - lf})
				for frame in frames
					this.callbacks['Message'](this, frame)
			}
		}
		onEvent(event, sc) {
			if (event = 'Message') {
				if ((len := sc.Recv(&buf := 0, , , 200)) && this.callbacks.Has('Message')) {
					frames := WebSocket.decodeDataFrames(buf)
					for frame in frames {
						if (frame.Opcode = 0x8)
							this.socket.OnMessage(this.socket.Socket, Socket.FD_CLOSE, Socket.WM_SOCKET, A_ScriptHwnd)
						this.callbacks['Message'](this, frame)
					}
				}
			} else {
				if (event = 'Close')
					this.readyState := 3, this.socket.Disconnect()
				if this.callbacks.Has(event)
					this.callbacks[event](this)
			}
		}
	}

	static decodeDataFrames(buf) {
		frames := [], size := buf.Size, ptr := buf.Ptr
		while (size > 0)
			frames.Push(frame := WebSocket.DataFrame.decode({ptr: ptr, size: size})), size -= frame.Size, ptr += frame.Size
		return frames
	}
	static sec_accept(key) {
		buf := BufferAlloc(size := StrPut(key .= '258EAFA5-E914-47DA-95CA-C5AB0DC85B11', 'utf-8') - 1), StrPut(key, buf, 'utf-8')
		DllCall('advapi32\CryptAcquireContextA', 'Ptr*', &hProv := 0, 'Uint', 0, 'Uint', 0, 'Uint', 1, 'Uint', 0xF0000000)
		DllCall('advapi32\CryptCreateHash', 'Ptr', hProv, 'Uint', CALG_SHA1 := 0x8004, 'Uint', 0, 'Uint', 0, 'Ptr*', &hHash := 0)
		DllCall('advapi32\CryptHashData', 'Ptr', hHash, 'Ptr', buf, 'Uint', size, 'Uint', 0)
		DllCall('advapi32\CryptGetHashParam', 'Ptr', hHash, 'Uint', 2, 'Ptr', 0, 'UInt*', &size, 'Uint', 0), HashVal := BufferAlloc(size)
		DllCall('advapi32\CryptGetHashParam', 'Ptr', hHash, 'Uint', 2, 'Ptr', HashVal, 'UInt*', &size, 'Uint', 0)
		DllCall('advapi32\CryptDestroyHash', 'Ptr', hHash), DllCall('advapi32\CryptReleaseContext', 'Ptr', hProv, 'Uint', 0)
		DllCall('crypt32\CryptBinaryToString', 'Ptr', HashVal, 'UInt', size, 'UInt', 0x40000001, 'Ptr', 0, 'Uint*', &_size := 0)
		VarSetStrCapacity(&secaccept, _size << 1)
		DllCall('crypt32\CryptBinaryToString', 'Ptr', HashVal, 'UInt', size, 'UInt', 0x40000001, 'Str', secaccept, 'Uint*', &_size)
		return secaccept
	}
	static sec_key() {
		buf := BufferAlloc(16)
		loop 16
			NumPut('uchar', Random(0, 255), buf, A_Index - 1)
		VarSetStrCapacity(&seckey, 50)
		DllCall('crypt32\CryptBinaryToString', 'Ptr', buf, 'UInt', 16, 'UInt', 0x40000001, 'Str', seckey, 'Uint*', 25)
		return seckey
	}
	class DataFrame {
		static decode(e) {
			e.DefineProp('__Item', {get: (s, i) => NumGet(s, i, 'uchar')})
			i := 0
			frame := {
				FIN: e[i] >> 7,
				Opcode: e[i++] & 15,
				Mask: e[i] >> 7,
				PayloadLength: e[i++] & 0x7f
			}
			if (frame.PayloadLength = 126)
				frame.PayloadLength := (e[i++] << 8) + e[i++]
			else if (frame.PayloadLength = 127)
				i += 4, frame.PayloadLength := (e[i++] << 24) + (e[i++] << 16) + (e[i++] << 8) + e[i++]
			s := BufferAlloc(frame.PayloadLength)
			if (frame.Mask) {
				frame.MaskingKey := [e[i++], e[i++], e[i++], e[i++]], j := 0
				while (j < frame.PayloadLength)
					NumPut('uchar', e[i + j] ^ frame.MaskingKey[Mod(j, 4) + 1], s, A_Index - 1), j++
			} else
				DllCall('RtlMoveMemory', 'ptr', s.Ptr, 'ptr', e.Ptr + i, 'uint', s.Size)
			if (frame.Opcode = 1)
				frame.text := StrGet(s.Ptr, s.Size, 'utf-8')
			frame.PayloadData := s, frame.Size := i + frame.PayloadLength
			return frame
		}

		static encode(e) {
			l := StrPut(e.PayloadData, 'utf-8') - 1, Mask := e.HasProp('Mask') ? e.Mask << 7 : 0
			o := BufferAlloc((l < 126 ? l + 2 : l < 0x10000 ? l + 4 : l + 10) + (Mask ? 4 : 0)), i := 0
			if (Mask)
				o.DefineProp('__Item', {get: (s, i) => NumGet(s, i, 'uchar'), set: (s, v, i) => NumPut('uchar', v, s, i)})
			else
				o.DefineProp('__Item', {set: (s, v, i) => NumPut('uchar', v, s, i)})
			o[i++] := (e.FIN << 7) + e.Opcode
			if (l < 126)
				o[i++] := l + Mask
			else if (l < 0x10000)
				o[i++] := 126 + Mask, o[i++] := (l & 0xFF00) >> 8, o[i++] := l & 0xFF
			else {
				o[i++] := 127 + Mask, o[i++] := 0, o[i++] := 0, o[i++] := 0, o[i++] := 0
				o[i++] := (l & 0xFF000000) >> 24, o[i++] := (l & 0xFF0000) >> 16, o[i++] := (l & 0xFF00) >> 8, o[i++] := l & 0xFF
			}
			if (Mask) {
				MaskingKey := [Random(0, 255), Random(0, 255), Random(0, 255), Random(0, 255)], j := 0
				o[i++] := MaskingKey[1], o[i++] := MaskingKey[2], o[i++] := MaskingKey[3], o[i++] := MaskingKey[4]
				StrPut(e.PayloadData, o.Ptr + i, 'utf-8')
				while (j < l)
					o[i + j] := (o[i + j] ^ MaskingKey[Mod(j, 4) + 1]), j++
			} else
				StrPut(e.PayloadData, o.Ptr + i, 'utf-8')
			return o
		}
	}
}

; ws := WebSocket.Client('ws://123.207.136.134:9010/ajaxchattest', {Message: ppp}, , 'Origin: http://coolaf.com/tool/chattest`r`n')
ws := WebSocket.Client('ws://121.40.165.18:8800', {Message: ppp})
; ws.SendText('fsd')
; ws.SendText('fsdgdfg')
; ws.SendText('zdw')
ppp(sc, data) {
	ToolTip(data.Text)
}

ws := ''

F7:: ws.SendText(InputBox().Value)
F4:: ws.close()