#pragma once

#include <OAIdl.h>
#include <tchar.h>

// Flags used when calling Invoke; also used by g_ObjGet etc.:
#define IT_GET				0
#define IT_SET				1
#define IT_CALL				2
#define IT_BITMASK			3 // bit-mask for the above.

#define IF_BYPASS_METAFUNC	0x10000 // Skip invocation of meta-functions, such as when calling __Init or __Delete.
#define IF_NO_SET_PROPVAL	0x20000 // Fail IT_SET for value properties (allow only setters/__set).
#define IF_DEFAULT			0x40000 // Invoke the default member (call a function object, array indexing, etc.).
#define IF_NEWENUM			0x80000 // Workaround for COM objects which don't resolve "_NewEnum" to DISPID_NEWENUM.
#define IF_BITMASK			0xF0000

#define EIF_VARIADIC		0x01000
#define EIF_STACK_MEMBER	0x02000
#define EIF_LEAVE_PARAMS	0x04000
#define EIF_BITMASK			0x07000

#define INVOKE_TYPE			(aFlags & IT_BITMASK)
#define IS_INVOKE_SET		(aFlags & IT_SET)
#define IS_INVOKE_GET		(INVOKE_TYPE == IT_GET)
#define IS_INVOKE_CALL		(aFlags & IT_CALL)
#define IS_INVOKE_META		(aFlags & IF_BYPASS_METAFUNC)

#define INVOKE_NOT_HANDLED	CONDITION_FALSE

#define MAX_NUMBER_LENGTH 255                   // Large enough to allow custom zero or space-padding via %10.2f, etc.
#define MAX_NUMBER_SIZE (MAX_NUMBER_LENGTH + 1) // But not too large because some things might rely on this being fairly small.
#define MAX_INTEGER_LENGTH 20                     // Max length of a 64-bit number when expressed as decimal or
#define MAX_INTEGER_SIZE (MAX_INTEGER_LENGTH + 1) // hex string; e.g. -9223372036854775808 or (unsigned) 18446744073709551616 or (hex) -0xFFFFFFFFFFFFFFFF.

#define _f_callee_id			(aResultToken.func->mFID)

// FAIL = 0 to remind that FAIL should have the value zero instead of something arbitrary
// because some callers may simply evaluate the return result as true or false
// (and false is a failure):
enum ResultType {
	FAIL = 0, OK, WARN = OK, CRITICAL_ERROR  // Some things might rely on OK==1 (i.e. boolean "true")
	, CONDITION_TRUE, CONDITION_FALSE
	, LOOP_BREAK, LOOP_CONTINUE
	, EARLY_RETURN, EARLY_EXIT // EARLY_EXIT needs to be distinct from FAIL for ExitApp() and AutoExecSection().
	, FAIL_OR_OK // For LineError/RuntimeError, error is continuable.
};
enum SymbolType // For use with ExpandExpression() and IsNumeric().
{
	// The sPrecedence array in ExpandExpression() must be kept in sync with any additions, removals,
	// or re-ordering of the below.  When reordering or adding new symbols, take care not to break
	// the range checks in the various macros defined below.
	PURE_NOT_NUMERIC // Must be zero/false because callers rely on that.
	, PURE_INTEGER, PURE_FLOAT
	, SYM_STRING = PURE_NOT_NUMERIC, SYM_INTEGER = PURE_INTEGER, SYM_FLOAT = PURE_FLOAT // Specific operand types.
#define IS_NUMERIC(symbol) ((symbol) == SYM_INTEGER || (symbol) == SYM_FLOAT) // Ordered for short-circuit performance.
	, SYM_MISSING // Only used in parameter lists.
	, SYM_VAR // An operand that is a variable's contents.
	, SYM_OBJECT // L31: Represents an IObject interface pointer.
	, SYM_DYNAMIC // A dynamic variable reference/double-deref.  Also used in Object::Variant to identify dynamic properties.
};

#define CONFIG_DEBUGGER

