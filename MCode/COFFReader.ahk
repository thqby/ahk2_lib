/************************************************************************
 * @description Modify from {@link https://github.com/G33kDude/MCL.ahk/blob/v2/MCL.ahk}
 * COFF(Common Object File Format) file reader, compile c/c++ files with cl.exe to get *.obj files,
 * and then read them to extract MCode.
 ***********************************************************************/
class COFFReader extends Buffer {
	Exports := [], Functions := Map()
	Symbols := [], SymbolByName := Map()
	__New(path) {
		f := FileOpen(path, 'r'), f.Pos := 0
		this.Size := f.Length
		f.RawRead(this), f.Close()
		this.Read()
	}
	__Delete() {
		for k in ObjOwnProps(this)
			this.%k% := 0
	}
	ReadString(Offset, Length?) => StrGet(this.Ptr + Offset, Length?, 'utf-8')
	ReadUChar(Offset) => NumGet(this, Offset, 'uchar')
	ReadUShort(Offset) => NumGet(this, Offset, 'ushort')
	ReadUInt(Offset) => NumGet(this, Offset, 'uint')

	ReadSection(HeadersBase, HeaderIndex) {
		static SIZEOF_SECTION_HEADER := 40

		HeaderOffset := HeadersBase + (HeaderIndex * SIZEOF_SECTION_HEADER)
		Result := {
			Index: HeaderIndex,
			Name: this.ReadString(HeaderOffset, 8),
			VirtualSize: this.ReadUInt(HeaderOffset + 8),
			VirtualAddress: this.ReadUInt(HeaderOffset + 12),
			FileSize: this.ReadUInt(HeaderOffset + 16),
			FileOffset: this.ReadUInt(HeaderOffset + 20),
			RelocationsOffset: this.ReadUInt(HeaderOffset + 24),
			RelocationCount: this.ReadUInt(HeaderOffset + 32),
			Characteristics: this.ReadUInt(HeaderOffset + 36),
			Relocations: [],
			Symbols: []
		}

		align := Result.Characteristics >>> 20 & 0xf
		Result.Align := align ? 1 << --align : 0

		if (SubStr(Result.Name, 1, 1) = '/') {
			Result.Name := this.ReadString(this.StringTableOffset + SubStr(Result.Name, 2))
		} else if Result.Name = '.drectve' {
			drectve := this.ReadString(Result.FileOffset, Result.FileSize), pos := 1
			while pos := RegExMatch(drectve, '/EXPORT:(\S+)\K', &m, pos)
				this.Exports.Push(this.SymbolByName[RegExReplace(m[1], ',DATA$')])
		}

		if !Result.FileOffset {
			; As mentioned, a section initialized to 0, which has no space allocated for it in the file. So we
			;  need to allocate some space for it.
			_buf := Buffer(Result.FileSize, 0), InitialData := _buf.Ptr
		} else {
			InitialData := this.Ptr + Result.FileOffset
		}

		Result.Data := COFFReader.Data(InitialData, Result.FileSize, _buf?)
		NextRelocationOffset := Result.RelocationsOffset

		loop Result.RelocationCount {
			; All relocations are processed later, but it is easiest to read them early and have them ready
			;  whenever we need.
			RelocationAddress := this.ReadUInt(NextRelocationOffset)
			SymbolIndex := this.ReadUInt(NextRelocationOffset + 4)
			RelocationType := this.ReadUShort(NextRelocationOffset + 8)
			NextRelocationOffset += 10
			RelocationSymbol := this.Symbols[SymbolIndex + 1]
			Result.Relocations.Push({
				Address: RelocationAddress,
				Type: RelocationType,
				Symbol: RelocationSymbol
			})
		}

		; Technically, symbols are global. But each one exists inside of a single section, so we can filter the
		; global list of symbols into the sections living inside of each section to make things a bit easier.

		for Symbol in this.Symbols {
			if !IsSet(Symbol) || Symbol.SectionIndex != HeaderIndex + 1
				continue
			Symbol.Section := Result
			Result.Symbols.Push(Symbol)
		}

		return Result
	}

