; #DllLoad "ws2_32.dll"
class Socket {
	static WM_SOCKET := 0x9987, MSG_PEEK := 2, FD_READ := 1, FD_ACCEPT := 8, FD_CLOSE := 32, Blocking := true, BlockSleep := 50
	Bound := false
	ProtocolId := 6	; IPPROTO_TCP
	SocketType := 1	; SOCK_STREAM
	__New(Socket := -1) {
		static Init := 0
		if (!Init) {
			DllCall("LoadLibrary", "Str", "ws2_32", "Ptr")
			WSAData := BufferAlloc(394 + A_PtrSize)
			if (Error := DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData))
				throw Exception("Error starting Winsock", , Error)
			if (NumGet(WSAData, 2, "UShort") != 0x0202)
				throw Exception("Winsock version 2.2 not available")
			Init := true
		}
		this.Socket := Socket
	}

	__Delete() {
		if (this.Socket != -1)
			this.Disconnect()
	}

	Connect(Address) {
		if (this.Socket != -1)
			throw Exception("Socket already connected")
		Next := pAddrInfo := this.GetAddrInfo(Address)
		while Next {
			ai_addrlen := NumGet(Next + 0, 16, "UPtr")
			ai_addr := NumGet(Next + 0, 16 + (2 * A_PtrSize), "Ptr")
			if ((this.Socket := DllCall("ws2_32\socket", "Int", NumGet(Next + 0, 4, "Int")
				, "Int", this.SocketType, "Int", this.ProtocolId, "UInt")) != -1) {
				if (DllCall("ws2_32\WSAConnect", "UInt", this.Socket, "Ptr", ai_addr
					, "UInt", ai_addrlen, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Int") = 0) {
					DllCall("ws2_32\freeaddrinfo", "Ptr", pAddrInfo)	; TODO: Error Handling
					return this.EventProcRegister(Socket.FD_READ | Socket.FD_CLOSE)
				}
				this.Disconnect()
			}
			Next := NumGet(Next + 0, 16 + (3 * A_PtrSize), "Ptr")
		}
		throw Exception("Error connecting")
	}

	Bind(Address) {
		if (this.Socket != -1)
			throw Exception("Socket already connected")
		Next := pAddrInfo := this.GetAddrInfo(Address)
		while Next {
			ai_addrlen := NumGet(Next + 0, 16, "UPtr")
			ai_addr := NumGet(Next + 0, 16 + (2 * A_PtrSize), "Ptr")
			if ((this.Socket := DllCall("ws2_32\socket", "Int", NumGet(Next + 0, 4, "Int")
				, "Int", this.SocketType, "Int", this.ProtocolId, "UInt")) != -1) {
				if (DllCall("ws2_32\bind", "UInt", this.Socket, "Ptr", ai_addr
					, "UInt", ai_addrlen, "Int") == 0) {
					DllCall("ws2_32\freeaddrinfo", "Ptr", pAddrInfo)	; TODO: ERROR HANDLING
					return this.EventProcRegister(Socket.FD_READ | Socket.FD_ACCEPT | Socket.FD_CLOSE)
				}
				this.Disconnect()
			}
			Next := NumGet(Next + 0, 16 + (3 * A_PtrSize), "Ptr")
		}
		throw Exception("Error binding")
	}

	Listen(backlog := 32) {
		return DllCall("ws2_32\listen", "UInt", this.Socket, "Int", backlog) == 0
	}

	Accept() {
		if ((s := DllCall("ws2_32\accept", "UInt", this.Socket, "Ptr", 0, "Ptr", 0, "Ptr")) == -1)
			throw Exception("Error calling accept", , this.GetLastError())
		Sock := Socket(s)
		Sock.ProtocolId := this.ProtocolId
		Sock.SocketType := this.SocketType
		Sock.EventProcRegister(Socket.FD_READ | Socket.FD_CLOSE)
		return Sock
	}

	Disconnect() {
		; Return 0 if not connected
		if (this.Socket == -1)
			return 0

		; Unregister the socket event handler and close the socket
		this.EventProcUnregister()
		if (DllCall("ws2_32\closesocket", "UInt", this.Socket, "Int") == -1)
			throw Exception("Error closing socket", , this.GetLastError())
		this.Socket := -1
		return 1
	}

	MsgSize() {
		static FIONREAD := 0x4004667F
		if (DllCall("ws2_32\ioctlsocket", "UInt", this.Socket, "UInt", FIONREAD, "UInt*", &argp := 0) == -1)
			throw Exception("Error calling ioctlsocket", , this.GetLastError())
		return argp
	}

	Send(pBuffer, BufSize, Flags := 0) {
		if ((r := DllCall("ws2_32\send", "UInt", this.Socket, "Ptr", pBuffer, "Int", BufSize, "Int", Flags)) == -1)
			throw Exception("Error calling send", , this.GetLastError())
		return r
	}

	SendText(Text, Flags := 0, Encoding := "UTF-8") {
		VarSetStrCapacity(&Buffer, StrPut(Text, Encoding) * ((Encoding = "UTF-16" || Encoding = "cp1200") ? 2 : 1))
		Length := StrPut(Text, StrPtr(Buffer), Encoding)
		return this.Send(StrPtr(Buffer), Length - 1)
	}

	Recv(&Buffer, BufSize := 0, Flags := 0) {
		while (!(Length := this.MsgSize()) && Socket.Blocking)
			Sleep Socket.BlockSleep
		if !Length
			return 0
		if !BufSize
			BufSize := Length
		VarSetStrCapacity(&Buffer, BufSize)
		if ((r := DllCall("ws2_32\recv", "UInt", this.Socket, "Ptr", StrPtr(Buffer), "Int", BufSize, "Int", Flags)) == -1)
			throw Exception("Error calling recv", , this.GetLastError())
		return r
	}

	RecvText(BufSize := 0, Flags := 0, Encoding := "UTF-8") {
		if (Length := this.Recv(&Buffer := 0, BufSize, flags))
			return StrGet(StrPtr(Buffer), Length, Encoding)
		return ""
	}

	RecvLine(BufSize := 0, Flags := 0, Encoding := "UTF-8", KeepEnd := false) {
		while !(i := InStr(this.RecvText(BufSize, Flags | Socket.MSG_PEEK, Encoding), "`n")) {
			if !Socket.Blocking
				return ""
			Sleep Socket.BlockSleep
		}
		if KeepEnd
			return this.RecvText(i, Flags, Encoding)
		else
			return RTrim(this.RecvText(i, Flags, Encoding), "`r`n")
	}

	GetAddrInfo(Address) {
		; TODO: Use GetAddrInfoW
		Host := Address[1], Port := Address[2]
		Hints := BufferAlloc(16 + (4 * A_PtrSize), 0)
		NumPut("Int", this.SocketType, "Int", this.ProtocolId, Hints, 8)
		if (Error := DllCall("ws2_32\getaddrinfo", "AStr", Host, "AStr", Port, "Ptr", Hints, "Ptr*", &Result := 0))
			throw Exception("Error calling GetAddrInfo", , Error)
		return Result
	}

	OnMessage(wParam, lParam, Msg, hWnd) {
		if (Msg != Socket.WM_SOCKET || wParam != this.Socket)
			return
		if (lParam & Socket.FD_READ)
			this.HasOwnProp('onRecv') ? this.onRecv() : 0
		else if (lParam & Socket.FD_ACCEPT)
			this.HasOwnProp('onAccept') ? this.onAccept() : 0
		else if (lParam & Socket.FD_CLOSE)
			this.EventProcUnregister(), this.OnDisconnect()
	}

	EventProcRegister(lEvent) {
		this.AsyncSelect(lEvent)
		if !this.Bound {
			this.Bound := (w, l, m, h) => (this.OnMessage(w, l, m, h))
			OnMessage(Socket.WM_SOCKET, this.Bound)
		}
	}

	EventProcUnregister() {
		this.AsyncSelect(0)
		if this.Bound {
			OnMessage(Socket.WM_SOCKET, this.Bound, 0)
			this.Bound := false
		}
	}

	AsyncSelect(lEvent) {
		if (DllCall("ws2_32\WSAAsyncSelect"
			, "UInt", this.Socket	; s
			, "Ptr", A_ScriptHwnd	; hWnd
			, "UInt", Socket.WM_SOCKET	; wMsg
			, "UInt", lEvent) == -1)	; lEvent
			throw Exception("Error calling WSAAsyncSelect", , this.GetLastError())
	}

	GetLastError() {
		return DllCall("ws2_32\WSAGetLastError")
	}
}

class SocketTCP extends Socket {
	ProtocolId := 6	; IPPROTO_TCP
	SocketType := 1	; SOCK_STREAM
}

class SocketUDP extends Socket {
	ProtocolId := 17	; IPPROTO_UDP
	SocketType := 2	; SOCK_DGRAM

	SetBroadcast(Enable) {
		static SOL_SOCKET := 0xFFFF, SO_BROADCAST := 0x20
		if (DllCall("ws2_32\setsockopt"
			, "UInt", this.Socket	; SOCKET s
			, "Int", SOL_SOCKET	; int    level
			, "Int", SO_BROADCAST	; int    optname
			, "UInt*", !!Enable	; *char  optval
			, "Int", 4) == -1)	; int    optlen
			throw Exception("Error calling setsockopt", , this.GetLastError())
	}
}