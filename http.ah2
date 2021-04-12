#Include <struct>
#Include <JSON>

class WinHttp {
	static FLAG_ASYNC := 0x10000000
	Ptr := 0, Version := 0, _statuscb := 0
	__New(UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.68', AccessType := 0, ProxyName := '', ProxyBypass := '', dwFlags := 0) {
		pwszUserAgent := UserAgent = '' ? 0 : StrPtr(UserAgent)
		pwszProxyName := ProxyName = '' ? 0 : StrPtr(ProxyName)
		pwszProxyBypass := ProxyBypass = '' ? 0 : StrPtr(ProxyBypass)
		if !hSession := DllCall('Winhttp\WinHttpOpen', 'ptr', pwszUserAgent, 'uint', AccessType, 'ptr', pwszProxyName, 'ptr', pwszProxyBypass, 'uint', dwFlags, 'ptr')
			throw
		this.Ptr := hSession
		if (dwFlags & WinHttp.FLAG_ASYNC)
			this._statuscb := CallbackCreate(StatusCallback)
		StatusCallback(hInternet, dwContext, dwInternetStatus, lpvStatusInformation, dwStatusInformationLength) {
			s := ''
			if (dwStatusInformationLength)
				s := StrGet(lpvStatusInformation, dwStatusInformationLength, 'utf-16')
			if (dwInternetStatus = 0x00400000)	; WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE
				fn := ObjPtr(dwContext)
			OutputDebug(dwInternetStatus '|' s '`n')
		}
	}
	__Delete() {
		WinHttp.CloseHandle(this.Ptr)
		if (this._statuscb)
			CallbackFree(this._statuscb)
	}
	Connect(pswzServerName, nServerPort, dwReserved) => DllCall('Winhttp\WinHttpConnect', 'ptr', this, 'wstr', pswzServerName, 'ushort', nServerPort, 'uint', dwReserved, 'ptr')
	GetProxyForUrl(lpcwszUrl, pAutoProxyOptions, pProxyInfo) => DllCall('Winhttp\WinHttpGetProxyForUrl', 'ptr', this, 'wstr', lpcwszUrl, 'ptr', pAutoProxyOptions, 'ptr', pProxyInfo, 'int')
	setTimeouts(dwResolveTimeout, dwConnectTimeout, dwSendTimeout, dwReceiveTimeout) => DllCall('Winhttp\WinHttpSetTimeouts', 'ptr', this, 'int', dwResolveTimeout, 'int', dwConnectTimeout, 'int', dwSendTimeout, 'int', dwReceiveTimeout, 'int')