	ReadSymbolHeader(HeaderOffset) {
		if (this.ReadUInt(HeaderOffset)) {
			Name := this.ReadString(HeaderOffset, 8)
		} else {
			Name := this.ReadString(this.StringTableOffset + this.ReadUInt(HeaderOffset + 4))
		}

		return {
			Name: Name,
			Value: this.ReadUInt(HeaderOffset + 8),
			SectionIndex: this.ReadUShort(HeaderOffset + 12),
			Type: this.ReadUShort(HeaderOffset + 14),
			StorageClass: this.ReadUChar(HeaderOffset + 16),
			AuxSymbolCount: this.ReadUChar(HeaderOffset + 17)
		}
	}

	MergeSections(Target, Sources*) {
		; Given a target section, and multiple source sections, join them all into a single section.
		; This is done by appending the 'source' section's data to the 'target' section's data, and
		;  then adding the offset of the 'source' inside of the 'target' to every symbol/relocation
		;   inside of the 'source'.
		; Then, the 'source' symbols can just be added to the 'target' symbol lists, and the 'source'
		;  relocations can just be added to the 'target' relocation list.

		for Section in Sources {
			if Section = Target
				continue

			OffsetInTarget := Target.Data.Length()
			Align := Section.Align
			Section.Offset := Offset := (OffsetInTarget + --Align) & ~Align
			if Offset > OffsetInTarget {
				buf := Buffer(Offset - OffsetInTarget, InStr(Section.Name, '.text') = 1 && 0xcc)
				Target.Data.Push({ Ptr: buf.Ptr, Size: buf.Size, Buf: buf })
				OffsetInTarget := Offset
			}
			Target.Data.Add(Section.Data)	; Merge section data

			for Symbol in Section.Symbols {
				Symbol.Value += OffsetInTarget
				Symbol.Section := Target
				Target.Symbols.Push(Symbol)
			}

			for Relocation in Section.Relocations {
				Relocation.Address += OffsetInTarget
				Target.Relocations.Push(Relocation)
			}

			Target.RelocationCount += Section.RelocationCount
		}
	}

	Read() {
		; Load all fields from the COFF file loaded into this instance

		static SIZEOF_COFF_HEADER := 20
		static SIZEOF_SECTION_HEADER := 40
		static SIZEOF_SYMBOL := 18

		Magic := this.ReadUShort(0)
		this.Is32Bit := Magic = 0x14c
		this.Is64Bit := Magic = 0x8664

		if (this.Is32Bit + this.Is64Bit != 1) {
			throw Error('Not a valid 32/64 bit COFF file')
		}

		SymbolTableOffset := this.ReadUInt(8)
		SymbolCount := this.ReadUInt(12)
		SymbolIndex := 0

		this.StringTableOffset := SymbolTableOffset + (SymbolCount * SIZEOF_SYMBOL)
		this.Symbols.Default := {}

		while (SymbolIndex < SymbolCount) {
			this.Symbols.Push(NextSymbol := this.ReadSymbolHeader(SymbolTableOffset + (SymbolIndex * SIZEOF_SYMBOL)))

			if NextSymbol.Type = 0x20
				this.Functions[NextSymbol.Name] := NextSymbol

			if NextSymbol.StorageClass = 2 && NextSymbol.SectionIndex
				this.SymbolByName[NextSymbol.Name] := NextSymbol

			; Aux symbols only serve to pad out the symbol table so the indexes inside of relocations are correct.
			this.Symbols.Length += NextSymbol.AuxSymbolCount

			; IMAGE_SYM_CLASS_WEAK_EXTERNAL
			if NextSymbol.StorageClass = 105 && NextSymbol.AuxSymbolCount {
				Offset := SymbolTableOffset + (SymbolIndex + 1) * SIZEOF_SYMBOL
				Index := this.ReadUInt(Offset), Characteristics := this.ReadUInt(Offset + 4)
				switch this.ReadUInt(Offset + 4) {
					case 4:	; IMAGE_WEAK_EXTERN_ANTI_DEPENDENCY
						throw Error('unimplemented')
					case 2:	; IMAGE_WEAK_EXTERN_SEARCH_LIBRARY
						this.Symbols[SymbolIndex + 1].WeakExternal := this.Symbols[Index + 1]
						throw Error('unimplemented')
					default:	; IMAGE_WEAK_EXTERN_SEARCH_NOLIBRARY, IMAGE_WEAK_EXTERN_SEARCH_ALIAS
						this.Symbols[SymbolIndex + 1] := this.Symbols[Index + 1]
				}
			}

			SymbolIndex += 1 + NextSymbol.AuxSymbolCount
		}

		SectionHeaderCount := this.ReadUShort(2)
		SizeOfOptionalHeader := this.ReadUShort(16)
		SectionHeaderTableOffset := SIZEOF_COFF_HEADER + SizeOfOptionalHeader
		this.Sections := [], this.UndefinedSymbols := Map()

		loop SectionHeaderCount {
			NextSection := this.ReadSection(SectionHeaderTableOffset, (A_Index - 1))
			this.Sections.Push(NextSection)
		}

		for Symbol in this.Symbols {
			if IsSet(Symbol) && !Symbol.HasOwnProp('Section') && !Symbol.SectionIndex
				this.UndefinedSymbols[Symbol.Name] := Symbol
		}
	}

