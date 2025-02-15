/************************************************************************
 * @description simple implementation of a socket Server and Client.
 * @author thqby
 * @date 2025/02/15
 * @version 1.0.7
 ***********************************************************************/

/**
 * Contains two base classes, `Socket.Server` and `Socket.Client`,
 * and handles asynchronous messages by implementing the `on%EventName%(err)` method of the class.
 * If none of these methods are implemented, it will be synchronous mode.
 */
class Socket {
	; sock type
	static TYPE := { STREAM: 1, DGRAM: 2, RAW: 3, RDM: 4, SEQPACKET: 5 }
	; address family
	static AF := { UNSPEC: 0, UNIX: 1, INET: 2, IPX: 6, APPLETALK: 16, NETBIOS: 17, INET6: 23, IRDA: 26, BTH: 32 }
	; sock protocol
	static IPPROTO := { ICMP: 1, IGMP: 2, RFCOMM: 3, TCP: 6, UDP: 17, ICMPV6: 58, RM: 113 }
	; flags of send/recv
	static MSG := { OOB: 1, PEEK: 2, DONTROUTE: 4, WAITALL: 8, INTERRUPT: 0x10, PUSH_IMMEDIATE: 0x20, PARTIAL: 0x8000 }
	static __New() {
		#DllLoad ws2_32.dll
		if this != Socket
			throw Error('Invalid base class')
		if err := DllCall('ws2_32\WSAStartup', 'ushort', 0x0202, 'ptr', WSAData := Buffer(394 + A_PtrSize, 0))
			throw OSError(err)
		if NumGet(WSAData, 2, 'ushort') != 0x0202
			throw Error('Winsock version 2.2 not available')
		this.DefineProp('__Delete', { call: (*) => DllCall('ws2_32\WSACleanup') })
		proto := this.base.Prototype
		for k, v in { addr: '', Ptr: -1 }.OwnProps()
			proto.DefineProp(k, { value: v })
	}
	static GetLastError() => DllCall('ws2_32\WSAGetLastError')

	class AddrInfo {
		static Prototype.size := 48
		static Call(host, port := 0) {
			if port {
				if err := DllCall('ws2_32\GetAddrInfoW', 'str', host, 'str', String(port), 'ptr', 0, 'ptr*', &addr := 0)
					throw OSError(err, -1)
				return { base: this.Prototype, ptr: addr, __Delete: this => DllCall('ws2_32\FreeAddrInfoW', 'ptr', this) }
			}
			; struct sockaddr_un used to connect to AF_UNIX socket
			NumPut('ushort', 1, buf := Buffer(158, 0), 48), StrPut(host, buf.Ptr + 50, 'cp0')
			NumPut('int', 0, 'int', 1, 'int', 0, 'int', 0, 'uptr', 110, 'ptr', 0, 'ptr', buf.Ptr + 48, buf)
			return { base: this.Prototype, buf: buf, ptr: buf.Ptr }
		}
		flags => NumGet(this, 'int')
		family => NumGet(this, 4, 'int')
		socktype => NumGet(this, 8, 'int')
		protocol => NumGet(this, 12, 'int')
		addrlen => NumGet(this, 16, 'uptr')
		canonname => StrGet(NumGet(this, 16 + A_PtrSize, 'ptr') || StrPtr(''))
		addr => NumGet(this, 16 + 2 * A_PtrSize, 'ptr')
		next => (p := NumGet(this, 16 + 3 * A_PtrSize, 'ptr')) && ({ base: this.Base, ptr: p })
		addrstr => (this.family = 1 ? StrGet(this.addr + 2, 'cp0') : !DllCall('ws2_32\WSAAddressToStringW', 'ptr', this.addr, 'uint', this.addrlen, 'ptr', 0, 'ptr', b := Buffer(s := 2048), 'uint*', &s) && StrGet(b))
	}

	class base {
		__Delete() => this.Close()
		Close() {
			if this.Ptr == -1
				return
			this.UpdateMonitoring(-1)
			DllCall('ws2_32\closesocket', 'ptr', this)
			this.Ptr := -1
		}

		GetLastError() => DllCall('ws2_32\WSAGetLastError')

