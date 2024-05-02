/*
#include <Windows.h>

typedef struct {
	char* Key;
	int Value;
} MyMap;
__declspec(dllexport)
MyMap Map[] = {
	{"Hello", 20},
	{"Goodbye", 90},
	{"dog", 200},
	{"cat", 900}
};

__declspec(dllexport)
MyMap* call_msgbox_and_return_item(int index) {
	MessageBoxA(0, Map[index].Key, "Call MCode Function", 0);
	return &Map[index];
}

__declspec(dllexport)
char *new_char_array_and_set_val() {
	auto p = new char[4];
	p[0] = 'a';
	p[1] = 'h';
	p[2] = 'k';
	p[3] = 0;
	return p;
}
*/
; Compile c++ code generation *.obj
; Compiler command line:  cl.exe /c /std:c++20 /permissive /O2 /Gz /GS- cpp.cpp
; Extract the mcode from obj and link it
;
; #Include <MCode\COFFReader>
; configs := ExtractMCode(COFFReader('cpp.obj'), ['user32', 'msvcrt'])
configs := {
	32: {
		code: "b7,o7AAagToQQAAAIMAxATHAGFoawAEw8wLAItEJARWEGoAaHAAkP80xQqEABiNAxhqAP8VAlAAHIvGXsIEABj/JVQAFgcASGVsBGxvAA5Hb29kYgB5ZQBkb2cAYwBhdABDYWxsIABNQ29kZSBGdQBuY3Rpb24AWFUAJxQAA2AAA1oAA2gVAAPIAANsAAOEAwAAnICUgIyAhIAASj42LyhQAgAAIISAAw==",
		import: "user32:MessageBoxA|msvcrt:??_U@YAPAXI@Z"
	},
	64: {
		code: "ea,tbAASIPsKLkEAAAIAOhKAEDHAGFoAGsASIPEKMPMCQMAQFMAhCBIY9kQTI0FWACESMHjIARIjQ1lASgD2QBFM8kzyUiLE0j/FRQBIIvDAHQgYlsBdv8lCgAiDwBIEGVsbG8ADkdvbwBkYnllAGRvZwAAY2F0AENhbABsIE1Db2RlIABGdW5jdGlvbl0CL3AENwFfAQB4BAdaVQQHgAQHyAQHhAUHAwAA0IDAgLCAoACAYAIAIKCAAw==",
		import: "user32:MessageBoxA|msvcrt:??_U@YAPEAX_K@Z"
	},
	export: "Map,call_msgbox_and_return_item,new_char_array_and_set_val"
}

#Include <MCode\MCodeLoader>
; load mcode
m := MCodeLoader(configs)
; call function
str := StrGet(p := DllCall(m['new_char_array_and_set_val'], 'ptr'), 'cp0')
; delete[] p
if A_PtrSize = 8
	DllCall('msvcrt\??_V@YAXPEAX@Z', 'ptr', p)
else DllCall('msvcrt\??_V@YAXPAX@Z', 'ptr', p, 'cdecl')
it := DllCall(m['call_msgbox_and_return_item'], 'int', 1, 'ptr')
MsgBox(Format('
(
  key: {}
  value: {}
  new char[4]: {}
)', StrGet(NumGet(it, 'ptr'), 'cp0'), NumGet(it, A_PtrSize, 'int'), str))
; read variable, Map[3]
pMap := m['Map']
it := pMap + 3 * (A_PtrSize * 2)
MsgBox('key: ' StrGet(NumGet(it, 'ptr'), 'cp0') '`nvalue: ' NumGet(it, A_PtrSize, 'int'))