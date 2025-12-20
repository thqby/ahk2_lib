#Include <WebView2\WebView2>
#Include <RapidOcr\RapidOcr>

g := Gui('+Resize +MinSize640x480')
g.OnEvent('Size', (g, minMax, *) => minMax >= 0 && IsSet(wv) && wvc.Fill())
g.OnEvent('Close', exitCb)
g.Show('Maximize')
wvc := WebView2.create(g.Hwnd)
wv := wvc.CoreWebView2
env := wv.Environment
wv.Navigate(A_ScriptDir '/index.html')
uri := 'file:///' StrReplace(A_ScriptDir, '\', '/') '/*'
uriLen := StrLen(uri)
wv.AddWebResourceRequestedFilter(uri, 7)
wv.AddWebResourceRequestedFilter('file:///*', 3)
token := wv.WebResourceRequested(wrr)
wrr(sender, args) {
	switch args.ResourceContext {
		case 7:
			switch SubStr((req := args.Request).Uri, uriLen) {
				case 'dirSelect': dirSelect(args)
				case 'ocr': ocr(args, req)
			}
		case 3:
			try args.Response := env.CreateWebResourceResponse(
				WebView2.CreateMemStream(FileRead(SubStr(args.Request.Uri, 9), 'raw')), 200, 'OK', '')
	}
	static dirSelect(args) {
		static cur_dir := A_ScriptDir
		defer := args.GetDeferral(), SetTimer(fn, -1)
		fn() {
			if dir := FileSelect('D', cur_dir) {
				r := [], l := StrLen(cur_dir := dir) + 2
				loop files dir '/*.*', 'FR'
					if A_LoopFileExt ~= 'i)^(onnx|txt|dict)$'
						r.Push(SubStr(A_LoopFilePath, l))
				r := JSON.stringify({ dir: dir, files: r })
			} else r := '{}'
			args.Response := response(r), defer.Complete()
		}
	}
	static ocr(args, req) {
		defer := args.GetDeferral(), SetTimer(fn, -1)
		fn() {
			global ocr
			static ps := ''
			js := JSON.parse(req.Content.ToString())
			cls := det := rec := dict := '', s := dir := js['folder']
			for k in ['cls', 'det', 'rec', 'dict'] {
				if t := js[k]
					js[k] := %k% := dir '\' t
				s .= '`n' . t
			}
			try {
				if s != ps
					ocr := RapidOcr(js), ps := s
				if !DllCall('crypt32\CryptStringToBinary', 'str', b64 := js['pic'], 'uint', 0, 'uint', 1, 'ptr', 0, 'uint*', &sz := 0, 'ptr', 0, 'ptr', 0) ||
					!DllCall('crypt32\CryptStringToBinary', 'str', b64, 'uint', 0, 'uint', 1, 'ptr', buf := Buffer(sz), 'uint*', &sz, 'ptr', 0, 'ptr', 0)
					throw OSError()
				if s := ocr.ocr_from_binary(buf, buf.Size, RapidOcr.OcrParam(js), true)
					s.Push({
						boxPoint: [],
						boxScore: '',
						angleIndex: '',
						angleScore: '',
						angleTime: '',
						text: s.text,
						charScores: [],
						crnnTime: s.detectTime - s.dbNetTime,
						blockTime: s.detectTime
					})
				else s := []
			} catch as e
				s := { error: e.Message }
			args.Response := response(JSON.stringify(s)), defer.Complete()
		}
	}
	static response(body) {
		return env.CreateWebResourceResponse(WebView2.CreateTextStream(body), 200, 'OK', 'Content-Type: application/json')
	}
}

exitCb(*) {
	global
	token := 0, wv := 0, wvc := 0, g := ocr := 0
}