	DoStaticRelocations(Section) {
		; Resolve any relocations which are independent of the image base/load address.
		; On 64 bit, this is anything RIP-relative to `Section`, or DISP8/DISP32 operands.
		; On 32 bit, this is only DISP8/DISP32 operands, since RIP-relative doesn't exist.

		; Note: The relocation list is cloned since we'll be modifying it to remove any relocations resolved
		;  entirely within this function.
		relocations := [], data := Section.Data, apply := this.Is32Bit ? ApplyRelx86 : ApplyRelx64
		for Relocation in Section.Relocations {
			if (Relocation.Symbol.Section != Section) {
				; If the data is relocated against a symbol in any other section, we can't resolve it, since
				;  we don't actually know the offset between the two sections.

				continue
			}

			apply(Relocation)
		}
		return relocations
		ApplyRelx86(reloc) {
			static IMAGE_REL_I386_DIR32 := 0x6
			static IMAGE_REL_I386_DIR32NB := 0x7
			static IMAGE_REL_I386_REL32 := 0x14
			off := reloc.Address
			s := reloc.Symbol.Value
			switch rt := reloc.Type {
				case IMAGE_REL_I386_DIR32:
					data.Write(data.Read(off, 'int') + s, off, 'int')
					relocations.Push(off)
				case IMAGE_REL_I386_DIR32NB:
					data.Write(data.Read(off, 'int') + s, off, 'int')
				case IMAGE_REL_I386_REL32:
					data.Write(data.Read(off, 'int') + s - off - 4, off, 'int')
				default: throw Error(Format('unsupported relocation type: 0x{:02x}', rt))
			}
		}
		ApplyRelx64(reloc) {
			static IMAGE_REL_AMD64_ADDR64 := 0x1
			static IMAGE_REL_AMD64_ADDR32 := 0x2
			static IMAGE_REL_AMD64_ADDR32NB := 0x3
			static IMAGE_REL_AMD64_REL32 := 0x4
			static IMAGE_REL_AMD64_REL32_1 := 0x5
			static IMAGE_REL_AMD64_REL32_2 := 0x6
			static IMAGE_REL_AMD64_REL32_3 := 0x7
			static IMAGE_REL_AMD64_REL32_4 := 0x8
			static IMAGE_REL_AMD64_REL32_5 := 0x9
			off := reloc.Address
			s := reloc.Symbol.Value
			switch rt := reloc.Type {
				case IMAGE_REL_AMD64_ADDR64:
					data.Write(data.Read(off, 'int64') + s, off, 'int64')
					relocations.Push(off)
				case IMAGE_REL_AMD64_ADDR32:
					data.Write(data.Read(off, 'int') + s, off, 'int')
					relocations.Push(off)
				case IMAGE_REL_AMD64_ADDR32NB:
					data.Write(data.Read(off, 'int') + s, off, 'int')
				case IMAGE_REL_AMD64_REL32:
					data.Write(data.Read(off, 'int') + s - off - 4, off, 'int')
				case IMAGE_REL_AMD64_REL32_1:
					data.Write(data.Read(off, 'int') + s - off - 5, off, 'int')
				case IMAGE_REL_AMD64_REL32_2:
					data.Write(data.Read(off, 'int') + s - off - 6, off, 'int')
				case IMAGE_REL_AMD64_REL32_3:
					data.Write(data.Read(off, 'int') + s - off - 7, off, 'int')
				case IMAGE_REL_AMD64_REL32_4:
					data.Write(data.Read(off, 'int') + s - off - 8, off, 'int')
				case IMAGE_REL_AMD64_REL32_5:
					data.Write(data.Read(off, 'int') + s - off - 9, off, 'int')
				default: throw Error(Format('unsupported relocation type: 0x{:02x}', rt))
			}
		}
	}

