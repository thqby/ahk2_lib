// cl.exe /c /std:c++20 /permissive /O2 /Gz /GS- /MD
// dlls: user32,ucrtbase,msvcrt
#include <Windows.h>
#include <string>


#include <typeinfo>
// When a virtual function is included in the source code,
// the compiler links the virtual function table of type_info,
// but the virtual destructor of the class is not implemented in the header file,
// so the compiler does not generate the symbol at compile-only time.
// Implement it so that it exists at compile time.
type_info::~type_info() {}

// typeid(var).name() uses this structure, but in the header file, it is a fake definition.
// so compiler does not generate the symbol at compile-only time.
struct __type_info_node {
	void* _[4];
} __type_info_root_node{ 0 };

class Base {
public:
	virtual void hello(std::string) = 0;
};

class AA : public Base
{
public:
	void hello(std::string text) {
		MessageBoxA(0, text.data(), typeid(this).name(), 0);
	}
};

class BB : public Base
{
public:
	void hello(std::string text) {
		MessageBoxA(0, text.data(), typeid(this).name(), 0);
	}
};

__declspec(dllexport)
void hello() {
	Base *a, *b;
	a = new AA;
	b = new BB;
	a->hello("call AA::hello()");
	b->hello("call BB::hello()");
	delete a;
	delete b;
}