/************************************************************************
 * @description An OVERLAPPED struct implemented with io completion ports
 * for asynchronously overlapping IO. It can be used to asynchronously read
 * and write files, pipes, http, and sockets.
 * @author thqby
 * @date 2024/12/11
 * @version 1.0.3
 ***********************************************************************/

class OVERLAPPED extends Buffer {
	/**
	 * The struct used in asynchronous (or overlapped) input and output (I/O).
	 * The specified callback function is called when the asynchronous operation completes or fails.
	 */
	__New(cb := (this, err, byte) => 0) {
		static size := 4 * A_PtrSize + 8
		super.__New(size, 0)
		NumPut('ptr', DllCall('CreateEvent', 'ptr', 0, 'int', 1, 'int', 0, 'ptr', 0, 'ptr'),
			'ptr', ObjPtr(this), this, size - 2 * A_PtrSize)
		this.Call := cb
	}
	static EnableIoCompletionCallback(hFile) {
		static code := init()
		if !DllCall('BindIoCompletionCallback', 'ptr', hFile, 'ptr', code, 'uint', 0)
			Throw OSError()
		init() {
			static g := Gui(), offset := 3 * A_PtrSize + 8
			DllCall('SetParent', 'ptr', hwnd := g.Hwnd, 'ptr', -3)
			msg := DllCall('RegisterWindowMessage', 'str', 'AHK_Overlapped_IO_Completion', 'uint')
			pSend := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'user32', 'ptr'), 'astr', 'SendMessageW', 'ptr')
			OnMessage(msg, (overlapped, err, *) => ObjFromPtrAddRef(NumGet(overlapped, offset, 'ptr'))(err, NumGet(overlapped, A_PtrSize, 'uptr')) || 1, 255)
			; 0xnnnnnnnn is used as a placeholder for the compiler to generate corresponding instructions
			/*
			#include <windows.h>
			void CALLBACK OverlappedIOCompletion(DWORD err, DWORD bytes, LPOVERLAPPED overlapped) {
				((decltype(&SendMessageW))0x1111111111111111)((HWND)0x2222222222222222, (UINT)0x33333333, (WPARAM)overlapped, (LPARAM)err);
			}*/
			if A_PtrSize = 8 {
				NumPut(
					; 44 8b c9   mov r9d, ecx ; err
					; ba 00 00 00 00 mov edx, 0 ; msg
					'uint', 0xbac98b44, 'uint', msg,
					; 48 b9 00 00 00 00
					;  00 00 00 00 mov rcx, 0 ; hwnd
					'ushort', 0xb948, 'ptr', hwnd,
					; 48 b8 00 00 00 00
					;  00 00 00 00 mov rax, 0 ; SendMessageW
					'ushort', 0xb848, 'ptr', pSend,
					; 48 ff e0   rex_jmp rax
					'uint', 0xe0ff48, code := Buffer(32))
			} else {
				NumPut(
					; ff 74 24 04  push DWORD PTR _err$[esp-4]
					'uint', 0x042474ff,
					; ff 74 24 10  push DWORD PTR _overlapped$[esp]
					'uint', 0x102474ff,
					; 68 00 00 00 00 push 0     ; msg
					'uchar', 0x68, 'uint', msg,
					; 68 00 00 00 00 push 0     ; hwnd
					'uchar', 0x68, 'ptr', hwnd,
					; b8 00 00 00 00 mov eax, 0    ; SendMessageW
					'uchar', 0xb8, 'ptr', pSend,
					; ff d0   call eax
					; c2 0c 00  ret 12
					'int64', 0x0cc2d0ff, code := Buffer(32))
			}
			DllCall('VirtualProtect', 'ptr', code, 'ptr', 32, 'uint', 0x40, 'uint*', 0)
			return code
		}
	}
	Cancel(hFile) => DllCall('CancelIoEx', 'ptr', hFile, 'ptr', this)
	Clear() => DllCall('RtlZeroMemory', 'ptr', this, 'uptr', 2 * A_PtrSize + 8)
	Internal => NumGet(this, 'uptr')
	InternalHigh => NumGet(this, A_PtrSize, 'uptr')
	hEvent => NumGet(this, 2 * A_PtrSize + 8, 'ptr')
	Reset() => DllCall('ResetEvent', 'ptr', this.hEvent)
	Set() => DllCall('SetEvent', 'ptr', this.hEvent)
	__Delete() => DllCall('CloseHandle', 'ptr', this.hEvent)
	SafeDelete(hFile) {
		static delay_delete := Map()
		delay_delete[this] := true
		this.Call := (this, *) => delay_delete.Delete(this)
		this.Cancel(hFile) || this()
	}
}