struct ExprTokenType;
struct ResultToken;
class Object;
struct DECLSPEC_NOVTABLE IObject // L31: Abstract interface for "objects".
	: public IDispatch
{
#define IObject_Invoke_PARAMS_DECL \
		ResultToken &aResultToken, int aFlags, LPTSTR aName, ExprTokenType &aThisToken, ExprTokenType *aParam[], int aParamCount
#define IObject_Invoke_PARAMS \
		aResultToken, aFlags, aName, aThisToken, aParam, aParamCount
	virtual ResultType Invoke(IObject_Invoke_PARAMS_DECL) = 0;
	virtual LPTSTR Type() = 0;
#define IObject_Type_Impl(name) \
		LPTSTR Type() { return _T(name); }
	virtual Object* Base() = 0;
	virtual bool IsOfType(Object* aPrototype) = 0;

#ifdef CONFIG_DEBUGGER
#define IObject_DebugWriteProperty_Def \
		void DebugWriteProperty(void *, int aPage, int aPageSize, int aMaxDepth)
	virtual IObject_DebugWriteProperty_Def;
#else
#define IObject_DebugWriteProperty_Def
#endif
};

// {619f7e25-6d89-4eb4-b2fb-18e7c73c0ea6}
const IID IID_IObjectComCompatible = { 0x619f7e25, 0x6d89, 0x4eb4, 0xb2, 0xfb, 0x18, 0xe7, 0xc7, 0x3c, 0xe, 0xa6 };

#define MAXP_VARIADIC 255

//
// FlatVector - utility class.
//

template <typename T, typename index_t = ::size_t>
class FlatVector
{
public:
	struct Data
	{
		index_t size;
		index_t length;
	};
	Data* data;
	index_t& Length() { return data->length; }
	index_t Capacity() { return data->size; }
	T* Value() { return (T*)(data + 1); }
	operator T* () { return Value(); }
};

//
// Property: Invoked when a derived object gets/sets the corresponding key.
//

class Property
{
public:
	IObject* mGet = nullptr, * mSet = nullptr, * mCall = nullptr;
	// MaxParams is cached for performance.  It is used in cases like x.y[z]:=v to
	// determine whether to GET and then apply the parameters to the result, or just
	// invoke SET with parameters.
	int MinParams = -1, MaxParams = -1;
};

class Var;
class Func;
class BuiltInFunc;
struct CallSite
{
	Func* func = nullptr;
	LPTSTR member = nullptr;
	int flags = IT_CALL;
	int param_count = 0;

	inline bool is_variadic() { return flags & EIF_VARIADIC; }
};

enum DerefTypeType : BYTE
{
	DT_VAR,			// Variable reference, including built-ins.
	DT_DOUBLE,		// Marks the end of a double-deref.
	DT_STRING,		// Segment of text in a text arg (delimited by '%').
	DT_QSTRING,		// Segment of text in a quoted string (delimited by '%').
	DT_WORDOP,		// Word operator: and, or, not, new.
	DT_CONST_INT,	// Constant integer value (true, false).
	DT_DOTPERCENT,	// Dynamic member: .%name%
	DT_FUNCREF		// Reference to function (for fat arrow functions).
};
typedef UINT DerefLengthType;
struct DerefType
{
	LPTSTR marker;
	union
	{
		Var* var; // DT_VAR
		Func* func; // DT_FUNCREF
		DerefType* next; // DT_STRING
		SymbolType symbol; // DT_WORDOP
		int int_value; // DT_CONST_INT
	};
	// Keep any fields that aren't an even multiple of 4 adjacent to each other.  This conserves memory
	// due to byte-alignment:
	DerefTypeType type;
	UCHAR substring_count;
	DerefLengthType length; // Listed only after byte-sized fields, due to it being a WORD.
};

struct ExprTokenType  // Something in the compiler hates the name TokenType, so using a different name.
{
	// Due to the presence of 8-byte members (double and __int64) this entire struct is aligned on 8-byte
	// vs. 4-byte boundaries.  The compiler defaults to this because otherwise an 8-byte member might
	// sometimes not start at an even address, which would hurt performance on Pentiums, etc.
	union // Which of its members is used depends on the value of symbol, below.
	{
		__int64 value_int64; // for SYM_INTEGER
		double value_double; // for SYM_FLOAT
		struct
		{
			union // These nested structs and unions minimize the token size by overlapping data.
			{
				IObject* object;
				CallSite* callsite;   // for SYM_FUNC, and (while parsing) SYM_ASSIGN etc.
				DerefType* var_deref; // for SYM_VAR while parsing
				Var* var;             // for SYM_VAR and SYM_DYNAMIC
				LPTSTR marker;        // for SYM_STRING and (while parsing) SYM_OPAREN
				ExprTokenType* circuit_token; // for short-circuit operators
			};
			union // Due to the outermost union, this doesn't increase the total size of the struct on x86 builds (but it does on x64).
			{
				CallSite* outer_param_list; // Used by ExpressionToPostfix().
				LPTSTR error_reporting_marker; // Used by ExpressionToPostfix() for binary and unary operators.
				size_t marker_length;
				int var_usage;		// for SYM_DYNAMIC and SYM_VAR (at load time)
			};
		};
	};
	SymbolType symbol;
};

