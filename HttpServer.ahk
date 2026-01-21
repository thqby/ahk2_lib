/************************************************************************
 * @description An http/websocket server implementation.
 * @author thqby
 * @date 2026/01/21
 * @version 2.0.2
 ***********************************************************************/

#Include <OVERLAPPED>
#Include <ctypes>
; #Include <compress>	; Used to support gzip/zstd compression and decompression
; #Include <JSON>	; https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk

;@region http structs
;@lint-disable class-non-dynamic-member-check
class HTTP_KNOWN_HEADER extends ctypes.struct {
	static fields := [['ushort', 'RawValueLength'], ['LPSTR', 'RawValue']]
}
class HTTP_UNKNOWN_HEADER extends ctypes.struct {
	static fields := [['ushort', 'NameLength'], ['ushort', 'RawValueLength'], ['LPSTR', 'Name'], ['LPSTR', 'RawValue']]
}
class HTTP_REQUEST_INFO extends ctypes.struct {
	static fields := [['int', 'InfoType'], ['uint', 'InfoLength'], ['ptr', 'pInfo']]
}
class PSOCKADDR extends ctypes.struct {
	static fields := [['ptr']]
	static from_ptr(ptr, *) {
		if !ptr
			return ''
		addr := NumGet(ptr := NumGet(ptr, 'ptr'), 16 + 2 * A_PtrSize, 'ptr')
		addrlen := NumGet(ptr, 16, 'uptr')
		DllCall('ws2_32\WSAAddressToStringW', 'ptr', ptr, 'uint', 28, 'ptr', 0, 'ptr', b := Buffer(s := 2048), 'uint*', &s)
		return StrGet(b)
	}
}
class HTTP_REQUEST extends ctypes.struct {
	static KnownHeaders := ['Cache-Control', 'Connection', 'Date', 'Keep-Alive', 'Pragma', 'Trailer', 'Transfer-Encoding', 'Upgrade', 'Via', 'Warning', 'Allow', 'Content-Length', 'Content-Type', 'Content-Encoding', 'Content-Language', 'Content-Location', 'Content-MD5', 'Content-Range', 'Expires', 'Last-Modified', 'Accept', 'Accept-Charset', 'Accept-Encoding', 'Accept-Language', 'Authorization', 'Cookie', 'Expect', 'From', 'Host', 'If-Match', 'If-Modified-Since', 'If-None-Match', 'If-Range', 'If-Unmodified-Since', 'Max-Forwards', 'Proxy-Authorization', 'Referer', 'Range', 'TE', 'Translate', 'User-Agent']
	static fields := [
		['uint', 'Flags'], ['int64', 'ConnectionId'], ['int64', 'RequestId'], ['int64', 'UrlContext'],
		['uint', 'Version'], ['int', '_Verb'],
		['ushort', 'UnknownVerbLength'], ['ushort', 'RawUrlLength'],
		['ptr', 'pUnknownVerb'], ['LPSTR', 'RawUrl'],
		; CookedUrl
		['ushort', 'FullUrlLength'], ['ushort', 'HostLength'], ['ushort', 'AbsPathLength'], ['ushort', 'QueryStringLength'],
		['LPWSTR', 'FullUrl'], ['LPWSTR', 'Host'], ['LPWSTR', 'AbsPath'], ['LPWSTR', 'QueryString'],
		; Address
		[PSOCKADDR, 'RemoteAddress'], [PSOCKADDR, 'LocalAddress'],
		; HTTP_REQUEST_HEADERS
		['ushort', 'UnknownHeaderCount'], [HTTP_UNKNOWN_HEADER, '*pUnknownHeaders'],
		['ushort', 'TrailerCount'], ['ptr', 'pTrailers'],
		[HTTP_KNOWN_HEADER, 'KnownHeaders[41]'],
		; HTTP_REQUEST
		['int64', 'BytesReceived'],
		['ushort', 'EntityChunkCount'], ['ptr', 'pEntityChunks'],
		['int64', 'RawConnectionId'], ['ptr', 'pSslInfo'],
		; HTTP_REQUEST_V2
		['ushort', 'RequestInfoCount'], [HTTP_REQUEST_INFO, '*pRequestInfo']
	]
	Verb {
		get {
			static verbs := ['Unparsed', '', 'Invalid', 'OPTIONS', 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'TRACE', 'CONNECT', 'TRACK', 'MOVE', 'COPY', 'PROPFIND', 'PROPPATCH', 'MKCOL', 'LOCK', 'UNLOCK', 'SEARCH']
			return verbs[this._Verb + 1] || StrGet(this.pUnknownVerb, this.UnknownVerbLength, 'cp0')
		}
	}
	Headers {
		get {
			static khs := HTTP_REQUEST.KnownHeaders
			if !this._Verb
				return
			this.DefineProp('Headers', { value: headers := Map() })
			headers.CaseSense := 0
			for h in this.KnownHeaders
				if h.RawValueLength
					headers[khs[A_Index]] := h.RawValue
			hs := this.pUnknownHeaders
			loop this.UnknownHeaderCount
				h := hs[A_Index - 1], headers[h.Name] := h.RawValue

			return headers
		}
	}
	Queries {
		get {
			que := (s := this.QueryString) ? HttpServer.parse_urlencoded(SubStr(s, 2)) : Map()
			this.DefineProp('Queries', { value: que })
			return que
		}
	}
}
class HTTP_RESPONSE extends ctypes.struct {
	static fields := [
		['uint', 'Flags'], ['uint', 'Version'],
		['ushort', 'StatusCode'], ['ushort', 'ReasonLength'], ['LPSTR', 'Reason'],
		; Headers
		['ushort', 'UnknownHeaderCount'], [HTTP_UNKNOWN_HEADER, '*pUnknownHeaders'],
		['ushort', 'TrailerCount'], ['ptr', 'pTrailers'],
		[HTTP_KNOWN_HEADER, 'KnownHeaders[30]'],
		;
		['ushort', 'EntityChunkCount'], ['ptr', 'pEntityChunks'],
		; HTTP_RESPONSE_V2
		['ushort', 'ResponseInfoCount'], ['ptr', 'pResponseInfo']
	]
	set_headers(headers) {
		static known_header_index := init_header_indexes()
		if !headers.Count
			return
		sz := n := 0
		for k, v in headers {
			if v == ''
				continue
			sz += StrPut(v, 'cp0')
			if (i := known_header_index.Get(k, 30)) > 29
				sz += StrPut(k, 'cp0'), n++
		}
		this._uh := buf := Buffer(sz + n * HTTP_UNKNOWN_HEADER.size, 0)
		if this.UnknownHeaderCount := n
			this.pUnknownHeaders := buf.Ptr, huh := this.pUnknownHeaders
		hhk := this.KnownHeaders, pstr := buf.Ptr + n * HTTP_UNKNOWN_HEADER.size, n := 0
		for k, v in headers {
			if v == ''
				continue
			if (i := known_header_index.Get(k, 30)) > 29
				h := huh[n++], pstr += 1 + h.NameLength := StrPut(k, h.Name := pstr, 'cp0') - 1
			else h := hhk[i]
			pstr += 1 + h.RawValueLength := StrPut(v, h.RawValue := pstr, 'cp0') - 1
		}
		static init_header_indexes() {
			m := Map(), m.CaseSense := 0, h := HTTP_REQUEST.KnownHeaders
			loop 20
				; http.sys won't send the Connection header if set as a known header
				if A_Index !== 2
					m[h[A_Index]] := A_Index - 1
			for k in ['Accept-Ranges', 'Age', 'Etag', 'Location', 'Proxy-Authenticate', 'Retry-After', 'Server', 'Set-Cookie', 'Vary', 'Www-Authenticate']
				m[k] := 19 + A_Index
			return m
		}
	}
}
;@endregion

