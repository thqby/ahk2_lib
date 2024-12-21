/************************************************************************
 * @description Implemented ssl/tls encryption and decryption.
 * @author thqby
 * @date 2024/12/21
 * @version 1.0.0
 ***********************************************************************/

class TLSAuth extends Buffer {
	/**
	 * Create ssl/tls context to provide services for authentication
	 * and data encryption and decryption between server and client.
	 * @param {String} serverHost On the client side, this is the server host name that needs to be verified;
	 * on the server side, this is not required.
	 * @param {String|PCCERT_CONTEXT} cert On the client side, this is optional; on the service side, it is required.
	 */
	__New(serverHost := '', cert := 0, ignoreCertError := false) {
		#DllLoad secur32.dll
		static UNISP_NAME := StrPtr('Microsoft Unified Security Protocol Provider')
		static cbContext := A_PtrSize * 2, cbSecBuffer := 8 + A_PtrSize, cbTotal := cbContext + cbSecBuffer * 6
		static SECBUFFER_STREAM_TRAILER := 6, SECBUFFER_STREAM_HEADER := 7, SECPKG_ATTR_STREAM_SIZES := 4
		static SECBUFFER_DATA := 1, SECBUFFER_TOKEN := 2, SECBUFFER_EXTRA := 5
		static SEC_I_CONTINUE_NEEDED := 590610, SEC_I_CONTEXT_EXPIRED := 590615,
			SEC_I_RENEGOTIATE := 590625, SEC_E_INCOMPLETE_MESSAGE := 0x80090318
		static ISC_REQ_REPLAY_DETECT := 4, ISC_REQ_SEQUENCE_DETECT := 8, ISC_REQ_CONFIDENTIALITY := 16,
			ISC_REQ_ALLOCATE_MEMORY := 256, ISC_REQ_EXTENDED_ERROR := 16384, ISC_REQ_STREAM := 32768
		static ISC_REQ_MANUAL_CRED_VALIDATION := 524288
		static dwSspiInFlags := ISC_REQ_REPLAY_DETECT | ISC_REQ_SEQUENCE_DETECT | ISC_REQ_CONFIDENTIALITY |
			ISC_REQ_EXTENDED_ERROR | ISC_REQ_ALLOCATE_MEMORY | ISC_REQ_STREAM

		if cert {
			if cert is String {
				loop 2 {
					if hStore := DllCall('crypt32\CertOpenStore', 'astr', 'System', 'uint', 1, 'ptr', 0,
						'uint', 65536 << A_Index - 1, 'str', 'My', 'ptr')
						pCert := DllCall('crypt32\CertFindCertificateInStore', 'ptr', hStore, 'uint', 1,
							'uint', 0, 'uint', 524295, 'str', cert, 'ptr', 0, 'ptr'),
							DllCall('crypt32\CertCloseStore', 'ptr', hStore, 'uint', 0)
				} until pCert
			} else pCert := IsObject(cert) ? cert.ptr : cert
			if !(pCert ?? 0)
				throw OSError(0x80092004)
			authData := Buffer(A_PtrSize * 7 + 32, 0)
			NumPut('uint', 4, 'uint', 1, 'ptr', authData.Ptr + authData.Size - A_PtrSize, authData)
			NumPut('uint', 0x400000, 'uint', 0, 'ptr', pCert, authData, A_PtrSize * 6 + 24)
			pCert := { ptr: pCert, __Delete: this => DllCall('crypt32\CertFreeCertificateContext', 'ptr', this) }
		} else authData := 0
		dwFlags := dwSspiInFlags | (ignoreCertError && serverHost ? ISC_REQ_MANUAL_CRED_VALIDATION : 0)
		DllCall('secur32\AcquireCredentialsHandle', 'ptr', 0, 'ptr', UNISP_NAME, 'uint', 2 | !serverHost, 'ptr', 0,
			'ptr', authData, 'ptr', 0, 'ptr', 0, 'ptr', hCred := Buffer(cbContext), 'int64*', &tsExpiry := 0, 'hresult')
		hCred.__Delete := (this) => DllCall('secur32\FreeCredentialsHandle', 'ptr', this)
		super.__New(cbTotal), initialized := 0
		; struct SecBufferDesc { uint ulVersion = 0; uint cBuffers; PSecBuffer pBuffers; }
		; struct SecBuffer { uint cbBuffer; uint BufferType; void *pvBuffer }
		pInputDesc := this.Ptr + cbContext, pOutputDesc := pInputDesc + cbSecBuffer
		pInputs := pOutputDesc + cbSecBuffer, pOutputs := pInputs + cbSecBuffer * 2
		NumPut('int64', 0, 'ptr', pInputs, 'int64', 0x100000000, 'ptr', pOutputs, pInputDesc)
		inBuffer := Buffer(), pRead := pReadEnd := pReadStart := cbInBuffer := cbUnRead := 0
		cbHeader := cbTrailer := cbMaximumMessage := cbMinimumPacket := 0
		STREAM_HEADER := STREAM_TRAILER := 0
		this.DefineProp('commit', { call: (this, size) => cbUnRead += size })
			.DefineProp('decrypt', { call: auth }).DefineProp('encryptor', { call: encryptor })
			.DefineProp('read', { call: read }).DefineProp('recvPtr', { call: recvPtr })

		auth(this, pInData, &cbInData, &oOutData) {
			NumPut('uint', 2, pInputDesc, 4)
			NumPut('int64', cbInData | 0x200000000, 'ptr', pInData,
				'int64', 0, 'ptr', 0, 'int64', 0x200000000, 'ptr', 0, pInputs)
			if initialized
				id := pInputDesc, ci := this, co := 0
			else initialized := 1, id := ci := 0, co := this.DefineProp('close', { call: close })
			secStatus := serverHost ?
				DllCall('secur32\InitializeSecurityContext', 'ptr', hCred, 'ptr', ci, 'str', serverHost,
					'uint', dwFlags, 'uint', 0, 'uint', 16, 'ptr', id, 'uint', 0, 'ptr', co,
					'ptr', pOutputDesc, 'uint*', &dwSspiOutputFlags := 0, 'int64*', &tsExpiry := 0, 'uint') :
				DllCall('secur32\AcceptSecurityContext', 'ptr', hCred, 'ptr', ci, 'ptr', pInputDesc,
					'uint', dwFlags, 'uint', 0, 'ptr', co, 'ptr', pOutputDesc,
					'uint*', &dwSspiOutputFlags := 0, 'int64*', &tsExpiry := 0, 'uint')
			oOutData := (pvBuffer := NumGet(pOutputs + 8, 'ptr')) && { ptr: pvBuffer, size: NumGet(pOutputs, 'uint'),
				__Delete: (this) => DllCall('secur32\FreeContextBuffer', 'ptr', this) }
			if secStatus == SEC_E_INCOMPLETE_MESSAGE
				return cbInData := 0
			if SECBUFFER_EXTRA == NumGet(pInputs + cbSecBuffer + 4, 'uint')
				cbInData -= NumGet(pInputs + cbSecBuffer, 'uint')
			if secStatus == SEC_I_CONTINUE_NEEDED
				return 2
			if secStatus || initialized == 1 && secStatus := DllCall('secur32\QueryContextAttributes',
				'ptr', this, 'uint', SECPKG_ATTR_STREAM_SIZES, 'ptr', Sizes := Buffer(20))
				throw OSError(secStatus)
			if initialized == 1 {
				this.cbHeader := cbHeader := NumGet(Sizes, 'uint')
				this.cbTrailer := cbTrailer := NumGet(Sizes, 4, 'uint')
				this.cbMaximumMessage := cbMaximumMessage := NumGet(Sizes, 8, 'uint')
				this.cbMinimumPacket := cbMinimumPacket := cbHeader + cbTrailer
				this.cbMaximumPacket := cbMaximumMessage + cbMinimumPacket
				STREAM_HEADER := cbHeader | (SECBUFFER_STREAM_HEADER << 32)
				STREAM_TRAILER := cbTrailer | (SECBUFFER_STREAM_TRAILER << 32)
				this.DefineProp('encrypt', { call: encrypt }).DefineProp('decrypt', { call: decrypt })
			}
			return initialized := 3
		}
		close(this) {
			this.DeleteProp('close')
			NumPut('int64', 0x200000004, 'ptr', pOutputs + cbSecBuffer, 'uint', 1, pOutputs)
			DllCall('secur32\ApplyControlToken', 'ptr', this, 'ptr', pOutputDesc)
			pRead := pReadStart, initialized := 3
			auth(this, cbUnRead := 0, &cb := 0, &out), initialized := 0
			DllCall('secur32\DeleteSecurityContext', 'ptr', this)
			this.DefineProp('decrypt', { call: auth }).DeleteProp('encrypt')
			return out
		}
		decrypt(this, pInData, &cbInData, &oOutData) {
			NumPut('uint', 4, pInputDesc, 4)
			NumPut('int64', cbInData | 0x100000000, 'ptr', pInData,
				'int64', 0, 'ptr', 0, 'int64', 0, 'ptr', 0, 'int64', 0, 'ptr', 0, pInputs)
			secStatus := DllCall('secur32\DecryptMessage', 'ptr', this, 'ptr', pInputDesc, 'uint', 0, 'ptr', 0, 'uint')
			cbExtra := oOutData := 0, p := pOutputDesc
			loop 4
				switch NumGet(p += cbSecBuffer, 4, 'uint') {
					case SECBUFFER_DATA: (oOutData || oOutData := { ptr: NumGet(p, 8, 'ptr'), size: NumGet(p, 'uint') })
					case SECBUFFER_EXTRA: (cbExtra || cbInData -= cbExtra := NumGet(p, 'uint'))
				}
			switch secStatus {
				case 0: return 1
				case SEC_E_INCOMPLETE_MESSAGE: return cbInData := 0
				case SEC_I_CONTEXT_EXPIRED:
					oOutData := 0, this.close()
					return -1
				case SEC_I_RENEGOTIATE:
					this.DeleteProp('encrypt')
					try return auth(this.DefineProp('decrypt', { call: auth }),
						pInData + cbInData, &cbExtra, &oOutData)
					finally cbInData += cbExtra
			}
			throw OSError(secStatus)
		}
		encrypt(this, pInData, cbInData, pOutData) {
			NumPut('uint', 4, pInputDesc, 4), NumPut('int64', STREAM_HEADER, 'ptr', pOutData,
				'int64', cbInData | 0x100000000, 'ptr', pMessage := pOutData + cbHeader,
				'int64', STREAM_TRAILER, 'ptr', pMessage + cbInData, 'int64', 0, 'ptr', 0, pInputs)
			if pMessage !== pInData
				DllCall('RtlMoveMemory', 'ptr', pMessage, 'ptr', pInData, 'uptr', cbInData)
			if secStatus := DllCall('secur32\EncryptMessage', 'ptr', this, 'uint', 0, 'ptr', pInputDesc, 'uint', 0)
				throw OSError(secStatus)
			return cbInData + cbMinimumPacket
		}
		encryptor(this, src, size?) {
			if src is String
				encoding := (size ?? '') || 'utf-8', size := encoding = 'utf-16' || encoding = 'cp1200' ?
					StrLen(src) << 1 : StrPut(src, encoding) - 1
			else size := size ?? src.Size, encoding := 0, pInData := IsObject(src) ? src.Ptr : src
			done := false
			return write
			write(pDst, cbDst) {
				if !size && done
					return src := 0
				if 0 >= cbInData := Min(cbMsg := cbDst - cbMinimumPacket, cbMaximumMessage, size) {
					if cbMsg < 0 || size {
						if !pDst && !encoding {
							src := ClipboardAll(pInData, cbInData)
							pInData := src.Ptr
							return
						}
						throw OSError(603)
					}
				} else if encoding {
					if size > cbInData {
						StrPut(src, pInData := Buffer(size), encoding)
						src := pInData, pInData := src.Ptr, encoding := 0
					} else
						StrPut(src, pInData := pDst + cbHeader, cbInData, encoding)
				}
				cbMsg := this.encrypt(pInData, cbInData, pDst)
				pInData += cbInData, size -= cbInData, done := true
				return cbMsg
			}
		}
		expand() {
			inBuffer.Size := cbInBuffer += 0x4000
			pRead := pRead - pReadStart + pReadStart := inBuffer.Ptr
			pReadEnd := pReadStart + cbInBuffer
		}
		read(this, &data) {
			r := this.decrypt(pRead, &cbInData := cbUnRead, &data)
			pRead := (cbUnRead -= cbInData) ? pRead + cbInData : pReadStart
			return r
		}
		recvPtr(this, &size) {
			if pRead - pReadStart > cbInBuffer - cbUnRead >> 1
				DllCall('RtlMoveMemory', 'ptr', pReadStart, 'ptr', pRead, 'uptr', cbUnRead), pRead := pReadStart
			size := pReadEnd - ptr := pRead + cbUnRead
			if size < 0x800 && cbInBuffer < 0x10000
				expand(), size := pReadEnd - ptr := pRead + cbUnRead
			return ptr
		}
	}
	__Delete() => this.close()