struct ResultToken : public ExprTokenType
{
	LPTSTR buf; // Points to a buffer of _f_retval_buf_size characters for returning short strings and misc purposes.
	LPTSTR mem_to_free; // Callee stores memory allocated for the result here.  Must be NULL or equal to marker.
#ifdef ENABLE_HALF_BAKED_NAMED_PARAMS
	IObject* named_params; // Variadic callers may pass named parameters via properties of this.
#endif
	BuiltInFunc* func; // For maintainability, this is separate from the ExprTokenType union.  Its main uses are func->mID and func->mOutputVars.

	// Utility function for initializing result tokens.
	void InitResult(LPTSTR aResultBuf)
	{
		symbol = SYM_STRING;
		marker = (LPTSTR)_T("");
		marker_length = -1; // Helps code size to do this here instead of in ReturnPtr(), which should be inlined.
		buf = aResultBuf;
		mem_to_free = nullptr;
#ifdef ENABLE_HALF_BAKED_NAMED_PARAMS
		named_params = nullptr;
#endif
		result = OK;
	}

	// Utility function for properly freeing a token's contents.
	void Free()
	{
		// If the token contains an object, release it.
		if (symbol == SYM_OBJECT)
			object->Release();
		// If the token has memory allocated for it, free it.
		if (mem_to_free)
			free(mem_to_free);
	}

	void AcceptMem(LPTSTR aNewMem, size_t aLength)
	{
		symbol = SYM_STRING;
		marker = mem_to_free = aNewMem;
		marker_length = aLength;
	}
	// Currently can't be included in the value union because meta-functions
	// need the EARLY_RETURN result *and* return value passed back.  However,
	// probably best to keep it separate for code size and maintainability.
	// Struct size is a non-issue since there is only one ResultToken per
	// function call on the stack.
	ResultType result;
};

struct TString
{
private:
	TCHAR* _p = NULL;
	size_t _len = 0;
	size_t capacity = 0;
	bool Realloc(size_t aNewSize) {
		TCHAR* newp = (TCHAR*)realloc(_p, sizeof(TCHAR) * aNewSize);
		if (!newp)
			return false;
		_p = newp;
		capacity = aNewSize;
		return true;
	}
	inline bool EnsureCapacity(size_t aLength) {
		return capacity > aLength ? OK : Realloc(aLength < (capacity << 1) ? capacity << 1 : aLength);
		if (capacity >= aLength)
			return OK;
		size_t newsize = capacity ? capacity : aLength;
		while (newsize < aLength)
			newsize *= 2;
		return Realloc(newsize);
	}
public:
	TString() {}
	~TString() { if (_p) free(_p); }
	TCHAR* data() { _p[_len] = 0; return _p; }
	size_t size() { return _len; }
	TString& append(ResultToken& token) {
		if (token.marker_length == -1)
			token.marker_length = _tcsclen(token.marker);
		if (!_p && token.mem_to_free) {
			_p = token.marker;
			capacity = _len = token.marker_length;
			token.mem_to_free = nullptr;
		}
		else
			append(token.marker, token.marker_length);
		return *this;
	}
	TString& append(TCHAR ch) {
		if (EnsureCapacity(_len + 2))
			_p[_len++] = ch;
		return *this;
	}
	TString& operator+=(TCHAR* str) {
		size_t len = _tcslen(str);
		return append(str, len);
	}
	TString& append(TCHAR* str, size_t len) {
		if (EnsureCapacity(_len + len + 1)) {
#ifdef UNICODE
			wmemcpy(_p + _len, str, len);
#else
			memcpy(_p + _len, str, len);
#endif
			_len += len;
		}
		return *this;
	}
	TCHAR& back() {
		return _p[_len - 1];
	}
	void release() { _p = NULL; _len = capacity = 0; }
	void pop_back() {
		if (_len)
			_len--;
	}
};