		; Gets the current message size of the receive buffer.
		MsgSize(timeout := 0) {
			r := ObjHasOwnProp(this, '_async_select') || (timeout || timeout := 0xffffffff) && ioctl(this, 0x8004667E, 1)
			argp := &size := 0, timeout += A_TickCount
			loop
				ioctl(this, 0x4004667F, argp)
			until size || A_TickCount >= timeout || isClosed(this) || Sleep(10)
			(r) || ioctl(this, 0x8004667E, 0)
			return size
			ioctl(this, cmd, arg) => DllCall('ws2_32\ioctlsocket', 'ptr', this, 'uint', cmd, 'uint*', arg)
			isClosed(this) => DllCall('ws2_32\recv', 'ptr', this, 'int*', 0, 'int', 1, 'int', 2) <= 0
				&& Socket.GetLastError() !== 10035
		}

		; Choose to receive the corresponding event according to the implemented method.
		UpdateMonitoring(start := true) {
			static WM_SOCKET := DllCall('RegisterWindowMessage', 'str', 'WM_AHK_SOCKET', 'uint')
			static EVENT := { READ: 1, OOB: 4, ACCEPT: 8, CONNECT: 16, CLOSE: 32, QOS: 64 }
			static mapget := Map.Prototype.Get, sockets_table := Map()
			static FIONBIO := 0x8004667E, id_to_event := init_table()
			if start > flags := 0
				for k, v in EVENT.OwnProps()
					if this.HasMethod('on' k)
						flags |= v
			if flags {
				if !sockets_table.Count
					OnMessage(WM_SOCKET, On_WM_SOCKET, 255)
				sockets_table[this.Ptr] := ObjPtr(this)
				this.DefineProp('_async_select', { call: _async_select })
				this._define_async_methods(), _async_select(this, flags, 0)
				return
			}
			if ObjHasOwnProp(this, '_async_select')
				this.DefineProp('_async_select', { call: (*) => 0 })
			_async_select(this, 0, 0)
			try sockets_table.Delete(this.Ptr), !sockets_table.Count && OnMessage(WM_SOCKET, On_WM_SOCKET, 0)
			if start > -1 && !DllCall('ws2_32\ioctlsocket', 'ptr', this, 'int', FIONBIO, 'uint*', 0)
				this.OnWrite(0)
			_async_select(this, _flags, mode := 1) {
				if mode && flags == _flags := mode > 0 ? flags | _flags : flags & ~_flags
					return
				if DllCall('ws2_32\WSAAsyncSelect', 'ptr', this, 'ptr', A_ScriptHwnd,
					'uint', WM_SOCKET, 'uint', flags := _flags)
				throw OSError(Socket.GetLastError())
			}
			static On_WM_SOCKET(wp, lp, *) {
				if !sk := mapget(sockets_table, wp, 0)
					return
				sk := ObjFromPtrAddRef(sk), ev := lp & 0xffff, err := (lp >> 16) & 0xffff
				switch ev {
					case 1: sk._async_select(1, -1), sk.OnRead(err), sk._async_select(1)
					case 2: sk.OnWrite(err)
					default: sk.On%id_to_event[ev]%(err)
				}
				return 0
			}
			static init_table() {
				m := Map(), proto := Socket.base.Prototype
				for k, v in EVENT.OwnProps()
					m[v] := k, proto.DefineProp(k := 'On' StrTitle(k), { set: get_setter(k) })
				return m
			}
			static get_setter(name) {
				return (self, value) => (self.DefineProp(name, { call: value }), self.UpdateMonitoring())
			}
		}

		/** @internal */
		OnWrite(err) => 0

		_define_async_methods() {
			queue := [], index := ql := 0
			this._define_methods(_define_async_methods, OnWrite, Send)
			_define_async_methods(*) => 0
			Send(this, buf, size?) {
				if !ql {
					if 0 > sz := DllCall('ws2_32\send', 'ptr', this, 'ptr', buf, 'int', size ?? buf.Size, 'int', 0) {
						if 10035 !== err := Socket.GetLastError()
							throw OSError(err)
						this._async_select(2)
					} else return sz
				}
				queue.Push(IsSet(size) ? ClipboardAll(buf, size) : buf), ql++
				return 0
			}
			OnWrite(this, err) {
				while ++index <= ql {
					if 0 > DllCall('ws2_32\send', 'ptr', this, 'ptr', buf := queue.Delete(index),
						'int', buf.size, 'int', 0) {
						queue[index] := buf, err := Socket.GetLastError()
						break
					}
				}
				if --index && index >= ql >> 1
					queue.RemoveAt(1, index), ql -= index, index := 0
				if err && err !== 10035
					throw OSError(err)
			}
		}

