#Include Socket.ahk
#Include Promise.ahk

/**
 * Send an icmp echo request to test whether the target host is accessible (no requested time).
 * @limit pinging dozens of hosts at the same time may result in packet loss and timeout.
 * @param {String} host Host domain name or ip address.
 * @param {Integer} timeout Timeout in milliseconds.
 * @returns {Promise<Integer>} 1: Accessible; 0: Not accessible; -1: Timeout.
 * @example
 * ping(host).then(MsgBox)
 * MsgBox(ping(host).await())
 * result := Promise.all([ping(host1), ping(host2)]).await()
 */
ping(host, timeout := 0) {
	static requests := Map(), echo_size := 16
	ai := Socket.AddrInfo(host, 0)
	if ai.family == 2 {
		static sock_v4 := create(0)
		sock := sock_v4, echo_type := 8
	} else {
		static sock_v6 := create(1)
		sock := sock_v6, echo_type := 128
	}
	obj := Promise.withResolvers(), requests[pr := ObjPtr(resolve := obj.resolve)] := resolve
	NumPut('short', echo_type, 'short', 0, 'uint', sock.Ptr, 'int64', pr, echo := Buffer(echo_size))
	NumPut('ushort', checksum(echo.Ptr, echo.Size), echo, 2)
	try sock.Send(ai, echo), timeout > 0 && SetTimer(markTimeout.Bind(pr), -timeout)
	catch
		resolve(0)
	return obj.promise
	static create(v6) {
		sock := v6 ? Socket.base(23, 3, 58) : Socket.base(2, 3, 1)
		sock.onRead := read_reply, sock._msg := v6 ? echo_size : echo_size + 20, sock._tp := v6 ? 129 : 0
		return sock
	}
	static read_reply(this, err) {
		if (size := this.MsgSize()) < minmsg := this._msg
			return
		buf := Buffer(size), tp := this._tp, psock := this.Ptr
		while size >= minmsg {
			if 0 > r := this._recv(buf, size)
				throw OSError(this.GetLastError())
			offset := r - echo_size, size -= r
			if NumGet(buf, offset + 4, 'uint') == this.Ptr
				try requests.Delete(NumGet(buf, offset + 8, 'int64'))(NumGet(buf, offset, 'short') == tp)
		}

	}
	static checksum(ptr, size) {
		sum := 0
		loop size >> 1
			sum += NumGet(ptr, 'ushort'), ptr += 2
		while high := sum >> 16
			sum := high + (sum & 0xffff)
		return ~sum & 0xffff
	}
	static markTimeout(ptr) {
		try requests.Delete(ptr)(-1)
	}
}
