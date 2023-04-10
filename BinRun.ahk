BinRun(bin, ExeToUse, cmdLineOrScript := "", scriptParams := "", Hide := 0) {
	static IMAGE_DOS_HEADER := "WORD e_magic;WORD e_cblp;WORD e_cp;WORD e_crlc;WORD e_cparhdr;WORD e_minalloc;WORD e_maxalloc;WORD e_ss;WORD e_sp;WORD e_csum;WORD e_ip;WORD e_cs;WORD e_lfarlc;WORD e_ovno;WORD e_res[4];WORD e_oemid;WORD e_oeminfo;WORD e_res2[10];LONG e_lfanew"
	static IMAGE_FILE_HEADER := "WORD Machine;WORD NumberOfSections;DWORD TimeDateStamp;DWORD PointerToSymbolTable;DWORD NumberOfSymbols;WORD SizeOfOptionalHeader;WORD Characteristics"
	static IMAGE_DATA_DIRECTORY := "DWORD VirtualAddress;DWORD Size"
	static IMAGE_OPTIONAL_HEADER64 := "WORD Magic;BYTE MajorLinkerVersion;BYTE MinorLinkerVersion;DWORD SizeOfCode;DWORD SizeOfInitializedData;DWORD SizeOfUninitializedData;DWORD AddressOfEntryPoint;DWORD BaseOfCode;ULONGLONG ImageBase;DWORD SectionAlignment;DWORD FileAlignment;WORD MajorOperatingSystemVersion;WORD MinorOperatingSystemVersion;WORD MajorImageVersion;WORD MinorImageVersion;WORD MajorSubsystemVersion;WORD MinorSubsystemVersion;DWORD Win32VersionValue;DWORD SizeOfImage;DWORD SizeOfHeaders;DWORD CheckSum;WORD Subsystem;WORD DllCharacteristics;ULONGLONG SizeOfStackReserve;ULONGLONG SizeOfStackCommit;ULONGLONG SizeOfHeapReserve;ULONGLONG SizeOfHeapCommit;DWORD LoaderFlags;DWORD NumberOfRvaAndSizes;BinRun(IMAGE_DATA_DIRECTORY) DataDirectory[16]"
	static IMAGE_OPTIONAL_HEADER32 := "WORD Magic;BYTE MajorLinkerVersion;BYTE MinorLinkerVersion;DWORD SizeOfCode;DWORD SizeOfInitializedData;DWORD SizeOfUninitializedData;DWORD AddressOfEntryPoint;DWORD BaseOfCode;DWORD BaseOfData;DWORD ImageBase;DWORD SectionAlignment;DWORD FileAlignment;WORD MajorOperatingSystemVersion;WORD MinorOperatingSystemVersion;WORD MajorImageVersion;WORD MinorImageVersion;WORD MajorSubsystemVersion;WORD MinorSubsystemVersion;DWORD Win32VersionValue;DWORD SizeOfImage;DWORD SizeOfHeaders;DWORD CheckSum;WORD Subsystem;WORD DllCharacteristics;DWORD SizeOfStackReserve;DWORD SizeOfStackCommit;DWORD SizeOfHeapReserve;DWORD SizeOfHeapCommit;DWORD LoaderFlags;DWORD NumberOfRvaAndSizes;BinRun(IMAGE_DATA_DIRECTORY) DataDirectory[16]"
	static IMAGE_NT_HEADERS := "DWORD Signature;BinRun(IMAGE_FILE_HEADER) FileHeader;BinRun(IMAGE_OPTIONAL_HEADER" (A_PtrSize = 8 ? 64 : 32) ") OptionalHeader"
	static IMAGE_NT_HEADERS32 := "DWORD Signature;BinRun(IMAGE_FILE_HEADER) FileHeader;BinRun(IMAGE_OPTIONAL_HEADER32) OptionalHeader"
	static IMAGE_NT_HEADERS64 := "DWORD Signature;BinRun(IMAGE_FILE_HEADER) FileHeader;BinRun(IMAGE_OPTIONAL_HEADER64) OptionalHeader"
	static IMAGE_SECTION_HEADER := "BYTE Name[8];{DWORD PhysicalAddress;DWORD VirtualSize};DWORD VirtualAddress;DWORD SizeOfRawData;DWORD PointerToRawData;DWORD PointerToRelocations;DWORD PointerToLinenumbers;WORD NumberOfRelocations;WORD NumberOfLinenumbers;DWORD Characteristics"
	static FLOATING_SAVE_AREA := "DWORD ControlWord;DWORD StatusWord;DWORD TagWord;DWORD ErrorOffset;DWORD ErrorSelector;DWORD DataOffset;DWORD DataSelector;BYTE RegisterArea[80];DWORD Cr0NpxState"
	static PROCESS_INFORMATION := "HANDLE hProcess;HANDLE hThread;DWORD dwProcessId;DWORD dwThreadId"
	static STARTUPINFO := "DWORD cb;LPTSTR lpReserved;LPTSTR lpDesktop;LPTSTR lpTitle;DWORD dwX;DWORD dwY;DWORD dwXSize;DWORD dwYSize;DWORD dwXCountChars;DWORD dwYCountChars;DWORD dwFillAttribute;DWORD dwFlags;WORD wShowWindow;WORD cbReserved2;LPBYTE lpReserved2;HANDLE hStdInput;HANDLE hStdOutput;HANDLE hStdError"
	static M128A := "ULONGLONG Low;LONGLONG High"
	static _XMM_SAVE_AREA32 := "WORD ControlWord;WORD StatusWord;BYTE TagWord;BYTE Reserved1;WORD ErrorOpcode;DWORD ErrorOffset;WORD ErrorSelector;WORD Reserved2;DWORD DataOffset;WORD DataSelector;WORD Reserved3;DWORD MxCsr;DWORD MxCsr_Mask;BinRun(M128A) FloatRegisters[8];BinRun(M128A) XmmRegisters[16];BYTE Reserved4[96]"
	static CONTEXT64 := "DWORD64 P1Home;DWORD64 P2Home;DWORD64 P3Home;DWORD64 P4Home;DWORD64 P5Home;DWORD64 P6Home;DWORD ContextFlags;DWORD MxCsr;WORD SegCs;WORD SegDs;WORD SegEs;WORD SegFs;WORD SegGs;WORD SegSs;DWORD EFlags;DWORD64 Dr0;DWORD64 Dr1;DWORD64 Dr2;DWORD64 Dr3;DWORD64 Dr6;DWORD64 Dr7;DWORD64 Rax;DWORD64 Rcx;DWORD64 Rdx;DWORD64 Rbx;DWORD64Rsp;DWORD64 Rbp;DWORD64 Rsi;DWORD64 Rdi;DWORD64 R8;DWORD64 R9;DWORD64 R10;DWORD64 R11;DWORD64R12;DWORD64 R13;DWORD64 R14;DWORD64 R15;DWORD64 Rip;{BinRun(_XMM_SAVE_AREA32) FltSave;struct { BinRun(M128A) Header[2];BinRun(M128A) Legacy[8];BinRun(M128A) Xmm0;BinRun(M128A) Xmm1;BinRun(M128A) Xmm2;BinRun(M128A) Xmm3;BinRun(M128A) Xmm4;BinRun(M128A) Xmm5;BinRun(M128A) Xmm6;BinRun(M128A) Xmm7;BinRun(M128A) Xmm8;BinRun(M128A) Xmm9;BinRun(M128A) Xmm10;BinRun(M128A) Xmm11;BinRun(M128A) Xmm12;BinRun(M128A) Xmm13;BinRun(M128A) Xmm14;BinRun(M128A) Xmm15}};BinRun(M128A) VectorRegister[26];DWORD64 VectorControl;DWORD64 DebugControl;DWORD64 LastBranchToRip;DWORD64 LastBranchFromRip;DWORD64 LastExceptionToRip;DWORD64 LastExceptionFromRip"
	static CONTEXT32 := "DWORD ContextFlags;DWORD Dr0;DWORD Dr1;DWORD Dr2;DWORD Dr3;DWORD Dr6;DWORD Dr7;BinRun(FLOATING_SAVE_AREA) FloatSave;DWORD SegGs;DWORD SegFs;DWORD SegEs;DWORD SegDs;DWORD Edi;DWORD Esi;DWORD Ebx;DWORD Edx;DWORD Ecx;DWORD Eax;DWORD Ebp;DWORD Eip;DWORD SegCs;DWORD EFlags;DWORD Esp;DWORD SegSs;BYTE ExtendedRegisters[512]"
	static IMAGE_NT_SIGNATURE := 17744, IMAGE_DOS_SIGNATURE := 23117, PAGE_EXECUTE_READWRITE := 64, CREATE_SUSPENDED := 4
	static MEM_COMMIT := 4096, MEM_RESERVE := 8192, STARTF_USESHOWWINDOW := 1
	If (bin is String) {
		; Try first reading the file from Resource
		If res := DllCall("FindResource", "PTR", lib := DllCall("GetModuleHandle", "PTR", 0, "PTR"), "Str", bin, "PTR", 10, "PTR")
			data := Buffer(sz := DllCall("SizeofResource", "PTR", lib, "PTR", res))
			, DllCall("RtlMoveMemory", "PTR", data, "PTR", DllCall("LockResource", "PTR", hres := DllCall("LoadResource", "PTR", lib, "PTR", res, "PTR"), "PTR"), "PTR", sz)
			, DllCall("FreeResource", "PTR", hres), data := UnZipRawMemory(data, sz) || data
		else	; else try reading file from disc etc...
			data := FileRead(bin, 'raw')
		bin := data.Ptr
	}

	If InStr(cmdLineOrScript, "`n") {	; a script was given, first line contains the cmdLine
		PipeName := "\\.\pipe\AHK" A_TickCount
		__PIPE_GA_ := DllCall("CreateNamedPipe", "str", PipeName, "UInt", 2, "UInt", 0, "UInt", 255, "UInt", 0, "UInt", 0, "PTR", 0, "PTR", 0)
		__PIPE_ := DllCall("CreateNamedPipe", "str", PipeName, "UInt", 2, "UInt", 0, "UInt", 255, "UInt", 0, "UInt", 0, "PTR", 0, "PTR", 0)
		if !(__PIPE_ := Handle(__PIPE_)) || !(__PIPE_GA_ := Handle(__PIPE_GA_))
			throw OSError(A_LastError)
		Script := SubStr(cmdLineOrScript, InStr(cmdLineOrScript, "`n") + 1), cmdLineOrScript := Trim(SubStr(cmdLineOrScript, 1, InStr(cmdLineOrScript, "`n")), "`n`r") A_Space PipeName
	} else Script := ""

	IDH := Struct(IMAGE_DOS_HEADER, bin)

	if (IDH.e_magic != IMAGE_DOS_SIGNATURE)
		throw Error('e_magic not found')
	INH := Struct(IMAGE_NT_HEADERS, bin + IDH.e_lfanew)

	if (INH.Signature != IMAGE_NT_SIGNATURE)
		throw Error('Signature not found')

	If (A_PtrSize = 8 && INH.OptionalHeader.magic = 267)	; x86 on x64
		pNtHeader := Struct(IMAGE_NT_HEADERS32, bin + IDH.e_lfanew), ctx := Struct(Context32), Force32Bit := 1, ctx.ContextFlags := (A_PtrSize = 8 ? 0x100000 : 0x10000) | 0x2
	else if (A_PtrSize = 4 && INH.OptionalHeader.magic = 523)
		throw Error('x64 on x86 not possible')
	else
		Force32Bit := 0, pNtHeader := INH, ctx := Struct(A_PtrSize = 8 ? Context64 : Context32), ctx.ContextFlags := (A_PtrSize = 8 ? 0x100000 : 0x10000) | 0x2	;CONTEXT_INTEGER
	pi := Struct(PROCESS_INFORMATION), si := Struct(STARTUPINFO), si.cb := sizeof(si), si.dwFlags := HIDE ? STARTF_USESHOWWINDOW : 0	;si.wShowWindow already set to 0
	if DllCall("CreateProcess", "PTR", 0, "STR", "`"" ExeToUse "`"" A_Space cmdLineOrScript (scriptParams ? A_Space scriptParams : ""), "PTR", 0, "PTR", 0, "int", 0, "Int", CREATE_SUSPENDED, "PTR", 0, "PTR", 0, "PTR", si, "PTR", pi) {
		hProcess := Handle(pi.hProcess), hThread := Handle(pi.hThread)
		if DllCall((Force32Bit ? "Wow64" : "") "GetThreadContext", "PTR", pi.hThread, "PTR", ctx) {
			pPebImageBase := ctx[A_PtrSize = 8 && !Force32Bit ? "Rdx" : "Ebx"] + (Force32Bit ? 4 : A_PtrSize) * 2
			if DllCall("ReadProcessMemory", "PTR", pi.hProcess, "PTR", pPebImageBase, "PTR*", &dwImagebase := 0, "PTR", (Force32Bit ? 4 : A_PtrSize), "Uint*", &NumberOfBytes := 0) {
				DllCall("ntdll\NtUnmapViewOfSection", "PTR", pi.hProcess, "PTR", dwImagebase), pImagebase := DllCall("VirtualAllocEx", "PTR", pi.hProcess, "PTR", pNtHeader.OptionalHeader.ImageBase, "PTR", pNtHeader.OptionalHeader.SizeOfImage, "UInt", MEM_COMMIT | MEM_RESERVE, "UInt", PAGE_EXECUTE_READWRITE, "PTR")
				if (pImagebase) {
					if DllCall("WriteProcessMemory", "PTR", pi.hProcess, "PTR", pImagebase, "PTR", bin, "PTR", pNtHeader.OptionalHeader.SizeOfHeaders, "UInt*", &NumberOfBytes) {
						pSecHeader := Struct(IMAGE_SECTION_HEADER), pSecHeader[] := pNtHeader.OptionalHeader[""] + pNtHeader.FileHeader.SizeOfOptionalHeader, counter := 0
						while (++counter < pNtHeader.FileHeader.NumberOfSections + 1)
							DllCall("WriteProcessMemory", "PTR", pi.hProcess, "PTR", pImagebase + pSecHeader.VirtualAddress, "PTR", bin + pSecHeader.PointerToRawData, "PTR", pSecHeader.SizeOfRawData, "UInt*", &NumberOfBytes), pSecHeader[] := pSecHeader[] + sizeof(pSecHeader)
						if DllCall("WriteProcessMemory", "PTR", pi.hProcess, "PTR", pPebImageBase, "PTR", pNtHeader.OptionalHeader.ImageBase[""], "PTR", (Force32Bit ? 4 : A_PtrSize), "UInt*", &NumberOfBytes) {
							ctx[A_PtrSize = 8 && !Force32Bit ? "Rcx" : "Eax"] := pImagebase + pNtHeader.OptionalHeader.AddressOfEntryPoint
							if DllCall((Force32Bit ? "Wow64" : "") "SetThreadContext", "PTR", pi.hThread, "PTR", ctx[]) {
								if DllCall("ResumeThread", "PTR", pi.hThread) {
									if (Script) {	; use pipe to pass script to new executable
										DllCall("ConnectNamedPipe", "PTR", __PIPE_GA_, "PTR", 0), __PIPE_GA_ := 0
										DllCall("ConnectNamedPipe", "PTR", __PIPE_, "PTR", 0)
										if !DllCall("WriteFile", "PTR", __PIPE_, "str", Chr(0xfeff) script, "UInt", StrLen(script) * 2 + 4, "UInt*", 0, "PTR", 0)
											goto ret
										__PIPE_ := 0
									}
									return pi.dwProcessId
								}
							}
						}
					}
				}
			}
		}
	ret:
		err := A_LastError
		DllCall("TerminateProcess", "PTR", pi.hProcess, "UInt", 0)
		throw OSError(err)
	} else
		throw OSError(A_LastError)
	Handle(ptr) => (ptr == 0 || ptr == -1) ? 0 : { ptr: ptr, __Delete: (s) => DllCall("CloseHandle", "ptr", s) }
}

; BinRun(A_AhkPath, 'calc.exe','
; (

; 	MsgBox 'pid: ' ProcessExist() '``ncmd: ' DllCall('GetCommandLineW', 'str') '``nargs: ' JSON.stringify(A_Args)
; )','43 54 65')