class RequestContext extends OVERLAPPED {
	static Prototype._requestId := 0
	__New(request, requestQueue, root) {
		super.__New(this.on_read_header)
		this._root := root
		this._request := request
		this._requestQueue := requestQueue
	}
	clear(*) {
		try ObjFromPtrAddRef(this._root).Delete(ObjPtr(this))
		for k in ['call', '_request', '_cb']
			this.DeleteProp(k)
	}
	cancel_request(err, *) {
		this.Call := this.clear
		if DllCall('httpapi\HttpCancelHttpRequest', 'ptr', this._requestQueue, 'int64', this._requestId, 'ptr', this)
			this()
		; ERROR_CONNECTION_INVALID, STATUS_END_OF_FILE, STATUS_CANCELLED
		if !err || err == 1229 || err == 0xc0000011 || err == 0xc0000120
			return
		err := OSError(err, -1)
		OutputDebug(JSON.stringify(err))
	}
	on_read_header(err, bytes) {
		static chunk_size := 64 * 1024
		hr := this._request
		if err {
			if err == 0x80000005 {
				if 997 !== err := DllCall('httpapi\HttpReceiveHttpRequest', 'ptr', rq := this._requestQueue, 'int64', 0, 'uint', 0,
					'ptr', this._request := HTTP_REQUEST(), 'uint', HTTP_REQUEST.size, 'ptr', 0, 'ptr', this)
					try this.cancel_request(err)
				ObjFromPtrAddRef(root := this._root)[ObjPtr(this := RequestContext(hr, rq, root))] := this
				err := DllCall('httpapi\HttpReceiveHttpRequest', 'ptr', rq, 'int64', this._requestId := hr.RequestId,
					'uint', 0, 'ptr', hr, 'uint', hr.Size := bytes, 'ptr', 0, 'ptr', this)
				if !err || err == 997
					return
			}
			return this.cancel_request(err)
		}
		kh := hr.KnownHeaders
		dc := (h := kh[13]).RawValueLength ? StrSplit(h.RawValue, ',', ' `t') : []
		if (h := kh[6]).RawValueLength {	; Transfer-Encoding
			sz := chunk_size, this._chunked := 1
			dc.Push(StrSplit(h.RawValue, ',', ' `t')*), dc.Pop()
		} else	; Content-Length
			sz := kh[11].RawValue
		if dc.Length > 1 || !InStr('identity,gzip,zstd', m := dc.Length && dc.Pop() || 'identity')
			this._decoding := 0
		else this._decoding := m
		; if RegExMatch((kh[22].RawValue || '') ',' (kh[38].RawValue || ''), 'i)\b(gzip|zstd)\b', &m)
		; 	this._encoding := m[]
		; else this._encoding := 0
		try {
			if sz
				this._chunk := hr.Body := chunk := Buffer(sz), chunk._used := err := 0
			else err := 38, hr.Body := ''
		} catch MemoryError
			return this.send_response(, , , 413)
		(this.Call := this.on_read_body)(this, err, 0)
	}
	on_read_body(err, bytes) {
		if !err {
			chunk := this._chunk
			used := chunk._used += bytes
			if used == chunk.Size {
				if !ObjHasOwnProp(this, '_chunked')
					goto handler
				chunk.Size *= 2
			}
			err := DllCall('httpapi\HttpReceiveRequestEntityBody', 'ptr', this._requestQueue, 'int64', this._requestId,
				'uint', 1, 'ptr', chunk.Ptr + used, 'uint', chunk.Size - used, 'ptr', 0, 'ptr', this)
			if !err || err == 997
				return
		}
		if err !== 38
			return this.cancel_request(err)
handler:
		IsSet(chunk) && chunk.Size := chunk.DeleteProp('_used')
		hr := this.DeleteProp('_request'), this.Version := hr.Version
		response := Map()
		response.CaseSense := 0
		response.Call := ObjBindMethod(this, 'send_response')
		try {
			if (body := hr.Body) && (dc := this._decoding) &&
				(StrLen(dc) == 4 ? IsSet(compress) : !dc := 0) {
				if dc
					body := compress.decode(body, , dc)
				ct := Trim(hr.KnownHeaders[12].RawValue || '')
				hr.Content := ct && !InStr(ct, ',') ? HttpServer.parse_body(ct, body) : body
			}
			ObjFromPtrAddRef(hr.UrlContext)(hr, response)
		} catch Error as e
			this.send_error(e)
	}
	on_send_response(err, bytes) {
		if err
			this.cancel_request(err)
		else if this._end
			this.clear()
		else if (res := this._res).Length <= i := ++this._i
			res.Length := this._i := 0, (this._cb)()
		else res[i] := this.send_body(res[++i])
	}
	send_body(body) {
		data := Buffer()
		if IsObject(body) {
			data.Size := 108, n := 3
			try {
				if !sz := body.Size
					return this.on_send_response(0, 0)
				if body is HttpServer.File
					NumPut('int64', 1, 'int64', 0, 'int64', -1, 'ptr', body.handle, data, 32)
				else NumPut('int64', 0, 'ptr', data.Ptr, 'uint', sz, data, 32)
			} catch Error as e
				return this.send_error(e)
			l := StrPut(Format('{:x}`r`n', sz), p := data.Ptr + 96, 'utf-8') - 1
			NumPut('int64', 0, 'ptr', p, 'uint', l, data)
			NumPut('int64', 0, 'ptr', p + l - 2, 'uint', 2, p - 32)
			data._data := body
		} else {
			sz := StrPut(body, 'utf-8'), sz += StrPut(s := Format('{:x}`r`n', sz - 1), 'utf-8')
			data.Size := sz + 32, n := 1, p := data.Ptr, sz == 5 && this._end := 1
			NumPut('int64', 0, 'ptr', p + 32, 'uint', sz, p)
			p += StrPut(s, p += 32, 'utf-8') - 1
			p += StrPut(body, p, 'utf-8') - 1
			StrPut('`r`n', p, 2, 'utf-8')
		}
		err := DllCall('httpapi\HttpSendResponseEntityBody', 'ptr', this._requestQueue, 'int64', this._requestId,
			'uint', this._end ? 0 : 2, 'ushort', n, 'ptr', data, 'ptr', 0, 'ptr', 0, 'uint', 0, 'ptr', this, 'ptr', 0)
		if !err || err == 997
			return data
		this.cancel_request(err)
	}
	send_error(err) {
		err.DeleteProp('Stack')
		status := err.DeleteProp('status') || 500
		this.send_response(Map('Content-Type', 'application/json'), JSON.stringify(err), status)
	}
	send(params) {
		(res := this._res).Push(res.Length ? params : this.send_body(params))
	}
	send_response(response_headers := Map(), body := '', status := 200, reason?) {
		static CT := 'Content-Type', file := HttpServer.File
		static base := file.Prototype.Base := HttpServer.Protocol.Prototype.Base := {}
		this.Call := this.on_send_response
		this._res := [hsp := HTTP_RESPONSE()], this._i := 0
		flags := sz := 0, response_headers.Call := this._cb := (*) => 0
		hsp.Version := this.DeleteProp('Version')
		if body == ''
			goto set_header
		if (isobj := IsObject(body)) && HasMethod(body) {
			te := Trim(response_headers.Get('Transfer-Encoding', ''))
			if !RegExMatch(te, 'i)(^|,)\s*chunked$')
				response_headers['Transfer-Encoding'] := (te && te ',') 'chunked'
			flags |= 2, this._cb := ObjBindMethod(body, , response_headers)
			response_headers.Call := (_, body := '') => this.send(body)
			goto set_header
		}
		ctv := response_headers.Get(CT, ''), data := Buffer(32)
set_body:
		if !isobj {
			response_headers[CT] := (ctv || 'text/html') ';charset=' charset := 'utf-8'
			StrPut(body, buf := Buffer(n := StrPut(body, charset) - 1), charset), body := buf
			NumPut('int64', 0, 'ptr', body.Ptr, 'uint', n, data)
		} else if HasBase(body, base) {
			if body is file {
				response_headers.Get(CT, 0) || response_headers[CT] := HttpServer.FindMime(body.path ||
					(buf := Buffer(256), buf.Size := body.file.RawRead(buf), buf))
				NumPut('int64', 1, 'int64', 0, 'int64', -1, 'ptr', body.handle, data)
			} else {
				flags |= 0x42, status := 101, body.CompleteUpgrade(this)
				goto set_header
			}
		} else if HasProp(body, 'Ptr') && HasProp(body, 'Size') {
			(!ctv) && response_headers[CT] := HttpServer.FindMime(body) || 'application/octet-stream'
			NumPut('int64', 0, 'ptr', body.Ptr, 'uint', body.Size, data)
		} else {
			isobj := false, !ctv && ctv := 'application/json', body := JSON.stringify(body)
			goto set_body
		}
		hsp._body := body, hsp._data := data, hsp.EntityChunkCount := 1, hsp.pEntityChunks := data.Ptr
set_header:
		hsp.set_headers(response_headers), hsp.StatusCode := status
		if reason ?? reason := HttpServer.StatusCodeReasons.Get(status, '')
			hsp.Reason := reason, hsp.ReasonLength := StrPut(reason, 'cp0') - 1
		this._end := !(flags & 2)
		err := DllCall('httpapi\HttpSendHttpResponse', 'ptr', this._requestQueue, 'int64', this._requestId,
			'uint', flags, 'ptr', hsp, 'ptr', 0, 'ptr', 0, 'ptr', 0, 'uint', 0, 'ptr', this, 'ptr', 0)
		if err && err !== 997
			this.cancel_request(err)
	}
}

