/************************************************************************
 * @description An OVERLAPPED struct implemented with io completion ports
 * for asynchronously overlapping IO. It can be used to asynchronously read
 * and write files, pipes, http, and sockets.
 * @author thqby
 * @date 2025/05/10
 * @version 1.0.4
 ***********************************************************************/

class OVERLAPPED extends Buffer {
	/**
	 * The struct used in asynchronous (or overlapped) input and output (I/O).
	 * The specified callback function is called when the asynchronous operation completes or fails.
	 */
	__New(cb := (this, err, byte) => 0) {
		static size := 5 * A_PtrSize + 8
		super.__New(size, 0)
		NumPut('ptr', DllCall('CreateEvent', 'ptr', 0, 'int', 1, 'int', 0, 'ptr', 0, 'ptr'),
			'ptr', ObjPtr(this), 'char', 0, this, 2 * A_PtrSize + 8)
		this.Call := cb
	}
	static EnableIoCompletionCallback(hFile) {
		static g := Gui(), offset := 4 * A_PtrSize + 8, code := init()
		if !DllCall('BindIoCompletionCallback', 'ptr', hFile, 'ptr', code, 'uint', 0)
			Throw OSError()
		overlapped_completion(obj, err, *) {
			NumPut('char', 0, obj := ObjFromPtrAddRef(obj), offset)
			obj(err, NumGet(obj, A_PtrSize, 'uptr'))
			return 1
		}
		init() {
			DllCall('SetParent', 'ptr', hwnd := g.Hwnd, 'ptr', -3)
			msg := DllCall('RegisterWindowMessage', 'str', 'AHK_Overlapped_IO_Completion', 'uint')
			pSend := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'user32', 'ptr'), 'astr', 'SendMessageW', 'ptr')
			if HasMethod(g, 'OnMessage')
				g.OnMessage(msg, (g, obj, err, *) => overlapped_completion(obj, err))
			else OnMessage(msg, overlapped_completion, 255)
			; 0xnnnnnnnn is used as a placeholder for the compiler to generate corresponding instructions
			/*
			#include <windows.h>
			struct MYOVERLAPPED : OVERLAPPED { void *obj; bool pending; };
			void CALLBACK OverlappedIOCompletion(DWORD err, DWORD bytes, MYOVERLAPPED *overlapped) {
				overlapped->pending = true;
				((decltype(&SendMessageW))0x1111111111111111)((HWND)0x2222222222222222, (UINT)0x33333333, (WPARAM)overlapped->obj, (LPARAM)err);
			}*/
			if A_PtrSize = 8 {
				NumPut(
					; 41 c6 40 28 01            mov BYTE PTR [r8+40], 1   ; overlapped->pending
					; 44 8b c9                  mov r9d, ecx              ; err
					'int64', 0xc98b44012840c641,
					; ba 00000000               mov edx, 0                ; msg
					; 48 b8 00000000 00000000   mov rax, 0                ; SendMessageW
					; 48 b9 00000000 00000000   mov rcx, 0                ; hwnd
					'uchar', 0xba, 'uint', msg, 'ushort', 0xb848, 'ptr', pSend, 'ushort', 0xb948, 'ptr', hwnd,
					; 4d 8b 40 20               mov r8, QWORD PTR [r8+32] ; overlapped->obj
					; 48 ff e0                  rex_jmp rax
					'int64', 0xe0ff4820408b4d, code := Buffer(48))
			} else {
				NumPut(
					; 8b 44 24 0c               mov eax, DWORD PTR _overlapped$[esp-4]
					; ff 74 24 04               push DWORD PTR _err$[esp-4]
					'int64', 0x042474ff0c24448b,
					; ff 70 14                  push DWORD PTR [eax+20]   ; overlapped->obj
					; c6 40 18 01               mov BYTE PTR [eax+24], 1  ; overlapped->pending
					; b8 00 00 00 00            mov eax, 0                ; SendMessageW
					'int64', 0xb8011840c61470ff, 'ptr', pSend,
					; 68 00 00 00 00            push 0                    ; msg
					; 68 00 00 00 00            push 0                    ; hwnd
					'char', 0x68, 'uint', msg, 'char', 0x68, 'ptr', hwnd,
					; ff d0                     call eax
					; c2 0c 00                  ret 12
					'int64', 0x0cc2d0ff, code := Buffer(40))
			}
			DllCall('VirtualProtect', 'ptr', code, 'ptr', 40, 'uint', 0x40, 'uint*', 0)
			return code
		}
	}
	Cancel(hFile) => DllCall('CancelIoEx', 'ptr', hFile, 'ptr', this)
	Clear() => DllCall('RtlZeroMemory', 'ptr', this, 'uptr', 2 * A_PtrSize + 8)
	Internal => NumGet(this, 'uptr')
	InternalHigh => NumGet(this, A_PtrSize, 'uptr')
	hEvent => NumGet(this, 2 * A_PtrSize + 8, 'ptr')
	Pending => NumGet(this, 4 * A_PtrSize + 8, 'char')
	Reset() => DllCall('ResetEvent', 'ptr', this.hEvent)
	Set() => DllCall('SetEvent', 'ptr', this.hEvent)
	__Delete() => DllCall('CloseHandle', 'ptr', this.hEvent)
	SafeDelete(hFile) {
		static delay_delete := Map()
		delay_delete[this] := true
		this.Call := (this, *) => delay_delete.Delete(this)
		this.Cancel(hFile) || this.Pending || this()
	}
}