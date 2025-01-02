/************************************************************************
 * @description Create a child process, and read stdout/stderr
 * asynchronously, supporting multiple stdin inputs.
 * @author thqby
 * @date 2025/01/02
 * @version 2.0.4
 ***********************************************************************/

class child_process {
	/** @type {Integer} */
	static Prototype.pid := 0
	/** @type {Integer} */
	static Prototype.hProcess := 0
	/** @type {File|unset} */
	static Prototype.stdin := 0
	/** @type {child_process.AsyncPipeReader|unset} */
	static Prototype.stdout := 0, Prototype.stderr := 0

	/**
	 * create a child process, then capture the stdout/stderr outputs.
	 * @param {String} command The name of the module to be executed or the command line to be executed.
	 * @param {Array<String>} [args] List of string arguments.
	 * @param {Object} [options] The object or map with optional property.
	 * @param {String} [options.cwd] Current working directory of the child process.
	 * @param {String} [options.input] The value is passed through stdin to the child process, and stdin is then closed.
	 * @param {Integer} [options.stdin] The stdin handle passed to child process.
	 * @param {Integer} [options.stdout] The stdout handle passed to child process.
	 * @param {Integer|'stdout'} [options.stderr] The stderr handle passed to child process.
	 * @param {String|Array<String>} [options.encoding='cp0'] The encoding(s) of stdin/stdout/stderr.
	 * @param {Integer} [options.hide=true] Hide the subprocess window that would normally be created on Windows systems.
	 * @param {Integer} [options.flags] The defval equal to `DllCall('GetPriorityClass', 'ptr', -1, 'uint')`,
	 * the flags that control the priority class and the creation of the process.
	 * 
	 * @example <caption>Wait for the subprocess to exit and read stdout.</caption>
	 * ping := child_process('ping -n 1 autohotkey.com')
	 * ping.wait()
	 * MsgBox(ping.stdout.read())
	 * 
	 * @example <caption>Read and write stdout/stdin many times</caption>
	 * cmd := child_process('cmd.exe',, { encoding: DllCall('GetOEMCP') })
	 * stdin := cmd.stdin, stdout := cmd.stdout, stdout.complete := false
	 * stdout.onData := (this, str) => RegExMatch(str, '(^|`n)(\s*\w:[^>]*>)$', &m) ?
	 * 	this.append(SubStr(str, this.complete := 1, -m.Len[2])) : this.append(str)
	 * write_and_read(cmd := '') {
	 * 	(cmd && stdin.Write(cmd), stdin.read(0))
	 * 	while !stdout.complete
	 * 		Sleep(10)
	 * 	MsgBox(stdout.read()), stdout.complete := false
	 * }
	 * write_and_read(), write_and_read('dir c:\`n')
	 * write_and_read('ping -n 1 autohotkey.com`n')
	 * cmd.terminate()
	 */
	__New(command, args?, options?) {
		local input, stderr, stdin, stdout := unset
		hide := true, flags := DllCall('GetPriorityClass', 'ptr', -1, 'uint')
		encoding := 'cp0', cwd := params := ''
		if IsSet(options)
			for k, v in options.OwnProps()
				InStr('input,stdin,stdout,stderr,flags,encoding,cwd,hide', k) && %k% := v
		ge := encoding is Array ? (e, i) => e.Has(i) ? e[i] : 'cp0' : (e, i) => e
		if IsSet(args) {
			if args is Array {
				for v in args
					params .= ' ' escapeparam(v)
			} else params := args
		} else if SubStr(command, 1, 1) = '"' || !FileExist(command)
			params := command, command := ''

		static mFlags_offset := (VerCompare(A_AhkVersion, '2.1-alpha.3') >= 0 ? 6 : 4) * A_PtrSize + 8, USEHANDLE := 0x10000000
		(handles := []).__Delete := closehandles

		if !IsSet(stdin) {
			if !DllCall('CreatePipe', "ptr*", &stdin := 0, "ptr*", &stdinW := 0, 'ptr', 0, 'uint', 0)
				Throw OSError()
			handles.Push(stdin), p := ObjPtr(this.stdin := FileOpen(stdinW, 'h', ge(encoding, 1)))
			NumPut('uint', NumGet(p, mFlags_offset, 'uint') & ~USEHANDLE, p, mFlags_offset)
		}
		loop 2
			IsSet(%k := A_Index == 1 ? 'stdout' : 'stderr'%) ||
				handles.Push(%k% := (this.%k% := child_process.AsyncPipeReader(
					k, this, ge(encoding, A_Index + 1))).DeleteProp('hPipeW'))
		stderr := stderr = 'stdout' ? stdout : stderr
		for h in handles
			DllCall('SetHandleInformation', 'ptr', h, 'int', 1, 'int', 1)

		static x64 := A_PtrSize = 8
		si := Buffer(sz := x64 ? 104 : 68, 0), pi := Buffer(x64 ? 24 : 16, 0)
		NumPut('uint', sz, si), NumPut('int64', 0x101 | !hide << 32, si, x64 ? 60 : 44)
		NumPut('ptr', stdin, 'ptr', stdout, 'ptr', stderr, si, sz - A_PtrSize * 3)
		if !DllCall('CreateProcess', 'ptr', command ? StrPtr(command) : 0, 'ptr', params ? StrPtr(params) : 0, 'ptr', 0, 'int', 0,
			'int', true, 'int', flags, 'int', 0, 'ptr', cwd ? StrPtr(cwd) : 0, 'ptr', si, 'ptr', pi)
			Throw OSError()
		handles.Push(NumGet(pi, A_PtrSize, 'ptr')), handles := 0
		this.hProcess := NumGet(pi, 'ptr'), this.pid := NumGet(pi, 2 * A_PtrSize, 'uint')
		if IsSet(input) && stdin := this.DeleteProp('stdin')
			stdin.Write(input), stdin.Read(0)

		static closehandles(handles) {
			for h in handles
				DllCall('CloseHandle', 'ptr', h)
		}
		static escapeparam(s) {
			s := StrReplace(s, '"', '\"', , &c)
			return c || RegExMatch(s, '[\s\v]') ? '"' RegexReplace(s, '(\\*)(?=(\\"|$))', '$1$1') '"' : s
		}
	}
	__Delete() => this.hProcess && (DllCall('CloseHandle', 'ptr', this.hProcess), this.hProcess := 0)
	/**
	 * wait process exit
	 * @returns 0 (false) if the function timed out 
	 */
	wait(timeout := -1) {
		hProcess := this.hProcess, t := A_TickCount, r := 258, old := Critical(0)
		while timeout && 1 == r := DllCall('MsgWaitForMultipleObjects', 'uint', 1, 'ptr*', hProcess, 'int', 0, 'uint', timeout, 'uint', 7423, 'uint')
			(timeout == -1) || timeout := Max(timeout - A_TickCount + t, 0), Sleep(-1)
		Critical(old)
		if r == 0xffffffff
			Throw OSError()
		return r == 258 || !timeout ? 0 : 1
	}
	; terminate process
	terminate(exitCode := 0) => this.hProcess && DllCall('TerminateProcess', 'ptr', this.hProcess, 'uint', exitCode)
	exitCode => (DllCall('GetExitCodeProcess', 'ptr', this.hProcess, 'uint*', &code := 0), code)