		_define_methods(methods*) {
			for m in methods
				this.DefineProp(m.Name, { call: m })
		}
	}

	class Client extends Socket.base {
		static Prototype.isConnected := 1
		/**
		 * Create a socket client to connect to the specified server.
		 * @param {String} host The name of host, if port is 0, the value should be the path of pipe or file.
		 * @param {Number} port Listen to the specified port, and if it is 0, listen to the pipe or file.
		 * @param {Socket.TYPE} socktype The type of socket.
		 * @param {Socket.IPPROTO} protocol The protocol of socket.
		 * @example <caption>https://github.com/thqby/ahk2_lib/issues/27</caption>
		 */
		__New(host, port?, socktype := Socket.TYPE.STREAM, protocol := 0) {
			this.addrinfo := host is Socket.AddrInfo ? host : Socket.AddrInfo(host, port?)
			last_family := -1, err := ai := 0
			loop {
				if !connect(this, A_Index > 1) || err == 10035
					return this.DefineProp('ReConnect', { call: connect })
			} until !ai
			throw OSError(err, -1)
			connect(this, next := false) {
				this.isConnected := 0
				if !ai := !next ? (last_family := -1, this.addrinfo) : ai && ai.next
					return 10061
				if ai.family == 1 && SubStr(ai.addrstr, 1, 9) = '\\.\pipe\'
					token := {
						ptr: DllCall('CreateNamedPipeW', 'str', ai.addrstr, 'uint', 1, 'uint', 4, 'uint', 1, 'uint', 0, 'uint', 0, 'uint', 0, 'ptr', 0, 'ptr'),
						__Delete: this => DllCall('CloseHandle', 'ptr', this)
					}
				if last_family != ai.family && this.Ptr != -1
					this.__Delete()
				while this.Ptr == -1 {
					if -1 == this.Ptr := DllCall('ws2_32\socket', 'int', ai.family, 'int', socktype, 'int', protocol, 'ptr')
						return (err := Socket.GetLastError(), connect(this, 1), err)
					last_family := ai.family
				}
				this.addr := ai.addrstr, this.HasMethod('onConnect') && this.UpdateMonitoring()
				if !DllCall('ws2_32\connect', 'ptr', this, 'ptr', ai.addr, 'uint', ai.addrlen)
					return (this.UpdateMonitoring(), this.isConnected := 1, err := 0)
				return err := Socket.GetLastError()
			}
		}

		_OnConnect(err) {
			if !err
				this.isConnected := 1
			else if err == 10061 && (err := this.ReConnect(true)) == 10035
				return
			else throw OSError(err)
		}

		; When it is a client, it is used to reconnect after disconnecting from the server.
		ReConnect(next := false) => 10061

		/**
		 * Sends data on a connected socket.
		 * @param {Buffer|Integer} buf The data to be transmitted.
		 * @param {Integer} size The size of data. When asynchronous transmission is not completed
		 * and this parameter is specified, a copy of the data will be created.
		 * @returns {Integer} The total number of bytes sent.
		 * Returns 0 when asynchronous sending is not completed.
		 */
		Send(buf, size?) {
			if 0 > sz := DllCall('ws2_32\send', 'ptr', this, 'ptr', buf, 'int', size ?? buf.Size, 'int', 0)
				throw OSError(Socket.GetLastError())
			return sz
		}

		SendText(text, encoding := 'utf-8') {
			StrPut(text, buf := Buffer(StrPut(text, encoding) - (encoding = 'utf-16' || encoding = 'cp1200' ? 2 : 1)), encoding)
			return this.Send(buf)
		}

