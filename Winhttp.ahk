/************************************************************************
 * @description WinHttp.dll class wrapper
 * @file WinHttp.ahk
 * @author thqby
 * @date 2021/10/04
 * @version 0.0.1
 ***********************************************************************/


class WinHttp {
	; flags for WinHttpOpen():
	static FLAG_ASYNC := 0x10000000	; this session is asynchronous (where supported)

	; flags for WinHttpOpenRequest():
	static FLAG_SECURE := 0x00800000	; use SSL if applicable (HTTPS)
	static FLAG_ESCAPE_PERCENT := 0x00000004	; if escaping enabled, escape percent as well
	static FLAG_NULL_CODEPAGE := 0x00000008	; assume all symbols are ASCII, use fast convertion
	static FLAG_BYPASS_PROXY_CACHE := 0x00000100	; add "pragma: no-cache" request header
	static FLAG_REFRESH := WinHttp.FLAG_BYPASS_PROXY_CACHE
	static FLAG_ESCAPE_DISABLE := 0x00000040	; disable escaping
	static FLAG_ESCAPE_DISABLE_QUERY := 0x00000080	; if escaping enabled escape path part, but do not escape query
	static AUTOPROXY_AUTO_DETECT := 0x00000001
	static AUTOPROXY_CONFIG_URL := 0x00000002
	static AUTOPROXY_HOST_KEEPCASE := 0x00000004
	static AUTOPROXY_HOST_LOWERCASE := 0x00000008
	static AUTOPROXY_ALLOW_AUTOCONFIG := 0x00000100
	static AUTOPROXY_ALLOW_STATIC := 0x00000200
	static AUTOPROXY_ALLOW_CM := 0x00000400
	static AUTOPROXY_RUN_INPROCESS := 0x00010000
	static AUTOPROXY_RUN_OUTPROCESS_ONLY := 0x00020000
	static AUTOPROXY_NO_DIRECTACCESS := 0x00040000
	static AUTOPROXY_NO_CACHE_CLIENT := 0x00080000
	static AUTOPROXY_NO_CACHE_SVC := 0x00100000
	static AUTOPROXY_SORT_RESULTS := 0x00400000

