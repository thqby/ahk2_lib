/************************************************************************
 * @author thqby
 * @date 2022/12/24
 * @version 1.0.2
 ***********************************************************************/

class child_process {
	pid := 0, hProcess := 0, onData := 0, onClose := 0
	stdin := 0, stdout := 0, stderr := 0, output := [], error := [], laststdoutindex := 0

	/**
	 * create a child process, then capture the stdout/stderr outputs.
	 * @param command The name of the module to be executed or the command line to be executed.
	 * @param args List of string arguments.
	 * @param sync Get the output by synchronous blocking method, `stdin` will be closed after `CreateProcess`.
	 * @param options The object or map with optional property.
	 * 
	 * `cwd` = '', Current working directory of the child process.
	 * 
	 * `input` = '', The value which will be passed as stdin to the child process.(only sync mode)
	 * 
	 * `encoding` = 'cp0' or ['cp0','cp0','cp0'], The encoding(s) of stdin/stdout/stderr.
	 * 
	 * `hide` = true, hide the subprocess window that would normally be created on Windows systems.
	 * 
	 * `flags` = DllCall('GetPriorityClass', 'ptr', -1, 'uint'), The flags that control the priority class and the creation of the process.
	 * 
	 * `onData`, The callback function that is called when stdout/stderr receives data. Close the pipe when the callback returns true.
	 * 
	 * `onClose` The callback function that is called when stdout/stderr is closed.
	 */
	__New(command, args := unset, sync := false, options := 0) {
		handles := [], handles.DefineProp('__Delete', { call: closehandles })
		hide := true, flags := DllCall('GetPriorityClass', 'ptr', -1, 'uint')
		encoding := encoding_in := encoding_out := encoding_err := 'cp0'
		input := cwd := params := '', onData := onClose := 0
		if options
			for k, v in (options is Object ? options.OwnProps() : options)
				try %k% := v
		flags |= hide ? 0x08000000 : 0, this.onData := onData, this.onClose := onClose
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

		x64 := (A_PtrSize = 8), STARTUPINFO := Buffer(x64 ? 104 : 68, 0), PROCESS_INFORMATION := Buffer(x64 ? 24 : 16)
		NumPut('uint', x64 ? 104 : 68, STARTUPINFO), NumPut('uint', 0x100, STARTUPINFO, x64 ? 60 : 44)
		sp := NumPut('ptr', (handles.Push(t := this.Pipe('stdin', encoding_in)), t), sp := (x64 ? 80 : 56) + STARTUPINFO.Ptr)
		sp := NumPut('ptr', (handles.Push(t := this.Pipe('stdout', encoding_out)), t), sp)
		sp := NumPut('ptr', (handles.Push(t := this.Pipe('stderr', encoding_err)), t), sp)

		if !DllCall('CreateProcess', 'ptr', command ? StrPtr(command) : 0, 'ptr', params ? StrPtr(params) : 0, 'ptr', 0, 'int', 0,
			'int', true, 'int', flags, 'int', 0, 'ptr', cwd ? StrPtr(cwd) : 0, 'ptr', STARTUPINFO, 'ptr', PROCESS_INFORMATION)
			throw OSError(A_LastError)
		handles.Push(NumGet(PROCESS_INFORMATION, A_PtrSize, 'ptr')), handles := 0
		this.hProcess := NumGet(PROCESS_INFORMATION, 'ptr'), this.pid := NumGet(PROCESS_INFORMATION, 2 * A_PtrSize, 'uint')
		this.output.DefineProp('toString', { call: toString }), this.error.DefineProp('toString', { call: toString })
		if sync {
			this.stdin := input ? (this.stdin.Write(input), '') : ''
			while this()
				continue
		} else SetTimer(this, 20, 10000)
		closehandles(obj) {
			for h in obj
				DllCall('CloseHandle', 'ptr', h)
		}
		escapeparam(s) {
			s := StrReplace(s, '"', '\"', , &c)
			return c || RegExMatch(s, '\s') ? '"' s '"' : s
		}
		toString(arr, begin := 0) {	; zero-based index
			static mIndex_offset := 6 * A_PtrSize + 16
			for v in (s := '', begin > 0 ? (NumPut('uint', begin - 1, ObjPtr(enum := arr.__Enum(1)), mIndex_offset), enum) : arr)
				s .= '`n' v
			return SubStr(s, 2)
		}
	}
	__Delete() {
		if this.hProcess
			DllCall('CloseHandle', 'ptr', this.hProcess), this.hProcess := 0
	}
	; create anonymous pipe
	Pipe(name, codepage) {
		static mFlags_offset := 4 * A_PtrSize + 8, USEHANDLE := 0x10000000
		if !DllCall('CreatePipe', "ptr*", &hPipeR := 0, "ptr*", &hPipeW := 0, 'ptr', 0, 'uint', 0)
			throw OSError(A_LastError)
		local file
		if name = 'stdin' {
			this.stdin := file := FileOpen(hPipeW, 'h', codepage), ptr := hPipeR
			file.DefineProp('Flush', { call: (s) => s.Read(0) })
		} else {
			this.%name% := file := FileOpen(hPipeR, 'h`n', codepage), ptr := hPipeW
			DllCall('SetNamedPipeHandleState', 'ptr', hPipeR, 'uint*', 1, 'ptr', 0, 'ptr', 0)	; PIPE_NOWAIT
		}
		p := ObjPtr(file), file.ptr := file.Handle
		NumPut('uint', NumGet(p, mFlags_offset, 'uint') & ~USEHANDLE, p, mFlags_offset)	; remove USEHANDLE flag, auto close handle
		DllCall('SetHandleInformation', 'ptr', ptr, 'int', 1, 'int', 1)
		return ptr
	}
	Clear() => this.output.Length := this.error.Length := this.laststdoutindex := 0
	GetLastStdout() => this.output.toString((t := this.laststdoutindex, this.laststdoutindex := this.output.Length, t))
	; wait process exit
	Wait(timeout := -1) => DllCall('WaitForSingleObject', 'ptr', this.hProcess, 'uint', timeout)
	; terminate process
	Terminate() {
		if this.hProcess
			DllCall('TerminateProcess', 'ptr', this.hProcess)
	}
	ExitCode => (DllCall('GetExitCodeProcess', 'ptr', this.hProcess, 'uint*', &code := 0), code)
	; get stdout/stderr output
	Call() {
		static outs := ['stdout', 'stderr']
		for k in (peek := 0, outs) {
			if !(f := this.%k%)
				continue
			out := k = 'stdout' ? this.output : this.error
			if DllCall('PeekNamedPipe', 'ptr', f, 'ptr', 0, 'int', 0, 'ptr', 0, 'ptr', 0, 'ptr', 0) && (t := '', ++peek) {
				while f {
					if t := t f.Read() {
						arr := StrSplit(t, '`n', '`r'), t := f.AtEOF ? '' : arr.Pop()
						for line in arr
							try if (out.Push(line), 1) && this.onData(k, line) && (--peek, !f := this.%k% := 0) {
								try this.onClose(k)
								break 2
							} catch MethodError
								continue
					} else if f.AtEOF
						break
					else Sleep(5)
				}
			} else try this.%k% := f := 0, this.onClose(k)
		}
		; terminates the timer when the object is not referenced
		return peek && (this.onData || this.onClose || NumGet(ObjPtr(this), A_PtrSize, 'uint') > 2) ? peek : (SetTimer(this, 0), 0)
	}
}
