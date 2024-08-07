/************************************************************************
 * @description Use [libarchive](https://github.com/libarchive/libarchive) to read and write archives in many formats.
 * After Windows 10 insider build 17063, libarchive is built-in.
 * @file archive.ahk
 * @author thqby
 * @date 2024/04/09
 * @version 1.0.0
 ***********************************************************************/

class archive {
	class reader extends archive.base {
		/**
		 * Open the archive.
		 * @param {String | Buffer} target the path of archive to be read, or the buffer of archive.
		 * @param {Integer} size the size of buffer.
		 * @param {String | Array<String>} password password used to decrypt archive data
		 * @param {String} options options is a comma-separated list of options.
		 * - `option=value` The option/value pair will be provided to every module.
		 * - `option` The option will be provided to every module with a value of 1.
		 * - `!option` The option will be provided to every module with a NULL value.
		 * {@link https://github.com/libarchive/libarchive/blob/master/libarchive/archive_read_set_options.3}
		 */
		__New(target, size := 0, password?, options := '') {
			if !this.ptr := ptr := DllCall(archive['read_new'], 'ptr')
				Throw MemoryError()
			DllCall(archive['read_support_filter_all'], 'ptr', ptr)
			DllCall(archive['read_support_format_all'], 'ptr', ptr)
			DllCall(archive['read_support_format_raw'], 'ptr', ptr)
			if !InStr(options, 'hdrcharset')	; maybe this option is not handled
				DllCall(archive['read_set_option'], 'ptr', ptr, 'ptr', 0, 'astr', 'hdrcharset', 'astr', 'cp' DllCall('GetACP'))
			if options
				this.SUCCEEDED(DllCall(archive['read_set_options'], 'ptr', ptr, 'astr', options))
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
			this.DefineProp('entry', { value: { base: archive.entry.Prototype } })
		}

		__Delete() => this.ptr && DllCall(archive['read_free'], 'ptr', this)