enum AllocMethod { ALLOC_NONE, ALLOC_SIMPLE, ALLOC_MALLOC };
enum VarTypes
{
	// The following must all be LOW numbers to avoid any realistic chance of them matching the address of
	// any function (namely a BIV_* function).
	VAR_ALIAS  // VAR_ALIAS must always have a non-NULL mAliasFor.  In other ways it's the same as VAR_NORMAL.  VAR_ALIAS is never seen because external users call Var::Type(), which automatically resolves ALIAS to some other type.
	, VAR_NORMAL // Most variables, such as those created by the user, are this type.
	, VAR_CONSTANT // or as I like to say, not variable.
	, VAR_VIRTUAL
	, VAR_LAST_TYPE = VAR_VIRTUAL
};
typedef UCHAR VarTypeType;     // UCHAR vs. VarTypes to save memory.
typedef UCHAR AllocMethodType; // UCHAR vs. AllocMethod to save memory.
typedef UCHAR VarAttribType;   // Same.
typedef UINT_PTR VarSizeType;  // jackieku(2009-10-23): Change this to UINT_PTR to ensure its size is the same with a pointer.

#ifdef _WIN64
#pragma pack(push, 8)
#else
#pragma pack(push, 4) // 32-bit vs. 64-bit. See above.
#endif
class Var
{
public:
	// Keep VarBkp (above) in sync with any changes made to the members here.
	union // 64-bit members kept at the top of the struct to reduce the chance that they'll span 2 64-bit regions.
	{
		// Although the 8-byte members mContentsInt64 and mContentsDouble could be hung onto the struct
		// via a 4-byte-pointer, thus saving 4 bytes for each variable that never uses a binary number,
		// it doesn't seem worth it because the percentage of variables in typical scripts that will
		// acquire a cached binary number at some point seems likely to be high. A percentage of only
		// 50% would be enough to negate the savings because half the variables would consume 12 bytes
		// more than the version of AutoHotkey that has no binary-number caching, and the other half
		// would consume 4 more (due to the unused/empty pointer).  That would be an average of 8 bytes
		// extra; i.e. exactly the same as the 8 bytes used by putting the numbers directly into the struct.
		// In addition, there are the following advantages:
		// 1) Code less complicated, more maintainable, faster.
		// 2) Caching of binary numbers works even in recursive script functions.  By contrast, if the
		//    binary number were allocated on demand, recursive functions couldn't use caching because the
		//    memory from SimpleHeap could never be freed, thus producing a memory leak.
		// The main drawback is that some scripts are known to create a million variables or more, so the
		// extra 8 bytes per variable would increase memory load by 8+ MB (possibly with a boost in
		// performance if those variables are ever numeric).
		__int64 mContentsInt64;
		double mContentsDouble;
		IObject* mObject; // L31
		//VirtualVar* mVV; // VAR_VIRTUAL
	};
	union
	{
		LPTSTR mCharContents; // Invariant: Anyone setting mByteCapacity to 0 must also set mCharContents to the empty string.
		char* mByteContents;
	};
	union
	{
		Var* mAliasFor = nullptr; // The variable for which this variable is an alias.
		VarSizeType mByteLength;  // How much is actually stored in it currently, excluding the zero terminator.
	};
	VarSizeType mByteCapacity = 0; // In bytes.  Includes the space for the zero terminator.
	AllocMethodType mHowAllocated = ALLOC_NONE; // Keep adjacent/contiguous with the below to save memory.
#define VAR_ATTRIB_CONTENTS_OUT_OF_DATE	0x01 // Combined with VAR_ATTRIB_IS_INT64/DOUBLE/OBJECT to indicate mContents is not current.
#define VAR_ATTRIB_ALREADY_WARNED		0x01 // Combined with VAR_ATTRIB_UNINITIALIZED to limit VarUnset warnings to 1 MsgBox per var.  See WarnUnassignedVar.
#define VAR_ATTRIB_UNINITIALIZED		0x02 // Var requires initialization before use.
#define VAR_ATTRIB_HAS_ASSIGNMENT		0x04 // Used during load time to detect vars that are not assigned anywhere.
#define VAR_ATTRIB_NOT_NUMERIC			0x08 // A prior call to IsNumeric() determined the var's value is PURE_NOT_NUMERIC.
#define VAR_ATTRIB_IS_INT64				0x10 // Var's proper value is in mContentsInt64.
#define VAR_ATTRIB_IS_DOUBLE			0x20 // Var's proper value is in mContentsDouble.
#define VAR_ATTRIB_IS_OBJECT			0x40 // Var's proper value is in mObject.
#define VAR_ATTRIB_VIRTUAL_OPEN			0x80 // Virtual var is open for writing.
#define VAR_ATTRIB_CACHE (VAR_ATTRIB_IS_INT64 | VAR_ATTRIB_IS_DOUBLE | VAR_ATTRIB_NOT_NUMERIC) // These three are mutually exclusive.
#define VAR_ATTRIB_TYPES (VAR_ATTRIB_IS_INT64 | VAR_ATTRIB_IS_DOUBLE | VAR_ATTRIB_IS_OBJECT) // These are mutually exclusive (but NOT_NUMERIC may be combined with OBJECT).
#define VAR_ATTRIB_OFTEN_REMOVED (VAR_ATTRIB_CACHE | VAR_ATTRIB_CONTENTS_OUT_OF_DATE | VAR_ATTRIB_UNINITIALIZED)
	VarAttribType mAttrib;  // Bitwise combination of the above flags (but many of them may be mutually exclusive).
#define VAR_GLOBAL			0x01
#define VAR_LOCAL			0x02
#define VAR_VARREF			0x04 // This is a VarRef (used to determine whether the ToReturnValue optimization is safe).
#define VAR_DOWNVAR			0x08 // This var is captured by a nested function/closure (it's in Func::mDownVar).
#define VAR_LOCAL_FUNCPARAM	0x10 // Indicates this local var is a function's parameter.  VAR_LOCAL_DECLARED should also be set.
#define VAR_LOCAL_STATIC	0x20 // Indicates this local var retains its value between function calls.
#define VAR_DECLARED		0x40 // Indicates this var was declared somehow, not automatic.
#define VAR_MACRO			0x80
	UCHAR mScope;  // Bitwise combination of the above flags.
	VarTypeType mType; // Keep adjacent/contiguous with the above due to struct alignment, to save memory.
	// Performance: Rearranging mType and the other byte-sized members with respect to each other didn't seem
	// to help performance.  However, changing VarTypeType from UCHAR to int did boost performance a few percent,
	// but even if it's not a fluke, it doesn't seem worth the increase in memory for scripts with many
	// thousands of variables.

