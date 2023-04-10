/************************************************************************
 * @description Number Theory Lib, used for high precision integer and floating point number calculation
 * @file NTLCalc.ahk
 * @author thqby
 * @date 2021/12/12
 * @version 1.0.3
 ***********************************************************************/

class NTLCalc {
	static _ := DllCall("LoadLibrary", "str", A_LineFile "\..\" (A_PtrSize * 8) "bit\ntl.dll", "ptr")

	/**
	 * Computational mathematical expression.
	 * @param exp A mathematical expression to be evaluated, such as `4*23.2/4.1`
	 * #### `constants`
	 * - pi, e
	 *
	 * #### functions
	 * - sin, cos, tan, pow, pow2, pow3, sqrt, abs, ceil, floor, exp, ln, log
	 * - max(x1, x2, ...)
	 * - min(x1, x2, ...)
	 * - round(x, n = 0)
	 */
	static Call(exp) {
		switch (DllCall("ntl\Calc", "astr", exp, "ptr*", &val := 0, 'cdecl')) {
			case 0: return StrGet(val, "cp0")
			case 1: throw Error("ExpressionError")
			case 2: throw ValueError("ParamCountError")
			case 3: throw TypeError("TypeError")
			case 4: throw Error("UnknowTokenError")
			case 5: throw ZeroDivisionError("ZeroDivisionError")
		}
	}

	; Set Debug Mode, Print the results of each step in the stdout.
	static SetDebugMode(p := false) {
		DllCall("ntl\SetDebugMode", "char", p, "cdecl")
	}

	; Set output precision(number of bits).
	static SetOutputPrecision(p) {
		DllCall("ntl\SetOutputPrecision", "int", p, "cdecl")
	}

	; Set the precision(number of bits).
	static SetPrecision(p) {
		DllCall("ntl\SetPrecision", "int", p, "cdecl")
	}
}