	/**
	 * Header size of each encrypted data.
	 * @readonly
	 */
	static Prototype.cbHeader := 0
	/**
	 * Maximum message bytes that can be encapsulated by each encrypted data.
	 * @readonly
	 */
	static Prototype.cbMaximumMessage := 0
	;
	/**
	 * Trailer size of each encrypted data.
	 * @readonly
	 */
	static Prototype.cbTrailer := 0
	/**
	 * Maximum bytes of each encrypted data.
	 * @readonly
	 */
	static Prototype.cbMaximumPacket := 0
	/**
	 * Minimum bytes of each encrypted data.
	 * @readonly
	 */
	static Prototype.cbMinimumPacket := 0

	/**
	 * Closes ssl/tls context and returns the closed frame data.
	 * @returns {{ptr:Integer,size:Integer}|0} 
	 */
	close() => 0

	/**
	 * Commit the number of bytes received, then call {@link TLSAuth#read} to read the decrypted data.
	 * @param {Integer} bytes Number of bytes received.
	 */
	commit(bytes) => 0

	/**
	 * Decrypt data between server and client.
	 * @param {Integer} pInData Pointer to the data to be decrypted.
	 * @param {VarRef<Integer, Integer>} cbInData Number of bytes of data to be decrypted. 
	 * @param {VarRef<{ptr:Integer,size:Integer}|0>} oOutData Decrypted data, maybe no data. If it is not authentication data, it is zero copy.
	 * @returns {Integer} Type of decrypted data.
	 * - -1: has shutdown
	 * - 0: incomplete message
	 * - 1: decrypted data
	 * - 2: authentication data, need to be sent to the other side
	 * - 3: authentication complete
	 */
	decrypt(pInData, &cbInData, &oOutData) => 0

