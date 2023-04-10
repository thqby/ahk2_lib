/************************************************************************
 * @description websocket Implemented By JS
 * @file ws-min.ahk
 * @author thqby
 * @date 2021/10/04
 * @version 0.0.1
 ***********************************************************************/

class WebSocket {
	doc := "", BlockSleep := 50, Timeout := 15000

	; usage1
	; WebSocket("ws://xxx.xx.xx.xx:xxxx", {Message: (self,event)=>MsgBox(event.data), Close: (*)=>Msgbox("websocket close")})
	; usage2
	; class socketinst extends WebSocket
	; {
	; 	OnMessage(event)=>MsgBox(event.data)
	; }
	; socketinst("ws://xxx.xx.xx.xx:xxxx")
	__New(ws_url, Callbacks := "", Timeout := "") {
		this.doc := ComObject("htmlfile"), this.doc.write("<meta http-equiv='X-UA-Compatible'content='IE=edge'><body><script>errorinfo='';function tojson(obj){var keys=[];for (k in obj){if (typeof obj[k]!=='function'){keys.push(k);}};return JSON.stringify(obj,keys);}function Connectsocket(url){errorinfo='';try{url=typeof url=='undefined'||url==''?ws.url:url;ws=new WebSocket(url);ws.onopen=function(event){ahk_event('Open',tojson(event));};ws.onclose=function(event){ahk_event('Close',tojson(event));};ws.onerror=function(event){ahk_event('Error',tojson(event));};ws.onmessage=function(event){ahk_event('Message',event.data);};}catch(err){errorinfo=err.message;}}</script></body>")
		if IsObject(Callbacks)
			for k, v in Type(Callbacks) = "Map" ? Callbacks : Callbacks.OwnProps()
				RegExMatch(k, "i)(Open|Close|Message|Error)", &mat) ? (this.%"on" mat[1]% := v) : ""
		this.doc.parentWindow.ahk_event := ObjBindMethod(this, "onEvent"), this.Timeout := IsInteger(Timeout) ? Timeout : this.Timeout, this.Connect(ws_url)
	}

	Connect(ws_url := "") {
		this.doc.parentWindow.Connectsocket(ws_url), err := this.doc.parentWindow.errorinfo, endt := A_TickCount + this.Timeout
		switch err
		{
			case "SecurityError":
				throw Error("尝试取消'Internet选项-安全-本地intranet-站点-包括所有不使用代理服务器的站点'勾选状态")
			case "SyntaxError":
				throw Error("ws地址错误")
			case "":	; nothing
			default:
				throw Error(err)
		}
		while (this.readyState = 0 && A_TickCount < endt)
			Sleep(this.BlockSleep)
		if (this.readyState = 0) {
			this.Disconnect()
			throw Error("连接超时")
		}
	}

	Send(Data) => this.doc.parentWindow.ws.send(Data)
	__Delete() => (this.doc := (this.readyState = 1) ? (this.Disconnect(), "") : "")
	Disconnect() => ((this.readyState = 1) ? this.doc.parentWindow.ws.close() : "")
	onEvent(EventName, Event) {
		if this.HasOwnProp("on" EventName)
			try this.on%EventName%(Event)
	}
	bufferedAmount => this.doc.parentWindow.ws.bufferedAmount
	readyState => this.doc.parentWindow.ws.readyState
	protocol => this.doc.parentWindow.ws.protocol
	url => this.doc.parentWindow.ws.url
}