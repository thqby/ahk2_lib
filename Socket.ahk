/************************************************************************
 * @description simple implementation of a socket Server and Client.
 * @author thqby
 * @date 2023/02/05
 * @version 1.0.3
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
	static EVENT := { READ: 1, WRITE: 2, OOB: 4, ACCEPT: 8, CONNECT: 16, CLOSE: 32, QOS: 64, GROUP_QOS: 128, ROUTING_INTERFACE_CHANGE: 256, ADDRESS_LIST_CHANGE: 512 }
	; flags of send/recv
	static MSG := { OOB: 1, PEEK: 2, DONTROUTE: 4, WAITALL: 8, INTERRUPT: 0x10, PUSH_IMMEDIATE: 0x20, PARTIAL: 0x8000 }
	static __sockets_table := Map()
	static __New() {
		#DllLoad ws2_32.dll
		if this != Socket
			return
		this.DeleteProp('__New')
		if err := DllCall('ws2_32\WSAStartup', 'ushort', 0x0202, 'ptr', WSAData := Buffer(394 + A_PtrSize))
			throw OSError(err)
		if NumGet(WSAData, 2, 'ushort') != 0x0202
			throw Error('Winsock version 2.2 not available')
		this.DefineProp('__Delete', { call: ((pSocket, self) => ObjPtr(self) == pSocket && DllCall('ws2_32\WSACleanup')).Bind(ObjPtr(Socket)) })
		proto := this.base.Prototype
		for k, v in { addr: '', async: 0, Ptr: -1 }.OwnProps()
			proto.DefineProp(k, { value: v })
		for k in this.EVENT.OwnProps()
			proto.DefineProp('On' k, { set: get_setter('On' k) })
		get_setter(name) {
			return (self, value) => (self.DefineProp(name, { call: value }), self.UpdateMonitoring())
		}
	}
	static GetLastError() => DllCall('ws2_32\WSAGetLastError')

	class AddrInfo {
		static Prototype.size := 48
		static Call(host, port?) {
			if IsSet(port) {
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
		addr := '', async := false, Ptr := -1
		__Delete() {
			if this.Ptr == -1
				return
			this.UpdateMonitoring(false)
			DllCall('ws2_32\closesocket', 'ptr', this)
			this.Ptr := -1
		}

		; Gets the current message size of the receive buffer.
		MsgSize() {
			static FIONREAD := 0x4004667F
			if DllCall('ws2_32\ioctlsocket', 'ptr', this, 'uint', FIONREAD, 'uint*', &argp := 0)
				throw OSError(Socket.GetLastError())
			return argp
		}

		; Choose to receive the corresponding event according to the implemented method. `CONNECT` event is unimplemented
		UpdateMonitoring(start := true) {
			static FIONBIO := 0x8004667E, id_to_event := init_table()
			static WM_SOCKET := DllCall('RegisterWindowMessage', 'str', 'WM_AHK_SOCKET', 'uint')
			flags := 0
			if start
				for k, v in Socket.EVENT.OwnProps()
					if this.HasMethod('on' k)
						flags |= v
			if flags {
				Socket.__sockets_table[this.Ptr] := ObjPtr(this), this.async := 1
				OnMessage(WM_SOCKET, On_WM_SOCKET, 0x7fffffff)
			} else {
				try {
					Socket.__sockets_table.Delete(this.Ptr)
					if !Socket.__sockets_table.Count
						OnMessage(WM_SOCKET, On_WM_SOCKET, 0)
				}
			}
			if this.async
				DllCall('ws2_32\WSAAsyncSelect', 'ptr', this, 'ptr', A_ScriptHwnd, 'uint', WM_SOCKET, 'uint', flags)
			if !flags && start && this.async && !DllCall('ws2_32\ioctlsocket', 'ptr', this, 'int', FIONBIO, 'uint*', 0)
				this.async := 0
			return flags
			static On_WM_SOCKET(wp, lp, *) {
				if !sk := Socket.__sockets_table.Get(wp, 0)
					return
				event := id_to_event[lp & 0xffff]
				ObjFromPtrAddRef(sk).On%event%((lp >> 16) & 0xffff)
			}
			init_table() {
				m := Map()
				for k, v in Socket.EVENT.OwnProps()
					m[v] := k
				return m
			}
		}
	}

	class Client extends Socket.base {
		static Prototype.isConnected := 1
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

		ReConnect(next := false) => 10061

		Send(buf, size?, flags := 0) {
			if (size := DllCall('ws2_32\send', 'ptr', this, 'ptr', buf, 'int', size ?? buf.Size, 'int', flags)) == -1
				throw OSError(Socket.GetLastError())
			return size
		}

		SendText(text, flags := 0, encoding := 'utf-8') {
			buf := Buffer(StrPut(text, encoding) - ((encoding = 'utf-16' || encoding = 'cp1200') ? 2 : 1))
			size := StrPut(text, buf, encoding)
			return this.Send(buf, size, flags)
		}

		_recv(buf, size, flags := 0) => DllCall('ws2_32\recv', 'ptr', this, 'ptr', buf, 'int', size, 'int', flags)

		Recv(&buf, maxsize := 0x7fffffff, flags := 0, timeout := 0) {
			endtime := A_TickCount + timeout
			while !(size := this.MsgSize()) && (!timeout && !this.async || A_TickCount < endtime)
				Sleep(10)
			if !size
				return 0
			buf := Buffer(size := Min(maxsize, size))
			if (size := this._recv(buf, size, flags)) == -1
				throw OSError(Socket.GetLastError())
			return size
		}

		RecvText(flags := 0, timeout := 0, encoding := 'utf-8') {
			if size := this.Recv(&buf, , flags, timeout)
				return StrGet(buf, size, encoding)
			return ''
		}

		RecvLine(flags := 0, timeout := 0, encoding := 'utf-8') {
			static MSG_PEEK := Socket.MSG.PEEK
			endtime := A_TickCount + timeout, buf := Buffer(1, 0), t := flags | MSG_PEEK
			while !(pos := InStr((size := this.Recv(&buf, , t, timeout && (endtime - A_TickCount)), StrGet(buf, size, encoding)), '`n')) {
				if this.async || timeout && A_TickCount > endtime
					return ''
				Sleep(10)
			}
			size := this.Recv(&buf, pos * (encoding = 'utf-16' || encoding = 'cp1200' ? 2 : 1), flags)
			return StrGet(buf, size, encoding)
		}
	}

	class Server extends Socket.base {
		__New(port?, host := '127.0.0.1', socktype := Socket.TYPE.STREAM, protocol := 0, backlog := 4) {
			_ := ai := Socket.AddrInfo(host, port?), ptr := last_family := -1
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

		AcceptAsClient(clientType := Socket.Client) {
			ptr := this._accept(&addr)
			sock := { base: clientType.Prototype, ptr: ptr, async: this.async, addr: addr }
			sock.UpdateMonitoring()
			return sock
		}
	}
}