	TCHAR* mName;    // The name of the var.
}; // class Var
#pragma pack(pop) // Calling pack with no arguments restores the default value (which is 8, but "the alignment of a member will be on a boundary that is either a multiple of n or a multiple of the size of the member, whichever is smaller.")


class Object : public IObject
{
protected:
	ULONG mRefCount;
	UINT mFlags;

	typedef LPTSTR name_t;
	typedef FlatVector<TCHAR> String;

public:
	// The type of an array element index or count.
	// Use unsigned to avoid the need to check for negatives.
	typedef UINT index_t;
	struct Variant
	{
		union { // Which of its members is used depends on the value of symbol, below.
			__int64 n_int64;	// for SYM_INTEGER
			double n_double;	// for SYM_FLOAT
			IObject* object;	// for SYM_OBJECT
			String string;		// for SYM_STRING
			Property* prop;		// for SYM_DYNAMIC
		};
		SymbolType symbol;
		// key_c contains the first character of key.s. This utilizes space that would
		// otherwise be unused due to 8-byte alignment. See FindField() for explanation.
		TCHAR key_c;
	};

	struct FieldType : Variant
	{
		name_t name;
	};

	enum EnumeratorType
	{
		Enum_Properties,
		Enum_Methods
	};

	enum Flags : decltype(mFlags)
	{
		UnsortedFlag = 0x80000000,  // for thqby's AHK_H
		ClassPrototype = 0x01,
		NativeClassPrototype = 0x02,
		LastObjectFlag = 0x02
	};

	Object* mBase = nullptr;
	FlatVector<FieldType, index_t> mFields;
};

//
// Array
//

class Array : public Object
{
public:
	Variant* mItem = nullptr;
	index_t mLength = 0, mCapacity = 0;

	enum : index_t
	{
		BadIndex = UINT_MAX, // Always >= mLength.
		MaxIndex = INT_MAX // This would need 32GB RAM just for mItem, assuming 16 bytes per element.  Not exceeding INT_MAX might avoid some issues.
	};
};

// Must not be smaller than INT_PTR; see "(IntKeyType)(INT_PTR)".
typedef __int64 IntKeyType;