	; Flags for dwAutoDetectFlags
	static AUTO_DETECT_TYPE_DHCP := 0x00000001
	static AUTO_DETECT_TYPE_DNS_A := 0x00000002
	static TIME_FORMAT_BUFSIZE := 62
	static OPTION_CALLBACK := 1
	static FIRST_OPTION := WinHttp.OPTION_CALLBACK
	static OPTION_RESOLVE_TIMEOUT := 2
	static OPTION_CONNECT_TIMEOUT := 3
	static OPTION_CONNECT_RETRIES := 4
	static OPTION_SEND_TIMEOUT := 5
	static OPTION_RECEIVE_TIMEOUT := 6
	static OPTION_RECEIVE_RESPONSE_TIMEOUT := 7
	static OPTION_HANDLE_TYPE := 9
	static OPTION_READ_BUFFER_SIZE := 12
	static OPTION_WRITE_BUFFER_SIZE := 13
	static OPTION_PARENT_HANDLE := 21
	static OPTION_EXTENDED_ERROR := 24
	static OPTION_SECURITY_FLAGS := 31
	static OPTION_SECURITY_CERTIFICATE_STRUCT := 32
	static OPTION_URL := 34
	static OPTION_SECURITY_KEY_BITNESS := 36
	static OPTION_PROXY := 38
	static OPTION_PROXY_RESULT_ENTRY := 39
	static OPTION_USER_AGENT := 41
	static OPTION_CONTEXT_VALUE := 45
	static OPTION_CLIENT_CERT_CONTEXT := 47
	static OPTION_REQUEST_PRIORITY := 58
	static OPTION_HTTP_VERSION := 59
	static OPTION_DISABLE_FEATURE := 63
	static OPTION_CODEPAGE := 68
	static OPTION_MAX_CONNS_PER_SERVER := 73
	static OPTION_MAX_CONNS_PER_1_0_SERVER := 74
	static OPTION_AUTOLOGON_POLICY := 77
	static OPTION_SERVER_CERT_CONTEXT := 78
	static OPTION_ENABLE_FEATURE := 79
	static OPTION_WORKER_THREAD_COUNT := 80
	static OPTION_PASSPORT_COBRANDING_TEXT := 81
	static OPTION_PASSPORT_COBRANDING_URL := 82
	static OPTION_CONFIGURE_PASSPORT_AUTH := 83
	static OPTION_SECURE_PROTOCOLS := 84
	static OPTION_ENABLETRACING := 85
	static OPTION_PASSPORT_SIGN_OUT := 86
	static OPTION_PASSPORT_RETURN_URL := 87
	static OPTION_REDIRECT_POLICY := 88
	static OPTION_MAX_HTTP_AUTOMATIC_REDIRECTS := 89
	static OPTION_MAX_HTTP_STATUS_CONTINUE := 90
	static OPTION_MAX_RESPONSE_HEADER_SIZE := 91
	static OPTION_MAX_RESPONSE_DRAIN_SIZE := 92
	static OPTION_CONNECTION_INFO := 93
	static OPTION_CLIENT_CERT_ISSUER_LIST := 94
	static OPTION_SPN := 96
	static OPTION_GLOBAL_PROXY_CREDS := 97
	static OPTION_GLOBAL_SERVER_CREDS := 98
	static OPTION_UNLOAD_NOTIFY_EVENT := 99
	static OPTION_REJECT_USERPWD_IN_URL := 100
	static OPTION_USE_GLOBAL_SERVER_CREDENTIALS := 101
	static OPTION_RECEIVE_PROXY_CONNECT_RESPONSE := 103
	static OPTION_IS_PROXY_CONNECT_RESPONSE := 104
	static OPTION_SERVER_SPN_USED := 106
	static OPTION_PROXY_SPN_USED := 107
	static OPTION_SERVER_CBT := 108
	static OPTION_UNSAFE_HEADER_PARSING := 110
	static OPTION_ASSURED_NON_BLOCKING_CALLBACKS := 111
	static OPTION_UPGRADE_TO_WEB_SOCKET := 114
	static OPTION_WEB_SOCKET_CLOSE_TIMEOUT := 115
	static OPTION_WEB_SOCKET_KEEPALIVE_INTERVAL := 116
	static OPTION_DECOMPRESSION := 118
	static OPTION_WEB_SOCKET_RECEIVE_BUFFER_SIZE := 122
	static OPTION_WEB_SOCKET_SEND_BUFFER_SIZE := 123
	static OPTION_TCP_PRIORITY_HINT := 128
	static OPTION_CONNECTION_FILTER := 131
	static OPTION_ENABLE_HTTP_PROTOCOL := 133
	static OPTION_HTTP_PROTOCOL_USED := 134
	static OPTION_KDC_PROXY_SETTINGS := 136
	static OPTION_ENCODE_EXTRA := 138
	static OPTION_DISABLE_STREAM_QUEUE := 139
	static LAST_OPTION := WinHttp.OPTION_DISABLE_STREAM_QUEUE
	static OPTION_USERNAME := 0x1000
	static OPTION_PASSWORD := 0x1001
	static OPTION_PROXY_USERNAME := 0x1002
	static OPTION_PROXY_PASSWORD := 0x1003
	static CONNS_PER_SERVER_UNLIMITED := 0xFFFFFFFF
	static DECOMPRESSION_FLAG_GZIP := 0x00000001
	static DECOMPRESSION_FLAG_DEFLATE := 0x00000002
	static DECOMPRESSION_FLAG_ALL := WinHttp.DECOMPRESSION_FLAG_GZIP | WinHttp.DECOMPRESSION_FLAG_DEFLATE
	static PROTOCOL_FLAG_HTTP2 := 0x1
	static PROTOCOL_MASK := (WinHttp.PROTOCOL_FLAG_HTTP2)
	static AUTOLOGON_SECURITY_LEVEL_MEDIUM := 0
	static AUTOLOGON_SECURITY_LEVEL_LOW := 1
	static AUTOLOGON_SECURITY_LEVEL_HIGH := 2
	static AUTOLOGON_SECURITY_LEVEL_DEFAULT := WinHttp.AUTOLOGON_SECURITY_LEVEL_MEDIUM
	static OPTION_REDIRECT_POLICY_NEVER := 0
	static OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP := 1
	static OPTION_REDIRECT_POLICY_ALWAYS := 2
	static OPTION_REDIRECT_POLICY_LAST := WinHttp.OPTION_REDIRECT_POLICY_ALWAYS
	static OPTION_REDIRECT_POLICY_DEFAULT := WinHttp.OPTION_REDIRECT_POLICY_DISALLOW_HTTPS_TO_HTTP
	static DISABLE_PASSPORT_AUTH := 0x00000000
	static ENABLE_PASSPORT_AUTH := 0x10000000
	static DISABLE_PASSPORT_KEYRING := 0x20000000
	static ENABLE_PASSPORT_KEYRING := 0x40000000
	static DISABLE_COOKIES := 0x00000001
	static DISABLE_REDIRECTS := 0x00000002
	static DISABLE_AUTHENTICATION := 0x00000004
	static DISABLE_KEEP_ALIVE := 0x00000008
	static ENABLE_SSL_REVOCATION := 0x00000001
	static ENABLE_SSL_REVERT_IMPERSONATION := 0x00000002
	static DISABLE_SPN_SERVER_PORT := 0x00000000
	static ENABLE_SPN_SERVER_PORT := 0x00000001
	static OPTION_SPN_MASK := WinHttp.ENABLE_SPN_SERVER_PORT
	static HANDLE_TYPE_SESSION := 1
	static HANDLE_TYPE_CONNECT := 2
	static HANDLE_TYPE_REQUEST := 3
	static AUTH_SCHEME_BASIC := 0x00000001
	static AUTH_SCHEME_NTLM := 0x00000002
	static AUTH_SCHEME_PASSPORT := 0x00000004
	static AUTH_SCHEME_DIGEST := 0x00000008
	static AUTH_SCHEME_NEGOTIATE := 0x00000010
	static AUTH_TARGET_SERVER := 0x00000000
	static AUTH_TARGET_PROXY := 0x00000001
	static CALLBACK_STATUS_FLAG_CERT_REV_FAILED := 0x00000001
	static CALLBACK_STATUS_FLAG_INVALID_CERT := 0x00000002
	static CALLBACK_STATUS_FLAG_CERT_REVOKED := 0x00000004
	static CALLBACK_STATUS_FLAG_INVALID_CA := 0x00000008
	static CALLBACK_STATUS_FLAG_CERT_CN_INVALID := 0x00000010
	static CALLBACK_STATUS_FLAG_CERT_DATE_INVALID := 0x00000020
	static CALLBACK_STATUS_FLAG_CERT_WRONG_USAGE := 0x00000040
	static CALLBACK_STATUS_FLAG_SECURITY_CHANNEL_ERROR := 0x80000000
	static FLAG_SECURE_PROTOCOL_SSL2 := 0x00000008
	static FLAG_SECURE_PROTOCOL_SSL3 := 0x00000020
	static FLAG_SECURE_PROTOCOL_TLS1 := 0x00000080
	static FLAG_SECURE_PROTOCOL_TLS1_1 := 0x00000200
	static FLAG_SECURE_PROTOCOL_TLS1_2 := 0x00000800
	static FLAG_SECURE_PROTOCOL_ALL := WinHttp.FLAG_SECURE_PROTOCOL_SSL2 | WinHttp.FLAG_SECURE_PROTOCOL_SSL3 | WinHttp.FLAG_SECURE_PROTOCOL_TLS1
	static CALLBACK_STATUS_RESOLVING_NAME := 0x00000001
	static CALLBACK_STATUS_NAME_RESOLVED := 0x00000002
	static CALLBACK_STATUS_CONNECTING_TO_SERVER := 0x00000004
	static CALLBACK_STATUS_CONNECTED_TO_SERVER := 0x00000008
	static CALLBACK_STATUS_SENDING_REQUEST := 0x00000010
	static CALLBACK_STATUS_REQUEST_SENT := 0x00000020
	static CALLBACK_STATUS_RECEIVING_RESPONSE := 0x00000040
	static CALLBACK_STATUS_RESPONSE_RECEIVED := 0x00000080
	static CALLBACK_STATUS_CLOSING_CONNECTION := 0x00000100
	static CALLBACK_STATUS_CONNECTION_CLOSED := 0x00000200
	static CALLBACK_STATUS_HANDLE_CREATED := 0x00000400
	static CALLBACK_STATUS_HANDLE_CLOSING := 0x00000800
	static CALLBACK_STATUS_DETECTING_PROXY := 0x00001000
	static CALLBACK_STATUS_REDIRECT := 0x00004000
	static CALLBACK_STATUS_INTERMEDIATE_RESPONSE := 0x00008000
	static CALLBACK_STATUS_SECURE_FAILURE := 0x00010000
	static CALLBACK_STATUS_HEADERS_AVAILABLE := 0x00020000
	static CALLBACK_STATUS_DATA_AVAILABLE := 0x00040000
	static CALLBACK_STATUS_READ_COMPLETE := 0x00080000
	static CALLBACK_STATUS_WRITE_COMPLETE := 0x00100000
	static CALLBACK_STATUS_REQUEST_ERROR := 0x00200000
	static CALLBACK_STATUS_SENDREQUEST_COMPLETE := 0x00400000
	static CALLBACK_STATUS_GETPROXYFORURL_COMPLETE := 0x01000000
	static CALLBACK_STATUS_CLOSE_COMPLETE := 0x02000000
	static CALLBACK_STATUS_SHUTDOWN_COMPLETE := 0x04000000
	static CALLBACK_STATUS_SETTINGS_WRITE_COMPLETE := 0x10000000
	static CALLBACK_STATUS_SETTINGS_READ_COMPLETE := 0x20000000
	static CALLBACK_FLAG_RESOLVE_NAME := (WinHttp.CALLBACK_STATUS_RESOLVING_NAME | WinHttp.CALLBACK_STATUS_NAME_RESOLVED)
	static CALLBACK_FLAG_CONNECT_TO_SERVER := (WinHttp.CALLBACK_STATUS_CONNECTING_TO_SERVER | WinHttp.CALLBACK_STATUS_CONNECTED_TO_SERVER)
	static CALLBACK_FLAG_SEND_REQUEST := (WinHttp.CALLBACK_STATUS_SENDING_REQUEST | WinHttp.CALLBACK_STATUS_REQUEST_SENT)
	static CALLBACK_FLAG_RECEIVE_RESPONSE := (WinHttp.CALLBACK_STATUS_RECEIVING_RESPONSE | WinHttp.CALLBACK_STATUS_RESPONSE_RECEIVED)
	static CALLBACK_FLAG_CLOSE_CONNECTION := (WinHttp.CALLBACK_STATUS_CLOSING_CONNECTION | WinHttp.CALLBACK_STATUS_CONNECTION_CLOSED)
	static CALLBACK_FLAG_HANDLES := (WinHttp.CALLBACK_STATUS_HANDLE_CREATED | WinHttp.CALLBACK_STATUS_HANDLE_CLOSING)
	static CALLBACK_FLAG_DETECTING_PROXY := WinHttp.CALLBACK_STATUS_DETECTING_PROXY
	static CALLBACK_FLAG_REDIRECT := WinHttp.CALLBACK_STATUS_REDIRECT
	static CALLBACK_FLAG_INTERMEDIATE_RESPONSE := WinHttp.CALLBACK_STATUS_INTERMEDIATE_RESPONSE
	static CALLBACK_FLAG_SECURE_FAILURE := WinHttp.CALLBACK_STATUS_SECURE_FAILURE
	static CALLBACK_FLAG_SENDREQUEST_COMPLETE := WinHttp.CALLBACK_STATUS_SENDREQUEST_COMPLETE
	static CALLBACK_FLAG_HEADERS_AVAILABLE := WinHttp.CALLBACK_STATUS_HEADERS_AVAILABLE
	static CALLBACK_FLAG_DATA_AVAILABLE := WinHttp.CALLBACK_STATUS_DATA_AVAILABLE
	static CALLBACK_FLAG_READ_COMPLETE := WinHttp.CALLBACK_STATUS_READ_COMPLETE
	static CALLBACK_FLAG_WRITE_COMPLETE := WinHttp.CALLBACK_STATUS_WRITE_COMPLETE
	static CALLBACK_FLAG_REQUEST_ERROR := WinHttp.CALLBACK_STATUS_REQUEST_ERROR
	static CALLBACK_FLAG_GETPROXYFORURL_COMPLETE := WinHttp.CALLBACK_STATUS_GETPROXYFORURL_COMPLETE
	static CALLBACK_FLAG_ALL_COMPLETIONS := WinHttp.CALLBACK_STATUS_SENDREQUEST_COMPLETE | WinHttp.CALLBACK_STATUS_HEADERS_AVAILABLE | WinHttp.CALLBACK_STATUS_DATA_AVAILABLE | WinHttp.CALLBACK_STATUS_READ_COMPLETE | WinHttp.CALLBACK_STATUS_WRITE_COMPLETE | WinHttp.CALLBACK_STATUS_REQUEST_ERROR | WinHttp.CALLBACK_STATUS_GETPROXYFORURL_COMPLETE
	static CALLBACK_FLAG_ALL_NOTIFICATIONS := 0xffffffff
	static INVALID_STATUS_CALLBACK := -1
	static QUERY_MIME_VERSION := 0
	static QUERY_CONTENT_TYPE := 1
	static QUERY_CONTENT_TRANSFER_ENCODING := 2
	static QUERY_CONTENT_ID := 3
	static QUERY_CONTENT_DESCRIPTION := 4
	static QUERY_CONTENT_LENGTH := 5
	static QUERY_CONTENT_LANGUAGE := 6
	static QUERY_ALLOW := 7
	static QUERY_PUBLIC := 8
	static QUERY_DATE := 9
	static QUERY_EXPIRES := 10
	static QUERY_LAST_MODIFIED := 11
	static QUERY_MESSAGE_ID := 12
	static QUERY_URI := 13
	static QUERY_DERIVED_FROM := 14
	static QUERY_COST := 15
	static QUERY_LINK := 16
	static QUERY_PRAGMA := 17
	static QUERY_VERSION := 18	; special: part of status line
	static QUERY_STATUS_CODE := 19	; special: part of status line
	static QUERY_STATUS_TEXT := 20	; special: part of status line
	static QUERY_RAW_HEADERS := 21	; special: all headers as ASCIIZ
	static QUERY_RAW_HEADERS_CRLF := 22	; special: all headers
	static QUERY_CONNECTION := 23
	static QUERY_ACCEPT := 24
	static QUERY_ACCEPT_CHARSET := 25
	static QUERY_ACCEPT_ENCODING := 26
	static QUERY_ACCEPT_LANGUAGE := 27
	static QUERY_AUTHORIZATION := 28
	static QUERY_CONTENT_ENCODING := 29
	static QUERY_FORWARDED := 30
	static QUERY_FROM := 31
	static QUERY_IF_MODIFIED_SINCE := 32
	static QUERY_LOCATION := 33
	static QUERY_ORIG_URI := 34
	static QUERY_REFERER := 35
	static QUERY_RETRY_AFTER := 36
	static QUERY_SERVER := 37
	static QUERY_TITLE := 38
	static QUERY_USER_AGENT := 39
	static QUERY_WWW_AUTHENTICATE := 40
	static QUERY_PROXY_AUTHENTICATE := 41
	static QUERY_ACCEPT_RANGES := 42
	static QUERY_SET_COOKIE := 43
	static QUERY_COOKIE := 44
	static QUERY_REQUEST_METHOD := 45	; special: GET/POST etc.
	static QUERY_REFRESH := 46
	static QUERY_CONTENT_DISPOSITION := 47
	static QUERY_AGE := 48
	static QUERY_CACHE_CONTROL := 49
	static QUERY_CONTENT_BASE := 50
	static QUERY_CONTENT_LOCATION := 51
	static QUERY_CONTENT_MD5 := 52
	static QUERY_CONTENT_RANGE := 53
	static QUERY_ETAG := 54
	static QUERY_HOST := 55
	static QUERY_IF_MATCH := 56
	static QUERY_IF_NONE_MATCH := 57
	static QUERY_IF_RANGE := 58
	static QUERY_IF_UNMODIFIED_SINCE := 59
	static QUERY_MAX_FORWARDS := 60
	static QUERY_PROXY_AUTHORIZATION := 61
	static QUERY_RANGE := 62
	static QUERY_TRANSFER_ENCODING := 63
	static QUERY_UPGRADE := 64
	static QUERY_VARY := 65
	static QUERY_VIA := 66
	static QUERY_WARNING := 67
	static QUERY_EXPECT := 68
	static QUERY_PROXY_CONNECTION := 69
	static QUERY_UNLESS_MODIFIED_SINCE := 70
	static QUERY_PROXY_SUPPORT := 75
	static QUERY_AUTHENTICATION_INFO := 76
	static QUERY_PASSPORT_URLS := 77
	static QUERY_PASSPORT_CONFIG := 78
	static QUERY_MAX := 78
	static QUERY_CUSTOM := 65535
	static QUERY_FLAG_REQUEST_HEADERS := 0x80000000
	static QUERY_FLAG_SYSTEMTIME := 0x40000000
	static QUERY_FLAG_NUMBER := 0x20000000
	static QUERY_FLAG_NUMBER64 := 0x08000000