class HttpServer {
	#DllLoad httpapi.dll
	static Prototype._id := 0
	static StatusCodeReasons := Map(
		100, 'Continue', 101, 'Switching Protocols',
		200, 'OK', 201, 'Created', 202, 'Accepted', 203, 'Non-Authoritative Information', 204, 'No Content', 205, 'Reset Content', 206, 'Partial Content',
		300, 'Multiple Choices', 301, 'Moved Permanently', 302, 'Found', 303, 'See Other', 304, 'Not Modified', 305, 'Use Proxy', 306, '(Unused)', 307, 'Temporary Redirect',
		400, 'Bad Request', 401, 'Unauthorized', 402, 'Payment Required', 403, 'Forbidden', 404, 'Not Found', 405, 'Method Not Allowed', 406, 'Not Acceptable', 407, 'Proxy Authentication Required', 408, 'Request Timeout', 409, 'Conflict', 410, 'Gone', 411, 'Length Required', 412, 'Precondition Failed', 413, 'Request Entity Too Large', 414, 'Request-URI Too Long', 415, 'Unsupported Media Type', 416, 'Requested Range Not Satisfiable', 417, 'Expectation Failed',
		500, 'Internal Server Error', 501, 'Not Implemented', 502, 'Bad Gateway', 503, 'Service Unavailable', 504, 'Gateway Timeout', 505, 'HTTP Version Not Supported'
	)
	__New() {
		if err := DllCall('httpapi\HttpInitialize', 'uint', 2, 'uint', 1, 'ptr', 0) ||
			DllCall('httpapi\HttpCreateServerSession', 'uint', 2, 'int64*', &sessionId := 0, 'uint', 0)
			Throw OSError(err)
		this._urlGroup := HttpServer.UrlGroup(this._id := sessionId,
			this._requestQueue := HttpServer.RequestQueue(), 30)
		OVERLAPPED.EnableIoCompletionCallback(rq := this._requestQueue)
		ols := this._requestQueue._overlappeds
		ol := RequestContext(hr := HTTP_REQUEST(), rq.Ptr, ObjPtr(ols))
		ols[ObjPtr(ol)] := ol
		err := DllCall('httpapi\HttpReceiveHttpRequest', 'ptr', rq, 'int64', 0, 'uint', 0,
			'ptr', hr, 'uint', HTTP_REQUEST.size, 'ptr', 0, 'ptr', ol)
		if err != 997
			Throw OSError(err)
	}
	__Delete() {
		if !this._id
			return
		this._urlGroup := 0
		this._requestQueue := 0
		DllCall('httpapi\HttpCloseServerSession', 'int64', this.DeleteProp('_id'))
		DllCall('httpapi\HttpTerminate', 'uint', 1, 'ptr', 0)
	}

