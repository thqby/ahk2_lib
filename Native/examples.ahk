#Include Native.ahk

if A_PtrSize = 4 {
	MsgBox 'You must run 64-bit AHK, because 32 bit machine code is not provided'
	ExitApp
}

; sum(a, b) => a + b

; void add(ResultToken& aResultToken, ExprTokenType* aParam[], int aParamCount) {
; 	aResultToken.symbol = SYM_INTEGER;
; 	aResultToken.value_int64 = aParam[0]->value_int64 + aParam[1]->value_int64;
; }
sum_native := Native.Func("1,x64:C7411001000000488B4208488B124C8B004C03024C8901C3", 2)

; int add(int a, int b) { return a + b; }
code2 := Native.MCode("1,x64:8D0411C3")
sum_dllcall := DllCall.Bind(code2, 'int', , 'int', , 'int')

; class Calculate : public IObject {
; 	void sum(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount);
; };
; void Calculate::sum(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount) {
; 	aResultToken.symbol = SYM_INTEGER;
; 	aResultToken.value_int64 = aParam[0]->value_int64 + aParam[1]->value_int64;
; }
obj := {}
Native.DefineProp(obj, 'sum', {
	call: {
		BIM: "1,x64:488B442428C7421001000000488B48084C8B00488B01490300488902C3",
		MinParams: 2
	}
})

MsgBox 'call method, result: ' obj.sum(2434, 75698)

sum_userfunc(a, b) => a + b

test_sum(funcnames, times := 10000000) {
	result := ''
	for f in funcnames {
		fn := %f%
		t := QPC()
		loop times
			fn(156498, 189298)
		result .= f ': ' (QPC() - t) 'ms`n'
	}
	return result
}

MsgBox 'The performance test, call func ' (times := 10000000) ' times'
MsgBox test_sum(['sum_userfunc', 'sum_dllcall', 'sum_native'], times)


QPC() {
	static c := 0, f := (DllCall("QueryPerformanceFrequency", "int64*", &c), c /= 1000)
	return (DllCall("QueryPerformanceCounter", "int64*", &c), c / f)
}

; dll module, download from https://www.autohotkey.com/boards/viewtopic.php?f=83&t=100197&p=445069#p445069
MsgBox "test load dll, this dll depends on VCRUNTIME140.dll"
ahkmodule := Native.LoadModule(A_ScriptDir '\ahk2.dll', ['Map', 'MyFunc', 'MyClass'])
m := Map('msg', MsgBox, 'rep', StrReplace)
; call Map.Prototype.__Call native code
m.msg('hello' m.rep(' this a str', 'str', 'string'))
; a c++ class from dll
a := ahkmodule.myclass()
try
	a.err()
catch as e
	MsgBox e.Message
MsgBox a.Value() ' ' a.int()
ahkmodule.myfunc()
ahkmodule.myfunc('qqqq')
ahkmodule['myclass'](1)
; myclass only accepts 0-1 param
ahkmodule['myclass'](1, 2)