	open() {
		; OpenRequest(hConnect, pwszVerb, pwszObjectName, pwszVersion, pwszReferrer, ppwszAcceptTypes, dwFlags) => DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', pwszVerb, 'wstr', pwszObjectName, 'wstr', pwszVersion, 'wstr', pwszReferrer, 'ptr', ppwszAcceptTypes, 'uint', dwFlags, 'ptr')

	}
	request(Url, Verb := 'GET', data := '', headers := '', disable_redirects := false) {
		static WINHTTP_FLAG_SECURE := 0x00800000, _ports := {ftp: 21, http: 80, https: 443}
		if (!RegExMatch(url, '^((?<SCHEME>\w+)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:]+)(:(?<PORT>\d+))?(?<PATH>/.*)?$', &m))
			throw Error('无效的url')
		port := Integer(m.PORT || (_ports.HasOwnProp(m.SCHEME) ? _ports.%m.SCHEME% : m.SCHEME = '' ? 80 : 0))
		if !(hConnect := DllCall('Winhttp\WinHttpConnect', 'ptr', this, 'wstr', m.HOST, 'ushort', port, 'uint', 0, 'ptr'))
			throw Error('连接失败')
		dwFlags := m.SCHEME = 'https' ? WINHTTP_FLAG_SECURE : 0
		pwszReferrer := 0, pwszVersion := this.Version ? StrPtr(this.Version) : 0
		path := LTrim(m.PATH, '/'), t := '', _headers := '', str := ''
		switch Type(headers) {
			case 'String':
				_headers := RegExReplace(headers, '\R', '`r`n')
			case 'Array':
				for v in headers
					_headers .= '`r`n' v
				_headers := LTrim(_headers, '`r`n')
			case 'Map', 'Object':
				for k, v in Type(headers) = 'Map' ? headers : headers.OwnProps()
					_headers .= '`r`n' k ': ' v
				_headers := LTrim(_headers, '`r`n')
		}
		if (data) {
			if ((t := Type(data)) ~= '^(Map|Object)$') {
				if (_headers ~= 'im)Content-Type:\s*application/json')
					data := JSON.stringify(data, 0)
				else {
					for k, v in t = 'Map' ? data : data.OwnProps()
						str .= '&' k '=' v
					if (Verb = 'POST')
						data := SubStr(str, 2), str := ''
					else if str
						path .= InStr(path, '?') ? str : '?' SubStr(str, 2)
				}
			} else if (t = 'String' && Verb != 'POST')
				path .= InStr(path, '?') ? data : '?' SubStr(data, 2), data := ''
		}
		if !(hRequest := DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', StrUpper(Verb), 'wstr', path, 'ptr', pwszVersion, 'ptr', pwszReferrer, 'ptr', 0, 'uint', dwFlags, 'ptr')) {
			WinHttp.CloseHandle(hConnect)
			throw Error('打开请求失败')
		}
		req := WinHttp.Request.Call(hRequest), req.hConnect := hConnect
		if (disable_redirects)
			buf := BufferAlloc(4), NumPut('uint', 0x2, buf), WinHttp.SetOption(hRequest, 63, buf, 4)
		req.SendRequest(data, _headers)
		return req
	}
	static CheckPlatform() => DllCall('Winhttp\WinHttpCheckPlatform', 'int')
	static CloseHandle(hInternet) => DllCall('Winhttp\WinHttpCloseHandle', 'ptr', hInternet, 'int')
	static CrackUrl(Url) {
		if (A_PtrSize = 8) {
			buf := BufferAlloc(104), NumPut('uint', 104, buf), NumPut('uint', -1, buf, 32), NumPut('uint', -1, buf, 48)
			NumPut('uint', -1, buf, 64), NumPut('uint', -1, buf, 80), NumPut('uint', -1, buf, 96)
		} else {
			buf := BufferAlloc(60), NumPut('uint', 60, buf), NumPut('uint', -1, buf, 20), NumPut('uint', -1, buf, 32)
			NumPut('uint', -1, buf, 40), NumPut('uint', -1, buf, 48), NumPut('uint', -1, buf, 56)
		}
		if (DllCall('Winhttp\WinHttpCrackUrl', 'wstr', Url, 'uint', 0, 'uint', 0, 'ptr', buf, 'int')) {
			if (A_PtrSize = 8) {
				lpszHostName := NumGet(buf, 24, 'ptr'), dwHostNameLength := NumGet(buf, 32, 'uint'), Port := NumGet(buf, 36, 'uint')
				lpszUserName := NumGet(buf, 40, 'ptr'), dwUserNameLength := NumGet(buf, 48, 'uint')
				lpszPassword := NumGet(buf, 56, 'ptr'), dwPasswordLength := NumGet(buf, 64, 'uint')
				lpszUrlPath := NumGet(buf, 72, 'ptr'), dwUrlPathLength := NumGet(buf, 80, 'uint')
				lpszExtraInfo := NumGet(buf, 88, 'ptr'), dwExtraInfoLength := NumGet(buf, 96, 'uint')
			} else {
				lpszHostName := NumGet(buf, 16, 'ptr'), dwHostNameLength := NumGet(buf, 20, 'uint'), Port := NumGet(buf, 24, 'uint')
				lpszUserName := NumGet(buf, 28, 'ptr'), dwUserNameLength := NumGet(buf, 32, 'uint')
				lpszPassword := NumGet(buf, 36, 'ptr'), dwPasswordLength := NumGet(buf, 40, 'uint')
				lpszUrlPath := NumGet(buf, 44, 'ptr'), dwUrlPathLength := NumGet(buf, 48, 'uint')
				lpszExtraInfo := NumGet(buf, 52, 'ptr'), dwExtraInfoLength := NumGet(buf, 56, 'uint')
			}
			HostName := dwHostNameLength ? StrGet(lpszHostName, dwHostNameLength) : ''
			UserName := dwUserNameLength ? StrGet(lpszUserName, dwUserNameLength) : ''
			Password := dwPasswordLength ? StrGet(lpszPassword, dwPasswordLength) : ''
			UrlPath := dwUrlPathLength ? StrGet(lpszUrlPath, dwUrlPathLength) : ''
			ExtraInfo := dwExtraInfoLength ? StrGet(lpszExtraInfo, dwExtraInfoLength) : ''
			return {HostName: HostName, UserName: UserName, Password: Password, Port: Port, UrlPath: UrlPath, ExtraInfo: ExtraInfo}
		}
	}
	static CreateUrl(lpUrlComponents, dwFlags, pwszUrl, lpdwUrlLength) => DllCall('Winhttp\WinHttpCreateUrl', 'ptr', lpUrlComponents, 'uint', dwFlags, 'wstr', pwszUrl, 'ptr', lpdwUrlLength, 'int')
	static DetectAutoProxyConfigUrl(dwAutoDetectFlags, ppwszAutoConfigUrl) => DllCall('Winhttp\WinHttpDetectAutoProxyConfigUrl', 'uint', dwAutoDetectFlags, 'ptr', ppwszAutoConfigUrl, 'int')
	static GetDefaultProxyConfiguration(pProxyInfo) => DllCall('Winhttp\WinHttpGetDefaultProxyConfiguration', 'ptr', pProxyInfo, 'int')
	static GetIEProxyConfigForCurrentUser(pProxyConfig) => DllCall('Winhttp\WinHttpGetIEProxyConfigForCurrentUser', 'ptr', pProxyConfig, 'int')
	static QueryOption(hInternet, dwOption, lpBuffer, lpdwBufferLength) => DllCall('Winhttp\WinHttpQueryOption', 'ptr', hInternet, 'uint', dwOption, 'ptr', lpBuffer, 'ptr', lpdwBufferLength, 'int')
	static SetDefaultProxyConfiguration(pProxyInfo) => DllCall('Winhttp\WinHttpSetDefaultProxyConfiguration', 'ptr', pProxyInfo, 'int')
	static SetOption(hInternet, dwOption, lpBuffer, dwBufferLength) => DllCall('Winhttp\WinHttpSetOption', 'ptr', hInternet, 'uint', dwOption, 'ptr', lpBuffer, 'uint', dwBufferLength, 'int')
	static SetStatusCallback(hInternet, lpfnInternetCallback, dwNotificationFlags) => DllCall('Winhttp\WinHttpSetStatusCallback', 'ptr', hInternet, 'ptr', lpfnInternetCallback, 'uint', dwNotificationFlags, 'uptr', 0, 'ptr')
	static TimeFromSystemTime(pst, pwszTime) => DllCall('Winhttp\WinHttpTimeFromSystemTime', 'ptr', pst, 'wstr', pwszTime, 'int')
	static TimeToSystemTime(pwszTime, pst) => DllCall('Winhttp\WinHttpTimeToSystemTime', 'wstr', pwszTime, 'ptr', pst, 'int')