	class AsyncPipeReader {
		/** @event onData */
		static Prototype.onData := (this, data) => this.Append(data)
		/** @event onClose */
		static Prototype.onClose := (this) => 0
		static Prototype.data := ''
		__New(name, process, encoding := 0) {
			static bufsize := 16 * 1024
			root := ObjPtr(this), process := ObjPtr(process)
			if -1 == this.Ptr := DllCall('CreateNamedPipe', 'str', pn := '\\.\pipe\' name process, 'uint', 0x40000001,
				'uint', 0, 'uint', 1, 'uint', 0, 'uint', 0, 'uint', 0, 'ptr', 0, 'ptr')
				Throw OSError()
			OVERLAPPED.EnableIoCompletionCallback(this), ol := OVERLAPPED(onConnect)
			err := !DllCall('ConnectNamedPipe', 'ptr', this, 'ptr', this._overlapped := ol) && A_LastError
			if err && err != 997
				Throw OSError()
			this.name := name, emit := buf := 0
			this.hPipeW := DllCall('CreateFile', 'str', pn, 'uint', 0x40000000,
				'uint', 0, 'ptr', 0, 'uint', 0x3, 'uint', 0x40000080, 'ptr', 0, 'ptr')
			this.DefineProp('process', { get: (*) => ObjFromPtrAddRef(process) })
				.DefineProp('setEncoding', { call: setEncoding }), setEncoding(this, encoding)
			onConnect(ol, err, *) {
				local apr := ObjFromPtrAddRef(root)
				if !err {
					buf := Buffer(bufsize), ol.Call := onRead
					err := !DllCall('ReadFile', 'ptr', apr, 'ptr', buf, 'uint', bufsize, 'ptr', 0, 'ptr', ol) && A_LastError
				}
				switch err {
					case 997, 0xC0000120, 0:	; ERROR_IO_PENDING, STATUS_CANCELLED
					case 109, 0xC000014B:		; ERROR_BROKEN_PIPE, STATUS_PIPE_BROKEN
						emit_close(apr)
					default: Throw OSError(err)
				}
			}
			onRead(ol, err, byte) {
				local apr := ObjFromPtrAddRef(root)
				if !err {
					emit(apr, buf, byte)
					err := !DllCall('ReadFile', 'ptr', apr, 'ptr', buf, 'uint', bufsize, 'ptr', 0, 'ptr', ol) && A_LastError
				}
				switch err {
					case 997, 0xC0000120, 0:
					case 109, 0xC000014B:
						emit_close(apr)
					default: Throw OSError(err)
				}
			}
			setEncoding(apr, encoding) {
				if encoding == -1 {
					apr.DefineProp('Append', { call: append_buf })
						.DefineProp('Read', { call: this => (v := this.data, this.data := Buffer(), v) })
						.data := Buffer(), emit := emit_buf
				} else {
					emit := emit_str.Bind(TextStreamDecoder(encoding || DllCall('GetACP')))
					for k in ['data', 'Read', 'Append']
						apr.DeleteProp(k)
				}
			}
			static emit_close(apr) => (apr.onClose(), apr.DeleteProp('onClose'), apr.DeleteProp('onData'), apr.__Delete())
			static emit_buf(apr, buf, byte) => apr.onData({ Ptr: buf.Ptr, Size: byte })
			static emit_str(decoder, apr, buf, byte) => apr.onData(decoder({ Ptr: buf.Ptr, Size: byte }))
			static append_buf(apr, buf) {
				data := apr.data, used := data.Size, data.Size += sz := buf.Size
				DllCall('RtlMoveMemory', 'ptr', buf, 'ptr', data.Ptr + used, 'uptr', sz)
			}
		}
		__Delete() {
			if this.Ptr == -1
				return
			this._overlapped.SafeDelete(this)
			DllCall('CloseHandle', 'ptr', this)
			this.Ptr := -1
		}

		; Default behavior when the onData callback function is not set, append data to the cache.
		append(data) {
			this.data .= data
		}

		isClosed => this.Ptr == -1

		/** @type {child_process} */
		process => 0

		/**
		 * Read the cached data and clear the cache.
		 * @returns {Buffer|String}
		 */
		read() => this.DeleteProp('data')

		setEncoding(encoding) => 0
	}
}
#Include <OVERLAPPED>
#Include <TextStreamDecoder>