	; flags for CrackUrl() and CombineUrl()
	static ICU_NO_ENCODE := 0x20000000	; Don't convert unsafe characters to escape sequence
	static ICU_DECODE := 0x10000000	; Convert %XX escape sequences to characters
	static ICU_NO_META := 0x08000000	; Don't convert .. etc. meta path sequences
	static ICU_ENCODE_SPACES_ONLY := 0x04000000	; Encode spaces only
	static ICU_BROWSER_MODE := 0x02000000	; Special encode/decode rules for browser
	static ICU_ENCODE_PERCENT := 0x00001000	; Encode any percent (ASCII25)

	; flags for WinHttpCrackUrl() and WinHttpCreateUrl()
	static ACCESS_TYPE_DEFAULT_PROXY := 0
	static ACCESS_TYPE_NO_PROXY := 1
	static ACCESS_TYPE_NAMED_PROXY := 3
	static ACCESS_TYPE_AUTOMATIC_PROXY := 4
	static NO_PROXY_NAME := 0
	static NO_PROXY_BYPASS := 0
	static NO_CLIENT_CERT_CONTEXT := 0
	static NO_REFERER := 0
	static DEFAULT_ACCEPT_TYPES := 0
	static ADDREQ_INDEX_MASK := 0x0000FFFF
	static ADDREQ_FLAGS_MASK := 0xFFFF0000
	static ADDREQ_FLAG_ADD_IF_NEW := 0x10000000
	static ADDREQ_FLAG_ADD := 0x20000000
	static ADDREQ_FLAG_COALESCE_WITH_COMMA := 0x40000000
	static ADDREQ_FLAG_COALESCE_WITH_SEMICOLON := 0x01000000
	static ADDREQ_FLAG_COALESCE := WinHttp.ADDREQ_FLAG_COALESCE_WITH_COMMA
	static ADDREQ_FLAG_REPLACE := 0x80000000
	static IGNORE_REQUEST_TOTAL_LENGTH := 0
	static NO_ADDITIONAL_HEADERS := 0
	static NO_REQUEST_DATA := 0
	static HEADER_NAME_BY_INDEX := 0
	static NO_OUTPUT_BUFFER := 0
	static NO_HEADER_INDEX := 0

