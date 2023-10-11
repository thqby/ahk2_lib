/************************************************************************
 * @description Use [libarchive](https://github.com/libarchive/libarchive) to read and write archives in many formats.
 * After Windows 10 insider build 17063, libarchive is built-in.
 * @file archive.ahk
 * @author 
 * @date 2023/09/30
 * @version 0.0.0
 ***********************************************************************/

class archive {
	#DllLoad archiveint.dll
	static Prototype.ptr := 0
	static __New() {
		if this != archive
			return
		this.DeleteProp('__New'), this.DeleteProp('Prototype'), this.DefineProp('__Item', { value: m := Map() })
		trim := A_PtrSize = 8 ? s => SubStr(s, 9) : s => SubStr(s, t1 := InStr(s, '_', , 2) + 1, (t2 := InStr(s, '@')) ? t2 - t1 : unset)
		for k, v in get_module_exports(DllCall('GetModuleHandle', 'str', 'archiveint', 'ptr'))
			m[trim(k)] := v
		this.DefineProp('version', { value: DllCall(archive['version_details'], 'astr') })
		get_module_exports(mod) {
			if !mod
				mod := DllCall('GetModuleHandleW', 'ptr', 0, 'ptr')
			else if (DllCall('GetModuleFileNameW', 'ptr', mod, 'ptr*', 0, 'uint', 1), A_LastError = 126)
				Throw OSError()
			entry_export := mod + NumGet(mod, data_directory_offset := NumGet(mod, 60, 'uint') + 104 + A_PtrSize * 4, 'uint')
			entry_export_end := entry_export + NumGet(mod, data_directory_offset + 4, 'uint')
			func_tbl_offset := NumGet(entry_export, 0x1c, 'uint'), name_tbl_offset := NumGet(entry_export, 0x20, 'uint')
			ordinal_tbl_offset := NumGet(entry_export, 0x24, 'uint'), exports := Map()
			loop NumGet(entry_export, 0x18, 'uint') {
				ordinal := NumGet(mod, ordinal_tbl_offset, 'ushort'), fn_ptr := mod + NumGet(mod, func_tbl_offset + ordinal * 4, 'uint')
				if entry_export <= fn_ptr && fn_ptr < entry_export_end {
					fn_name := StrSplit(StrGet(fn_ptr, 'cp0'), '.')
					fn_ptr := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', fn_name[1], 'ptr'), 'astr', fn_name[2], 'ptr')
				}
				exports[StrGet(mod + NumGet(mod, name_tbl_offset, 'uint'), 'cp0')] := fn_ptr, name_tbl_offset += 4, ordinal_tbl_offset += 2
			}
			return exports
		}
	}

	class reader extends archive {
		__New(target, size := 0, password?, codepage := 0) {
			if !this.ptr := ptr := DllCall(archive['read_new'], 'ptr')
				Throw MemoryError()
			DllCall(archive['read_support_filter_all'], 'ptr', ptr)
			DllCall(archive['read_support_format_all'], 'ptr', ptr)
			DllCall(archive['read_support_format_raw'], 'ptr', ptr)
			this.SUCCEEDED(DllCall(archive['read_set_options'], 'ptr', ptr, 'astr', 'hdrcharset=cp' (codepage || DllCall('GetACP', 'uint'))))
			if IsSet(password) {
				if !(password is Array)
					password := [password]
				for pwd in password
					this.SUCCEEDED(DllCall(archive['read_add_passphrase'], 'ptr', ptr, 'astr', pwd))
			}
			if target is String
				this.SUCCEEDED(DllCall(archive['read_open_filename_w'], 'ptr', ptr, 'wstr', target, 'uptr', 10240))
			else
				this.SUCCEEDED(DllCall(archive['read_open_memory'], 'ptr', ptr, 'ptr', target, 'uptr', size || target.size))
			entry := { base: archive.entry.Prototype }, this.DefineProp('entry', { get: (*) => entry })
		}
		__Delete() => this.ptr && DllCall(archive['read_free'], 'ptr', this)
		__Enum(*) {
			e := this.entry
			return fn
			fn(&entry := 0, *) {
				r := DllCall(archive['read_next_header'], 'ptr', this, 'ptr*', e)
				if !r
					return (entry := e, true)
				if r > 0
					return false
				Throw(Error(DllCall(archive['error_string'], 'ptr', this, 'astr')))
			}
		}
		read_data() {
			if !bptr := this.entry.ptr {
				Throw Error('no data')
				return
			}
			read_data_block := archive['read_data_block'], data := size := offset := 0
			bptr := (buf := Buffer(bsize := DllCall(archive['entry_size'], 'ptr', bptr, 'int64'))).Ptr
			while !r := DllCall(read_data_block, 'ptr', this, 'ptr*', &data, 'uptr*', &size, 'int64*', &offset) {
				if !size
					continue
				if (total := offset + size) > bsize
					buf.Size := total, bptr := buf.Ptr, bsize := buf.Size
				DllCall('RtlMoveMemory', 'ptr', bptr + offset, 'ptr', data, 'uptr', size)
			}
			this.entry.ptr := 0
			if r > 0
				return buf
			this.SUCCEEDED(r)
		}
		read_data_block(&data, &size, &offset) {
			data := size := offset := 0
			if !this.entry.ptr
				return 1
			while !(r := DllCall(archive['read_data_block'], 'ptr', this, 'ptr*', &data, 'uptr*', &size, 'int64*', &offset)) && !size
				continue
			if r = 0
				return 0
			if r > 0
				return !(this.entry.ptr := 0)
			this.SUCCEEDED(r)
		}
		save_file(filename) {
			if !bptr := this.entry.ptr {
				Throw Error('no data')
				return
			}
			f := FileOpen(filename, 'w'), off := 0
			read_data_block := archive['read_data_block']
			while !r := DllCall(read_data_block, 'ptr', this, 'ptr*', &data := 0, 'uptr*', &size := 0, 'int64*', &offset := 0) {
				if !size
					continue
				(off != offset) && f.Seek(offset)
				f.RawWrite(data, size), off := offset
			}
			this.entry.ptr := 0, f.Close()
			if r < 0
				FileDelete(filename), this.SUCCEEDED(r)
		}
		format_name => DllCall(archive['format_name'], 'ptr', this, 'astr')
		filter_names {
			get {
				names := []
				loop DllCall(archive['filter_count'], 'ptr', this, 'int')
					names.Push(DllCall(archive['filter_name'], 'ptr', this, 'int', A_Index - 1, 'astr'))
				return names
			}
		}
	}

