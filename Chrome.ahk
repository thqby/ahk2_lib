; Chrome.ahk v1.0 for ahk_v2
; modify by thqby
; Copyright GeekDude 2018
; https://github.com/G33kDude/Chrome.ahk
#Requires AutoHotkey v2.0-a118
class Chrome
{
	static DebugPort := 9222
	
	/*
		Escape a string in a manner suitable for command line parameters
	*/
	CliEscape(Param){
		return '"' RegExReplace(Param, "(\\*)`"", '$1$1\"') '"'
	}

	static FindInstances(exename:="Chrome.exe"){
		static Needle := "--remote-debugging-port=(\d+)"
		Out := 0
		for Item in ComObjGet("winmgmts:").ExecQuery("SELECT CommandLine FROM Win32_Process WHERE Name = '" exename "'")
			if RegExMatch(Item.CommandLine, Needle, Match)
				Out:={DebugPort: Match[1], CommandLine: Item.CommandLine}
		return Out
	}
	
	/*
		ProfilePath - Path to the user profile directory to use. Will use the standard if left blank.
		URLs        - The page or array of pages for Chrome to load when it opens
		Flags       - Additional flags for Chrome when launching
		ChromePath  - Path to Chrome.exe, will detect from start menu when left blank
		DebugPort   - What port should Chrome's remote debugging server run on
	*/
	__New(ProfilePath:="", URLs:="about:blank", Flags:="", ChromePath:="", DebugPort:="")
	{
		; Verify ProfilePath
		if (ProfilePath != "" && !InStr(FileExist(ProfilePath), "D"))
			throw Exception("The given ProfilePath does not exist")
		this.ProfilePath := ProfilePath
		
		; Verify ChromePath
		if (ChromePath == "")
			try FileGetShortcut A_StartMenuCommon "\Programs\Chrome.lnk", ChromePath
		if (ChromePath == "")
			try ChromePath:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Chrome.exe")
		if !FileExist(ChromePath)&&!FileExist(ChromePath:="C:\Program Files (x86)\Google\Chrome\Application\Chrome.exe")
			throw Exception("Chrome could not be found")
		this.ChromePath := ChromePath
		
		; Verify DebugPort
		if (DebugPort != ""){
			if !IsInteger(DebugPort)||(DebugPort <= 0)
				throw Exception("DebugPort must be a positive integer")
			this.DebugPort := DebugPort
		} else
			this.DebugPort:=Chrome.DebugPort
		
		; Escape the URL(s)
		for url in (URLString:="",(t:=Type(URLs))="Array" ? URLs : t="String" ? [URLs] : ["about:blank"])
			URLString .= " " this.CliEscape(URL)

		Run this.CliEscape(ChromePath)
		. " --remote-debugging-port=" this.DebugPort
		. (ProfilePath ? " --user-data-dir=" this.CliEscape(ProfilePath) : "")
		. (Flags ? " " Flags : "")
		. URLString,,, PID
		this.PID := PID
	}
	
	/*
		End Chrome by terminating the process.
	*/
	Kill(){
		ProcessClose this.PID
	}
	
	/*
		Queries Chrome for a list of pages that expose a debug interface.
		In addition to standard tabs, these include pages such as extension
		configuration pages.
	*/
	GetPageList(){
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		http.open("GET", "http://127.0.0.1:" this.DebugPort "/json")
		try {
			http.send()
			return Chrome.Json.Load(http.responseText)
		} catch
			return []
	}
	
	FindPages(opts, MatchMode:="exact"){
		Pages:=[]
		for PageData in this.GetPageList(){
			fg:=true
			for k, v in (Type(opts)="Map"?opts:opts.OwnProps())
				if !((MatchMode = "exact" && PageData[k] = v) || (MatchMode = "contains" && InStr(PageData[k], v))
					|| (MatchMode = "startswith" && InStr(PageData[k], v) == 1) || (MatchMode = "regex" && PageData[k] ~= v)){
					fg:=false
					break
				}
			if (fg)
				Pages.Push(PageData)
		}
		return Pages
	}

	NewTab(url:="about:blank"){
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1"), PageData:=Map()
		http.open("GET", "http://127.0.0.1:" this.DebugPort "/json/new?" url), http.send()
		try PageData:=Chrome.Json.Load(http.responseText)
		if (PageData.Has("webSocketDebuggerUrl"))
			return Chrome.Page.New(StrReplace(PageData["webSocketDebuggerUrl"], "localhost", "127.0.0.1"))
	}

	ClosePage(opts, MatchMode:="exact"){
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		switch Type(opts)
		{
		case "String":
			return (http.open("GET", "http://127.0.0.1:" this.DebugPort "/json/close/" opts), http.send())
		case "Map":
			if opts.Has("id")
				return (http.open("GET", "http://127.0.0.1:" this.DebugPort "/json/close/" opts["id"]), http.send())
		case "Object":
			if opts.Has("id")
				return (http.open("GET", "http://127.0.0.1:" this.DebugPort "/json/close/" opts.id), http.send())
		}
		for page in this.FindPages(opts, MatchMode)
			http.open("GET", "http://127.0.0.1:" this.DebugPort "/json/close/" page["id"]), http.send()
	}

	ActivatePage(opts, MatchMode:="exact"){
		http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		for page in this.FindPages(opts, MatchMode)
			return (http.open("GET", "http://127.0.0.1:" this.DebugPort "/json/activate/" page["id"]), http.send())
	}
	/*
		Returns a connection to the debug interface of a page that matches the
		provided criteria. When multiple pages match the criteria, they appear
		ordered by how recently the pages were opened.
		
		Key        - The key from the page list to search for, such as "url" or "title"
		Value      - The value to search for in the provided key
		MatchMode  - What kind of search to use, such as "exact", "contains", "startswith", or "regex"
		Index      - If multiple pages match the given criteria, which one of them to return
		fnCallback - A function to be called whenever message is received from the page
	*/
	GetPageBy(Key, Value, MatchMode:="exact", Index:=1, fnCallback:=""){
		Count := 0
		for PageData in this.GetPageList()
		{
			if (((MatchMode = "exact" && PageData[Key] = Value) ; Case insensitive
				|| (MatchMode = "contains" && InStr(PageData[Key], Value))
				|| (MatchMode = "startswith" && InStr(PageData[Key], Value) == 1)
				|| (MatchMode = "regex" && PageData[Key] ~= Value))
				&& ++Count == Index)
				return Chrome.Page.New(PageData["webSocketDebuggerUrl"], fnCallback)
		}
	}
	
	/*
		Shorthand for GetPageBy("url", Value, "startswith")
	*/
	GetPageByURL(Value, MatchMode:="startswith", Index:=1, fnCallback:=""){
		return this.GetPageBy("url", Value, MatchMode, Index, fnCallback)
	}
	
	/*
		Shorthand for GetPageBy("title", Value, "startswith")
	*/
	GetPageByTitle(Value, MatchMode:="startswith", Index:=1, fnCallback:=""){
		return this.GetPageBy("title", Value, MatchMode, Index, fnCallback)
	}
	
	/*
		Shorthand for GetPageBy("type", Type, "exact")
		
		The default type to search for is "page", which is the visible area of
		a normal Chrome tab.
	*/
	GetPage(Index:=1, Type:="page", fnCallback:=""){
		return this.GetPageBy("type", Type, "exact", Index, fnCallback)
	}
	
	/*
		Connects to the debug interface of a page given its WebSocket URL.
	*/
	class Page extends WebSocket
	{
		Connected := false, ID := 0, responses := Map(), BoundKeepAlive:=""
		onEvent(EventName, Event){
			switch EventName
			{
			case "Open":
				this.Connected:=true, SetTimer(this.BoundKeepAlive:=ObjBindMethod(this, "Call", "Browser.getVersion",, false), 25000)
			case "Close":
				SetTimer(this.BoundKeepAlive,0), this.Connected:=this.ReConnect(this.Connected)?true:(this.BoundKeepAlive:="",this.Disconnect(),false)
			case "Message":
				data := Chrome.Json.Load(Event)
				if data.Has("id")&&this.responses.Has(data["id"])
					this.responses[data["id"]] := data
			}
			try this.on%EventName%(Event)
		}

		ReConnect(flag:=true){
			if !flag
				return false
			http := ComObjCreate("WinHttp.WinHttpRequest.5.1"), list:=[], RegExMatch(this.url, "ws://[\d\.]+:(\d+)/devtools/page/(.+)$", m)
			http.open("GET", "http://127.0.0.1:" m[1] "/json")
			try http.send(), list:=Chrome.Json.Load(http.responseText)
			for page in list
				if (page["id"]=m[2])
					return (this.Connect(), true)
			return false
		}

		Call(DomainAndMethod, Params:="", WaitForResponse:=True){
			if (!this.Connected&&!this.ReConnect())
				throw Exception("Not connected to tab")
			
			; Use a temporary variable for ID in case more calls are made
			; before we receive a response.
			this.Send(Chrome.Json.Dump(Map("id", ID := this.ID += 1, "params", Params ? Params : {}, "method", DomainAndMethod)))
			if !WaitForResponse
				return
			
			; Wait for the response
			this.responses[ID] := false
			while (this.Connected&&!this.responses[ID])
				Sleep 50
			
			; Get the response, check if it's an error
			response := this.responses.Delete(ID)
			if (Type(response)!="Map")
				return
			if (response.Has("error"))
				throw Exception("Chrome indicated error in response",, Chrome.Json.Dump(response["error"]))
			if response.Has("result")
				return response["result"]
		}

		Evaluate(JS){
			response := this.Call("Runtime.evaluate",{
				expression: JS,
				objectGroup: "console",
				includeCommandLineAPI: Chrome.Json._true,
				silent: Chrome.Json._false,
				returnByValue: Chrome.Json._false,
				userGesture: Chrome.Json._true,
				awaitPromise: Chrome.Json._false
			})
			if (Type(response)="Map"){
				if (response.Has("exceptionDetails"))
					throw Exception(response["result"]["description"],, Chrome.Json.Dump(response["exceptionDetails"]))
				return response["result"]
			}
		}

		Close(){
			this.Connected:=false, RegExMatch(this.url, "ws://[\d\.]+:(\d+)/devtools/page/(.+)$", m), this.Disconnect()
			http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			http.open("GET", "http://127.0.0.1:" m[1] "/json/close/" m[2]), http.send()
		}

		Activate(){
			http := ComObjCreate("WinHttp.WinHttpRequest.5.1"), RegExMatch(this.url, "ws://[\d\.]+:(\d+)/devtools/page/(.+)$", m)
			http.open("GET", "http://127.0.0.1:" m[1] "/json/activate/" m[2]), http.send()
		}

		WaitForLoad(DesiredState:="complete", Interval:=100){
			while this.Evaluate("document.readyState")["value"] != DesiredState
				Sleep Interval
		}
	}

	class Json
	{
		static _true:=[], _false:=[]

		static Load(S,Y:=0){ ; PureJSON: convert pure JSON Object
			D:=[C:=(A:=InStr(S,"[")=1)?[]:Map()],S:=LTrim(SubStr(S,2)," `t`r`n"),L:=1,N:=0,NQ:=P:=V:=K:="",Y?(Y.Push(C),J:=Y):J:=[C],!(Q:=InStr(S,'"')!=1)?S:=LTrim(S,'"'):""
			Loop Parse, S, '"' {
				Q:=NQ?1:!Q,NQ:=Q&&(SubStr(A_LoopField,-3)="\\\"||(SubStr(A_LoopField,-1)="\"&&SubStr(A_LoopField,-2)!="\\"))
				if !Q {
					if (t:=Trim(A_LoopField," `t`r`n"))=","||(t=":"&&V:=1)
						continue
					else if t&&(InStr("{[]},:",SubStr(t,1,1)) || RegExMatch(t,"^\d*\s*[,\]\}]")){
						Loop Parse, t {
							if N&&N--
								continue
							if InStr("`n`r `t",A_LoopField)
								continue
							else if InStr("{[",A_LoopField){
								if !A&&!V
									throw("Error: Malformed JSON - missing key: " t)
								C:=A_LoopField="["?[]:Map(),A?D[L].Push(C):D[L][K]:=C,D.Has(++L)?D[L]:=C:D.Push(C),V:="",A:=Type(C)="Array"
								continue
							} else if InStr("]}",A_LoopField){
								if (!A&&V)
									throw("Error: Malformed JSON - missing value: " t)
								else if L=0
									throw("Error: Malformed JSON - to many closing bracket: " t)
								else C:=--L=0?"":D[L],A:=Type(C)="Array"
							} else if !(InStr(" `t`r,",A_LoopField)||(A_LoopField=":"&&V:=1)){
								if RegExMatch(SubStr(t,A_Index),"m)^(null|false|true|-?\d+\.?\d*)\s*[,}\]\r\n]",R)&&(N:=R.Len(0)-2,R:=R.1,1){
									if A
										C.Push(R="null"?"":R="true"?true:R="false"?false:"" R+0=R?R+0:R)
									else if V
										C[K]:=R="null"?"":R="true"?true:R="false"?false:"" R+0=R?R+0:R,K:=V:=""
									else
										throw("Error: Malformed JSON - missing key in: " t)
								} else
									throw("Error: Malformed JSON - unrecognized character: " A_LoopField " in " t)
							}
						}
					}
				} else if NQ&&(P.=A_LoopField '"',1)
					continue
				else if A
					LF:=P A_LoopField,C.Push(LF~="^(?!0)-?\d+\.?\d*$"&&"" LF+0=LF?LF+0:InStr(LF,"\")?U(LF):LF),P:=""
				else if V
					LF:=P A_LoopField,C[K]:=LF~="^(?!0)-?\d+\.?\d*$"&&"" LF+0=LF?LF+0:InStr(LF,"\")?U(LF):LF,K:=V:=P:=""
				else
					LF:=P A_LoopField,K:=LF~="^(?!0)-?\d+\.?\d*$"&&"" LF+0=LF?LF+0:InStr(LF,"\")?U(LF):LF,P:=""
			}
			return J[1]
			U(ByRef S,e:=1){ ; UniChar: convert unicode and special characters
				static m:=Map(Ord('"'),'"',Ord("a"),"`a",Ord("b"),"`b",Ord("t"),"`t",Ord("n"),"`n",Ord("v"),"`v",Ord("f"),"`f",Ord("r"),"`r",Ord("e"),Chr(0x1B),Ord("N"),Chr(0x85),Ord("P"),Chr(0x2029),0,"",Ord("L"),Chr(0x2028),Ord("_"),Chr(0xA0))
				_v:=""
				Loop Parse S,"\"
					if !((e:=!e)&&A_LoopField=""?_v.="\":!e?_v.=A_LoopField:0)
						_v .= (t:=InStr("ux",SubStr(A_LoopField " ",1,1)) ? SubStr(A_LoopField,1,RegExMatch(A_LoopField,"^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K")-1) : "")&&RegexMatch(t,"i)^[ux][\da-f]+$") ? Chr(Abs("0x" SubStr(t,2))) SubStr(A_LoopField,RegExMatch(A_LoopField,"^[ux]?([\dA-F]{4})?([\dA-F]{2})?\K")) : m.has(Ord(A_LoopField)) ? m[Ord(A_LoopField)] SubStr(A_LoopField,2) : "\" A_LoopField,e:=A_LoopField=""?e:!e
				return _v
			}
		}

		static Dump(obj:="",indent:=0,CharUni:=0){ ; dump object to string, indent>0 yaml otherwise json
			if (str:="",Type(obj)!="Array"||!obj.Length||!IsObject(obj[1]))
				str.= H(obj,indent)
			else if indent<1 {
				for K,V in obj
					str.=H(V,indent) (indent<0?"`n,":",")
				return indent<0?"[`n  " StrReplace(RTrim(str,",`n"),"`n","`n  ") "`n]":"[" RTrim(str,",`n") "]"
			} else
				for K,V in obj
					str.="---`n" H(V,indent) "`n"
			return RTrim(str,",`n")
			H(O:="",J:=0,R:=0,Q:=0){ ; helper: convert object to yaml string
				static M1:="{",M2:="}",S1:="[",S2:="]",N:="`n",C:=",",S:="- ",E:="",K:=":"
				if (t:=type(O))="Array"{
					if (_ptr:=ObjPtr(O))=ObjPtr(Chrome.Json._true)
						return "true"
					else if _ptr=ObjPtr(Chrome.Json._false)
						return "false"
					D:=J<1&&!R?S1:""
					for key, value in O{
						if Type(value)="Buffer"{
							DllCall("crypt32\CryptBinaryToString", "Ptr", value, "Uint", value.Size, "Uint", 0x40000001, "Ptr", 0, "Uint*", BTS:=0)
							VarSetStrCapacity(VAL, BTS*2)
							DllCall("crypt32\CryptBinaryToString", "Ptr", value, "Uint", value.Size, "Uint", 0x40000001, "Str", VAL, "Uint*", BTS)
							if J<=R
								D.=(J<R*-1?"`n" I(R+2):"") " !!binary " VAL (Q="S"&&A_Index=(Y?O.count:ObjOwnPropCount(O))?M2:E) (J!=0||R?(A_Index=(Y?O.count:ObjOwnPropCount(O))?E:C):E)
							else
								D.=N I(R+1) S " !!binary " VAL
							continue
						} else
							F:=IsObject(value)?(Type(value)="Array"?"S":"M"):E
						Z:=Type(value)="Array"&&value.Length=0?"[]":((Type(value)="Map"&&value.count=0)||(Type(value)="Object"&&ObjOwnPropCount(value)=0))?"{}":""
						if (Z="[]"){
							if (_ptr:=ObjPtr(value))=ObjPtr(Chrome.Json._true)
									value:="true", F:=E, Z:=""
								else if _ptr=ObjPtr(Chrome.Json._false)
									value:="false", F:=E, Z:=""
							if (Z=""){
								if J<=R
									D.=(J<R*-1?"`n" I(R+2):"") value ((Type(O)="Array"&&O.Length=A_Index) ? E : C)
								else
									D.=N I(R+1) S "!!bool " value
								continue
							}
						}
						if J<=R
							D.=(J<R*-1?"`n" I(R+2):"") (F?(%F%1 (Z?"":H(value,J,R+1,F)) %F%2):E(value, J)) ((Type(O)="Array"&&O.Length=A_Index) ? E : C)
						else if ((D:=D N I(R+1) S)||1)&&F
							D.= Z?Z:(J<=(R+1)?%F%1:E) H(value,J,R+1,F) (J<=(R+1)?%F%2:E)
						else D .= E(value,J)
					}
				} else {
					D:=J<1&&!R?M1:""
					for key, value in Type(O)="Map"?(Y:=1,O):(Y:=0,O.OwnProps()){
						if Type(value)="Buffer"{
							DllCall("crypt32\CryptBinaryToString", "Ptr", value, "Uint", value.Size, "Uint", 0x40000001, "Ptr", 0, "Uint*", BTS:=0)
							VarSetStrCapacity(VAL, BTS*2)
							DllCall("crypt32\CryptBinaryToString", "Ptr", value, "Uint", value.Size, "Uint", 0x40000001, "Str", VAL, "Uint*", BTS)
							if J<=R
								D.=(J<R*-1?"`n" I(R+2):"") E(key,J) K " !!binary " VAL (Q="S"&&A_Index=(Y?O.count:ObjOwnPropCount(O))?M2:E) (J!=0||R?(A_Index=(Y?O.count:ObjOwnPropCount(O))?E:C):E)
							else
								D.=N I(R+1) E(key) K " !!binary " VAL
						} else {
							F:=IsObject(value)?(Type(value)="Array"?"S":"M"):E
							Z:=Type(value)="Array"&&value.Length=0?"[]":((Type(value)="Map"&&value.count=0)||(Type(value)="Object"&&ObjOwnPropCount(value)=0))?"{}":""
							if (Z="[]"){
								if (_ptr:=ObjPtr(value))=ObjPtr(Chrome.Json._true)
									value:="true", F:=E, Z:=""
								else if _ptr=ObjPtr(Chrome.Json._false)
									value:="false", F:=E, Z:=""
								if (Z=""){
									if J<=R
										D.=(J<R*-1?"`n" I(R+2):"") E(key,J) K " " value (J!=0||R?(A_Index=(Y?O.count:ObjOwnPropCount(O))?E:C):E)
									else
										D.=N I(R+1) E(key) K " " value
									if J=0&&!R
										D.= (A_Index<(Y?O.count:ObjOwnPropCount(O))?C:E)
									continue
								}
							}
							if J<=R
								D.=(J<R*-1?"`n" I(R+2):"") (Q="S"&&A_Index=1?M1:E) E(key,J) K (J<R*-1?" ":"") (F?(%F%1 (Z?"": H(value,J,R+1,F)) %F%2): E(value,J)) (Q="S"&&A_Index=(Y?O.count:ObjOwnPropCount(O))?M2:E) (J!=0||R?(A_Index=(Y?O.count:ObjOwnPropCount(O))?E:C):E)
							else if ((D:=D N I(R+1) E(key) K)||1)&&F
								D.= Z?Z:(J<=(R+1)?%F%1:E) H(value,J,R+1,F) (J<=(R+1)?%F%2:E)
							else D .= " " E(value, J)
						}
						if J=0&&!R
							D.= (A_Index<(Y?O.count:ObjOwnPropCount(O))?C:E)
					}
				}
				if J<0&&J<R*-1
					D.= "`n" I(R+1)
				if R=0
					D:=RegExReplace(D,"^\R+") (J<1?(Type(O)="Array"?S2:M2):"")
				Return D
			}
			I(i){ ; Convert level to spaces
				Loop (s:="",i-1)
					s .= "  "
				Return s
			}
			E(ByRef S, J:=1){ ; EscIfNeed: check if escaping needed and convert to unicode notation
				if S=""
					return '""'
				else if (J<1&&!IsNumber(S))||RegExMatch(S,"m)[\{\[`"'\r\n]|:\s|,\s|\s#")||RegExMatch(S,"^([\s#\\\-:>\|]|!!)")||RegExMatch(S,"m)\s$")||RegExMatch(S,"m)[\x{7F}-\x{7FFF}]")
					return ("`"" C(S) "`"")
				else return (J<1?'"' S '"':S)
			}
			C(ByRef S){ ; CharUni: convert text to unicode notation
				static ascii:=Map("\","\","`a","a","`b","b","`t","t","`n","n","`v","v","`f","f","`r","r",Chr(0x1B),"e","`"","`"",Chr(0x85),"N",Chr(0x2029),"P",Chr(0x2028),"L","","0",Chr(0xA0),"_")
				v:=""
				if (!CharUni||!RegexMatch(S,"[\x{007F}-\x{FFFF}]")){ ;!(v:="") && 
					Loop Parse, S
						v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : A_LoopField
					return v
				}
				Loop Parse, S
					v .= ascii.Has(A_LoopField) ? "\" ascii[A_LoopField] : Ord(A_LoopField)<128 ? A_LoopField : "\u" Format("{1:.4X}",Ord(A_LoopField))
				return v
			}
		}
	}
}

class WebSocket
{
	doc:="", BlockSleep:=50, Timeout:=15000
	__New(ws_url, Callbacks:="", Timeout:=""){
		static pcall:=""
		this.doc:=ComObjCreate("htmlfile"), this.doc.write("<meta http-equiv='X-UA-Compatible'content='IE=edge'><body><script>errorinfo='';function tojson(obj){var keys=[];for (k in obj){if (typeof obj[k]!=='function'){keys.push(k);}};return JSON.stringify(obj,keys);}function Connectsocket(url){errorinfo='';try{url=typeof url=='undefined'||url==''?ws.url:url;ws=new WebSocket(url);ws.onopen=function(event){ahk_event('Open',tojson(event));};ws.onclose=function(event){ahk_event('Close',tojson(event));};ws.onerror=function(event){ahk_event('Error',tojson(event));};ws.onmessage=function(event){ahk_event('Message',event.data);};}catch(err){errorinfo=err.message;}}</script></body>")
		if (Type(Callbacks)~="Func"?((Callbacks.MinParams=2?this.DefineMethod("onMessage", Callbacks):(pcall:=Callbacks,this.DefineMethod("onMessage", (s,e)=>(%pcall%(e))))),false):IsObject(Callbacks))
			for k, v in Type(Callbacks)="Map"?Callbacks:Callbacks.OwnProps()
				RegExMatch(k, "i)(Open|Close|Message|Error)", mat)?this.DefineMethod("on" mat[1], v):""
		this.doc.parentWindow.ahk_event:=ObjBindMethod(this, "onEvent"), this.Timeout:=IsInteger(Timeout)?Timeout:this.Timeout, this.Connect(ws_url)
	}

	Connect(ws_url:=""){
		this.doc.parentWindow.Connectsocket(ws_url), err:=this.doc.parentWindow.errorinfo, endt:=A_TickCount+this.Timeout
		switch err
		{
		case "SecurityError":
			throw Exception("尝试取消'Internet选项-安全-本地intranet-站点-包括所有不使用代理服务器的站点'勾选状态")
		case "SyntaxError":
			throw Exception("ws地址错误")
		case "":	; nothing
		default:
			throw Exception(err)
		}
		while (this.readyState=0&&A_TickCount<endt)
			Sleep(this.BlockSleep)
		if (this.readyState=0){
			this.Disconnect()
			throw Exception("连接超时")
		}
	}

	Send(Data) => this.doc.parentWindow.ws.send(Data)
	__Delete() => (this.doc:=(this.readyState=1)?(this.Disconnect(),""):"")
	Disconnect() => ((this.readyState=1)?this.doc.parentWindow.ws.close():"")
	onEvent(EventName, Event) => (this.HasOwnMethod("on" EventName)?this.on%EventName%(Event):"")
	bufferedAmount[] => this.doc.parentWindow.ws.bufferedAmount
	readyState[] => this.doc.parentWindow.ws.readyState
	protocol[] => this.doc.parentWindow.ws.protocol
	url[] => this.doc.parentWindow.ws.url
}