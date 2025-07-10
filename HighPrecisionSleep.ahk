/************************************************************************
 * @description Support millisecond high-precision sleep.
 * @author thqby
 * @date 2023/11/01
 * @version 0.0.1
 ***********************************************************************/
HighPrecisionSleep(milliseconds) {
	static pfn := init()
	DllCall(pfn, 'uint', milliseconds)
	static init() {
		/*msvc v19 /FAc /O2
		uint32_t sleep_until_ms;
		uint32_t microseconds_for_correction;
		uint64_t util_mul_div(size_t num, size_t mul, size_t div)
		{
		#if _WIN64
			uint64_t high, low = _umul128(num, mul, &high);
			return _udiv128(high, low, div, &high);
		#else
			// Assume that the value of QueryPerformanceFrequency is 10000000, and div <= 1000000
			// can use uint type, avoiding the introduction of __allmul,
			// significantly reduces the generated code
			return (mul / div) * num;
		#endif
		}
		__declspec(noinline) void __stdcall sleep(uint32_t milliseconds)
		{
			LARGE_INTEGER cur, end;
			QueryPerformanceCounter(&end);
			QueryPerformanceFrequency(&cur);
			end.QuadPart += util_mul_div(milliseconds, cur.QuadPart, 1000) -
				util_mul_div(microseconds_for_correction, cur.QuadPart, 1000000);
			if (milliseconds > sleep_until_ms)
				Sleep(milliseconds - sleep_until_ms);
			for (;;) {
				QueryPerformanceCounter(&cur);
				if (cur.QuadPart >= end.QuadPart)
					break;
				YieldProcessor();
			}
		}*/
		if A_PtrSize = 8
			offset := 0xa0, code := 'QFNIg+wgi9lIjUwkQP8VjQAAAEiNTCQ4/xWKAAAASItEJDi56AMAAEj340j38YsNiAAAAEyLyEiLRCQ4SPfhuUBCDwBI9/FMK8iLBWgAAABMAUwkQDvYdgor2IvL/xVNAAAASI1MJDj/FTIAAABIi0QkQEg5RCQ4fR9mDx9EAADzkEiNTCQ4/xUTAAAASItEJEBIOUQkOHznSIPEIFvDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		else
			offset := 0xa9, code := 'g+wQVleLPQAAAACNRCQIUP/XjUQkEFD/FQAAAACLTCQcuIPeG0P3ZCQQuNNNYhCL8vdkJBDB7hIzwA+vNQAAAADB6gYPr9Er1hvAAVQkCBFEJAyhAAAAADvIdgkryFH/FQAAAACNRCQQUP/Xi0QkFDtEJAx/K3wKi0QkEDtEJAhzH/OQjUQkEFD/14tEJBQ7RCQMfO1/CotEJBA7RCQIcuFfXoPEEMIEAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
		DllCall('crypt32\CryptStringToBinary', 'str', code, 'uint', 0, 'uint', 1, 'ptr', 0, 'uint*', &s := 0, 'ptr', 0, 'ptr', 0)
		static buf := Buffer(s)
		DllCall('crypt32\CryptStringToBinary', 'str', code, 'uint', 0, 'uint', 1, 'ptr', buf, 'uint*', &s, 'ptr', 0, 'ptr', 0)
		DllCall('VirtualProtect', 'ptr', buf, 'uint', s, 'uint', 0x40, 'uint*', 0)
		mod := DllCall('GetModuleHandle', 'str', 'kernel32', 'ptr')
		get_proc(n) => DllCall('GetProcAddress', 'ptr', mod, 'astr', n, 'ptr')
		NumPut('ptr', get_proc('QueryPerformanceCounter'),
			'ptr', get_proc('QueryPerformanceFrequency'),
			; 'ptr', get_proc('Sleep'),
			'ptr', psleep := CallbackCreate(Sleep),
			'uint', 20, 'uint', 10,
			p := buf.Ptr + offset)	; set import table and global vars
		OnExit((*) => CallbackFree(psleep))
		if A_PtrSize = 4
			for o in [0x07, 0x19, 0x61, 0x54, 0x3d]
				NumPut('ptr', p + 4 * (A_Index - 1), buf, o)
		p += 3 * A_PtrSize
		SetHighPrecisionSleepParams.DefineProp('Call', {
			call: (_, ms := 20, us := 10) => NumPut('uint', ms, 'uint', us, p)
		})
		return buf.Ptr
	}
}
/**
 * Setting parameters for high-precision sleep.
 * @param {Integer} sleep_until_milliseconds The remaining milliseconds to start high-precision sleep.
 * When {@link HighPrecisionSleep~milliseconds} is greater than this parameter,
 * use ahk's built-in sleep function first and then start high-precision sleep.
 * @param {Integer} microseconds_for_correction The microseconds used for fine-tuning.
 */
SetHighPrecisionSleepParams(sleep_until_milliseconds := 20, microseconds_for_correction := 10) {
	HighPrecisionSleep(0), SetHighPrecisionSleepParams(sleep_until_milliseconds, microseconds_for_correction)
}