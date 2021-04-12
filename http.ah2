#Include <struct>
#Include <JSON>

class WinHttp {
	Ptr := 0
	__New(UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.68', AccessType := 0, ProxyName := '', ProxyBypass := '', dwFlags := 0) {
		pwszUserAgent := UserAgent = '' ? 0 : StrPtr(UserAgent)
		pwszProxyName := ProxyName = '' ? 0 : StrPtr(ProxyName)
		pwszProxyBypass := ProxyBypass = '' ? 0 : StrPtr(ProxyBypass)
		if !hSession := DllCall('Winhttp\WinHttpOpen', 'ptr', pwszUserAgent, 'uint', AccessType, 'ptr', pwszProxyName, 'ptr', pwszProxyBypass, 'uint', dwFlags, 'ptr')
			throw
		this.Ptr := hSession
	}
	__Delete() {
		WinHttp.CloseHandle(this.Ptr)
	}
	Connect(pswzServerName, nServerPort, dwReserved) => DllCall('Winhttp\WinHttpConnect', 'ptr', this, 'wstr', pswzServerName, 'ushort', nServerPort, 'uint', dwReserved, 'ptr')
	GetProxyForUrl(lpcwszUrl, pAutoProxyOptions, pProxyInfo) => DllCall('Winhttp\WinHttpGetProxyForUrl', 'ptr', this, 'wstr', lpcwszUrl, 'ptr', pAutoProxyOptions, 'ptr', pProxyInfo, 'int')