	class Request {
		Ptr := 0, hConnect := 0, _ResponseBody := 0, _Headers := 0, _HasReceiveResponse := 0
		__New(hRequest, statuscb := 0, callback := 0) {
			this.Ptr := hRequest
			if (statuscb)
				WinHttp.SetStatusCallback(hRequest, statuscb, 0xffffffff)
		}
		__Delete() {
			this._Headers := this._ResponseBody := 0
			if (this.Ptr)
				WinHttp.CloseHandle(this.Ptr), this.Ptr := 0
			if (this.hConnect)
				WinHttp.CloseHandle(this.hConnect)
		}
		AddRequestHeaders(Headers, dwModifiers := 0x40000000) => DllCall('Winhttp\WinHttpAddRequestHeaders', 'ptr', this, 'wstr', Headers, 'uint', -1, 'uint', dwModifiers, 'int')
		QueryAuthSchemes(lpdwSupportedSchemes, lpdwFirstScheme, pdwAuthTarget) => DllCall('Winhttp\WinHttpQueryAuthSchemes', 'ptr', this, 'ptr', lpdwSupportedSchemes, 'ptr', lpdwFirstScheme, 'ptr', pdwAuthTarget, 'int')
		QueryDataAvailable(&dwNumberOfBytesAvailable) => DllCall('Winhttp\WinHttpQueryDataAvailable', 'ptr', this, 'uint*', &dwNumberOfBytesAvailable := 0, 'int')
		QueryHeaders(dwInfoLevel, pwszName, lpBuffer, &dwBufferLength, dwIndex := 0) => DllCall('Winhttp\WinHttpQueryHeaders', 'ptr', this, 'uint', dwInfoLevel, 'ptr', pwszName, 'ptr', lpBuffer, 'uint*', &dwBufferLength, 'uint*', &dwIndex, 'int')
		ReadData(lpBuffer, dwNumberOfBytesToRead, &dwNumberOfBytesRead) => DllCall('Winhttp\WinHttpReadData', 'ptr', this, 'ptr', lpBuffer, 'uint', dwNumberOfBytesToRead, 'uint*', &dwNumberOfBytesRead := 0, 'int')
		ReceiveResponse() => DllCall('Winhttp\WinHttpReceiveResponse', 'ptr', this, 'ptr', 0, 'int')
		SendRequest(Data := '', Headers := '') {
			static errors := Map(12002, '操作超时', 12007, '无法解析服务器的名称或地址', 12029, '无法连接')
			this._ResponseBody := 0, this._HasReceiveResponse := 0
			if (Data = '') {
				lpOptional := 0, dwOptionalLength := 0
			} else if (Type(lpOptional) = 'Buffer')
				lpOptional := Data.Ptr, dwOptionalLength := Data.Size
			else
				lpOptional := StrPtr(Data := String(Data)), dwOptionalLength := StrLen(lpOptional) * 2
			pwszHeaders := Headers = '' ? 0 : StrPtr(Headers)
			if (!DllCall('Winhttp\WinHttpSendRequest', 'ptr', this, 'ptr', pwszHeaders, 'uint', -1, 'ptr', lpOptional, 'uint', dwOptionalLength, 'uint', 0, 'uptr', 0, 'int'))
				throw Error(errors.Has(err := A_LastError) ? errors[err] : err, -1)
		}
		SetCredentials(AuthTargets, AuthScheme, pwszUserName, pwszPassword, pAuthParams) => DllCall('Winhttp\WinHttpSetCredentials', 'ptr', this, 'uint', AuthTargets, 'uint', AuthScheme, 'wstr', pwszUserName, 'wstr', pwszPassword, 'ptr', pAuthParams, 'int')
		WriteData(lpBuffer, dwNumberOfBytesToWrite, &dwNumberOfBytesWritten) => DllCall('Winhttp\WinHttpWriteData', 'ptr', this, 'ptr', lpBuffer, 'uint', dwNumberOfBytesToWrite, 'uint*', &dwNumberOfBytesWritten := 0, 'int')
		