	/**
	 * Adds the specified URL's handler.
	 * @param {String} url Url string that contains a properly formed
	 * {@link https://learn.microsoft.com/en-us/windows/desktop/Http/urlprefix-strings UrlPrefix String}
	 * that identifies the URL to be registered.
	 * If you are not running as an administrator, specify a port number greater than 1024,
	 * otherwise you may get an `ERROR_ACCESS_DENIED` error.
	 * The url format is `http(s)://host(:port)/(path)`, when host is `+`, matches all addresses or domain names.
	 * @param {(req: HTTP_REQUEST, rsp: Response)=>void} handler Handler of http request
	 * @typedef {Buffer|Object|HttpServer.File|HttpServer.Protocol|String|(rsp: Response)=>void} ResponseBody
	 * The types supported by the response body, they will have these conversions:
	 * - `BufferLike`, `HttpServer.File`: No conversion.
	 * - `Object`: Converted to json strings.
	 * - `String`: Encoded as utf-8.
	 * - `HttpServer.Protocol`: Current connection is upgraded to special protocol.
	 * - `(rsp: Response)=>void`: A callback function that fires when buffered data has been sent.
	 *   Can be used to persistently send data to the client, and the session ends when empty data is sent.
	 * @typedef {Map} Response Set the items of the Map as the response headers and call it to send the response body.
	 * @property {(body?:ResponseBody, status?:Integer, reason?:String)=>void} Call
	 * By calling it to send the response body to the client, you can specify the http status code and reason on the first call.
	 * @returns {this}
	 */
	Add(url, handler) => (this._urlGroup.Add(url, handler), this)
	; Removes the specified URL's handler or all handlers.
	Remove(url?) => this._urlGroup.Remove(url?)
	; Detect mime of file or data
	static FindMime(PathOrData) {
		pPath := pBuf := size := 0
		if IsObject(PathOrData)
			pBuf := PathOrData, size := PathOrData.Size
		else if (pPath := StrPtr(PathOrData), !size := (pBuf := FileRead(PathOrData, 'raw m256')).Size)
			pBuf := 0
		loop 2
			hr := DllCall('urlmon\FindMimeFromData', 'ptr', 0, 'ptr', pPath, 'ptr', pBuf, 'uint', size, 'ptr', 0, 'uint', 0x20, 'ptr*', &pmime := 0, 'uint', 0)
		until !pBuf || !pPath || (pBuf := size := 0)
		if hr
			return
		mime := StrGet(pmime), DllCall('ole32\CoTaskMemFree', 'ptr', pmime)
		return mime
	}