	open() {
		; OpenRequest(hConnect, pwszVerb, pwszObjectName, pwszVersion, pwszReferrer, ppwszAcceptTypes, dwFlags) => DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', pwszVerb, 'wstr', pwszObjectName, 'wstr', pwszVersion, 'wstr', pwszReferrer, 'ptr', ppwszAcceptTypes, 'uint', dwFlags, 'ptr')

	}
	_open(Url, Verb := 'GET', Version := '') {
		static _ports := {ftp: 21, http: 80, https: 443}
		if (!RegExMatch(url, '^((?<SCHEME>\w+)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:]+)(:(?<PORT>\d+))?(?<EXTRA>/.*)?$', &m))
			throw Error('无效的url')
		port := Integer(m.PORT || (_ports.HasOwnProp(m.SCHEME) ? _ports.%m.SCHEME% : m.SCHEME = '' ? 80 : 0))
		if !(hConnect := DllCall('Winhttp\WinHttpConnect', 'ptr', this, 'wstr', m.HOST, 'ushort', port, 'uint', 0, 'ptr'))
			throw Error('连接失败')
		dwFlags := m.SCHEME = 'https' ? 0x00800000 : 0
		pwszReferrer := 0
		pwszVersion := Version = '' ? 0 : StrPtr(Version)
		if !(hRequest := DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', StrUpper(Verb), 'wstr', LTrim(m.EXTRA, '/'), 'ptr', pwszVersion, 'ptr', pwszReferrer, 'ptr', 0, 'uint', dwFlags, 'ptr')) {
			WinHttp.CloseHandle(hConnect)
			throw Error('打开请求失败')
		}
		req := WinHttp.Request.Call(hRequest), req.hConnect := hConnect
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
	static SetStatusCallback(hInternet, lpfnInternetCallback, dwNotificationFlags, dwReserved) => DllCall('Winhttp\WinHttpSetStatusCallback', 'ptr', hInternet, 'ptr', lpfnInternetCallback, 'uint', dwNotificationFlags, 'uptr', dwReserved, 'ptr')
	static SetTimeouts(hInternet, dwResolveTimeout, dwConnectTimeout, dwSendTimeout, dwReceiveTimeout) => DllCall('Winhttp\WinHttpSetTimeouts', 'ptr', hInternet, 'int', dwResolveTimeout, 'int', dwConnectTimeout, 'int', dwSendTimeout, 'int', dwReceiveTimeout, 'int')
	static TimeFromSystemTime(pst, pwszTime) => DllCall('Winhttp\WinHttpTimeFromSystemTime', 'ptr', pst, 'wstr', pwszTime, 'int')
	static TimeToSystemTime(pwszTime, pst) => DllCall('Winhttp\WinHttpTimeToSystemTime', 'wstr', pwszTime, 'ptr', pst, 'int')

	class Request {
		Ptr := 0, hConnect := 0, _ResponseBody := 0, _Headers := 0, _ReceiveResponse := 0
		__New(hRequest) {
			this.Ptr := hRequest
		}
		__Delete() {
			WinHttp.CloseHandle(this.Ptr)
			if (this.hConnect)
				WinHttp.CloseHandle(this.hConnect)
		}
		AddRequestHeaders(Headers, dwModifiers := 0x40000000) => DllCall('Winhttp\WinHttpAddRequestHeaders', 'ptr', this, 'wstr', Headers, 'uint', -1, 'uint', dwModifiers, 'int')
		QueryAuthSchemes(lpdwSupportedSchemes, lpdwFirstScheme, pdwAuthTarget) => DllCall('Winhttp\WinHttpQueryAuthSchemes', 'ptr', this, 'ptr', lpdwSupportedSchemes, 'ptr', lpdwFirstScheme, 'ptr', pdwAuthTarget, 'int')
		QueryDataAvailable(&dwNumberOfBytesAvailable) => DllCall('Winhttp\WinHttpQueryDataAvailable', 'ptr', this, 'uint*', &dwNumberOfBytesAvailable := 0, 'int')
		QueryHeaders(dwInfoLevel, pwszName, lpBuffer, &dwBufferLength, lpdwIndex) => DllCall('Winhttp\WinHttpQueryHeaders', 'ptr', this, 'uint', dwInfoLevel, 'ptr', pwszName, 'ptr', lpBuffer, 'uint*', &dwBufferLength, 'ptr', lpdwIndex, 'int')
		ReadData(lpBuffer, dwNumberOfBytesToRead, &dwNumberOfBytesRead) => DllCall('Winhttp\WinHttpReadData', 'ptr', this, 'ptr', lpBuffer, 'uint', dwNumberOfBytesToRead, 'uint*', &dwNumberOfBytesRead := 0, 'int')
		ReceiveResponse() => DllCall('Winhttp\WinHttpReceiveResponse', 'ptr', this, 'ptr', 0, 'int')
		SendRequest(Optional := '', Headers := '') {
			this._ResponseBody := 0, this._ReceiveResponse := 0
			if (Optional = '') {
				lpOptional := 0, dwOptionalLength := 0
			} else if (Type(lpOptional) = 'Buffer')
				lpOptional := Optional.Ptr, dwOptionalLength := Optional.Size
			else
				lpOptional := StrPtr(Optional := String(Optional)), dwOptionalLength := StrLen(lpOptional) * 2
			pwszHeaders := Headers = '' ? 0 : StrPtr(Headers)
			if (!DllCall('Winhttp\WinHttpSendRequest', 'ptr', this, 'ptr', pwszHeaders, 'uint', -1, 'ptr', lpOptional, 'uint', dwOptionalLength, 'uint', 0, 'uptr', 0, 'int'))
				throw Error(A_LastError)
		}
		SetCredentials(AuthTargets, AuthScheme, pwszUserName, pwszPassword, pAuthParams) => DllCall('Winhttp\WinHttpSetCredentials', 'ptr', this, 'uint', AuthTargets, 'uint', AuthScheme, 'wstr', pwszUserName, 'wstr', pwszPassword, 'ptr', pAuthParams, 'int')
		WriteData(lpBuffer, dwNumberOfBytesToWrite, lpdwNumberOfBytesWritten) => DllCall('Winhttp\WinHttpWriteData', 'ptr', this, 'ptr', lpBuffer, 'uint', dwNumberOfBytesToWrite, 'ptr', lpdwNumberOfBytesWritten, 'int')
		ResponseBody {
			get {
				if (this._ResponseBody)
					return this._ResponseBody
				if (this._ReceiveResponse || this._ReceiveResponse := this.ReceiveResponse()) {
					if (!this.QueryDataAvailable(&size))
						return
					; this._ResponseBody := 
					buf := BufferAlloc(size)
					this.ReadData(buf.Ptr, size, &dwread)
					return buf
				}
			}
		}
		ResponseText {
			get {
				; if (this._ResponseBody || this.ResponseBody) {
					text := StrGet(this.ResponseBody, 'utf-8')
					return text
				; }
			}
		}
		Headers {
			get {
				if (this._ReceiveResponse || this._ReceiveResponse := this.ReceiveResponse()) {
					this.QueryHeaders(22, 0, 0, &size := 0, 0)
					buf := BufferAlloc(size)
					if (this.QueryHeaders(22, 0, buf.Ptr, &size, 0))
						return this._Headers := StrGet(buf, 'utf-16')
				}
			}
		}
	}
}

session := WinHttp()
req := session._open('https://www.baidu.com')
; req.AddRequestHeaders()
req.SendRequest()
OutputDebug(req.Headers)
OutputDebug(req.ResponseText)
OutputDebug(req.ResponseText)
OutputDebug(req.ResponseText)
OutputDebug(req.ResponseText)
OutputDebug(req.ResponseText)