	/**
	 * Encrypt data between server and client.
	 * @param {Integer} pInData Pointer to the data to be encrypted.
	 * @param {Integer} cbInData Number of bytes of data to be encrypted,
	 * that shall not be greater than {@link TLSAuth#cbMaximumMessage}.
	 * @param {Integer} pOutData Pointer to the buffer that receives encrypted data,
	 * the bytes of which must not be less than {@link TLSAuth#cbMinimumPacket} + cbInData
	 * @returns {Integer} Number of bytes of encrypted data.
	 */
	encrypt(pInData, cbInData, pOutData) {
		throw OSError(0x80090301)
	}

	/**
	 * Create an encryptor that is called continuously to write encrypted data to the target buffer.
	 * @param {Buffer|Integer|String} src The data that needs to be encrypted, it can be a string or buffer or a pointer to data.
	 * @param {Integer|String} sizeOrEncoding When `src` is a string, convert the string to the encoding specified by this parameter, and the default is utf-8.
	 * Otherwise, the parameter is the number of bytes of data.
	 * @returns {(pDst,cbDst)=>Integer} Calling the returned encryptor to write the encrypted data to the target buffer may take several calls to complete.
	 */
	encryptor(src, sizeOrEncoding?) => 0

	/**
	 * Read the decrypted data from the internal buffer.
	 * @param {VarRef<{ptr:Integer,size:Integer}|0>} oOutData Decrypted data, maybe no data. If it is not authentication data, it is zero copy.
	 * @returns {Integer} Type of decrypted data.
	 * - -1: has shutdown
	 * - 0: incomplete message
	 * - 1: decrypted data
	 * - 2: authentication data, need to be sent to the other side
	 * - 3: authentication complete
	 */
	read(&oOutData) => 0

