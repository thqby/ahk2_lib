#Include WinHttpRequest.ahk

/**
 * Asynchronous download, you can get the download progress, and call the specified function after the download is complete
 * @param {String} URL The URL address to be downloaded, including the http(s) header
 * @param {String} Filename File path to save. If omit, download to memory
 * @param {(downloaded_size, total_size)=>void} OnProgress Download progress callback function
 * @return {WinHttpRequest} A WinHttpRequest instance, can be used to terminate the download
 * @example
 * url := "https://www.autohotkey.com/download/ahk-v2.exe"
 * Persistent()
 * DownloadAsync(url,,
 *   (req) => (Persistent(0), ToolTip(), (req is OSError) ? MsgBox('Error:' req.Message) : MsgBox('size: ' req.ResponseBody.Size)),
 *   (s, t) => ToolTip('downloading: ' s '/' t))
 */
DownloadAsync(URL, Filename?, OnFinished := 0, OnProgress := 0) {
	totalsize := -1, file := size := 0, err := OSError(0, -2)
	if IsSet(Filename) && !(file := FileOpen(Filename, 'w-wd'))
		throw OSError()
	req := WinHttpRequest(), req.Open('GET', URL, true)
	if (OnProgress) {
		req.OnResponseDataAvailable := (self, pvData, cbElements) => OnProgress(size += cbElements, totalsize)
		req2 := WinHttpRequest()
		req2.OnResponseFinished := (whr) => totalsize := Integer(whr.GetResponseHeader('Content-Length'))
		req2.Open('HEAD', URL, true), req2.Send()
	}
	req.OnError := req.OnResponseFinished := finished, req.Send()
	return req

	finished(self, msg := 0, data := 0) {
		if (msg) {
			if file
				file.Close(), FileDelete(Filename)
			err.Message := data, err.Number := msg, err.Extra := URL
			try OnFinished(err)
		} else {
			if file {
				pSafeArray := ComObjValue(self.whr.ResponseBody)
				pvData := NumGet(pSafeArray + 8 + A_PtrSize, 'ptr')
				cbElements := NumGet(pSafeArray + 8 + A_PtrSize * 2, 'uint')
				file.RawWrite(pvData, cbElements), file.Close()
			}
			try OnFinished(self)
		}
	}
}
