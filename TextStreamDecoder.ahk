TextStreamDecoder(encoding := 0) {
	static fffd := Chr(0xfffd)
	lastChar := lastSize := 0
	switch encoding, false {
		case 'utf-8', 'utf8': encoding := 65001
		case 'utf-16', 'utf16', 'cp1200', 1200: return (lastChar := Buffer(2), u16_decoder)
		default: StrPut('', 'cp' encoding := Integer(SubStr(encoding, 1, 2) = 'cp' ? SubStr(encoding, 3) : encoding))
	}
	if !DllCall('GetCPInfo', 'uint', encoding, 'ptr', info := Buffer(18))
		Throw Error('Invalid Encoding')
	if 1 == maxCharSize := NumGet(info, 'uint')
		return sbc_decoder(buf := 0) => buf ? StrGet(buf, , encoding) : ''
	return (lastChar := Buffer(8), mbc_decoder)
	u16_decoder(buf := 0) {
		if !buf || !size := buf.size
			return lastSize ? (lastSize := 0, fffd) : ''
		if lastSize
			NumPut('char', NumGet(ptr := buf.ptr, 'char'), lastChar, 1), s := StrGet(lastChar) StrGet(ptr + 1, --size >> 1)
		else s := StrGet(buf, size >> 1)
		if lastSize := size & 1
			NumPut('ushort', NumGet(ptr, size - 1, 'uchar'), lastChar)
		return s
	}
	mbc_decoder(buf := 0) {
		if !buf || !size := buf.size
			return lastSize ? (lastSize := 0, fffd) : ''
		if lastSize {
			DllCall('RtlMoveMemory', 'ptr', lastSize + pl := lastChar.ptr, 'ptr', ptr := buf.ptr, 'uptr', sz := Min(size, maxCharSize - lastSize))
			if SubStr(s1 := StrGet(pl, , encoding), -1) == fffd {
				sl := StrLen(s1), lastSize += sz
				loop sz - 1
					if DllCall('MultiByteToWideChar', 'uint', encoding, 'uint', 0, 'ptr', pl, 'int', lastSize - A_Index, 'ptr', 0, 'int', 0) < sl {
						s1 := SubStr(s1, 1, -1), sz -= A_Index, lastSize := maxCharSize
						break
					}
				if lastSize < maxCharSize
					return ''
			}
			if !(lastSize := 0, ptr += sz, size -= sz)
				return s1
			o := { ptr: ptr, size: size }
		} else s1 := '', o := buf
		if SubStr(s2 := StrGet(o, , encoding), -1) == fffd {
			sl := StrLen(s2), ptr ?? ptr := o.ptr
			loop sz := Min(maxCharSize - 1, size)
				if DllCall('MultiByteToWideChar', 'uint', encoding, 'uint', 0, 'ptr', ptr, 'int', size - A_Index, 'ptr', 0, 'int', 0) < sl {
					DllCall('RtlMoveMemory', 'ptr', NumPut('int64', 0, pl ?? lastChar.ptr) - 8, 'ptr', ptr + size - A_Index, 'ptr', lastSize := A_Index)
					return s1 SubStr(s2, 1, -1)
				}
		}
		return s1 s2
	}
}
