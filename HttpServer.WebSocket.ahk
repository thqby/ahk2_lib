/************************************************************************
 * @description A websocket server implementation, can upgrade the request in HttpServer to websocket.
 * @author thqby
 * @date 2025/06/28
 * @version 1.0.0
 ***********************************************************************/

#Include HttpServer.ahk
#DllLoad Websocket.dll
class WebSocketSession extends HttpServer.Protocol {
	/**
	 * Upgrade an http request to websocket.
	 * @param {HTTP_REQUEST} req An http request.
	 * @param {Response} rsp An http response.
	 * @param {String} subprotocol Specifies the subprotocol used by websocket.
	 */
	__New(req, rsp, subprotocol?) {
		if req._Verb !== 4 || req.Version !== 65537
			check(0x80190190)
		check(DllCall('Websocket\WebSocketCreateServerHandle', 'ptr', 0, 'int', 0, 'ptr*', &handle := 0))
		this.LastPeekTime := l := 0, this.ptr := handle, this.readyState := 1
		for k, v in headers := req.Headers
			l += StrPut(k, 'cp0') + StrPut(v, 'cp0')
		buf := Buffer(l + od := headers.Count * 4 * A_PtrSize), p := buf.Ptr, pd := p + od
		for k, v in headers {
			l := StrPut(k, pd, 'cp0'), p := NumPut('ptr', pd, 'uptr', l - 1, p), pd += l
			l := StrPut(v, pd, 'cp0'), p := NumPut('ptr', pd, 'uptr', l - 1, p), pd += l
		}
		check(DllCall('Websocket\WebSocketBeginServerHandshake', 'ptr', handle,
			IsSet(subprotocol) ? 'astr' : (subprotocol := 0, 'ptr'), subprotocol, 'ptr', 0, 'int', 0,
			'ptr', buf, 'int', headers.Count, 'ptr*', &p := 0, 'int*', &l := 0))
		headers := []
		loop l << 1
			headers.Push(StrGet({ ptr: NumGet(p, 'ptr'), size: NumGet(p, A_PtrSize, 'uint') }, 'cp0')), p += A_PtrSize << 1
		DllCall('Websocket\WebSocketEndServerHandshake', 'ptr', handle)
		rsp.Set(headers*), rsp(this)
		check(err) {
			if err
				throw(((err := OSError(err)).status := 400, err))
		}
	}
	__Delete() => ObjHasOwnProp(this, 'ptr') && DllCall('Websocket\WebSocketDeleteHandle', 'ptr', this.DeleteProp('ptr'))
	/**
	 * Sends a close frame to client and then close the connection. If it is closing, close the connection immediately.
	 * @param {Integer} code An integer [WebSocket connection close code](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.1.5) value indicating a reason for closure.
	 * @param {String} reason A string providing a custom [WebSocket connection close reason](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.1.6)
	 * (a concise human-readable prose explanation for the closure).
	 * The value must be no longer than 123 bytes (encoded in UTF-8).
	 */
	Close(code?, reason?) => 0
	/**
	 * Enqueues the specified data to be transmitted to the client.
	 * @param {Buffer|String|HttpServer.File} data The data to send to the client.
	 * @param {Integer} flag An 8-bit integer. If omitted, 0x81 when `data` is a string, 0x82 otherwise.
	 * This parameter is constructed by using the bitwise OR operator with any of the following [values](https://www.rfc-editor.org/rfc/rfc6455.html#section-5.2).
	 * - FIN:  0x80
	 * - RSV1: 0x40
	 * - RSV2: 0x20
	 * - RSV3: 0x10
	 * - Opcode: 0x0~0xf
	 */
	Send(data?, flag?) => 0

	/**
	 * Triggered when data is received.
	 * @event
	 * @setter
	 */
	OnMessage(data) => 0
	/**
	 * Triggered when the connection is closed.
	 * @event
	 * @setter
	 */
	OnClose(code, reason) => 0
	