	static parse_body(type, data) {
		header := split2map(type)
		charset := header.Get('charset', 'utf-8')
		switch type := header['type'] {
			case 'application/x-www-form-urlencoded': return this.parse_urlencoded(StrGet(data, charset))
			case 'application/json': return JSON.parse(StrGet(data, charset))
			case 'multipart/form-data': return parse_multipart(data, '--' header['boundary'])
			default: return SubStr(type, 1, 5) == 'text/' ? StrGet(data, charset) : data
		}
		static parse_multipart(buf, boundary) {
			lb := StrLen(boundary), datas := []
			ptr := buf.Ptr, end := ptr + buf.Size, crlf := ptr - 2
			loop {
				if !crlf := next_crlf(start := crlf + 2)
					return
			} until t := at_boundary_line(start, crlf - start)
			if t !== 1
				return
			loop {
				; parse headers
				cd := ct := 0
				while (start := crlf + 2) < crlf := next_crlf(start) {
					line := StrGet(start, crlf - start, 'utf-8')
					if !colon := InStr(line, ':')
						continue
					switch SubStr(line, 1, colon - 1), false {
						case 'Content-Disposition': cd := split2map(Trim(SubStr(line, colon + 1)))
						case 'Content-Type': ct := Trim(SubStr(line, colon + 1))
					}
				}
				if !crlf
					return
				; parse data
				data_start := crlf + 2
				loop {
					if !crlf := next_crlf(start := crlf + 2)
						if t := at_boundary_line(start, end - start)
							break
						else return
				} until t := at_boundary_line(start, crlf - start)
				data_end := start - 2, datas.Push(data := {})
				if cd
					data.key := cd.Get('name', ''), (fn := cd.Get('filename', 0)) && data.filename := fn
				else data.name := ''
				if ct
					data.value := HttpServer.parse_body(data.type := ct, { ptr: data_start, size: data_end - data_start })
				else data.value := StrGet(data_start, data_end - data_start, 'cp0')
			} until t == 2
			return datas

			next_crlf(p) {
				while lf := DllCall('msvcrt\memchr', 'ptr', p, 'int', 10, 'uptr', end - p, 'ptr')
					if --lf >= p && NumGet(lf, 'uchar') == 13
						return lf
					else p := lf + 2
				return 0
			}
			at_boundary_line(p, l) {
				if l == lb
					return StrGet(p, l, 'cp0') == boundary
				if l == lb + 2
					return (s := StrGet(p, l, 'cp0')) == boundary '--' && 2
				return 0
			}
		}
		static split2map(ct) {
			arr := StrSplit('type=' ct, ['=', ';'], ' `t')
			loop arr.Length >> 1
				i := A_Index << 1, arr[i] := Trim(arr[i], '"')
			return Map(arr*)
		}
	}

