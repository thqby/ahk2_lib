#include "ahk2_types.h"

class MyClass : public Object {
	TCHAR buf[200] = { 0 };
public:
#define CLASSNAME "MyClass"
	IObject_Type_Impl;
	static ObjectMember sMembers[];
	void __New(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount);
	void Invoke(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount);
};

void MyClass::__New(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount) {
	int i = 0;
	for (auto c : _T("this a string stored in the class"))
		buf[i++] = c;
	MessageBox(NULL, _T("create MyClass"), _T("native class from dll"), 0);
}
void MyClass::Invoke(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount) {
	if (aID == 0) {
		aResultToken.symbol = SYM_STRING;
		aResultToken.marker = buf;
		aResultToken.marker_length = -1;
	}
	else if (aID == 1) {
		aResultToken.value_int64 = 666, aResultToken.symbol = SYM_INTEGER;
	}
	else
	{
		Object a;
		a.Error(_T("an error from dll"));
		aResultToken.result = FAIL;
	}
}

ObjectMember MyClass::sMembers[] = {
	Object_Method(value, Invoke, 0, 0,0),
	Object_Method(int, Invoke, 1, 0,0),
	Object_Method(err, Invoke, 2, 0,0),
	Object_Method(__New, __New, 0, 0,1),
};

class MAP : Map {
public:
	static ObjectMember sMembers[];
	void __Call(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount);
};

void MAP::__Call(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount) {
	ExprTokenType t_this = {}, param[64] = {}, * params[64] = { param,param + 1,param + 2 };
	auto obj = (Array*)aParam[1]->object;
	TCHAR c[] = { 'G', 'e', 't', 0, 0 };
	aParamCount = obj->mLength;
	params[0] = aParam[0], param[1].symbol = SYM_INTEGER;
	t_this.symbol = SYM_OBJECT, t_this.object = this;
	Invoke(aResultToken, IT_CALL, c, t_this, params, 2);
	if (aResultToken.symbol == SYM_OBJECT) {
		t_this.object = aResultToken.object, aResultToken.object->Release();
		aResultToken.marker = c + 3, aResultToken.marker_length = 0, aResultToken.symbol = SYM_STRING;
		if (aParamCount < 64) {
			for (int i = 0; i < aParamCount; ++i) {
				auto& it = obj->mItem[i];
				params[i] = &param[i];
				switch (param[i].symbol = it.symbol)
				{
				case SYM_STRING:
				case SYM_MISSING:
					param[i].marker = (LPTSTR)(it.string.data + 1);
					param[i].marker_length = it.string.data->length;
					break;
				case SYM_DYNAMIC:
					param[i].value_int64 = 0, param[i].symbol = SYM_MISSING;
					break;
				default:
					param[i].value_int64 = it.n_int64; // Union copy.
				}
			}
			t_this.object->Invoke(aResultToken, IT_CALL, nullptr, t_this, params, aParamCount);
		}
	}
}
ObjectMember MAP::sMembers[] = {
	{_T("Map.Prototype.__Call"),(ObjectMethod)&__Call, 0, 2, 2}
};
BIF_DECL(MyFunc) {
	MessageBox(NULL, aParamCount && aParam[0]->symbol == SYM_STRING ? aParam[0]->marker : _T("hello"), _T("a func from dll"), 0);
}
ExportSymbol symbols[] = {
	EXPORT_CLASS(MyClass,2)
	EXPORT_FUNC(MyFunc, 0, 1)
	ExportSymbol(_T("Map"), nullptr, 1, MAP::sMembers)
};

EXPORT_AHKMODULE(symbols)

