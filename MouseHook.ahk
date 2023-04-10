/************************************************************************
 * @description Hook Mouse
 * @file MouseHook.ahk
 * @author thqby
 * @date 2021/10/04
 * @version 0.0.1
 ***********************************************************************/


; #Persistent
; hk := MouseHook.New((self, w, l) => ToolTip('x:' self.x ' y:' self.y '`n行为:' self.Action '`n按下键:' self.ThisKey '`n按下次数:' self.Times '`n按下持续时间:' self.TimeSinceThisHotkey))
; hk.Wait('MButton')
; MsgBox('MButton按下了')
; hk := MouseHook((*) => true)
; hk.Start()
; Sleep(3000)
; hk := ''
; return

class MouseHook {
	Ptr := 0, ThisKey := '', Times := 0, Action := '', ThisKeyTime := 0, Interval := 200
	TimeSinceThisHotkey {
		get => this.ThisKeyTime ? A_TickCount - this.ThisKeyTime : 0
	}
	__New(Event := unset) {
		if IsSet(Event)
			this.OnEvent := Event
		else
			this.OnEvent := (*) => false
		this.cb := CallbackCreate(LowLevelMouseProc, 'F')
		ObjRelease(ObjPtr(this))
		LowLevelMouseProc(nCode, wParam, lParam) {
			static Msg := Map(512, 'Move', 513, 'LButton Down', 514, 'LButton Up', 516, 'RButton Down', 517, 'RButton Up', 519, 'MButton Down', 520, 'MButton Up', 522, 'Wheel', 523, 'XButton{:d} Down', 524, 'XButton{:d} Up')
			static keep := false, resetTimes := (*) => (this.Times := 0)
			if (wParam = 512) {
				this.Action := 'Move'
			} else {
				if (wParam = 522) {
					this.Action := 'Wheel ' (NumGet(lParam, 8, 'Int') > 0 ? 'Up' : 'Down')
				} else if (wParam = 523 || wParam = 524)
					this.Action := Format(Msg[wParam], NumGet(lParam, 8, 'Int') >> 16)
				else this.Action := Msg.Has(wParam) ? Msg[wParam] : "Unknown"
				if (this.Action != 'Unknown') {
					if ((t := StrSplit(this.Action, ' '))[1] = 'Wheel')
						t[1] := this.Action, t[2] := 'Up'
					if (t[1] != this.ThisKey)
						this.Times := 0, this.ThisKey := t[1]
					if (t[2] = 'Up') {
						SetTimer(resetTimes, -this.Interval), this.Times += (InStr(t[1], 'Wheel') ? 1 : 0)
						this.ThisKeyTime := 0, keep := false
					} else {
						this.Times++, this.ThisKeyTime := A_TickCount, keep := true
						SetTimer((*) => (keep ? this.OnEvent(wParam, 0) : SetTimer(, 0)), 100)
					}
				} else this.ThisKey := 'Unknown', this.Times := 1, this.ThisKeyTime := 0, keep := false
			}
			this.x := NumGet(lParam, 0, 'Int'), this.y := NumGet(lParam, 4, 'Int')
			return this.OnEvent(wParam, lParam) ? true : DllCall('CallNextHookEx', 'Ptr', 0, 'Int', nCode, 'UInt', wParam, 'UInt', lParam)
		}
	}
	__Delete() {
		if this.cb
			ObjPtrAddRef(this), this.Stop(), CallbackFree(this.cb), this.cb := 0
	}
	Stop() => (this.Ptr ? (DllCall('UnhookWindowsHookEx', 'Ptr', this), this.Ptr := 0) : 0)
	; OnEvent(wParam, lParam) => false
	Start() {
		if this.Ptr
			return
		this.Ptr := DllCall('SetWindowsHookEx', 'Int', 14, 'Ptr', this.cb, 'Ptr', DllCall('GetModuleHandle', 'UInt', 0, 'Ptr'), 'UInt', 0, 'Ptr')
	}

	Wait(Key, Timeout := 0) {
		if (!RegExMatch(Key, "i)^([lrm]button|xbutton\d|wheel)\s*(up|down)?$", &m))
			throw Error('无效的鼠标按键')
		else if (m[2] = 'up' && m[1] != 'wheel' && !GetKeyState(m[1], 'P'))
			return 0
		Key := m[1] ' ' (m[2] = '' ? 'Down' : m[2]), this.Action := '', Timeout := Timeout ? A_TickCount + Timeout : 0
		while ((!Timeout || Timeout > A_TickCount) && (this.Action = '' || this.Action != Key))
			Sleep(-1)
		return (Timeout ? (A_TickCount > Timeout) : 0)
	}
}