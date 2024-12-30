/************************************************************************
 * @description Create a child process, and read stdout/stderr
 * asynchronously, supporting multiple stdin inputs.
 * @author thqby
 * @date 2024/12/29
 * @version 2.0.3
 ***********************************************************************/

class child_process {
	/** @type {Integer} */
	pid := 0
	/** @type {Integer} */
	hProcess := 0
	/** @type {File} */
	stdin := 0
	/** @type {child_process.AsyncPipeReader} */
	stdout := 0, stderr := 0

	/**
	 * create a child process, then capture the stdout/stderr outputs.
	 * @param {String} command The name of the module to be executed or the command line to be executed.
	 * @param {Array<String>} [args] List of string arguments.
	 * @param {Object} [options] The object or map with optional property.
	 * @param {String} [options.cwd] Current working directory of the child process.
	 * @param {String} [options.input] The value is passed through stdin to the child process, and stdin is then closed.
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
	 * cmd := child_process('cmd.exe')
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
		hide := true, flags := DllCall('GetPriorityClass', 'ptr', -1, 'uint')
		encoding := encoding_in := encoding_out := encoding_err := 'cp0'
		input := unset, cwd := params := ''
		if IsSet(options)
			for k, v in options.OwnProps()
				%k% := v
		flags |= hide ? 0x08000000 : 0
		if encoding is Array {
			for i, v in ['in', 'out', 'err']
				encoding.Has(i) ? encoding_%v% := encoding[i] : 0
		} else encoding_in := encoding_out := encoding_err := encoding
		if IsSet(args) {
			if args is Array {
				for v in args
					params .= ' ' escapeparam(v)
			} else params := args
		} else if SubStr(command, 1, 1) = '"' || !FileExist(command)
			params := command, command := ''

		if !DllCall('CreatePipe', "ptr*", &stdinR := 0, "ptr*", &stdinW := 0, 'ptr', 0, 'uint', 0)
			Throw OSError()
		(handles := [stdinR]).__Delete := closehandles
		this.stdin := FileOpen(stdinW, 'h', encoding_in)
		this.stdin.DefineProp('Write', { call: Write_by_ControlSend })
		Write_by_ControlSend(_, text) {
			bak_A_DetectHiddenWindows:=A_DetectHiddenWindows
			; bak_A_KeyDelay:=A_KeyDelay
			A_DetectHiddenWindows:=1
			; A_KeyDelay:=-1
			Loop 25 {
				if (!(hwnd:=WinExist("ahk_pid " this.pid))) {
					Sleep 10
				}
			}
			buf := {Ptr:StrPtr(text),Size:StrLen(text)<<1}
			ptr:=buf.Ptr
			end:=buf.Ptr + buf.Size
			while (ptr < end) {
				DllCall("PostMessageW","Ptr",hwnd,"Uint",0x0102,"Ptr",NumGet(ptr,"uShort"),"Ptr",0) ;WM_CHAR
				ptr+=2
			}
			; ControlSend(text,,hwnd) ; Send order isn't consistent with this (it uses both WM_KEYDOWN and WM_CHAR)
			A_DetectHiddenWindows:=bak_A_DetectHiddenWindows
			; A_KeyDelay:=bak_A_KeyDelay
		}
		static mFlags_offset := (VerCompare(A_AhkVersion, '2.1-alpha.3') >= 0 ? 6 : 4) * A_PtrSize + 8, USEHANDLE := 0x10000000
		; remove USEHANDLE flag, auto close handle
		NumPut('uint', NumGet(p := ObjPtr(this.stdin), mFlags_offset, 'uint') & ~USEHANDLE, p, mFlags_offset)
		this.stdout := child_process.AsyncPipeReader('stdout', this, encoding_out)
		this.stderr := child_process.AsyncPipeReader('stderr', this, encoding_err)

		static x64 := A_PtrSize = 8
		STARTUPINFO := Buffer(sz := x64 ? 104 : 68, 0)
		PROCESS_INFORMATION := Buffer(x64 ? 24 : 16, 0)
		NumPut('uint', sz, STARTUPINFO), NumPut('uint', 0x101, STARTUPINFO, x64 ? 60 : 44)
		NumPut('ptr', 0, 'ptr', stdoutW := this.stdout.DeleteProp('hPipeW'), 'ptr',
			stderrW := this.stderr.DeleteProp('hPipeW'), STARTUPINFO, sz - A_PtrSize * 3)
		handles.Push(stdoutW, stderrW)
		for h in handles
			DllCall('SetHandleInformation', 'ptr', h, 'int', 1, 'int', 1)

		if !DllCall('CreateProcess', 'ptr', command ? StrPtr(command) : 0, 'ptr', params ? StrPtr(params) : 0, 'ptr', 0, 'int', 0,
			'int', true, 'int', flags | 0x10, 'int', 0, 'ptr', cwd ? StrPtr(cwd) : 0, 'ptr', STARTUPINFO, 'ptr', PROCESS_INFORMATION)
			Throw OSError()
		handles.Push(NumGet(PROCESS_INFORMATION, A_PtrSize, 'ptr')), handles := 0
		this.hProcess := NumGet(PROCESS_INFORMATION, 'ptr'), this.pid := NumGet(PROCESS_INFORMATION, 2 * A_PtrSize, 'uint')

		if IsSet(input)
			this.stdin.Write(input), this.stdin.Read(0), this.stdin := unset

		closehandles(handles) {
			for h in handles
				DllCall('CloseHandle', 'ptr', h)
		}
		escapeparam(s) {
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
			if -1 == this.Ptr := DllCall('CreateNamedPipe', 'str', pn := '\\.\pipe\' name ObjPtr(this), 'uint', 0x40000001,
				'uint', 0, 'uint', 1, 'uint', 0, 'uint', 0, 'uint', 0, 'ptr', 0, 'ptr')
				Throw OSError()
			OVERLAPPED.EnableIoCompletionCallback(this)
			root := ObjPtr(this), process := ObjPtr(process), ol := OVERLAPPED(onConnect)
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