	; error
	static ERROR_BASE := 12000
	static ERROR_OUT_OF_HANDLES := (WinHttp.ERROR_BASE + 1)
	static ERROR_TIMEOUT := (WinHttp.ERROR_BASE + 2)
	static ERROR_INTERNAL_ERROR := (WinHttp.ERROR_BASE + 4)
	static ERROR_INVALID_URL := (WinHttp.ERROR_BASE + 5)
	static ERROR_UNRECOGNIZED_SCHEME := (WinHttp.ERROR_BASE + 6)
	static ERROR_NAME_NOT_RESOLVED := (WinHttp.ERROR_BASE + 7)
	static ERROR_INVALID_OPTION := (WinHttp.ERROR_BASE + 9)
	static ERROR_OPTION_NOT_SETTABLE := (WinHttp.ERROR_BASE + 11)
	static ERROR_SHUTDOWN := (WinHttp.ERROR_BASE + 12)
	static ERROR_LOGIN_FAILURE := (WinHttp.ERROR_BASE + 15)
	static ERROR_OPERATION_CANCELLED := (WinHttp.ERROR_BASE + 17)
	static ERROR_INCORRECT_HANDLE_TYPE := (WinHttp.ERROR_BASE + 18)
	static ERROR_INCORRECT_HANDLE_STATE := (WinHttp.ERROR_BASE + 19)
	static ERROR_CANNOT_CONNECT := (WinHttp.ERROR_BASE + 29)
	static ERROR_CONNECTION_ERROR := (WinHttp.ERROR_BASE + 30)
	static ERROR_RESEND_REQUEST := (WinHttp.ERROR_BASE + 32)
	static ERROR_CLIENT_AUTH_CERT_NEEDED := (WinHttp.ERROR_BASE + 44)
	static ERROR_CANNOT_CALL_BEFORE_OPEN := (WinHttp.ERROR_BASE + 100)
	static ERROR_CANNOT_CALL_BEFORE_SEND := (WinHttp.ERROR_BASE + 101)
	static ERROR_CANNOT_CALL_AFTER_SEND := (WinHttp.ERROR_BASE + 102)
	static ERROR_CANNOT_CALL_AFTER_OPEN := (WinHttp.ERROR_BASE + 103)
	static ERROR_HEADER_NOT_FOUND := (WinHttp.ERROR_BASE + 150)
	static ERROR_INVALID_SERVER_RESPONSE := (WinHttp.ERROR_BASE + 152)
	static ERROR_INVALID_HEADER := (WinHttp.ERROR_BASE + 153)
	static ERROR_INVALID_QUERY_REQUEST := (WinHttp.ERROR_BASE + 154)
	static ERROR_HEADER_ALREADY_EXISTS := (WinHttp.ERROR_BASE + 155)
	static ERROR_REDIRECT_FAILED := (WinHttp.ERROR_BASE + 156)
	static ERROR_AUTO_PROXY_SERVICE_ERROR := (WinHttp.ERROR_BASE + 178)
	static ERROR_BAD_AUTO_PROXY_SCRIPT := (WinHttp.ERROR_BASE + 166)
	static ERROR_UNABLE_TO_DOWNLOAD_SCRIPT := (WinHttp.ERROR_BASE + 167)
	static ERROR_UNHANDLED_SCRIPT_TYPE := (WinHttp.ERROR_BASE + 176)
	static ERROR_SCRIPT_EXECUTION_ERROR := (WinHttp.ERROR_BASE + 177)
	static ERROR_NOT_INITIALIZED := (WinHttp.ERROR_BASE + 172)
	static ERROR_SECURE_FAILURE := (WinHttp.ERROR_BASE + 175)
	static ERROR_SECURE_CERT_DATE_INVALID := (WinHttp.ERROR_BASE + 37)
	static ERROR_SECURE_CERT_CN_INVALID := (WinHttp.ERROR_BASE + 38)
	static ERROR_SECURE_INVALID_CA := (WinHttp.ERROR_BASE + 45)
	static ERROR_SECURE_CERT_REV_FAILED := (WinHttp.ERROR_BASE + 57)
	static ERROR_SECURE_CHANNEL_ERROR := (WinHttp.ERROR_BASE + 157)
	static ERROR_SECURE_INVALID_CERT := (WinHttp.ERROR_BASE + 169)
	static ERROR_SECURE_CERT_REVOKED := (WinHttp.ERROR_BASE + 170)
	static ERROR_SECURE_CERT_WRONG_USAGE := (WinHttp.ERROR_BASE + 179)
	static ERROR_AUTODETECTION_FAILED := (WinHttp.ERROR_BASE + 180)
	static ERROR_HEADER_COUNT_EXCEEDED := (WinHttp.ERROR_BASE + 181)
	static ERROR_HEADER_SIZE_OVERFLOW := (WinHttp.ERROR_BASE + 182)
	static ERROR_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW := (WinHttp.ERROR_BASE + 183)
	static ERROR_RESPONSE_DRAIN_OVERFLOW := (WinHttp.ERROR_BASE + 184)
	static ERROR_CLIENT_CERT_NO_PRIVATE_KEY := (WinHttp.ERROR_BASE + 185)
	static ERROR_CLIENT_CERT_NO_ACCESS_PRIVATE_KEY := (WinHttp.ERROR_BASE + 186)
	static ERROR_CLIENT_AUTH_CERT_NEEDED_PROXY := (WinHttp.ERROR_BASE + 187)
	static ERROR_SECURE_FAILURE_PROXY := (WinHttp.ERROR_BASE + 188)
	static ERROR_LAST := (WinHttp.ERROR_BASE + 188)
	static RESET_STATE := 0x00000001
	static RESET_SWPAD_CURRENT_NETWORK := 0x00000002
	static RESET_SWPAD_ALL := 0x00000004
	static RESET_SCRIPT_CACHE := 0x00000008
	static RESET_ALL := 0x0000FFFF
	static RESET_NOTIFY_NETWORK_CHANGED := 0x00010000
	static RESET_OUT_OF_PROC := 0x00020000
	static RESET_DISCARD_RESOLVERS := 0x00040000
	static WEB_SOCKET_MAX_CLOSE_REASON_LENGTH := 123
	static WEB_SOCKET_MIN_KEEPALIVE_VALUE := 15000
	Ptr := 0, async := false, UserAgent := '', _statuscb := 0
	__New(UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.68', dwFlags := 0) {
		pwszUserAgent := UserAgent = '' ? 0 : StrPtr(UserAgent)
		if !hSession := DllCall('Winhttp\WinHttpOpen', 'ptr', pwszUserAgent, 'uint', 0, 'ptr', 0, 'ptr', 0, 'uint', dwFlags, 'ptr')
			throw
		this.Ptr := hSession, this.dwFlags := dwFlags, this.UserAgent := UserAgent
		if (WinHttp.FLAG_ASYNC & dwFlags)
			this.async := true
		this._statuscb := CallbackCreate(StatusCallback)
		StatusCallback(hInternet, dwContext, dwInternetStatus, lpvStatusInformation, dwStatusInformationLength) {
			critical
			; OutputDebug(dwInternetStatus '`n')
			if (IsSet(dwContext) && IsSet(hInternet) && dwContext && (req := ObjFromPtrAddRef(dwContext)) && hInternet = req.Ptr) {
				switch dwInternetStatus {
					case WinHttp.CALLBACK_STATUS_SENDREQUEST_COMPLETE:
						req.readyState := 3
						if req.ReceiveResponse()
							req.readyState := 4
					case WinHttp.CALLBACK_STATUS_HEADERS_AVAILABLE:
						DllCall('Winhttp\WinHttpQueryDataAvailable', 'ptr', hInternet, 'uint*', &size := 0, 'int')
						req.read()
					case WinHttp.CALLBACK_STATUS_DATA_AVAILABLE:
						req.onreadystatechange()
					case WinHttp.CALLBACK_STATUS_REQUEST_ERROR:
						dwResult := NumGet(lpvStatusInformation, 'ptr')
						dwError := NumGet(lpvStatusInformation, A_PtrSize, 'uint')
					case WinHttp.CALLBACK_STATUS_READ_COMPLETE:

				}
			}
			req := ''
			return 0
		}
	}
	__Delete() {
		WinHttp.CloseHandle(this.Ptr)
		if (this._statuscb)
			CallbackFree(this._statuscb), this._statuscb := 0
	}
	openRequset(Method, Url) {
		static _ports := {ftp: 21, http: 80, https: 443}
		if (!RegExMatch(Url, '^((?<SCHEME>\w+)://)?((?<USERNAME>[^:]+):(?<PASSWORD>.+)@)?(?<HOST>[^/:]+)(:(?<PORT>\d+))?(?<PATH>/.*)?$', &m))
			throw Error('无效的url')
		port := Integer(m.PORT || (_ports.HasOwnProp(m.SCHEME) ? (_ports.%(m.SCHEME)%) : m.SCHEME = '' ? 80 : 0))
		hConnect := WinHttp.Connect.Call(this.Ptr, m.HOST, port)
		dwFlags := m.SCHEME = 'https' ? WinHttp.FLAG_SECURE : 0
		pwszReferrer := 0, pwszVersion := 0
		if !(hRequest := DllCall('Winhttp\WinHttpOpenRequest', 'ptr', hConnect, 'wstr', StrUpper(Method), 'wstr', m.PATH, 'ptr', pwszVersion, 'ptr', pwszReferrer, 'ptr', 0, 'uint', dwFlags, 'ptr'))
			throw Error('打开请求失败')
		req := WinHttp.Request.Call(hRequest, hConnect, this.async)
		if (this.async) {
			WinHttp.SetStatusCallback(req.Ptr, this._statuscb, WinHttp.CALLBACK_FLAG_ALL_COMPLETIONS)
			val := Buffer(A_PtrSize), NumPut('ptr', ObjPtr(req), val), req.option[WinHttp.OPTION_CONTEXT_VALUE] := val
		}
		return req
	}
	GetProxyForUrl(lpcwszUrl, pAutoProxyOptions, pProxyInfo) => DllCall('Winhttp\WinHttpGetProxyForUrl', 'ptr', this, 'wstr', lpcwszUrl, 'ptr', pAutoProxyOptions, 'ptr', pProxyInfo, 'int')
	setAutoLogonPolicy(AutoLogonPolicy) {

	}
	setClientCertificate(ClientCertificate) {

	}
	setProxy(ProxySetting, ProxyServer, BypassList := '<local>') {
		dwAccessType := ProxySetting = 2 ? 3 : ProxySetting
		lpszProxy := StrPtr(ProxyServer), lpszProxyBypass := StrPtr(BypassList)
		if (A_PtrSize = 8)
			ProxyInfo := Buffer(24), NumPut('uint', dwAccessType, ProxyInfo), NumPut('ptr', lpszProxy, 'ptr', lpszProxyBypass, ProxyInfo, 8)
		else
			ProxyInfo := Buffer(12), NumPut('uint', dwAccessType, 'ptr', lpszProxy, 'ptr', lpszProxyBypass, ProxyInfo)
		if (ret := WinHttp.SetOption(this, WinHttp.OPTION_PROXY, ProxyInfo))
			throw Error(ret)
	}
	setTimeouts(ResolveTimeout := 0, ConnectTimeout := 60000, SendTimeout := 30000, ReceiveTimeout := 30000) {
		return DllCall('Winhttp\WinHttpSetTimeouts', 'ptr', this, 'int', ResolveTimeout, 'int', ConnectTimeout, 'int', SendTimeout, 'int', ReceiveTimeout, 'int') ? 0 : A_LastError
	}
	option[dwOption] {
		get => WinHttp.QueryOption(this.Ptr, dwOption)
		set {
			if (ret := WinHttp.SetOption(this.Ptr, dwOption, Value))
				throw Error(ret)
		}
	}
	static CheckPlatform() => DllCall('Winhttp\WinHttpCheckPlatform', 'int')
	static CloseHandle(hInternet) => DllCall('Winhttp\WinHttpCloseHandle', 'ptr', hInternet, 'int')
	static CrackUrl(Url) {
		if (A_PtrSize = 8) {
			buf := Buffer(104), NumPut('uint', 104, buf), NumPut('uint', -1, buf, 32), NumPut('uint', -1, buf, 48)
			NumPut('uint', -1, buf, 64), NumPut('uint', -1, buf, 80), NumPut('uint', -1, buf, 96)
		} else {
			buf := Buffer(60), NumPut('uint', 60, buf), NumPut('uint', -1, buf, 20), NumPut('uint', -1, buf, 32)
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
	static QueryOption(hInternet, dwOption) {
		DllCall('Winhttp\WinHttpQueryOption', 'ptr', hInternet, 'uint', dwOption, 'ptr', 0, 'uint*', &dwBufferLength := 0, 'int')
		buf := Buffer(dwBufferLength), lpBuffer := buf.Ptr
		if !DllCall('Winhttp\WinHttpQueryOption', 'ptr', hInternet, 'uint', dwOption, 'ptr', lpBuffer, 'uint*', &dwBufferLength, 'int')
			return 0
		return buf
	}
	static SetDefaultProxyConfiguration(ProxySetting, ProxyServer, BypassList := '<local>') {
		dwAccessType := ProxySetting = 2 ? 3 : ProxySetting
		lpszProxy := StrPtr(ProxyServer), lpszProxyBypass := StrPtr(BypassList)
		if (A_PtrSize = 8)
			ProxyInfo := Buffer(24), NumPut('uint', dwAccessType, ProxyInfo), NumPut('ptr', lpszProxy, 'ptr', lpszProxyBypass, ProxyInfo, 8)
		else
			ProxyInfo := Buffer(12), NumPut('uint', dwAccessType, 'ptr', lpszProxy, 'ptr', lpszProxyBypass, ProxyInfo)
		return DllCall('Winhttp\WinHttpSetDefaultProxyConfiguration', 'ptr', ProxyInfo.Ptr, 'int') ? 0 : A_LastError
	}
	static SetOption(hInternet, dwOption, Value) {
		switch Type(Value) {
			case 'String':
				lpBuffer := StrPtr(Value), dwBufferLength := StrLen(Value) * 2
			case 'Integer':
				buf := Buffer(4), NumPut('uint', Value, buf), lpBuffer := buf.Ptr, dwBufferLength := 4
			case 'Buffer':
				lpBuffer := Value.Ptr, dwBufferLength := Value.Size
			case 'Object':
				if (Value.HasOwnProp('Ptr') && Value.HasOwnProp('Size'))
					lpBuffer := Value.Ptr, dwBufferLength := Value.Size
				else
					return 87
			default:
				return 87
		}
		return DllCall('Winhttp\WinHttpSetOption', 'ptr', hInternet, 'uint', dwOption, 'ptr', lpBuffer, 'uint', dwBufferLength, 'int') ? 0 : A_LastError
	}
	static SetStatusCallback(hInternet, lpfnInternetCallback, dwNotificationFlags) => DllCall('Winhttp\WinHttpSetStatusCallback', 'ptr', hInternet, 'ptr', lpfnInternetCallback, 'uint', dwNotificationFlags, 'uptr', 0, 'ptr')
	static TimeFromSystemTime(pst) {
		if DllCall('Winhttp\WinHttpTimeFromSystemTime', 'ptr', pst, 'ptr', pszTime := Buffer(62), 'int')
			return StrGet(pszTime, 'utf-16')
	}
	static TimeToSystemTime(Time) {
		pst := Buffer(16)
		if DllCall('Winhttp\WinHttpTimeToSystemTime', 'wstr', Time, 'ptr', pst, 'int')
			return pst
	}
	class Connect {
		Ptr := 0
		option[dwOption] {
			get => WinHttp.QueryOption(this.Ptr, dwOption)
			set {
				if (ret := WinHttp.SetOption(this.Ptr, dwOption, Value))
					throw Error(ret)
			}
		}
		__New(hSession, ServerName, nServerPort) {
			if !(hConnect := DllCall('Winhttp\WinHttpConnect', 'ptr', hSession, 'wstr', ServerName, 'ushort', nServerPort, 'uint', 0, 'ptr'))
				throw Error(A_LastError)
			this.Ptr := hConnect
		}
		__Delete() => DllCall('Winhttp\WinHttpCloseHandle', 'ptr', this, 'int')
	}

	class Request {
		Ptr := 0, hConnect := 0, async := 0, _ResponseBody := 0, _HasReceiveResponse := 0, readyState := 0, onreadystatechange := 0
		__New(hRequest, hConnect, async) {
			this.Ptr := hRequest, this.hConnect := hConnect, this.async := async
		}
		__Delete() {
			this.abort()
		}
		abort() {
			if (this.Ptr)
				WinHttp.CloseHandle(this.Ptr), this.Ptr := this.hConnect := 0
		}
		getAllResponseHeaders() {
			this.QueryHeaders(22, 0, 0, &size := 0, 0)
			if (size && (buf := Buffer(size)) && this.QueryHeaders(22, 0, buf.Ptr, &size, 0))
				return StrGet(buf, 'utf-16')
		}
		getResponseHeader(Header) {
			if (i := 0, s := '', Type(Header) = 'String') {
				this.QueryHeaders(65535, ps := StrPtr(Header), 0, &size := 0, i)
				while (size && (buf := Buffer(size)) && this.QueryHeaders(65535, ps, buf.Ptr, &size, i++))
					s .= StrGet(buf, 'utf-16'), this.QueryHeaders(65535, ps := StrPtr(Header), 0, &size := 0, i)
				return s
			} else {
				this.QueryHeaders(Header += 0, 0, 0, &size := 0, i)
				if (Header = 21) {
					buf := Buffer(size), this.QueryHeaders(Header, 0, buf.Ptr, &size, i)
					return buf
				}
				while (size && (buf := Buffer(size)) && this.QueryHeaders(Header, 0, buf.Ptr, &size, i++)) {
					s .= '`n' StrGet(buf, 'utf-16')
					this.QueryHeaders(Header += 0, 0, 0, &size := 0, i)
				}
				return LTrim(s, '`n')
			}
		}
		send(data := '') {
			static errors := Map(12002, '操作超时', 12007, '无法解析服务器的名称或地址', 12029, '无法连接')
			if ((t := Type(data)) ~= '^(Map|Object)$') {
				str := ''
				for k, v in t = 'Map' ? data : data.OwnProps()
					str .= '&' k '=' v
				data := SubStr(str, 2), str := ''
			}
			if (data = '') {
				lpOptional := 0, dwOptionalLength := 0
			} else if (Type(data) = 'Buffer')
				lpOptional := Data.Ptr, dwOptionalLength := Data.Size
			else
				lpOptional := StrPtr(data), dwOptionalLength := StrLen(data) * 2
			this.readyState := 1
			if (!DllCall('Winhttp\WinHttpSendRequest', 'ptr', this, 'ptr', 0, 'uint', 0, 'ptr', lpOptional, 'uint', dwOptionalLength, 'uint', 0, 'uptr', 0, 'int'))
				throw Error(errors.Has(err := A_LastError) ? errors[err] : err, -1)
			if (this.async)
				this.readyState := 2
			else
				this.ReceiveResponse(), this.readyState := this.responseBody ? 4 : 3
		}
		setRequestHeader(Header, Value, dwModifiers := 0x80000000) {
			return DllCall('Winhttp\WinHttpAddRequestHeaders', 'ptr', this, 'wstr', str := Trim(Header) ': ' Trim(Value), 'uint', -1, 'uint', dwModifiers, 'int') ? 0 : A_LastError
		}
		setCredentials(UserName, Password, AuthTargets, AuthScheme := 1) {
			return DllCall('Winhttp\WinHttpSetCredentials', 'ptr', this, 'uint', AuthTargets, 'uint', AuthScheme, 'wstr', UserName, 'wstr', Password, 'ptr', 0, 'int') ? 0 : A_LastError
		}
		waitForResponse(Timeout := -1, &Succeeded := 1) {
			if (this.async) {
				if (Timeout = -1) {
					while (this.readyState < 3)
						Sleep(-1)
				} else {
					t := A_TickCount + Timeout
					while (this.readyState < 3 && A_TickCount <= t)
						Sleep(-1)
					if (A_TickCount > t && this.readyState < 3)
						Succeeded := 0
				}
			}
			return 0
		}
		read() {
			if (!DllCall('Winhttp\WinHttpQueryDataAvailable', 'ptr', this, 'uint*', &size := 0, 'int'))
				return
			buf := Buffer(size), this.ReadData(buf.Ptr, size, &dwread)
			if (dwread)
				return buf
		}
		ReadData(lpBuffer, dwNumberOfBytesToRead, &dwNumberOfBytesRead) => DllCall('Winhttp\WinHttpReadData', 'ptr', this, 'ptr', lpBuffer, 'uint', dwNumberOfBytesToRead, 'uint*', &dwNumberOfBytesRead := 0, 'int')
		WriteData(lpBuffer, dwNumberOfBytesToWrite, &dwNumberOfBytesWritten) => DllCall('Winhttp\WinHttpWriteData', 'ptr', this, 'ptr', lpBuffer, 'uint', dwNumberOfBytesToWrite, 'uint*', &dwNumberOfBytesWritten := 0, 'int')
		QueryAuthSchemes(lpdwSupportedSchemes, lpdwFirstScheme, pdwAuthTarget) => DllCall('Winhttp\WinHttpQueryAuthSchemes', 'ptr', this, 'ptr', lpdwSupportedSchemes, 'ptr', lpdwFirstScheme, 'ptr', pdwAuthTarget, 'int')
		QueryHeaders(dwInfoLevel, pwszName, lpBuffer, &dwBufferLength, dwIndex) => DllCall('Winhttp\WinHttpQueryHeaders', 'ptr', this, 'uint', dwInfoLevel, 'ptr', pwszName, 'ptr', lpBuffer, 'uint*', &dwBufferLength, 'uint*', dwIndex, 'int')
		ReceiveResponse() => DllCall('Winhttp\WinHttpReceiveResponse', 'ptr', this, 'ptr', 0, 'int')
		option[dwOption] {
			get => WinHttp.QueryOption(this.Ptr, dwOption)
			set {
				if (ret := WinHttp.SetOption(this.Ptr, dwOption, Value))
					throw Error(ret)
			}
		}
		status => this.getResponseHeader(WinHttp.QUERY_STATUS_CODE)
		statusText => this.getResponseHeader(WinHttp.QUERY_STATUS_TEXT)
		responseBody {
			get {
				if (this._ResponseBody)
					return this._ResponseBody
				if (!DllCall('Winhttp\WinHttpQueryDataAvailable', 'ptr', this, 'uint*', &size := 0, 'int'))
					return
				buf := Buffer(size), this.ReadData(buf.Ptr, size, &dwread), offset := dwread
				while (DllCall('Winhttp\WinHttpQueryDataAvailable', 'ptr', this, 'uint*', &size := 0, 'int') && size)
					buf.Size := offset + size, this.ReadData(buf.Ptr + offset, size, &dwread), offset += dwread
				this.readyState := 4
				return this._ResponseBody := buf
			}
		}
		responseStream {
			get {

			}
		}
		responseText {
			get {
				if (this._ResponseBody || this.ResponseBody) {
					if RegExMatch(this.getResponseHeader('Content-Type') || '', 'charset=([\w\-]+)', &m)
						charset := m[1]
					else
						charset := this.getResponseHeader(WinHttp.QUERY_ACCEPT_CHARSET)
					switch charset {
						case 'utf-8', 'utf-16':
						case 'gb2312':
							charset := 'cp936'
						default:
							if (charset = '')
								charset := 'utf-16'
							else
								throw Error('未知的字符集: ' charset)
					}
					return StrGet(this._ResponseBody, charset)
				}
			}
		}
	}
}