		_read_data_block(&data, &size, &offset) {
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

		/** @returns {archive.entry} */
		_read_next_header() {
			if !r := DllCall(archive['read_next_header'], 'ptr', this, 'ptr*', entry := this.entry)
				return entry
			if r < 0
				this.SUCCEEDED(r)
		}

		/**
		 * Enumerate each item entry in the archive, and then read or extract them.
		 * 
		 * **NOTE:** Each item in the archive can be read only once.
		 * @returns {Enumerator<archive.entry>}
		 */
		__Enum(*) => (&entry, *) => entry := this._read_next_header()

		/**
		 * Enumerate each item entry in the archive, and then read or extract them.
		 * 
		 * **NOTE:** Each item in the archive can be read only once.
		 * @param {(this, entry) => Integer} fn a callbak function, ends the enumeration when true is returned.
		 */
		for_each(fn) {
			while e := this._read_next_header()
				if fn(this, e)
					break
		}

		/**
		 * Reads item data from the archive into the buffer.
		 * @returns {Buffer | void}
		 * @example <caption>read to memory</caption>
		 * m := Map()
		 * for e in a := archive.reader(path)
		 *   (e.filetype = 'IFREG') && m[e.pathname] := a.read_data()
		 */
		read_data() {
			entry := this.entry
			if !bptr := entry.ptr || this._read_next_header() && entry.ptr
				Throw Error('End of read')
			this.entry := { base: archive.entry.Prototype }
			if !bsize := DllCall(archive['entry_size'], 'ptr', bptr, 'int64') && entry.filetype == 'IFDIR'
				return
			read_data_block := archive['read_data_block']
			bptr := (buf := Buffer(bsize)).Ptr, data := size := offset := 0
			while !r := DllCall(read_data_block, 'ptr', this, 'ptr*', &data, 'uptr*', &size, 'int64*', &offset) {
				if !size
					continue
				if (total := offset + size) > bsize
					buf.Size := total, bptr := buf.Ptr, bsize := buf.Size
				DllCall('RtlMoveMemory', 'ptr', bptr + offset, 'ptr', data, 'uptr', size)
			}
			if r > 0
				return buf
			this.SUCCEEDED(r)
		}

		/**
		 * Extract item from the archive to disk.
		 * @param {String} dest the name of the destination, which is assumed to be in A_WorkingDir if an absolute path isn't specified.
		 */
		extract(dest := '') {
			entry := this.entry
			if !bptr := entry.ptr || this._read_next_header() && entry.ptr
				Throw Error('End of read')
			this.entry := { base: archive.entry.Prototype }
			if dest {
				if dest ~= '[/\\]$' || InStr(FileExist(dest), 'd') && dest .= '/'
					entry.pathname := dest entry.pathname
				else entry.pathname := dest
			}
			this.SUCCEEDED(DllCall(archive['read_extract'], 'ptr', this, 'ptr', entry, 'int', 0x44))
		}

		/**
		 * Extract all items from the archive to disk.
		 * @param {String} dest_dir the name of the destination directory, which is assumed to be in A_WorkingDir if an absolute path isn't specified.
		 * @example <caption>extract all from archive</caption>
		 * archive.reader(path).extract_all(A_ScriptDir)
		 */
		extract_all(dest_dir := '') {
			if dest_dir
				dest_dir := RegExReplace(dest_dir, '[/\\]?$', '/')
			while this._read_next_header()
				this.extract(dest_dir)
		}

		/**
		 * After reading the first item entry, you can get the format name of the archive file.
		 * @returns {String} the format name of archive.
		 * @example <caption>get archive format name</caption>
		 * (a := archive.reader(path))._read_next_header()
		 * MsgBox(a.format_name)
		 */
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

	class writer extends archive.base {
		static Prototype.is_opened := false
		/**
		 * Create an archive and then add files or folders.
		 * @param {String} target the path of archive to be written.
		 * @param {String} password password used to encrypt archive data
		 * @param {String} options options is a comma-separated list of options.
		 * - `option=value` The option/value pair will be provided to every module.
		 * - `option` The option will be provided to every module with a value of 1.
		 * - `!option` The option will be provided to every module with a NULL value.
		 * {@link https://github.com/libarchive/libarchive/blob/master/libarchive/archive_write_set_options.3}
		 * @param {Integer} mapping_size If this value is set, an archive will be created in memory using `CreateFileMappingW`,
		 * and the generated archive size cannot be greater than this set value.
		 * Call {@linkcode archive.writer#close()} to get the archive buffer after creation.
		 */
		__New(target, password?, options := '', mapping_size := 0) {
			if !this.ptr := ptr := DllCall(archive['write_new'], 'ptr')
				Throw MemoryError()
			this.SUCCEEDED(DllCall(archive['write_set_format_filter_by_ext'], 'ptr', ptr, 'astr', target))
			if IsSet(password) {
				this.SUCCEEDED(DllCall(archive['write_set_passphrase'], 'ptr', ptr, 'astr', password))
				if !InStr(options, 'encryption')
					options .= ',encryption'
			}
			if !InStr(options, 'hdrcharset')	; maybe this option is not handled
				DllCall(archive['write_set_option'], 'ptr', ptr, 'ptr', 0, 'astr', 'hdrcharset', 'astr', 'cp' DllCall('GetACP'))
			if options
				this.SUCCEEDED(DllCall(archive['write_set_options'], 'ptr', ptr, 'astr', options))
			if !mapping_size
				this.SUCCEEDED(DllCall(archive['write_open_filename_w'], 'ptr', ptr, 'str', target))
			else {
				mapping_size := Max(mapping_size, 0x40000) + A_PtrSize
				if !memorymap := DllCall('CreateFileMappingW', 'ptr', -1, 'ptr', 0, 'uint', 4, 'uint', mapping_size >> 32, 'uint', mapping_size & 0xffffffff, 'ptr', 0, 'ptr')
					Throw OSError()
				free := [{ __Delete: (*) => DllCall('CloseHandle', 'ptr', memorymap) }]
				if !destination := DllCall('MapViewOfFile', 'ptr', memorymap, 'uint', 0xff001f, 'uint', 0, 'uint', 0, 'uptr', 0, 'ptr')
					Throw OSError()
				free.InsertAt(1, { __Delete: (*) => DllCall('UnmapViewOfFile', 'ptr', destination) })
				this.SUCCEEDED(DllCall(archive['write_open_memory'], 'ptr', ptr, 'ptr', destination + A_PtrSize, 'uptr', mapping_size - A_PtrSize, 'ptr', destination))
				this.DefineProp('close', { call: close })
				close(this) {
					this.DeleteProp('close'), this.close(), buf := Buffer(used_size := NumGet(destination, 'uptr'))
					DllCall('RtlMoveMemory', 'ptr', buf, 'ptr', destination + A_PtrSize, 'uptr', used_size), free := 0
					return buf
				}
			}
			this.is_opened := true
		}

		__Delete() {
			(archive.writer.Prototype.close)(this)
			this.close()
			if this.ptr
				this.SUCCEEDED(DllCall(archive['write_free'], 'ptr', this))
		}

		/**
		 * End archive write. If written to memory, this buffer is returned.
		 * @returns {Buffer | void}
		 */
		close() {
			if this.is_opened
				this.is_opened := false, this.SUCCEEDED(DllCall(archive['write_close'], 'ptr', this))
		}

		/**
		 * Add the source to the archive.
		 * @param {String | Buffer} source The name of a single file or folder,
		 * or a wildcard pattern such as `e:\1\*.txt`.
		 * It can also be buffer-like data.
		 * @param {String} dest dest is considered the specified directory when it ends with a slash.
		 * otherwise specify the pathname when the source is a single file or folder.
		 * @returns {this}
		 */
		add(source, dest := '') {
			dest := String(dest)
			write_data := archive['write_data']
			write_header := archive['write_header']
			if HasProp(source, 'Ptr') {
				e := archive.entry(this)
				e.pathname := dest, e.filetype := 'IFREG', e.size := source.Size
				e.atime := e.btime := e.ctime := e.mtime := DateDiff('', '19700101080000', 'Seconds')
				if 0 > r := DllCall(write_header, 'ptr', this, 'ptr', e) || DllCall(write_data, 'ptr', this, 'ptr', source, 'uptr', source.Size)
					this.SUCCEEDED(r)
				return this
			}
			if !disk := DllCall(archive['read_disk_new'], 'ptr')
				Throw MemoryError()
			free := [{ __Delete: (*) => DllCall(archive['read_free'], 'ptr', disk) }]
			this.SUCCEEDED(DllCall(archive['read_disk_open_w'], 'ptr', disk, 'wstr', source))
			free.InsertAt(1, { __Delete: (*) => DllCall(archive['read_close'], 'ptr', disk) })
			e := { base: archive.entry.Prototype }
			data := size := offset := r := 0
			read_next_header := archive['read_next_header']
			read_data_block := archive['read_data_block']
			read_disk_descend := archive['read_disk_descend']
			SplitPath(source := StrReplace(source, '/', '\'), &fn, &dir), tl := StrLen(dir) + 2, fnl := StrLen(fn) + 1
			if !dest
				trim_name := (n) => SubStr(n, tl)
			else if dest ~= '[/\\]$' || InStr(FileExist(dest), 'd') && dest .= '/'
				trim_name := (n) => dest SubStr(n, tl)
			else
				trim_name := (n) => (n := SubStr(n, tl), InStr(n, fn) = 1 && n := dest SubStr(n, fnl), n)
			while !r := DllCall(read_next_header, 'ptr', disk, 'ptr*', e) {
				e.pathname := trim_name(e.pathname)
				if 0 > r := DllCall(write_header, 'ptr', this, 'ptr', e)
					this.SUCCEEDED(r)
				switch e.filetype {
					case 'IFDIR':
						r := DllCall(read_disk_descend, 'ptr', disk)
					case 'IFREG':
						while !r := DllCall(read_data_block, 'ptr', disk, 'ptr*', &data, 'uptr*', &size, 'int64*', &offset)
							if -20 > r := DllCall(write_data, 'ptr', this, 'ptr', data, 'uptr', size)
								break
				}
			}
			if r < 0
				this.SUCCEEDED(r)
			return this
		}

		format_name => DllCall(archive['format_name'], 'ptr', this, 'astr')
	}

	class entry extends archive.base {
		static Prototype._owner := 0, Prototype.ptr := 0
		__New(a := 0) {
			if !this.ptr := this._owner := DllCall(archive['entry_new2'], 'ptr', a, 'ptr')
				Throw MemoryError()
		}
		__Delete() => this._owner && DllCall(archive['entry_free'], 'ptr', this)
		filetype {
			get {
				static tps := Map(0, 'SYMLINK_TYPE_UNDEFINED', 1, 'SYMLINK_TYPE_FILE', 2, 'SYMLINK_TYPE_DIRECTORY', 61440, 'IFMT', 32768, 'IFREG', 40960, 'IFLNK', 49152, 'IFSOCK', 8192, 'IFCHR', 24576, 'IFBLK', 16384, 'IFDIR', 4096, 'IFIFO')
				return tps[DllCall(archive['entry_filetype'], 'ptr', this, 'ushort')]
			}
			set {
				static tps := Map('SYMLINK_TYPE_UNDEFINED', 0, 'SYMLINK_TYPE_FILE', 1, 'SYMLINK_TYPE_DIRECTORY', 2, 'IFMT', 61440, 'IFREG', 32768, 'IFLNK', 40960, 'IFSOCK', 49152, 'IFCHR', 8192, 'IFBLK', 24576, 'IFDIR', 16384, 'IFIFO', 4096)
				DllCall(archive['entry_set_filetype'], 'ptr', this, 'ushort', tps.Get(Value, Value))
			}
		}
		is_data_encrypted {
			get => DllCall(archive['entry_is_data_encrypted'], 'ptr', this)
			set => DllCall(archive['entry_set_is_data_encrypted'], 'ptr', this, 'int', Value)
		}
		is_encrypted => DllCall(archive['entry_is_encrypted'], 'ptr', this)
		is_metadata_encrypted {
			get => DllCall(archive['entry_is_metadata_encrypted'], 'ptr', this)
			set => DllCall(archive['entry_set_is_metadata_encrypted'], 'ptr', this, 'int', Value)
		}
		pathname {
			get => DllCall(archive['entry_pathname_w'], 'ptr', this, 'wstr')
			set => DllCall(archive['entry_copy_pathname_w'], 'ptr', this, 'wstr', Value)
		}
		sourcepath {
			get => DllCall(archive['entry_sourcepath_w'], 'ptr', this, 'wstr')
			set => DllCall(archive['entry_copy_sourcepath_w'], 'ptr', this, 'wstr', Value)
		}
		hardlink {
			get => DllCall(archive['entry_hardlink_w'], 'ptr', this, 'wstr')
			set => DllCall(archive['entry_copy_hardlink_w'], 'ptr', this, 'wstr', Value)
		}
		symlink {
			get => DllCall(archive['entry_symlink_w'], 'ptr', this, 'wstr')
			set => DllCall(archive['entry_copy_symlink_w'], 'ptr', this, 'wstr', Value)
		}
		symlink_type {
			get => DllCall(archive['entry_symlink_type'], 'ptr', this)
			set => DllCall(archive['entry_set_symlink_type'], 'ptr', this, 'int', Value)
		}
		size {
			get => DllCall(archive['entry_size'], 'ptr', this, 'int64')
			set => DllCall(archive['entry_set_size'], 'ptr', this, 'int64', Value)
		}
		size_is_set => DllCall(archive['entry_size_is_set'], 'ptr', this)
		nlink {
			get => DllCall(archive['entry_nlink'], 'ptr', this, 'uint')
			set => DllCall(archive['entry_set_nlink'], 'ptr', this, 'uint', Value)
		}
		mode {
			get => DllCall(archive['entry_mode'], 'ptr', this, 'ushort')
			set => DllCall(archive['entry_mode'], 'ptr', this, 'ushort', Value)
		}
		atime_is_set => DllCall(archive['entry_atime_is_set'], 'ptr', this)
		btime_is_set => DllCall(archive['entry_birthtime_is_set'], 'ptr', this)
		ctime_is_set => DllCall(archive['entry_ctime_is_set'], 'ptr', this)
		mtime_is_set => DllCall(archive['entry_mtime_is_set'], 'ptr', this)
		atime {
			get => DllCall(archive['entry_atime'], 'ptr', this, 'int64')
			set => DllCall(archive['entry_set_atime'], 'ptr', this, 'int64', Value, 'int', 0)
		}
		btime {
			get => DllCall(archive['entry_birthtime'], 'ptr', this, 'int64')
			set => DllCall(archive['entry_set_birthtime'], 'ptr', this, 'int64', Value, 'int', 0)
		}
		ctime {
			get => DllCall(archive['entry_ctime'], 'ptr', this, 'int64')
			set => DllCall(archive['entry_set_ctime'], 'ptr', this, 'int64', Value, 'int', 0)
		}
		mtime {
			get => DllCall(archive['entry_mtime'], 'ptr', this, 'int64')
			set => DllCall(archive['entry_set_mtime'], 'ptr', this, 'int64', Value, 'int', 0)
		}
	}

	#DllLoad archiveint.dll
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

	class base {
		SUCCEEDED(r := 0) {
			switch r {
				case 0:		; OK
				case 1:		; EOF
				case -10:	; RETRY
				case -20:	; WARN
					OutputDebug(DllCall(archive['error_string'], 'ptr', this, 'astr'))
				case -25, -30:	; FAILED, FATAL
					Throw(Error(DllCall(archive['error_string'], 'ptr', this, 'astr')))
			}
		}
	}
}