	/**
	 * @param {Map} Result - Map to populate with dependencies
	 */
	CollectSectionDependencies(Result, Target) {
		; Given a section `Target`, set `Result[RequiredSectionName] := RequiredSection` for each
		; section which `Target` requires loaded into memory in order to run correctly.
		; And of course, this includes any sections which `RequiredSection` itself requires, and so on.

		if (Result.Has(index := Target.Index))
			return

		Result[index] := Target

		for Relocation in Target.Relocations
			if Relocation.Symbol.SectionIndex
				this.CollectSectionDependencies(Result, Relocation.Symbol.Section)
			else (Result.Get(0, 0) || Result[0] := (t := Map(), t.Default := 0, t))[Relocation.Symbol]++
	}

	class Data extends Array {
		; Just a list of 'fragments' of data, aka an easy way to join multiple smaller buffers into one larger one without
		;  loads of copies (at least until all data needs to be written to a single buffer, aka coalesced)

		__New(Ptr?, Size?, Buf?) => IsSet(Ptr) && this.Push({ Ptr: Ptr, Size: Size, Buf: Buf? })
		Add(Data, Size?) => IsObject(Data) ? this.Push(Data*) : this.Push({ Ptr: Data, Size: Size })
		Length() {
			Result := 0
			for v in this
				Result += v.Size
			return Result
		}
		/**
		 * Merge all fragments into a single buffer
		 */
		Coalesce(Dest) {
			for v in this {
				DllCall('RtlMoveMemory', 'ptr', Dest, 'ptr', v, 'uptr', v.Size)
				Dest += v.Size
			}
		}
		Read(Offset, Type) {
			for v in this {
				if (Offset < v.Size)
					return NumGet(v, Offset, Type)
				Offset -= v.Size
			}
			throw Error('Attempt to read from offset past end of section data')
		}
		Write(Value, Offset, Type) {
			for v in this {
				if (Offset < v.Size)
					return NumPut(Type, Value, v, Offset)
				Offset -= v.Size
			}
			throw Error('Attempt to write to offset past end of section data')
		}
	}
	static __New() {
		COFFReader.DeleteProp('__New')
		if ObjHasOwnProp(Array.Prototype, 'Sort')
			return
		for v in ['Filter', 'Join', 'Map', 'Sort']
			Array.Prototype.DefineProp(v, { call: _%v% })
		static _Filter(this, fn) {
			t := []
			for i in this
				fn(i) && t.Push(i)
			return t
		}
		static _Join(this, c) {
			s := '', l := this.Length
			loop l - 1
				s .= this[A_Index] c
			return l ? s this[l] : s
		}
		static _Map(this, fn) {
			t := []
			for i in this
				t.Push(fn(i))
			return t
		}
		static _Sort(this, fn) {
			s := '', c := [this*]
			loop this.Length
				s .= ',' A_Index
			s := Sort(LTrim(s, ','), 'D,', (a, b, *) => fn(this[a], this[b]))
			for i in StrSplit(s, ',')
				this[A_Index] := c[i]
			return this
		}
	}
}