	static parse_urlencoded(url) {
		params := StrSplit(url, ['=', '&'])
		for v in params
			if InStr(v, '%') {
				DllCall('shlwapi\UrlUnescape', 'str', v, 'ptr', 0, 'uint*', 0, 'uint', 0x140000)
				params[A_Index] := v
			}
		m := Map()
		m.CaseSense := 0
		m.Set(params*)
		return m
	}

	class File {
		__New(path?, handle?) {
			if IsSet(handle)
				this.file := FileOpen(this.handle := handle, 'h'), this.path := path ?? ''
			else this.handle := (this.file := FileOpen(this.path := path, 'r')).Handle
		}
		size {
			get {
				if !DllCall('GetFileSizeEx', 'ptr', this.handle, 'int64*', &sz := 0)
					throw OSError()
				return sz
			}
		}
	}

	class Protocol {
		CompleteUpgrade(ctx) {
			throw Error('not implemented')
		}
	}

	;@region internal classes
	class RequestQueue {
		static Prototype.Ptr := 0
		__New() {
			if r := DllCall('httpapi\HttpCreateRequestQueue', 'uint', 2, 'ptr', 0, 'ptr', 0, 'uint', 0, 'ptr*', this)
				Throw OSError(r)
			this._overlappeds := Map()
		}
		__Delete() {
			if !this.Ptr
				return
			ols := this.DeleteProp('_overlappeds')
			DllCall('httpapi\HttpShutdownRequestQueue', 'ptr', this)
			prev := Critical(0), t := A_TickCount + 500
			while ols.Count && A_TickCount < t
				Sleep(-1)
			Critical(prev)
			DllCall('httpapi\HttpCloseRequestQueue', 'ptr', this.DeleteProp('Ptr'))
		}
	}

