if A_PtrSize = 4 {
	MsgBox 'You must run 64-bit AHK, because 32 bit machine code is not provided'
	ExitApp
}

; sum(a, b) => a + b

; void add(ResultToken& aResultToken, ExprTokenType* aParam[], int aParamCount) {
; 	aResultToken.symbol = SYM_INTEGER;
; 	aResultToken.value_int64 = aParam[0]->value_int64 + aParam[1]->value_int64;
; }
code1 := MCode("1,x64:C7411001000000488B4208488B124C8B004C03024C8901C3")

; int add(int a, int b) { return a + b; }
code2 := MCode("1,x64:8D0411C3")

; class Calculate : public IObject {
; 	void add(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount);
; };
; void Calculate::add(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount) {
; 	aResultToken.symbol = SYM_INTEGER;
; 	aResultToken.value_int64 = aParam[0]->value_int64 + aParam[1]->value_int64;
; }
code3 := MCode("1,x64:488B442428C7421001000000488B48084C8B00488B01490300488902C3")
sum_dllcall := DllCall.Bind(code2.Ptr, 'int', , 'int', , 'int')
sum_native := BuiltInFunc(code1.Ptr, 2)
obj := {}
ObjDefineBuiltInProp(obj, 'add', {
	call: {
		BIM: code3.Ptr,
		MinParams: 2
	}
})

MsgBox 'call method, result: ' obj.Add(2434, 75698)

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
MsgBox test_sum(['sum_userfunc', 'sum_dllcall', 'sum_native'])

MCode(hex) {
	static reg := "^([12]?).*" (c := A_PtrSize = 8 ? "x64" : "x86") ":([A-Za-z\d+/=]+)"
	if (RegExMatch(hex, reg, &m))
		hex := m[2], flag := m[1] = "1" ? 4 : m[1] = "2" ? 1 : hex ~= "[+/=]" ? 1 : 4
	else
		flag := hex ~= "[+/=]" ? 1 : 4
	if (!DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", 0, "uint*", &s := 0, "ptr", 0, "ptr", 0))
		return
	code := Buffer(s)
	if (DllCall("crypt32\CryptStringToBinary", "str", hex, "uint", 0, "uint", flag, "ptr", code, "uint*", &s, "ptr", 0, "ptr", 0) && DllCall("VirtualProtect", "ptr", code, "uint", s, "uint", 0x40, "uint*", 0))
		return code
}

QPC() {
	static c := 0, f := (DllCall("QueryPerformanceFrequency", "int64*", &c), c /= 1000)
	return (DllCall("QueryPerformanceCounter", "int64*", &c), c / f)
}


; create class

;; c++ dll
; class MyClass : public Object {
; 	char buf[200];
; public:
; 	IObject_Type_Impl("MyClass");
; 	MyClass(Object* ahkObj) {
; 		const VTableIndex vtindexs[] = { VTableIndex::Type, VTableIndex::dtor };
; 		Create(ahkObj, vtindexs);
; 	}
; };

; EXPORT BIF_DECL(NewMyClass) {
; 	NewObject<MyClass>(aResultToken, aParam, aParamCount);
; }

;; ahk
; module := DllCall('LoadLibrary', 'str', dllpath, 'ptr')
; classctor := NumGet(DllCall('GetProcAddress', 'ptr', module, 'astr', funcname, 'ptr'), 'ptr')

; myclass := BuiltInClass(classctor)
; ObjDefineBuiltInProp(myclass.Prototype, propname, propdesc)
; obj := myclass()
; MsgBox Type(obj)