		/**
		 * @param {Socket.MSG} flags A set of flags that specify the way in which the call is made.
		 * This parameter is constructed by using the bitwise OR operator with any of the following values.
		 * - OOB — Processes Out Of Band (OOB) data.
		 * - PEEK — Peeks at the incoming data. The data is copied into the buffer, but is not removed from the input queue.
		 * - WAITALL
		 */
		_recv(buf, size?, flags := 0) {
			if 0 > sz := DllCall('ws2_32\recv', 'ptr', this, 'ptr', buf, 'int', size ?? buf.Size, 'int', flags)
				throw OSError(Socket.GetLastError())
			return sz
		}

		Recv(timeout := 0, flags := 0) {
			if !size := this.MsgSize(timeout)
				return 0
			this._recv(buf := Buffer(size), size, flags)
			return buf
		}

		RecvText(encoding := 'utf-8', timeout := 0, flags := 0) {
			if buf := this.Recv(timeout, flags)
				return StrGet(buf, encoding)
			return ''
		}

		/**
		 * Start SSL/TLS handshake, establish a secure connection.
		 * @param {TLSAuth} tls
		 */
		StartTLS(tls) => tls.wrapSocket(this)
	}

	class Server extends Socket.base {
		/**
		 * Create a socket server to listen to the specified port or local file.
		 * @param {Integer} port Listen to the specified port, and if it is 0, listen to the pipe or file.
		 * @param {String} host The name of host, if port is 0, the value should be the path of pipe or file.
		 * @param {Socket.TYPE} socktype The type of socket.
		 * @param {Socket.IPPROTO} protocol The protocol of socket.
		 * @param {Integer} backlog The maximum length of the queue of pending connections.
		 * @example <caption>https://github.com/thqby/ahk2_lib/issues/27</caption>
		 */
		__New(port := 0, host := '0.0.0.0', socktype := Socket.TYPE.STREAM, protocol := 0, backlog := 4) {
			_ := ai := Socket.AddrInfo(host, port), ptr := last_family := -1
			if ai.family == 1
				this.file := make_del_token(ai.addrstr)
			loop {
				if last_family != ai.family {
					(ptr != -1) && (DllCall('ws2_32\closesocket', 'ptr', ptr), this.Ptr := -1)
					if -1 == (ptr := DllCall('ws2_32\socket', 'int', ai.family, 'int', socktype, 'int', protocol, 'ptr'))
						continue
					last_family := ai.family, this.Ptr := ptr
				}
				if !DllCall('ws2_32\bind', 'ptr', ptr, 'ptr', ai.addr, 'uint', ai.addrlen, 'int')
					&& !DllCall('ws2_32\listen', 'ptr', ptr, 'int', backlog)
					return (this.addr := ai.addrstr, this.UpdateMonitoring(), 0)
			} until !ai := ai.next
			throw OSError(Socket.GetLastError(), -1)
			make_del_token(file) {
				if SubStr(file, 1, 9) = '\\.\pipe\'
					token := {
						ptr: DllCall('CreateNamedPipeW', 'str', file, 'uint', 1, 'uint', 4, 'uint', backlog, 'uint', 0, 'uint', 0, 'uint', 0, 'ptr', 0, 'ptr'),
						__Delete: this => DllCall('CloseHandle', 'ptr', this)
					}
				else
					token := { file: file, __Delete: this => FileExist(this.file) && FileDelete(this.File) }, token.__Delete()
				return token
			}
		}

		_accept(&addr?) {
			if -1 == (ptr := DllCall('ws2_32\accept', 'ptr', this, 'ptr', addr := Buffer(addrlen := 128, 0), 'int*', &addrlen, 'ptr'))
				throw OSError(Socket.GetLastError())
			if NumGet(addr, 'ushort') != 1
				DllCall('ws2_32\WSAAddressToStringW', 'ptr', addr, 'uint', addrlen, 'ptr', 0, 'ptr', b := Buffer(s := 2048), 'uint*', &s), addr := StrGet(b)
			else addr := this.addr
			return ptr
		}

		/**
		 * Accept the connection of socket client.
		 * @param {typeof Socket.Client} clientType The class for socket instantiation.
		 * @returns {Socket.Client}
		 */
		AcceptAsClient(clientType := Socket.Client) {
			ptr := this._accept(&addr)
			sock := { base: clientType.Prototype, addr: addr, ptr: ptr }
			sock.UpdateMonitoring()
			return sock
		}
	}
}
