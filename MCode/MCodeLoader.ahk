/************************************************************************
 * @description Enhanced version of MCode, which can build machine code supporting import symbol,
 * multi-function export, using strings, setting global variables and other features.
 * @author thqby
 * @date 2024/12/29
 * @version 1.0.1
 ***********************************************************************/

class MCodeLoader extends Buffer {
	/**
	 * Build a c/c++ code buffer, retrieve the function address, and then call it with DllCall to get higher performance.
	 * @param {{32?:String|$Code, 64?:String|$Code, import?:String, export?:String}} configs 
	 * @param {Integer} bits Number of bits corresponding to the code to be loaded.
	 * The built code cannot be run when the bits are inconsistent with the current exe.
	 * @param {Map} import_fn_ptrs Fill in the import address table with the function address obtained by yourself.
	 * @typedef {Object} $Code
	 * @property {String} code Base64 format string.
	 * @property {Integer} size If the code is compressed by LZ, the value is the decompressed size.
	 * @property {String|Array<String>} export The comma-concatenated names that are sequentially associated with the export function.
	 * If not specified, it is named by serial number.
	 * @property {String} import Get the address of dll import symbols in sequence and fill them into the import address table.
	 * e.g. `dll1:fn1,fn2|dll2:fn3`
	 */
	__New(configs, bits := A_PtrSize * 8, import_fn_ptrs := Map()) {
		if !ObjHasOwnProp(configs, bits)
			throw ValueError('No matching machine code')
		import := prop('import'), export_ := prop('export'), configs := configs.%bits%
		if IsObject(configs)
			import := prop('import') || import, export_ := prop('export') || export_, configs := configs.code
		if n := RegExMatch(configs, '^[\da-f]{1,8},\K')
			this.Size := '0x' SubStr(configs, 1, --n - 1), lz_decompress(base64_decode(StrPtr(configs) + n * 2), this)
		else base64_decode(StrPtr(configs), this)

		; decode headers
		; .export: N, offset1, ..., offsetN; .import: N, extry offset; .reloc: offset1, offset2, ..., 0
		bptr := this.Ptr, cptr := bptr + this.Size, eptr := cptr--, exports := [], relocs := []
		loop read_int() {
			if eptr <= n := read_int() + bptr
				throw ValueError('unknown/corrupt code format')
			exports.Push(n)
		} else exports.Push(bptr)
		import_count := read_int()
		if import_count && eptr < import_count * 4 + import_entry := read_int() + bptr
			throw ValueError('unknown/corrupt code format')
		while n := read_int()
			if eptr <= n += bptr
				throw ValueError('unknown/corrupt code format')
			else relocs.Push(n)
		(n := eptr - cptr += 2) && DllCall('RtlZeroMemory', 'ptr', cptr, 'uptr', n)

		; relocation
		for n in relocs
			if eptr <= t := NumGet(n, 'ptr') + bptr
				throw ValueError('unknown/corrupt code format')
			else NumPut('ptr', t, n)

		; import symbols
		if import_count {
			tp := bits = 32 ? 'uint' : 'int64'
			import_fn_ptrs := _fn_ptrs := import_fn_ptrs.Get.Bind(import_fn_ptrs, , 0)
			if bits = A_PtrSize * 8
				import_fn_ptrs := ((f, n) => f(n) || DllCall('GetProcAddress', 'ptr', mod, 'astr', n, 'ptr')).Bind(import_fn_ptrs)
			for n in StrSplit(import || '', '|') {
				t := InStr(n, ':'), r := SubStr(n, 1, t - 1)
				if r = '?'
					import_fn_ptrs := _fn_ptrs
				else if !mod := DllCall('GetModuleHandle', 'str', r, 'ptr') || DllCall('LoadLibrary', 'str', r, 'ptr')
					throw OSError(,, r)
				for n in StrSplit(SubStr(n, t + 1), ',', ' ')
					if !cptr := import_fn_ptrs(n)
						throw ValueError('unknown import symbol',, r '\' n)
					else import_entry := NumPut(tp, cptr, import_entry), import_count--
			}
			if import_count
				throw ValueError('wrong number of import symbols', import_count)
		}

		if bits = A_PtrSize * 8 && !DllCall('VirtualProtect', 'ptr', bptr, 'uint', this.Size, 'uint', 0x40, 'uint*', 0)
			throw OSError()

		if export_ {
			if export_ is String
				export_ := StrSplit(export_, ',')
			t := exports, exports := Map()
			loop Min(export_.Length, t.Length)
				exports[export_[A_Index]] := t[A_Index]
		}
		this.DefineProp('__Item', { value: exports })
			.DefineProp('__Enum', { call: (*) => exports.__Enum() })

		static base64_decode(b64, buf := Buffer()) {
			if DllCall('crypt32\CryptStringToBinary', 'ptr', b64, 'uint', 0, 'uint', 1, 'ptr', 0, 'uint*', &sz := 0, 'ptr', 0, 'ptr', 0) &&
				DllCall('crypt32\CryptStringToBinary', 'ptr', b64, 'uint', 0, 'uint', 1, 'ptr', buf, 'uint*', buf.Size := sz, 'ptr', 0, 'ptr', 0)
				return buf
			throw OSError()
		}
		static lz_decompress(compressBuf, UncompressBuf) {
			DllCall('ntdll\RtlDecompressBuffer', 'ushort', 2, 'ptr', UncompressBuf, 'uint', UncompressBuf.Size,
				'ptr', compressBuf, 'uint', compressBuf.Size, 'uint*', &fuSize := 0, 'hresult')
			if UncompressBuf.Size != fuSize
				throw ValueError('unknown/corrupt code format')
		}
		prop(name) => ObjHasOwnProp(configs, name) && configs.%name%
		read_int() {
			n := NumGet(cptr--, 'uchar')
			switch n & 0xc0 {
				case 0x80: n := (n & 0x3f) << 8 | NumGet(cptr--, 'uchar')
				case 0xc0: n := (n & 0x3f) << 24 | NumGet(cptr--, 'uchar') << 16 | NumGet(cptr--, 'uchar') << 8 | NumGet(cptr--, 'uchar')
			}
			return n
		}
	}

	; Retrieve the export function address
	__Item[name] => 0
	; Enumeration of export function addresses
	__Enum(*) => 0
}
