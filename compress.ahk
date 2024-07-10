/************************************************************************
 * @description Read and write gzip/zstd data using libarchive
 * @author thqby
 * @date 2024/07/11
 * @version 1.0.1
 ***********************************************************************/

class compress {
	/**
	 * Decompress the gzip/zstd data
	 * @param {Buffer|Integer} data Data to be decompressed
	 * @param {Integer} size Data size
	 * @param {'gzip'|'zstd'} filter
	 * @returns {Buffer}
	 */
	static decode(data, size?, filter := 'zstd') {
		gz := this.reader()
		r := gz.read_support_filter_%filter%() || gz.read_support_format_raw() ||
			gz.read_open_memory(data, size ?? data.size) || gz.read_next_header(0)
		if r < 0
			throw Error(gz.error_string())
		buf := Buffer()
		while !r := gz.read_data_block(&data := 0, &size := 0, &offset := 0)
			buf.Size += size, DllCall('RtlMoveMemory', 'ptr', buf.Ptr + offset, 'ptr', data, 'uptr', size)
		if r > 0
			return buf
		throw Error(gz.error_string())
	}
	/**
	 * Compress data into gzip/zstd
	 * @param {Buffer|Integer} data Data that needs to be compressed
	 * @param {Integer} size Data size
	 * @param {'gzip'|'zstd'} filter
	 * @param {Integer} compression_level 0~9 compression levels, up to 9, with the highest compression rate but the slowest compression speed
	 * @returns {Buffer}
	 */
	static encode(data, size?, filter := 'zstd', compression_level?) {
		size := size ?? data.size, gz := this.writer(), buf := Buffer((bufsize := size + 56) + 8)	; Reserved 56 + 8 bytes
		pused := buf.Ptr + bufsize, entry := this.entry(), entry.entry_set_filetype(32768)	; IFREG
		r := gz.write_add_filter_%filter%() || gz.write_set_format_raw() ||
			IsSet(compression_level) && gz.write_set_options('compression-level=' compression_level) ||
			gz.write_open_memory(buf, bufsize, pused := buf.Ptr + bufsize) ||
			gz.write_header(entry) || (gz.write_data(data, size), gz.write_close())
		if r < 0
			throw Error(gz.error_string())
		if !(buf.Size := NumGet(pused, 'uptr'))
			throw Error('Failed')
		return buf
	}
	static __New() {
		#DllLoad archiveint.dll
		mod := DllCall('GetModuleHandle', 'str', 'archiveint', 'ptr'), is_32bit := A_PtrSize = 4
		get_proc_addr := !is_32bit ? (name, *) => DllCall('GetProcAddress', 'ptr', mod, 'astr', 'archive_' name, 'ptr')
			: (name, argsize) => DllCall('GetProcAddress', 'ptr', mod, 'astr', '_archive_' name '@' argsize, 'ptr')
		base_reader := this.DeleteProp('Prototype'), base_writer := base_reader.Clone(), base_entry := base_reader.Clone()
		read_new := write_new := entry_new := 0
		for k, v in Map('reader', 'read', 'writer', 'write', 'entry', 'entry') {
			(base := base_%k%).__Class := 'gzip.' k, %v%_new := DllCall.Bind(get_proc_addr(v '_new', 0))
			base.DefineProp('__Delete', { call: DllCall.Bind(get_proc_addr(v '_free', 4), 'ptr') })
			this.DefineProp(k, { call: ((base, new, *) => { base: base, ptr: new() }).Bind(base, %v%_new) })
		}

		; load archive_read_xx
		base := base_reader
		load('error_string', 'ptr', , 'astr')
		load('read_data_block', 'ptr', , 'ptr*', , 'uptr*', , 'int64*', unset)
		load('read_next_header', 'ptr', , 'ptr*', unset)
		load('read_open_memory', 'ptr', , 'ptr', , 'uptr', unset)
		load('read_support_filter_gzip', 'ptr', unset)
		load('read_support_filter_zstd', 'ptr', unset)
		load('read_support_format_raw', 'ptr', unset)

		; load archive_write_xx
		base := base_writer
		base.DefineProp('error_string', { call: base_reader.error_string })
		load('write_add_filter_gzip', 'ptr', unset)
		load('write_add_filter_zstd', 'ptr', unset)
		load('write_close', 'ptr', unset)
		load('write_data', 'ptr', , 'ptr', , 'uptr', unset)
		load('write_header', 'ptr', , 'ptr', unset)
		load('write_open_memory', 'ptr', , 'ptr', , 'uptr', , 'ptr', unset)
		load('write_set_format_raw', 'ptr', unset)
		load('write_set_options', 'ptr', , 'astr', unset)

		; load archive_entry_xx
		base := base_entry
		load('entry_set_filetype', 'ptr', , 'ushort', unset)

		load(name, args*) {
			argsize := 0
			loop is_32bit && (args.Length >> 1)
				argsize += args[A_Index * 2 - 1] = 'int64' ? 8 : 4
			base.DefineProp(name, { call: DllCall.Bind(p := get_proc_addr(name, argsize), args*) })
			if !p
				throw Error('nonexistent function', , name)
		}
	}
}