ExtractMCode(msvc_obj, import_dlls := [], api_rename := Map(), debug := true) {
	static IMAGE_REL_I386_DIR32 := 0x6
	static IMAGE_REL_AMD64_REL32 := 0x4
	sections := Map(), exports := msvc_obj.Exports
	if !exports.Length
		exports.Push(msvc_obj.Functions.__Enum().Bind(&_)*)
	for , symbol in exports
		msvc_obj.CollectSectionDependencies(sections, symbol.Section)

	if sections.Has(0) && (imports := sections.Delete(0)).Count {
		dlls := Map('?', []), dlln := Map(), dllet := Map(), ptrsize := msvc_obj.Is32Bit ? 4 : 8
		thunk := {
			Align: ptrsize,
			; Data: COFFReader.Data(),
			Name: '.text',
			Index: 65535,
			RelocationCount: 0,
			Relocations: [],
			Symbols: []
		}
		for n in import_dlls
			dllet[n] := GetExportTable(n, msvc_obj.Is64Bit), dlln[n] := 0, dlls[n] := []

		has_export := Map.Prototype.Has
		symbols := [imports*].Sort((a, b) => imports[b] - imports[a])
		get_name := api_rename.Get.Bind(api_rename, , 0), is32 := msvc_obj.Is32Bit
		resolved := Map(), RELOCTYPE := msvc_obj.Is32Bit ? IMAGE_REL_I386_DIR32 : IMAGE_REL_AMD64_REL32
next:
		for fn in symbols {
			if isimp := fn.Name ~= '^__imp_'
				fnn := fn.Name := SubStr(fn.Name, 7)
			else fnn := fn.Name
			if resolved.Has(fnn)
				continue
			resolved[fnn] := 1
			if !isimp {
				imports[_ := fn.Clone()] := imports.Delete(fn)
				fn.Value := thunk.Symbols.Length * 6
				thunk.RelocationCount++
				thunk.Relocations.Push({
					Address: fn.Value + 2,
					Type: RELOCTYPE,
					Symbol: _
				})
				thunk.Symbols.Push(fn)
				fn.Section := thunk
				fn := _
				; void __cdecl operator delete(void*, size_t) -> void __cdecl operator delete(void*)
				if ptrsize = 8 {
					if fnn == '??3@YAXPEAX_K@Z'
						fnn := fn.Name := '??3@YAXPEAX@Z'
				} else if fnn == '??3@YAXPAXI@Z'
					fnn := fn.Name := '??3@YAXPAX@Z'
			}
			for n in import_dlls
				if has_export(et := dllet[n], fnn) ||
					; 32bit, __stdcall: fnname -> _fnname, __cdecl: fnname -> _fnname@n
					(is32 && RegExMatch(fnn, '^_(\S+?)(@\d+)?$', &m) && has_export(et, m := m[1]) ||
						(m := get_name(fnn)) && has_export(et, m)) && fn.Name := m {
							dlls[n].Push(fn), dlln[n] += imports[fn]
							continue next
				}
			dlls['?'].Push(fn)
		}

		imports := '', symbols := [], i := 0
		import_dlls := import_dlls.Filter(a => dlln[a]).Sort((a, b) => dlln[b] - dlln[a])
		dlls['?'].Length && import_dlls.Push('?')

		for n in import_dlls {
			imports .= n ':'
			for symbol in dlls[n]
				imports .= symbol.Name ',', symbols.Push(symbol), symbol.Value := ptrsize * i++
			imports .= '|'
		}

		buf := Buffer(ptrsize * i, 0)
		imports := SubStr(StrReplace(imports, ',|', '|'), 1, -1)
		sections[0] := import_section := {
			Align: ptrsize,
			Data: COFFReader.Data(buf.Ptr, buf.Size, buf),
			Name: '.rdata',
			Index: 0,
			RelocationCount: 0,
			Relocations: [],
			Symbols: symbols
		}
		if i := thunk.Symbols.Length {
			buf := Buffer(i * 6, 0)
			thunk.Data := COFFReader.Data(ptr := buf.Ptr, buf.Size, buf)
			loop i
				ptr := NumPut('ushort', 0x25ff, ptr) + 4	; jmp: ff 25 00 00 00 00
			sections[-1] := thunk
		}
	}

	sections := [sections.__Enum().Bind(&_)*].Sort((a, b) => StrCompare(b.Name, a.Name) || a.Index - b.Index)
	mergedSection := {
		Name: '',
		Data: COFFReader.Data(),
		RelocationCount: 0,
		Relocations: [],
		RelocationsOffset: 0,
		Symbols: [],
		VirtualAddress: 0,
		VirtualSize: 0
	}

	msvc_obj.MergeSections(mergedSection, sections*)
	buf := Buffer(mergedSection.Data.Length())
	if !buf.Size
		throw Error('code is empty')
	mergedSection.Data.Coalesce(basePtr := buf.Ptr)
	mergedSection.Data := COFFReader.Data(basePtr, buf.Size, buf)
	relocs := msvc_obj.DoStaticRelocations(mergedSection)

	; The header is appended to the first non-zero at the end with flashback.
	; .export: N, offset1, ..., offsetN; .import: N, extry offset; .reloc: offset1, offset2, ..., 0
	; Integer compression format
	; 1byte: 0xxxxxxx; 2byte: 10xxxxxx xxxxxxxx; 4byte: 11xxxxxx xxxxxxxx xxxxxxxx xxxxxxxx
	headers := [], obj := {}
	if exports.Length = 1 && !exports[1].Value		; Only an export and offset = 0
		headers.Push(0)
	else headers.Push(exports.Length, exports.Map(v => v.Value)*)
	obj.export := exports.Map(v => v.Name).Join(',')
	if IsSet(import_section)
		obj.import := imports, headers.Push(import_section.Symbols.Length, import_section.Offset)
	else headers.Push(0)
	headers.Push(relocs*), header_buf := compress_headers(headers)
	p := basePtr + buf.Size, lp := Max(p - header_buf.Size, basePtr)
	while p > lp && !NumGet(p - 1, 'uchar')
		p--
	offset := p - basePtr
	if expand := Max(header_buf.Size + offset - buf.Size, 0)
		buf.Size += expand
	DllCall('RtlMoveMemory', 'ptr', buf.Ptr + offset, 'ptr', header_buf, 'uptr', header_buf.Size)

	; LZ format compression code, if the compression rate is low, it will not be compressed.
	compress := lz_compress(buf), hex_size := Format('{:x}', buf.Size)
	if (buf.Size - compress.Size) * 1.3333 <= StrLen(hex_size) + 1
		compress := '', obj.code := base64_encode(buf)
	else obj.code := hex_size ',' base64_encode(compress)

	if debug {
		stdout := FileOpen('*', 'w')
		stdout.Write(Format('BASE64{}:`n', compress && '(LZCompress)') obj.code)
		stdout.Write('`n`nEXPORT OFFSETS:`n' exports.Map(v => v.Value '`t' v.Name).Join('`n'))
		stdout.Write(Format('`n`n{}BIT CODE WITH {} BYTE HEADER:`n', 32 << msvc_obj.Is64Bit, header_buf.Size) base64_encode(buf, 0xb))
		(relocs.Length) && stdout.Write('`nRELOCATION OFFSETS:`n' relocs.Join(', '))
		if IsSet(import_section) {
			stdout.Write('`n`nIMPORT TABLE ENTRY OFFSET: ' import_section.Offset)
			stdout.Write('`n' StrReplace(imports, '|', '`n') '`n')
			if dlls['?'].Length {
				stdout.Write('`nUNKNOWN IMPORT SYMBOLS:')
				for symbol in dlls['?']
					n := symbol.Name, stdout.Write('`n' n (SubStr(n, 1, 1) = '?' ? (' `t' UnDecorateSymbolName(n)) : ''))
			}
		}
		stdout.Read(0), stdout.Close()
	}

	return { %32 << msvc_obj.Is64Bit%: ObjOwnPropCount(obj) = 1 ? obj.code : obj }

	static base64_encode(Buf, Codec := 0x40000001) {
		p := Buf, s := Buf.Size
		if DllCall('crypt32\CryptBinaryToString', 'Ptr', p, 'UInt', s, 'UInt', Codec, 'Ptr', 0, 'Uint*', &sz := 0) &&
			(VarSetStrCapacity(&str, sz << 1), DllCall('crypt32\CryptBinaryToString', 'Ptr', p, 'UInt', s, 'UInt', Codec, 'Str', str, 'Uint*', &sz))
			return (VarSetStrCapacity(&str, -1), str)
	}
	static compress_headers(ns) {
		ps := [0], sz := 1, l := ns.Length
		loop l {
			n := ns[l--]
			if n < 0x80
				sz++, ps.Push(n)
			else if n < 0x4000
				sz += 2, ps.Push(n & 0xff, n >> 8 | 0x80)
			else if n < 0x40000000
				sz += 4, ps.Push(n & 0xff, n >> 8 & 0xff, n >> 16 & 0xff, n >> 24 | 0xc0)
			else throw ValueError('out of range')
		}
		buf := Buffer(sz), p := buf.Ptr
		for n in ps
			p := NumPut('uchar', n, p)
		return buf
	}
	static lz_compress(data) {
		DllCall('ntdll\RtlGetCompressionWorkSpaceSize', 'ushort', 0x102, 'uint*', &cbwsSize := 0, 'uint*', &cfwsSize := 0)
		DllCall('ntdll\RtlCompressBuffer', 'ushort', 0x102, 'ptr', data, 'uint', data.Size,
			'ptr', cb := Buffer(data.Size << 1), 'uint', cb.Size,
			'uint', cfwsSize, 'uint*', &fcSize := 0, 'ptr', Buffer(cbwsSize))
		cb.Size := fcSize
		return cb
	}
	static UnDecorateSymbolName(Decorated) {
		if (size := DllCall('imagehlp\UnDecorateSymbolName', 'astr', Decorated, 'ptr', UnDecorated := Buffer(2048, 0), 'uint', 2048, 'uint', 0, 'uint'))
			return StrGet(UnDecorated, size, 'cp0')
		return Decorated
	}
}