	class UrlGroup {
		static Prototype._id := 0
		__New(sessionId, requestQueue, timeout) {
			if r := DllCall('httpapi\HttpCreateUrlGroup', 'int64', sessionId, 'int64*', &urlGroupId := 0, 'uint', 0)
				Throw OSError(r)
			; HttpServerBindingProperty
			NumPut('ptr', 1, 'ptr', requestQueue.Ptr, info := Buffer(sz := 2 * A_PtrSize))
			if r := DllCall('httpapi\HttpSetUrlGroupProperty', 'int64', this._id := urlGroupId, 'int', 7, 'ptr', info, 'uint', sz)
				Throw OSError(r)
			; HttpServerTimeoutsProperty
			NumPut('uint', 1,
				'ushort', timeout,  ; EntityBody
				'ushort', timeout,  ; DrainEntityBody
				'ushort', timeout,  ; RequestQueue
				'ushort', timeout,  ; IdleConnection
				'ushort', timeout,  ; HeaderWait
				info := Buffer(sz := 20, 0))
			if r := DllCall('httpapi\HttpSetUrlGroupProperty', 'int64', urlGroupId, 'int', 3, 'ptr', info, 'uint', sz)
				Throw OSError(r)
			this._handlers := Map()
		}
		__Delete() {
			if this._id
				this.Remove(), DllCall('httpapi\HttpCloseUrlGroup', 'int64', this.DeleteProp('_id'))
		}
		Add(url, handler) {
			if r := DllCall('httpapi\HttpAddUrlToUrlGroup', 'int64', this._id, 'wstr', url, 'int64', ObjPtr(handler), 'uint', 0)
				Throw OSError(r, , r == 5 ? 'Listening on this URL may require administrator privileges!' : url)
			this._handlers[url] := handler
		}
		Remove(url?) {
			if !IsSet(url)
				DllCall('httpapi\HttpRemoveUrlFromUrlGroup', 'int64', this._id, 'ptr', 0, 'uint', 1), this._handlers.Clear()
			else if r := DllCall('httpapi\HttpRemoveUrlFromUrlGroup', 'int64', this._id, 'wstr', url, 'uint', 0)
				Throw OSError(r)
			else this._handlers.Delete(url)
		}
	}
	;@endregion
}

; Persistent()
; hs := HttpServer()
; hs.Add('http://127.0.0.1:1212/', handler)
; ; Monitor all IPs on the current computer, requiring administrator privileges
; ; hs.Add('http://+:1212/', handler)
; handler(req, rsp) {
; 	switch req.rawurl {
; 		case '/upload': rsp['Content-Type'] := 'application/json', rsp(req.Content)
;		case '/ws': WebSocketSession(req, rsp).OnMessage := (this, data) => this.Send(data)
; 		case '/': rsp('<body><form action="/upload" method="POST" enctype="multipart/form-data"><div>username<input type="text" name="username"></div><div>password<input type="text" name="password"></div><div><button type="submit">submit</button></div></form></body>')
; 		default: rsp(, 404)
; 	}
; }