	/** @internal */
	CompleteUpgrade(sender) {
		receiver := RequestContext(0, sender._requestQueue, root := sender._root)
		receiver._requestId := sender._requestId
		ObjFromPtrAddRef(root)[ObjPtr(receiver)] := receiver

		db := Buffer(16), buf := Buffer(), ctx := used := 0
		receiver._ws := sender._ws := ObjPtr(this)
		receiver.Call := on_recv, sender.Call := on_send
		sender.DefineProp('send_body', { call: send_body })._olr := ObjPtr(receiver)
		init_ws(this, sender)

		static init_ws(ws, sender) {
			ws.DefineProp('Close', { call: ws_close })
			ws.DefineProp('Send', { call: ws_send })

			ws_send(this, data?, flag?) {
				static empty := { Size: 0 }
				if this.readyState > 1
					throw Error('WebSocket is already in CLOSING or CLOSED state.')
				if !t := IsObject(data ?? data := empty)
					StrPut(data, o := Buffer(StrPut(data, 'utf-8') - 1), 'utf-8'), data := o
				sender.send([data, flag ?? 0x80 | t + 1])
			}
			ws_close(this, code := 1005, reason := '') {
				switch this.readyState {
					case 1:
						data := Buffer()
						if code !== 1005 {
							if 123 < sz := StrPut(reason, 'utf-8') - 1
								throw Error('The close reason must not be greater than 123 UTF-8 bytes.')
							data.Size := sz + 2
							NumPut('ushort', (code & 0xff) << 8 | code >> 8, data)
							if sz
								StrPut(reason, data.Ptr + 2, sz, 'utf-8')
						}
						this.readyState := 2, sender.send([data, 0x88])
					case 2: this.readyState := 3, sender.cancel_request(0)
				}
			}
		}
		static on_send(this, err, *) {
			if err || !ol := ObjFromPtrAddRef(this._root).Get(this._olr, 0)
				return this.cancel_request(err)
			ol(0, 0), (this.Call := this.on_send_response)(this, 0, 0)
		}
		static send_body(this, params) {
			obj := params[1], flag := params[2]
			chunk_size := 32 * n := 2 - !size := obj.Size
			head_size := size < 126 ? 2 : size < 0x10000 ? 4 : 10
			chunk := Buffer(chunk_size + head_size, 0)
			NumPut('int64', 0, 'ptr', p := chunk.Ptr + chunk_size, 'uint', head_size, chunk)
			p := NumPut('uchar', flag, p)
			if size < 126
				p := NumPut('uchar', size, p)
			else if size < 0x10000
				p := NumPut('uchar', 126, 'uchar', size >> 8, 'uchar', size, p)
			else p := NumPut('uchar', 127,
				'uchar', size >>> 56, 'uchar', size >>> 48, 'uchar', size >>> 40, 'uchar', size >>> 32,
				'uchar', size >>> 24, 'uchar', size >>> 16, 'uchar', size >>> 8, 'uchar', size, p)
			if size {
				if obj is HttpServer.File
					NumPut('int64', 1, 'int64', 0, 'int64', -1, 'ptr', obj.handle, chunk, 32)
				else NumPut('int64', 0, 'ptr', obj.Ptr, 'uint', size, chunk, 32)
				chunk._data := obj
			}
			err := DllCall('httpapi\HttpSendResponseEntityBody', 'ptr', this._requestQueue, 'int64', this._requestId,
				'uint', flag & 0xf == 8 ? this._end := 1 : 2, 'ushort', n, 'ptr', chunk, 'ptr', 0, 'ptr', 0, 'uint', 0, 'ptr', this, 'ptr', 0)
			if !err || err == 997
				return chunk
			this.cancel_request(err)
		}
		on_recv(ol, err, bytes) {
			loop {
				DllCall('Websocket\WebSocketCompleteAction', 'ptr', this, 'ptr', ctx, 'uint', bytes)
				if err || err2 := DllCall('Websocket\WebSocketGetAction', 'ptr', this, 'int', 2, 'ptr', db,
					'int*', 1, 'int*', &action := 0, 'uint*', &tp := 0, 'ptr', 0, 'ptr*', &ctx) {
					DllCall('Websocket\WebSocketAbortHandle', 'ptr', this), ctx := 0
					if err
						sender.cancel_request(err)
					else this.Close(1002, OSError(err2).Message)
					this.readyState := 3, ol.clear()
					SetTimer(ObjBindMethod(this, 'OnClose', 1006, ''), -1)
					return
				}
				switch action {
					case 0: DllCall('Websocket\WebSocketReceive', 'ptr', this, 'ptr', bytes := 0, 'ptr', 0, 'hresult')
					case 1:	; ping
						if 2 < bytes := NumGet(db, A_PtrSize, 'uint')
							p := ClipboardAll(NumGet(db, 'ptr') + 2, bytes - 2)
						else {
							DllCall('Websocket\WebSocketCompleteAction', 'ptr', this, 'ptr', ctx, 'uint', bytes)
							DllCall('Websocket\WebSocketGetAction', 'ptr', this, 'int', 1, 'ptr', db,
								'int*', 1, 'int*', &action, 'uint*', &tp, 'ptr', 0, 'ptr*', &ctx)
							if action == 1
								p := ClipboardAll(NumGet(db, 'ptr'), bytes := NumGet(db, A_PtrSize, 'uint'))
							else p := unset, bytes := 0
						}
						this.Send(p?, 0x8a)
					case 3:
						err := DllCall('httpapi\HttpReceiveRequestEntityBody', 'ptr', ol._requestQueue, 'int64', ol._requestId,
							'uint', 0, 'ptr', NumGet(db, 'ptr'), 'uint', NumGet(db, A_PtrSize, 'uint'), 'ptr', 0, 'ptr', ol)
						if !err || err == 997
							return this.LastPeekTime := A_TickCount
						bytes := 0
					case 4:
						bytes := 0, p := NumGet(db, 'ptr'), q := NumGet(db, A_PtrSize, 'uint')
						switch tp {
							case 0x80000000, 0x80000002:
								tp &= 2
								if used
									(data := buf).Size += q, DllCall('RtlMoveMemory', 'ptr', data.Ptr + used, 'ptr', p, 'uptr', q), buf := Buffer(used := 0)
								else data := tp ? ClipboardAll(p, q) : { ptr: p, size: q }
								SetTimer(ObjBindMethod(this, 'OnMessage', tp ? data : StrGet(data, 'utf-8')), -1)
							case 0x80000001, 0x80000003:
								buf.Size += q, DllCall('RtlMoveMemory', 'ptr', buf.Ptr + used, 'ptr', p, 'uptr', q), used += q
							case 0x80000004:	; close
								if p {
									code := NumGet(p - 2, 'ushort'), code := (code & 0xff) << 8 | code >> 8
									reason := StrGet({ ptr: p, size: q }, 'utf-8')
								} else code := 1005, reason := ''
								DllCall('Websocket\WebSocketCompleteAction', 'ptr', this, 'ptr', ctx, 'uint', 0)
								this.Close(code, reason), this.readyState := 3, ol.clear()
								SetTimer(ObjBindMethod(this, 'OnClose', code, reason), -1)
								return
							default:
								tp >>= 1
								OutputDebug(Format('Unknown Frame Header: FIN={}, RSV1={}, RSV2={}, RSV3={}, Opcode=0x{:x}',
									tp >> 7, !!(tp & 64), !!(tp & 32), !!(tp & 16), tp & 0xf))
						}
				}
			}
		}
	}

	static __New() {
		WebSocketSession.DeleteProp('__New'), proto := this.Prototype
		for k in ['OnClose', 'OnMessage'] {
			desc := proto.GetOwnPropDesc(k), desc.set := setter.Bind(k, desc.call.MinParams)
			proto.DefineProp(k, desc)
		}
		setter(method, paramcount, this, value) {
			if !HasMethod(value, , paramcount)
				throw Error(method ' method requires ' paramcount ' parameters.')
			this.DefineProp(method, { call: value })
		}
	}
}