	class entry {
		static Prototype._owner := false, Prototype.ptr := 0
		__New(archive := 0) {
			if !this.ptr := this._owner := DllCall(archive['entry_new2'], 'ptr', archive, 'ptr')
				throw MemoryError()
		}
		__Delete() => this._owner && DllCall(archive['entry_free'], 'ptr', this)
		filetype {
			get {
				static tps := Map(0, 'UNDEFINED', 1, 'FILE', 2, 'DIRECTORY', 61440, 'IFMT', 32768, 'IFREG', 40960, 'IFLNK', 49152, 'IFSOCK', 8192, 'IFCHR', 24576, 'IFBLK', 16384, 'IFDIR', 4096, 'IFIFO')
				return tps[DllCall(archive['entry_filetype'], 'ptr', this, 'ushort')]
			}
		}
		is_data_encrypted => DllCall(archive['entry_is_data_encrypted'], 'ptr', this)
		is_encrypted => DllCall(archive['entry_is_encrypted'], 'ptr', this)
		is_metadata_encrypted => DllCall(archive['entry_is_metadata_encrypted'], 'ptr', this)
		pathname =>
			; DllCall(archive['entry_pathname'], 'ptr', this, 'astr') ||
			DllCall(archive['entry_pathname_w'], 'ptr', this, 'wstr')
		sourcepath => DllCall(archive['entry_sourcepath_w'], 'ptr', this, 'wstr')
		hardlink => DllCall(archive['entry_hardlink_w'], 'ptr', this, 'wstr')
		symlink => DllCall(archive['entry_symlink_w'], 'ptr', this, 'wstr')
		symlink_type => DllCall(archive['entry_symlink_type'], 'ptr', this)
		size => DllCall(archive['entry_size'], 'ptr', this, 'int64')
		size_is_set => DllCall(archive['entry_size_is_set'], 'ptr', this)
		nlink => DllCall(archive['entry_nlink'], 'ptr', this, 'uint')
		mode => DllCall(archive['entry_mode'], 'ptr', this, 'ushort')
		atime => DllCall(archive['entry_atime'], 'ptr', this, 'int64')
		btime => DllCall(archive['entry_birthtime'], 'ptr', this, 'int64')
		ctime => DllCall(archive['entry_ctime'], 'ptr', this, 'int64')
		mtime => DllCall(archive['entry_mtime'], 'ptr', this, 'int64')
	}

	class writer {

	}

	SUCCEEDED(r := 0) {
		switch r {
			case 0:		; OK
			case 1:		; EOF
			case -10:	; RETRY
			case -20:	; WARN
				OutputDebug(DllCall(archive['error_string'], 'ptr', this, 'astr'))
			case -25, -30:	; FAILED, FATAL
				Throw (Error(DllCall(archive['error_string'], 'ptr', this, 'astr')))
		}
		return this
	}
}