//
// Map
//

class Map : public Object
{
	union Key // Which of its members is used depends on the field's position in the mItem array.
	{
		LPTSTR s;
		IntKeyType i;
		IObject* p;
	};
	struct Pair : Variant
	{
		Key key;
	};

	enum MapOption : decltype(mFlags)
	{
		MapCaseless = LastObjectFlag << 1,
			MapUseLocale = MapCaseless << 1
	};

	Pair* mItem = nullptr;
	index_t mCount = 0, mCapacity = 0;

	// Holds the index of the first key of a given type within mItem.  Must be in the order: int, object, string.
	// Compared to storing the key-type with each key-value pair, this approach saves 4 bytes per key (excluding
	// the 8 bytes taken by the two fields below) and speeds up lookups since only the section within mItem
	// with the appropriate type of key needs to be searched (and no need to check the type of each key).
	// mKeyOffsetObject should be set to mKeyOffsetInt + the number of int keys.
	// mKeyOffsetString should be set to mKeyOffsetObject + the number of object keys.
	// mKeyOffsetObject-1, mKeyOffsetString-1 and mFieldCount-1 indicate the last index of each prior type.
	static const index_t mKeyOffsetInt = 0;
	index_t mKeyOffsetObject = 0, mKeyOffsetString = 0;
};

class BufferObject : public Object
{
public:
	void* mData;
	size_t mSize;
};

class ComObject : public IObject
{
protected:
	ULONG mRefCount;
#ifdef _WIN64
	// Used by Object, but defined here on (x64 builds only) to utilize the space
	// that would otherwise just be padding, due to alignment requirements.
	UINT _mFlags;
#endif

public:
	union
	{
		IDispatch* mDispatch;
		IUnknown* mUnknown;
		SAFEARRAY* mArray;
		void* mValPtr;
		__int64 mVal64; // Allow 64-bit values when ComObject is used as a VARIANT in 32-bit builds.
	};
	void* mEventSink;
	VARTYPE mVarType;
	enum { F_OWNVALUE = 1 };
	USHORT mFlags;
};

class DECLSPEC_NOVTABLE Func : public Object
{
public:
	LPCTSTR mName;
	int mParamCount = 0; // The function's maximum number of parameters.  For UDFs, also the number of items in the mParam array.
	int mMinParams = 0;  // The number of mandatory parameters (populated for both UDFs and built-in's).
	bool mIsVariadic = false; // Whether to allow mParamCount to be exceeded.

	virtual bool IsBuiltIn() = 0; // FIXME: Should not need to rely on this.
	virtual bool ArgIsOutputVar(int aArg) = 0;

	// bool result indicates whether aResultToken contains a value (i.e. false for FAIL/EARLY_EXIT).
	virtual bool Call(ResultToken& aResultToken, ExprTokenType* aParam[], int aParamCount) = 0;

	virtual IObject* CloseIfNeeded() = 0;
};

class DECLSPEC_NOVTABLE NativeFunc : public Func
{
public:
	UCHAR* mOutputVars = nullptr; // String of indices indicating which params are output vars (for BIF_PerformAction).
};

enum BuiltInFunctionID {};
#define BIF_DECL_PARAMS ResultToken &aResultToken, ExprTokenType *aParam[], int aParamCount

// The following macro is used for definitions and declarations of built-in functions:
#define BIF_DECL(name) void name(BIF_DECL_PARAMS)

typedef BIF_DECL((*BuiltInFunctionType));
class BuiltInFunc : public NativeFunc
{
public:
	BuiltInFunctionType mBIF;
	union {
		BuiltInFunctionID mFID; // For code sharing: this function's ID in the group of functions which share the same C++ function.
		void* mData;
	};
};

typedef void (IObject::* ObjectMethod)(ResultToken& aResultToken, int aID, int aFlags, ExprTokenType* aParam[], int aParamCount);
class BuiltInMethod : public NativeFunc
{
public:
	ObjectMethod mBIM;
	Object* mClass; // The class or prototype object which this method was defined for, and which `this` must derive from.
	UCHAR mMID;
	UCHAR mMIT;
};
// constexpr int size_BuiltInFunc = sizeof(BuiltInFunc);		//80	48
// constexpr int size_BuiltInFunc = sizeof(BuiltInMethod);		//104	64
// constexpr int size_ResultToken = sizeof(ResultToken);		//56	32