		responseBody {
			get {
				if (this._ResponseBody)
					return this._ResponseBody
				if (this._HasReceiveResponse || this._HasReceiveResponse := this.ReceiveResponse()) {
					if (!this.QueryDataAvailable(&size))
						return
					buf := BufferAlloc(size), this.ReadData(buf.Ptr, size, &dwread), offset := dwread
					while (this.QueryDataAvailable(&size) && size)
						buf.Size := offset + size, this.ReadData(buf.Ptr + offset, size, &dwread), offset += dwread
					return this._ResponseBody := buf
				}
			}
		}
		responseText {
			get {
				if (this._ResponseBody || this.ResponseBody) {
					text := StrGet(this._ResponseBody, 'utf-8')
					return text
				}
			}
		}
		headers[Name := ''] {
			get {
				if (this._HasReceiveResponse || this._HasReceiveResponse := this.ReceiveResponse()) {
					i := 0, s := ''
					if (Name = '') {
						if (this._Headers)
							return this._Headers
						this.QueryHeaders(22, 0, 0, &size := 0, 0)
						if (size && (buf := BufferAlloc(size)) && this.QueryHeaders(22, 0, buf.Ptr, &size, 0))
							return this._Headers := StrGet(buf, 'utf-16')
					} else if (Type(Name) = 'String') {
						this.QueryHeaders(65535, ps := StrPtr(Name), 0, &size := 0, i)
						while (size && (buf := BufferAlloc(size)) && this.QueryHeaders(65535, ps, buf.Ptr, &size, i++))
							s .= StrGet(buf, 'utf-16'), this.QueryHeaders(65535, ps, 0, &size := 0, i)
						return s
					} else {
						this.QueryHeaders(Name += 0, 0, 0, &size := 0, i)
						if (Name = 21) {
							buf := BufferAlloc(size), this.QueryHeaders(Name, 0, buf.Ptr, &size, i)
							return buf
						}
						while (size && (buf := BufferAlloc(size)) && this.QueryHeaders(Name, 0, buf.Ptr, &size, i++)) {
							s .= '`n' StrGet(buf, 'utf-16')
							this.QueryHeaders(Name += 0, 0, 0, &size := 0, i)
						}
						return LTrim(s, '`n')
					}
				}
			}
		}
	}
}

session := WinHttp(, , , , WinHttp.FLAG_ASYNC)
req := session.request('https://www.baidu.com')
Persistent()
; req := session.request('http://www.sojson.com', 'POST', , 'Content-Type: application/x-www-form-urlencoded;charset=UTF-8`r`nConnection: close`r`nContent-Length: 0', true)
; req.AddRequestHeaders()
; OutputDebug(req.Headers '`n')
; OutputDebug(req.Headers[19] '`n')
; OutputDebug(req.Headers)
; Sleep(1100)
; OutputDebug(req.headers '`n')
; OutputDebug(req.responseText)
; hObject := ComObject("WinHttp.WinHttpRequest.5.1")
; hObject.SetTimeouts(30000, 30000, 30000, 30000)
; hObject.Open('GET', 'https://www.baiduw.com', true)
; hObject.send()
; OutputDebug('ss')
; OutputDebug hObject.readyState