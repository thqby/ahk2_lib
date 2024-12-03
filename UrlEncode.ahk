UrlEncode(url, component := false) {
    flag := component ? 0xc2000 : 0xc0000
	DllCall('shlwapi\UrlEscape', 'str', url, 'ptr*', 0, 'uint*', &len := 1, 'uint', flag)
	DllCall('shlwapi\UrlEscape', 'str', url, 'ptr', buf := Buffer(len << 1), 'uint*', &len, 'uint', flag)
	return StrGet(buf)
}