GetExportTable(DllPath, Is64bit := true) {
	static LocSignatureOff := 0x3c, SizeOfCoffHdr := 20, SizeOfSectionHdr := 40, SizeOfSignature := 4
	SplitPath(DllPath := SearchDllPath(DllPath, !Is64bit), &FileName, , &ext)
	Exports := Map(), Exports.Name := ext = 'dll' && !InStr(FileName, '.', , , 2) ? SubStr(FileName, 1, -4) : FileName

	DllFile := FileOpen(DllPath, 'r')
	if DllFile.Pos || DllFile.ReadUShort() != 0x5a4d ||
		(DllFile.Pos := LocSignatureOff, DllFile.Pos := DllFile.ReadUInt(), DllFile.ReadUInt() != 0x4550)
		throw Error('not a valid DLL or EXE file')

	DllFile.RawRead(RawBytes := Buffer(SizeOfCoffHdr))
	Machine := NumGet(RawBytes, 0, 'ushort')
	if Machine != 0x014c && Machine != 0x8664
		throw Error('wrong CPU type')
	NumberOfSections := NumGet(RawBytes, 2, 'ushort')
	SizeOfOptionalHeader := NumGet(RawBytes, 16, 'ushort')
	Characteristics := NumGet(RawBytes, 18, 'ushort')
	if !((Characteristics & 0x2000) || (Characteristics & 0x3))
		throw Error('not a valid DLL or EXE file')

	DllFile.RawRead(RawBytes := Buffer(SizeOfOptionalHeader))
	Magic := NumGet(RawBytes, 0, 'ushort')
	if !Is64bit = (Magic = 0x020b)
		throw TargetError()
	OffSet := 92 + (Is64bit && 16)
	SizeOfImage := NumGet(RawBytes, 56, 'uint')
	if (NumberOfRvaAndSizes := NumGet(RawBytes, OffSet + 0, 'uint')) < 1
		|| (ExportAddr := NumGet(RawBytes, OffSet + 4, 'uint')) < 1
		|| (ExportSize := NumGet(RawBytes, OffSet + 8, 'uint')) < 1
		return Exports

	DllFile.RawRead(RawBytes := Buffer(SizeOfSectionHdr * NumberOfSections))
	ImageData := Buffer(SizeOfImage, 0), OffSet := 0
	loop NumberOfSections {
		VirtualAddress := NumGet(RawBytes, OffSet + 12, 'uint'), SizeOfRawData := NumGet(RawBytes, OffSet + 16, 'uint')
		PointerToRawData := NumGet(RawBytes, OffSet + 20, 'uint'), OffSet += SizeOfSectionHdr
		DllFile.Pos := PointerToRawData, DllFile.RawRead(ImageData.Ptr + VirtualAddress, SizeOfRawData)
	}

	ImageBase := ImageData.Ptr, EndOfSection := ExportAddr + ExportSize, Addr := ExportAddr + ImageBase
	FuncCount := NumGet(Addr + 0x14, 'uint')
	NameCount := NumGet(Addr + 0x18, 'uint')
	FuncTblPtr := ImageBase + NumGet(Addr + 0x1c, 'uint')
	NameTblPtr := ImageBase + NumGet(Addr + 0x20, 'uint')
	OrdTblPtr := ImageBase + NumGet(Addr + 0x24, 'uint')

	loop NameCount {
		NamePtr := NumGet(NameTblPtr, 'uint'), Ordinal := NumGet(OrdTblPtr, 'ushort')
		FnAddr := NumGet(FuncTblPtr + (Ordinal * 4), 'uint'), NameTblPtr += 4, OrdTblPtr += 2
		EntryPt := FnAddr > ExportAddr && FnAddr < EndOfSection ? StrGet(ImageBase + FnAddr, 'cp0') : FnAddr
		Exports[StrGet(ImageBase + NamePtr, 'cp0')] := EntryPt
	}
	return Exports
	SearchDllPath(path, is32bit := false) {
		SplitPath(StrReplace(path, '/', '\'), , &dir, &ext, &name)
		ext := '.' (ext || 'dll'), dir && dir .= '\'
		if DllCall('SearchPath', 'ptr', 0, 'str', dir name ext, 'ptr', 0, 'uint', 2048, 'ptr', b := Buffer(4096), 'ptr', 0) {
			path1 := StrGet(b), path := dir name ext
			if is32bit && A_Is64bitOS && path = SubStr(path2 := StrReplace(path1, A_WinDir '\System32\', A_WinDir '\SysWOW64\'), -StrLen(path))
				return path2
			return path1
		}
		if FileExist(path1 := dir RegExReplace(name, '(32|64)$', is32bit ? '32' : '64') ext)
			return path1
		if dir {
			if FileExist(path1 := RegExReplace(dir, 'i)(?<=(^|\\))x(86|64)(?=\\)', is32bit ? 'x86' : 'x64') name ext)
				return path1
			if FileExist(path1 := RegExReplace(dir, 'i)(?<=(^|\\))(32|64)(?=bit\\)', is32bit ? '32' : '64') name ext)
				return path1
		}
		return path
	}
}
