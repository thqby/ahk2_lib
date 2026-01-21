/************************************************************************
 * @description A simple smtp client implementation for sending emails.
 * @author thqby
 * @date 2025/06/06
 * @version 0.0.1
 ***********************************************************************/

#Include Socket.ahk
#Include TLSAuth.ahk

class SMTPClient extends Socket.Client {
	__New(host, port := 587) {
		super.__New(host, port)
		if !this._expect(220)
			throw TimeoutError('CONNECTION')
		this.SendText('EHLO ' host '`r`n')
		if !r := this._expect(250)
			throw TimeoutError('EHLO')
		for v in ['STARTTLS', 'SMTPUTF8']
			if !InStr(r, v)
				throw Error('Smtp server does not support ' v)
		this.SendText('STARTTLS`r`n')
		if !this._expect(220)
			throw TimeoutError('STARTTLS')
		this.StartTLS(TLSAuth(host))
	}

	login(user, pwd) {
		this.sendMsg('AUTH LOGIN', 334)
		this.sendMsg(b64(user), 334)
		this.sendMsg(b64(pwd), 235)
		return this
		b64(str) {
			StrPut(str, bin := Buffer(StrPut(str, 'utf-8') - 1), 'utf-8'), chars := Ceil(bin.Size * 4 / 3) + 3
			DllCall('crypt32\CryptBinaryToString', 'ptr', bin, 'uint', bin.Size, 'uint', 0x40000001, 'ptr', outData := Buffer(chars << 1), 'uint*', chars)
			return StrGet(outData)
		}
	}

	mail(from, to, subject, body) {
		this.sendMsg('MAIL FROM: <' from '>', 250)
		this.sendMsg('RCPT TO: <' to '>', 250)
		this.sendMsg('DATA', 354)
		this.sendMsg('from: ' from '`r`nto: ' to '`r`nsubject: ' subject '`r`n`r`n' body '`r`n.', 250)
		return this
	}

	quit() {
		this.sendMsg('QUIT', 221)
	}

	_expect(code) {
		str := ''
		while (s := this.RecvText(, 5000))
			if SubStr(str .= s, -2) == '`r`n'
				break
		if str && SubStr(str, InStr(str, '`n', , , -2) + 1, 4) !== code ' '
			throw Error(str)
		return str
	}

	sendMsg(str, code?) {
		this.SendText(str '`r`n')
		IsSet(code) && this._expect(code)
	}
}