	/**
	 * Get the pointer and size of the internal buffer to receive the data to be decrypted.
	 * Then call {@link TLSAuth#commit} to commit the number of bytes received.
	 * @param {VarRef<Integer>} bytes Number of bytes of the internal buffer.
	 * @returns {Integer} Pointer to the internal buffer.
	 */
	recvPtr(&bytes) => 0

	/**
	 * Wrap socket connection, start SSL/TLS handshake.
	 * @param {Socket.Client} sock 
	 */
	wrapSocket(sock) {
		if this.read(&authData) & 1
			throw ValueError()
		bwrite := Buffer(), pwrite := lwrite := 0
		queue := [], index := ql := 0, tls := this
		sock._define_methods(_define_async_methods, Close, OnWrite, Recv, Send, SendText)
		if authData
			authData := send_auth(sock, authData)
		if !ObjHasOwnProp(sock, '_async_select')
			while !pwrite
				sock.Recv()
		_define_async_methods(*) => 0
		static send_auth(sock, buf) {
			if 0 > DllCall('ws2_32\send', 'ptr', sock, 'ptr', buf, 'int', buf.size, 'int', 0) {
				if 10035 !== err := sock.GetLastError()
					throw OSError(err)
				sock._async_select(2)
				return buf
			}
		}
		_send(sock, fn, total := 0) {
			if ql
				queue.Push(task(pwrite, 0, fn, lwrite)), ql++
			else while size := fn(pwrite, lwrite) {
				if 0 > sz := DllCall('ws2_32\send', 'ptr', sock, 'ptr', pwrite, 'int', size, 'int', 0) {
					if 10035 !== err := sock.GetLastError()
						throw OSError(err)
					queue.Push(task(pwrite, size, fn, lwrite)), ql++
					sock._async_select(2)
					return 0
				} else total += sz
			}
			return total
		}
		Close(sock) {
			if o := tls.close()
				DllCall('ws2_32\send', 'ptr', sock, 'ptr', o, 'int', o.size, 'int', 0)
			(sock.Base.Close)(sock)
		}
		Send(sock, buf, size?) {
			if !sz := _send(sock, fn := tls.encryptor(buf, size?))
				IsSet(size) && fn(0, 0)
			return sz
		}
		SendText(sock, text, encoding?) => _send(sock, tls.encryptor(text, encoding?))
		Recv(sock, timeout := 0, flags?) {
			if !size := sock.MsgSize(timeout)
				return 0
			buf := Buffer(), datas := [], add_size := 0
			while size > 0 {
				if 0 > sz := sock._recv(tls.recvPtr(&sz), sz, 0)
					throw OSError(sock.GetLastError())
				if !sz
					break
				size -= sz, tls.commit(sz)
				while t := tls.read(&o) {
					if t == 1
						datas.Push(o), add_size += o.size
					else if t !== -1 {
						if t == 3 {
							bwrite.Size := lwrite := tls.cbMaximumPacket
							pwrite := bwrite.Ptr
							sock.isConnected := 2
						} else lwrite := 0
						if o
							authData := send_auth(sock, o)
					} else break
				}
				if add_size
					bappend(buf, datas, add_size), datas.Length := add_size := 0
			}
			return buf.Size && buf
		}
		OnWrite(this, err) {
			if !err {
				if !lwrite
					authData := send_auth(this, authData)
				else {
					while ++index <= ql {
						if !err := (fn := queue[index])(this)
							queue.Delete(index)
						else break
					}
					if --index && index >= ql >> 1
						queue.RemoveAt(1, index), ql -= index, index := 0
				}
			}
			if err && err !== 10035
				throw OSError(err)
			return 0
		}
		static task(ptr, size, fn, arg) {
			return sender
			sender(sock) {
				loop {
					if size && 0 > DllCall('ws2_32\send', 'ptr', sock, 'ptr', ptr, 'int', size, 'int', 0)
						return sock.GetLastError()
				} until !size := fn(ptr, arg)
			}
		}
		static bappend(buf, datas, size) {
			ps := buf.size, buf.size += size, ptr := buf.ptr + ps
			for d in datas
				DllCall('RtlMoveMemory', 'ptr', ptr, 'ptr', d, 'uptr', ps := d.size), ptr += ps
		}
	}
}

; simulated_tls_handshake(domain) {
; 	client := TLSAuth(domain), server := TLSAuth(, domain)
; 	client.decrypt(0, &cbin := 0, &oc)
; 	server.decrypt(oc.ptr, &cbin := oc.size, &os)
; 	client.decrypt(os.ptr, &cbin := os.size, &oc)
; 	t2 := server.decrypt(oc.ptr, &cbin := oc.size, &os)
; 	t1 := client.decrypt(os.ptr, &cbin := os.size, &oc)
; 	OutputDebug(t1 ' ' t2 '`n')   ; 3 3
; 	fn := client.encryptor(msg := 'abcdefghi'), buf := Buffer(100)
; 	sz := fn(ptr := buf.Ptr, size := buf.Size)
; 	t2 := server.decrypt(ptr, &cbin := sz, &os)
; 	OutputDebug(msg '`n' StrGet(os, 'utf-8') '`n')
; 	os := server.close()
; 	t1 := client.decrypt(os.ptr, &cbin := os.size, &oc)
; 	OutputDebug(t1)	; -1
; }